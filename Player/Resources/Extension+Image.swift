import UIKit
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { [weak self] _ in
            self?.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
