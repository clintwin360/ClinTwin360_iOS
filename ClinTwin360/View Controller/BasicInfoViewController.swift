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
	
	let viewModel = BasicHealthViewModel()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFields()
		
		nextButton.layer.cornerRadius = 10.0
		nextButton.layer.borderWidth = 0.5
		nextButton.layer.borderColor = CommonColors.mediumGrey.cgColor
    }
    
	private func setUpFields() {
		birthdateField.configure(title: "Birth Date", delegate: self)
		birthdateField.placeholder = "MM/DD/YYYY"
		bioSexField.configure(title: "Biological Sex", delegate: self)
		heightField.configure(title: "Height", delegate: self)
		weightField.configure(title: "Weight", delegate: self)
		zipcodeField.configure(title: "Zipcode", delegate: self)
	}
	
	private func postResponses() {
		view.endEditing(true)
		guard viewModel.isValid else { return }
 
		showLoadingView()
		NetworkManager.shared.postBasicHealthDetails(healthModel: viewModel) { (error) in
			self.hideLoadingView()
			if error != nil {
				self.showNetworkError()
			} else {
				let healthDetailsConfirmVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HDConfirmViewController")
				self.navigationController?.pushViewController(healthDetailsConfirmVC, animated: true)
			}
		}
	}
	
	@IBAction func didTapNext(_ sender: UIButton) {
		postResponses()
	}
}

extension BasicInfoViewController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		// TODO: pickerview
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if textField == birthdateField {
			// TODO: formatting
		}
		
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return true
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		if textField == heightField {
			viewModel.setHeightFromString(textField.text)
		} else if textField == weightField {
			viewModel.setWeightFromString(textField.text)
		} else if textField == birthdateField {
			viewModel.formatBirthdateFromString(textField.text)
		} else if textField == bioSexField {
			viewModel.bioSex = textField.text
		}
	}
}
