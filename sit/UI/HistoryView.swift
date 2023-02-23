//
//  HistoryView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                Text("History")
                    .foregroundColor(.white)
            }
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
