//
//  ViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/1/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
	
	@IBOutlet weak var emailField: LabeledTextFieldView!
	@IBOutlet weak var passwordField: LabeledTextFieldView!
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var createAccountButton: UIButton!
	
	var buttonGradient: CAGradientLayer?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		navigationController?.setNavigationBarHidden(true, animated: false)
		setUpFields()
		
		signInButton.layer.cornerRadius = 10.0
		signInButton.layer.borderWidth = 0.5
		signInButton.layer.borderColor = UIColor.black.cgColor
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if buttonGradient == nil {
			createButtonGradient()
		}
	}
	
	private func setUpFields() {
		emailField.configure(title: "Email Address")
		passwordField.configure(title: "Password")
	}
	
	private func createButtonGradient() {
		let topGradientColor = CommonColors.clinTwinTeal
		let bottomGradientColor = UIColor.black

		buttonGradient = CAGradientLayer()

		buttonGradient!.frame = signInButton.bounds

		buttonGradient!.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]

		buttonGradient!.startPoint = CGPoint(x: 0.0, y: 0.0)
		buttonGradient!.endPoint = CGPoint(x: 0.0, y: 2.0)
		buttonGradient!.locations = [0.0, 2.0]

		signInButton.layer.insertSublayer(buttonGradient!, at: 0)
		signInButton.clipsToBounds = true
	}
	
	@IBAction func didTapSignIn(_ sender: UIButton) {
		if sender.tag == 0 { // sign in
			// TODO: authenticate
			let navController = UINavigationController()
			let onboardingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingViewController")
			navController.viewControllers = [onboardingVC]
			navController.modalPresentationStyle = .overFullScreen
		
			present(navController, animated: true) {
				let trialsListVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "MatchingTrialsListViewController")

				self.navigationController?.setViewControllers([trialsListVC], animated: false)
			}
		} else if sender.tag == 1 { // sign up
			// TODO: create account
		}
		
	}
	
	@IBAction func didTapCreateAccount(_ sender: UIButton) {
		if sender.tag == 0 { // sign up
			signInButton.setTitle("Sign Up", for: .normal)
			signInButton.tag = 1
			createAccountButton.setTitle("Sign In", for: .normal)
			createAccountButton.tag = 1
		} else if sender.tag == 1 { // sign in
			signInButton.setTitle("Sign In", for: .normal)
			signInButton.tag = 0
			createAccountButton.setTitle("Create Account", for: .normal)
			createAccountButton.tag = 0
		}
	}
	
	

}

