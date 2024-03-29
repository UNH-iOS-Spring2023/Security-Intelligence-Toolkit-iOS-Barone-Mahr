//
//  SettingsView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/23/23.
//
/// This file defines the design and architecture of the Settings screen which provides users the opportunity to upload their Shodan Key or logout of the app.

import SwiftUI
import Firebase

struct SettingsView: View {
    var showContentView: () -> Void
    
    @EnvironmentObject var authState: AuthenticationState
    
    @State private var shodanKey: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CustomColors.gray?.suColor
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Image("sit_top_bar_view")
                            .resizable()
                            .scaledToFit()
                            .frame(width:40,height:40)
                        
                        Text("SIT")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    .padding(.all, 20)
                    .background(CustomColors.purple?.suColor)
                    
                    Text("Settings")
                        .foregroundColor(.white)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        TextField("", text: $shodanKey)
                            .autocapitalization(.none)
                            .foregroundColor(.white)
                            .placeholder(when: shodanKey.isEmpty) {
                                Text("Shodan Key").foregroundColor(.gray)
                            }
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.white)
                                    .offset(y: 16)
                                    .padding(.horizontal, 0)
                            )
                            .multilineTextAlignment(.center)
                        
                        Button(action: saveShodanKey, label: {
                            Text("Save Settings")
                                .font(.callout)
                                .bold()
                        })
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(CustomColors.pink?.suColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        Button(action: showContentView, label: {
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
                    
                    Spacer()
                    
                    Button(action: doLogOut, label: {
                        Text("Logout")
                            .font(.callout)
                            .bold()
                    })
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
        }
        .onAppear(perform: fetchShodanKey)
    }
    
    /// This function will fetch the user's Shodan Key from the Firestore database
    private func fetchShodanKey() {
        guard let userId = authState.user?.uid else { return }
        
        let db = Firestore.firestore()
        let settingsRef = db.collection("settings").document(userId)
        
        settingsRef.getDocument { document, error in
            guard let document = document, document.exists else {
                return
            }
            
            if let shodanKeyValue = document.data()?["shodanKey"] as? String {
                shodanKey = shodanKeyValue
            }
        }
    }
    
    ///This function will save the users Shodan Key to the database
    private func saveShodanKey() {
        guard let userID = authState.user?.uid else { return }
        let db = Firestore.firestore()
        let settingsRef = db.collection("settings").document(userID)
        
        let data: [String: Any] = ["shodanKey": shodanKey]
        
        settingsRef.setData(data, merge: true) { error in
            if let error = error {
                print("Error updating shodan key: \(error.localizedDescription)")
            } else {
                print("Shodan key saved successfully.")
            }
        }
    }
    
    ///This function handles logging out the user and resetting the app to the home screen after relogin
    private func doLogOut() {
        showContentView() //Required so that they return to the home screen after logging back in.
        authState.logout()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showContentView: { })
    }
}
