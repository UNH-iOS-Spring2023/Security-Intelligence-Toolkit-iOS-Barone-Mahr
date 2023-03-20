//
//  CardView.swift
//  Security Intelligence Toolkit
//
//  Created by Andrew Mahr on 3/19/23.
//  Structure and Card implementation taken from Prof. Pelicano's PianiFit Demo
//

import SwiftUI

struct CardView: View {
    @State  private var isTap: Bool = false
    
    let edgeRadius: CGFloat
    let elevation: CGFloat
    let width: CGFloat
    let height: CGFloat
    let focusColor: Color?
    let color: Color
    let views: () -> AnyView
    let click: () -> Void
    
    init(
        edgeRadius: CGFloat = 16,
        elevation: CGFloat = 2,
        width: CGFloat = CGFloat.infinity,
        height: CGFloat = 140,
        color: Color = Color(.white),
        focusColor: Color? = nil,
        click: @escaping () -> Void = {},
        views           : @escaping () -> AnyView
    ){
        self.edgeRadius = edgeRadius
        self.elevation = elevation
        self.width = width
        self.height = height
        self.color = color
        self.focusColor = focusColor
        self.views = views
        self.click = click
    }
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: edgeRadius)
                .fill(isTap ? focusColor ?? color : color)
                .shadow(radius: elevation)
                .frame(maxWidth: width, maxHeight: height)
            
            VStack{
                views()
            }
            .frame(maxWidth: width, maxHeight: height)
            
        }
        .padding(5)
        .onTapGesture{
            click()
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(focusColor: Color(.systemBlue).opacity(0.05)){
            AnyView(
                Text("Network Scan Results")
            )
        }
    }
}
