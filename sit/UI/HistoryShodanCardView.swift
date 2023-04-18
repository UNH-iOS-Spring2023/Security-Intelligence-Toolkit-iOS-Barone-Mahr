//
//  HistoryShodanCardView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 4/2/23.
//

import SwiftUI

struct HistoryShodanCardView: View {
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
                            switch(scan.scanType) {
                            case "SHODAN_SEARCH_IP":
                                Text("Shodan Search IP Result: \(((scan.results as? [[String: Any]])?.first?.keys.first as? String)!)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(CustomColors.black?.suColor)
                            case "SHODAN_PUBLIC_IP":
                                Text("Shodan Public IP Result: \(scan.attemptedScan)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(CustomColors.black?.suColor)
                            case "SHODAN_FILTER_SEARCH":
                                Text("Shodan Search Filter Result: \(scan.attemptedScan)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(CustomColors.black?.suColor)
                            default:
                                Text("INVALID_SHODAN_TYPE: \(scan.attemptedScan)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(CustomColors.black?.suColor)
                            }
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

struct HistoryShodanCardView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryShodanCardView(scan: ScanResult(id: "1", data: [
            "attemptedScan": "8.8.8.8",
            "createdTime": Date(),
            "localScan":false,
            "networkScan": false,
            "results": [
                ["SHODAN_PUBLIC_SCAN":[]
                ]
            ],
            "scanType":"SHODAN_PUBLIC_IP",
            "uid": ""
        ])!)
    }
}
