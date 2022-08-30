//
//  Donut.swift
//  
//
//  Created by Anton Heestand on 2022-08-29.
//

import SwiftUI

@available(iOS 15.0, *)
public struct Donut: Shape {
    
    let width: CGFloat
    
    public init(width: CGFloat) {
        self.width = width
    }
    
    public func path(in rect: CGRect) -> Path {
        
        Path { path in
            
            path.addArc(center: rect.center, radius: rect.width / 2, startAngle: .zero, endAngle: Angle(degrees: 360), clockwise: true)
            
            path.addArc(center: rect.center, radius: rect.width / 2 - width, startAngle: .zero, endAngle: Angle(degrees: 360), clockwise: false)
        }
    }
}

@available(iOS 15.0, *)
struct Donut_Previews: PreviewProvider {
    static var previews: some View {
        Donut(width: 50)
    }
}
