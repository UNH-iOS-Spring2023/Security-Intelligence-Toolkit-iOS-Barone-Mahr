//
//  HistoryScanCardView.swift
//  Security Intelligence Toolkit
//
//  Created by Andrew Mahr on 3/19/23.
//
/// This file contains the code used to define what the HistoryScan Card looks like. It builds off the CardView base code to make it unique.

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
                                .foregroundColor(CustomColors.black?.suColor)
                            Text(scan.createdTime.getFormattedDate(format: "EEEE, MMM d, yyyy h:mm a"))
                                .font(.system(size: 16))
                                .foregroundColor(CustomColors.black?.suColor)
                        }
                        .padding(.vertical, 25)
                        Spacer()
                    }
                )

                
            }
        )
    }
    
    /// Defines what happens when a History Card is clicked on
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
