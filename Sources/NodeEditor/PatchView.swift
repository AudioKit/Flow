

import Foundation
import SwiftUI

/// Draws and interacts with the patch.
///
/// Draws everything using a single Canvas with manual layout. We found this is faster than
/// using a View for each Node.
struct PatchView: View {
    @Binding var patch: Patch

    let portSize = CGSize(width: 20, height: 20)
    let portSpacing: CGFloat = 10

    struct PortInfo: Hashable {
        var node: NodeID
        var port: Int
    }

    func draw(_ node: Node,
              _ id: NodeID,
              _ cx: GraphicsContext,
              _ inputRects: inout [PortInfo: CGRect],
              _ outputRects: inout [PortInfo: CGRect]) {

        let inputs = node.inputs
        let outputs = node.outputs

        let maxio = max(inputs.count, outputs.count)

        let size = CGSize(width: 200, height: maxio * 30 + 40)

        let pos = node.position // + (node.name == dragInfo.node ? dragInfo.offset : .zero)

        let bg = Path(roundedRect: CGRect(origin: pos, size: size), cornerRadius: 5)
        cx.fill(bg, with: .color(Color(white: 0.2, opacity: 0.6)))

        cx.draw(Text(node.name), at: pos + CGSize(width: size.width/2, height: 20), anchor: .center)

        var y: CGFloat = 40
        var i = 0
        for input in inputs {
            let rect = CGRect(origin: pos + CGSize(width: portSpacing, height: y), size: portSize)
            inputRects[.init(node: id, port: i)] = rect
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.cyan))

            cx.draw(Text(input).font(.caption), at: rect.center + CGSize(width: (portSize.width/2 + portSpacing), height: 0), anchor: .leading)

            y += portSize.height + portSpacing
            i += 1
        }

        y = 40
        i = 0
        for output in outputs {
            let rect = CGRect(origin: pos + CGSize(width: size.width - portSpacing - portSize.width, height: y), size: portSize)
            outputRects[.init(node: id, port: i)] = rect
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.magenta))

            cx.draw(Text(output).font(.caption), at: rect.center + CGSize(width: -(portSize.width/2 + portSpacing), height: 0), anchor: .trailing)

            y += portSize.height + portSpacing
            i += 1
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

    var body: some View {
        Canvas { cx, size in

            var inputRects: [PortInfo: CGRect] = [:]
            var outputRects: [PortInfo: CGRect] = [:]

            cx.addFilter(.shadow(radius: 5))

            var id = 0
            for node in patch.nodes {
                draw(node, id, cx, &inputRects, &outputRects)
                id += 1
            }

            for wire in patch.wires {

                if let outputRect = outputRects[PortInfo(node: wire.from, port: wire.output)],
                   let inputRect = inputRects[PortInfo(node: wire.to, port: wire.input)] {

                    strokeWire(cx: cx, from: outputRect.center, to: inputRect.center)

                }
            }
        }
    }
}
