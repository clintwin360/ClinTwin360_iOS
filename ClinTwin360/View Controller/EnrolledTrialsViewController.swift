//
//  EnrolledTrialsViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/27/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class EnrolledTrialsViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var noTrialsLabel: UILabel!
	
	var trials: [TrialResult] = [TrialResult]() {
		didSet {
			refreshState()
		}
	}
	
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
		let trial = trials[index].clinicalTrial
		
		let trialVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "MatchedTrialInfoViewController") as! MatchedTrialInfoViewController
		trialVC.trialDetail = trial
		trialVC.isEnrolled = true
		navigationController?.pushViewController(trialVC, animated: true)
	}
	
	func didTapCompleteTasks(atIndex index: Int) {
		let trial = trials[index].clinicalTrial
		// TODO
	}
	
	
}
