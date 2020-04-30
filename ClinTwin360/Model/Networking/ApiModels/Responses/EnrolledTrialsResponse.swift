//
//  EnrolledTrialsResponse.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/29/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

struct EnrolledTrialsResponse: Decodable {
	let count: Int
	let next: String?
	let previous: String?
	let results: [TrialResult]
}
