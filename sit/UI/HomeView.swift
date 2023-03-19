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
                Spacer()
                Text("Welcome to SIT!")
                    .foregroundColor(.white)
                    .font(.system(size:42))
                Text("SIT enables network intelligence for everyone. It provides you with the ability to perform real-time network interrogation on your local and remote networks.The discovery of systems on networks are saved to a database and can be viewed at any time by selecting the history button below. Additional features include integration with Shodan, a search engine for discovering unsecured Internet of Things (IoT) devices.")
                    .foregroundColor(.white)
                Spacer()
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
