//
//  TrialsParentViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/27/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class TrialsParentViewController: UIViewController {

	@IBOutlet weak var menuView: UIView!
	@IBOutlet weak var menuViewLeadingConstraint: NSLayoutConstraint!
	@IBOutlet weak var additionalQuestionsView: AdditionalQuestionsView!
	@IBOutlet weak var additionalQuestionsBottomConstraint: NSLayoutConstraint!
	
	var matchingTrialsVC: MatchingTrialsListViewController!
	var enrolledTrialsVC: EnrolledTrialsViewController!
	
	var dismissMenuTappableView: UIView?
	var dismissMenuTapGesture: UITapGestureRecognizer?
	var menuIsOpen: Bool = false
	
	override func viewDidLoad() {
        super.viewDidLoad()

		additionalQuestionsView.delegate = self
		
		NotificationCenter.default.addObserver(self, selector: #selector(receivedMatchedTrials(notification:)), name: Notification.Name("MatchedTrials"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(showAdditionalQuestionsView), name: Notification.Name("ShowBanner"), object: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(false, animated: false)
		configureMenuButton()
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
	
	@IBAction func didTapSurveysButton(_ sender: Any) {
		dismissMenu()
		// TODO: check for more questions
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
			
			self.matchingTrialsVC.trials = []
			self.enrolledTrialsVC.trials = []
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let tabController = segue.destination as? UITabBarController {
			tabController.tabBar.tintColor = .black
			
			let tabs = tabController.viewControllers
			matchingTrialsVC = (tabs!.first(where: {$0 is MatchingTrialsListViewController}) as! MatchingTrialsListViewController)
			enrolledTrialsVC = (tabs!.first(where: {$0 is EnrolledTrialsViewController}) as! EnrolledTrialsViewController)
		}
	}

}

extension TrialsParentViewController {
	@objc func receivedMatchedTrials(notification: Notification) {
		if let userInfo = notification.userInfo {
			guard let trials = userInfo["trials"] as? [TrialResult] else { return }
			self.matchingTrialsVC.trials = trials
		}
	}
	
	@objc func showAdditionalQuestionsView() {
		view.layoutIfNeeded()
		additionalQuestionsBottomConstraint.constant = 60
		
		UIView.animate(withDuration: 0.5, animations: {
			self.view.layoutIfNeeded()
		}) { (finished) in
			DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
				self.dismissAdditionalQuestionsView()
			}
		}
	}
	
	private func dismissAdditionalQuestionsView() {
		view.layoutIfNeeded()
		additionalQuestionsBottomConstraint.constant = -(additionalQuestionsView.frame.size.height * 2)
		
		UIView.animate(withDuration: 0.5) {
			self.view.layoutIfNeeded()
		}
	}
}

extension TrialsParentViewController: AdditionalQuestionsViewDelegate {
	func didTapAnswerMoreQuestions() {
		dismissAdditionalQuestionsView()
		// TODO: fetch more questions
	}
}
