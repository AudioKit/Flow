// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

extension NodeEditor {
    /// Draw a node.
    func draw(node: Node,
              nodeIndex: NodeIndex,
              cx: GraphicsContext,
              viewport: CGRect)
    {
        let offset = self.offset(for: nodeIndex)
        let rect = node.rect(layout: layout).offset(by: offset)

        if !rect.intersects(viewport) {
            return
        }

        let pos = rect.origin

        let bg = Path(roundedRect: rect, cornerRadius: 5)

        var selected = false
        switch dragInfo {
        case let .selection(rect: selectionRect):
            selected = rect.intersects(selectionRect)
        default:
            selected = selection.contains(nodeIndex)
        }

        cx.fill(bg, with: .color(Color(white: selected ? 0.4 : 0.2, opacity: 0.6)))

        cx.draw(Text(node.name),
                at: pos + CGSize(width: rect.size.width / 2, height: 20),
                anchor: .center)

        for (i, input) in node.inputs.enumerated() {
            let rect = node.inputRect(input: i, layout: layout).offset(by: offset)
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.cyan))
            if !patch.wires.contains(where: { $0.input == InputID(patch.nodes.firstIndex(of: node)!, i) }) {
                let dot = Path(ellipseIn: rect.insetBy(dx: rect.size.width / 3, dy: rect.size.height / 3))
                cx.fill(dot, with: .color(.black))
            }
            cx.draw(Text(input.name).font(.caption),
                    at: rect.center + CGSize(width: layout.portSize.width / 2 + layout.portSpacing, height: 0),
                    anchor: .leading)
        }

        for (i, output) in node.outputs.enumerated() {
            let rect = node.outputRect(output: i, layout: layout).offset(by: offset)
            let circle = Path(ellipseIn: rect)
            cx.fill(circle, with: .color(.magenta))
            if !patch.wires.contains(where: { $0.output == OutputID(patch.nodes.firstIndex(of: node)!, i) }) {
                let dot = Path(ellipseIn: rect.insetBy(dx: rect.size.width / 3, dy: rect.size.height / 3))
                cx.fill(dot, with: .color(.black))
            }
            cx.draw(Text(output.name).font(.caption),
                    at: rect.center + CGSize(width: -(layout.portSize.width / 2 + layout.portSpacing), height: 0),
                    anchor: .trailing)
        }
    }

    func drawNodes(cx: GraphicsContext, viewport: CGRect) {
        for (idx, node) in patch.nodes.enumerated() {
            draw(node: node, nodeIndex: idx, cx: cx, viewport: viewport)
        }
    }

    func drawWires(cx: GraphicsContext, viewport: CGRect) {
        var hideWire: Wire?
        switch dragInfo {
        case .wire(output: _, offset: _, hideWire: let hw):
            hideWire = hw
        default:
            hideWire = nil
        }
        for wire in patch.wires where wire != hideWire {
            let fromPoint = patch.nodes[wire.output.nodeIndex].outputRect(
                output: wire.output.portIndex,
                layout: layout
            )
            .offset(by: offset(for: wire.output.nodeIndex)).center
            let toPoint = patch.nodes[wire.input.nodeIndex].inputRect(
                input: wire.input.portIndex,
                layout: layout
            )
            .offset(by: offset(for: wire.input.nodeIndex)).center

            let bounds = CGRect(origin: fromPoint, size: toPoint - fromPoint)
            if viewport.intersects(bounds) {
                strokeWire(from: fromPoint, to: toPoint, cx: cx)
            }
        }
    }

    func drawDraggedWire(cx: GraphicsContext) {
        if case let .wire(output: output, offset: offset, _) = dragInfo {
            let outputRect = patch.nodes[output.nodeIndex].outputRect(output: output.portIndex, layout: layout)
            strokeWire(from: outputRect.center, to: outputRect.center + offset, cx: cx)
        }
    }

    func drawSelectionRect(cx: GraphicsContext) {
        if case let .selection(rect: rect) = dragInfo {
            let rectPath = Path(roundedRect: rect, cornerRadius: 0)
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
