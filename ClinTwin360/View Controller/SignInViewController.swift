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
		
		// Hide for now
		passwordField.optionalButton.isHidden = false
		passwordField.optionalButton.setTitle("Forgot Password?", for: .normal)
		passwordField.delegate = self
		
		NotificationCenter.default.addObserver(self,
        selector: #selector(self.keyboardNotification(notification:)),
        name: UIResponder.keyboardWillShowNotification,
        object: nil)
		NotificationCenter.default.addObserver(self,
        selector: #selector(self.keyboardNotification(notification:)),
        name: UIResponder.keyboardWillHideNotification,
        object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
		
		self.emailField.text = nil
		self.passwordField.text = nil
		
		showLoadingView()
		NetworkManager.shared.login(username: email, password: password) { (error) in
			self.hideLoadingView()
			if error != nil {
				let alertController = UIAlertController(title: "Login Failed", message: "Please check your email address and password, and try again.", preferredStyle: .alert)
				let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
				alertController.addAction(okAction)
				self.present(alertController, animated: true, completion: nil)
			} else {
                // Register for push notifications if previously agreed
                self.reRegisterForPushNotifications()
                
				self.getUserData()
			}
		}
	}
    
    private func reRegisterForPushNotifications() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            if settings.authorizationStatus == .authorized {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
	
	private func getUserData() {
		showLoadingView()
		NetworkManager.shared.getParticipantData { (success) in
			self.hideLoadingView()
			if success {
				 //TODO: display this only the first time
				self.presentOnboardingVC()
			} else {
				self.showNetworkError()
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
				let trialsParentVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "TrialsParentViewController")

				self.navigationController?.setViewControllers([trialsParentVC], animated: false)
			}
	}
	
	@objc func keyboardNotification(notification: NSNotification) {
		if let userInfo = notification.userInfo {
			let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
			let endFrameY = endFrame?.origin.y ?? 0
			let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
			let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
			let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
			let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
			if endFrameY >= UIScreen.main.bounds.size.height {
				view.frame.origin.y = 0.0
			} else {
				if let height = endFrame?.size.height {
					view.frame.origin.y = -(height * 0.5)
				}
			}
			UIView.animate(withDuration: duration,
									   delay: TimeInterval(0),
									   options: animationCurve,
									   animations: { self.view.layoutIfNeeded() },
									   completion: nil)
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

extension SignInViewController: LabeledTextFieldViewDelegate {
	func didTapOptionalButtonInTextFieldView(_ textFieldView: LabeledTextFieldView) {
		let ac = UIAlertController(title: "Forgot Password", message: "Please enter your email address to reset your password:", preferredStyle: .alert)
		ac.addTextField()

		let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned ac] _ in
			let answer = ac.textFields![0].text
			self.submitForgotPassword(withEmail: answer ?? "")
		}

		ac.addAction(submitAction)

		present(ac, animated: true)
	}
	
	private func submitForgotPassword(withEmail email: String) {
		showLoadingView()
		NetworkManager.shared.forgotPassword(forUser: email) { (response) in
			self.hideLoadingView()
			if response?.response?.statusCode == 200 {
				let alert = UIAlertController(title: "Thank you!", message: "If a user with the provided email address exists, you will receive an email to reset your password.", preferredStyle: .alert)
				let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
				alert.addAction(okAction)
				self.present(alert, animated: true, completion: nil)
			} else {
				let alert = UIAlertController(title: "User Not Found", message: "We could not find a user with the provided email address. Please try again.", preferredStyle: .alert)
				let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
				alert.addAction(okAction)
				self.present(alert, animated: true, completion: nil)
			}
		}
	}
}

