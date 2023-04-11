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
    
    @State private var shodanQuery: String = ""
    @State private var selectedOption = 0
    @State private var isTextFieldVisible = false
    @State private var queryPlaceholder = ""
    let options = ["My Public IP", "Search Filter (e.g. webcam)", "Search IP"]
    
    @State private var errorMessage = ""
    @State private var alertError = false
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                if isTextFieldVisible {
                    TextField("", text: $shodanQuery)
                        .autocapitalization(.none)
                        .foregroundColor(.white)
                        .placeholder(when: shodanQuery.isEmpty) {
                            Text(queryPlaceholder).foregroundColor(.gray)
                        }
                        .padding(.leading)
                        .padding(.trailing)
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.white)
                                .offset(y: 16)
                                .padding(.horizontal, 16) // match button width
                        )
                }
                
                Spacer().frame(height: 16)
                
                Menu {
                    ForEach(0 ..< 3) { index in
                        Button(action: {
                            self.selectedOption = index
                            self.isTextFieldVisible = index > 0
                            
                            switch index {
                            case 1:
                                shodanQuery = ""
                                queryPlaceholder = "Query String"
                            case 2:
                                shodanQuery = ""
                                queryPlaceholder = "IPv4 Address"
                            default:
                                queryPlaceholder = ""
                                shodanQuery = ""
                            }
                        }, label: {
                            Text(options[index])
                                .foregroundColor(.white)
                        })
                    }
                } label: {
                    HStack {
                        Text(options[selectedOption])
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.white)
                    }
                }
                .menuStyle(DefaultMenuStyle())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.leading)
                .padding(.trailing)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.white)
                        .offset(y: 16)
                        .padding(.horizontal, 16)
                )
                
                Spacer().frame(height: 16)
                
                Button(action: {
                    switch selectedOption {
                    case 0:
                        doShodan(scanType: .SHODAN_PUBLIC_IP, input: "")
                    case 1:
                        doShodan(scanType: .SHODAN_FILTER_SEARCH, input: shodanQuery)
                    case 2:
                        doShodan(scanType: .SHODAN_SEARCH_IP, input: shodanQuery)
                    default:
                        print("ERROR: Invalid selection...")
                    }
                    
                }, label: {
                    Text("Run Shodan")
                        .font(.callout)
                        .bold()
                })
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(CustomColors.pink?.suColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)
            }
            .alert(errorMessage, isPresented: $alertError){ //display an alert if anything happens during this?
                Button("OK", role: .cancel){}
            }
        }
    }
    
    private func doShodan(scanType: ShodanScanType, input: String) {
        guard let userId = authState.user?.uid else { return }
        
        if(scanType == .SHODAN_SEARCH_IP) {
            if(!Util.isValidIPv4(input)) {
                self.errorMessage = "ERROR: Please provide a valid IPv4 Address!"
                self.alertError = true
                return
            }
        } else if(scanType == .SHODAN_FILTER_SEARCH) {
            if(input == "") {
                self.errorMessage = "ERROR: Query string cannot be empty!"
                self.alertError = true
                return
            }
        }
        
        let db = Firestore.firestore()
        let settingsRef = db.collection("settings").document(userId)
        
        settingsRef.getDocument { document, error in
            guard let document = document, document.exists else {
                self.errorMessage = "ERROR: No Shodan Key set!"
                self.alertError = true
                //print("ERROR: No Shodan Key set!")
                return
            }
            
            if let shodanKeyValue = document.data()?["shodanKey"] as? String {
                Util.doShodanQuery(apiKey: shodanKeyValue, scanType: scanType, uid: userId, input: input)
                self.errorMessage = "Shodan Query Finished"
                self.alertError = true
            }
        }
    }
}

struct ShodanView_Previews: PreviewProvider {
    static var previews: some View {
        ShodanView()
    }
}
