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

    func incomingWires(for nodeIndex: NodeIndex) -> [Wire] {
        self.wires.filter {
            $0.input.nodeIndex == nodeIndex
        }.sorted(by: { $0.input.portIndex < $1.input.portIndex })
    }

    /// Recursive layout.
    ///
    /// - Returns: Height of all nodes in subtree.
    @discardableResult
    public mutating func recursiveLayout(
        nodeIndex: NodeIndex,
        at point: CGPoint,
        layout: LayoutConstants = LayoutConstants(),
        consumedNodeIndexes: Set<NodeIndex> = [],
        nodePadding: Bool = false
    ) -> (
        aggregateHeight: CGFloat,
        consumedNodeIndexes: Set<NodeIndex>
    ) {

        self.nodes[nodeIndex].position = point

        // XXX: super slow
        let incomingWires = self.incomingWires(for: nodeIndex)
        
        var consumedNodeIndexes = consumedNodeIndexes
        
        var height: CGFloat = 0
        for wire in incomingWires {
            let addPadding = wire == incomingWires.last
            let ni = wire.output.nodeIndex
            guard !consumedNodeIndexes.contains(ni) else { continue }

            let rl = self.recursiveLayout(
                nodeIndex: ni,
                at: CGPoint(x: point.x - layout.nodeWidth - layout.nodeSpacing,
                            y: point.y + height),
                layout: layout,
                consumedNodeIndexes: consumedNodeIndexes,
                nodePadding: addPadding
            )

            height = rl.aggregateHeight
            consumedNodeIndexes.insert(ni)
            consumedNodeIndexes.formUnion(rl.consumedNodeIndexes)
        }

        let nodeHeight = self.nodes[nodeIndex].rect(layout: layout).height
        let aggregateHeight = max(height, nodeHeight) + (nodePadding ? layout.nodeSpacing : 0)

        return (aggregateHeight, consumedNodeIndexes)
    }
    
    /// Manual stacked grid layout.
    ///
    /// - Parameters:
    ///   - origin: Top-left origin coordinate.
    ///   - columns: Array of columns each comprised of an array of node indexes.
    ///   - layout: Layout constants.
    public mutating func stackedLayout(
        at origin: CGPoint = .zero,
        _ columns: [[NodeIndex]],
        layout: LayoutConstants = LayoutConstants()
    ) {
        for column in columns.indices {
            let nodeStack = columns[column]
            var yOffset: CGFloat = 0
            
            let xPos = origin.x + (CGFloat(column) * (layout.nodeWidth + layout.nodeSpacing))
            for nodeIndex in nodeStack {
                self.nodes[nodeIndex].position = .init(
                    x: xPos,
                    y: origin.y + yOffset
                )
                
                let nodeHeight = self.nodes[nodeIndex].rect(layout: layout).height
                yOffset += nodeHeight
                if column != columns.indices.last {
                    yOffset += layout.nodeSpacing
                }
            }
        }
    }
}
