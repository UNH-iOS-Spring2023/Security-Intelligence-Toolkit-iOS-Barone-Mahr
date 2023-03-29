//
//  HomeView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//
/// This page defines the home screen users see when the login to the application. It provides a brief overview of the application and its capabilities.

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
                Text("SIT enables network intelligence for everyone. It provides you with the ability to perform real-time network interrogation on your local and remote networks.")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("The discovery of systems on networks are saved to a database and can be viewed at any time by selecting the history button below." )
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                Text("Additional features include integration with Shodan, a search engine for discovering unsecured Internet of Things (IoT) devices.")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
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
