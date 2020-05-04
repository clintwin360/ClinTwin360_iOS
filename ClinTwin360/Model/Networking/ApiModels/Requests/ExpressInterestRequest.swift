//
//  ExpressInterestRequest.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 5/1/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

struct ExpressInterestRequest: Encodable {
	let expressedInterest: Bool = true
	
	enum CodingKeys: String, CodingKey {
		case expressedInterest = "expressed_interest"
	}
}
