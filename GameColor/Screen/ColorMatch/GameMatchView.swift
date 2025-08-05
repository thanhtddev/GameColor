//
//  GameMatchView.swift
//  GameColor
//
//  Created by Thanh Dao on 13/7/25.
//

import SwiftUI
import Photos
import UIKit
import ColorThiefSwift

struct ColorOption: Identifiable, Hashable {
    let id = UUID()
    let uiColor: UIColor

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ColorOption, rhs: ColorOption) -> Bool {
        lhs.id == rhs.id
    }
}

struct GameMatchView: View {
    let selectedImage: UIImage

    @State private var showHint = false
    @State private var correctColors: [UIColor] = []
    @State private var quantizedImage: UIImage?
    @State private var startTime = Date()
    @State private var elapsedSeconds = 0
    @State private var missingColors: [UIColor] = []
    @State private var visibleColors: [UIColor] = []
    @State private var imageFakeColors: [UIColor] = []
    @State private var displayFakeColors: [UIColor] = []
    @State private var displayedColorOptions: [ColorOption] = []
    @State private var correctColorsFoundCount: Int = 0
    @State private var navigateToSuccess: Bool = false
    @State private var finalElapsedTime: Int? = nil

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        GeometryReader { geometry in
            NavigationLink(
                destination: SuccessView(selectedImage: selectedImage, elapsedTime: finalElapsedTime ?? elapsedSeconds),
                isActive: $navigateToSuccess,
                label: { EmptyView() }
            )
            .hidden()

            ZStack {
                LinearGradient(colors: [.white, .color2], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    // Top bar
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 25))
                                .foregroundStyle(.black)
                                .padding(.leading, geometry.size.width * 0.05)
                        }
                        Spacer()
                        Text(timeFommat(elapsedSeconds))
                            .font(.custom("SinhalaMN-Bold", size: geometry.size.height * 0.03))
                            .foregroundStyle(.color6)
                        Spacer()
                        Button(action: { showHint.toggle() }) {
                            Image(systemName: "lightbulb.circle.fill")
                                .font(.system(size: 25))
                                .padding(.trailing, geometry.size.width * 0.05)
                                .foregroundColor(.black)
                        }
                    }
                    .frame(height: geometry.size.height * 0.05)

                    Spacer()

                    ZStack {
                        if showHint {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.8)
                                .cornerRadius(12)
                        } else if let quantizedImage {
                            Image(uiImage: quantizedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: geometry.size.width * 0.8)
                                .cornerRadius(12)
                        }
                    }

                    Spacer()

                    Text("Choose the correct color to create a drawing in the original color.")
                        .font(.sinhalaMN(geometry.size.height * 0.025))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    HStack(spacing: 20) {
                        ForEach(displayedColorOptions) { colorOption in
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(colorOption.uiColor))
                                .frame(width: geometry.size.height * 0.07, height: geometry.size.height * 0.07)
                                .onTapGesture {
                                    handleColorSelection(selectedColor: colorOption.uiColor)
                                }
                        }
                    }
                    Spacer()
                }
                .onAppear(perform: setupGame)
                .onReceive(timer) { _ in
                    elapsedSeconds = Int(Date().timeIntervalSince(startTime))
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func setupGame() {
        startTime = Date()

        correctColors = selectedImage.extractDominantColors(maxCount: 4)

        let shuffledCorrectColors = correctColors.shuffled()
        visibleColors = Array(shuffledCorrectColors.prefix(2))

        missingColors = Array(shuffledCorrectColors.suffix(2))

        imageFakeColors = []
        while imageFakeColors.count < 2 {
            let fake = UIColor.randomDistinct(from: correctColors)
            if !imageFakeColors.contains(where: { $0.isSimilar(to: fake) }) {
                imageFakeColors.append(fake)
            }
        }

        displayFakeColors = []
        let allUsedColors = correctColors + imageFakeColors
        while displayFakeColors.count < 2 {
            let fake = UIColor.randomDistinct(from: allUsedColors)
            if !displayFakeColors.contains(where: { $0.isSimilar(to: fake) }) {
                displayFakeColors.append(fake)
            }
        }

        let imagePalette = visibleColors + imageFakeColors
        quantizedImage = quantizeToFourColors(image: selectedImage, paletteColors: imagePalette)

        updateDisplayedColorOptions()
    }

    private func handleColorSelection(selectedColor: UIColor) {
        if let index = missingColors.firstIndex(where: { $0.isSimilar(to: selectedColor) }) {
            correctColorsFoundCount += 1

            let foundColor = missingColors.remove(at: index)

            visibleColors.append(foundColor)

//            let newImagePalette = visibleColors + imageFakeColors
//            quantizedImage = quantizeToFourColors(image: selectedImage, paletteColors: newImagePalette)

            updateDisplayedColorOptions()

            if correctColorsFoundCount == 2 {
                finalElapsedTime = elapsedSeconds
                navigateToSuccess = true
            }
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }

    private func updateDisplayedColorOptions() {
        displayedColorOptions = (missingColors + displayFakeColors)
            .shuffled()
            .map { ColorOption(uiColor: $0) }
    }

    func timeFommat(_ time: Int) -> String {
        let minute = time / 60
        let second = time % 60
        return String(format: "%02d:%02d", minute, second)
    }
}

