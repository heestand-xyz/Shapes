import SwiftUI

public struct Star: Shape {
    
    let count: Int
    
    var radii: ClosedRange<CGFloat>
    var cornerRadius: CGFloat
    
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, CGFloat> {
        get {
            AnimatablePair(AnimatablePair(radii.lowerBound, radii.upperBound), cornerRadius)
        }
        set {
            radii = newValue.first.first...newValue.first.second
            cornerRadius = newValue.second
        }
    }
    
    /// Star
    /// - Parameters:
    ///   - count: The point count of the star.
    ///   - radii: The lower bound is the inner radius and the upper bound is the outer radius.
    ///   - cornerRadius: This corner radius of the star. Default is `0.0`.
    public init(count: Int, radii: ClosedRange<CGFloat>, cornerRadius: CGFloat = 0.0) {
        self.count = max(count, 3)
        self.radii = radii
        self.cornerRadius = max(cornerRadius, 0.0)
    }
    
    public func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        let size: CGSize = rect.size
        
        if cornerRadius == 0.0 {
            
            for i in 0..<count {
                
                if i == 0 {
                    let startPoint: CGPoint = point(angle: angle(index: CGFloat(i) - 0.5),
                                                    radius: radii.lowerBound, size: size)
                    path.move(to: startPoint)
                }
                
                let outerPoint: CGPoint = point(angle: angle(index: CGFloat(i)),
                                                radius: radii.upperBound, size: size)
                path.addLine(to: outerPoint)
                
                let innerPoint: CGPoint = point(angle: angle(index: CGFloat(i) + 0.5),
                                                radius: radii.lowerBound, size: size)
                path.addLine(to: innerPoint)
                
            }
            
            path.closeSubpath()
            
        } else {
            
            let isSubConvex: Bool = {
                let fraction: CGFloat = 1.0 / CGFloat(count)
                let pointA = CGPoint(x: cos(0.0) * radii.upperBound,
                                   y: sin(0.0) * radii.upperBound)
                let pointB = CGPoint(x: cos(fraction * .pi * 2.0) * radii.upperBound,
                                   y: sin(fraction * .pi * 2.0) * radii.upperBound)
                let pointAB: CGPoint = CGPoint(x: (pointA.x + pointB.x) / 2,
                                               y: (pointA.y + pointB.y) / 2)
                let distanceAB: CGFloat = hypot(pointAB.x, pointAB.y)
                return radii.lowerBound > distanceAB
            }()
            
            for i in 0..<count {

                let prevInnerPoint: CGPoint = point(angle: angle(index: CGFloat(i) - 0.5), radius: radii.lowerBound, size: size)
                let currentOuterPoint: CGPoint = point(angle: angle(index: CGFloat(i)), radius: radii.upperBound, size: size)
                let nextInnerPoint: CGPoint = point(angle: angle(index: CGFloat(i) + 0.5), radius: radii.lowerBound, size: size)
                let nextOuterPoint: CGPoint = point(angle: angle(index: CGFloat(i) + 1.0), radius: radii.upperBound, size: size)

                let outerCornerCircle: RoundedCornerCircle = roundedCornerCircle(leading: prevInnerPoint,
                                                                                 center: currentOuterPoint,
                                                                                 trailing: nextInnerPoint,
                                                                                 cornerRadius: cornerRadius)
                
                let innerCornerCircle: RoundedCornerCircle = roundedCornerCircle(leading: currentOuterPoint,
                                                                                 center: nextInnerPoint,
                                                                                 trailing: nextOuterPoint,
                                                                                 cornerRadius: cornerRadius)
                let outerLeadingAngle: Angle = .radians(atan2(
                    outerCornerCircle.leading.y - outerCornerCircle.center.y,
                    outerCornerCircle.leading.x - outerCornerCircle.center.x))
                let outerTrailingAngle: Angle = .radians(atan2(
                    outerCornerCircle.trailing.y - outerCornerCircle.center.y,
                    outerCornerCircle.trailing.x - outerCornerCircle.center.x))

                let innerLeadingAngle: Angle = .radians(atan2(
                    innerCornerCircle.leading.y - innerCornerCircle.center.y,
                    innerCornerCircle.leading.x - innerCornerCircle.center.x))
                let innerTrailingAngle: Angle = .radians(atan2(
                    innerCornerCircle.trailing.y - innerCornerCircle.center.y,
                    innerCornerCircle.trailing.x - innerCornerCircle.center.x))

                path.addArc(center: outerCornerCircle.center,
                            radius: cornerRadius,
                            startAngle: outerLeadingAngle,
                            endAngle: outerTrailingAngle,
                            clockwise: false)

                path.addArc(center: innerCornerCircle.center,
                            radius: cornerRadius,
                            startAngle: innerLeadingAngle,
                            endAngle: innerTrailingAngle,
                            clockwise: !isSubConvex)
                
            }
            
            path.closeSubpath()
            
        }
        
