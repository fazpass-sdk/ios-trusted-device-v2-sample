//
//  AppDelegate.swift
//  ios-trusted-device-v2-sample
//
//  Created by Andri nova riswanto on 11/11/24.
//

import Foundation
import UIKit
import Fazpass

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Fazpass.shared.`init`(publicAssetName: "FazpassKey", application: application, fcmAppId: "1:762638394860:ios:19b19305e8ae6a4dc90cc9")
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Fazpass.shared.registerDeviceToken(deviceToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
}
