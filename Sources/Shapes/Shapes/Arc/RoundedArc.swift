import SwiftUI

public struct RoundedArc: Shape {
    
    var angle: Angle
    var length: Angle
    
    var width: CGFloat
    var cornerRadius: CGFloat
   
    public var animatableData: AnimatablePair<
        AnimatablePair<CGFloat, CGFloat>,
            AnimatablePair<CGFloat, CGFloat>
    > {
        get {
            AnimatablePair(
                AnimatablePair(angle.radians, length.radians),
                AnimatablePair(width, cornerRadius)
            )
        }
        set {
            angle = .radians(newValue.first.first)
            length = .radians(newValue.first.second)
            width = newValue.second.first
            cornerRadius = newValue.second.second
        }
    }
    
    public init(
        angle: Angle,
        length: Angle,
        width: CGFloat,
        cornerRadius: CGFloat
    ) {
        self.angle = angle
        self.length = .radians(max(0.0, length.radians))
        self.width = width
        self.cornerRadius = cornerRadius
    }
    
    public init(
        from leadingAngle: Angle,
        to trailingAngle: Angle,
        width: CGFloat,
        cornerRadius: CGFloat
    ) {
        self.angle = (leadingAngle + trailingAngle) / 2
        self.length = .radians(abs((trailingAngle - leadingAngle).radians))
        self.width = width
        self.cornerRadius = cornerRadius
    }
    
    public func path(in rect: CGRect) -> Path {
        
        let outerRadius: CGFloat = min(rect.width, rect.height) / 2
        let innerRadius: CGFloat = outerRadius - width
        
        let outerPaddingRadius: CGFloat = outerRadius - cornerRadius
        let innerPaddingRadius: CGFloat = innerRadius + cornerRadius

        let leadingAngle: Angle = angle - length / 2
        let trailingAngle: Angle = angle + length / 2
        
        let outerPaddingAngle: Angle = Angle(radians: Double(cornerRadius / (outerRadius - cornerRadius)))
        let innerPaddingAngle: Angle = Angle(radians: Double(cornerRadius / (innerRadius + cornerRadius)))
        
        let outerLeadingCenter = CGPoint(
            x: rect.center.x + cos(CGFloat(leadingAngle.radians + outerPaddingAngle.radians)) * outerPaddingRadius,
            y: rect.center.y + sin(CGFloat(leadingAngle.radians + outerPaddingAngle.radians)) * outerPaddingRadius)
        let outerTrailingCenter = CGPoint(
            x: rect.center.x + cos(CGFloat(trailingAngle.radians - outerPaddingAngle.radians)) * outerPaddingRadius,
            y: rect.center.y + sin(CGFloat(trailingAngle.radians - outerPaddingAngle.radians)) * outerPaddingRadius)
        let innerLeadingCenter = CGPoint(
            x: rect.center.x + cos(CGFloat(leadingAngle.radians + innerPaddingAngle.radians)) * innerPaddingRadius,
            y: rect.center.y + sin(CGFloat(leadingAngle.radians + innerPaddingAngle.radians)) * innerPaddingRadius)
        let innerTrailingCenter = CGPoint(
            x: rect.center.x + cos(CGFloat(trailingAngle.radians - innerPaddingAngle.radians)) * innerPaddingRadius,
            y: rect.center.y + sin(CGFloat(trailingAngle.radians - innerPaddingAngle.radians)) * innerPaddingRadius)
        
        return Path { path in
            
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
            path.addArc(center: innerTrailingCenter,
                        radius: cornerRadius,
                        startAngle: trailingAngle + Angle(degrees: 90),
                        endAngle: trailingAngle - innerPaddingAngle + Angle(degrees: 180),
                        clockwise: false)
            
            path.addArc(center: rect.center,
                        radius: innerRadius,
                        startAngle: trailingAngle - innerPaddingAngle,
                        endAngle: leadingAngle + innerPaddingAngle,
                        clockwise: true)
            
            path.addArc(center: innerLeadingCenter,
                        radius: cornerRadius,
                        startAngle: leadingAngle + innerPaddingAngle + Angle(degrees: 180),
                        endAngle: leadingAngle + Angle(degrees: 270),
                        clockwise: false)
            path.addArc(center: outerLeadingCenter,
                        radius: cornerRadius,
                        startAngle: leadingAngle + Angle(degrees: 270),
                        endAngle: leadingAngle + outerPaddingAngle,
                        clockwise: false)
            
        }
    }
}

struct RoundedArc_Previews: PreviewProvider {
    static var previews: some View {
        RoundedArc(angle: .zero, length: .degrees(90), width: 50, cornerRadius: 5)
            .padding()
    }
}
