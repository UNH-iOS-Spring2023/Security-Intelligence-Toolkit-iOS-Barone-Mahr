//
//  TopBarView.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/23/23.
//

import SwiftUI

struct TopBarView: View {
    var showSettingsView: () -> Void
    
    @EnvironmentObject var authState: AuthenticationState
    
    var body: some View {
        HStack {
            Image("sit_top_bar_view")
                .resizable()
                .scaledToFit()
                .frame(width:40,height:40)
              
            Text("SIT")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: showSettingsView) {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
        }
        .padding(.all, 20)
        .background(CustomColors.purple?.suColor)
    }
}

struct TopBarView_Previews: PreviewProvider {
    static var previews: some View {
        TopBarView(showSettingsView: { })
    }
}
