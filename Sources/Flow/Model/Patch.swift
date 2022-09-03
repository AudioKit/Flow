// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

/// Data model for Flow.
///
/// Write a function to generate a `Patch` from your own data model
/// as well as a function to update your data model when the `Patch` changes.
/// Use SwiftUI's onChange(of:) to monitor changes.
public struct Patch: Equatable {
    var nodes: [Node]
    var wires: Set<Wire>

    public init(nodes: [Node], wires: Set<Wire>) {
        self.nodes = nodes
        self.wires = wires
    }

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

    /// Recursive layout.
    ///
    /// Returns height of all nodes in subtree.
    @discardableResult
    public mutating func recursiveLayout(nodeIndex: NodeIndex, point: CGPoint, layout: LayoutConstants = LayoutConstants()) -> CGFloat {
        nodes[nodeIndex].position = point

        // XXX: super slow
        let incomingWires = wires.filter {
            $0.input.nodeIndex == nodeIndex
        }.sorted(by: { $0.input.portIndex < $1.input.portIndex })

        var height: CGFloat = 0
        for wire in incomingWires {
            let h = recursiveLayout(nodeIndex: wire.output.nodeIndex,
                                    point: CGPoint(x: point.x - layout.nodeWidth - 40, y: point.y + height),
                                    layout: layout)
            height += h
        }

        return height + nodes[nodeIndex].rect(layout: layout).height
    }
}
