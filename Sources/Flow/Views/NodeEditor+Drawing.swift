// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

extension GraphicsContext {
    @inlinable @inline(__always)
    func drawDot(in rect: CGRect, with shading: Shading) {
        let dot = Path(ellipseIn: rect.insetBy(dx: rect.size.width / 3, dy: rect.size.height / 3))
        self.fill(dot, with: shading)
    }

    func drawInputPort(
        node: Node,
        index: Int,
        layout: LayoutConstants,
        offset: CGSize,
        portColor: Color,
        isConnected: Bool
    ) {
        let rect = node.inputRect(input: index, layout: layout).offset(by: offset)
        let circle = Path(ellipseIn: rect)
        let port = node.inputs[index]

        self.fill(circle, with: .color(portColor))

        if !isConnected {
            self.drawDot(in: rect, with: .color(.black))
        }

        self.draw(
            Text(port.name).font(.caption),
            at: rect.center + CGSize(width: layout.portSize.width / 2 + layout.portSpacing, height: 0),
            anchor: .leading
        )
    }

    func strokeWire(
        from: CGPoint,
        to: CGPoint,
        gradient: Gradient
    ) {
        let d = 0.4 * abs(to.x - from.x)
        var path = Path()
        path.move(to: from)
        path.addCurve(
            to: to,
            control1: CGPoint(x: from.x + d, y: from.y),
            control2: CGPoint(x: to.x - d, y: to.y)
        )

        self.stroke(
            path,
            with: .linearGradient(gradient, startPoint: from, endPoint: to),
            style: StrokeStyle(lineWidth: 2.0, lineCap: .round)
        )
    }

    func drawOutputPort(
        node: Node,
        index: Int,
        layout: LayoutConstants,
        offset: CGSize,
        portColor: Color,
        isConnected: Bool
    ) {
        let rect = node.outputRect(output: index, layout: layout).offset(by: offset)
        let circle = Path(ellipseIn: rect)
        let port = node.outputs[index]

        self.fill(circle, with: .color(portColor))

        if !isConnected {
            self.drawDot(in: rect, with: .color(.black))
        }

        self.draw(
            Text(port.name).font(.caption),
            at: rect.center + CGSize(width: -(layout.portSize.width / 2 + layout.portSpacing), height: 0),
            anchor: .trailing
        )
    }
}

extension NodeEditor {
    @inlinable @inline(__always)
    func color(for type: PortType, isOutput: Bool) -> Color {
        self.style.color(for: type, isOutput: isOutput) ?? .gray
    }

    /// Draw a node.
    func draw(
        node: Node,
        nodeIndex: NodeIndex,
        cx: GraphicsContext,
        viewport: CGRect
    ) {
        let offset = self.offset(for: nodeIndex)
        let rect = node.rect(layout: layout).offset(by: offset)

        guard rect.intersects(viewport) else { return }

        let pos = rect.origin

        let bg = Path(roundedRect: rect, cornerRadius: 5)

        var selected = false
        switch dragInfo {
        case let .selection(rect: selectionRect):
            selected = rect.intersects(selectionRect)
        default:
            selected = selection.contains(nodeIndex)
        }

        cx.fill(bg, with: .color(style.nodeColor.opacity(selected ? 0.8 : 0.4)))

        cx.draw(Text(node.name),
                at: pos + CGSize(width: rect.size.width / 2, height: 20),
                anchor: .center)

        for (i, input) in node.inputs.enumerated() {
            let portColor = self.color(for: input.type, isOutput: false)

            cx.drawInputPort(
                node: node,
                index: i,
                layout: layout,
                offset: offset,
                portColor: portColor,
                isConnected: patch.isInputWireConnected(node: node, index: i)
            )
        }

        for (i, output) in node.outputs.enumerated() {
            let portColor = self.color(for: output.type, isOutput: true)

            cx.drawOutputPort(
                node: node,
                index: i,
                layout: layout,
                offset: offset,
                portColor: portColor,
                isConnected: patch.isOutputWireConnected(node: node, index: i)
            )
        }
    }

    func drawNodes(cx: GraphicsContext, viewport: CGRect) {
        for (idx, node) in patch.nodes.enumerated() {
            draw(node: node, nodeIndex: idx, cx: cx, viewport: viewport)
        }
    }

    func drawWires(cx: GraphicsContext, viewport: CGRect) {
        var hideWire: Wire?
        switch self.dragInfo {
        case let .wire(_, _, hideWire: hw):
            hideWire = hw
        default:
            hideWire = nil
        }
        for wire in self.patch.wires where wire != hideWire {
            let fromPoint = patch.nodes[wire.output.nodeIndex].outputRect(
                output: wire.output.portIndex,
                layout: self.layout
            )
            .offset(by: offset(for: wire.output.nodeIndex)).center
            let toPoint = patch.nodes[wire.input.nodeIndex].inputRect(
                input: wire.input.portIndex,
                layout: self.layout
            )
            .offset(by: offset(for: wire.input.nodeIndex)).center

            let bounds = CGRect(origin: fromPoint, size: toPoint - fromPoint)
            if viewport.intersects(bounds) {
                let gradient = gradient(for: wire)
                cx.strokeWire(from: fromPoint, to: toPoint, gradient: gradient)
            }
        }
    }

    func drawDraggedWire(cx: GraphicsContext) {
        if case let .wire(output: output, offset: offset, _) = dragInfo {
            let outputRect = patch
                .nodes[output.nodeIndex]
                .outputRect(output: output.portIndex, layout: layout)
            let gradient = gradient(for: output)
            cx.strokeWire(from: outputRect.center, to: outputRect.center + offset, gradient: gradient)
        }
    }

    func drawSelectionRect(cx: GraphicsContext) {
        if case let .selection(rect: rect) = dragInfo {
            let rectPath = Path(roundedRect: rect, cornerRadius: 0)
            cx.stroke(rectPath, with: .color(.cyan))
        }
    }
    
    func gradient(for outputID: OutputID) -> Gradient {
        let portType = patch
            .nodes[outputID.nodeIndex]
            .outputs[outputID.portIndex]
            .type
        return style.gradient(for: portType) ?? .init(colors: [.gray])
    }
    
    func gradient(for wire: Wire) -> Gradient {
        gradient(for: wire.output)
    }
}
