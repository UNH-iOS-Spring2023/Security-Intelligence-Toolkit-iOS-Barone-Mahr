//
//  ScanView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//

import SwiftUI

struct ScanView: View {
    @EnvironmentObject var authState: AuthenticationState
    
    @State private var subnetToScan: String = ""
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("Remote Scan")
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)

                TextField("", text: $subnetToScan)
                    .autocapitalization(.none)
                    .foregroundColor(.white)
                    .placeholder(when: subnetToScan.isEmpty) {
                        Text("Subnet to scan").foregroundColor(.gray)
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.white)
                            .offset(y: 16)
                            .padding(.horizontal, 16) // match button width
                    )

                Button(action: {
                    let result = Util.doTCPCheck(host: subnetToScan, port: UInt16(80))
                    if result {
                        print("IT WORKED!!!")
                    } else {
                        print("IT DIDNT WORK!!")
                    }
                }, label: {
                    Text("Start Remote Scan")
                        .font(.callout)
                        .bold()
                })
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(CustomColors.pink?.suColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)

                Text("Automatically Scan Local Subnet")
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)

                Button(action: {
                    // TODO: do local scan
                }, label: {
                    Text("Start Local Scan")
                        .font(.callout)
                        .bold()
                })
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(CustomColors.pink?.suColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.horizontal)

                Spacer()
            }
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
