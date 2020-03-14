//
//  ViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/1/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit
import ResearchKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

	@IBAction func consentTapped(sender : AnyObject) {
		let taskViewController = ORKTaskViewController(task: ConsentTask, taskRun: nil)
		taskViewController.delegate = self
		taskViewController.modalPresentationStyle = .overFullScreen
		present(taskViewController, animated: true, completion: nil)
	}
	
	@IBAction func surveyTapped(sender : AnyObject) {
		let taskViewController = ORKTaskViewController(task: SurveyTask, taskRun: nil)
		taskViewController.delegate = self
		taskViewController.modalPresentationStyle = .overFullScreen
		present(taskViewController, animated: true, completion: nil)
	}

}

extension ViewController : ORKTaskViewControllerDelegate {
	func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
		//Handle results with taskViewController.result
		taskViewController.dismiss(animated: true, completion: nil)
	}

}

