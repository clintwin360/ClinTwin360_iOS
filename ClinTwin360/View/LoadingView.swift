//
//  LoadingView.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/2/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import UIKit

fileprivate struct Constants {
    /// an arbitrary tag id for the loading view, so it can be retrieved later without keeping a reference to it
    fileprivate static let loadingViewTag = 1234
}

protocol Loadable {
    func showLoadingView()
    func hideLoadingView()
}

/// Default implementation for UIViewController
extension Loadable where Self: UIViewController {
    
    func showLoadingView() {
		DispatchQueue.main.async {
			let loadingView = LoadingView()
			self.view.addSubview(loadingView)
			
			loadingView.translatesAutoresizingMaskIntoConstraints = false
			loadingView.widthAnchor.constraint(equalToConstant: 100).isActive = true
			loadingView.heightAnchor.constraint(equalToConstant: 100).isActive = true
			loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
			loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
			loadingView.animate()
			
			loadingView.tag = Constants.loadingViewTag
		}
    }
    
    func hideLoadingView() {
		DispatchQueue.main.async {
			self.view.subviews.forEach { subview in
				if subview.tag == Constants.loadingViewTag {
					subview.removeFromSuperview()
				}
			}
		}
    }
}

final class LoadingView: UIView {
	private let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 5
        
        if activityIndicatorView.superview == nil {
            addSubview(activityIndicatorView)
            
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            activityIndicatorView.startAnimating()
        }
    }
    
    public func animate() {
        activityIndicatorView.startAnimating()
    }
}
