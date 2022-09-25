// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

public protocol PatchDelegate {
    /// Called when a node is moved.
    func nodeMoved(index: NodeIndex, location: CGPoint)

    /// Called when a wire is added.
    func wireAdded(wire: Wire)

    /// Wire removed handler closure.
    func wireRemoved(wire: Wire)
}

/// Data model for Flow.
///
/// Write a function to generate a `Patch` from your own data model
/// as well as a function to update your data model when the `Patch` changes.
/// Use SwiftUI's `onChange(of:)` to monitor changes.
public final class Patch: ObservableObject {
    @Published public var nodes: [Node]
    @Published public var wires: Set<Wire>

    @Published var selection: Set<NodeIndex>

    public var delegate: PatchDelegate?

    public init(nodes: [Node], wires: Set<Wire>) {
        self.nodes = nodes
        self.wires = wires
        self.selection = []
    }

    enum HitTestResult {
        case node(NodeIndex)
        case input(NodeIndex, PortIndex)
        case output(NodeIndex, PortIndex)
    }

    /// Search for inputs.
    func findInput(
        node: Node,
        point: CGPoint,
        layout: LayoutConstants
    ) -> PortIndex? {
        node.inputs.enumerated().first { portIndex, _ in
            node.inputRect(input: portIndex, layout: layout).contains(point)
        }?.0
    }

    /// Search for an input in the whole patch.
    func findInput(
        point: CGPoint,
        layout: LayoutConstants
    ) -> InputID? {
        // Search nodes in reverse to find nodes drawn on top first.
        for (nodeIndex, node) in self.nodes.enumerated().reversed() {
            if let portIndex = self.findInput(node: node, point: point, layout: layout) {
                return InputID(nodeIndex, portIndex)
            }
        }
        return nil
    }

    /// Search for outputs.
    func findOutput(
        node: Node,
        point: CGPoint,
        layout: LayoutConstants
    ) -> PortIndex? {
        node.outputs.enumerated().first { portIndex, _ in
            node.outputRect(output: portIndex, layout: layout).contains(point)
        }?.0
    }

    /// Search for an output in the whole patch.
    func findOutput(point: CGPoint, layout: LayoutConstants)  -> OutputID? {
        // Search nodes in reverse to find nodes drawn on top first.
        for (nodeIndex, node) in self.nodes.enumerated().reversed() {
            if let portIndex = self.findOutput(node: node, point: point, layout: layout) {
                return OutputID(nodeIndex, portIndex)
            }
        }
        return nil
    }

//    func findNode(point: CGPoint, layout: LayoutConstants) -> NodeIndex? {
//        // Search nodes in reverse to find nodes drawn on top first.
//        self.nodes.enumerated().reversed().first { _, node in
//            node.rect(layout: layout).contains(point)
//        }?.0
//    }

    /// Hit test a point against the whole patch.
    func hitTest(
        point: CGPoint,
        layout: LayoutConstants
    ) -> HitTestResult? {
        for (nodeIndex, node) in self.nodes.enumerated().reversed() {
            if let result = node.hitTest(nodeIndex: nodeIndex, point: point, layout: layout) {
                return result
            }
        }

        return nil
    }

    func attachedWire(inputID: InputID) -> Wire? {
        self.wires.first(where: { $0.input == inputID })
    }

    /// Adds a new wire to the patch, ensuring that multiple wires aren't connected to an input.
    func connect(
        _ output: OutputID,
        to input: InputID
    ) {
        let wire = Wire(from: output, to: input)

        // Remove any other wires connected to the input.
        self.wires = self.wires.filter { w in
            let result = w.input != wire.input
            if !result {
                self.delegate?.wireRemoved(wire: w)
            }
            return result
        }
        self.wires.insert(wire)
        self.delegate?.wireAdded(wire: wire)
    }

    func moveNode(
        nodeIndex: NodeIndex,
        offset: CGSize
    ) {
        if !self.nodes[nodeIndex].locked {
            self.nodes[nodeIndex].position += offset
            let pos = self.nodes[nodeIndex].position
            self.delegate?.nodeMoved(index: nodeIndex, location: pos)
        }
    }

    func moveNode2(
        nodeIndex: NodeIndex,
        translation: CGSize
//        nodeMoved: NodeEditor.NodeMovedHandler
    ) {
        self.moveNode(
            nodeIndex: nodeIndex,
            offset: translation
//            nodeMoved: nodeMoved
        )
        if self.selection.contains(nodeIndex) {
            for idx in self.selection where idx != nodeIndex {
                self.moveNode(
                    nodeIndex: idx,
                    offset: translation
                )
            }
        }
    }

    func dragUpdated(
        startLocation: CGPoint,
        location: CGPoint,
        translation: CGSize,
        layout: LayoutConstants
    ) -> NodeEditor.DragInfo? {
        if let result = self.hitTest(point: startLocation, layout: layout) {
            switch result {
            case let .node(nodeIndex):
                return .node(index: nodeIndex, offset: translation)

            case let .output(nodeIndex, portIndex):
                return .wire(output: OutputID(nodeIndex, portIndex), offset: translation)

            case let .input(nodeIndex, portIndex):
                let node = self.nodes[nodeIndex]
                // Is a wire attached to the input?
                if let attachedWire = self.attachedWire(inputID: InputID(nodeIndex, portIndex)) {
                    let offset = node.inputRect(input: portIndex, layout: layout).center
                    - self.nodes[attachedWire.output.nodeIndex].outputRect(
                        output: attachedWire.output.portIndex,
                        layout: layout
                    ).center + translation
                    return .wire(
                        output: attachedWire.output,
                        offset: offset,
                        hideWire: attachedWire
                    )
                }

            }

        } else {
            return .selection(rect: CGRect(a: startLocation, b: location))
        }

        return nil
    }
    

