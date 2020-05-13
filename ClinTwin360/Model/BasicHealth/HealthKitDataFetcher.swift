//
//  HealthKitDataFetcher.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/14/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitDataFetcher {
	
	let healthKitStore = HKHealthStore()
	
	func pullHealthKitData(completion: @escaping (_ data: (height: Double?,
																	weight: Double?,
																	biologicalSex: HKBiologicalSex?,
																	birthdate: String?)) -> ()) {
		let bioSex = pullBiologicalSex()
		let birthdate = pullBirthdate()
		
		pullHeightData { (heightData) in
			let height = heightData
			
			self.pullWeightData { (weightData) in
				let weight = weightData
				
				completion((height: height,
							weight: weight,
							biologicalSex: bioSex,
							birthdate: birthdate))
			}
		}
	}
	
	private func pullHeightData(completion: @escaping (_ height: Double?)->()) {
		let heightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.height)!
		let heightQuery = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
			if let result = results?.first as? HKQuantitySample{
				let height = result.quantity.doubleValue(for: HKUnit(from: "in"))
				print("Height => \(height)")
				completion(height)
			} else{
				completion(nil)
			}
		}
		healthKitStore.execute(heightQuery)
	}
	
	private func pullWeightData(completion: @escaping (_ weight: Double?)->()) {
		let weightType = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
		let weightQuery = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: nil) { (query, results, error) in
			if let result = results?.first as? HKQuantitySample{
				let weight = result.quantity.doubleValue(for: HKUnit(from: "lb"))
				print("Weight => \(weight)")
				completion(weight)
			} else{
				completion(nil)
			}
		}
		healthKitStore.execute(weightQuery)
	}
	
	private func pullBiologicalSex() -> HKBiologicalSex? {
		let biologicalSex = try? healthKitStore.biologicalSex()
		return biologicalSex?.biologicalSex
	}
	
	private func pullBirthdate() -> String? {
		let birthdayComponents =  try? healthKitStore.dateOfBirthComponents()
		var dateString = ""
		if let month = birthdayComponents?.month, let day = birthdayComponents?.day, let year = birthdayComponents?.year {
			dateString = "\(month)/\(day)/\(year)"
		}
		
		return dateString
	}
	
	func healthViewModelFromData(_ data: (height: Double?,
													weight: Double?,
													biologicalSex: HKBiologicalSex?,
													birthdate: String?)) -> BasicHealthViewModel {
		
		let healthVM = BasicHealthViewModel()
		if let height = data.height {
			healthVM.setHeightFromInches(height)
		}
		if let weight = data.weight {
			let _ = healthVM.setWeightFromString("\(weight)")
		}
		if let bioSex = data.biologicalSex {
			switch bioSex {
			case .female: healthVM.bioSex = "Female"
			case .male: healthVM.bioSex = "Male"
			default: break
			}
		}
		if let birthdate = data.birthdate {
			let _ = healthVM.formatBirthdateFromString(birthdate)
		}
		
		return healthVM
	}
}
