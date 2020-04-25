//
//  MatchedTrialInfoViewController.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/21/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

class MatchedTrialInfoViewController: UIViewController {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var sponsorLabel: UILabel!
	@IBOutlet weak var objectiveLabel: UILabel!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var noButton: UIButton!
	@IBOutlet weak var applyButton: UIButton!
	
	var trialDetail: TrialObject?
	
	override func viewDidLoad() {
        super.viewDidLoad()

        noButton.layer.cornerRadius = 10.0
		noButton.layer.borderWidth = 0.5
		noButton.layer.borderColor = UIColor.black.cgColor
		
		applyButton.layer.cornerRadius = 10.0
		applyButton.layer.borderWidth = 0.5
		applyButton.layer.borderColor = UIColor.black.cgColor
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		titleLabel.text = trialDetail?.title
		configureInfoFromData()
	}
	
	private func configureInfoFromData() {
		setSponsorData()
		setObjectiveData()
		setDescriptionData()
	}
	
	private func setSponsorData() {
		var info = ""
		var s: String = ""
		var link: String = ""
		if let sponsor = trialDetail?.sponsor {
			info = sponsor.contactPerson
			s = sponsor.contactPerson
			if let organization = sponsor.organization {
				info = "\(info)\n\(organization)"
			}
		}
		if let url = trialDetail?.url {
			link = url
			if info.count > 0 {
				info = "\(info)\n\(url)"
			} else {
				info = url
			}
			
			let linkOpenGesture = UITapGestureRecognizer(target: self, action: #selector(openLink))
			sponsorLabel.isUserInteractionEnabled = true
			sponsorLabel.addGestureRecognizer(linkOpenGesture)
		}
		
		if info.count > 0 {
			let searchString = NSString(string: info)
			let range = searchString.range(of: s)
			let attributedString = addBoldAttributes(attributedString: NSMutableAttributedString(string: info), range: range)
			
			let linkRange = searchString.range(of: link)
			attributedString.addAttribute(.link, value: link, range: linkRange)
			
			sponsorLabel.attributedText = attributedString
		} else {
			sponsorLabel.isHidden = true
		}
	}
	
	private func setObjectiveData() {
		if let objective = trialDetail?.objective, objective.count > 0 {
			let info = "Objective: \(objective)"
			let searchString = NSString(string: info)
			let range = searchString.range(of: "Objective:")
			let attributedString = addBoldAttributes(attributedString: NSMutableAttributedString(string: info), range: range)
			objectiveLabel.attributedText = attributedString
		} else {
			objectiveLabel.isHidden = true
		}
	}
	
	private func setDescriptionData() {
		if let description = trialDetail?.description, description.count > 0 {
			let info = "Description: \(description)"
			let searchString = NSString(string: info)
			let range = searchString.range(of: "Description:")
			let attributedString = addBoldAttributes(attributedString: NSMutableAttributedString(string: info), range: range)
			descriptionLabel.attributedText = attributedString
		} else {
			descriptionLabel.isHidden = true
		}
	}
	
	private func addBoldAttributes(attributedString: NSMutableAttributedString, range: NSRange) -> NSMutableAttributedString {
		let boldAttributes = [NSAttributedString.Key.font: UIFont(name:"HelveticaNeue-Bold", size: 18.0)]
		attributedString.addAttributes(boldAttributes as [NSAttributedString.Key : Any], range: range)
		return attributedString
	}
	
	@objc func openLink() {
		guard let urlString = trialDetail?.url else { return }
		guard let url = URL(string: urlString) else { return }
		UIApplication.shared.open(url)
	}
    
	@IBAction func didTapNo(_ sender: UIButton) {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func didTapApply(_ sender: UIButton) {
		
		let nextStepsVC = UIStoryboard(name: "TrialsInfo", bundle: nil).instantiateViewController(withIdentifier: "TrialNextStepsViewController") as! TrialNextStepsViewController
		navigationController?.pushViewController(nextStepsVC, animated: true)
	}
	
}
