import UIKit
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { [weak self] _ in
            self?.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
func changePicture(buttonSize: CGSize, button: UIButton) {
    let image = APManager.shared.isPlaying
    ? UIImage(systemName: "pause")?.withTintColor(.white).resized(to: buttonSize)
    : UIImage(systemName: "play")?.withTintColor(.white).resized(to: buttonSize)
    button.setImage(image, for: .normal)
}
