//
//  NetworkManager.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 3/28/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import Alamofire

class NetworkManager {
	
	static let shared = NetworkManager()
	
	var session: Alamofire.Session
	
	private init() {
		let token = Keys.apiToken
		let adapter = AccessTokenAdapter(accessToken: token, prefix: ApiEndpoints.base)
		let interceptor = Interceptor(adapters: [adapter])
		
		session = Alamofire.Session(interceptor: interceptor)
	}
	
	func getQuestions(completion: @escaping (_ response: DataResponse<GetQuestionsResponse, AFError>?) -> ()) {
		session.request(ApiEndpoints.base + ApiEndpoints.questionsEndpoint)
			// This one is helping with debugging for now
			.responseJSON { response in
				print("Response JSON: \(String(describing: response.value))")
			}
	
			.responseDecodable(of: GetQuestionsResponse.self) { response in
				debugPrint("Response: \(response)")
				completion(response)
			}
	}
	
	func postSurveyResponse(_ answer: ResearchQuestionAnswer, completion: @escaping (_ response: DataResponse<PostAnswersResponse, AFError>?) -> ()) {
		
		session.request(ApiEndpoints.base + ApiEndpoints.responsesEndpoint,
						method: .post,
						parameters: answer,
						encoder: JSONParameterEncoder.default)
				// This one is helping with debugging for now
				.responseJSON { response in
					print("Response JSON: \(String(describing: response.value))")
				}
		
				.responseDecodable(of: PostAnswersResponse.self) { response in
					// Does this need a response? It is just echoing back the post parameters for now
					debugPrint("Response: \(response)")
					completion(response)
				}
	}
	
}

