// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

public extension NodeEditor {
    /// Offset to apply to a node based on selection and gesture state.
    func offset(for idx: NodeIndex) -> CGSize {
        if self.patch.nodes[idx].locked {
            return .zero
        }
        switch self.dragInfo {
        case let .node(index: index, offset: offset):
            if idx == index {
                return offset
            }
            if self.selection.contains(index), self.selection.contains(idx) {
                // Offset other selected node only if we're dragging the
                // selection.
                return offset
            }
        default:
            return .zero
        }
        return .zero
    }

    /// Search for inputs.
    func findInput(node: Node, point: CGPoint) -> PortIndex? {
        node.inputs.enumerated().first { portIndex, _ in
            node.inputRect(input: portIndex, layout: self.layout).contains(point)
        }?.0
    }

    /// Search for an input in the whole patch.
    func findInput(point: CGPoint) -> InputID? {
        // Search nodes in reverse to find nodes drawn on top first.
        for (nodeIndex, node) in self.patch.nodes.enumerated().reversed() {
            if let portIndex = self.findInput(node: node, point: point) {
                return InputID(nodeIndex, portIndex)
            }
        }
        return nil
    }

    /// Search for outputs.
    func findOutput(node: Node, point: CGPoint) -> PortIndex? {
        node.outputs.enumerated().first { portIndex, _ in
            node.outputRect(output: portIndex, layout: self.layout).contains(point)
        }?.0
    }

    /// Search for an output in the whole patch.
    func findOutput(point: CGPoint) -> OutputID? {
        // Search nodes in reverse to find nodes drawn on top first.
        for (nodeIndex, node) in self.patch.nodes.enumerated().reversed() {
            if let portIndex = self.findOutput(node: node, point: point) {
                return OutputID(nodeIndex, portIndex)
            }
        }
        return nil
    }

    /// Search for a node which intersects a point.
    func findNode(point: CGPoint) -> NodeIndex? {
        // Search nodes in reverse to find nodes drawn on top first.
        self.patch.nodes.enumerated().reversed().first { _, node in
            node.rect(layout: self.layout).contains(point)
        }?.0
    }
}
