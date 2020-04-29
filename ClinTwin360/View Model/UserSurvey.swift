//
//  UserSurvey.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/29/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import ResearchKit

class UserSurvey {
	var questions: [Question]
	var surveyTask: ORKNavigableOrderedTask {
		return surveyTaskFromQuestions()
	}
	var responses: [ResearchQuestionAnswer] = [ResearchQuestionAnswer]()
	
	init(questions: [Question]) {
		self.questions = questions
	}
	
	private func surveyTaskFromQuestions() -> ORKNavigableOrderedTask {
		var steps = [ORKStep]()
		
		var predicateRules = [(String, ORKStepNavigationRule)]()
		questions.enumerated().forEach { (index, question) in
			let questionStep = surveyStepFromQuestion(question)
			steps += [questionStep]
			
			if let followUps = question.followups, followUps.count > 0 {
				// Create rule to navigate to follow-ups
				let rules = generatePredicateRuleForFollowUps(followUps, inQuestion: question)
				if let navigationRule = rules.0 {
					predicateRules.append(("\(question.id)", navigationRule))
				}
				if let directRule = rules.1 {
					predicateRules.append(("\(question.id)", directRule))
				}
			} else if question.isFollowup > 0 {
				// No more follow-ups but this question is a follow-up,
				if let parent = question.parent, parent.type == .multipleChoice {
					// Evaluate responses to parent question to see if other follow-ups need to be navigated to
					if let rule = generatePredicateRuleForFollowUp(question, forMultipleChoiceParent: parent) {
						predicateRules.append(("\(question.id)", rule))
					} else {
						// Navigate to next non-followup question
						let nextQuestionId = idOfNextNonFollowUpQuestion(afterQuestion: question)
						if let nq = nextQuestionId {
							let rule = ORKDirectStepNavigationRule(destinationStepIdentifier: "\(nq)")
							predicateRules.append(("\(question.id)", rule))
						} else {
							// No next non-follow-up question found, end the survey
							let endRule = ORKDirectStepNavigationRule(destinationStepIdentifier: ORKNullStepIdentifier)
							predicateRules.append(("\(question.id)", endRule))
						}
					}
				} else {
					// Navigate to next non-followup question
					let nextQuestionId = idOfNextNonFollowUpQuestion(afterQuestion: question)
					if let nq = nextQuestionId {
						let rule = ORKDirectStepNavigationRule(destinationStepIdentifier: "\(nq)")
						predicateRules.append(("\(question.id)", rule))
					} else {
						// No next non-follow-up question found, end the survey
						let endRule = ORKDirectStepNavigationRule(destinationStepIdentifier: ORKNullStepIdentifier)
						predicateRules.append(("\(question.id)", endRule))
					}
				}
			}
		}
		
		let navigableTask = ORKNavigableOrderedTask(identifier: "SurveyTask", steps: steps)
		predicateRules.forEach {
			navigableTask.setNavigationRule($0.1, forTriggerStepIdentifier: $0.0)
		}

		return navigableTask
	}
	
	private func surveyStepFromQuestion(_ question: Question) -> ORKQuestionStep {
		let title = question.text
		let textChoices = textChoicesForQuestion(question)
		
		// Determine the format to display the question
		var format: ORKAnswerFormat
		switch question.type {
		case .yesNo:
			format = .booleanAnswerFormat()
		case .singleChoice:
			format = .choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
		case .multipleChoice:
			format = .choiceAnswerFormat(with: .multipleChoice, textChoices: textChoices)
		case .largeSet:
			if textChoices.count > 0 {
				format = .valuePickerAnswerFormat(with: textChoices)
			} else {
				format = .textAnswerFormat()
			}
		case .freeText, .numberValue:
			format = .textAnswerFormat()
		}

		let questionStep = ORKQuestionStep(identifier: "\(question.id)", title: nil, question: title, answer: format)
		return questionStep
	}
	
	
	private func textChoicesForQuestion(_ question: Question) -> [ORKTextChoice] {
		var textChoices: [ORKTextChoice] = []
		if let textOptions = question.options as? [String] {
			textOptions.enumerated().forEach { (index, option) in
				let choice = ORKTextChoice(text: option, value: index as NSNumber)
				textChoices += [choice]
			}
		} else if let data = question.options as? LargeOptionSetData {
			let min = data.min
			let max = data.max
			for i in stride(from: min, through: max, by: data.increment) {
				let remainder = i.truncatingRemainder(dividingBy: 1)
				var choice: ORKTextChoice
				if remainder == 0 {
					choice = ORKTextChoice(text: "\(Int(i)) \(data.unit)", value: i as NSNumber)
				} else {
					choice = ORKTextChoice(text: "\(i) \(data.unit)", value: i as NSNumber)
				}
				textChoices += [choice]
			}
		}
		return textChoices
	}
	
