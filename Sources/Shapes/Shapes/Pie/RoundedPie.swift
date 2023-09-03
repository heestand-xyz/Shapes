import SwiftUI

public struct RoundedPie: Shape {
    
    var angle: Angle
    var length: Angle
    
    var cornerRadius: CGFloat
    
    public var animatableData: AnimatablePair<
        AnimatablePair<CGFloat, CGFloat>,
        CGFloat
    > {
        get {
            AnimatablePair(
                AnimatablePair(angle.radians, length.radians),
                cornerRadius
            )
        }
        set {
            angle = .radians(newValue.first.first)
            length = .radians(newValue.first.second)
            cornerRadius = newValue.second
        }
    }
    
    public init(
        angle: Angle,
        length: Angle,
        cornerRadius: CGFloat
    ) {
        self.angle = angle
        self.length = length
        self.cornerRadius = cornerRadius
    }
    
    public init(
        from leadingAngle: Angle,
        to trailingAngle: Angle,
        cornerRadius: CGFloat
    ) {
        self.angle = (leadingAngle + trailingAngle) / 2
        self.length = .radians(abs((trailingAngle - leadingAngle).radians))
        self.cornerRadius = cornerRadius
    }
    
    public func path(in rect: CGRect) -> Path {
        
        let outerRadius: CGFloat = min(rect.width, rect.height) / 2
        
        let outerPaddingRadius: CGFloat = outerRadius - cornerRadius

        let leadingAngle: Angle = angle - length / 2
        let trailingAngle: Angle = angle + length / 2
        
        let outerPaddingAngle: Angle = Angle(radians: Double(cornerRadius / (outerRadius - cornerRadius)))
        
        let innerCenter = CGPoint(
            x: rect.center.x + cos(CGFloat(angle.radians)) * cornerRadius,
            y: rect.center.y + sin(CGFloat(angle.radians)) * cornerRadius)
        let outerLeadingCenter = CGPoint(
            x: rect.center.x + cos(CGFloat(leadingAngle.radians + outerPaddingAngle.radians)) * outerPaddingRadius,
            y: rect.center.y + sin(CGFloat(leadingAngle.radians + outerPaddingAngle.radians)) * outerPaddingRadius)
        let outerTrailingCenter = CGPoint(
            x: rect.center.x + cos(CGFloat(trailingAngle.radians - outerPaddingAngle.radians)) * outerPaddingRadius,
            y: rect.center.y + sin(CGFloat(trailingAngle.radians - outerPaddingAngle.radians)) * outerPaddingRadius)
        
        return Path { path in
            
            path.addArc(center: outerLeadingCenter,
                        radius: cornerRadius,
                        startAngle: leadingAngle + Angle(degrees: 270),
                        endAngle: leadingAngle + outerPaddingAngle,
                        clockwise: false)
            
            path.addArc(center: rect.center,
                        radius: outerRadius,
                        startAngle: leadingAngle + outerPaddingAngle,
                        endAngle: trailingAngle - outerPaddingAngle,
                        clockwise: false)
            
            path.addArc(center: outerTrailingCenter,
                        radius: cornerRadius,
                        startAngle: trailingAngle - outerPaddingAngle,
                        endAngle: trailingAngle + Angle(degrees: 90),
                        clockwise: false)
            
            path.addArc(center: innerCenter,
                        radius: cornerRadius,
                        startAngle: leadingAngle + Angle(degrees: 180),
                        endAngle: trailingAngle + Angle(degrees: 180),
                        clockwise: false)
            
            path.closeSubpath()
        }
    }
}

struct RoundedPie_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RoundedPie(angle: .zero, length: .degrees(90), cornerRadius: 15)
                .padding()
            RoundedPie(angle: .zero, length: .degrees(90), cornerRadius: 15)
                .stroke(lineWidth: 10)
                .padding()
        }
    }
}
