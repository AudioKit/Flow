// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

extension NodeEditor {
    /// Configuration used to determine rendering style of a ``NodeEditor`` instance.
    public struct Style {
        /// Color used for rendering nodes.
        public var nodeColor: Color = .init(white: 0.3)
        
        /// Color used for rendering control wires.
        public var controlWire: WireStyle = .init()
        
        /// Color used for rendering signal wires.
        public var signalWire: WireStyle = .init()
        
        /// Colors used for rendering custom wires.
        /// Dictionary is keyed by the custom wire name.
        public var customWires: [String: WireStyle] = [:]
        
        /// Returns input or output port color for the specified port type.
        public func color(for portType: PortType, isOutput: Bool) -> Color? {
            switch portType {
            case .control:
                return isOutput ? controlWire.outputColor : controlWire.inputColor
            case .signal:
                return isOutput ? signalWire.outputColor : signalWire.inputColor
            case .custom(let id):
                return isOutput ? customWires[id]?.outputColor : customWires[id]?.inputColor
            }
        }
        
        /// Returns port gradient for the specified port type.
        public func gradient(for portType: PortType) -> Gradient? {
            switch portType {
            case .control:
                return controlWire.gradient
            case .signal:
                return signalWire.gradient
            case .custom(let id):
                return customWires[id]?.gradient
            }
        }
    }
}

extension NodeEditor.Style {
    /// Configuration used to determine rendering style of a ``NodeEditor`` wire type.
    public struct WireStyle {
        public var inputColor: Color = .cyan
        public var outputColor: Color = .magenta
        
        /// Get or set the input and output colors as a `Gradient`.
        /// Only the first and last stops will be used.
        public var gradient: Gradient {
            get {
                Gradient(colors: [outputColor, inputColor])
            }
            set {
                if let inputColor = newValue.stops.last?.color {
                    self.inputColor = inputColor
                }
                if let outputColor = newValue.stops.first?.color{
                    self.outputColor = outputColor
                }
            }
        }
    }
}
