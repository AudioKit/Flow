
import Foundation

public struct LayoutConstants {
    let portSize = CGSize(width: 20, height: 20)
    let portSpacing: CGFloat = 10
    let nodeWidth: CGFloat = 200
    let nodeTitleHeight: CGFloat = 40

    public init() {}
}

public enum HitTestResult {
    case node(NodeIndex)
    case input(NodeIndex, PortIndex)
    case output(NodeIndex, PortIndex)
    case background
}

public extension Node {

    /// Calculates the boudning rectangle for a node.
    func rect(layout: LayoutConstants) -> CGRect {
        let maxio = CGFloat(max(inputs.count, outputs.count))
        let size = CGSize(width: layout.nodeWidth, height: CGFloat(maxio * 30 + layout.nodeTitleHeight))

        return CGRect(origin: position, size: size)
    }

    /// Calculates the bounding rectangle for an input port (not including the name).
    func inputRect(input: PortIndex, layout: LayoutConstants) -> CGRect {
        let y = layout.nodeTitleHeight + CGFloat(input) * (layout.portSize.height + layout.portSpacing)
        return CGRect(origin: position + CGSize(width: layout.portSpacing, height: y),
                      size: layout.portSize)
    }

    /// Calculates the bounding rectangle for an output port (not including the name).
    func outputRect(output: PortIndex, layout: LayoutConstants) -> CGRect {
        let y = layout.nodeTitleHeight + CGFloat(output) * (layout.portSize.height + layout.portSpacing)
        return CGRect(origin: position + CGSize(width: layout.nodeWidth - layout.portSpacing - layout.portSize.width, height: y),
                      size: layout.portSize)
    }
}

public extension Patch {

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
