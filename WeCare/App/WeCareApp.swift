//
//  WeCareApp.swift
//  WeCare
//
//  Created by student on 13/11/25.
//


import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions:
        [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        print("🔥 Firebase configured successfully")
        return true
    }
}

@main
struct WeCareApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            GiverCalendarView()
        }
    }
}











