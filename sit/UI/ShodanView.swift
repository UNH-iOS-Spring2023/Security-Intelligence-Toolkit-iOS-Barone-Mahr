//
//  ShodanView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//
/// This file defines the structure and design of the page used to initiate Shodan Scans.

import SwiftUI
import Firebase

enum ShodanScanType {
    case SHODAN_PUBLIC_IP
    case SHODAN_FILTER_SEARCH
    case SHODAN_SEARCH_IP
}

struct ShodanView: View {
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                Button(action: {
                    doShodan(scanType: .SHODAN_PUBLIC_IP)
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
    
    private func doShodan(scanType: ShodanScanType) {
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
                var returnData: Any?
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
                    switch scanType {
                    case .SHODAN_PUBLIC_IP:
                        api.getPublicIPAddress { result in
                            switch result {
                            case .success(let publicIP):
                                returnData = publicIP
                            case .failure(let error):
                                errorMessage = "ERROR: \(error.localizedDescription)"
                                apiConnectionSuccessful = false
                            }
                            dispatchGroup.leave()
                        }
                    case .SHODAN_SEARCH_IP:
                        api.getHostInformation(ipAddress: "8.8.8.8") { result in
                            switch result {
                            case .success(let hostInfo):
                                returnData = hostInfo
                            case .failure(let error):
                                errorMessage = "ERROR: \(error.localizedDescription)"
                                apiConnectionSuccessful = false
                            }
                            dispatchGroup.leave()
                        }
                    case .SHODAN_FILTER_SEARCH:
                        api.search(query: "webcam") { result in
                            switch result {
                            case .success(let searchResults):
                                returnData = searchResults
                            case .failure(let error):
                                errorMessage = "ERROR: \(error.localizedDescription)"
                                apiConnectionSuccessful = false
                            }
                            dispatchGroup.leave()
                        }
                    }
                } else {
                    dispatchGroup.leave()
                }
                
                dispatchGroup.notify(queue: .main) {
                    if apiConnectionSuccessful, let returnData = returnData {
                        print("Shodan Return Data: \(returnData)")
                    } else {
                        print(errorMessage!)
                    }
                }
            }
        }
    }
}

struct ShodanView_Previews: PreviewProvider {
    static var previews: some View {
        ShodanView()
    }
}
