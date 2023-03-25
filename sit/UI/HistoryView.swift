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
                    .contextMenu { //This section creates a delete button for the card on long press
                        Button(action: deleteScan) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
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
                .background(CustomColors.gray?.suColor)
            }
            .background(CustomColors.gray?.suColor)
            
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
                        .background(CustomColors.gray?.suColor)
                        
                    Spacer()
                }
            }.onAppear() {
                getPreviousScans()
            }
            .background(CustomColors.gray?.suColor)
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
    private func deleteScan(){
        // NEED TO FINISH FUNCTION TO MAKE DELETION WORK
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
            .environmentObject(AppVariables())
    }
}

/* Code to attempt swipe to delete - need to investigate more
 
 var body: some View {
     let list = List{
     ForEach(previousScans, id: \.self.id){
         (scan: ScanResult) in
         HistoryScanCardView(scan: scan)
            .contextMenu {
                 Button(action: {
                      Delete the scan result from the previousScans array
                     if let index = previousScans.firstIndex(of: scan) {
                         previousScans.remove(at: index)
                     }
                      Delete the scan result from the database
                     let db = Firestore.firestore()
                     db.collection("scans").document(scan.id).delete()
                 }) {
                     Label("Delete", systemImage: "trash")
                 }
             }
         }
         .onDelete { indexSet in
             indexSet.forEach { index in
                  Delete the scan result from the previousScans array
                 let scan = previousScans[index]
                 if let index = previousScans.firstIndex(of: scan) {
                     previousScans.remove(at: index)
                 }
                  Delete the scan result from the database
                 let db = Firestore.firestore()
                 db.collection("scans").document(scan.id).delete()
             }
         }
     }
 
 }
 */
