//
//  HDConfirmViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/19/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class HDConfirmViewController: UIViewController {

	@IBOutlet weak var startButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		startButton.layer.cornerRadius = 10.0
		startButton.layer.borderWidth = 0.5
		startButton.layer.borderColor = CommonColors.mediumGrey.cgColor
    }
    
	@IBAction func didTapStart(_ sender: UIButton) {
	}
	

}
