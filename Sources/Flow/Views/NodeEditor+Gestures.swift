// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

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
        self.patch.wires = self.patch.wires.filter { w in
            let result = w.input != wire.input
            if !result {
                self.wireRemoved(w)
            }
            return result
        }
        self.patch.wires.insert(wire)
        self.wireAdded(wire)
    }

    func attachedWire(inputID: InputID) -> Wire? {
        self.patch.wires.first(where: { $0.input == inputID })
    }

    func toLocal(_ p: CGPoint) -> CGPoint {
        CGPoint(x: p.x / CGFloat(self.zoom), y: p.y / CGFloat(self.zoom)) - self.pan
    }

    func toLocal(_ sz: CGSize) -> CGSize {
        CGSize(width: sz.width / CGFloat(self.zoom), height: sz.height / CGFloat(self.zoom))
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating(self.$dragInfo) { drag, dragInfo, _ in

                let startLocation = toLocal(drag.startLocation)
                let location = toLocal(drag.location)
                let translation = toLocal(drag.translation)

                switch self.patch.hitTest(point: startLocation, layout: self.layout) {
                case .none:
                    dragInfo = .selection(rect: CGRect(a: startLocation, b: location))

                case let .node(nodeIndex):
                    dragInfo = .node(index: nodeIndex, offset: translation)

                case let .output(nodeIndex, portIndex):
                    dragInfo = .wire(output: OutputID(nodeIndex, portIndex), offset: translation)

                case let .input(nodeIndex, portIndex):
                    let node = self.patch.nodes[nodeIndex]
                    // Is a wire attached to the input?
                    if let attachedWire = self.attachedWire(inputID: InputID(nodeIndex, portIndex)) {
                        let offset = node.inputRect(input: portIndex, layout: self.layout).center
                        - self.patch.nodes[attachedWire.output.nodeIndex].outputRect(
                                output: attachedWire.output.portIndex,
                                layout: self.layout
                            ).center
                            + translation
                        dragInfo = .wire(
                            output: attachedWire.output,
                            offset: offset,
                            hideWire: attachedWire
                        )
                    }
                }
            }
            .onEnded { drag in

                let startLocation = self.toLocal(drag.startLocation)
                let location = self.toLocal(drag.location)
                let translation = self.toLocal(drag.translation)

                let hitResult = self.patch.hitTest(point: startLocation, layout: self.layout)

                // Note that this threshold should be in screen coordinates.
                if drag.distance > 5 {
                    switch hitResult {
                    case .none:
                        let selectionRect = CGRect(a: startLocation, b: location)
                        selection = self.patch.selected(
                            in: selectionRect,
                            layout: self.layout
                        )
                    case let .node(nodeIndex):
                        self.patch.moveNode(
                            nodeIndex: nodeIndex,
                            offset: translation,
                            nodeMoved: self.nodeMoved
                        )
                        if self.selection.contains(nodeIndex) {
                            for idx in self.selection where idx != nodeIndex {
                                self.patch.moveNode(
                                    nodeIndex: idx,
                                    offset: translation,
                                    nodeMoved: self.nodeMoved
                                )
                            }
                        }
                    case let .output(nodeIndex, portIndex):
                        if let input = findInput(point: location) {
                            self.connect(OutputID(nodeIndex, portIndex), to: input)
                        }
                    case let .input(nodeIndex, portIndex):
                        // Is a wire attached to the input?
                        if let attachedWire = self.attachedWire(inputID: InputID(nodeIndex, portIndex)) {
                            self.patch.wires.remove(attachedWire)
                            wireRemoved(attachedWire)
                            if let input = self.findInput(point: location) {
                                self.connect(attachedWire.output, to: input)
                            }
                        }
                    }
                } else {
                    // If we haven't moved far, then this is effectively a tap.
                    switch hitResult {
                    case .none:
                        self.selection = Set<NodeIndex>()
                    case let .node(nodeIndex):
                        self.selection = Set<NodeIndex>([nodeIndex])
                    default: break;
                    }
                }

            }
    }
}

extension DragGesture.Value {
    @inlinable @inline(__always)
    var distance: CGFloat {
        self.startLocation.distance(to: self.location)
    }
}
