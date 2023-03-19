//
//  ScanView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//

import SwiftUI
import Firebase

struct ScanView: View {
    @EnvironmentObject var authState: AuthenticationState
    
    @State private var subnetToScan: String = ""
    
    @State private var errorMessage = ""
    @State private var alertError = false
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("Remote Scan")
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)

                TextField("", text: $subnetToScan)
                    .autocapitalization(.none)
                    .foregroundColor(.white)
                    .placeholder(when: subnetToScan.isEmpty) {
                        Text("Subnet to scan").foregroundColor(.gray)
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

                Button(action: doRemoteScan,
                   label: {
                    Text("Start Remote Scan")
                        .font(.callout)
                        .bold()
                })
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(CustomColors.pink?.suColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)

                Text("Automatically Scan Local Subnet")
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)

                Button(action: {
                    // TODO: do local scan
                }, label: {
                    Text("Start Local Scan")
                        .font(.callout)
                        .bold()
                })
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(CustomColors.pink?.suColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)

                Spacer()
            }
            .alert(errorMessage, isPresented: $alertError){ //display an alert if anything happens during this?
                Button("OK", role: .cancel){}
            }
        }
    }
    
    private func doRemoteScan() {
        if(Util.isValidIPv4(subnetToScan) || Util.isValidCIDR(subnetToScan)) {
            self.errorMessage = "Started Scan on \(subnetToScan)."
            self.alertError = true
            
            DispatchQueue.global(qos: .background).async {
                var data: [String: Any] = Util.doTCPScan(subnetToScan)
                
                data["uid"] = authState.user?.uid
                
                let db = Firestore.firestore()
                db.collection("scans").addDocument(data: data) { error in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.errorMessage = "Error saving scan results: \(error)"
                            self.alertError = true
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.errorMessage = "Finished Scan on \(subnetToScan)."
                            self.alertError = true
                        }
                    }
                }
            }
        } else {
            self.errorMessage = "Error: \(subnetToScan) is not a valid IPv4 or CIDR."
            self.alertError = true
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
