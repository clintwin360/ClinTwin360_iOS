//
//  MatchingTrialsListViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/21/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class MatchingTrialsListViewController: UIViewController, UITableViewDataSource {
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var noTrialsLabel: UILabel!
	
	var trials: [Any] = [1, 2]

    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationController?.setNavigationBarHidden(false, animated: false)

		tableView.register(UINib(nibName: "MatchingTrialCell", bundle: nil), forCellReuseIdentifier: "MatchingTrialCell")
		
		noTrialsLabel.isHidden = trials.count > 0
		tableView.isHidden = trials.count == 0
    }
    
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return trials.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "MatchingTrialCell") as? MatchingTrialCell {
			
			cell.configureCell(title: "Novartis Heart Study", details: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec est mi, elementum et auctor eget, vulputate sit amet leo. Aenean pretium fringilla dolor, quis rhoncus nulla iaculis eu.")
			cell.tag = indexPath.row
			cell.delegate = self
			
			return cell
		}
		
		return UITableViewCell()
	}

}

extension MatchingTrialsListViewController: MatchingTrialCellDelegate {
	func didTapLearnMore(atIndex index: Int) {
		// TODO: get selected trial
		
		let trialVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "MatchedTrialInfoViewController") as! MatchedTrialInfoViewController
		navigationController?.pushViewController(trialVC, animated: true)
	}
}
