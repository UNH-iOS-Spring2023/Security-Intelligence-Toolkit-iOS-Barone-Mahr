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

    func login(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func logout() {
        do {
            try auth.signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func forgotPassword(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        auth.sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(true))
        }
    }
    
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
