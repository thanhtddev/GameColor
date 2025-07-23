//
//  SourceView.swift
//  GameColor
//
//  Created by Thanh Dao on 9/7/25.
//

import SwiftUI
import PhotosUI

struct SourceView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var isShowingPicker = false
    @State private var navigationToHome = false
    @State private var showAlert = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(colors: [.white, .color2], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    Text("Source game")
                        .font(.custom("SinhalaMN-Bold", size: geometry.size.height * 0.03))
                        .padding()
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            Button(action: {
                                isShowingPicker = true
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 0)
                                        .fill(LinearGradient(colors: [.color4, .color2], startPoint: .top, endPoint: .bottom))
                                        .frame(width: geometry.size.height * 0.125, height: geometry.size.height * 0.125)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 0)
                                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                                .foregroundStyle(.black)
                                        )
                                    Image(systemName: "arrow.up.circle")
                                        .font(.system(size: 25))
                                        .foregroundStyle(.black)
                                }
                            }
                            ForEach(selectedImages, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.height * 0.125, height: geometry.size.height * 0.125)
                                    .clipped()
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    
                    Spacer()
                }
                VStack {
                    Spacer()
                    NavigationLink(destination: HomeView(selectedImages: selectedImages), isActive: $navigationToHome){
                        EmptyView()
                    }
                    Button(action: {
                        if selectedImages.isEmpty {
                            showAlert = true
                            
                        }else{
                            navigationToHome = true
                        }
                    }) {
                        Text("Start game")
                            .font(.custom("SinhalaMN-Bold", size: geometry.size.height * 0.03))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.height * 0.08)
                            .background(RoundedRectangle(cornerRadius: 0)
                                .fill(.color3)
                                .shadow(color: .black, radius: 0, x: 0, y: -5))
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Thông báo"), message: Text("Bạn phải chọn ít nhất 1 ảnh trước khi bắt đầu."), dismissButton: .default(Text("OK")))
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
            .sheet(isPresented: $isShowingPicker) {
                PhotoPicker(selectedImages: $selectedImages)
            }
        }
        .navigationBarHidden(true)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 10
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SourceView()
}
