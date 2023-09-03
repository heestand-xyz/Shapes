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
        
        let minLength = min(rect.width, rect.height)
        let arcLength = length.radians * (minLength / 2)
        print(cornerRadius, arcLength / 2)
        let cornerRadius = min(cornerRadius, (arcLength / 2) * 0.9)
        
        let outerRadius: CGFloat = minLength / 2
        
        let outerPaddingRadius: CGFloat = outerRadius - cornerRadius

        let leadingAngle: Angle = angle - length / 2
        let trailingAngle: Angle = angle + length / 2
        
        let outerPaddingAngle: Angle = Angle(radians: Double(cornerRadius / (outerRadius - cornerRadius)))
        
        let outerLeadingCenter = CGPoint(
            x: rect.center.x + cos(CGFloat(leadingAngle.radians + outerPaddingAngle.radians)) * outerPaddingRadius,
            y: rect.center.y + sin(CGFloat(leadingAngle.radians + outerPaddingAngle.radians)) * outerPaddingRadius)
        let outerTrailingCenter = CGPoint(
            x: rect.center.x + cos(CGFloat(trailingAngle.radians - outerPaddingAngle.radians)) * outerPaddingRadius,
            y: rect.center.y + sin(CGFloat(trailingAngle.radians - outerPaddingAngle.radians)) * outerPaddingRadius)
        
        let innerLeadingSidePoint = CGPoint(
            x: rect.center.x + cos(CGFloat(leadingAngle.radians)) * cornerRadius,
            y: rect.center.y + sin(CGFloat(leadingAngle.radians)) * cornerRadius)
        
        let innerTrailingSidePoint = CGPoint(
            x: rect.center.x + cos(CGFloat(trailingAngle.radians)) * cornerRadius,
            y: rect.center.y + sin(CGFloat(trailingAngle.radians)) * cornerRadius)
        
        let innerTrailingSideExtraPoint = CGPoint(
            x: rect.center.x + cos(CGFloat(trailingAngle.radians)) * (cornerRadius + 1),
            y: rect.center.y + sin(CGFloat(trailingAngle.radians)) * (cornerRadius + 1))
        
        let circle = self.circle(innerLeadingSidePoint, innerTrailingSidePoint, innerTrailingSideExtraPoint)

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
            
            if length != .degrees(180),
               let circle {
                let leadingAngle: Angle = .radians(atan2(innerLeadingSidePoint.y - circle.center.y,
                                                         innerLeadingSidePoint.x - circle.center.x))
                let trailingAngle: Angle = .radians(atan2(innerTrailingSidePoint.y - circle.center.y,
                                                          innerTrailingSidePoint.x - circle.center.x))
                path.addArc(center: circle.center,
                            radius: circle.radius,
                            startAngle: trailingAngle,
                            endAngle: leadingAngle,
                            clockwise: length.degrees > 180)
            } else {
                path.addLine(to: rect.center)
            }
            
            path.closeSubpath()
        }
    }
    
    /// GPT-4
    func circle(_ point1: CGPoint, _ point2: CGPoint, _ point3: CGPoint) -> (center: CGPoint, radius: CGFloat)? {
        
        // Calculate the determinants
        let D = 2 * (point1.x * (point2.y - point3.y) + point2.x * (point3.y - point1.y) + point3.x * (point1.y - point2.y))
        if D == 0 {
            return nil
        }
        
        // Calculate the center (h, k)
        let h = ((point1.x * point1.x + point1.y * point1.y) * (point2.y - point3.y) + (point2.x * point2.x + point2.y * point2.y) * (point3.y - point1.y) + (point3.x * point3.x + point3.y * point3.y) * (point1.y - point2.y)) / D
        let k = ((point1.x * point1.x + point1.y * point1.y) * (point3.x - point2.x) + (point2.x * point2.x + point2.y * point2.y) * (point1.x - point3.x) + (point3.x * point3.x + point3.y * point3.y) * (point2.x - point1.x)) / D
        
        let center = CGPoint(x: h, y: k)
        
        // Calculate the radius r
        let dx = center.x - point1.x
        let dy = center.y - point1.y
        let radius = sqrt(dx * dx + dy * dy)
        
        return (center: center, radius: radius)
    }
}

struct RoundedPie_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            ForEach([45, 90, 135, 180, 270, 360], id: \.self) { deg in
                ForEach([45, 90, 135, 180, 270, 360, 1000], id: \.self) { num in
                    RoundedPie(angle: .degrees(deg), length: .degrees(num), cornerRadius: 25)
                        .stroke()
                        .frame(width: 300, height: 300)
                        .aspectRatio(1.0, contentMode: .fit)
                        .padding()
                }
            }
        }
    }
}
