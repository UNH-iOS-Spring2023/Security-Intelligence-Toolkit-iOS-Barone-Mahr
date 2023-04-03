//
//  HistoryShodanDetailsCardView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 4/2/23.
//

import SwiftUI

struct HistoryShodanDetailsCardView: View {
    @ObservedObject var scan: ScanResult
    private var height: CGFloat = 150
    private var list: [String]
    
    init(
        scan: ScanResult
    ){
        self.scan = scan
        self.list = []
        if(scan.scanType == "SHODAN_FILTER_SEARCH") {
            self.list = scan.getShodanFilterResults()
        }
        
        if(scan.scanType == "SHODAN_PUBLIC_IP") {
            self.height = 150
        } else {
            self.height = 300
        }
    }
    
    
    var body: some View {
        CardView(
            edgeRadius: 16,
            elevation: 3,
            height: self.height,
            color: Color(.white),
            focusColor: CustomColors.white?.suColor.opacity(0.05),
            views:{
                AnyView(
                    ScrollView {
                        VStack(alignment: .leading){
                            if(self.scan.scanType == "SHODAN_PUBLIC_IP") {
                                Text("Shodan Public IP Result:")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(CustomColors.black?.suColor)
                            } else {
                                Text("Shodan Search Filter Result: \(scan.attemptedScan)")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(CustomColors.black?.suColor)
                            }
                            
                            Text(scan.createdTime.getFormattedDate(format: "EEEE, MMM d, yyyy h:mm a"))
                                .font(.system(size: 16))
                                .padding(.bottom, 8)
                                .foregroundColor(CustomColors.black?.suColor)
                            
                            if(self.scan.scanType == "SHODAN_PUBLIC_IP") {
                                Text("IP Address: \(scan.attemptedScan)")
                                    .font(.system(size: 18))
                                    .underline()
                                    .foregroundColor(CustomColors.black?.suColor)
                            } else {
                                Text("Shodan Query Matches:")
                                    .font(.system(size: 18))
                                    .underline()
                                    .foregroundColor(CustomColors.black?.suColor)
                            }
                            
                            if(self.scan.scanType == "SHODAN_FILTER_SEARCH") {
                                ForEach(list, id: \.self) { str in
                                    Text(str)
                                        .padding(.leading, 20)
                                        .foregroundColor(CustomColors.black?.suColor)
                                }
                            }
                            
                        }
                        .padding(.vertical, 25)
                    }
                )
            }
        )
    }
}

struct HistoryShodanDetailsCardView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryShodanDetailsCardView(scan: ScanResult(id: "1", data: [
            "attemptedScan": "8.8.8.8",
            "createdTime": Date(),
            "localScan":false,
            "networkScan": false,
            "results": [
                ["SHODAN_PUBLIC_IP":[]
                ]
            ],
            "scanType":"SHODAN_PUBLIC_IP",
            "uid": ""
        ])!)
    }
}
