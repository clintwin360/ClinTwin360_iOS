//
//  PushNotificationsManager.swift
//  ClinTwin360
//
//  Created by Lauren Bongartz on 4/29/20.
//  Copyright © 2020 Lauren Bongartz. All rights reserved.
//

import Foundation
import UIKit

class PushNotificationsManager {
	
	func shouldRequestToRegister(_ completion: @escaping (_ shouldRequest: Bool) -> ()) {
		UNUserNotificationCenter.current().getNotificationSettings { settings in
			print("Notification settings: \(settings)")
			completion(settings.authorizationStatus == .notDetermined)
		}
	}
	
	func requestNotificationsAuthorization(_ completion: @escaping (_ success: Bool) -> ()) {
		UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
			print("Permission granted: \(granted)")
			
			guard granted else {
				completion(false)
				return
			}
			
			UNUserNotificationCenter.current().getNotificationSettings { settings in
				print("Notification settings: \(settings)")
				guard settings.authorizationStatus == .authorized else {
					completion(false)
					return
				}
				DispatchQueue.main.async {
					UIApplication.shared.registerForRemoteNotifications()
					completion(true)
				}
			}
		}
	}
	
}
