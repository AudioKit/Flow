import SwiftUI

extension PatchView {
    /// State for all gestures.
    struct DragInfo {
        var output: PortIndex? = nil
        var origin: NodeIndex = 0
        var offset: CGSize = .zero
        var selectionRect: CGRect = .zero
        var hideWire: Wire?
    }

    /// Adds a new wire to the patch, ensuring that multiple wires aren't connected to an input.
    func connect(_ output: PortID, to input: PortID) {
        let wire = Wire(from: output, to: input)

        // Remove any other wires connected to the input.
        patch.wires = patch.wires.filter { w in
            w.input != wire.input
        }
        patch.wires.insert(wire)
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragInfo) { drag, state, _ in

                if let output = findOutput(point: drag.startLocation) {
                    state = DragInfo(output: output.portIndex, origin: output.nodeIndex, offset: drag.translation)
                } else if let input = findInput(point: drag.startLocation) {
                    // Is a wire attached to the input?
                    if let wire = patch.wires.first(where: { $0.input == input }) {
                        let offset = inputRect(node: patch.nodes[input.nodeIndex], input: input.portIndex).center
                        - outputRect(node: patch.nodes[wire.output.nodeIndex], output: wire.output.portIndex).center
                            + drag.translation
                        state = DragInfo(output: wire.output.portIndex, origin: wire.output.nodeIndex, offset: offset, hideWire: wire)
                    }
                } else if let nodeIndex = findNode(point: drag.startLocation) {
                    state = DragInfo(origin: nodeIndex, offset: drag.translation)
                } else {
                    state = DragInfo(selectionRect: CGRect(origin: drag.startLocation, size: drag.translation))
                }
            }
            .onEnded { drag in

                if let output = findOutput(point: drag.startLocation) {
                    if let input = findInput(point: drag.location) {
                        connect(output, to: input)
                    }
                } else if let input = findInput(point: drag.startLocation) {
                    // Is a wire attached to the input?
                    if let wire = patch.wires.first(where: { $0.input == input }) {
                        patch.wires.remove(wire)
                        if let input = findInput(point: drag.location) {
                            connect(wire.output, to: input)
                        }
                    }
                } else if let nodeIndex = findNode(point: drag.startLocation) {
                    patch.nodes[nodeIndex].position += drag.translation
                    for idx in selection where idx != nodeIndex {
                        patch.nodes[idx].position += drag.translation
                    }
                } else {
                    selection = Set<NodeIndex>()
                    let selectionRect = CGRect(origin: drag.startLocation, size: drag.translation)
                    for (idx, node) in patch.nodes.enumerated() {
                        if selectionRect.intersects(rect(node: node)) {
                            selection.insert(idx)
                        }
                    }
                }
            }
    }
}
