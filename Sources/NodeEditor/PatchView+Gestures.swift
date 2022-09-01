import SwiftUI

extension PatchView {
    /// State for all gestures.
    enum DragInfo {
        case wire(output: OutputID, offset: CGSize = .zero, hideWire: Wire? = nil)
        case node(index: NodeIndex, offset: CGSize = .zero)
        case selection(rect: CGRect = .zero)
        case none
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

                if let nodeIndex = findNode(point: drag.startLocation) {

                    let node = patch.nodes[nodeIndex]

                    if let output = findOutput(node: node, point: drag.startLocation) {
                        dragInfo = DragInfo.wire(output: OutputID(nodeIndex, output), offset: drag.translation)
                    } else if let input = findInput(node: node, point: drag.startLocation) {
                        // Is a wire attached to the input?
                        if let attachedWire = attachedWire(inputID: InputID(nodeIndex, input)) {
                            let offset = inputRect(node: node, input: input).center
                            - outputRect(node: patch.nodes[attachedWire.output.nodeIndex],
                                         output: attachedWire.output.portIndex).center
                            + drag.translation
                            dragInfo = .wire(output: attachedWire.output,
                                             offset: offset,
                                             hideWire: attachedWire)
                        }
                    } else {
                        dragInfo = .node(index: nodeIndex, offset: drag.translation)
                    }

                } else {
                    dragInfo = .selection(rect: CGRect(a: drag.startLocation,
                                                       b: drag.location))
                }
            }
            .onEnded { drag in

                if let nodeIndex = findNode(point: drag.startLocation) {

                    let node = patch.nodes[nodeIndex]

                    if let output = findOutput(node: node, point: drag.startLocation) {
                        if let input = findInput(point: drag.location) {
                            connect(OutputID(nodeIndex, output), to: input)
                        }
                    } else if let input = findInput(node: node, point: drag.startLocation) {
                        // Is a wire attached to the input?
                        if let attachedWire = attachedWire(inputID: InputID(nodeIndex, input)) {
                            patch.wires.remove(attachedWire)
                            if let input = findInput(point: drag.location) {
                                connect(attachedWire.output, to: input)
                            }
                        }
                    } else {
                        patch.nodes[nodeIndex].position += drag.translation
                        if selection.contains(nodeIndex) {
                            for idx in selection where idx != nodeIndex {
                                patch.nodes[idx].position += drag.translation
                            }
                        }
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
