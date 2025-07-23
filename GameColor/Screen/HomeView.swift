//
//  HomeView.swift
//  GameColor
//
//  Created by Thanh Dao on 8/7/25.
//

import SwiftUI

struct HomeView: View {
    @State private var navigationToColorGuess = false
    @State private var navigationToColorMatch = false
    let selectedImages: [UIImage]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                LinearGradient(
                    colors: [.color5, .color2],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading)
                .ignoresSafeArea(.all)
                VStack(spacing: 20){
                    Spacer()
                    Image("image2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.6)
                    Spacer()
                    HStack {
                        NavigationLink(destination: ColorMatchView(selectedImages: selectedImages), isActive: $navigationToColorMatch){
                            EmptyView()
                        }
                        Button(action: {
                            navigationToColorMatch = true
                        }){
                            Text("Shadow to Color Match")
                                .font(.custom("SinhalaMN-Bold", size: geometry.size.height * 0.025))
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Image(systemName: "gamecontroller.fill")
                            .padding(.trailing)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 25)
                    .frame(width: geometry.size.width * 0.85)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                    HStack {
                        NavigationLink(destination: ColorGuessView(selectedImages: selectedImages), isActive: $navigationToColorGuess){
                            EmptyView()
                        }
                        Button(action: {
                            navigationToColorGuess = true
                        }){
                            Text("Color Guess")
                                .font(.custom("SinhalaMN-Bold", size: geometry.size.height * 0.025))
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Image(systemName: "gamecontroller.fill")
                            .padding(.trailing)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 25)
                    .frame(width: geometry.size.width * 0.85)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
                    Spacer()
                    HStack{
                        Button(action:{
                            
                        }){
                            Image(systemName: "gearshape")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                        Spacer()
                        Button(action:{
                            dismiss()
                        }){
                            Text("Source")
                                .font(.custom("SinhalaMN-Bold", size: geometry.size.height * 0.02))
                                .frame(width: geometry.size.width * 0.15, height: geometry.size.height * 0.01)
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
                        Button(action:{
                            
                        }){
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 24))
                                .foregroundColor(.black)
                        }
                    }
                    .frame(width: geometry.size.width * 0.9)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
#Preview {
    HomeView(selectedImages: [])
}
