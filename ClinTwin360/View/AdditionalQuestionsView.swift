//
//  AdditionalQuestionsView.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/27/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

protocol AdditionalQuestionsViewDelegate: class {
	func didTapAnswerMoreQuestions()
}

class AdditionalQuestionsView: UIView {

	@IBOutlet var view: UIView!
	@IBOutlet weak var answerMoreButton: UIButton!
	
	weak var delegate: AdditionalQuestionsViewDelegate?
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	private func commonInit() {
		Bundle.main.loadNibNamed("AdditionalQuestionsView", owner: self, options: nil)
		view.frame = self.bounds
		addSubview(view)
		
		view.layer.cornerRadius = 12.0
		view.layer.borderColor = UIColor.black.cgColor
		view.layer.borderWidth = 1.0
		
		answerMoreButton.layer.cornerRadius = 8.0
		answerMoreButton.layer.borderColor = CommonColors.clinTwinTeal.cgColor
		answerMoreButton.layer.borderWidth = 0.5
	}
	
	@IBAction func didTapButton(_ sender: Any) {
		delegate?.didTapAnswerMoreQuestions()
	}
}
