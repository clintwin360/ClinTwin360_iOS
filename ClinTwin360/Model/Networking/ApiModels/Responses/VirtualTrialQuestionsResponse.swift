//
//  VirtualTrialQuestionsResponse.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 5/3/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

class VirtualTrialQuestionsResponse: Decodable {
	let count: Int
	let next: String?
	let previous: String?
	let results: [VirtualTrialQuestion]?
}

class VirtualTrialQuestion: Decodable {
	let id: Int
	let options: AnyObject?
	let text: String?
	let type: QuestionType
	
	enum CodingKeys: String, CodingKey {
	    case id
		case options
		case text
		case type = "valueType"
	}
	
	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(Int.self, forKey: .id)
		text = try? values.decode(String.self, forKey: .text)
		type = try values.decode(QuestionType.self, forKey: .type)
		
		switch type {
		case .multipleChoice, .singleChoice, .yesNo:
			options = try? values.decode([String].self, forKey: .options) as AnyObject
		case .largeSet:
			options = try? values.decode(LargeOptionSetData.self, forKey: .options) as AnyObject
		case .freeText, .numberValue:
			options = try? values.decode(String.self, forKey: .options) as AnyObject
		@unknown default:
			options = nil
		}
	}
}

