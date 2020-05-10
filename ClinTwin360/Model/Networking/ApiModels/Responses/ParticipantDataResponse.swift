//
//  ParticipantDataResponse.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/27/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

class ParticipantDataResponse: Decodable {
	var id: Int
	var firstName: String?
	var lastName: String?
	var email: String?
	var completedBasicHealth: Bool
	
	enum CodingKeys: String, CodingKey {
	    case id
		case firstName = "first_name"
		case lastName = "last_name"
		case email
		case completedBasicHealth = "basic_health_submitted"
	}
	
//	required init(from decoder: Decoder) throws {
//		let values = try decoder.container(keyedBy: CodingKeys.self)
//		id = try values.decode(Int.self, forKey: .id)
//		firstName = try? values.decode(String.self, forKey: .firstName)
//		lastName = try? values.decode(String.self, forKey: .lastName)
//		email = try? values.decode(String.self, forKey: .email)
//		
//		let basicHealth = try values.decode(Int.self, forKey: .completedBasicHealth)
//		completedBasicHealth = Bool(exactly: NSNumber(value: basicHealth))!
//	}
}
