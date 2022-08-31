import SwiftUI

public extension PatchView {
    /// Calculates the boudning rectangle for a node.
    func rect(node: Node) -> CGRect {
        let maxio = max(node.inputs.count, node.outputs.count)
        let size = CGSize(width: nodeWidth, height: CGFloat(maxio * 30 + 40))

        return CGRect(origin: node.position, size: size)
    }

    /// Calculates the bounding rectangle for an input port (not including the name).
    func inputRect(node: Node, input: PortIndex) -> CGRect {
        let pos = rect(node: node).origin
        let y = menuBarHeight + CGFloat(input) * (portSize.height + portSpacing)
        return CGRect(origin: pos + CGSize(width: portSpacing, height: y), size: portSize)
    }

    /// Calculates the bounding rectangle for an output port (not including the name).
    func outputRect(node: Node, output: PortIndex) -> CGRect {
        let pos = rect(node: node).origin
        let y = menuBarHeight + CGFloat(output) * (portSize.height + portSpacing)
        return CGRect(origin: pos + CGSize(width: nodeWidth - portSpacing - portSize.width, height: y),
                      size: portSize)
    }

    /// Offset to apply to a node based on selection and gesture state.
    func offset(for idx: NodeIndex) -> CGSize {
        guard dragInfo.output == nil, idx == dragInfo.origin || selection.contains(idx) else { return .zero }
        return dragInfo.offset
    }

    /// Search for inputs.
    func findInput(node: Node, point: CGPoint) -> PortIndex? {
        node.inputs.enumerated().first { portIndex, _ in
            inputRect(node: node, input: portIndex).contains(point)
        }?.0
    }

    /// Search for an input in the whole patch.
    func findInput(point: CGPoint) -> PortID? {
        for (nodeIndex, node) in patch.nodes.enumerated() {
            if let portIndex = findInput(node: node, point: point) {
                return PortID(nodeIndex, portIndex)
            }
        }
        return nil
    }

    /// Search for outputs.
    func findOutput(node: Node, point: CGPoint) -> PortIndex? {
        node.outputs.enumerated().first { portIndex, _ in
            outputRect(node: node, output: portIndex).contains(point)
        }?.0
    }

    /// Search for an output in the whole patch.
    func findOutput(point: CGPoint) -> PortID? {
        for (nodeIndex, node) in patch.nodes.enumerated() {
            if let portIndex = findOutput(node: node, point: point) {
                return PortID(nodeIndex, portIndex)
            }
        }
        return nil
    }

    /// Search for a node which intersects a point.
    func findNode(point: CGPoint) -> NodeIndex? {
        patch.nodes.enumerated().first { _, node in
            rect(node: node).contains(point)
        }?.0
    }
}
