//
//  AHConfirmViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/17/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class AHConfirmViewController: UIViewController {

	@IBOutlet weak var yesButton: UIButton!
	@IBOutlet weak var noButton: UIButton!
	
	let hkDataFetcher = HealthKitDataFetcher()
		
		override func viewDidLoad() {
			super.viewDidLoad()

			yesButton.layer.cornerRadius = 10.0
			yesButton.layer.borderWidth = 0.5
			yesButton.layer.borderColor = CommonColors.mediumGrey.cgColor
			
			noButton.layer.cornerRadius = 10.0
			noButton.layer.borderWidth = 0.5
			noButton.layer.borderColor = CommonColors.mediumGrey.cgColor
		}
		
		private func pullHealthKitData() {
			hkDataFetcher.pullHealthKitData { (data) in
				let viewModel = self.hkDataFetcher.healthViewModelFromData(data)
				self.postHealthData(viewModel)
			}
		}
		
		private func postHealthData(_ viewModel: BasicHealthViewModel) {
			guard viewModel.isValid else { return }
		
			showLoadingView()
			NetworkManager.shared.postBasicHealthDetails(healthModel: viewModel) { (error) in
				self.hideLoadingView()
				if error != nil {
					self.showNetworkError()
				} else {
					self.pushHealthDataConfirmation()
				}
			}
		}
		
		private func pushHealthDataConfirmation() {
			DispatchQueue.main.async {
				let healthDetailsConfirmVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HDConfirmViewController")
				self.navigationController?.pushViewController(healthDetailsConfirmVC, animated: true)
			}
		}
		
		@IBAction func didTapYes(_ sender: UIButton) {
			HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
				guard authorized else {
					let baseMessage = "HealthKit Authorization Failed"

					if let error = error as? HealthKitSetupError {
						print("\(baseMessage). Reason: \(error.description)")
					} else {
						print(baseMessage)
					}
					return
				}
				
				self.pullHealthKitData()
			}
		}
		
		@IBAction func didTapNo(_ sender: UIButton) {
			let basicInfoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BasicInfoViewController")
			navigationController?.pushViewController(basicInfoVC, animated: true)
		}
		
	}
