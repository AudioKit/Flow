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
    func add(wire: Wire) {
        // Remove any other wires connected to the input.
        patch.wires = patch.wires.filter { w in
            w.input != wire.input
        }
        patch.wires.insert(wire)
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragInfo) { value, state, _ in

                if let output = findOutput(point: value.startLocation) {
                    state = DragInfo(output: output.portIndex, origin: output.nodeIndex, offset: value.translation)
                } else if let input = findInput(point: value.startLocation) {
                    // Is a wire attached to the input?
                    if let wire = patch.wires.first(where: { $0.input == input }) {
                        let offset = inputRect(node: patch.nodes[input.nodeIndex], input: input.portIndex).center
                        - outputRect(node: patch.nodes[wire.output.nodeIndex], output: wire.output.portIndex).center
                            + value.translation
                        state = DragInfo(output: wire.output.nodeIndex, origin: wire.output.nodeIndex, offset: offset, hideWire: wire)
                    }
                } else if let nodeIndex = findNode(point: value.startLocation) {
                    state = DragInfo(origin: nodeIndex, offset: value.translation)
                } else {
                    state = DragInfo(selectionRect: CGRect(origin: value.startLocation, size: value.translation))
                }
            }
            .onEnded { value in

                if let output = findOutput(point: value.startLocation) {
                    if let input = findInput(point: value.location) {
                        print(output, input)
                        add(wire: Wire(from: output, to: input))
                    }
                } else if let input = findInput(point: value.startLocation) {
                    // Is a wire attached to the input?
                    if let wire = patch.wires.first(where: { $0.input == input }) {
                        patch.wires.remove(wire)
                        if let input = findInput(point: value.location) {
                            add(wire: Wire(from: wire.output, to: input))
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
