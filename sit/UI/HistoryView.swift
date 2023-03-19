//
//  HistoryView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//

import SwiftUI
import Firebase

struct HistoryView: View {
    @EnvironmentObject var authState: AuthenticationState
    
    @State private var previousScans: [ScanResult] = []
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                Text("History")
                    .foregroundColor(.white)
            }
        }.onAppear() {
            getPreviousScans()
        }
    }
    
    private func getPreviousScans() {
        let db = Firestore.firestore()
        
        db.collection("scans")
            .whereField("uid", isEqualTo: String(authState.user?.uid ?? ""))
            .getDocuments() { (querySnapshot, error) in
                if let error = error {
                    //TODO: Handle error
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let id = document.documentID
                        if let scanResult = ScanResult(id: document.documentID, data: document.data()) {
                            self.previousScans.append(scanResult)
                        }
                    }
                }
            }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
