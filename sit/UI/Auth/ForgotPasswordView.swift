//
//  ForgotPasswordView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/23/23.
//

import SwiftUI

struct ForgotPasswordView: View {
    var showLoginView: () -> Void
    
    @EnvironmentObject var authState: AuthenticationState
    
    @State private var email: String = ""
    @State private var errorMessage = ""
    @State private var passwordErrorAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CustomColors.gray?.suColor
                    .ignoresSafeArea()
                VStack(spacing: 64) {
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
                        
                        Button(action: doForgotPassword, label: {
                            Text("Forgot Password")
                                .font(.callout)
                                .bold()
                        })
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(CustomColors.pink?.suColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .disabled(email.count == 0)
                        
                        Button(action: showLoginView, label: {
                            Text("Back")
                                .font(.callout)
                                .bold()
                        })
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: geometry.size.width * 0.95)
                    .alert(errorMessage, isPresented: $passwordErrorAlert){
                        Button("OK", role: .cancel){}
                    }
                }
            }
        }
    }
    
    private func doForgotPassword() {
        authState.forgotPassword(email: email){ result in
            switch result {
                case .success(let success):
                    if success {
                        // Switch to main view
                        self.errorMessage = ""
                        showLoginView()
                    } else {
                        self.errorMessage = "Forgot Password Failure."
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.passwordErrorAlert = true
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(showLoginView: { })
    }
}
