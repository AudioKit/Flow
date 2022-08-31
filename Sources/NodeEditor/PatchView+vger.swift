
import Foundation
import vger
import vgerSwift

extension PatchView {

    func strokeWire(from: CGPoint, to: CGPoint, vger: vgerContext) {

        let d = Float(0.4 * abs(to.x - from.x))

        let center = 0.5 * (from.simd + to.simd)
        let cyan = SIMD4<Float>(0,1,1,1)
        let magenta = SIMD4<Float>(1,0,1,1)
        let paint = vgerLinearGradient(vger, from.simd, to.simd, cyan, magenta, 0)

        let bez0 = vgerBezierSegment(a: from.simd, b: from.simd + SIMD2(d, 0), c: center)
        vgerStrokeBezier(vger, bez0, 2.0, paint)

        let bez1 = vgerBezierSegment(a: center, b: to.simd - SIMD2(d, 0), c: to.simd)
        vgerStrokeBezier(vger, bez1, 2.0, paint)

    }
}
