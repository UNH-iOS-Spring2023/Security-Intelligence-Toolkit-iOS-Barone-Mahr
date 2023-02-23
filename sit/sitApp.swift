//
//  sitApp.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/14/23.
//

import SwiftUI
import Firebase

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
