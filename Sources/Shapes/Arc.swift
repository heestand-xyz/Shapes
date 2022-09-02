import SwiftUI

public struct Arc: Shape {
    
    var angle: Angle
    var length: Angle
    
    var width: CGFloat
   
    public var animatableData: AnimatablePair<
        AnimatablePair<CGFloat, CGFloat>,
        CGFloat
    > {
        get {
            AnimatablePair(
                AnimatablePair(angle.radians, length.radians),
                width
            )
        }
        set {
            angle = .radians(newValue.first.first)
            length = .radians(newValue.first.second)
            width = newValue.second
        }
    }
    
    public init(
        angle: Angle,
        length: Angle,
        width: CGFloat
    ) {
        self.angle = angle
        self.length = length
        self.width = width
    }
    
    public init(
        from leadingAngle: Angle,
        to trailingAngle: Angle,
        width: CGFloat
    ) {
        self.angle = (leadingAngle + trailingAngle) / 2
        self.length = .radians(abs((trailingAngle - leadingAngle).radians))
        self.width = width
    }
    
    public func path(in rect: CGRect) -> Path {
        
        let outerRadius: CGFloat = min(rect.width, rect.height) / 2
        let innerRadius: CGFloat = outerRadius - width
        
        let leadingAngle: Angle = angle - length / 2
        let trailingAngle: Angle = angle + length / 2
        
        return Path { path in
            
            path.addArc(center: rect.center,
                        radius: outerRadius,
                        startAngle: leadingAngle,
                        endAngle: trailingAngle,
                        clockwise: false)
            
            path.addArc(center: rect.center,
                        radius: innerRadius,
                        startAngle: trailingAngle,
                        endAngle: leadingAngle,
                        clockwise: true)
        }
    }
}
