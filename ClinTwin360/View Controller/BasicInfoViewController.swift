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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
//		navigationController?.setNavigationBarHidden(false, animated: false)

        setUpFields()
		
		nextButton.layer.cornerRadius = 10.0
		nextButton.layer.borderWidth = 0.5
		nextButton.layer.borderColor = CommonColors.mediumGrey.cgColor
    }
    
	private func setUpFields() {
		birthdateField.configure(title: "Birth Date")
		bioSexField.configure(title: "Biological Sex")
		heightField.configure(title: "Height")
		weightField.configure(title: "Weight")
		zipcodeField.configure(title: "Zipcode")
	}
	
	@IBAction func didTapNext(_ sender: UIButton) {
		let healthDetailsConfirmVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HDConfirmViewController")
		navigationController?.pushViewController(healthDetailsConfirmVC, animated: true)
	}
	
}
