import Foundation
import SwiftUI

/// Draws and interacts with the patch.
///
/// Draws everything using a single Canvas with manual layout. We found this is faster than
/// using a View for each Node.
public struct PatchView: View {
    @Binding var patch: Patch

    public init(patch: Binding<Patch>) {
        _patch = patch
    }

    let portSize = CGSize(width: 20, height: 20)
    let portSpacing: CGFloat = 10
    let nodeWidth: CGFloat = 200

    @State var selection = Set<NodeID>()

    /// Calculates the boudning rectangle for a node.
    func rect(node: Node) -> CGRect {

        let maxio = max(node.inputs.count, node.outputs.count)
        let size = CGSize(width: nodeWidth, height: CGFloat(maxio * 30 + 40))

        return CGRect(origin: node.position, size: size)
    }

    /// Calculates the bounding rectangle for an input port (not including the name).
    func inputRect(node: Node, input: Int) -> CGRect {
        let pos = rect(node: node).origin
        let y = 40 + CGFloat(input) * (portSize.height + portSpacing)
        return CGRect(origin: pos + CGSize(width: portSpacing, height: y), size: portSize)
    }

    /// Calculates the bounding rectangle for an output port (not including the name).
    func outputRect(node: Node, output: Int) -> CGRect {
        let pos = rect(node: node).origin
        let y = 40 + CGFloat(output) * (portSize.height + portSpacing)
        return CGRect(origin: pos + CGSize(width: nodeWidth - portSpacing - portSize.width, height: y), size: portSize)
    }

    /// Offset to apply to a node based on selection and gesture state.
    func offset(for id: NodeID) -> CGSize {
        guard dragInfo.output == nil && (id == dragInfo.node || selection.contains(id)) else { return .zero }
        return dragInfo.offset
    }

    func draw(_ node: Node,
              _ id: NodeID,
              _ cx: GraphicsContext) {

        let offset = self.offset(for: id)
        let rect = rect(node: node).offset(by: offset)

        let pos = rect.origin

        let bg = Path(roundedRect: rect, cornerRadius: 5)

        let selected = dragInfo.selectionRect != .zero ? rect.intersects(dragInfo.selectionRect) : selection.contains(id)
        cx.fill(bg, with: .color(Color(white: selected ? 0.4 : 0.2, opacity: 0.6)))

        cx.draw(Text(node.name), at: pos + CGSize(width: rect.size.width/2, height: 20), anchor: .center)

        for (i, input) in node.inputs.enumerated() {
            let rect = inputRect(node: node, input: i).offset(by: offset)
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.cyan))
            cx.draw(Text(input.name).font(.caption), at: rect.center + CGSize(width: (portSize.width/2 + portSpacing), height: 0), anchor: .leading)
        }

        for (i, output) in node.outputs.enumerated() {
            let rect = outputRect(node: node, output: i).offset(by: offset)
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.magenta))
            cx.draw(Text(output.name).font(.caption), at: rect.center + CGSize(width: -(portSize.width/2 + portSpacing), height: 0), anchor: .trailing)
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

    struct DragInfo {
        var output: Int? = nil
        var node: NodeID = 0
        var offset: CGSize = .zero
        var selectionRect: CGRect = .zero
    }

    @GestureState var dragInfo = DragInfo()

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragInfo) { value, state, _ in
                for (idx, node) in patch.nodes.enumerated() {
                    for (portIndex, _) in node.outputs.enumerated() {
                        if outputRect(node: node, output: portIndex).contains(value.startLocation) {
                            state = DragInfo(output: portIndex, node: idx, offset: value.translation)
                            return
                        }
                    }

                    if rect(node: node).contains(value.startLocation) {
                        state = DragInfo(node: idx, offset: value.translation)
                        return
                    }
                }

                state = DragInfo(selectionRect: CGRect(origin: value.startLocation, size: value.translation))
            }
            .onEnded { value in
                for (idx, node) in patch.nodes.enumerated() {
                    for (outputIndex, _) in node.outputs.enumerated() {
                        if outputRect(node: node, output: outputIndex).contains(value.startLocation) {
                            for (destinationIndex, destinationNode) in patch.nodes.enumerated() {
                                for (inputIndex, _) in destinationNode.inputs.enumerated() {
                                    if inputRect(node: destinationNode, input: inputIndex).contains(value.location) {
                                        patch.wires.append(Wire(from: idx, output: outputIndex, to: destinationIndex, input: inputIndex))
                                        return
                                    }
                                }
                            }
                            return
                        }
                    }

                    if rect(node: node).contains(value.startLocation) {
                        patch.nodes[idx].position += value.translation
                        for id in selection where id != idx {
                            patch.nodes[id].position += value.translation
                        }
                        return
                    }
                }

                selection = Set<NodeID>()
                let selectionRect = CGRect(origin: value.startLocation, size: value.translation)
                for (idx, node) in patch.nodes.enumerated() {
                    if selectionRect.intersects(rect(node: node)) {
                        selection.insert(idx)
                    }
                }
            }
    }

    public var body: some View {
        Canvas { cx, size in

            cx.addFilter(.shadow(radius: 5))

            for (idx, node) in patch.nodes.enumerated() {
                draw(node, idx, cx)
            }

            for wire in patch.wires {
                let outputRect = outputRect(node: patch.nodes[wire.from], output: wire.output).offset(by: offset(for: wire.from))
                let inputRect = inputRect(node: patch.nodes[wire.to], input: wire.input).offset(by: offset(for: wire.to))
                strokeWire(cx: cx, from: outputRect.center, to: inputRect.center)
            }

            if let output = dragInfo.output {
                let outputRect = outputRect(node: patch.nodes[dragInfo.node], output: output)
                strokeWire(cx: cx, from: outputRect.center, to: outputRect.center + dragInfo.offset)
            }
            if dragInfo.selectionRect != .zero {
                let rectPath = Path(roundedRect: dragInfo.selectionRect, cornerRadius: 0)
                cx.stroke(rectPath, with: .color(.cyan))
            }
        }.gesture(dragGesture)
    }
}
