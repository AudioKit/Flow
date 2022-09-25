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
        
        /// Color used for rendering MIDI wires.
        public var midiWire: WireStyle = .init()
        
        /// Colors used for rendering custom wires.
        /// Dictionary is keyed by the custom wire name.
        public var customWires: [String: WireStyle] = [:]
        
        /// Returns input or output port color for the specified port type.
        public func color(for portType: PortType, isOutput: Bool) -> Color? {
            switch portType {
            case .control:
                return self.controlWire.color(output: isOutput)
            case .signal:
                return self.signalWire.color(output: isOutput)
            case .midi:
                return self.midiWire.color(output: isOutput)
            case let .custom(id):
                return self.customWires[id]?.color(output: isOutput)
            }
        }
        
        /// Returns port gradient for the specified port type.
        public func gradient(for portType: PortType) -> Gradient? {
            switch portType {
            case .control:
                return self.controlWire.gradient
            case .signal:
                return self.signalWire.gradient
            case .midi:
                return self.midiWire.gradient
            case let .custom(id):
                return self.customWires[id]?.gradient
            }
        }
    }
}

extension NodeEditor.Style {
    /// Configuration used to determine rendering style of a ``NodeEditor`` wire type.
    public struct WireStyle {
        public var inputColor: Color = .cyan
        public var outputColor: Color = .magenta

        func color(output: Bool) -> Color {
            output ? self.outputColor : self.inputColor
        }
        
        /// Get or set the input and output colors as a `Gradient`.
        /// Only the first and last stops will be used.
        public var gradient: Gradient {
            get {
                Gradient(colors: [self.outputColor, self.inputColor])
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
