import SwiftUI

struct TimerView: View {
    
    @State var size = UIScreen.main.bounds.width - 100
    @State var progress : CGFloat = 0
    @State var angle : Double = 0
    
    var body: some View{
            VStack(spacing:80){
                Text("Timer")
                    .font(.system(size: 50))
                ZStack{
                    Circle()
                        .stroke(.gray,style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .frame(width: size, height: size)
                    // progress....
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.orange,style: StrokeStyle(lineWidth: 12, lineCap: .butt))
                        .frame(width: size, height: size)
                        .rotationEffect(.init(degrees: -90))
                    // Drag Circle...
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 35, height: 35)
                        .offset(x: size / 2)
                        .rotationEffect(.init(degrees: angle))
                    // adding gesture...
                        .gesture(DragGesture().onChanged(onDrag(value:)))
                        .rotationEffect(.init(degrees: -90))
                    Text(String(format: "%.0f", progress * 60) + " min")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                }
                Button {
                    
                } label: {
                    ZStack {
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.width / 1.7 ,height: 75)
                            .cornerRadius(75 / 2)
                            .tint(.yellow)
                        Text("start")
                            .foregroundColor(.black)
                            .font(.system(size: 25))
                    }
                }
            }
            .preferredColorScheme(.dark)
    }
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

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView()
    }
}

