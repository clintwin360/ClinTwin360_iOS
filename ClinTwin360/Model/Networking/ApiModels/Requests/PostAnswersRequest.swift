//
//  PostAnswersRequest.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/29/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

//struct PostAnswersRequest: Encodable {
//	let question: String
//	let participant: Int
//	let value: String
//}

struct ResearchQuestionAnswer: Encodable {
	let question: Int
	let value: String
	let participant: Int = 1 // TODO: change later
}
