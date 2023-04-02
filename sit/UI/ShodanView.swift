//
//  ShodanView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//
/// This file defines the structure and design of the page used to initiate Shodan Scans.

import SwiftUI
import Firebase

struct ShodanView: View {
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                Button(action: {
                    doShodan()
                }, label: {
                    Text("Test Shodan")
                        .font(.callout)
                        .bold()
                })
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(CustomColors.pink?.suColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
            }
        }
    }
    
    private func doShodan() {
        guard let userId = authState.user?.uid else { return }
        
        let db = Firestore.firestore()
        let settingsRef = db.collection("settings").document(userId)
        
        settingsRef.getDocument { document, error in
            guard let document = document, document.exists else {
                print("ERROR: No Shodan Key set!")
                return
            }
            
            if let shodanKeyValue = document.data()?["shodanKey"] as? String {
                let api = ShodanAPI(apiKey: shodanKeyValue)
                
                let dispatchGroup = DispatchGroup()
                var apiConnectionSuccessful = false
                var publicIPAddress: String?
                var errorMessage: String?
                
                dispatchGroup.enter()
                api.testAPIConnection { result in
                    switch result {
                    case .success(let isConnected):
                        if isConnected {
                            apiConnectionSuccessful = true
                        } else {
                            errorMessage = "ERROR: API connection failed, verify API Key!"
                        }
                    case .failure(let error):
                        errorMessage = "ERROR: \(error.localizedDescription)"
                    }
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                if(apiConnectionSuccessful) {
                    api.getPublicIPAddress { result in
                        switch result {
                        case .success(let publicIP):
                            publicIPAddress = publicIP
                        case .failure(let error):
                            errorMessage = "ERROR: \(error.localizedDescription)"
                            apiConnectionSuccessful = false
                        }
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
                
                dispatchGroup.notify(queue: .main) {
                    if apiConnectionSuccessful, let publicIPAddress = publicIPAddress {
                        print("API connection successful, your public IP address is: \(publicIPAddress)")
                    } else {
                        print(errorMessage!)
                    }
                }

                /* api.getHostInformation(ipAddress: "8.8.8.8") { result in
                    switch result {
                    case .success(let hostInfo):
                        print("Host information for 8.8.8.8: \(hostInfo)")
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                } */
                
                
                
                /* api.search(query: "webcam") { result in
                    switch result {
                    case .success(let searchResults):
                        print("Search results: \(searchResults)")
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                    }
                } */
            }
        }
    }
}

struct ShodanView_Previews: PreviewProvider {
    static var previews: some View {
        ShodanView()
    }
}
