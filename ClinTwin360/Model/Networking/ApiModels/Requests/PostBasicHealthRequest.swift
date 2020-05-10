//
//  PostBasicHealthRequest.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/6/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

struct PostBasicHealthRequest: Encodable {
	let participant: Int
	let height: Float?
	let weight: Float?
	let birthdate: String?
	let sex: String?
	
	enum CodingKeys: String, CodingKey {
		case participant
		case height
		case weight
		case birthdate = "birth_date"
		case sex
	}
}
