//
//  HistoryScanCardView.swift
//  Security Intelligence Toolkit
//
//  Created by Andrew Mahr on 3/19/23.
//

import SwiftUI

struct HistoryScanCardView: View {
    @EnvironmentObject private var app: AppVariables
    @ObservedObject var scan: ScanResult
    
    init(
        scan: ScanResult
    ){
        self.scan = scan
    }
    
    var body: some View {
        CardView(
            edgeRadius: 16,
            elevation: 3,
            height: 150,
            color: Color(.white),
            focusColor: CustomColors.white?.suColor.opacity(0.05),
            click: clickScanItem,
            views:{
                AnyView(
                    HStack{
                        Spacer()
                        VStack{
                            Text("Network Scan: \(scan.attemptedScan)")
                                .font(.system(size: 18, weight: .bold))
                            Text(scan.createdTime.getFormattedDate(format: "EEEE, MMM d, yyyy h:mm a"))
                                .font(.system(size: 16))
                        }
                        .padding(.vertical, 25)
                        Spacer()
                    }
                )

                
            }
        )
    }
    
    private func clickScanItem(){
        app.selectedScan = scan
        app.isShowingScanResult = true
    }
}

struct HistoryScanCardView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryScanCardView(scan: ScanResult(id: "1", data: [
            "attemptedScan": "8.8.8.8/32",
            "createdTime": Date(),
            "localScan":false,
            "networkScan": true,
            "results": [
                ["8.8.8.8":[
                        "443",
                        "53"
                    ]
                ]
            ],
            "scanType":"",
            "uid": ""
        ])!)
    }
}
