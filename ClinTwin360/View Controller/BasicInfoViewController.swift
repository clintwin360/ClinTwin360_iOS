//
//  BasicInfoViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/17/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class BasicInfoViewController: UIViewController {
	
	@IBOutlet weak var birthdateField: LabeledTextFieldView!
	@IBOutlet weak var bioSexField: LabeledTextFieldView!
	@IBOutlet weak var heightField: LabeledTextFieldView!
	@IBOutlet weak var weightField: LabeledTextFieldView!
	@IBOutlet weak var zipcodeField: LabeledTextFieldView!
	@IBOutlet weak var nextButton: UIButton!
	
	var viewModel: BasicHealthViewModel!
	
	var pickerViewObject: BasicHealthPickerObject?
	var dummyView: UITextField?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFields()
		
		nextButton.layer.cornerRadius = 10.0
		nextButton.layer.borderWidth = 0.5
		nextButton.layer.borderColor = CommonColors.mediumGrey.cgColor
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		NotificationCenter.default.addObserver(self,
        selector: #selector(self.keyboardNotification(notification:)),
        name: UIResponder.keyboardWillShowNotification,
        object: nil)
		NotificationCenter.default.addObserver(self,
        selector: #selector(self.keyboardNotification(notification:)),
        name: UIResponder.keyboardWillHideNotification,
        object: nil)
		
		if viewModel == nil {
			viewModel = BasicHealthViewModel()
		} else {
			populateFieldsWithViewModel()
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
    
	private func setUpFields() {
		birthdateField.configure(title: "Birth Date", delegate: self)
		birthdateField.placeholder = "MM/DD/YYYY"
		birthdateField.textField.keyboardType = .numberPad
		
		bioSexField.configure(title: "Biological Sex", delegate: self)
		heightField.configure(title: "Height", delegate: self)
		
		weightField.configure(title: "Weight", delegate: self)
		weightField.placeholder = "in pounds"
		weightField.textField.keyboardType = .numberPad
		
		zipcodeField.configure(title: "Zipcode", delegate: self)
		zipcodeField.textField.keyboardType = .numberPad
	}
	
	private func populateFieldsWithViewModel() {
		birthdateField.text = viewModel.birthdateToDisplayString()
		bioSexField.text = viewModel.bioSex
		heightField.text = viewModel.heightToString()
		
		if let weight = viewModel.weight {
			weightField.text = "\(Int(weight))"
		}
	}
	
	private func postResponses() {
		showLoadingView()
		NetworkManager.shared.postBasicHealthDetails(healthModel: viewModel) { (success, error) in
			self.hideLoadingView()
			if error != nil || success == false {
				self.showNetworkError()
			} else {
				let healthDetailsConfirmVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HDConfirmViewController")
				self.navigationController?.pushViewController(healthDetailsConfirmVC, animated: true)
			}
		}
	}
	
	@objc func keyboardNotification(notification: NSNotification) {
		if let userInfo = notification.userInfo {
			let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			let endFrameY = endFrame?.origin.y ?? 0
			let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
			let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
			let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
			let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
			if endFrameY >= UIScreen.main.bounds.size.height {
				view.frame.origin.y = 0.0
			} else {
				if let height = endFrame?.size.height {
					view.frame.origin.y = -(height * 0.5)
				}
			}
			UIView.animate(withDuration: duration,
									   delay: TimeInterval(0),
									   options: animationCurve,
									   animations: { self.view.layoutIfNeeded() },
									   completion: nil)
		}
	}
	
	@IBAction func didTapNext(_ sender: UIButton) {
		view.endEditing(true)
		if viewModel.isValid {
			postResponses()
		} else {
			// Highlight individual invalid fields
			var isValid = viewModel.isBirthdateValid()
			birthdateField.isValid = isValid
			
			isValid = viewModel.isHeightValid()
			heightField.isValid = isValid
			
			isValid = viewModel.isWeightValid()
			weightField.isValid = isValid
			
			isValid = viewModel.isBioSexValid()
			bioSexField.isValid = isValid
			
			let alert = UIAlertController(title: "Error", message: "Please verify your responses are valid.", preferredStyle: .alert)
			let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
			alert.addAction(okAction)
			present(alert, animated: true, completion: nil)
		}
	}
}

extension BasicInfoViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if textField.keyboardType == .numberPad || textField == bioSexField.textField || textField == heightField.textField {
			let keyboardToolbar = UIToolbar()
			keyboardToolbar.sizeToFit()
			let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
			let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
			keyboardToolbar.items = [flexBarButton, doneBarButton]
			textField.inputAccessoryView = keyboardToolbar
		}
		
		guard textField == bioSexField.textField || textField == heightField.textField else { return }
		
		if textField == bioSexField.textField {
			pickerViewObject = BasicHealthPickerObject(type: .bioSex, delegate: self)
		} else if textField == heightField.textField {
			pickerViewObject = BasicHealthPickerObject(type: .height, delegate: self)
		}
		
		let pickerView = UIPickerView()
		pickerView.dataSource = pickerViewObject
		pickerView.delegate = pickerViewObject
		
		textField.inputView = pickerView
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField == birthdateField.textField {
			var newString = ""
			if string.count > 0 {
				newString = "\(textField.text ?? "")\(string)".replacingOccurrences(of: "/", with: "")
				if newString.count > 8 { return false }
			} else {
				if let text = textField.text {
					newString = String(text.dropLast()).replacingOccurrences(of: "/", with: "")
				}
			}
			
			if newString.count > 4 {
				let midStartIndex = newString.index(newString.startIndex, offsetBy: 2)
				let midEndIndex = newString.index(newString.startIndex, offsetBy: 4)
				let range = midStartIndex..<midEndIndex

				let midString = newString[range]
				let suffixCount = newString.count - 4
				newString = "\(newString.prefix(2))/\(midString)/\(newString.suffix(suffixCount))"
			} else if newString.count == 4 {
				newString = "\(newString.prefix(2))/\(newString.suffix(2))"
			} else if newString.count == 3 {
				newString = "\(newString.prefix(2))/\(newString.suffix(1))"
			}
			textField.text = newString
			
			return false
		} else if textField == weightField.textField {
			if (textField.text ?? "").count == 3 && string.count > 0 {
				return false
			}
		} else if textField == zipcodeField.textField {
			if (textField.text ?? "").count == 5 && string.count > 0 {
				return false
			}
		}
		
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField == heightField.textField {
			let valid = viewModel.setHeightFromString(textField.text)
			heightField.isValid = valid
		} else if textField == weightField.textField {
			let valid = viewModel.setWeightFromString(textField.text)
			weightField.isValid = valid
		} else if textField == birthdateField.textField {
			let valid = viewModel.formatBirthdateFromString(textField.text)
			birthdateField.isValid = valid
		} else if textField == bioSexField.textField {
			viewModel.bioSex = textField.text
			let valid = viewModel.isBioSexValid()
			bioSexField.isValid = valid
		}
	}
}

extension BasicInfoViewController: BasicHealthPickerObjectDelegate {
	func didSelectText(_ text: String, forType type: BasicHealthPickerType) {
		if type == .bioSex {
			bioSexField.text = text
		} else if type == .height {
			heightField.text = text
		}
	}
	
	
}
