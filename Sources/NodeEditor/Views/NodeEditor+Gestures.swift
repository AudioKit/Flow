import SwiftUI

extension NodeEditor {
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

                switch patch.hitTest(point: drag.startLocation, layout: layout) {
                case .background:
                    dragInfo = .selection(rect: CGRect(a: drag.startLocation,
                                                       b: drag.location))
                case .node(let nodeIndex):
                    dragInfo = .node(index: nodeIndex, offset: drag.translation)
                case .output(let nodeIndex, let portIndex):
                    dragInfo = DragInfo.wire(output: OutputID(nodeIndex, portIndex), offset: drag.translation)
                case .input(let nodeIndex, let portIndex):
                    let node = patch.nodes[nodeIndex]
                    // Is a wire attached to the input?
                    if let attachedWire = attachedWire(inputID: InputID(nodeIndex, portIndex)) {
                        let offset = node.inputRect(input: portIndex, layout: layout).center
                        - patch.nodes[attachedWire.output.nodeIndex].outputRect(
                                     output: attachedWire.output.portIndex,
                                     layout: layout).center
                        + drag.translation
                        dragInfo = .wire(output: attachedWire.output,
                                         offset: offset,
                                         hideWire: attachedWire)
                    }
                }

            }
            .onEnded { drag in

                switch patch.hitTest(point: drag.startLocation, layout: layout) {
                case .background:
                    selection = Set<NodeIndex>()
                    let selectionRect = CGRect(a: drag.startLocation,
                                               b: drag.location)
                    for (idx, node) in patch.nodes.enumerated() {
                        if selectionRect.intersects(node.rect(layout: layout)) {
                            selection.insert(idx)
                        }
                    }
                case .node(let nodeIndex):
                    patch.nodes[nodeIndex].position += drag.translation
                    if selection.contains(nodeIndex) {
                        for idx in selection where idx != nodeIndex {
                            patch.nodes[idx].position += drag.translation
                        }
                    }
                case .output(let nodeIndex, let portIndex):
                    if let input = findInput(point: drag.location) {
                        connect(OutputID(nodeIndex, portIndex), to: input)
                    }
                case .input(let nodeIndex, let portIndex):
                    // Is a wire attached to the input?
                    if let attachedWire = attachedWire(inputID: InputID(nodeIndex, portIndex)) {
                        patch.wires.remove(attachedWire)
                        if let input = findInput(point: drag.location) {
                            connect(attachedWire.output, to: input)
                        }
                    }
                }

            }
    }
}
