//
//  SurveyTask.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/13/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import ResearchKit

public var SurveyTask: ORKOrderedTask {
  
	var steps = [ORKStep]()
  
  	// Instructions step
	let instructionStep = ORKInstructionStep(identifier: "IntroStep")
	instructionStep.title = "The Questions Three"
	instructionStep.text = "Who would cross the Bridge of Death must answer me these questions three, ere the other side they see."
	steps += [instructionStep]
  
	// Name question
	let nameAnswerFormat = ORKTextAnswerFormat(maximumLength: 20)
	nameAnswerFormat.multipleLines = false
	let nameQuestionStepTitle = "What is your name?"
	let nameQuestionStep = ORKQuestionStep(identifier: "QuestionStep", title: nil, question: nameQuestionStepTitle, answer: nameAnswerFormat)
	steps += [nameQuestionStep]
  
	// What is your quest question
	let questQuestionStepTitle = "What is your quest?"
	let textChoices = [
	  ORKTextChoice(text: "Create a ResearchKit App", value: 0 as NSNumber),
	  ORKTextChoice(text: "Seek the Holy Grail", value: 1 as NSNumber),
	  ORKTextChoice(text: "Find a shrubbery", value: 2 as NSNumber)
	]
	let questAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
	let questQuestionStep = ORKQuestionStep(identifier: "TextChoiceQuestionStep", title: nil, question: questQuestionStepTitle, answer: questAnswerFormat)
	steps += [questQuestionStep]
  
    // Summary
	let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
	summaryStep.title = "Right. Off you go!"
	summaryStep.text = "That was easy!"
	steps += [summaryStep]
  
	return ORKOrderedTask(identifier: "SurveyTask", steps: steps)
}
