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
            if self.patch.selection.contains(index), self.patch.selection.contains(idx) {
                // Offset other selected node only if we're dragging the
                // selection.
                return offset
            }
        default:
            return .zero
        }
        return .zero
    }
}
