import SwiftUI

/// Draws and interacts with the patch.
///
/// Draws everything using a single Canvas with manual layout. We found this is faster than
/// using a View for each Node.
public struct PatchView: View {
    /// Data model.
    @Binding var patch: Patch

    /// Selected nodes.
    @Binding var selection: Set<NodeIndex>

    /// State for all gestures.
    @GestureState var dragInfo = DragInfo.none

    /// Initialize the patch view with a patch and a selection
    /// - Parameters:
    ///   - patch: Patch to display
    ///   - selection: set of nodes currently selected
    public init(patch: Binding<Patch>, selection: Binding<Set<NodeIndex>>) {
        _patch = patch
        _selection = selection
    }

    // Constants, for now
    let layout = LayoutConstants()
    let gradient = Gradient(colors: [.magenta, .cyan])

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
