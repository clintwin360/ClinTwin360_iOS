//
//  EnrollInTrialRequest.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/29/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

struct EnrollInTrialRequest: Encodable {
	let participant: Int
	let trialId: Int
	
	enum CodingKeys: String, CodingKey {
		case participant
		case trialId = "clinical_trial"
	}
}
