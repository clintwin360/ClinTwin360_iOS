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
	case trialsFound(count: Int)
}

class TrialIntroViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var navigationButton: UIButton!
	
	var pushNotificationsManager = PushNotificationsManager()
	
	var trialIntroResult: TrialIntroResult = .noneFound
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationButton.layer.cornerRadius = 10.0
		navigationButton.layer.borderWidth = 0.5
		navigationButton.layer.borderColor = UIColor.black.cgColor
		
		switch trialIntroResult {
		case .noneFound:
			configureForNoTrials()
		case .trialsFound(let count):
			configureForFoundTrials(count: count)
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(true, animated: false)
	}
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		pushNotificationsManager.shouldRequestToRegister { (shouldRequest) in
			if shouldRequest {
				DispatchQueue.main.async {
					self.registerForPushNotifications()
				}
			}
		}
	}

	private func configureForNoTrials() {
		titleLabel.text = "No Trials Yet"
		messageLabel.text = "Unfortunately we were not able to find any Clinical Trials that match your criteria at this time. We promise to keep an eye out for future trials that may be a good fit for you and let you know what we find."
		navigationButton.setTitle("OK", for: .normal)
		navigationButton.tag = 0
	}
	
	private func configureForFoundTrials(count: Int) {
		titleLabel.text = "Matching Trials"
		messageLabel.text = "We have good news! We have found \(count) Clinical Trials that match your criteria. We will also continue to compare your criteria against future trials and we will notify you if there is a match."
		navigationButton.setTitle("See Trials", for: .normal)
		navigationButton.tag = 1
	}
	
	private func registerForPushNotifications() {
		let alertController = UIAlertController(title: "Notifications", message: "Would you like to be notified of additional future clinical trial opportunities?", preferredStyle: .alert)
		let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
		let yesAction = UIAlertAction(title: "Yes", style: .default) { (action) in
			self.pushNotificationsManager.requestNotificationsAuthorization { (success) in
				print("Register for push notifications success: \(success)")
			}
		}
		alertController.addAction(noAction)
		alertController.addAction(yesAction)
		
		present(alertController, animated: true, completion: nil)
	}
	
	@IBAction func didTapNavigationButton(_ sender: UIButton) {
		dismiss(animated: true) {
			NotificationCenter.default.post(name: Notification.Name("ShowBanner"), object: nil)
		}
		
	}
	
}
