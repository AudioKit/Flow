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

    struct PortInfo: Hashable {
        var node: NodeID
        var port: Int
    }

    struct Layout {
        var nodeRects: [CGRect] = []
        var inputRects: [PortInfo: CGRect] = [:]
        var outputRects: [PortInfo: CGRect] = [:]
    }

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

    var layout: Layout {
        var result = Layout()

        var id = 0

        for node in patch.nodes {
            let shouldOffset = id == dragInfo.node || selection.contains(id)
            let rect = rect(node: node).offset(by: (shouldOffset ? dragInfo.offset : .zero))
            result.nodeRects.append(rect)

            let pos = rect.origin

            var y: CGFloat = 40
            var i = 0
            for _ in node.inputs {
                let rect = CGRect(origin: pos + CGSize(width: portSpacing, height: y), size: portSize)
                result.inputRects[PortInfo(node: id, port: i)] = rect
                y += portSize.height + portSpacing
                i += 1
            }

            y = 40
            i = 0
            for _ in node.outputs {
                let rect = CGRect(origin: pos + CGSize(width: rect.size.width - portSpacing - portSize.width, height: y), size: portSize)
                result.outputRects[PortInfo(node: id, port: i)] = rect
                y += portSize.height + portSpacing
                i += 1
            }

            id += 1
        }

        return result
    }

    func draw(_ node: Node,
              _ id: NodeID,
              _ cx: GraphicsContext,
              _ layout: Layout) {

        let shouldOffset = id == dragInfo.node || selection.contains(id)
        let offset = (shouldOffset ? dragInfo.offset : .zero)
        let rect = rect(node: node).offset(by: offset)

        let pos = rect.origin

        let bg = Path(roundedRect: rect, cornerRadius: 5)

        let selected = dragInfo.selectionRect != .zero ? rect.intersects(dragInfo.selectionRect) : selection.contains(id)
        cx.fill(bg, with: .color(Color(white: selected ? 0.4 : 0.2, opacity: 0.6)))

        cx.draw(Text(node.name), at: pos + CGSize(width: rect.size.width/2, height: 20), anchor: .center)

        var i = 0
        for input in node.inputs {
            let rect = inputRect(node: node, input: i).offset(by: offset)
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.cyan))
            cx.draw(Text(input.name).font(.caption), at: rect.center + CGSize(width: (portSize.width/2 + portSpacing), height: 0), anchor: .leading)
            i += 1
        }

        i = 0
        for output in node.outputs {
            let rect = outputRect(node: node, output: i).offset(by: offset)
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.magenta))
            cx.draw(Text(output.name).font(.caption), at: rect.center + CGSize(width: -(portSize.width/2 + portSpacing), height: 0), anchor: .trailing)
            i += 1
        }

        if dragInfo.selectionRect != .zero {
            let rectPath = Path(roundedRect: dragInfo.selectionRect, cornerRadius: 0)
            cx.stroke(rectPath, with: .color(.cyan))
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
        var node: NodeID = 0
        var offset: CGSize = .zero
        var selectionRect: CGRect = .zero
    }

    @GestureState var dragInfo = DragInfo()

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragInfo) { value, state, _ in
                var idx = 0
                for node in patch.nodes {
                    if rect(node: node).contains(value.startLocation) {
                        state = DragInfo(node: idx, offset: value.translation)
                        return
                    }
                    idx += 1
                }

                state = DragInfo(selectionRect: CGRect(origin: value.startLocation, size: value.translation))
            }
            .onEnded { value in
                var idx = 0
                for node in patch.nodes {
                    if rect(node: node).contains(value.startLocation) {
                        patch.nodes[idx].position += value.translation
                        for id in selection where id != idx {
                            patch.nodes[id].position += value.translation
                        }
                        return
                    }
                    idx += 1
                }

                selection = Set<NodeID>()
                let selectionRect = CGRect(origin: value.startLocation, size: value.translation)
                idx = 0
                for node in patch.nodes {
                    if selectionRect.intersects(rect(node: node)) {
                        selection.insert(idx)
                    }
                    idx += 1
                }
            }
    }

    public var body: some View {
        Canvas { cx, size in

            cx.addFilter(.shadow(radius: 5))

            let layout = self.layout

            var id = 0
            id = 0
            for node in patch.nodes {
                draw(node, id, cx, layout)
                id += 1
            }

            for wire in patch.wires {

                if let outputRect = layout.outputRects[PortInfo(node: wire.from, port: wire.output)],
                   let inputRect = layout.inputRects[PortInfo(node: wire.to, port: wire.input)] {

                    strokeWire(cx: cx, from: outputRect.center, to: inputRect.center)

                }
            }
        }.gesture(dragGesture)
    }
}
