// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

// View Modifiers

public extension NodeEditor {
    // MARK: - Event Handlers

    /// Called when a node is moved.
    func onNodeMoved(_ handler: @escaping NodeMovedHandler) -> Self {
        var viewCopy = self
        viewCopy.nodeMoved = handler
        return viewCopy
    }

    /// Called when a wire is added.
    func onWireAdded(_ handler: @escaping WireAddedHandler) -> Self {
        var viewCopy = self
        viewCopy.wireAdded = handler
        return viewCopy
    }

    /// Called when a wire is removed.
    func onWireRemoved(_ handler: @escaping WireRemovedHandler) -> Self {
        var viewCopy = self
        viewCopy.wireRemoved = handler
        return viewCopy
    }
    
    /// Called when the viewing transform has changed.
    func onTransformChanged(_ handler: @escaping TransformChangedHandler) -> Self {
        var viewCopy = self
        viewCopy.transformChanged = handler
        return viewCopy
    }

    // MARK: - Style Modifiers

    /// Set the node color.
    func nodeColor(_ color: Color) -> Self {
        var viewCopy = self
        viewCopy.style.nodeColor = color
        return viewCopy
    }

    /// Set the port color for a port type.
    func portColor(for portType: PortType, _ color: Color) -> Self {
        var viewCopy = self

        switch portType {
        case .control:
            viewCopy.style.controlWire.inputColor = color
            viewCopy.style.controlWire.outputColor = color
        case .signal:
            viewCopy.style.signalWire.inputColor = color
            viewCopy.style.signalWire.outputColor = color
        case .midi:
            viewCopy.style.midiWire.inputColor = color
            viewCopy.style.midiWire.outputColor = color
        case let .custom(id):
            if viewCopy.style.customWires[id] == nil {
                viewCopy.style.customWires[id] = .init()
            }
            viewCopy.style.customWires[id]?.inputColor = color
            viewCopy.style.customWires[id]?.outputColor = color
        }

        return viewCopy
    }

    /// Set the port color for a port type to a gradient.
    func portColor(for portType: PortType, _ gradient: Gradient) -> Self {
        var viewCopy = self

        switch portType {
        case .control:
            viewCopy.style.controlWire.gradient = gradient
        case .signal:
            viewCopy.style.signalWire.gradient = gradient
        case .midi:
            viewCopy.style.midiWire.gradient = gradient
        case let .custom(id):
            if viewCopy.style.customWires[id] == nil {
                viewCopy.style.customWires[id] = .init()
            }
            viewCopy.style.customWires[id]?.gradient = gradient
        }

        return viewCopy
    }
}
