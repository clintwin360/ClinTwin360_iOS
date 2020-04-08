//
//  GetQuestionsResponse.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/28/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation


struct GetQuestionsResponse: Decodable {
	let count: Int
	let next: String?
	let previous: String?
	let results: [ResearchQuestion]?
}

struct ResearchQuestion: Decodable {
	let id: Int
	let text: String
	let valueType: QuestionType
	let options: String
}

enum QuestionType: String, Decodable {
	case multipleChoice = "list"
	case yesNo = "yes_no"
	case singleChoice = "pick_one"
	case largeSet = "large_option_set"
}
