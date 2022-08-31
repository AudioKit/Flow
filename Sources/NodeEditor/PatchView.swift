import Foundation
import SwiftUI

/// Draws and interacts with the patch.
///
/// Draws everything using a single Canvas with manual layout. We found this is faster than
/// using a View for each Node.
public struct PatchView: View {

    /// Data model.
    @Binding var patch: Patch

    /// Selected nodes.
    @Binding var selection: Set<NodeID>

    /// State for all gestures.
    @GestureState var dragInfo = DragInfo()

    public init(patch: Binding<Patch>, selection: Binding<Set<NodeID>>) {
        _patch = patch
        _selection = selection
    }

    let portSize = CGSize(width: 20, height: 20)
    let portSpacing: CGFloat = 10
    let nodeWidth: CGFloat = 200
    let menuBarHeight: CGFloat = 40

    let gradient = Gradient(colors: [.magenta, .cyan])

    public var body: some View {
        Canvas { cx, size in

            let viewport = CGRect(origin: .zero, size: size)
            cx.addFilter(.shadow(radius: 5))

            // Draw wires.
            for wire in patch.wires where wire != dragInfo.hideWire {
                let fromPoint = outputRect(node: patch.nodes[wire.originNode],
                                           output: wire.outputPort).offset(by: offset(for: wire.originNode)).center
                let toPoint = inputRect(node: patch.nodes[wire.destinationNode],
                                        input: wire.inputPort).offset(by: offset(for: wire.destinationNode)).center

                let bounds = CGRect(origin: fromPoint, size: toPoint - fromPoint)
                if viewport.intersects(bounds) {
                    strokeWire(cx: cx, from: fromPoint, to: toPoint)
                }
            }

            // Draw nodes.
            for (idx, node) in patch.nodes.enumerated() {
                draw(node: node, id: idx, cx: cx, viewport: viewport)
            }

            // Draw a wire we're dragging.
            if let output = dragInfo.output {
                let outputRect = outputRect(node: patch.nodes[dragInfo.node], output: output)
                strokeWire(cx: cx, from: outputRect.center, to: outputRect.center + dragInfo.offset)
            }

            // Draw selection rect.
            if dragInfo.selectionRect != .zero {
                let rectPath = Path(roundedRect: dragInfo.selectionRect, cornerRadius: 0)
                cx.stroke(rectPath, with: .color(.cyan))
            }

        }.gesture(dragGesture)
    }
}
