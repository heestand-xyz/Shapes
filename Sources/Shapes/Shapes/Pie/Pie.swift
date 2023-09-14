import SwiftUI

public struct Pie: Shape {
    
    var angle: Angle
    var length: Angle
    
    let asLine: Bool
   
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get {
            AnimatablePair(angle.radians, length.radians)
        }
        set {
            angle = .radians(newValue.first)
            length = .radians(newValue.second)
        }
    }
    
    public init(
        angle: Angle,
        length: Angle,
        asLine: Bool = false
    ) {
        self.angle = angle
        self.length = .radians(max(0.0, length.radians))
        self.asLine = asLine
    }
    
    public init(
        from leadingAngle: Angle,
        to trailingAngle: Angle,
        asLine: Bool = false
    ) {
        self.angle = (leadingAngle + trailingAngle) / 2
        self.length = .radians(abs((trailingAngle - leadingAngle).radians))
        self.asLine = asLine
    }
    
    public func path(in rect: CGRect) -> Path {
        
        let outerRadius: CGFloat = min(rect.width, rect.height) / 2
        
        let leadingAngle: Angle = angle - length / 2
        let trailingAngle: Angle = angle + length / 2
        
        return Path { path in
            
            if !asLine {
                path.move(to: rect.center)
            }
            
            path.addArc(center: rect.center,
                        radius: outerRadius,
                        startAngle: leadingAngle,
                        endAngle: trailingAngle,
                        clockwise: false)
            
            if !asLine {
                path.closeSubpath()
            }
        }
    }
}

struct Pie_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Pie(angle: .zero, length: .degrees(90))
                .padding()
            Pie(angle: .zero, length: .degrees(90), asLine: true)
                .stroke(lineWidth: 10)
                .padding()
        }
    }
}
