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
	
	var trials: [Any] = [1, 2]

    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationController?.setNavigationBarHidden(false, animated: false)
		configureMenuButton()
		
		tableView.register(UINib(nibName: "MatchingTrialCell", bundle: nil), forCellReuseIdentifier: "MatchingTrialCell")
		
		noTrialsLabel.isHidden = trials.count > 0
		tableView.isHidden = trials.count == 0
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
		
		NetworkManager.shared.getTrialDetails { [weak self] (response) in
			if let error = response?.error {
				debugPrint(error.localizedDescription)
				self?.showNetworkError()
			} else {
				let trialVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "MatchedTrialInfoViewController") as! MatchedTrialInfoViewController
				// TODO: inject trial details model
				self?.navigationController?.pushViewController(trialVC, animated: true)
			}
		}
	}
}
