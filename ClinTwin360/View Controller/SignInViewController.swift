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
		passwordField.isSecureField = true
		
		let keyboardToolbar = UIToolbar()
		keyboardToolbar.sizeToFit()
		let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
		keyboardToolbar.items = [flexBarButton, doneBarButton]
		
		emailField.textField.inputAccessoryView = keyboardToolbar
		passwordField.textField.inputAccessoryView = keyboardToolbar
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
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
	
	private func signIn() {
		guard let email = emailField.text, email.count > 0 else { return }
		guard let password = passwordField.text, password.count > 0 else { return }
		
		showLoadingView()
		NetworkManager.shared.login(username: email, password: password) { (error) in
			self.hideLoadingView()
			if error != nil {
				let alertController = UIAlertController(title: "Login Failed", message: "Please check your email address and password, and try again.", preferredStyle: .alert)
				let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
				alertController.addAction(okAction)
				self.present(alertController, animated: true, completion: nil)
			} else {
				// TODO: display this only the first time
				self.presentOnboardingVC()
				
				self.emailField.text = nil
				self.passwordField.text = nil
			}
		}
	}
	
	private func registerUser() {
		guard let email = emailField.text, email.count > 0 else { return }
		guard let password = passwordField.text, password.count > 0 else { return }
		
		showLoadingView()
		NetworkManager.shared.registerUser(email: email, password: password) { (error) in
			self.hideLoadingView()
			if error != nil {
				self.showNetworkError()
			} else {
				self.signIn()
			}
		}
	}
	
	private func presentOnboardingVC() {
		let navController = UINavigationController()
			let onboardingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OnboardingViewController")
			navController.viewControllers = [onboardingVC]
			navController.modalPresentationStyle = .overFullScreen
		
			present(navController, animated: true) {
				let trialsListVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "MatchingTrialsListViewController")

				self.navigationController?.setViewControllers([trialsListVC], animated: false)
			}
	}
	
	@IBAction func didTapSignIn(_ sender: UIButton) {
		view.endEditing(true)
		if sender.tag == 0 { // sign in
			signIn()
		} else if sender.tag == 1 { // sign up
			registerUser()
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

