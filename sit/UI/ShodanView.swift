//
//  ShodanView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//
/// This file defines the structure and design of the page used to initiate Shodan Scans.

import SwiftUI

struct ShodanView: View {
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                Text("Shodan")
                    .foregroundColor(.white)
            }
        }
    }
}

struct ShodanView_Previews: PreviewProvider {
    static var previews: some View {
        ShodanView()
    }
}
