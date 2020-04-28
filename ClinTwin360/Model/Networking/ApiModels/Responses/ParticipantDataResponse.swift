//
//  ParticipantDataResponse.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/27/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

struct ParticipantDataResponse: Decodable {
	var id: Int
	var firstName: String?
	var lastName: String?
	var email: String?
	
	enum CodingKeys: String, CodingKey {
	    case id
		case firstName = "first_name"
		case lastName = "last_name"
		case email
	}
}
