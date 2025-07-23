//
//  ColorGuessView.swift
//  GameColor
//
//  Created by Thanh Dao on 12/7/25.
//
import SwiftUI

struct ColorGuessView: View {
    let selectedImages: [UIImage]
    @State private var isSelected: UIImage?
    @State private var selectedIndex: Int = 0
    @State private var navigationToGame:Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack{
                LinearGradient(colors: [.white, .color2], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                VStack{
                    HStack{
                        Button(action:{
                            dismiss()
                        }){
                            Image(systemName: "chevron.left")
                                .font(.system(size: 25))
                                .foregroundStyle(.black)
                                .padding(.leading, geometry.size.width * 0.05)
                        }
                        Spacer()
                        Text("Color Guess")
                            .font(.custom("SinhalaMN-Bold", size: geometry.size.height * 0.03))
                            .foregroundStyle(.black)
                        Spacer()
                        Color.clear.frame(width: geometry.size.width * 0.06)
                            .padding(.trailing, geometry.size.width * 0.05)
                    }
                    .frame(height: geometry.size.height * 0.05)
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .font(.sinhalaMN(geometry.size.height * 0.022))
                            Text("Players choose the correct main color tone of the image.")
                                .font(.sinhalaMN(geometry.size.height * 0.022))
                        }
                        
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .font(.sinhalaMN(geometry.size.height * 0.022))
                            Text("Remember the colors of the images to get the most accurate results.")
                                .font(.sinhalaMN(geometry.size.height * 0.022))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .padding(.top, geometry.size.width * 0.1)
                    
                    let imageSize = geometry.size.width * 0.6
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(Array(selectedImages.enumerated()), id: \.1) { index, image in
                                GeometryReader { geo in
                                    let midX = geo.frame(in: .global).midX
                                    let screenMidX = geometry.size.width / 2
                                    let scale = max(0.8, 1.2 - abs(midX - screenMidX) / 300)
                                    
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: imageSize, height: imageSize)
                                        .scaleEffect(scale)
                                        .clipped()
                                        .animation(.easeOut(duration: 0.2), value: scale)
                                }
                                .frame(width: imageSize, height: imageSize)
                            }
                        }
                        .padding(.horizontal, geometry.size.width * 0.2)
                    }
                    .frame(height: geometry.size.height * 0.5)
                    Spacer()
                    VStack {
                        Spacer()
                        NavigationLink(destination: GameGuessView(image: selectedImages[selectedIndex], onNext: {
                            if selectedIndex + 1 < selectedImages.count {
                                selectedIndex += 1
                                navigationToGame = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    navigationToGame = true
                                }
                            } else {
                                navigationToGame = false
                            }
                        }), isActive: $navigationToGame){
                            EmptyView()
                        }
                        Button(action: {
                            
                            navigationToGame = true
                        }) {
                            Text("Next")
                                .font(.sinhalaMNBold(geometry.size.height * 0.03))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: geometry.size.height * 0.08)
                                .background(RoundedRectangle(cornerRadius: 0)
                                    .fill(.color3)
                                    .shadow(color: .black, radius: 0, x: 0, y: -5))
                        }
                    }
                    .ignoresSafeArea(.container, edges: .bottom)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    let sample = UIImage(named: "asdf") ?? UIImage()
    return ColorGuessView(selectedImages: [sample, sample, sample, sample, sample, sample])
}

