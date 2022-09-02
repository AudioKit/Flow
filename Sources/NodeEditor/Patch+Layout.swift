
import Foundation

public struct LayoutConstants {
    let portSize = CGSize(width: 20, height: 20)
    let portSpacing: CGFloat = 10
    let nodeWidth: CGFloat = 200
    let nodeTitleHeight: CGFloat = 40

    public init() {}
}

public extension Patch {

    enum HitTestResult {
        case node(NodeIndex)
        case input(NodeIndex, PortIndex)
        case output(NodeIndex, PortIndex)
        case background
    }

    /// Hit test a point against the whole patch.
    func hitTest(point: CGPoint, layout: LayoutConstants) -> HitTestResult {

        for (nodeIndex, node) in nodes.enumerated().reversed() {
            for (inputIndex, _) in node.inputs.enumerated() {
                if node.inputRect(input: inputIndex, layout: layout).contains(point) {
                    return .input(nodeIndex, inputIndex)
                }
            }
            for (outputIndex, _) in node.outputs.enumerated() {
                if node.outputRect(output: outputIndex, layout: layout).contains(point) {
                    return .output(nodeIndex, outputIndex)
                }
            }

            if node.rect(layout: layout).contains(point) {
                return .node(nodeIndex)
            }
        }

        return .background
    }
}
