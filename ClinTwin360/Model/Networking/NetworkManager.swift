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
		let adapter = AccessTokenAdapter()
		let interceptor = Interceptor(adapters: [adapter])
		
		session = Alamofire.Session(interceptor: interceptor)
	}
	
	func registerUser(email: String, password: String, completion: @escaping (_ error: AFError?) -> ()) {
		
		let request = RegisterUserRequest(email: email, password: password)
		AF.request(ApiEndpoints.base + ApiEndpoints.registerEndpoint,
					method: .post,
					parameters: request,
					encoder: JSONParameterEncoder.default)
			.responseDecodable(of: RegisterUserResponse.self) { response in
				debugPrint("Response: \(response)")
	
				completion(response.error)
			}
	}
	
	func login(username: String, password: String, completion: @escaping (_ error: AFError?) -> ()) {
		
		let request = LoginRequest(username: username, password: password)
		AF.request(ApiEndpoints.base + ApiEndpoints.loginEndpoint,
						method: .post,
						parameters: request,
						encoder: JSONParameterEncoder.default)
				.responseDecodable(of: LoginResponse.self) { response in
					debugPrint("Response: \(response)")
					if let response = response.value {
						KeychainWrapper.standard.set(response.token, forKey: "token")
						KeychainWrapper.standard.set(username, forKey: "username")
					}
					
					completion(response.error)
				}
	}
	
	func getParticipantData(completion: @escaping (_ success: Bool) -> ()) {
		session.request(ApiEndpoints.base + ApiEndpoints.participantEndpoint)
				// This one is helping with debugging for now
				.responseJSON { response in
					print("Response JSON: \(String(describing: response.value))")
				}
		
				.responseDecodable(of: ParticipantDataResponse.self) { response in
					debugPrint("Response: \(response)")
					
					if let data = response.value {
						KeychainWrapper.standard.set(data.id, forKey: "userId")
						completion(true)
					} else {
						completion(false)
					}
				}
	}
	
	func postBasicHealthDetails(healthModel: BasicHealthViewModel, completion: @escaping (_ success: Bool, _ error: AFError?) -> ()) {
		
//		guard let id = KeychainWrapper.standard.integer(forKey: "userId") else {
//			completion(false, nil)
//			return
//		}
		let id = 1
		
		let request = PostBasicHealthRequest(participant: id, height: healthModel.height, weight: healthModel.weight, birthdate: healthModel.birthdate)
		session.request(ApiEndpoints.base + ApiEndpoints.basicHealthEndpoint,
						method: .post,
						parameters: request,
						encoder: JSONParameterEncoder.default)
				.responseJSON { response in
					print("Response JSON: \(String(describing: response.value))")
					
//					if response.response?.statusCode == 200 {
						completion(true, nil)
//					} else {
//						completion(false, nil)
//					}
				}
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
	
	func getMatches(completion: @escaping (_ success: Bool, _ response: DataResponse<GetMatchesReponse, AFError>?) -> ()) {
//		guard let id = KeychainWrapper.standard.integer(forKey: "userId") else {
//			completion(false, nil)
//			return
//		}
		let id = 1
		
		let parameters = GetMatchesRequest(participant: id)
		
		session.request(ApiEndpoints.base + ApiEndpoints.matchesEndpoint,
						parameters: parameters)
				.responseDecodable(of: GetMatchesReponse.self) { response in
					debugPrint("Response: \(response)")

					completion(true,  response)
				}
	}
	
//	func getTrialDetails(trialId: Int?, completion: @escaping (_ response: DataResponse<TrialObject, AFError>?) -> ()) {
//		guard let id = trialId else {
//			completion(nil)
//			return
//		}
//	//		let parameters = GetTrialDetailsRequest(id: id)
//			print(ApiEndpoints.base + ApiEndpoints.trialDetailsEndpoint + "/\(1)")
//			session.request(ApiEndpoints.base + ApiEndpoints.trialDetailsEndpoint + "/\(1)") // TODO: change this to id
//			// This one is helping with debugging for now
//			.responseJSON { response in
//				print("Response JSON: \(String(describing: response.value))")
//				completion(nil)
//			}
//			
//			.responseDecodable(of: TrialObject.self) { response in
//				debugPrint("Response: \(response)")
//				completion(response)
//			}
//	}
	
	// Do not need completion block as this can be done in the background
	func registerForPushNotifications(deviceToken: String) {
		guard let name = KeychainWrapper.standard.string(forKey: "username") else { return }
		let request = PushNotificationsRegistrationRequest(name: name, registrationId: deviceToken)
		session.request(ApiEndpoints.base + ApiEndpoints.pushNotificationsEndpoint,
						method: .post,
						parameters: request,
						encoder: JSONParameterEncoder.default)
			
				.responseJSON { response in
					print("Response JSON: \(String(describing: response.value))")
				}
	}
	
	func signOut(completion: @escaping (_ response: DataResponse<Any, AFError>?) -> ()) {
		session.request(ApiEndpoints.base + ApiEndpoints.signOutEndpoint,
						method: .post)
			.responseJSON { response in
				print("Response JSON: \(String(describing: response.value))")
				completion(nil)
			}
	}
	
	func forgotPassword(forUser user: String, completion: @escaping (_ response: DataResponse<Any, AFError>?) -> ()) {
		let request = ForgotPasswordRequest(email: user)
		
		session.request(ApiEndpoints.base + ApiEndpoints.forgotPasswordEndpoint,
				method: .post,
				parameters: request,
				encoder: JSONParameterEncoder.default)
				.responseJSON { response in
					print("Response JSON: \(String(describing: response.value))")
					completion(response)
		}
	}
}

