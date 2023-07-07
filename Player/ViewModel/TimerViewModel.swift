import SwiftUI

final class TimerViewModel: ObservableObject {
    
//    var onButtonTapped: (() -> Void)?
//    var startTimer: (()->Void)?
//    var stopTimer: (()->Void)?
    
    @Published var size = UIScreen.main.bounds.width - 130
    @Published var progress : CGFloat = 0
    @Published var angle : Double = 0
    @Published var buttonLabel: String = "start"
    @Published var disabled: Bool = false
    
    func onDrag(value: DragGesture.Value){
        let vector = CGVector(dx: value.location.x, dy: value.location.y)
        let radians = atan2(vector.dy - 27.5, vector.dx - 27.5)
        var angle = radians * 180 / .pi
        if angle < 0{ angle = 360 + angle }
        let progress = angle / 360
        self.progress = progress
        self.angle = Double(angle)
    }
}
