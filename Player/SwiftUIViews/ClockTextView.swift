import SwiftUI

struct ClockText: View {
    
    var numbers: [String]
    var angle: CGFloat
    
    private struct IdentifiableNumbers: Identifiable {
        var id: Int
        var number: String
    }
    
    private var dataSource: [IdentifiableNumbers] {
        numbers.enumerated().map { IdentifiableNumbers(id: $0, number: $1) }
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                ForEach(dataSource) {
                    Text("\($0.number)")
                        .position(position(for: $0.id, in: geometry.frame(in: .local)))
                }
            }
        }
    }
    
    private func position(for index: Int, in rect: CGRect) -> CGPoint {
        
        let rect = rect.insetBy(dx: angle, dy: angle)
        let angle = ((2 * .pi) / CGFloat(numbers.count) * CGFloat(index)) - .pi / 2
        let radius = min(rect.width, rect.height) / 2
        
        return CGPoint(x: rect.midX + radius * cos(angle),
                       y: rect.midY + radius * sin(angle))
    }
}
