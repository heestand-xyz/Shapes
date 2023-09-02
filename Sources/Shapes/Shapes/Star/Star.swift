import SwiftUI

public struct Star: Shape {
    
    let count: Int
    
    enum CornerRadius {
        case relative(CGFloat)
        case constant(CGFloat)
        func relativeRadius(maxRadius: CGFloat) -> CGFloat {
            switch self {
            case .relative(let relativeRadius):
                return relativeRadius
            case .constant(let radius):
                return radius / maxRadius
            }
        }
        var animatablePair: AnimatablePair<CGFloat, CGFloat> {
            get {
                switch self {
                case .relative(let relativeRadius):
                    return AnimatablePair(0.0, relativeRadius)
                case .constant(let radius):
                    return AnimatablePair(1.0, radius)
                }
            }
            set {
                if newValue.first == 0.0 {
                    self = .relative(newValue.second)
                } else {
                    self = .constant(newValue.second)
                }
            }
        }
    }
    
    var radii: ClosedRange<CGFloat>
    var cornerRadius: CornerRadius
    
    public var animatableData: AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>> {
        get {
            AnimatablePair(AnimatablePair(radii.lowerBound, radii.upperBound), cornerRadius.animatablePair)
        }
        set {
            radii = newValue.first.first...newValue.first.second
            cornerRadius.animatablePair = newValue.second
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
        self.cornerRadius = .constant(max(cornerRadius, 0.0))
    }
    
    /// Star
    /// - Parameters:
    ///   - count: The point count of the star.
    ///   - radii: The lower bound is the inner radius and the upper bound is the outer radius.
    ///   - relativeCornerRadius: This value is between `0.0` and `1.0`, where `0.0` is a pure star.
    public init(count: Int, radii: ClosedRange<CGFloat>, relativeCornerRadius: CGFloat) {
        self.count = max(count, 3)
        self.radii = radii
        self.cornerRadius = .relative(min(max(relativeCornerRadius, 0.0), 1.0))
    }
    
    public func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        let size: CGSize = rect.size
        
        let maxCornerRadius = maxCornerRadius(size: size)
        let relativeCornerRadius = min(max(cornerRadius.relativeRadius(maxRadius: maxCornerRadius), 0.0), 1.0)
        
        if relativeCornerRadius == 0.0 {
            
            for i in 0..<count {
                
                if i == 0 {
                    let currentPoint: CGPoint = point(angle: angle(index: CGFloat(i)), radius: radii.lowerBound, size: size)
                    path.move(to: currentPoint)
                }
                
                let nextOuterPoint: CGPoint = point(angle: angle(index: CGFloat(i) + 1.0), radius: radii.upperBound, size: size)
                path.addLine(to: nextOuterPoint)
                
                let nextInnerPoint: CGPoint = point(angle: angle(index: CGFloat(i) + 1.5), radius: radii.lowerBound, size: size)
                path.addLine(to: nextInnerPoint)
                
            }
            
            path.closeSubpath()
            
        } else {
            
            let cornerRadius: CGFloat = relativeCornerRadius * maxCornerRadius
            
            let isConcave: Bool = true
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

                let outerCornerCircle: RoundedCornerCircle = roundedCornerCircle(leading: prevInnerPoint,
                                                                                 center: currentOuterPoint,
                                                                                 trailing: nextInnerPoint,
                                                                                 cornerRadius: cornerRadius)

                let outerStartAngle = angle(index: CGFloat(i) - 0.5)
                let outerStartAngleInRadians: Angle = .radians(Double(outerStartAngle) * .pi * 2.0)
                let outerEndAngle = angle(index: CGFloat(i) + 0.5)
                let outerEndAngleInRadians: Angle = .radians(Double(outerEndAngle) * .pi * 2.0)

                path.addArc(center: outerCornerCircle.center,
                            radius: cornerRadius,
                            startAngle: outerStartAngleInRadians,
                            endAngle: outerEndAngleInRadians,
                            clockwise: false)

                let prevOuterPoint: CGPoint = point(angle: angle(index: CGFloat(i)), radius: radii.upperBound, size: size)
                let currentInnerPoint: CGPoint = point(angle: angle(index: CGFloat(i) + 0.5), radius: radii.lowerBound, size: size)
                let nextOuterPoint: CGPoint = point(angle: angle(index: CGFloat(i) + 1.0), radius: radii.upperBound, size: size)

                let innerCornerCircle: RoundedCornerCircle = roundedCornerCircle(leading: prevOuterPoint,
                                                                                 center: currentInnerPoint,
                                                                                 trailing: nextOuterPoint,
                                                                                 cornerRadius: cornerRadius)

                let innerStartAngle = angle(index: CGFloat(i) + 1.0) + 0.5
                let innerStartAngleInRadians: Angle = .radians(Double(innerStartAngle) * .pi * 2.0)
                let innerEndAngle = angle(index: CGFloat(i) + 0.0) + 0.5
                let innerEndAngleInRadians: Angle = .radians(Double(innerEndAngle) * .pi * 2.0)

                path.addArc(center: innerCornerCircle.center,
                            radius: cornerRadius,
                            startAngle: innerStartAngleInRadians,
                            endAngle: innerEndAngleInRadians,
                            clockwise: true)
                
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
    
    func maxCornerRadius(size: CGSize) -> CGFloat {
        
        let currentPoint: CGPoint = point(angle: angle(index: 0.0), radius: radii.upperBound, size: size)
        let inBetweenPoint: CGPoint = point(angle: angle(index: 1.0), radius: radii.lowerBound, size: size)
        let nextPoint: CGPoint = point(angle: angle(index: 1.0), radius: radii.upperBound, size: size)
        
        let midPoint: CGPoint = CGPoint(x: (currentPoint.x + nextPoint.x) / 2,
                                        y: (currentPoint.y + nextPoint.y) / 2)
        
        let centerPoint: CGPoint = CGPoint(x: size.width / 2,
                                           y: size.height / 2)
        
        let pointDistance: CGPoint = CGPoint(x: abs(midPoint.x - centerPoint.x),
                                             y: abs(midPoint.y - centerPoint.y))
        let distance: CGFloat = hypot(pointDistance.x, pointDistance.y)
        
        return distance
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
        Star(count: 5, radii: 50...100)
        VStack {
            Star(count: 3, radii: 90...100, cornerRadius: 10)
                .stroke()
            Star(count: 4, radii: 75...100, cornerRadius: 15)
                .stroke()
            Star(count: 5, radii: 45...100, cornerRadius: 20)
                .stroke()
        }
        Star(count: 5, radii: 50...100, relativeCornerRadius: 0.5)
    }
}
