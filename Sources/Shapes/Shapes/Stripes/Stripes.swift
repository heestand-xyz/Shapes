//
//  Stripes.swift
//  
//
//  Created by Heestand, Anton Norman | Anton | GSSD on 2023-09-14.
//

import SwiftUI

public struct Stripes: View {
    
    private let length: CGFloat
    private let spacing: CGFloat
    private let angle: Angle
    
    public init(length: CGFloat, spacing: CGFloat? = nil, angle: Angle) {
        self.length = length
        self.spacing = spacing ?? length
        self.angle = angle
    }
    
    public var body: some View {
        Canvas { context, size in
            context.fill(path(size: size), with: .foreground)
        }
    }
    
    private func path(size: CGSize) -> Path {
        Path { path in
            
            let angle: Angle = angle + .degrees(90)

            let diagonalDiameter: CGFloat = hypot(size.width, size.height)
            let diagonalRadius: CGFloat = diagonalDiameter / 2

            let distance: CGFloat = length + spacing
            let radius: CGFloat = length / 2
            
            let count = Int(ceil(diagonalRadius / distance))
            for index in -count...count {
                let offset: CGFloat = CGFloat(index) * distance
                let a = CGPoint(
                    x: size.width / 2 + cos(CGFloat(angle.radians)) * (offset + radius),
                    y: size.height / 2 + sin(CGFloat(angle.radians)) * (offset + radius))
                let b = CGPoint(
                    x: size.width / 2 + cos(CGFloat(angle.radians)) * (offset - radius),
                    y: size.height / 2 + sin(CGFloat(angle.radians)) * (offset - radius))
                let a1 = CGPoint(
                    x: a.x + cos(CGFloat((angle + .degrees(90)).radians)) * diagonalRadius,
                    y: a.y + sin(CGFloat((angle + .degrees(90)).radians)) * diagonalRadius)
                let a2 = CGPoint(
                    x: a.x + cos(CGFloat((angle - .degrees(90)).radians)) * diagonalRadius,
                    y: a.y + sin(CGFloat((angle - .degrees(90)).radians)) * diagonalRadius)
                let b1 = CGPoint(
                    x: b.x + cos(CGFloat((angle + .degrees(90)).radians)) * diagonalRadius,
                    y: b.y + sin(CGFloat((angle + .degrees(90)).radians)) * diagonalRadius)
                let b2 = CGPoint(
                    x: b.x + cos(CGFloat((angle - .degrees(90)).radians)) * diagonalRadius,
                    y: b.y + sin(CGFloat((angle - .degrees(90)).radians)) * diagonalRadius)
                path.move(to: a1)
                path.addLine(to: a2)
                path.addLine(to: b2)
                path.addLine(to: b1)
            }
        }
    }
}

#Preview {
    Stripes(length: 10, spacing: 20, angle: .degrees(370))
}
