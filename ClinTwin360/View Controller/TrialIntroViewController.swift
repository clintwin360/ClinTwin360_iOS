//
//  TrialIntroViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/21/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

enum TrialIntroResult {
	case noneFound
	case trialsFound
}

class TrialIntroViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var navigationButton: UIButton!
	
	var trialIntroResult: TrialIntroResult = .noneFound
	
	override func viewDidLoad() {
        super.viewDidLoad()

		navigationButton.layer.cornerRadius = 10.0
		navigationButton.layer.borderWidth = 0.5
		navigationButton.layer.borderColor = UIColor.black.cgColor
		
		if trialIntroResult == .noneFound {
			configureForNoTrials()
		} else {
			configureForFoundTrials()
		}
    }
    

	private func configureForNoTrials() {
		titleLabel.text = "No Trials Yet"
		messageLabel.text = "Unfortunately we were not able to find any Clinical Trials that match your criteria at this time. We promise to keep an eye out for future trials that may be a good fit for you and let you know what we find."
		navigationButton.setTitle("OK", for: .normal)
		navigationButton.tag = 0
	}
	
	private func configureForFoundTrials() {
		titleLabel.text = "Matching Trials"
		messageLabel.text = "We have good news! We have found 2 Clinical Trials that match your criteria. We will also continue to compare your criteria against future trials and we will notify you if there is a match."
		navigationButton.setTitle("See Trials", for: .normal)
		navigationButton.tag = 1
	}
	
	@IBAction func didTapNavigationButton(_ sender: UIButton) {
		dismiss(animated: true, completion: nil)
		
	}
	
}
