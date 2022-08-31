import SwiftUI

extension PatchView {
    /// Draw a node.
    func draw(node: Node,
              nodeIndex: NodeIndex,
              cx: GraphicsContext,
              viewport: CGRect)
    {
        let offset = self.offset(for: nodeIndex)
        let rect = rect(node: node).offset(by: offset)

        if !rect.intersects(viewport) {
            return
        }

        let pos = rect.origin

        let bg = Path(roundedRect: rect, cornerRadius: 5)

        let selected = dragInfo.selectionRect != .zero ? rect.intersects(dragInfo.selectionRect) : selection.contains(nodeIndex)
        cx.fill(bg, with: .color(Color(white: selected ? 0.4 : 0.2, opacity: 0.6)))

        cx.draw(Text(node.name),
                at: pos + CGSize(width: rect.size.width / 2, height: 20),
                anchor: .center)

        for (i, input) in node.inputs.enumerated() {
            let rect = inputRect(node: node, input: i).offset(by: offset)
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.cyan))
            if !patch.wires.contains(where: { $0.input == InputID(patch.nodes.firstIndex(of: node)!, i) }) {
                let dot = Path(ellipseIn: rect.insetBy(dx: rect.size.width / 3, dy: rect.size.height / 3))
                cx.fill(dot, with: .color(.black))
            }
            cx.draw(Text(input.name).font(.caption),
                    at: rect.center + CGSize(width: portSize.width / 2 + portSpacing, height: 0),
                    anchor: .leading)
        }

        for (i, output) in node.outputs.enumerated() {
            let rect = outputRect(node: node, output: i).offset(by: offset)
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.magenta))
            if !patch.wires.contains(where: { $0.output == OutputID(patch.nodes.firstIndex(of: node)!, i) }) {
                let dot = Path(ellipseIn: rect.insetBy(dx: rect.size.width / 3, dy: rect.size.height / 3))
                cx.fill(dot, with: .color(.black))
            }
            cx.draw(Text(output.name).font(.caption),
                    at: rect.center + CGSize(width: -(portSize.width / 2 + portSpacing), height: 0),
                    anchor: .trailing)
        }
    }

    func drawNodes(cx: GraphicsContext, viewport: CGRect) {
        for (idx, node) in patch.nodes.enumerated() {
            draw(node: node, nodeIndex: idx, cx: cx, viewport: viewport)
        }
    }

    func drawWires(cx: GraphicsContext, viewport: CGRect) {
        for wire in patch.wires where wire != dragInfo.hideWire {
            let fromPoint = outputRect(node: patch.nodes[wire.output.nodeIndex],
                                       output: wire.output.portIndex).offset(by: offset(for: wire.output.nodeIndex)).center
            let toPoint = inputRect(node: patch.nodes[wire.input.nodeIndex],
                                    input: wire.input.portIndex).offset(by: offset(for: wire.input.nodeIndex)).center

            let bounds = CGRect(origin: fromPoint, size: toPoint - fromPoint)
            if viewport.intersects(bounds) {
                strokeWire(from: fromPoint, to: toPoint, cx: cx)
            }
        }
    }

    func drawDraggedWire(cx: GraphicsContext) {
        if let output = dragInfo.output {
            let outputRect = outputRect(node: patch.nodes[dragInfo.origin], output: output.portIndex)
            strokeWire(from: outputRect.center, to: outputRect.center + dragInfo.offset, cx: cx)
        }
    }

    func drawSelectionRect(cx: GraphicsContext) {
        if dragInfo.selectionRect != .zero {
            let rectPath = Path(roundedRect: dragInfo.selectionRect, cornerRadius: 0)
            cx.stroke(rectPath, with: .color(.cyan))
        }
    }

    func strokeWire(from: CGPoint, to: CGPoint, cx: GraphicsContext) {
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
}
