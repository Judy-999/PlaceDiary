//
//  AppDelegate.swift
//  WeThereProject
//
//  Created by 김주영 on 2021/05/26. --> Refacted on 2022/12/15
//

import UIKit
import Firebase
import GoogleMaps
import GooglePlaces

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyCKaNwQ-mrvM3rezwCFgoac9H1NO7-5f2s")
        GMSPlacesClient.provideAPIKey("AIzaSyCKaNwQ-mrvM3rezwCFgoac9H1NO7-5f2s")
        Thread.sleep(forTimeInterval: 0.1)
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

