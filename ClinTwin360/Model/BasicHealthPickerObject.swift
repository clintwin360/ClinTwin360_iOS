//
//  BasicHealthPickerObject.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/7/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import UIKit

enum BasicHealthPickerType {
	case bioSex
	case height
}

protocol BasicHealthPickerObjectDelegate: class {
	func didSelectText(_ text: String, forType type: BasicHealthPickerType)
}

class BasicHealthPickerObject: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
	
	var displayedType: BasicHealthPickerType!
	
	var bioSexDataSource = ["Male", "Female"]
	var heightDataSource = [["3'", "4'", "5'", "6'", "7'"],
							["0\"", "1\"", "2\"", "3\"", "4\"", "5\"", "6\"", "7\"", "8\"", "9\"", "10\"", "11\""]]
	
	weak var delegate: BasicHealthPickerObjectDelegate?
	
	init(type: BasicHealthPickerType, delegate: BasicHealthPickerObjectDelegate) {
		self.displayedType = type
		self.delegate = delegate
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		if displayedType == .bioSex {
			return 1
		} else if displayedType == .height {
			return 2
		}
		return 0
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		if displayedType == .bioSex {
			return bioSexDataSource.count
		} else if displayedType == .height {
			return heightDataSource[component].count
		}
		return 0
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if displayedType == .bioSex {
			return bioSexDataSource[row]
		} else if displayedType == .height {
			return heightDataSource[component][row]
		}
		return nil
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		if displayedType == .bioSex {
			delegate?.didSelectText(bioSexDataSource[row], forType: .bioSex)
		} else if displayedType == .height {
			let feetRow = pickerView.selectedRow(inComponent: 0)
			let feet = heightDataSource[0][feetRow]
			let inchesRow = pickerView.selectedRow(inComponent: 1)
			let inches = heightDataSource[1][inchesRow]
			let text = "\(feet)\(inches)"
			delegate?.didSelectText(text, forType: .height)
		}
	}
	
	
}
