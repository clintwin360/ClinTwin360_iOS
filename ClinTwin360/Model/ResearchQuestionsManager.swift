//
//  ResearchQuestionsManager.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/19/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import Alamofire

class ResearchQuestionsManager {
	
	static let shared = ResearchQuestionsManager()
	static let primaryQuestionLimit = 15
	
	private init() {}
	
	var currentUserSurvey: UserSurvey?
	var participantId: Int? {
		return KeychainWrapper.standard.integer(forKey: "userId")
	}
	
	func startSurvey(completion: @escaping (_ survey: UserSurvey?, _ error: AFError?) -> ()) {
		getQuestions { (success, error) in
			if success && error == nil {
				completion(self.currentUserSurvey, nil)
			} else {
				completion(nil, error)
			}
		}
	}
	
	func startVirtualTrialSurvey(trial: TrialObject, completion: @escaping (_ survey: UserSurvey?, _ error: AFError?) -> ()) {
		getVirtualTrialQuestions(trial: trial) { (success, error) in
			if success && error == nil {
				completion(self.currentUserSurvey, nil)
			} else {
				completion(nil, error)
			}
		}
	}
	
	private func getQuestions(completion: @escaping (_ success: Bool, _ error: AFError?) -> ()) {
		NetworkManager.shared.getQuestionFlow { (response) in
			if let error = response?.error {
				completion(false, error)
			} else if let value = response?.value {
				self.prepareSurveyWithResponse(value)
				completion(true, nil)
			} else {
				completion(false, nil)
			}
		}
	}
	
	private func getVirtualTrialQuestions(trial: TrialObject, completion: @escaping (_ success: Bool, _ error: AFError?) -> ()) {
		NetworkManager.shared.getQuestionsForVirtualTrial(trial) { (response) in
			if let error = response?.error {
				completion(false, error)
			} else if let value = response?.value {
				self.prepareVirtualTrialSurveyWithResponse(value)
				completion(true, nil)
			} else {
				completion(false, nil)
			}
		}
	}
	
	private func prepareSurveyWithResponse(_ response: QuestionFlowResponse) {
		if let responseQuestions = response.questions {
			var questions = self.sortQuestionsByPriority(responseQuestions)
			questions = self.limitAmountOfPrimaryQuestions(questions)
			self.currentUserSurvey = UserSurvey(questions: questions)
		}
	}
	
	private func prepareVirtualTrialSurveyWithResponse(_ response: VirtualTrialQuestionsResponse) {
		if let responseQuestions = response.results {
			let questions = convertVirtualTrialQuestionsToStandard(responseQuestions)
			self.currentUserSurvey = UserSurvey(questions: questions)
		}
	}
	
	private func convertVirtualTrialQuestionsToStandard(_ vtQuestions: [VirtualTrialQuestion]) -> [Question] {
		var questions = [Question]()
		vtQuestions.forEach {
			let question = Question(virtualTrialQuestion: $0)
			questions.append(question)
		}
		return questions
	}
	
	private func sortQuestionsByPriority(_ questions: [Question]) -> [Question] {
		var sortedQuestions = [Question]()
		
		var hashTable = [Int:Question]()
		questions.forEach({hashTable[$0.id] = $0})
		
		var mutableQuestions = questions
		mutableQuestions = mutableQuestions.filter{$0.isFollowup == 0}
		mutableQuestions.sort(by: {$0.rank > $1.rank})
		mutableQuestions.forEach { question in
			sortedQuestions.append(question)
			
			if let followups = flatMapFollowUpTreeForQuestion(question, withTable: hashTable) {
				sortedQuestions.append(contentsOf: followups)
			}
		}
		return sortedQuestions
	}
	
	private func flatMapFollowUpTreeForQuestion(_ question: Question, withTable table: [Int:Question]) -> [Question]? {
		guard let followups = question.followups, followups.count > 0 else { return nil }

		var sorted = [Question]()

		let removedDuplicates = Array(Set(followups))
		removedDuplicates.forEach {
			if let followupQuestion = table[$0.nextQuestion] {
				followupQuestion.parent = question
				sorted.append(followupQuestion)
				
				if let mapped = flatMapFollowUpTreeForQuestion(followupQuestion, withTable: table) {
					sorted.append(contentsOf: mapped)
				}
			}
		}
		sorted.sort { $0.id < $1.id }
		return sorted
	}

	private func limitAmountOfPrimaryQuestions(_ questions: [Question]) -> [Question] {
		var limitedQuestions = [Question]()
		var counter = 0
		for question in questions {
			limitedQuestions.append(question)
			if question.isFollowup == 0 {
				counter += 1
				
				if counter == ResearchQuestionsManager.primaryQuestionLimit {
					break
				}
			}
		}
		
		return limitedQuestions
	}
	
