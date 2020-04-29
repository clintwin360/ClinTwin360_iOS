//
//  EnrolledTrialCell.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/29/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

protocol EnrolledTrialCellDelegate: class {
	func didTapViewTrial(atIndex index: Int)
	func didTapCompleteTasks(atIndex index: Int)
}

class EnrolledTrialCell: UITableViewCell {

	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detailsLabel: UILabel!
	@IBOutlet weak var viewTrialButton: UIButton!
	@IBOutlet weak var completeTasksButton: UIButton!
	@IBOutlet weak var newTasksLabel: UILabel!
	
	weak var delegate: EnrolledTrialCellDelegate?
	
	var hasNewTasks: Bool = true {
		didSet {
			newTasksLabel.isHidden = !hasNewTasks
			completeTasksButton.isEnabled = hasNewTasks
			completeTasksButton.alpha = hasNewTasks ? 1.0 : 0.5
		}
	}
	
	override func awakeFromNib() {
        super.awakeFromNib()
        
		cardView.layer.cornerRadius = 10.0
		cardView.layer.borderWidth = 1.0
		cardView.layer.borderColor = UIColor.black.cgColor
		
		viewTrialButton.layer.cornerRadius = 10.0
		viewTrialButton.layer.borderWidth = 1.0
		viewTrialButton.layer.borderColor = UIColor.black.cgColor
		
		completeTasksButton.layer.cornerRadius = 10.0
		completeTasksButton.layer.borderWidth = 1.0
		completeTasksButton.layer.borderColor = UIColor.black.cgColor
    }

	
	@IBAction func viewTrialButtonTapped(_ sender: Any) {
		delegate?.didTapViewTrial(atIndex: tag)
	}
	
	@IBAction func completeTaskButtonTapped(_ sender: Any) {
		delegate?.didTapCompleteTasks(atIndex: tag)
	}
	
}
