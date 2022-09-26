// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import Foundation
import SwiftUI

extension String {
    @_disfavoredOverload
    func removing(prefix: String) -> String? {
        guard hasPrefix(prefix) else { return nil }
        return String(dropFirst(prefix.count))
    }
}

extension CGSize {
    @_disfavoredOverload
    var point: CGPoint {
        CGPoint(x: width, y: height)
    }
}

extension CGPoint {
    @_disfavoredOverload
    static func + (lhs: Self, rhs: CGSize) -> Self {
        Self(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }

    @_disfavoredOverload
    static func - (lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
    }
}

extension CGSize {
    @_disfavoredOverload
    static func + (lhs: Self, rhs: Self) -> Self {
        Self(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    @_disfavoredOverload
    static func - (pt: CGPoint, sz: Self) -> CGPoint {
        CGPoint(x: pt.x - sz.width, y: pt.y - sz.height)
    }

    @_disfavoredOverload
    static func - (lhs: Self, rhs: Self) -> Self {
        Self(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    @_disfavoredOverload
    static func * (s: Double, sz: Self) -> Self {
        Self(width: s * sz.width, height: s * sz.height)
    }

    @_disfavoredOverload
    static func * (sz: Self, s: Double) -> Self {
        Self(width: s * sz.width, height: s * sz.height)
    }
}

extension CGRect {
    @_disfavoredOverload
    var center: CGPoint {
        origin + CGSize(width: size.width / 2, height: size.height / 2)
    }

    @_disfavoredOverload
    func offset(by off: CGSize) -> CGRect {
        offsetBy(dx: off.width, dy: off.height)
    }

    @_disfavoredOverload
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

    @inlinable @inline(__always)
    func distance(to p: CGPoint) -> CGFloat {
        hypot(x - p.x, y - p.y)
    }

    @_disfavoredOverload
    static func += (lhs: inout CGPoint, rhs: CGSize) {
        lhs = lhs + rhs
    }
}

extension Color {
    static let magenta = Color(.sRGB, red: 1, green: 0, blue: 1, opacity: 1)
}
