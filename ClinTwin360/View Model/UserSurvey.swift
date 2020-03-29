//
//  UserSurvey.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/29/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import ResearchKit

struct UserSurvey {
	var questions: [ResearchQuestion]
	var surveyTask: ORKOrderedTask {
		return surveyTaskFromQuestions()
	}
	
	var responses: [ResearchQuestionAnswer] = []
	
	init(questions: [ResearchQuestion]) {
		self.questions = questions
	}
	
	private func surveyTaskFromQuestions() -> ORKOrderedTask {
		var steps = [ORKStep]()
		
		questions.enumerated().forEach { (index, question) in
			let title = question.text
			
			var textChoices: [ORKTextChoice] = []
			let options = question.options.components(separatedBy: ", ") // can remove once options is converted to array
			options.enumerated().forEach { (index, option) in
				let text = option.replacingOccurrences(of: "[", with: "")
					.replacingOccurrences(of: "]", with: "")
					.replacingOccurrences(of: "\"", with: "")
					.capitalized
				let choice = ORKTextChoice(text: text, value: index as NSNumber)
				textChoices += [choice]
			}
			
			let format: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
			let questionStep = ORKQuestionStep(identifier: "\(question.id)", title: nil, question: title, answer: format)
			steps += [questionStep]
		}
		
		return ORKOrderedTask(identifier: "SurveyTask", steps: steps)
	}
	
	mutating func parseAnswers(fromTaskResult result: ORKTaskResult) {
		responses.removeAll()
		
		if let results = result.results {
			results.forEach {
				guard let stepResult = $0 as? ORKStepResult else { return }
				guard let questionResults = stepResult.results else { return }
				questionResults.forEach { (questionResult) in
					if let choiceQuestionResult = questionResult as? ORKChoiceQuestionResult {
						guard let question = questions.first(where: { (question) -> Bool in
							return question.id == Int(questionResult.identifier)
						}) else { return }
						
						if let cqrAnswer = choiceQuestionResult.choiceAnswers?.first as? Int {
							let optionsComponents = question.options.components(separatedBy: ", ")
							
							let matchedOption = optionsComponents[cqrAnswer]
								.replacingOccurrences(of: "[", with: "")
								.replacingOccurrences(of: "]", with: "")
								.replacingOccurrences(of: "\"", with: "")
							let answer = ResearchQuestionAnswer(question: question.id, value: matchedOption)
							responses.append(answer)
						}
					}
				}
			}
		}
	}
}
