// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

/// Data model for Flow.
///
/// Write a function to generate a `Patch` from your own data model
/// as well as a function to update your data model when the `Patch` changes.
/// Use SwiftUI's `onChange(of:)` to monitor changes.
public struct Patch: Equatable {
    public var nodes: [Node]
    public var wires: Set<Wire>

    public init(nodes: [Node], wires: Set<Wire>) {
        self.nodes = nodes
        self.wires = wires
    }

    enum HitTestResult {
        case node(NodeIndex)
        case input(NodeIndex, PortIndex)
        case output(NodeIndex, PortIndex)
    }

    /// Hit test a point against the whole patch.
    func hitTest(point: CGPoint, layout: LayoutConstants) -> HitTestResult? {
        for (nodeIndex, node) in nodes.enumerated().reversed() {
            if let result = node.hitTest(nodeIndex: nodeIndex, point: point, layout: layout) {
                return result
            }
        }

        return nil
    }

    mutating func moveNode(
        nodeIndex: NodeIndex,
        offset: CGSize,
        nodeMoved: NodeEditor.NodeMovedHandler
    ) {
        if !self.nodes[nodeIndex].locked {
            self.nodes[nodeIndex].position += offset
            nodeMoved(nodeIndex, self.nodes[nodeIndex].position)
        }
    }

    func selected(in rect: CGRect, layout: LayoutConstants) -> Set<NodeIndex> {
        var selection = Set<NodeIndex>()

        for (idx, node) in self.nodes.enumerated() {
            if rect.intersects(node.rect(layout: layout)) {
                selection.insert(idx)
            }
        }
        return selection
    }

    @inlinable @inline(__always)
    func isInputWireConnected(node: Node, index: Int) -> Bool {
        self.wires.contains(where: { $0.input == InputID(nodes.firstIndex(of: node)!, index) })
    }

    @inlinable @inline(__always)
    func isOutputWireConnected(node: Node, index: Int) -> Bool {
        self.wires.contains(where: { $0.output == OutputID(nodes.firstIndex(of: node)!, index) })
    }
}
