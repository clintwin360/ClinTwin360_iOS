//
//  MatchingTrialCell.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/21/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

protocol MatchingTrialCellDelegate: class {
	func didTapLearnMore(atIndex index: Int)
}

class MatchingTrialCell: UITableViewCell {
	
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var detailsLabel: UILabel!
	@IBOutlet weak var trialImageView: UIImageView!
	@IBOutlet weak var learnMoreButton: UIButton!
	
	weak var delegate: MatchingTrialCellDelegate?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        
		
		cardView.layer.cornerRadius = 10.0
		cardView.layer.borderWidth = 1.0
		cardView.layer.borderColor = UIColor.black.cgColor
		
		learnMoreButton.layer.cornerRadius = 10.0
		learnMoreButton.layer.borderWidth = 1.0
		learnMoreButton.layer.borderColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	@IBAction func didTapLearnMore(_ sender: UIButton) {
		delegate?.didTapLearnMore(atIndex: tag)
	}
	
	func configureCell(title: String, details: String) {
		titleLabel.text = title
		detailsLabel.text = details
	}

}
