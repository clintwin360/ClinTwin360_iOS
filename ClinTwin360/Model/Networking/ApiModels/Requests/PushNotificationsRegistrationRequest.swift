//
//  PushNotificationsRegistrationRequest.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/22/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

struct PushNotificationsRegistrationRequest: Encodable {
	let name: String
	let registrationId: String
	
	enum CodingKeys: String, CodingKey {
		case name
		case registrationId = "registration_id"
	}
}
