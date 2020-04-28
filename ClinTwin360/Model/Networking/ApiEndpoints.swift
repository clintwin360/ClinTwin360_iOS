//
//  ApiEndpoints.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/28/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

struct ApiEndpoints {
	static let base = 						"https://clintwin.com/"
	static let registerEndpoint = 			"api/register/"
	static let participantEndpoint = 		"api/participant/"
	static let pushNotificationsEndpoint = 	"api/device/apns/"
	static let loginEndpoint = 				"api/auth-token/"
	static let basicHealthEndpoint = 		"api/health/"
	static let questionsEndpoint = 			"api/questions/"
//	static let questionsEndpoint = "sponsor/question_flow"
	static let responsesEndpoint = 			"api/responses/"
	static let matchesEndpoint = 			"api/matches/"
	static let trialDetailsEndpoint = 		"api/trials/"
	static let signOutEndpoint = 			"api/logout/"
	static let forgotPasswordEndpoint =		"api/password_reset/"
}
