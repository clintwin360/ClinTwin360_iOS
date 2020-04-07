//
//  BasicHealthViewModel.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/6/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation

class BasicHealthViewModel {
	
	var height: Float?
	var weight: Float?
	var birthdate: String?
	var bioSex: String?
	
	var isValid: Bool {
		var valid = true
		if height == nil { valid = false }
		if weight == nil { valid = false }
		if birthdate == nil { valid = false }
		if bioSex == nil { valid = false }
		return valid
	}
	
	func setHeightFromString(_ heightString: String?) {
		let components = heightString?.components(separatedBy: "'")
		guard let feet = Int(components?.first ?? "") else { return }
		guard let inches = Int(components?.last?.replacingOccurrences(of: "\"", with: "") ?? "") else { return }
		
		let totalInches = (feet * 12) + inches
		
		height = Float(totalInches)
	}
	
	func setWeightFromString(_ weightString: String?) {
		weight = Float(weightString ?? "")
	}
	
	func formatBirthdateFromString(_ birthdateString: String?) {
		guard let bday = birthdateString else {
			birthdate = nil
			return
		}
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy"
		guard let shortDate = dateFormatter.date(from: bday) else {
			birthdate = nil
			return
		}
		
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let birthdate = dateFormatter.string(from: shortDate)
		self.birthdate = birthdate
	}
}
