import SwiftUI
import ImageIO
import UIKit

/// Runtime native-size variants keep the exact adopted raster subject. Native labels/state/tier overlays remain editable SwiftUI.
struct RewardArtwork: View {
    var family: AwardFamily
    var size: CGFloat = 72
    var status = "Earned"
    private static let cache = NSCache<NSString, UIImage>()
    private var image: UIImage? {
        let pixels = Int(size * 3)
        let key = "\(family.id)/\(pixels)" as NSString
        if let cached = Self.cache.object(forKey: key) { return cached }
        guard let url = Bundle.main.url(forResource: family.filename, withExtension: nil, subdirectory: "masters"),
              let source = CGImageSourceCreateWithURL(url as CFURL, [kCGImageSourceShouldCache: false] as CFDictionary),
              let cg = CGImageSourceCreateThumbnailAtIndex(source, 0, [kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceThumbnailMaxPixelSize: pixels, kCGImageSourceShouldCacheImmediately: true] as CFDictionary) else { return nil }
        let image = UIImage(cgImage: cg)
        Self.cache.setObject(image, forKey: key, cost: cg.bytesPerRow * cg.height)
        Self.cache.totalCostLimit = 32 * 1024 * 1024
        return image
    }
    var body: some View {
        Group {
            if !family.collectible { Image(systemName: "book.closed").resizable().scaledToFit().padding(14) }
            else if let image { Image(uiImage: image).resizable().scaledToFit() }
            else { Image(systemName: family.collectible ? "seal" : "book.closed").resizable().scaledToFit() }
        }
        .saturation(status.hasPrefix("Earned") ? 1 : 0.25)
        .opacity(status.hasPrefix("Earned") ? 1 : 0.65)
        .frame(width: size, height: size)
        .padding(6).background(Kit.surface, in: RoundedRectangle(cornerRadius: 14))
        .accessibilityHidden(true) // Name/category/state are separate readable text.
    }
}
