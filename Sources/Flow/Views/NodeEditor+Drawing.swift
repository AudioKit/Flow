// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

extension GraphicsContext {
    @inlinable @inline(__always)
    func drawDot(in rect: CGRect, with shading: Shading) {
        let dot = Path(ellipseIn: rect.insetBy(dx: rect.size.width / 3, dy: rect.size.height / 3))
        fill(dot, with: shading)
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

        stroke(
            path,
            with: .linearGradient(gradient, startPoint: from, endPoint: to),
            style: StrokeStyle(lineWidth: 2.0, lineCap: .round)
        )
    }
}

extension NodeEditor {
    @inlinable @inline(__always)
    func color(for type: PortType, isOutput: Bool) -> Color {
        style.color(for: type, isOutput: isOutput) ?? .gray
    }
    
    func drawInputPort(
        cx: GraphicsContext,
        node: Node,
        index: Int,
        offset: CGSize,
        portShading: GraphicsContext.Shading,
        isConnected: Bool
    ) {
        let rect = node.inputRect(input: index, layout: layout).offset(by: offset)
        let circle = Path(ellipseIn: rect)
        let port = node.inputs[index]

        cx.fill(circle, with: portShading)

        if !isConnected {
            cx.drawDot(in: rect, with: .color(.black))
        } else if rect.contains(toLocal(mousePosition)) {
            cx.stroke(circle, with: .color(.white), style: .init(lineWidth: 1.0))
        }

        cx.draw(
            textCache.text(string: port.name, font: layout.portNameFont, cx),
            at: rect.center + CGSize(width: layout.portSize.width / 2 + layout.portSpacing, height: 0),
            anchor: .leading
        )
    }
    
    func drawOutputPort(
        cx: GraphicsContext,
        node: Node,
        index: Int,
        offset: CGSize,
        portShading: GraphicsContext.Shading,
        isConnected: Bool
    ) {
        let rect = node.outputRect(output: index, layout: layout).offset(by: offset)
        let circle = Path(ellipseIn: rect)
        let port = node.outputs[index]

        cx.fill(circle, with: portShading)

        if !isConnected {
            cx.drawDot(in: rect, with: .color(.black))
        }
        
        if rect.contains(toLocal(mousePosition)) {
            cx.stroke(circle, with: .color(.white), style: .init(lineWidth: 1.0))
        }

        cx.draw(textCache.text(string: port.name, font: layout.portNameFont, cx),
             at: rect.center + CGSize(width: -(layout.portSize.width / 2 + layout.portSpacing), height: 0),
             anchor: .trailing)
    }

    func inputShading(_ type: PortType,  _ colors: inout [PortType: GraphicsContext.Shading], _ cx: GraphicsContext) -> GraphicsContext.Shading {
        if let shading = colors[type] {
            return shading
        }
        let shading = cx.resolve(.color(color(for: type, isOutput: false)))
        colors[type] = shading
        return shading
    }

    func outputShading(_ type: PortType,  _ colors: inout [PortType: GraphicsContext.Shading], _ cx: GraphicsContext) -> GraphicsContext.Shading {
        if let shading = colors[type] {
            return shading
        }
        let shading = cx.resolve(.color(color(for: type, isOutput: true)))
        colors[type] = shading
        return shading
    }

