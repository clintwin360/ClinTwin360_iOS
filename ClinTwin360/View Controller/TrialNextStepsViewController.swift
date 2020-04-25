//
//  TrialNextStepsViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/21/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class TrialNextStepsViewController: UIViewController {

	@IBOutlet weak var okButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
	
	var trialDetail: TrialObject?
	
	override func viewDidLoad() {
        super.viewDidLoad()

	   okButton.layer.cornerRadius = 10.0
	   okButton.layer.borderWidth = 0.5
	   okButton.layer.borderColor = UIColor.black.cgColor
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		titleLabel.text = trialDetail?.title
	}

   

}
