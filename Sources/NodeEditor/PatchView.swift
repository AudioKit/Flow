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

    /// Draw a node.
    func draw(_ node: Node,
              _ id: NodeID,
              _ cx: GraphicsContext,
              _ viewport: CGRect) {

        let offset = self.offset(for: id)
        let rect = rect(node: node).offset(by: offset)

        if !rect.intersects(viewport) {
            return
        }

        let pos = rect.origin

        let bg = Path(roundedRect: rect, cornerRadius: 5)

        let selected = dragInfo.selectionRect != .zero ? rect.intersects(dragInfo.selectionRect) : selection.contains(id)
        cx.fill(bg, with: .color(Color(white: selected ? 0.4 : 0.2, opacity: 0.6)))

        cx.draw(Text(node.name),
                at: pos + CGSize(width: rect.size.width/2, height: 20),
                anchor: .center)

        for (i, input) in node.inputs.enumerated() {
            let rect = inputRect(node: node, input: i).offset(by: offset)
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.cyan))
            cx.draw(Text(input.name).font(.caption),
                    at: rect.center + CGSize(width: (portSize.width/2 + portSpacing), height: 0),
                    anchor: .leading)
        }

        for (i, output) in node.outputs.enumerated() {
            let rect = outputRect(node: node, output: i).offset(by: offset)
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.magenta))
            cx.draw(Text(output.name).font(.caption),
                    at: rect.center + CGSize(width: -(portSize.width/2 + portSpacing), height: 0),
                    anchor: .trailing)
        }
    }

    let gradient = Gradient(colors: [.magenta, .cyan])

    func strokeWire(cx: GraphicsContext, from: CGPoint, to: CGPoint) {

        let d = 0.4 * abs(to.x - from.x)
        var path = Path()
        path.move(to: from)
        path.addCurve(to: to,
                      control1: CGPoint(x: from.x + d, y: from.y),
                      control2: CGPoint(x: to.x - d, y: to.y))

        cx.stroke(path,
                  with: .linearGradient(gradient, startPoint: from, endPoint: to),
                  style: StrokeStyle(lineWidth: 2.0, lineCap: .round))

    }

    /// Adds a new wire to the patch, ensuring that multiple wires aren't connected to an input.
    func add(wire: Wire) {
        // Remove any other wires connected to the input.
        patch.wires = patch.wires.filter { w in
            (w.destinationNode, w.inputPort) != (wire.destinationNode, wire.inputPort)
        }
        patch.wires.insert(wire)
    }

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
                draw(node, idx, cx, viewport)
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
