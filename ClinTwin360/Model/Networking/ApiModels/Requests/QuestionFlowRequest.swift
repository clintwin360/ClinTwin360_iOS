//
//  QuestionFlowRequest.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 5/1/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

struct QuestionFlowRequest: Encodable {
	let id: Int
	
	enum CodingKeys: String, CodingKey {
		case id = "particpant_id"
	}
}
