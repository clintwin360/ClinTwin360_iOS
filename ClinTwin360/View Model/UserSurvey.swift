//
//  UserSurvey.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/29/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation


class UserSurvey {
	var questions: [Question]
	var surveyTask: ORKNavigableOrderedTask {
		return surveyTaskFromQuestions()
	}
	var responses: [ResearchQuestionAnswer] = [ResearchQuestionAnswer]()
	
	init(questions: [Question]) {
		self.questions = questions
	}
	
	/**
	Creates the research survey based on the questions array.
	*/
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
					if let rule = generatePredicateRuleForFollowUp(question, forMultipleChoiceParent: parent, inQuestions:  questions) {
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
	
	/**
	Converts a question data object into an ORKQuestionStep to use in the survey.

	- Parameter question: The question object to convert to an ORKQuestionStep
	- Returns: An ORKQuestionStep
	*/
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
	
	/**
	Creates an array of choices to to display for a specified question.

	- Parameter question: The question to create the text choices for.
	- Returns: An array of ORKTextChoice
	*/
	private func textChoicesForQuestion(_ question: Question) -> [ORKTextChoice] {
		var textChoices: [ORKTextChoice] = []
		if let textOptions = question.options as? [String] {
			// Convert string to ORKTextChoice
			textOptions.enumerated().forEach { (index, option) in
				let choice = ORKTextChoice(text: option, value: index as NSNumber)
				textChoices += [choice]
			}
		} else if let data = question.options as? LargeOptionSetData {
			// Create the text choices that should appear in the picker
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
	
	/**
	Used to create a navigation rule to determine if a follow-up question should be asked, based on the response of the specified question.

	- Parameter followUps: The followups of the provided question.
	- Parameter parent: The question to evaluate.
	- Returns: An tuple that includes an optional predicate navigation rule and optional direct navigation rule.
	*/
	private func generatePredicateRuleForFollowUps(_ followUps: [QuestionFollowUp], inQuestion question: Question) -> (stepNavRule: ORKPredicateStepNavigationRule?, directStepRule: ORKDirectStepNavigationRule?) {
		var predicates = [(NSPredicate, String)]()
		var navigationRule: ORKPredicateStepNavigationRule?
		var directRule: ORKDirectStepNavigationRule?
		
		let nextQuestionIds = Set(followUps.map{$0.nextQuestion})
		if let options = question.options as? [String] {
			if followUps.count == options.count && nextQuestionIds.count == 1 {
				// Only one next question to go to, just create a direct step rule
				directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: "\(followUps.first!.nextQuestion)")
				return (nil, directRule)
			}
		}
		
		// Create predicate rules
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
			/*
			Check if there's a next primary question to go to if none of the predicates match,
			otherwise defaultStepIdentifier is nil to end the survey.
			*/
			if let nextPrimaryId = idOfNextNonFollowUpQuestion(afterQuestion: question) {
				navigationRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: predicates, defaultStepIdentifierOrNil: "\(nextPrimaryId)")
			} else {
				navigationRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: predicates, defaultStepIdentifierOrNil: nil)
			}
		}
		return (navigationRule, directRule)
	}
	
	/**
	Used to create a navigation rule to determine if any more follow-up questions should be asked, based on the responses of the multiple-choice parent question.

	- Parameter followUp: The followup question to evaluate.
	- Parameter parent: The primary question that the followUp is associated with.
	- Parameter questions: The full array of survey questions
	- Returns: An ORKPredicateStepNavigationRule, or nil if no followups remain.
	*/
	private func generatePredicateRuleForFollowUp(_ followUp: Question, forMultipleChoiceParent parent: Question, inQuestions questions: [Question]) -> ORKPredicateStepNavigationRule? {
		
		var predicates = [(NSPredicate, String)]()
		let resultSelector = ORKResultSelector(resultIdentifier: "\(parent.id)")
		var predicate: NSPredicate
		
		guard let followups = parent.followups else { return nil }
		guard let followUpResponseIndex = followups.lastIndex(where: {$0.nextQuestion == followUp.id}) else { return nil }
		guard followUpResponseIndex < followups.count - 1 else { return nil }
		
		/*
		Only add predicates for followups that come after this followup question in the parent's followup questions list.
		This ensures loops aren't created.
		*/
		for i in followUpResponseIndex..<followups.count {
			let followup = followups[i]
			let expectedResponseIndex = (parent.options as? [String])?.firstIndex(of: followup.response) ?? Int.max
			predicate = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector, expectedAnswerValue: expectedResponseIndex as NSCoding & NSCopying & NSObjectProtocol)
			predicates.append((predicate, "\(followup.nextQuestion)"))
		}
	
		// Sanity check, don't ask the same question again
		predicates = predicates.filter({Int($0.1) != followUp.id})
		
		if predicates.count > 0 {
			var navigationRule: ORKPredicateStepNavigationRule
			/*
			Check if there's a next primary question to go to if none of the predicates match,
			otherwise defaultStepIdentifier is nil to end the survey.
			*/
			if let nextPrimaryId = idOfNextNonFollowUpQuestion(afterQuestion: followUp) {
				navigationRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: predicates, defaultStepIdentifierOrNil: "\(nextPrimaryId)")
			} else {
				navigationRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: predicates, defaultStepIdentifierOrNil: nil)
			}
			return navigationRule
		}
		return nil
	}
	
	/**
	Used to find the identifier of a primary (non-followup) question that comes after a specified question.

	- Parameter question: The question to evaluate
	- Returns: The id of the next primary question or nil if none exists.
	*/
	private func idOfNextNonFollowUpQuestion(afterQuestion question: Question) -> Int? {
		let index = questions.firstIndex(where: {$0.id == question.id})!
		var nextQuestionId: Int? = nil
		for i in (index + 1)..<questions.count {
			let q = questions[i]
			if q.isFollowup == 0 {
				nextQuestionId = q.id
				break
			}
		}
		return nextQuestionId
	}
	
	func setResponses(_ responses: [ResearchQuestionAnswer]) {
		self.responses = responses
	}
}
