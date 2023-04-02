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
                    doShodan(scanType: .SHODAN_SEARCH_IP)
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
                Util.doShodanQuery(apiKey: shodanKeyValue, scanType: scanType)
            }
        }
    }
}

struct ShodanView_Previews: PreviewProvider {
    static var previews: some View {
        ShodanView()
    }
}
