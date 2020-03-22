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
	

    override func viewDidLoad() {
        super.viewDidLoad()

		tableView.register(UINib(nibName: "MatchingTrialCell", bundle: nil), forCellReuseIdentifier: "MatchingTrialCell")
    }
    
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2 // need to update this later
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if let cell = tableView.dequeueReusableCell(withIdentifier: "MatchingTrialCell") as? MatchingTrialCell {
			
			cell.configureCell(title: "Any", details: "Details")
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
