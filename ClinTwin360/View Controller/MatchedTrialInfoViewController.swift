//
//  MatchedTrialInfoViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/21/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class MatchedTrialInfoViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detailsLabel: UILabel!
	@IBOutlet weak var noButton: UIButton!
	@IBOutlet weak var applyButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()

        noButton.layer.cornerRadius = 10.0
		noButton.layer.borderWidth = 0.5
		noButton.layer.borderColor = UIColor.black.cgColor
		
		applyButton.layer.cornerRadius = 10.0
		applyButton.layer.borderWidth = 0.5
		applyButton.layer.borderColor = UIColor.black.cgColor
    }
    

	@IBAction func didTapNo(_ sender: UIButton) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func didTapApply(_ sender: UIButton) {
		
		let nextStepsVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "TrialNextStepsViewController") as! TrialNextStepsViewController
		navigationController?.pushViewController(nextStepsVC, animated: true)
	}
	
}
