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
	
	var blurView: UIVisualEffectView?
	
	var researchQuestionsManager = ResearchQuestionsManager.shared
	
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
	
	private func beginResearchTask(withSurvey survey: UserSurvey) {
		let taskViewController = ORKTaskViewController(task: survey.surveyTask, taskRun: nil)
		taskViewController.delegate = self
		taskViewController.modalPresentationStyle = .overFullScreen
		
		addBlurView()
		navigationController?.setNavigationBarHidden(true, animated: false)
		present(taskViewController, animated: true, completion: nil)
	}
	
	private func getMatches() {
		NetworkManager.shared.getMatches { [weak self] (success, response) in
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
    
	@IBAction func didTapStart(_ sender: UIButton) {
		showLoadingView()
		
		researchQuestionsManager.startInitialSurvey { (survey, error) in
			self.hideLoadingView()
			if let error = error {
				debugPrint(error.localizedDescription)
				self.showNetworkError()
			} else if let survey = survey {
				let primaryQuestionsCount = survey.questions.reduce(0) { (result, question) -> Int in
					return question.isFollowup == 0 ? (result + 1) : result
				}
				if primaryQuestionsCount > 0 {
					self.beginResearchTask(withSurvey: survey)
				} else {
					let alert = UIAlertController(title: nil, message: "No survey questions available at this time. Check back later!", preferredStyle: .alert)
					let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
					alert.addAction(okAction)
					self.present(alert, animated: true, completion: nil)
				}
			}
		}
	}
}

extension HDConfirmViewController: ORKTaskViewControllerDelegate {
	func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
		
		if reason == .completed {
			// Handle results with taskViewController.result
			let responses = researchQuestionsManager.parseAnswers(fromTaskResult: taskViewController.result)
			taskViewController.dismiss(animated: true, completion: nil)
			
			showLoadingView()
			researchQuestionsManager.postResponses(responses) { [weak self] (success) in
				self?.navigationController?.setNavigationBarHidden(false, animated: false)
				self?.removeBlurView()
				self?.getMatches()
			}
		} else {
			// Survey was not completed, no need to submit responses
			taskViewController.dismiss(animated: true, completion: nil)
			navigationController?.setNavigationBarHidden(false, animated: false)
			removeBlurView()
			showLoadingView()
			getMatches()
		}
	}
}
