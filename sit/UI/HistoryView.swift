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
                (scan: ScanResult) in
                    HistoryScanCardView(scan: scan)
            }
        }
        
        if(app.isShowingScanResult){
            //TODO: BUILD OUT SCAN RESULT UNIQUE VIEW
            ZStack{
                CustomColors.gray?.suColor
                    .ignoresSafeArea()
                
                VStack{
                    if(app.selectedScan!.networkScan) {
                        Text("Network Scan: \(app.selectedScan!.attemptedScan)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else {
                        //TODO: Shodan Query
                    }
                    Spacer()
                    
                    if(app.selectedScan!.networkScan) {
                        HistoryScanDetailsCardView(scan: app.selectedScan!)
                    }
                    
                    Spacer()
                    Button(action: {
                        app.isShowingScanResult = false
                    }, label: {
                        Text("Back")
                            .font(.callout)
                            .bold()
                    })
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
        }
        else{
            ZStack {
                CustomColors.gray?.suColor
                    .ignoresSafeArea()
                
                VStack {
                    Text("History")
                        .font(.title)
                        .fontWeight(.bold)
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
