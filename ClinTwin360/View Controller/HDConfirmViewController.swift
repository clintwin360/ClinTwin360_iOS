//
//  HDConfirmViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/19/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit
import ResearchKit

class HDConfirmViewController: UIViewController {

	@IBOutlet weak var startButton: UIButton!
	
	var blurView: UIVisualEffectView?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		startButton.layer.cornerRadius = 10.0
		startButton.layer.borderWidth = 0.5
		startButton.layer.borderColor = CommonColors.mediumGrey.cgColor
    }
	
	private func addBlurView() {
		let blurEffect = UIBlurEffect(style: .light)
		blurView = UIVisualEffectView(effect: blurEffect)
		//always fill the view
		blurView!.frame = self.view.bounds
		blurView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		view.addSubview(blurView!)
	}
	
	private func removeBlurView() {
		blurView?.removeFromSuperview()
		blurView = nil
	}
    
	@IBAction func didTapStart(_ sender: UIButton) {
		let taskViewController = ORKTaskViewController(task: SurveyTask, taskRun: nil)
		taskViewController.delegate = self
		taskViewController.modalPresentationStyle = .overFullScreen
		
		addBlurView()
		navigationController?.setNavigationBarHidden(true, animated: false)
		present(taskViewController, animated: true, completion: nil)
	}

}

extension HDConfirmViewController: ORKTaskViewControllerDelegate {
	func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
		// TODO: Handle results with taskViewController.result
		taskViewController.dismiss(animated: true, completion: nil)
		navigationController?.setNavigationBarHidden(false, animated: false)
		removeBlurView()
		
		let trialIntroVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "TrialIntroViewController") as! TrialIntroViewController
		trialIntroVC.trialIntroResult = .trialsFound // TODO: update this later
		navigationController?.pushViewController(trialIntroVC, animated: true)
	}
}
