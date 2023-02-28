//
//  SignUpView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/20/23.
//

import SwiftUI

struct SignUpView: View {
    var showLoginView: () -> Void
    
    @EnvironmentObject var authState: AuthenticationState

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordConf: String = ""
    @State private var isShowingPassword = false
    @State private var errorMessage = ""
    @State private var signUpError = false
    
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
                        
                        if isShowingPassword {
                            TextField("", text: $password)
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                                .placeholder(when: password.isEmpty) {
                                    Text("Password").foregroundColor(.gray)
                                }
                        } else {
                            SecureField("", text: $password)
                                .foregroundColor(.white)
                                .placeholder(when: password.isEmpty) {
                                    Text("Password").foregroundColor(.gray)
                                }
                        }
                        
                        if isShowingPassword {
                            TextField("", text: $passwordConf)
                                .textContentType(.password)
                                .autocapitalization(.none)
                                .foregroundColor(.white)
                                .placeholder(when: passwordConf.isEmpty) {
                                    Text("Password Confirmation").foregroundColor(.gray)
                                }
                        } else {
                            SecureField("", text: $passwordConf)
                                .foregroundColor(.white)
                                .placeholder(when: passwordConf.isEmpty) {
                                    Text("Password Confirmation").foregroundColor(.gray)
                                }
                        }
                        
                        Toggle("Show password", isOn: $isShowingPassword)
                            .foregroundColor(.white)
                        
                        Button(action: doSignUp) {
                            Text("Sign Up")
                                .font(.callout)
                                .foregroundColor(.white)
                        }
                        .disabled(email.count == 0 && password.count == 0)
                        
                        Button(action: showLoginView) {
                            Text("Back")
                                .font(.callout)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: geometry.size.width * 0.95)
                    .alert(errorMessage, isPresented: $signUpError){
                        Button("OK", role: .cancel){}
                    }
                }
            }
        }
    }
    
    private func doSignUp() {
        authState.signUp(email: email, password: password, passwordConfirmation: passwordConf) { result in
            authState.isLoggingIn = false
            switch result {
                case .success(let success):
                    if success {
                        // Switch to main view
                        self.errorMessage = ""
                        showLoginView() //if you don't call this here after a log out they'll be brought to signup again instead of login
                    } else {
                        self.errorMessage = "Sign Up Failure."
                        self.signUpError = true
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.signUpError = true
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(showLoginView: { })
    }
}
