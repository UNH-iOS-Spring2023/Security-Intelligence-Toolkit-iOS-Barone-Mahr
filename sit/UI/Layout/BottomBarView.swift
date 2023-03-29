//
//  BottomBarView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/19/23.
//
/// This file defines the layout of the Bottom Bar screen and defines the look and options for Home, Scan, Shodan, and History.

import SwiftUI

struct BottomBarView: View {
    
    @EnvironmentObject private var app: AppVariables
    
    let Home : AnyView
    let Scan : AnyView
    let Shodan : AnyView
    let History : AnyView
    
    init(
        _ Home : AnyView,
        _ Scan : AnyView,
        _ Shodan : AnyView,
        _ History : AnyView
    ) {
        self.Home = Home
        self.Scan = Scan
        self.Shodan = Shodan
        self.History = History
        
        UITabBar.appearance().barTintColor = UIColor(.clear)
        UITabBar.appearance().backgroundColor = CustomColors.purple
        UITabBar.appearance().unselectedItemTintColor = CustomColors.white
    }
    
    var body: some View {
        TabView(selection: $app.selectedTab) {
            Home
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            Scan
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Scan")
                }
                .tag(1)
            
            Shodan
                .tabItem {
                    Image(systemName: "network")
                    Text("Shodan")
                }
                .tag(2)
            
            History
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("History")
                }
                .tag(3)
        }
        .accentColor(CustomColors.black?.suColor)
    }
}

struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        BottomBarView(
            AnyView(HomeView()),
            AnyView(ScanView()),
            AnyView(ShodanView()),
            AnyView(HistoryView())
        )
        .environmentObject(AppVariables())
    }
}
