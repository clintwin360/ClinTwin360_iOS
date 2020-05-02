//
//  VirtualTrialQuestionsRequest.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 5/2/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

struct VirtualTrialQuestionsRequest: Encodable {
	let trialId: Int
	
	enum CodingKeys: String, CodingKey {
		case trialId = "clinical_trial"
	}
}
