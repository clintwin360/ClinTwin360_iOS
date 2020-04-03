//
//  RegisterUserRequest.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/2/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation


struct RegisterUserRequest: Encodable {
//	let firstName: String
//	let lastName: String
//	let email: String
	let username: String
	let password: String
}
