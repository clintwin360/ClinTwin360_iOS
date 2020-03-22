//
//  HealthKitSetupAssistant.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/17/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import HealthKit

enum HealthKitSetupError: Error, CustomStringConvertible {
	case notAvailableOnDevice
	case dataTypeNotAvailable
	
	var description: String {
		switch self {
		case .notAvailableOnDevice: return "HealthKit not available"
		case .dataTypeNotAvailable: return "Data type not available"
		}
	}
}

class HealthKitSetupAssistant {
	
	class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
		guard HKHealthStore.isHealthDataAvailable() else {
			completion(false, HealthKitSetupError.notAvailableOnDevice)
			return
		}
		
		guard let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
        let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
        let height = HKObjectType.quantityType(forIdentifier: .height),
        let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
        
        completion(false, HealthKitSetupError.dataTypeNotAvailable)
        return
		}
		
		let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
													   biologicalSex,
													   height,
													   bodyMass]
		
		HKHealthStore().requestAuthorization(toShare: nil,
											 read: healthKitTypesToRead) { (success, error) in
												completion(success, error)
		}
	}
}


    

