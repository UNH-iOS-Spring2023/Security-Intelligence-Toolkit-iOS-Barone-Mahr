//
//  ShodanView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//
/// This file defines the structure and design of the page used to initiate Shodan Scans.

import SwiftUI

struct ShodanView: View {
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                Button(action: {
                    let api = ShodanAPI()

                    api.testAPIConnection { result in
                        switch result {
                        case .success(let isConnected):
                            if isConnected {
                                print("API connection successful")
                            } else {
                                print("API connection failed")
                            }
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }

                    api.getHostInformation(ipAddress: "8.8.8.8") { result in
                        switch result {
                        case .success(let hostInfo):
                            print("Host information for 8.8.8.8: \(hostInfo)")
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                    
                    api.getPublicIPAddress { result in
                        switch result {
                        case .success(let publicIP):
                            print("Your public IP address is: \(publicIP)")
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                    
                    api.search(query: "webcam") { result in
                        switch result {
                        case .success(let searchResults):
                            print("Search results: \(searchResults)")
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                        }
                    }

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
}

struct ShodanView_Previews: PreviewProvider {
    static var previews: some View {
        ShodanView()
    }
}
