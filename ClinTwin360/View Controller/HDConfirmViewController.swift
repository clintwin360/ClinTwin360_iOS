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
	
	var currentUserSurvey: UserSurvey?
	
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
	
	private func beginResearchTask(withQuestions response: GetQuestionsResponse) {
		guard let questions = response.results else { return }
		currentUserSurvey = UserSurvey(questions: questions)
		
		let taskViewController = ORKTaskViewController(task: currentUserSurvey!.surveyTask, taskRun: nil)
		taskViewController.delegate = self
		taskViewController.modalPresentationStyle = .overFullScreen
		
		addBlurView()
		navigationController?.setNavigationBarHidden(true, animated: false)
		present(taskViewController, animated: true, completion: nil)
	}
	
	private func postResponses(_ responses: [ResearchQuestionAnswer]?, completion: @escaping (_ success: Bool) -> ()) {
		guard responses?.count ?? 0 > 0 else {
			completion(true)
			return
		}
		
		NetworkManager.shared.postSurveyResponse(responses!.first!) { (result) in
			// Ignoring result for now
			self.postResponses(Array(responses!.dropFirst())) { (success) in
				completion(success)
			}
		}
	}
    
	@IBAction func didTapStart(_ sender: UIButton) {
		showLoadingView()
		NetworkManager.shared.getQuestions { (response) in
			self.hideLoadingView()
			if let error = response?.error {
				debugPrint(error.localizedDescription)
				self.showNetworkError()
			} else if let value = response?.value {
				self.beginResearchTask(withQuestions: value)
			}
		}
	}
}

extension HDConfirmViewController: ORKTaskViewControllerDelegate {
	func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
		// Handle results with taskViewController.result
		currentUserSurvey?.parseAnswers(fromTaskResult: taskViewController.result)
		
		showLoadingView()
		postResponses(currentUserSurvey?.responses) { [weak self] (success) in
			taskViewController.dismiss(animated: true, completion: nil)
			self?.navigationController?.setNavigationBarHidden(false, animated: false)
			self?.removeBlurView()
			
			NetworkManager.shared.getMatches { (success, response) in
				self?.hideLoadingView()
				if response?.error != nil || success == false {
					self?.showNetworkError()
				} else {
					let trialIntroVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "TrialIntroViewController") as! TrialIntroViewController
					
					if let matches = response?.value, let results = matches.results, results.count > 0 {
						trialIntroVC.trialIntroResult = .trialsFound(count: results.count)
						
						let userInfo = ["trials":results]
						NotificationCenter.default.post(name: NSNotification.Name("MatchedTrials"), object: nil, userInfo: userInfo)
					} else {
						trialIntroVC.trialIntroResult = .noneFound
					}
					self?.navigationController?.pushViewController(trialIntroVC, animated: true)
				}
			}
		}
	}
}
