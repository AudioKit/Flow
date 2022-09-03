// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/NodeEditor/

import SwiftUI

/// Draws and interacts with the patch.
///
/// Draws everything using a single Canvas with manual layout. We found this is faster than
/// using a View for each Node.
public struct NodeEditor: View {
    /// Data model.
    @Binding var patch: Patch

    /// Selected nodes.
    @Binding var selection: Set<NodeIndex>

    /// State for all gestures.
    @GestureState var dragInfo = DragInfo.none

    /// Called when a node is moved.
    var nodeMoved: (NodeIndex, CGPoint) -> Void

    /// Called when a wire is added.
    var wireAdded: (Wire) -> Void

    /// Called when a wire is removed.
    var wireRemoved: (Wire) -> Void

    /// Initialize the patch view with a patch and a selection
    /// - Parameters:
    ///   - patch: Patch to display
    ///   - selection: set of nodes currently selected
    ///   - moveNode: called when a node is moved
    public init(patch: Binding<Patch>,
                selection: Binding<Set<NodeIndex>>,
                nodeMoved: @escaping (NodeIndex, CGPoint) -> Void = { (_,_) in },
                wireAdded: @escaping (Wire) -> Void = { _ in },
                wireRemoved: @escaping (Wire) -> Void = { _ in }) {
        _patch = patch
        _selection = selection
        self.nodeMoved = nodeMoved
        self.wireAdded = wireAdded
        self.wireRemoved = wireRemoved
    }

    /// Constants used for layout.
    var layout = LayoutConstants()

    /// Gradient used for rendering wires.
    let wireGradient = Gradient(colors: [.magenta, .cyan])

    public var body: some View {
        Canvas { cx, size in

            let viewport = CGRect(origin: .zero, size: size)
            cx.addFilter(.shadow(radius: 5))

            drawWires(cx: cx, viewport: viewport)
            drawNodes(cx: cx, viewport: viewport)
            drawDraggedWire(cx: cx)
            drawSelectionRect(cx: cx)

        }.gesture(dragGesture)
    }
}
