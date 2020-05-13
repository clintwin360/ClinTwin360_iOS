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
			return false
		}
		let components = heightString?.components(separatedBy: "'")
		guard let feet = Int(components?.first ?? "") else {
			height = -1
			return false
		}
		guard let inches = Int(components?.last?.replacingOccurrences(of: "\"", with: "") ?? "") else {
			height = -1
			return false
		}
		
		let totalInches = (feet * 12) + inches
		height = Float(totalInches)
		
		return isHeightValid()
	}
	
	func isHeightValid() -> Bool {
		if let h = height {
			return h >= 24 && h <= 96
		} else {
			return false
		}
	}
	
	/**
	Converts the height saved from Apple Health data into the user-readable format.

	- Returns: A user-readable height string, if able to format.
	*/
	func heightToString() -> String? {
		guard let height = self.height else { return nil }

		let feet = Int(height/12)
		let inches = Int(height.remainder(dividingBy: 12.0))
		return "\(feet)'\(inches)\""
	}
	
	func setWeightFromString(_ weightString: String?) -> Bool {
		guard let weight = weightString, weight.count > 0 else {
			self.weight = nil
			return false
		}
		guard let floatValue = Float(weight) else {
			self.weight = -1
			return false
		}
		
		self.weight = floatValue
		
		return isWeightValid()
	}
	
	func isWeightValid() -> Bool {
		if let weight = self.weight {
			return weight > 0 && weight < 1000
		} else {
			return false
		}
	}
	
	/**
	Converts the user-entered birthdate string into the format accepted by the api.

	- Parameter birthdateString: The date string to format.
	- Returns: A boolean for whether the provided birthdate was valid.
	*/
	func formatBirthdateFromString(_ birthdateString: String?) -> Bool {
		guard let bday = birthdateString, bday.count > 0 else {
			birthdate = nil
			return false
		}
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy"
		guard let shortDate = dateFormatter.date(from: bday) else {
			birthdate = "-1"
			return false
		}
		
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let birthdate = dateFormatter.string(from: shortDate)
		self.birthdate = birthdate
		
		return isBirthdateValid()
	}
	
	func isBirthdateValid() -> Bool {
		guard let bday = birthdate else {
			return false
		}
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		guard let birthdate = dateFormatter.date(from: bday) else { return false }
		
		let currentDate = Date()
		let calendar = Calendar.current
		let backDate = calendar.date(byAdding: .year, value: -150, to: currentDate)!
		
		return birthdate < currentDate && birthdate > backDate
	}
	
	/**
	Converts the birthdate saved from Apple Health data into the user-readable format.

	- Returns: A user-readable birthdate string, if able to format.
	*/
	func birthdateToDisplayString() -> String? {
		guard let birthdate = self.birthdate else { return nil }
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		guard let date = dateFormatter.date(from: birthdate) else { return nil }
		dateFormatter.dateFormat = "MM/dd/yyyy"
		
		return dateFormatter.string(from: date)
	}
	
	func isBioSexValid() -> Bool {
		if let bioSex = self.bioSex {
			return bioSex == "Male" || bioSex == "Female" || bioSex == "Other"
		} else {
			return false
		}
	}
}
