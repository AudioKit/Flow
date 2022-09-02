import CoreGraphics
import Foundation

/// Data model for NodeEditor.
///
/// Write a function to generate a `Patch` from your own data model
/// as well as a function to update your data model when the `Patch` changes.
/// Use SwiftUI's onChange(of:) to monitor changes.
public struct Patch: Equatable {
    var nodes: [Node]
    var wires: Set<Wire>

    public init(nodes: [Node], wires: Set<Wire>) {
        self.nodes = nodes
        self.wires = wires
    }
}

public typealias NodeIndex = Int
public typealias PortIndex = Int

/// Uniquely identfies an input by indices.
public struct InputID: Equatable, Hashable {
    var nodeIndex: NodeIndex
    var portIndex: PortIndex

    public init(_ nodeIndex: NodeIndex, _ portIndex: PortIndex) {
        self.nodeIndex = nodeIndex
        self.portIndex = portIndex
    }
}

/// Uniquely identfies an output by indices.
public struct OutputID: Equatable, Hashable {
    var nodeIndex: NodeIndex
    var portIndex: PortIndex

    public init(_ nodeIndex: NodeIndex, _ portIndex: PortIndex) {
        self.nodeIndex = nodeIndex
        self.portIndex = portIndex
    }
}

/// Support for different types of connections.
///
/// Some graphs have different types of ports which can't be
/// connected to eachother. Here we offer two common types
/// as well as a custom option for your own types.
public enum PortType: Equatable, Hashable {
    case control
    case signal
    case custom(String)
}

/// Information for either an input or an output.
public struct Port: Equatable, Hashable {
    var name: String
    var type: PortType

    public init(name: String, type: PortType) {
        self.name = name
        self.type = type
    }
}

/// An (output, input) pair. Represents a connection between nodes.
///
/// Node graphs are often represented with the connections
/// on the inputs instead of a separate set, which doesn't allow multiple inputs connected to
/// a single node. Our data model allows arbitrary connections, though we don't yet support
/// editing of arbitrary connection graphs (an input can only have one wire).
public struct Wire: Equatable, Hashable {
    var output: OutputID
    var input: InputID

    public init(from: OutputID, to: InputID) {
        output = from
        input = to
    }
}
