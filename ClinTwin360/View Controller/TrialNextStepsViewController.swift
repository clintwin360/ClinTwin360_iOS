//
//  TrialNextStepsViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/21/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class TrialNextStepsViewController: UIViewController {


	@IBOutlet weak var interestButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
	
	var trial: TrialResult?
	var trialDetail: TrialObject? {
		return trial?.clinicalTrial
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

	   interestButton.layer.cornerRadius = 10.0
	   interestButton.layer.borderWidth = 0.5
	   interestButton.layer.borderColor = UIColor.black.cgColor
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		titleLabel.text = trialDetail?.title
	}

	@IBAction func didTapInterestButton(_ sender: UIButton) {
		guard let trial = self.trial else { return }
		showLoadingView()
		NetworkManager.shared.expressInterest(inTrial: trial) { (success) in
			self.hideLoadingView()
			if success {
				DispatchQueue.main.async {
					let alert = UIAlertController(title: "Success!", message: "You will receive an email with further details.", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
						self.dismiss(animated: true) {
							if let vcs = self.navigationController?.viewControllers.filter({!($0 is MatchedTrialInfoViewController) && !($0 is TrialNextStepsViewController)}) {
								self.navigationController?.setViewControllers(vcs, animated: true)
							}
						}
					}
					alert.addAction(okAction)
					
					self.present(alert, animated: true, completion: nil)
				}
			} else {
				self.showNetworkError()
			}
		}
	}
}
