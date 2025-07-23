//
//  StartView.swift
//  GameColor
//
//  Created by Thanh Dao on 8/7/25.
//

import SwiftUI

struct StartView: View {
    @State private var navigateToSource = false
    
    var body: some View {
        GeometryReader{geometry in
            ZStack{
                LinearGradient(
                    colors: [.color1, .color2],
                    startPoint: .topTrailing,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack{
                    Spacer()
                    Image("UFO")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.height * 0.4)
                    Spacer()
                    Image("image1")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.4, height: geometry.size.height * 0.06)
                    Spacer()
                    Text("Add your own images to create your own \ngame starter source")
                        .font(.custom("SinhalaMN-Bold", size: geometry.size.height * 0.02))
                        .multilineTextAlignment(.center)
                    Spacer()
                    NavigationLink(destination: SourceView(), isActive: $navigateToSource) {
                        EmptyView()
                    }
                    Button(action:{
                        navigateToSource = true
                    }){
                        Text("Import")
                            .font(.custom("SinhalaMN-Bold", size: geometry.size.height * 0.02))
                            .frame(width: geometry.size.width * 0.2, height: geometry.size.height * 0.03)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .fill(.color3)
                                .shadow(color: .black, radius: 0, x: 2, y: 5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    Spacer()
                }
            }
        }
    }
}
#Preview {
    StartView()
}
