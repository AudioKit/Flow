import SwiftUI

extension PatchView {
    /// State for all gestures.
    struct DragInfo {
        var output: PortIndex? = nil
        var node: NodeIndex = 0
        var offset: CGSize = .zero
        var selectionRect: CGRect = .zero
        var hideWire: Wire?
    }

    /// Adds a new wire to the patch, ensuring that multiple wires aren't connected to an input.
    func add(wire: Wire) {
        // Remove any other wires connected to the input.
        patch.wires = patch.wires.filter { w in
            (w.destinationNode, w.inputPort) != (wire.destinationNode, wire.inputPort)
        }
        patch.wires.insert(wire)
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragInfo) { value, state, _ in

                if let (nodeIndex, portIndex) = findOutput(point: value.startLocation) {
                    state = DragInfo(output: portIndex, node: nodeIndex, offset: value.translation)
                } else if let (nodeIndex, inputIndex) = findInput(point: value.startLocation) {
                    // Is a wire attached to the input?
                    if let wire = patch.wires.first(where: { ($0.destinationNode, $0.inputPort) == (nodeIndex, inputIndex) }) {
                        let offset = inputRect(node: patch.nodes[nodeIndex], input: inputIndex).center
                        - outputRect(node: patch.nodes[wire.originNode], output: wire.outputPort).center
                        + value.translation
                        state = DragInfo(output: wire.outputPort, node: wire.originNode, offset: offset, hideWire: wire)
                    }
                } else if let nodeIndex = findNode(point: value.startLocation) {
                    state = DragInfo(node: nodeIndex, offset: value.translation)
                } else {
                    state = DragInfo(selectionRect: CGRect(origin: value.startLocation, size: value.translation))
                }

            }
            .onEnded { value in

                if let (nodeIndex, outputIndex) = findOutput(point: value.startLocation) {
                    if let (destinationIndex, inputIndex) = findInput(point: value.location) {
                        add(wire: Wire(from: nodeIndex,
                                       output: outputIndex,
                                       to: destinationIndex,
                                       input: inputIndex))
                    }
                } else if let (nodeIndex, inputIndex) = findInput(point: value.startLocation) {
                    // Is a wire attached to the input?
                    if let wire = patch.wires.first(where: { ($0.destinationNode, $0.inputPort) == (nodeIndex, inputIndex) }) {
                        patch.wires.remove(wire)
                        if let (destinationIndex, inputIndex) = findInput(point: value.location) {
                            add(wire: Wire(from: wire.originNode,
                                           output: wire.outputPort,
                                           to: destinationIndex,
                                           input: inputIndex))
                        }
                    }
                } else if let nodeIndex = findNode(point: value.startLocation) {
                    patch.nodes[nodeIndex].position += value.translation
                    for id in selection where id != nodeIndex {
                        patch.nodes[id].position += value.translation
                    }
                } else {
                    selection = Set<NodeIndex>()
                    let selectionRect = CGRect(origin: value.startLocation, size: value.translation)
                    for (idx, node) in patch.nodes.enumerated() {
                        if selectionRect.intersects(rect(node: node)) {
                            selection.insert(idx)
                        }
                    }
                }
            }
    }
}
