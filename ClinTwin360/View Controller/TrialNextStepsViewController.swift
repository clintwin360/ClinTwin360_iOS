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
	
	override func viewDidLoad() {
        super.viewDidLoad()

	   okButton.layer.cornerRadius = 10.0
	   okButton.layer.borderWidth = 0.5
	   okButton.layer.borderColor = UIColor.black.cgColor
    }
    

   

}
