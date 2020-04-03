//
//  AccessTokenAdapter.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/28/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import Alamofire

class AccessTokenAdapter: RequestAdapter {
	private var accessToken: String? {
		return KeychainWrapper.standard.string(forKey: "token")
	}
	
	func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
		
		var adaptedRequest = urlRequest
		adaptedRequest.headers.update(.authorization("Token \(accessToken ?? "")"))
		adaptedRequest.headers.update(.accept("application/json"))
		completion(.success(adaptedRequest))
	}
}
