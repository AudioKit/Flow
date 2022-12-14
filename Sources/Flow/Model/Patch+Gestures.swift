// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

extension Patch {
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
        if !nodes[nodeIndex].locked {
            nodes[nodeIndex].position += offset
            nodeMoved(nodeIndex, nodes[nodeIndex].position)
        }
    }

    func selected(in rect: CGRect, layout: LayoutConstants) -> Set<NodeIndex> {
        var selection = Set<NodeIndex>()

        for (idx, node) in nodes.enumerated() {
            if rect.intersects(node.rect(layout: layout)) {
                selection.insert(idx)
            }
        }
        return selection
    }
}
