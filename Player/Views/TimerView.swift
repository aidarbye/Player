import SwiftUI
import Combine
struct TimerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: TimerViewModel
    
    var startTimer = PassthroughSubject<Void,Never>()
    var stopTimer = PassthroughSubject<Void,Never>()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 80) {
                ZStack {
                    ClockText(
                        numbers: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map {"\($0 * 5)"},
                        angle: 30
                    )
                        .font(.system(size: 20))
                        .frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.width , alignment: .center)
                    Circle()
                        .stroke(.gray, style: StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round))
                        .frame(width: vm.size, height: vm.size)
                    
                    // Progress
                    Circle()
                        .trim(from: 0, to: vm.progress)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .butt))
                        .frame(width: vm.size, height: vm.size)
                        .rotationEffect(.init(degrees: -90))
                    
                    // Drag Circle
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 20, height: 20)
                        .offset(x: vm.size / 2)
                        .rotationEffect(.init(degrees: vm.angle))
                        .gesture(DragGesture().onChanged(vm.onDrag(value:)))
                        .rotationEffect(.init(degrees: -90))
                    // Timer text
                    Text(String(format: "%.0f", vm.progress * 60) + " min")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                }
                .disabled(vm.disabled)
                Button {
                    if vm.disabled {
                        stopTimer.send()
                    } else {
                        startTimer.send()
                    }
                    vm.disabled.toggle() 
                    dismiss()
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width / 1.7, height: 75)
                            .cornerRadius(75 / 2)
                            .tint(.yellow)
                        Text(vm.buttonLabel)
                            .foregroundColor(.black)
                            .font(.system(size: 25))
                    }
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                vm.angle = vm.progress * 360
                vm.buttonLabel = vm.disabled ? "Stop" : "Start"
            }
            .navigationTitle("Timer")
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(vm: TimerViewModel())
    }
}