	func parseAnswers(fromTaskResult result: ORKTaskResult) -> [ResearchQuestionAnswer] {
		var responses = [ResearchQuestionAnswer]()
		if let results = result.results, let researchQuestions = currentUserSurvey?.questions {
			results.forEach {
				guard let stepResult = $0 as? ORKStepResult else { return }
				guard let questionResults = stepResult.results else { return }
				questionResults.forEach { (questionResult) in
					guard let question = questionWithIdentifier(questionResult.identifier, inQuestions: researchQuestions) else { return }
					
					var response: ResearchQuestionAnswer?
					
					// Boolean question response
					if let yesNoResult = questionResult as? ORKBooleanQuestionResult {
						response = responseForYesNoQuestion(fromResult: yesNoResult, withQuestionId: question.id)
					}
					
					// Text question response
					if let freeTextResult = questionResult as? ORKTextQuestionResult {
						response = responseForFreeTextQuestion(fromResult: freeTextResult, withQuestionId: question.id)
					}
					
					// Single-choice, multiple-choice, or picker response
					if let choiceQuestionResult = questionResult as? ORKChoiceQuestionResult {
						if question.type == .largeSet {
							response = responseForPickerQuestion(fromResult: choiceQuestionResult, withQuestion: question)
						} else {
							response = responseForChoiceQuestion(fromResult: choiceQuestionResult, withQuestion: question)
						}
					}
					
					if let r = response {
						responses.append(r)
					}
				}
			}
		}
		currentUserSurvey?.setResponses(responses)
		
		return responses
	}
	
	private func questionWithIdentifier(_ identifier: String, inQuestions questions: [Question]) -> Question? {
		let question = questions.first(where: { (question) -> Bool in
			return question.id == Int(identifier)
		})
		
		return question
	}
	
	private func responseForYesNoQuestion(fromResult result: ORKBooleanQuestionResult, withQuestionId id: Int) -> ResearchQuestionAnswer? {
		guard let participantId = self.participantId else { return nil }
		guard let response = result.booleanAnswer else { return nil }
		var yesNoResponse = "No"
		if response.intValue == 1 {
			yesNoResponse = "Yes"
		}
		return ResearchQuestionAnswer(question: id, value: yesNoResponse, participant: participantId)
	}
	
	private func responseForFreeTextQuestion(fromResult result: ORKTextQuestionResult, withQuestionId id: Int) -> ResearchQuestionAnswer? {
		guard let participantId = self.participantId else { return nil }
		guard let response = result.textAnswer else { return nil }
		return ResearchQuestionAnswer(question: id, value: response, participant: participantId)
	}
	
	private func responseForChoiceQuestion(fromResult result: ORKChoiceQuestionResult, withQuestion question: Question) -> ResearchQuestionAnswer? {
		guard let participantId = self.participantId else { return nil }
		guard let choiceAnswers = result.choiceAnswers else { return nil }
		
		var response = ""
		choiceAnswers.forEach { answer in
			guard let numValue = answer as? Int else { return }
			guard let matchedOption = getMatchedOptionFromResponse(numValue, forQuestion: question) else { return }
			if response.count == 0 {
				response = matchedOption
			} else {
				response += ", \(matchedOption)"
			}
		}
		guard response.count > 0 else { return nil }
		let answer = ResearchQuestionAnswer(question: question.id, value: response, participant: participantId)
		return answer
	}
	
	private func responseForPickerQuestion(fromResult result: ORKChoiceQuestionResult, withQuestion question: Question) -> ResearchQuestionAnswer? {
		guard let participantId = self.participantId else { return nil }
		guard let choiceAnswers = result.choiceAnswers else { return nil }
		
		var response = ""
		choiceAnswers.forEach { answer in
			if response.count == 0 {
				response = "\(answer)"
			} else {
				response += ", \(answer)"
			}
		}
		guard response.count > 0 else { return nil }
		let answer = ResearchQuestionAnswer(question: question.id, value: response, participant: participantId)
		return answer
	}
	
	private func getMatchedOptionFromResponse(_ response: Int, forQuestion question: Question) -> String? {
		guard let options = question.options as? [String] else { return nil }
		guard options.count > response else { return nil }

		let matchedOption = options[response]
		return matchedOption
	}
	
	func postResponses(_ responses: [ResearchQuestionAnswer]?, completion: @escaping (_ success: Bool) -> ()) {
		guard responses?.count ?? 0 > 0 else {
			completion(true)
			return
		}
		
		NetworkManager.shared.postSurveyResponse(responses!.first!) { (result) in
			// Ignoring result for now
			self.postResponses(Array(responses!.dropFirst())) { (success) in
				completion(success)
			}
		}
	}
	
	func postVirtualTrialResponses(_ responses: [ResearchQuestionAnswer]?, completion: @escaping (_ success: Bool) -> ()) {
		guard responses?.count ?? 0 > 0 else {
			completion(true)
			return
		}
		
		NetworkManager.shared.postVirtualTrialSurveyResponse(responses!.first!) { (result) in
			// Ignoring result for now
			self.postResponses(Array(responses!.dropFirst())) { (success) in
				completion(success)
			}
		}
	}
}
