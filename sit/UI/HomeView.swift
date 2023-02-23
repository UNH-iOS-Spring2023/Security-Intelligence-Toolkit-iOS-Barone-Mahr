//
//  HomeView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                Text("Home")
                    .foregroundColor(.white)
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
