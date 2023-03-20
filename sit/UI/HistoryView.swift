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
    @EnvironmentObject private var app: AppVariables
    @State private var previousScans: [ScanResult] = []
    
    var body: some View {
        let list = ScrollView{
            ForEach(previousScans, id: \.self.id){
                (scan: ScanResult) in HistoryScanCardView(scan: scan)
            }
        }
        
        if(app.isShowingScanResult){
            //TODO - BUILD OUT SCAN RESULT UNIQUE VIEW
        }
        else{
            ZStack {
                CustomColors.gray?.suColor
                    .ignoresSafeArea()
                
                VStack {
                    Text("History")
                        .foregroundColor(.white)
                    list
                }
            }.onAppear() {
                getPreviousScans()
            }
        }
    }
    
    private func getPreviousScans() {
        let db = Firestore.firestore()
        self.previousScans = []
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
            .environmentObject(AppVariables())
    }
}
