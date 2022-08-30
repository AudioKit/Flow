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

    func rect(node: Node) -> CGRect {

        let maxio = max(node.inputs.count, node.outputs.count)
        let size = CGSize(width: nodeWidth, height: CGFloat(maxio * 30 + 40))

        return CGRect(origin: node.position, size: size)
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
              _ rect: CGRect,
              _ cx: GraphicsContext,
              _ inputRects: inout [PortInfo: CGRect],
              _ outputRects: inout [PortInfo: CGRect]) {

        let inputs = node.inputs
        let outputs = node.outputs
        let pos = rect.origin

        let bg = Path(roundedRect: rect, cornerRadius: 5)

        let selected = dragInfo.selectionRect != .zero ? rect.intersects(dragInfo.selectionRect) : selection.contains(id)
        cx.fill(bg, with: .color(Color(white: selected ? 0.4 : 0.2, opacity: 0.6)))

        cx.draw(Text(node.name), at: pos + CGSize(width: rect.size.width/2, height: 20), anchor: .center)

        var y: CGFloat = 40
        var i = 0
        for input in inputs {
            let rect = CGRect(origin: pos + CGSize(width: portSpacing, height: y), size: portSize)
            inputRects[.init(node: id, port: i)] = rect
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.cyan))

            cx.draw(Text(input.name).font(.caption), at: rect.center + CGSize(width: (portSize.width/2 + portSpacing), height: 0), anchor: .leading)

            y += portSize.height + portSpacing
            i += 1
        }

        y = 40
        i = 0
        for output in outputs {
            let rect = CGRect(origin: pos + CGSize(width: rect.size.width - portSpacing - portSize.width, height: y), size: portSize)
            outputRects[.init(node: id, port: i)] = rect
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.magenta))

            cx.draw(Text(output.name).font(.caption), at: rect.center + CGSize(width: -(portSize.width/2 + portSpacing), height: 0), anchor: .trailing)

            y += portSize.height + portSpacing
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

            var nodeRects: [CGRect] = []
            var inputRects: [PortInfo: CGRect] = [:]
            var outputRects: [PortInfo: CGRect] = [:]

            cx.addFilter(.shadow(radius: 5))

            var id = 0

            for node in patch.nodes {
                let shouldOffset = id == dragInfo.node || selection.contains(id)
                let rect = rect(node: node).offset(by: (shouldOffset ? dragInfo.offset : .zero))
                nodeRects.append(rect)
                id += 1
            }

            id = 0
            for node in patch.nodes {
                draw(node, id, nodeRects[id], cx, &inputRects, &outputRects)
                id += 1
            }

            for wire in patch.wires {

                if let outputRect = outputRects[PortInfo(node: wire.from, port: wire.output)],
                   let inputRect = inputRects[PortInfo(node: wire.to, port: wire.input)] {

                    strokeWire(cx: cx, from: outputRect.center, to: inputRect.center)

                }
            }
        }.gesture(dragGesture)
    }
}
