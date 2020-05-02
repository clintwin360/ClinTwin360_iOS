//
//  UIViewController+Extension.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/31/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController: Loadable {
	
	func showNetworkError() {
		DispatchQueue.main.async {
			let alertController = UIAlertController(title: nil, message: "An error occurred. Please try again later.", preferredStyle: .alert)
			let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
			alertController.addAction(okAction)
			
			self.present(alertController, animated: true, completion: nil)
		}
	}
}
