//
//  AuthenticationState.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//

import Foundation
import Firebase

class AuthenticationState: ObservableObject {
    
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoggingIn = false
    
    private let auth = Auth.auth()
    
    init() {
        auth.addStateDidChangeListener { auth, user in
            self.user = user
            self.isAuthenticated = user != nil
        }
    }

    /// Authenticates the user with the given email and password.
    ///
    /// - Parameters:
    ///  - email: The user's email address.
    ///  - password: The user's password.
    ///  - completion: A completion handler that takes a Result object containing a boolean value indicating success or failure, or an Error object if the operation failed.
    ///
    /// - Returns: None. The result of the operation is passed to the completion handler.
    func login(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    /// Signs out the current user and sets user and isAuthenticated properties to nil and false, respectively.
    ///
    /// - Throws: An error if signing out fails.
    func logout() {
        do {
            try auth.signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    /// Sends a password reset email to the user associated with the provided email address.
    ///
    /// - Parameters:
    ///  - email: The email address associated with the user account.
    ///  - completion: A completion handler that takes a Result object containing a boolean value indicating success or failure, or an Error object if the operation failed.
    ///
    /// - Returns: None. The result of the operation is passed to the completion handler.
    func forgotPassword(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(true))
        }
    }
    
    /// Registers a new user with the provided email and password, and confirms the password by comparing it with the password confirmation value.
    ///
    /// - Parameters:
    ///  - email: The email of the user to register.
    ///  - password: The password of the user to register.
    ///  - passwordConfirmation: The confirmation of the password provided by the user.
    ///  - completion: A completion handler that takes a Result object containing a boolean value indicating success or failure, or an Error object if the operation failed.
    ///
    /// - Returns: None. The result of the operation is passed to the completion handler.
    func signUp(email: String, password: String, passwordConfirmation: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard password == passwordConfirmation else {
            completion(.failure(NSError(domain: "", code: 9210, userInfo: [NSLocalizedDescriptionKey: "Password and confirmation do not match"])))
            return
        }
        
        self.isLoggingIn = true
        
        auth.createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoggingIn = false
                
                if let error = error {
                    completion(.failure(error))
                } else if let user = authResult?.user {
                    self.user = user
                    completion(.success(true))
                }
            }
        }
    }
}
