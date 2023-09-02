//
//  File.swift
//  
//
//  Created by Anton on 2023-08-26.
//

import CoreGraphics
import SwiftUI

public enum SShape {
    case circle(radius: CGFloat, center: CGPoint)
    case rectangle(CGRect)
    case polygon(count: Int, radius: CGFloat, center: CGPoint)
    case star(count: Int, radius: CGFloat, center: CGPoint)
    case arc(radius: CGFloat, center: CGPoint, leading: Angle, trailing: Angle)
    case donut(radius: CGFloat, width: CGFloat, center: CGPoint)
    case line(leading: CGPoint, trailing: CGPoint)
}

enum SStroke {
    case center
    case inner
}

//extension SShape {
//
//    public func view(stroke: SStroke? = nil,
//                     cornerRadius: CGFloat = 0.0) -> some View {
//        switch self {
//        case .circle(let radius, let center):
//            return Circle()
//        case .rectangle(let cGRect):
//            <#code#>
//        case .polygon(let radius, let center):
//            <#code#>
//        case .star(let count, let radius, let center):
//            <#code#>
//        case .arc(let radius, let center, let leading, let trailing):
//            <#code#>
//        case .donut(let radius, let width, let center):
//            <#code#>
//        case .line(let leading, let trailing):
//            <#code#>
//        }
//    }
//
//    private func shape(cornerRadius: CGFloat = 0.0) -> any Shape {
//        switch self {
//        case .circle:
//            return Circle()
//        case .rectangle:
//            return Rectangle()
//        case .polygon(let count, _, _):
//            return Polygon(count: count, cornerRadius: cornerRadius)
//        case .star(let count, let radius, let center):
//            <#code#>
//        case .arc(let radius, let center, let leading, let trailing):
//            <#code#>
//        case .donut(let radius, let width, let center):
//            <#code#>
//        case .line(let leading, let trailing):
//            <#code#>
//        }
//    }
//}
