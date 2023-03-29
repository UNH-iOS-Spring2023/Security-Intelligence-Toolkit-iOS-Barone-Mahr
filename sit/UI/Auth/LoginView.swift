//
//  LoginView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//

import SwiftUI

struct LoginView: View {
    var showSignUpView: () -> Void
    var showForgotPasswordView: () -> Void
    
    @EnvironmentObject var authState: AuthenticationState

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingPassword = false
    @State private var errorMessage = ""
    @State private var alertError = false
    
    @State private var path = NavigationPath()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CustomColors.gray?.suColor
                    .ignoresSafeArea()
                VStack(spacing: 64) {
                    Image("sit_logo_small")
                    Text("Security Intelligence Toolkit")
                        .foregroundColor(CustomColors.purple?.suColor)
                        .bold()
                        .font(.title)
                    
                    VStack(spacing: 16) {
                        TextField("", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(.white)
                            .placeholder(when: email.isEmpty) {
                                Text("Email").foregroundColor(.gray)
                            }
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.white)
                                    .offset(y: 16)
                                    .padding(.horizontal, 0)
                            )
                        
                        if isShowingPassword {
                            TextField("", text: $password)
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                                .placeholder(when: password.isEmpty) {
                                    Text("Password").foregroundColor(.gray)
                                }
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.white)
                                        .offset(y: 16)
                                        .padding(.horizontal, 0)
                                )
                        } else {
                            SecureField("", text: $password)
                                .foregroundColor(.white)
                                .placeholder(when: password.isEmpty) {
                                    Text("Password").foregroundColor(.gray)
                                }
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.white)
                                        .offset(y: 16)
                                        .padding(.horizontal, 0)
                                )
                        }
                        
                        Toggle("Show password", isOn: $isShowingPassword)
                            .foregroundColor(.white)
                        
                        Button(action: doLogin, label: {
                            Text("Login")
                                .font(.callout)
                                .bold()
                        })
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(CustomColors.pink?.suColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .disabled(email.count == 0 && password.count == 0)
                        
                        Button(action: showSignUpView, label: {
                            Text("Sign Up")
                                .font(.callout)
                                .bold()
                        })
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(CustomColors.pink?.suColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        Button(action: showForgotPasswordView, label: {
                            Text("Forgot Password")
                                .font(.callout)
                                .bold()
                        })
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(CustomColors.pink?.suColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: geometry.size.width * 0.95)
                    .alert(errorMessage, isPresented: $alertError){ //display an alert if anything happens during this?
                        Button("OK", role: .cancel){}
                    }
                }
            }
        }
    }
    
    /// Perform login with given email and password.
    ///
    /// - Parameters:
    ///  - email: The email to use for login.
    ///  - password: The password to use for login.
    ///
    ///  - Returns: None. Updates authState.
    private func doLogin() {
        authState.login(email: email, password: password) { result in
            authState.isLoggingIn = false
            switch result {
                case .success(let success):
                    if success {
                        // Switch to main view
                        self.errorMessage = ""
                    } else {
                        self.alertError = true
                        self.errorMessage = "Incorrect email or password."
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.alertError = true
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showSignUpView: { }, showForgotPasswordView: { })
    }
}