        return path
    }
    
    func radius(size: CGSize) -> CGFloat {
        min(size.width, size.height) / 2.0
    }
    
    func angle(index: CGFloat) -> CGFloat {
        index / CGFloat(count) - 0.25
    }
    
    func point(angle: CGFloat, radius: CGFloat, size: CGSize) -> CGPoint {
        let x: CGFloat = size.width / 2.0 + cos(angle * .pi * 2.0) * radius
        let y: CGFloat = size.height / 2.0 + sin(angle * .pi * 2.0) * radius
        return CGPoint(x: x, y: y)
    }
    
    struct RoundedCornerCircle {
        let center: CGPoint
        let leading: CGPoint
        let trailing: CGPoint
    }
    
    func roundedCornerCircle(leading: CGPoint,
                             center: CGPoint,
                             trailing: CGPoint,
                             cornerRadius: CGFloat) -> RoundedCornerCircle {
        roundedCornerCircle(center, leading, trailing, cornerRadius)
    }
    
    private func roundedCornerCircle(_ p: CGPoint,
                                     _ p1: CGPoint,
                                     _ p2: CGPoint,
                                     _ r: CGFloat) -> RoundedCornerCircle {
        
        var r: CGFloat = r
        
        //Vector 1
        let dx1: CGFloat = p.x - p1.x
        let dy1: CGFloat = p.y - p1.y
        
        //Vector 2
        let dx2: CGFloat = p.x - p2.x
        let dy2: CGFloat = p.y - p2.y
        
        //Angle between vector 1 and vector 2 divided by 2
        let angle: CGFloat = (atan2(dy1, dx1) - atan2(dy2, dx2)) / 2
        
        // The length of segment between angular point and the
        // points of intersection with the circle of a given radius
        let _tan: CGFloat = abs(tan(angle))
        var segment: CGFloat = r / _tan
        
        //Check the segment
        let length1: CGFloat = sqrt(pow(dx1, 2) + pow(dy1, 2))
        let length2: CGFloat = sqrt(pow(dx2, 2) + pow(dy2, 2))
        
        let _length: CGFloat = min(length1, length2)
        
        if segment > _length {
            segment = _length
            r = _length * _tan
        }
        
        // Points of intersection are calculated by the proportion between
        // the coordinates of the vector, length of vector and the length of the segment.
        let p1Cross: CGPoint = proportion(p, segment, length1, dx1, dy1)
        let p2Cross: CGPoint = proportion(p, segment, length2, dx2, dy2)
        
        // Calculation of the coordinates of the circle
        // center by the addition of angular vectors.
        let dx: CGFloat = p.x * 2 - p1Cross.x - p2Cross.x
        let dy: CGFloat = p.y * 2 - p1Cross.y - p2Cross.y
        
        let L: CGFloat = sqrt(pow(dx, 2) + pow(dy, 2))
        let d: CGFloat = sqrt(pow(segment, 2) + pow(r, 2))
        
        let circlePoint: CGPoint = proportion(p, d, L, dx, dy)
        
        return RoundedCornerCircle(center: circlePoint, leading: p1Cross, trailing: p2Cross)
        
    }
    
    private func proportion(_ point: CGPoint,
                            _ segment: CGFloat,
                            _ length: CGFloat,
                            _ dx: CGFloat,
                            _ dy: CGFloat) -> CGPoint {
        let factor: CGFloat = segment / length
        return CGPoint(x: point.x - dx * factor,
                       y: point.y - dy * factor)
    }
}

struct Star_Previews: PreviewProvider {
    static var previews: some View {
        Star(count: 5, radii: 50...100, cornerRadius: 10)
        VStack {
            Star(count: 3, radii: 90...100, cornerRadius: 10)
            Star(count: 4, radii: 75...100, cornerRadius: 15)
            Star(count: 5, radii: 45...100, cornerRadius: 20)
        }
    }
}
