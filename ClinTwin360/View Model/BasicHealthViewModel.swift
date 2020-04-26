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
		if isHeightValid() == false { valid = false }
		if isWeightValid() == false { valid = false }
		if isBirthdateValid() == false { valid = false }
		if isBioSexValid() == false { valid = false }
		return valid
	}
	
	func setHeightFromInches(_ inches: Double) {
		height = Float(inches)
	}
	
	func setHeightFromString(_ heightString: String?) -> Bool {
		guard (heightString?.count ?? 0) > 0 else {
			height = nil
			return true
		}
		let components = heightString?.components(separatedBy: "'")
		guard let feet = Int(components?.first ?? "") else { return false }
		guard let inches = Int(components?.last?.replacingOccurrences(of: "\"", with: "") ?? "") else { return false }
		
		let totalInches = (feet * 12) + inches
		
		height = Float(totalInches)
		
		return isHeightValid()
	}
	
	func isHeightValid() -> Bool {
		if let h = height {
			return h >= 24 && h <= 96
		} else {
			return true
		}
	}
	
	func setWeightFromString(_ weightString: String?) -> Bool {
		guard let weight = weightString, weight.count > 0 else {
			self.weight = nil
			return true
		}
		self.weight = Float(weight)
		return isWeightValid()
	}
	
	func isWeightValid() -> Bool {
		if let weight = self.weight {
			return weight > 0 && weight < 1000
		} else {
			return true
		}
	}
	
	func formatBirthdateFromString(_ birthdateString: String?) -> Bool {
		guard let bday = birthdateString else {
			birthdate = nil
			return true
		}
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy"
		guard let shortDate = dateFormatter.date(from: bday) else {
			birthdate = nil
			return false
		}
		
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let birthdate = dateFormatter.string(from: shortDate)
		self.birthdate = birthdate
		
		return isBirthdateValid()
	}
	
	func isBirthdateValid() -> Bool {
		guard let bday = birthdate else {
			return true
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		guard let birthdate = dateFormatter.date(from: bday) else { return false }
		
		let currentDate = Date()
		let calendar = Calendar.current
		let backDate = calendar.date(byAdding: .year, value: -150, to: currentDate)!
		
		return birthdate < currentDate && birthdate > backDate
	}
	
	func isBioSexValid() -> Bool {
		if let bioSex = self.bioSex {
			return bioSex == "Male" || bioSex == "Female"
		} else {
			return true
		}
	}
}
