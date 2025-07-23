//
//  SuccessView.swift
//  GameColor
//
//  Created by Thanh Dao on 18/7/25.
//

import SwiftUI
import Photos 
import UIKit

struct SuccessView: View {
    let selectedImage: UIImage
    let elapsedTime: Int
    
    @State private var completedImage: UIImage?
    @State private var showSaveSuccessAlert = false
    @State private var showSaveFailedAlert = false
    @State private var saveErrorMessage: String = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(colors: [.white, .color2], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack {
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 25))
                                .foregroundStyle(.black)
                                .padding(.leading, geometry.size.width * 0.05)
                        }
                        Spacer()
                    }
                    .frame(height: geometry.size.height * 0.05)
                    .padding(.bottom, 20)
                    Spacer()
                    if let completedImage = completedImage {
                        Image(uiImage: completedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.8)
                            .cornerRadius(12)
                            .padding(.bottom, 30)
                    } else {
                        ProgressView()
                            .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8 * (selectedImage.size.height / selectedImage.size.width))
                            .padding(.bottom, 30)
                    }

                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName:"checkmark")
                            Text("Completed")
                                .font(.sinhalaMNBold(geometry.size.height * 0.025))
                                
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: geometry.size.height * 0.08)
                        .foregroundColor(.color6)
                        Text("You completed the picture in \(timeFommat(elapsedTime))")
                            .font(.sinhalaMNBold(geometry.size.height * 0.025))
                            .foregroundColor(.black)
                    }
                    .padding(.bottom, 30)

                    Button(action:{
                        saveCompletedImage()
                    }){
                        Text("Save to photos")
                            .font(.custom("SinhalaMN-Bold", size: geometry.size.height * 0.02))
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.01)
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
                    .alert("Save Image", isPresented: $showSaveSuccessAlert) {
                        Button("OK") { }
                    } message: {
                        Text("The photo has been saved")
                    }
                    .alert("Save Error", isPresented: $showSaveFailedAlert) {
                        Button("OK") { }
                    } message: {
                        Text(saveErrorMessage)
                    }

                    Spacer()
                }
                .onAppear {
                    let dominantColors = selectedImage.extractDominantColors(maxCount: 4)
                    completedImage = quantizeToFourColors(image: selectedImage, paletteColors: dominantColors)
                }
            }
        }
        .navigationBarHidden(true)
    }

    func timeFommat(_ time: Int) -> String {
        let minute = time / 60
        let second = time % 60
        return String(format: "%02d:%02d", minute, second)
    }

    private func saveCompletedImage() {
        guard let imageToSave = completedImage else {
            saveErrorMessage = "Không có ảnh để lưu."
            showSaveFailedAlert = true
            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
                DispatchQueue.main.async {
                    self.showSaveSuccessAlert = true
                }
            case .denied, .restricted:
                DispatchQueue.main.async {
                    self.saveErrorMessage = "Quyền truy cập vào Thư viện ảnh bị từ chối. Vui lòng cấp quyền trong Cài đặt."
                    self.showSaveFailedAlert = true
                }
            case .notDetermined: break
            case .limited:
                DispatchQueue.main.async {
                    self.saveErrorMessage = "Quyền truy cập vào Thư viện ảnh bị giới hạn. Vui lòng cấp quyền đầy đủ trong Cài đặt."
                    self.showSaveFailedAlert = true
                }
            @unknown default:
                DispatchQueue.main.async {
                    self.saveErrorMessage = "Đã xảy ra lỗi không xác định khi yêu cầu quyền truy cập Thư viện ảnh."
                    self.showSaveFailedAlert = true
                }
            }
        }
    }
}

