//
//  LabeledTextFieldView.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/17/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import UIKit

@objc protocol LabeledTextFieldViewDelegate: class {
	@objc optional func didTapOptionalButtonInTextFieldView(_ textFieldView: LabeledTextFieldView)
}

class LabeledTextFieldView: UIView {

	@IBOutlet var view: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var optionalButton: UIButton!
	
	var text: String? {
		get {
			return textField.text
		}
		set {
			textField.text = newValue
		}
	}
	
	var placeholder: String? {
		didSet {
			textField.placeholder = placeholder
		}
	}
	
	var isSecureField: Bool = false {
		didSet {
			textField.isSecureTextEntry = isSecureField
		}
	}
	
	weak var delegate: LabeledTextFieldViewDelegate?
	
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
	
	func configure(title: String, delegate: UITextFieldDelegate? = nil) {
		titleLabel.text = title
		textField.delegate = delegate
	}
	
	@IBAction func didTapOptionButton(_ sender: UIButton) {
		delegate?.didTapOptionalButtonInTextFieldView?(self)
	}
	
}
