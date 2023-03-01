//
//  SettingsView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/23/23.
//

import SwiftUI

struct SettingsView: View {
    var showContentView: () -> Void
    
    @EnvironmentObject var authState: AuthenticationState
    
    @State private var shodanKey: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CustomColors.gray?.suColor
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Text("SIT")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                    .padding(.all, 20)
                    .background(CustomColors.purple?.suColor)
                    
                    Text("Settings")
                        .foregroundColor(.white)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        TextField("", text: $shodanKey)
                            .autocapitalization(.none)
                            .foregroundColor(.white)
                            .placeholder(when: shodanKey.isEmpty) {
                                Text("Shodan Key").foregroundColor(.gray)
                            }
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(.white)
                                    .offset(y: 16)
                                    .padding(.horizontal, 0)
                            )
                        
                        Button(action: saveShodanKey, label: {
                            Text("Save Settings")
                                .font(.callout)
                                .bold()
                        })
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(CustomColors.pink?.suColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                        Button(action: showContentView, label: {
                            Text("Back")
                                .font(.callout)
                                .bold()
                        })
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        
                    }
                    .frame(maxWidth: geometry.size.width * 0.95)
                    
                    Spacer()
                    
                    Button(action: doLogOut, label: {
                        Text("Logout")
                            .font(.callout)
                            .bold()
                    })
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background(.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func saveShodanKey() {
        // TODO: Write code here to save shodan key to firestore
    }
    
    private func doLogOut() {
        showContentView() //Required so that they return to the home screen after logging back in.
        authState.logout()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showContentView: { })
    }
}