    func drawNodes(cx: GraphicsContext, viewport: CGRect) {

        let connectedInputs = Set( patch.wires.map { wire in wire.input } )
        let connectedOutputs = Set( patch.wires.map { wire in wire.output } )

        let selectedShading = cx.resolve(.color(style.nodeColor.opacity(0.8)))
        let unselectedShading = cx.resolve(.color(style.nodeColor.opacity(0.4)))

        var resolvedInputColors = [PortType: GraphicsContext.Shading]()
        var resolvedOutputColors = [PortType: GraphicsContext.Shading]()

        for (nodeIndex, node) in patch.nodes.enumerated() {
            let offset = self.offset(for: nodeIndex)
            let rect = node.rect(layout: layout).offset(by: offset)

            guard rect.intersects(viewport) else { continue }

            let pos = rect.origin

            let cornerRadius = layout.nodeCornerRadius
            let bg = Path(roundedRect: rect, cornerRadius: cornerRadius)

            var selected = false
            switch dragInfo {
            case let .selection(rect: selectionRect):
                selected = rect.intersects(selectionRect)
            default:
                selected = selection.contains(nodeIndex)
            }

            cx.fill(bg, with: selected ? selectedShading : unselectedShading)
            
            // Draw the title bar for the node. There seems to be
            // no better cross-platform way to render a rectangle with the top
            // two cornders rounded.
            var titleBar = Path()
            titleBar.move(to: CGPoint(x: 0, y: layout.nodeTitleHeight) + rect.origin.size)
            titleBar.addLine(to: CGPoint(x: 0, y: cornerRadius) + rect.origin.size)
            titleBar.addRelativeArc(center: CGPoint(x: cornerRadius, y: cornerRadius) + rect.origin.size,
                                    radius: cornerRadius,
                                    startAngle: .degrees(180),
                                    delta: .degrees(90))
            titleBar.addLine(to: CGPoint(x: layout.nodeWidth - cornerRadius, y: 0) + rect.origin.size)
            titleBar.addRelativeArc(center: CGPoint(x: layout.nodeWidth - cornerRadius, y: cornerRadius) + rect.origin.size,
                                    radius: cornerRadius,
                                    startAngle: .degrees(270),
                                    delta: .degrees(90))
            titleBar.addLine(to: CGPoint(x: layout.nodeWidth, y: layout.nodeTitleHeight) + rect.origin.size)
            titleBar.closeSubpath()
            
            cx.fill(titleBar, with: .color(node.titleBarColor))
            
            if rect.contains(toLocal(mousePosition)) {
                cx.stroke(bg, with: .color(.white), style: .init(lineWidth: 1.0))
            }

            cx.draw(textCache.text(string: node.name, font: layout.nodeTitleFont, cx),
                    at: pos + CGSize(width: rect.size.width / 2, height: layout.nodeTitleHeight / 2),
                    anchor: .center)

            for (i, input) in node.inputs.enumerated() {
                drawInputPort(
                    cx: cx,
                    node: node,
                    index: i,
                    offset: offset,
                    portShading: inputShading(input.type, &resolvedInputColors, cx),
                    isConnected: connectedInputs.contains(InputID(nodeIndex, i))
                )
            }

            for (i, output) in node.outputs.enumerated() {
                drawOutputPort(
                    cx: cx,
                    node: node,
                    index: i,
                    offset: offset,
                    portShading: outputShading(output.type, &resolvedOutputColors, cx),
                    isConnected: connectedOutputs.contains(OutputID(nodeIndex, i))
                )
            }
        }
    }

    func drawWires(cx: GraphicsContext, viewport: CGRect) {
        var hideWire: Wire?
        switch dragInfo {
        case let .wire(_, _, hideWire: hw):
            hideWire = hw
        default:
            hideWire = nil
        }
        for wire in patch.wires where wire != hideWire {
            let fromPoint = self.patch.nodes[wire.output.nodeIndex].outputRect(
                output: wire.output.portIndex,
                layout: self.layout
            )
            .offset(by: self.offset(for: wire.output.nodeIndex)).center

            let toPoint = self.patch.nodes[wire.input.nodeIndex].inputRect(
                input: wire.input.portIndex,
                layout: self.layout
            )
            .offset(by: self.offset(for: wire.input.nodeIndex)).center

            let bounds = CGRect(origin: fromPoint, size: toPoint - fromPoint)
            if viewport.intersects(bounds) {
                let gradient = self.gradient(for: wire)
                cx.strokeWire(from: fromPoint, to: toPoint, gradient: gradient)
            }
        }
    }

    func drawDraggedWire(cx: GraphicsContext) {
        if case let .wire(output: output, offset: offset, _) = dragInfo {
            let outputRect = self.patch
                .nodes[output.nodeIndex]
                .outputRect(output: output.portIndex, layout: self.layout)
            let gradient = self.gradient(for: output)
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
