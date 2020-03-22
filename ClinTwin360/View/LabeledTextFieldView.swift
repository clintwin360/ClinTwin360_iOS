//
//  LabeledTextFieldView.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/17/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

@objc protocol LabeledTextFieldViewDelegate: class {
	@objc optional func labeledTextFieldDidBeginEditing(_ textField: UITextField)
	@objc optional func labeledTextFieldDidEndEditing(_ textField: UITextField)
}

class LabeledTextFieldView: UIView {

	@IBOutlet var view: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	
	var text: String? {
		return textField.text
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	private func commonInit() {
		Bundle.main.loadNibNamed("LabeledTextFieldView", owner: self, options: nil)
		view.frame = self.bounds
		addSubview(view)
	}
	
	func configure(title: String) {
		titleLabel.text = title
	}
}
