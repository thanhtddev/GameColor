//
//  UIFont+Ex.swift
//  GameColor
//
//  Created by Thanh Dao on 8/7/25.
//

import SwiftUI
import CoreImage
import ColorThiefSwift

extension Font {
    static func sinhalaMNBold(_ size: CGFloat)->Font {
        .custom("SinhalaMN-Bold", size: size)
    }
    static func sinhalaMN(_ size: CGFloat)->Font {
        .custom( "SinhalaMN", size: size)
    }
}

extension UIImage {
    
    // Làm ảnh đen trắng
    func grayScale()->UIImage? {
        let context = CIContext()
        guard let ciImage = CIImage(image: self) else { return nil }
        guard let filter = CIFilter(name: "CIPhotoEffectMono") else { return nil }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let output = filter.outputImage else { return nil }
        guard let cgImage = context.createCGImage(output, from: ciImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    // Lấy ra màu chủ đạo
    func extractDominantColors(maxCount: Int = 4) -> [UIColor] {
        guard let colorPalette = ColorThief.getPalette(from: self, colorCount: maxCount) else {
            return []
        }
        return colorPalette.map { $0.makeUIColor() }
    }
    // Tránh lật ảnh
    func fixedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage ?? self
    }
}

extension UIColor {
    func isSimilar(to color: UIColor, tolerance: CGFloat = 0.2) -> Bool {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return abs(r1 - r2) < tolerance &&
        abs(g1 - g2) < tolerance &&
        abs(b1 - b2) < tolerance
    }
    static func randomColor() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0.2...0.9),
            green: CGFloat.random(in: 0.2...0.9),
            blue: CGFloat.random(in: 0.2...0.9),
            alpha: 1.0
        )
    }
    var rgba: (UInt8, UInt8, UInt8, UInt8) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return (UInt8(r * 255), UInt8(g * 255), UInt8(b * 255), UInt8(a * 255))
    }
    func toHexString() -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02lX%02lX%02lX",
                      lroundf(Float(r * 255)),
                      lroundf(Float(g * 255)),
                      lroundf(Float(b * 255)))
    }
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb >> 16) & 0xFF) / 255
        let g = CGFloat((rgb >> 8) & 0xFF) / 255
        let b = CGFloat(rgb & 0xFF) / 255
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    static func random() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0.1...0.9),
            green: CGFloat.random(in: 0.1...0.9),
            blue: CGFloat.random(in: 0.1...0.9),
            alpha: 1.0
        )
    }
    static func randomDistinct(from colors: [UIColor]) -> UIColor {
        var newColor: UIColor
        repeat {
            newColor = UIColor(
                red: .random(in: 0...1),
                green: .random(in: 0...1),
                blue: .random(in: 0...1),
                alpha: 1
            )
        } while colors.contains(where: { $0.isSimilar(to: newColor) })
        return newColor
    }
}
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

func quantizeToFourColors(image: UIImage, paletteColors: [UIColor]) -> UIImage? {
    guard let inputCGImage = image.cgImage else { return nil }
    
    let width = inputCGImage.width
    let height = inputCGImage.height
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    var pixelData = [UInt8](repeating: 0, count: height * width * 4)
    
    guard let context = CGContext(data: &pixelData,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: bitsPerComponent,
                                  bytesPerRow: bytesPerRow,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    else { return nil }
    
    context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    let quantizationPalette = paletteColors // Sử dụng paletteColors được truyền vào
    
    for y in 0..<height {
        for x in 0..<width {
            let offset = (y * width + x) * 4
            let r = pixelData[offset]
            let g = pixelData[offset + 1]
            let b = pixelData[offset + 2]
            
            // Tìm màu gần nhất trong bảng màu lượng tử hóa
            let closest = quantizationPalette.min(by: {
                colorDistance(from: $0, to: r, g, b) < colorDistance(from: $1, to: r, g, b)
            })!
            
            let (rr, gg, bb, _) = closest.rgba
            pixelData[offset] = rr
            pixelData[offset + 1] = gg
            pixelData[offset + 2] = bb
        }
    }
    
    guard let outputContext = CGContext(data: &pixelData,
                                        width: width,
                                        height: height,
                                        bitsPerComponent: bitsPerComponent,
                                        bytesPerRow: bytesPerRow,
                                        space: colorSpace,
                                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
          let outputCGImage = outputContext.makeImage() else { return nil }
    
    return UIImage(cgImage: outputCGImage)
}



func colorDistance(from color: UIColor, to r: UInt8, _ g: UInt8, _ b: UInt8) -> CGFloat {
    var cr: CGFloat = 0, cg: CGFloat = 0, cb: CGFloat = 0, ca: CGFloat = 0
    color.getRed(&cr, green: &cg, blue: &cb, alpha: &ca)
    return pow(CGFloat(r)/255 - cr, 2) +
    pow(CGFloat(g)/255 - cg, 2) +
    pow(CGFloat(b)/255 - cb, 2)
}
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
func generateFakeColors(from colors: [UIColor], excluding: [UIColor]) -> [UIColor] {
    var generated: [UIColor] = []
    while generated.count < 2 {
        let color = UIColor.random()
        if !excluding.contains(where: { $0.isSimilar(to: color) }) {
            generated.append(color)
        }
    }
    return generated
}