    func dragEnded(
        startLocation: CGPoint,
        location: CGPoint,
        translation: CGSize,
        layout: LayoutConstants
    ) {
        let hitResult = self.hitTest(point: startLocation, layout: layout)

        let distance = startLocation.distance(to: location)

        // Note that this threshold should be in screen coordinates.
        if distance > 5 {
            switch hitResult {
            case .none:
                let selectionRect = CGRect(a: startLocation, b: location)
                self.select(in: selectionRect, layout: layout)

            case let .node(nodeIndex):
                self.moveNode2(
                    nodeIndex: nodeIndex,
                    translation: translation
                )

            case let .output(nodeIndex, portIndex):
                if let input = self.findInput(point: location, layout: layout) {
                    self.connect(OutputID(nodeIndex, portIndex), to: input)
                }

            case let .input(nodeIndex, portIndex):
                // Is a wire attached to the input?
                if let attachedWire = self.attachedWire(inputID: InputID(nodeIndex, portIndex)) {
                    self.wires.remove(attachedWire)
                    self.delegate?.wireRemoved(wire: attachedWire)
                    if let input = self.findInput(point: location, layout: layout) {
                        self.connect(attachedWire.output, to: input)
                    }
                }
            }
        } else {
            // If we haven't moved far, then this is effectively a tap.
            switch hitResult {
            case .none:
                self.unselectAll()

            case let .node(nodeIndex):
                self.select(node: nodeIndex)

            default: break
            }
        }
    }

    func unselectAll() {
        self.selection.removeAll()
    }

    func select(node: NodeIndex) {
        self.selection.removeAll()
        self.selection.insert(node)
    }

    func selected(in rect: CGRect, layout: LayoutConstants) -> Set<NodeIndex> {
        var selection = Set<NodeIndex>()

        for (idx, node) in self.nodes.enumerated() {
            if rect.intersects(node.rect(layout: layout)) {
                selection.insert(idx)
            }
        }
        return selection
    }

    func select(in rect: CGRect, layout: LayoutConstants) {
        self.selection = self.selected(in: rect, layout: layout)
    }

    @inlinable @inline(__always)
    func isInputWireConnected(node: Node, index: Int) -> Bool {
        self.wires.contains(where: { $0.input == InputID(nodes.firstIndex(of: node)!, index) })
    }

    @inlinable @inline(__always)
    func isOutputWireConnected(node: Node, index: Int) -> Bool {
        self.wires.contains(where: { $0.output == OutputID(nodes.firstIndex(of: node)!, index) })
    }

    func incomingWires(for nodeIndex: NodeIndex) -> [Wire] {
        self.wires.filter {
            $0.input.nodeIndex == nodeIndex
        }.sorted(by: { $0.input.portIndex < $1.input.portIndex })
    }

    /// Recursive layout.
    ///
    /// - Returns: Height of all nodes in subtree.
    @discardableResult
    public func recursiveLayout(
        nodeIndex: NodeIndex,
        at point: CGPoint,
        layout: LayoutConstants = LayoutConstants(),
        consumedNodeIndexes: Set<NodeIndex> = [],
        nodePadding: Bool = false
    ) -> (
        aggregateHeight: CGFloat,
        consumedNodeIndexes: Set<NodeIndex>
    ) {

        self.nodes[nodeIndex].position = point

        // XXX: super slow
        let incomingWires = self.incomingWires(for: nodeIndex)
        
        var consumedNodeIndexes = consumedNodeIndexes
        
        var height: CGFloat = 0
        for wire in incomingWires {
            let addPadding = wire == incomingWires.last
            let ni = wire.output.nodeIndex
            guard !consumedNodeIndexes.contains(ni) else { continue }

            let rl = self.recursiveLayout(
                nodeIndex: ni,
                at: CGPoint(x: point.x - layout.nodeWidth - layout.nodeSpacing,
                            y: point.y + height),
                layout: layout,
                consumedNodeIndexes: consumedNodeIndexes,
                nodePadding: addPadding
            )

            height = rl.aggregateHeight
            consumedNodeIndexes.insert(ni)
            consumedNodeIndexes.formUnion(rl.consumedNodeIndexes)
        }

        let nodeHeight = self.nodes[nodeIndex].rect(layout: layout).height
        let aggregateHeight = max(height, nodeHeight) + (nodePadding ? layout.nodeSpacing : 0)

        return (aggregateHeight, consumedNodeIndexes)
    }
    
    /// Manual stacked grid layout.
    ///
    /// - Parameters:
    ///   - origin: Top-left origin coordinate.
    ///   - columns: Array of columns each comprised of an array of node indexes.
    ///   - layout: Layout constants.
    public func stackedLayout(
        at origin: CGPoint = .zero,
        _ columns: [[NodeIndex]],
        layout: LayoutConstants = LayoutConstants()
    ) {
        for column in columns.indices {
            let nodeStack = columns[column]
            var yOffset: CGFloat = 0
            
            let xPos = origin.x + (CGFloat(column) * (layout.nodeWidth + layout.nodeSpacing))
            for nodeIndex in nodeStack {
                self.nodes[nodeIndex].position = .init(
                    x: xPos,
                    y: origin.y + yOffset
                )
                
                let nodeHeight = self.nodes[nodeIndex].rect(layout: layout).height
                yOffset += nodeHeight
                if column != columns.indices.last {
                    yOffset += layout.nodeSpacing
                }
            }
        }
    }
}
