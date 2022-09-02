
import Foundation

public struct LayoutConstants {
    let portSize = CGSize(width: 20, height: 20)
    let portSpacing: CGFloat = 10
    let nodeWidth: CGFloat = 200
    let nodeTitleHeight: CGFloat = 40

    public init() {}
}

public extension Node {

    func rect(layout: LayoutConstants) -> CGRect {
        let maxio = max(inputs.count, outputs.count)
        let size = CGSize(width: layout.nodeWidth, height: CGFloat(maxio * 30 + 40))

        return CGRect(origin: position, size: size)
    }
}
