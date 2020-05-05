//
//  EnrolledTrialsViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/27/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit
import ResearchKit

class EnrolledTrialsViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var noTrialsLabel: UILabel!
	
	let researchQuestionsManager = ResearchQuestionsManager.shared
	
	var trials: [TrialResult] = [TrialResult]() {
		didSet {
			refreshState()
		}
	}
	
	var blurView: UIVisualEffectView?
	
	override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "EnrolledTrialCell", bundle: nil), forCellReuseIdentifier: "EnrolledTrialCell")
    }
    

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		getEnrolledTrials()
	}
	
	private func getEnrolledTrials() {
		NetworkManager.shared.getEnrolledTrials { (response) in
			if let trials = response?.value?.results {
				self.trials = trials
			}
			self.refreshState()
		}
	}
	
	private func refreshState() {
		noTrialsLabel?.isHidden = trials.count > 0
		tableView?.isHidden = trials.count == 0
		tableView?.reloadData()
	}
}

extension EnrolledTrialsViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return trials.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let trial = trials[indexPath.row].clinicalTrial
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "EnrolledTrialCell") as! EnrolledTrialCell
		cell.tag = indexPath.row
		cell.delegate = self
		cell.configureCell(withTrial: trial)
		
		cell.selectionStyle = .none
		
		return cell
	}
}

extension EnrolledTrialsViewController: EnrolledTrialCellDelegate {
	func didTapViewTrial(atIndex index: Int) {
		let trial = trials[index]
		
		let trialVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "MatchedTrialInfoViewController") as! MatchedTrialInfoViewController
		trialVC.trial = trial
		trialVC.isEnrolled = true
		navigationController?.pushViewController(trialVC, animated: true)
	}
	
	func didTapCompleteTasks(atIndex index: Int) {
		let trial = trials[index].clinicalTrial
		showLoadingView()
		researchQuestionsManager.startVirtualTrialSurvey(trial: trial) { (survey, error) in
			self.hideLoadingView()
			if let error = error {
				debugPrint(error.localizedDescription)
				self.showNetworkError()
			} else if let survey = survey {
				if survey.questions.count > 0 {
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
	
	private func beginResearchTask(withSurvey survey: UserSurvey) {
		let taskViewController = ORKTaskViewController(task: survey.surveyTask, taskRun: nil)
		taskViewController.delegate = self
		taskViewController.modalPresentationStyle = .overFullScreen
		
		addBlurView()
		navigationController?.setNavigationBarHidden(true, animated: false)
		present(taskViewController, animated: true, completion: nil)
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
}

extension EnrolledTrialsViewController: ORKTaskViewControllerDelegate {
	func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
		
		if reason == .completed {
			// Handle results with taskViewController.result
			let responses = researchQuestionsManager.parseAnswers(fromTaskResult: taskViewController.result)
			taskViewController.dismiss(animated: true, completion: nil)
			
			showLoadingView()
			researchQuestionsManager.postVirtualTrialResponses(responses) { [weak self] (success) in
				self?.hideLoadingView()
				self?.navigationController?.setNavigationBarHidden(false, animated: false)
				self?.removeBlurView()
			}
		} else {
			// Survey was not completed, no need to submit responses
			taskViewController.dismiss(animated: true, completion: nil)
			navigationController?.setNavigationBarHidden(false, animated: false)
			removeBlurView()
		}
	}
}
