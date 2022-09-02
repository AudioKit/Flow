
import Foundation

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
/// as well as a custom option for your own types. XXX: not implemented yet
public enum PortType: Equatable, Hashable {
    case control
    case signal
    case custom(String)
}

/// Information for either an input or an output.
public struct Port: Equatable, Hashable {
    var name: String
    var type: PortType

    public init(name: String, type: PortType = .signal) {
        self.name = name
        self.type = type
    }
}
