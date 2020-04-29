//
//  ResearchQuestionsManager.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/19/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import Alamofire
import ResearchKit

class ResearchQuestionsManager {
	
	var currentUserSurvey: UserSurvey?
	
	func startInitialSurvey(completion: @escaping (_ survey: UserSurvey?, _ error: AFError?) -> ()) {
		getQuestions { (success, error) in
			if success && error == nil {
				completion(self.currentUserSurvey, nil)
			} else {
				completion(nil, error)
			}
		}
	}
	
	func getQuestions(completion: @escaping (_ success: Bool, _ error: AFError?) -> ()) {
		NetworkManager.shared.getQuestionFlow { (response) in
			if let error = response?.error {
				completion(false, error)
			} else if let value = response?.value, let responseQuestions = value.questions {
				let questions = self.sortQuestionsByPriority(responseQuestions)
				self.currentUserSurvey = UserSurvey(questions: questions)
				completion(true, nil)
			} else {
				completion(false, nil)
			}
		}
	}
	
	func sortQuestionsByPriority(_ questions: [Question]) -> [Question] {
		var sortedQuestions = [Question]()
		
		var hashTable = [Int:Question]()
		questions.forEach({hashTable[$0.id] = $0})
		
		var mutableQuestions = questions
		mutableQuestions = mutableQuestions.filter{$0.isFollowup == 0}
		mutableQuestions.sort(by: {$0.rank > $1.rank})
		mutableQuestions.forEach { question in
			sortedQuestions.append(question)
			if let followups = question.followups, followups.count > 0 {
				let sortedFollowups = depthFirstSortFollowups(followups, forQuestion: question, withTable: hashTable).reversed()
				sortedQuestions.append(contentsOf: sortedFollowups)
			}
		}
		return sortedQuestions
	}
	
	func depthFirstSortFollowups(_ followups: [QuestionFollowUp], forQuestion parent: Question, withTable table: [Int:Question]) -> [Question] {
		var sorted = [Question]()
		
		let removedDuplicates = Array(Set(followups))
		removedDuplicates.forEach {
			if let followupQuestion = table[$0.nextQuestion] {
				followupQuestion.parent = parent
				sorted.append(followupQuestion)
				
				if let moreFollowups = followupQuestion.followups, moreFollowups.count > 0 {
					sorted.append(contentsOf: depthFirstSortFollowups(moreFollowups, forQuestion: followupQuestion, withTable: table))
				}
			}
		}
		return sorted
	}
	
	func parseAnswers(fromTaskResult result: ORKTaskResult) -> [ResearchQuestionAnswer] {
		return [ResearchQuestionAnswer]()
	}
}
