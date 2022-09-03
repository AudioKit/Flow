// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import Foundation
import SwiftUI

extension String {
    func deletingPrefix(_ prefix: String) -> String? {
        guard hasPrefix(prefix) else { return nil }
        return String(dropFirst(prefix.count))
    }
}

extension CGSize {
    var point: CGPoint {
        CGPoint(x: width, y: height)
    }
}

func + (lhs: CGPoint, rhs: CGSize) -> CGPoint {
    CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
}

func - (lhs: CGPoint, rhs: CGPoint) -> CGSize {
    CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
}

func + (lhs: CGSize, rhs: CGSize) -> CGSize {
    CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}

extension CGRect {
    var center: CGPoint {
        origin + CGSize(width: size.width / 2, height: size.height / 2)
    }

    func offset(by off: CGSize) -> CGRect {
        offsetBy(dx: off.width, dy: off.height)
    }

    init(a: CGPoint, b: CGPoint) {
        self.init()
        origin = CGPoint(x: min(a.x, b.x), y: min(a.y, b.y))
        size = CGSize(width: abs(a.x - b.x), height: abs(a.y - b.y))
    }
}

extension CGPoint {
    var size: CGSize {
        CGSize(width: x, height: y)
    }

    var simd: SIMD2<Float> {
        .init(x: Float(x), y: Float(y))
    }
}

func += (lhs: inout CGPoint, rhs: CGSize) {
    lhs = lhs + rhs
}

extension Color {
    static let magenta = Color(.sRGB, red: 1, green: 0, blue: 1, opacity: 1)
}
