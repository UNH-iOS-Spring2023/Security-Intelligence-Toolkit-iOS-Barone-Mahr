//
//  ScanView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//

import SwiftUI

struct ScanView: View {
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                Text("Scan")
                    .foregroundColor(.white)
            }
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
