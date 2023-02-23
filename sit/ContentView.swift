//
//  ContentView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/14/23.
//

import SwiftUI

struct ContentView: View {
    var showSettingsView: () -> Void
    
    @StateObject var app = AppVariables()
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        ZStack {
            CustomColors.gray?.suColor
                .ignoresSafeArea()
            
            VStack {
                TopBarView(showSettingsView: showSettingsView)
                    .environmentObject(authState)
                
                BottomBarView(
                    AnyView(HomeView()),
                    AnyView(ScanView()),
                    AnyView(ShodanView()),
                    AnyView(HistoryView())
                )
                .environmentObject(AppVariables())
                .environmentObject(authState)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showSettingsView: { })
            .environmentObject(AuthenticationState())
    }
}
