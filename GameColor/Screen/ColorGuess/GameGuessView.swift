//
//  GameGuessView.swift
//  GameColor
//
//  Created by Thanh Dao on 12/7/25.
//

import SwiftUI
import ColorThiefSwift

struct GameGuessView: View {
    @AppStorage("userScore") var score: Int = 0
    let image: UIImage
    let onNext: () -> Void
    
    @State private var dominantColor: UIColor = .white
    @State private var options: [UIColor] = []
    @State private var selectedIndex: Int? = nil
    @State private var hasAnswered = false
    @State private var isCorrect = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(colors: [.white, .color2], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 25))
                                .foregroundStyle(.black)
                                .padding(.leading, geometry.size.width * 0.01)
                        }
                        Spacer()
                        Text("Color Guess")
                            .font(.custom("SinhalaMN-Bold", size: geometry.size.height * 0.03))
                            .foregroundStyle(.black)
                        Spacer()
                        Color.clear
                            .frame(width: geometry.size.width * 0.06)
                            .padding(.trailing, geometry.size.width * 0.05)
                    }
                    .frame(height: geometry.size.height * 0.05)
                    
                    Text("Score: \(score)")
                        .font(.sinhalaMNBold(geometry.size.height * 0.025))
                        .foregroundStyle(.color6)
                        .padding()
                    Spacer()
                    Image(uiImage: image.grayScale() ?? image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.9)
                    
                    Spacer()
                    Text("Choose the main color of the picture")
                        .font(.sinhalaMN(geometry.size.height * 0.025))
                    
                    HStack(spacing: 24) {
                        ForEach(0..<4, id: \.self) { index in
                            VStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(options[safe: index] ?? .gray))
                                    .frame(width: geometry.size.height * 0.07, height: geometry.size.height * 0.07)
                                Text(String(UnicodeScalar(65 + index)!))
                                    .font(.sinhalaMNBold(geometry.size.height * 0.02))
                                    .foregroundColor(.black)
                                    .padding(6)
                                    .background(
                                        Circle()
                                            .stroke(selectedIndex == index ? Color.black : .clear, lineWidth: 2)
                                    )
                            }
                            .onTapGesture {
                                guard !hasAnswered else { return }
                                selectedIndex = index
                                hasAnswered = true
                                
                                isCorrect = options[safe: index] == dominantColor
                                if isCorrect {
                                    score += 1
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    onNext()
                                }
                            }
                        }
                    }
                    Spacer()
                    
                }
                .padding()
                .onAppear {
                    generateRandomColors()
                }
                VStack {
                    Spacer()
                    if hasAnswered {
                            HStack {
                                Image(systemName: isCorrect ? "checkmark" : "xmark")
                                Text(isCorrect ? "Correct" : "Wrong")
                                    .font(.sinhalaMNBold(geometry.size.height * 0.025))
                                    
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.height * 0.08)
                            .background(isCorrect ? Color.color6 : Color.color3)
                            .foregroundColor(.white)
                        }
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .navigationBarHidden(true)
    }
    
    func generateRandomColors() {
        guard let domColor = ColorThief.getColor(from: image)?.makeUIColor() else { return }
        dominantColor = domColor
        var result: [UIColor] = [domColor]
        
        while result.count < 4 {
            let color = UIColor(
                red: CGFloat.random(in: 0.2...0.8),
                green: CGFloat.random(in: 0.2...0.8),
                blue: CGFloat.random(in: 0.2...0.8),
                alpha: 1.0
            )
            if !result.contains(where: { $0.isSimilar(to: color) }) {
                result.append(color)
            }
        }
        options = result.shuffled()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var score = 0
        let sample = UIImage(named: "asdf") ?? UIImage(systemName: "photo")!
        
        var body: some View {
            GameGuessView(image: sample, onNext: { print("Next!") })
                .environment(\.colorScheme, .light)
        }
    }
    
    return PreviewWrapper()
}