	private func generatePredicateRuleForFollowUps(_ followUps: [QuestionFollowUp], inQuestion question: Question) -> (stepNavRule: ORKPredicateStepNavigationRule?, directStepRule: ORKDirectStepNavigationRule?) {
		var predicates = [(NSPredicate, String)]()
		var navigationRule: ORKPredicateStepNavigationRule?
		var directRule: ORKDirectStepNavigationRule?
		
		followUps.enumerated().forEach { (index, followUp) in
			let resultSelector = ORKResultSelector(resultIdentifier: "\(question.id)")
			var predicate: NSPredicate?
			switch question.type {
			case .yesNo:
				let expected = followUp.response.lowercased() == "yes" ? true : false
				predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: expected)
			case .singleChoice, .multipleChoice:
				if followUp.response == "not_applicable" {
					// Go directly to next question step
					directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: "\(followUp.nextQuestion)")
				} else {
					// Create predicate based on expected response
					let expectedResponseIndex = (question.options as? [String])?.firstIndex(of: followUp.response) ?? Int.max
					predicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: expectedResponseIndex as NSCoding & NSCopying & NSObjectProtocol)
				}
			default: return
			}
			
			if let p = predicate {
				predicates.append((p, "\(followUp.nextQuestion)"))
			}
		}
		
		if predicates.count > 0 {
			if let nextPrimaryId = idOfNextNonFollowUpQuestion(afterQuestion: question) {
				navigationRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: predicates, defaultStepIdentifierOrNil: "\(nextPrimaryId)")
			} else {
				navigationRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: predicates, defaultStepIdentifierOrNil: nil)
			}
		}
		return (navigationRule, directRule)
	}
	
	private func generatePredicateRuleForFollowUp(_ followUp: Question, forMultipleChoiceParent parent: Question) -> ORKPredicateStepNavigationRule? {
		var predicates = [(NSPredicate, String)]()
		let resultSelector = ORKResultSelector(resultIdentifier: "\(parent.id)")
		var predicate: NSPredicate
		
		guard let followUpResponseIndex = parent.followups?.firstIndex(where: {$0.nextQuestion == followUp.id}) else {
			return nil
		}
		guard followUpResponseIndex < parent.followups!.count - 1 else {
			return nil
		}
		var remainingFollowUpIndex = followUpResponseIndex + 1
		while remainingFollowUpIndex < parent.followups!.count {
			let followUpToEval = parent.followups![remainingFollowUpIndex]
			predicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: remainingFollowUpIndex as NSCoding & NSCopying & NSObjectProtocol)
			predicates.append((predicate, "\(followUpToEval.nextQuestion)"))
			remainingFollowUpIndex += 1
		}
		predicates = predicates.filter({Int($0.1) != followUp.id})
		
		if predicates.count > 0 {
			var navigationRule: ORKPredicateStepNavigationRule
			if let nextPrimaryId = idOfNextNonFollowUpQuestion(afterQuestion: followUp) {
				navigationRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: predicates, defaultStepIdentifierOrNil: "\(nextPrimaryId)")
			} else {
				navigationRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: predicates, defaultStepIdentifierOrNil: nil)
			}
			return navigationRule
		}
		return nil
	}
	
	private func idOfNextNonFollowUpQuestion(afterQuestion question: Question) -> Int? {
		let index = questions.firstIndex(where: {$0.id == question.id})!
		var nextQuestionId: Int? = nil
		for counter in (index + 1)..<questions.count {
			let q = questions[counter]
			if q.isFollowup == 0 {
				nextQuestionId = q.id
				break
			}
		}
		return nextQuestionId
	}


//	mutating func parseAnswers(fromTaskResult result: ORKTaskResult) {
//		responses.removeAll()
//
//		if let results = result.results {
//			results.forEach {
//				guard let stepResult = $0 as? ORKStepResult else { return }
//				guard let questionResults = stepResult.results else { return }
//				questionResults.forEach { (questionResult) in
//					if let choiceQuestionResult = questionResult as? ORKChoiceQuestionResult {
//						guard let question = researchQuestions.first(where: { (question) -> Bool in
//							return question.id == Int(questionResult.identifier)
//						}) else { return }
//
//						guard let choiceAnswers = choiceQuestionResult.choiceAnswers else { return }
//						if choiceAnswers.count == 1 {
//							if let cqrAnswer = choiceQuestionResult.choiceAnswers?.first as? Int {
//								if let matchedOption = getMatchedOptionFromResponse(cqrAnswer, forQuestion: question) {
//									let answer = ResearchQuestionAnswer(question: question.id, value: matchedOption)
//									responses.append(answer)
//								}
//
//							}
//						} else if choiceAnswers.count > 1 {
//							var response = ""
//							(choiceQuestionResult.choiceAnswers as? [Int])?.forEach { answer in
//								if let matchedOption = getMatchedOptionFromResponse(answer, forQuestion: question) {
//									if response.count == 0 {
//										response = matchedOption
//									} else {
//										response += ", \(matchedOption)"
//									}
//								}
//							}
//							let answer = ResearchQuestionAnswer(question: question.id, value: response)
//							responses.append(answer)
//						}
//					}
//				}
//			}
//		}
//	}
	
	private func getMatchedOptionFromResponse(_ response: Int, forQuestion question: ResearchQuestion) -> String? {
		let optionsComponents = question.options.components(separatedBy: ", ")
		
		guard optionsComponents.count > response else { return nil }

		let matchedOption = optionsComponents[response]
			.replacingOccurrences(of: "[", with: "")
			.replacingOccurrences(of: "]", with: "")
			.replacingOccurrences(of: "\"", with: "")
		
		return matchedOption
	}
	
	func setResponses(_ responses: [ResearchQuestionAnswer]) {
		self.responses = responses
	}
}
