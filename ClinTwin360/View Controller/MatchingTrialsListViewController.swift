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
	@IBOutlet weak var menuView: UIView!
	@IBOutlet weak var menuViewLeadingConstraint: NSLayoutConstraint!
	
	var dismissMenuTappableView: UIView?
	var dismissMenuTapGesture: UITapGestureRecognizer?
	var menuIsOpen: Bool = false
	
	var trials: [TrialResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationController?.setNavigationBarHidden(false, animated: false)
		configureMenuButton()
		
		NotificationCenter.default.addObserver(self, selector: #selector(receivedMatchedTrials(notification:)), name: Notification.Name("MatchedTrials"), object: nil)
		
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
	
	private func configureMenuButton() {
		let menuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
		menuButton.setImage(UIImage(named: "menu"), for: .normal)
		menuButton.addTarget(self, action: #selector(toggleMenu), for: .touchUpInside)
		navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
	}
	
	private func addTappableView() {
		dismissMenuTappableView = UIView(frame: view.bounds)
		dismissMenuTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
		view.insertSubview(dismissMenuTappableView!, belowSubview: menuView)
		dismissMenuTappableView?.addGestureRecognizer(dismissMenuTapGesture!)
	}
	
	@objc func receivedMatchedTrials(notification: Notification) {
		if let userInfo = notification.userInfo {
			guard let trials = userInfo["trials"] as? [TrialResult] else { return }
			self.trials = trials
			refreshState()
		}
	}
	
	@objc func toggleMenu() {
		if menuIsOpen {
			dismissMenu()
		} else {
			showMenu()
		}
	}
	
	@objc func showMenu() {
		menuIsOpen = true
		menuView.layoutIfNeeded()
		menuViewLeadingConstraint.constant = 0
		
		UIView.animate(withDuration: 0.3, animations: {
			self.view.layoutIfNeeded()
		}) { (finished) in
			self.addTappableView()
		}
	}
	
	@objc func dismissMenu() {
		menuIsOpen = false
		dismissMenuTappableView?.removeFromSuperview()
		dismissMenuTappableView = nil
		dismissMenuTapGesture = nil
		
		menuView.layoutIfNeeded()
		menuViewLeadingConstraint.constant = -(menuView.frame.size.width)
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
	
	@IBAction func didTapSignOut(_ sender: UIButton) {
		showLoadingView()
		NetworkManager.shared.signOut { (response) in
			print("signed out")
			self.dismissMenu()
			KeychainWrapper.standard.removeAllKeys()
			
			let signInNavVC = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()!
			signInNavVC.modalPresentationStyle = .overFullScreen
			self.present(signInNavVC, animated: true, completion: nil)
			self.hideLoadingView()
		}
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
			
			cell.configureCell(title: trial.title, details: trial.description ?? "")
			cell.tag = indexPath.row
			cell.delegate = self
			
			return cell
		}
		
		return UITableViewCell()
	}

}

extension MatchingTrialsListViewController: MatchingTrialCellDelegate {
	func didTapLearnMore(atIndex index: Int) {
		let trialResult = trials[index]
		let trial = trialResult.clinicalTrial
		
		NetworkManager.shared.getTrialDetails(trialId: trial.trialId) { [weak self] (response) in
			if let error = response?.error {
				debugPrint(error.localizedDescription)
				self?.showNetworkError()
			} else {
				let trialVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "MatchedTrialInfoViewController") as! MatchedTrialInfoViewController
				trialVC.trialDetail = response?.value
				self?.navigationController?.pushViewController(trialVC, animated: true)
			}
		}
	}
}
