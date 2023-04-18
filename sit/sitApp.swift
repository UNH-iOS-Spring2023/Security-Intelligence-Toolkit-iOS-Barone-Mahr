//
//  sitApp.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/14/23.
//

import SwiftUI
import Firebase
import UserNotifications

@main
struct sitApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var authState = AuthenticationState()
    
    @State private var currentAuthView = 0
    /*
     currentAuthView vals:
     0 - LoginView
     1 - SignUpView
     2 - ForgotPasswordView
     */
    
    @State private var isShowingSettingsView = false
    
    init() {
        FirebaseApp.configure()
        //Requests permission to send the user notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if let error = error {
                        print("Error requesting notification authorization: \(error.localizedDescription)")
                    } else if granted {
                        print("Notification authorization granted")
                    } else {
                        print("Notification authorization denied")
                    }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if authState.isAuthenticated {
                if !isShowingSettingsView {
                    ContentView(showSettingsView: { isShowingSettingsView = true })
                        .environmentObject(authState)
                } else {
                    SettingsView(showContentView: { isShowingSettingsView = false })
                        .environmentObject(authState)
                }
                
            } else {
                if currentAuthView == 0 {
                    LoginView(showSignUpView: { currentAuthView = 1 }, showForgotPasswordView: { currentAuthView = 2 })
                        .environmentObject(authState)
                } else if currentAuthView == 1 {
                    SignUpView(showLoginView: { currentAuthView = 0 })
                        .environmentObject(authState)
                } else {
                    ForgotPasswordView(showLoginView: { currentAuthView = 0 })
                        .environmentObject(authState)
                }
            }
        }
    }
}
