//
//  HistoryScanDetailsCardView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 3/19/23.
//
/// This file contains the code which defines the architecture and design used to present the individual scan results associated with a Card. It presents the IP address that was scanned, and the date the scan was initiated.

import SwiftUI

struct HistoryScanDetailsCardView: View {
    @ObservedObject var scan: ScanResult
    private var list: [(String, [String])]
    private var height: CGFloat = 150
    
    init(
        scan: ScanResult
    ){
        self.scan = scan
        self.list = scan.getNetworkScanResults()
        if(self.list.count < 3) {
            self.height = CGFloat(150 + (self.list.count * 50))
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
                            Text("Network Scan: \(scan.attemptedScan)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(CustomColors.black?.suColor)
                            
                            Text(scan.createdTime.getFormattedDate(format: "EEEE, MMM d, yyyy h:mm a"))
                                .font(.system(size: 16))
                                .padding(.bottom, 8)
                                .foregroundColor(CustomColors.black?.suColor)
                            
                            Text("Open Port Results")
                                .font(.system(size: 18))
                                .underline()
                                .foregroundColor(CustomColors.black?.suColor)
                            
                            ForEach(list, id: \.0) { ip, ports in
                                Section(header: Text("\(ip):")
                                                    .bold()
                                                    .foregroundColor(CustomColors.black?.suColor)
                                ){
                                    if(ports.count == 0) {
                                        Text("No open ports")
                                            .padding(.leading, 20)
                                            .foregroundColor(CustomColors.black?.suColor)
                                    } else {
                                        ForEach(ports, id: \.self) { port in
                                            Text("• \(port)")
                                                .padding(.leading, 20)
                                                .foregroundColor(CustomColors.black?.suColor)
                                        }
                                    }
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

struct HistoryScanDetailsCardView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryScanDetailsCardView(scan: ScanResult(id: "1", data: [
            "attemptedScan": "8.8.8.8/32",
            "createdTime": Date(),
            "localScan":false,
            "networkScan": true,
            "results": [
                ["8.8.8.8":[
                        NSNumber(value: 443),
                        NSNumber(value: 53)
                    ],
                 "8.8.8.9":[
                         NSNumber(value: 443),
                         NSNumber(value: 53)
                     ],
                 "8.8.8.10":[
                         NSNumber(value: 443),
                         NSNumber(value: 53)
                     ],
                 "8.8.8.11":[
                         NSNumber(value: 443),
                         NSNumber(value: 53)
                     ]
                ]
            ],
            "scanType":"",
            "uid": ""
        ])!)
    }
}
