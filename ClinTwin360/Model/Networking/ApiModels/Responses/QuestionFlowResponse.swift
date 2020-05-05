//
//  QuestionFlowResponse.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/19/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

struct QuestionFlowResponse: Decodable {
	let questions: [Question]?
}

class Question: Decodable {
	let id: Int
	let followups: [QuestionFollowUp]?
	let isFollowup: Int
	let options: AnyObject?
	let rank: Int
	let text: String?
	let type: QuestionType
	weak var parent: Question?
	
	enum CodingKeys: String, CodingKey {
	    case id
		case followups
		case isFollowup = "is_followup"
		case options
		case rank
		case text
		case type = "value_type"
	}
	
	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(Int.self, forKey: .id)
		followups = try? values.decode([QuestionFollowUp].self, forKey: .followups)
		isFollowup = try values.decode(Int.self, forKey: .isFollowup)
		rank = try values.decode(Int.self, forKey: .rank)
		text = try? values.decode(String.self, forKey: .text)
		type = try values.decode(QuestionType.self, forKey: .type)
		parent = nil
		
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
	
	init(virtualTrialQuestion: VirtualTrialQuestion) {
		self.id = virtualTrialQuestion.id
		self.followups = nil
		self.isFollowup = 0
		self.rank = 0
		self.text = virtualTrialQuestion.text
		self.type = virtualTrialQuestion.type
		self.parent = nil
		self.options = virtualTrialQuestion.options
	}
}

struct LargeOptionSetData: Decodable {
	var increment: Double
	var min: Double
	var max: Double
	var unit: String
}

struct QuestionFollowUp: Decodable, Hashable, Equatable {
	let nextQuestion: Int
	let response: String
	
	enum CodingKeys: String, CodingKey {
	    case nextQuestion = "next_question"
		case response
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(nextQuestion)
	}
	
	static func ==(left: QuestionFollowUp, right: QuestionFollowUp) -> Bool {
		return left.nextQuestion == right.nextQuestion
	}
}

