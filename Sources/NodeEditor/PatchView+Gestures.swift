import SwiftUI

extension PatchView {
    /// State for all gestures.
    struct DragInfo {
        var output: OutputID? = nil
        var origin: NodeIndex = 0
        var offset: CGSize = .zero
        var selectionRect: CGRect = .zero
        var hideWire: Wire?
    }

    /// Adds a new wire to the patch, ensuring that multiple wires aren't connected to an input.
    func connect(_ output: OutputID, to input: InputID) {
        let wire = Wire(from: output, to: input)

        // Remove any other wires connected to the input.
        patch.wires = patch.wires.filter { w in
            w.input != wire.input
        }
        patch.wires.insert(wire)
    }

    func attachedWire(inputID: InputID) -> Wire? {
        patch.wires.first(where: { $0.input == inputID })
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($dragInfo) { drag, dragInfo, _ in

                if let output = findOutput(point: drag.startLocation) {
                    dragInfo = DragInfo(output: output,
                                        origin: output.nodeIndex,
                                        offset: drag.translation)
                } else if let input = findInput(point: drag.startLocation) {
                    // Is a wire attached to the input?
                    if let attachedWire = attachedWire(inputID: input) {
                        let offset = inputRect(node: patch.nodes[input.nodeIndex],
                                               input: input.portIndex).center
                        - outputRect(node: patch.nodes[attachedWire.output.nodeIndex],
                                     output: attachedWire.output.portIndex).center
                        + drag.translation
                        dragInfo = DragInfo(output: attachedWire.output,
                                            origin: attachedWire.output.nodeIndex,
                                            offset: offset,
                                            hideWire: attachedWire)
                    }
                } else if let nodeIndex = findNode(point: drag.startLocation) {
                    dragInfo = DragInfo(origin: nodeIndex, offset: drag.translation)
                } else {
                    dragInfo = DragInfo(selectionRect: CGRect(origin: drag.startLocation,
                                                              size: drag.translation))
                }
            }
            .onEnded { drag in

                if let output = findOutput(point: drag.startLocation) {
                    if let input = findInput(point: drag.location) {
                        connect(output, to: input)
                    }
                } else if let input = findInput(point: drag.startLocation) {
                    // Is a wire attached to the input?
                    if let attachedWire = attachedWire(inputID: input) {
                        patch.wires.remove(attachedWire)
                        if let input = findInput(point: drag.location) {
                            connect(attachedWire.output, to: input)
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
