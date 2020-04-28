//
//  MatchingTrialsListViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/21/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class MatchingTrialsListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var noTrialsLabel: UILabel!
	
	var trials: [TrialResult] = [] {
		didSet {
			refreshState()
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.register(UINib(nibName: "MatchingTrialCell", bundle: nil), forCellReuseIdentifier: "MatchingTrialCell")
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		refreshState()
	}
	
	private func refreshState() {
		noTrialsLabel.isHidden = trials.count > 0
		tableView.isHidden = trials.count == 0
		tableView.reloadData()
	}
    
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return trials.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let trialResult = trials[indexPath.row]
		let trial = trialResult.clinicalTrial
		
		if let cell = tableView.dequeueReusableCell(withIdentifier: "MatchingTrialCell") as? MatchingTrialCell {
			
			cell.configureCell(title: trial.title, details: trial.objective ?? "")
			cell.tag = indexPath.row
			cell.delegate = self
			cell.selectionStyle = .none
			
			return cell
		}
		
		return UITableViewCell()
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		didTapLearnMore(atIndex: indexPath.row)
	}

}

extension MatchingTrialsListViewController: MatchingTrialCellDelegate {
	func didTapLearnMore(atIndex index: Int) {
		let trialResult = trials[index]
		let trial = trialResult.clinicalTrial
		
		let trialVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "MatchedTrialInfoViewController") as! MatchedTrialInfoViewController
		trialVC.trialDetail = trial
		navigationController?.pushViewController(trialVC, animated: true)
	}
}
