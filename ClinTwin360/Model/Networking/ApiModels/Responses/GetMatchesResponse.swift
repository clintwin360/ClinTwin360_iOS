//
//  GetMatchesResponse.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/8/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

class GetMatchesReponse: Decodable {
	let count: Int?
	let next: String?
	let previous: String?
	let results: [TrialResult]?
}

class TrialResult: Decodable {
	let clinicalTrial: TrialObject
	let id: Int?
	let expressedInterest: Bool?
	var hasTasks: Int?
	
	enum CodingKeys: String, CodingKey {
		case clinicalTrial = "clinical_trial"
		case id
		case expressedInterest = "expressed_interest"
		case hasTasks = "has_tasks"
	}
}

struct TrialObject: Decodable {
	let trialId: Int
	let customId: String
	let currentRecruitment: Int?
	let enrollmentTarget: Int?
	let description: String?
	let objective: String?
	let recruitmentStartDate: String?
	let recruitmentEndDate: String?
	let sponsor: TrialSponsor?
	let status: String?
	let title: String
	let url: String?
	let isVirtualTrial: Bool
	
	enum CodingKeys: String, CodingKey {
	    case trialId = "id"
		case customId = "custom_id"
		case currentRecruitment = "current_recruitment"
		case enrollmentTarget
		case description
		case objective
		case recruitmentStartDate
		case recruitmentEndDate
		case sponsor
		case status
		case title
		case url
		case isVirtualTrial = "is_virtual"
	}
}

struct TrialSponsor: Decodable {
	let contactPerson: String
	let email: String?
	let organization: String?
}
