//
//  OnboardingViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/17/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

	@IBOutlet weak var beginButton: UIButton!
	
	
	override func viewDidLoad() {
        super.viewDidLoad()

		navigationController?.setNavigationBarHidden(true, animated: false)
		
		beginButton.layer.cornerRadius = 10.0
		beginButton.layer.borderWidth = 0.5
		beginButton.layer.borderColor = CommonColors.mediumGrey.cgColor
    }
	
	
	@IBAction func didTapBegin(_ sender: UIButton) {
		let appleHealthVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AHConfirmViewController")
		navigationController?.pushViewController(appleHealthVC, animated: true)
	}
	

}
