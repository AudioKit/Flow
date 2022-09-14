// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import Foundation

/// Ports are identified by index within a node.
public typealias PortIndex = Int

/// Uniquely identifies an input by indices.
public struct InputID: Equatable, Hashable {
    public let nodeIndex: NodeIndex
    public let portIndex: PortIndex

    /// Initialize an input
    /// - Parameters:
    ///   - nodeIndex: Index for the node the input belongs
    ///   - portIndex: Index to the input within the node
    public init(_ nodeIndex: NodeIndex, _ portIndex: PortIndex) {
        self.nodeIndex = nodeIndex
        self.portIndex = portIndex
    }
}

/// Uniquely identifies an output by indices.
public struct OutputID: Equatable, Hashable {
    public let nodeIndex: NodeIndex
    public let portIndex: PortIndex

    /// Initialize an output
    /// - Parameters:
    ///   - nodeIndex: Index for the node the output belongs
    ///   - portIndex: Index to the output within the node
    public init(_ nodeIndex: NodeIndex, _ portIndex: PortIndex) {
        self.nodeIndex = nodeIndex
        self.portIndex = portIndex
    }
}

/// Support for different types of connections.
///
/// Some graphs have different types of ports which can't be
/// connected to each other. Here we offer two common types
/// as well as a custom option for your own types. XXX: not implemented yet
public enum PortType: Equatable, Hashable {
    case control
    case signal
    case midi
    case custom(String)
}

/// Information for either an input or an output.
public struct Port: Equatable, Hashable {
    public let name: String
    public let type: PortType

    /// Initialize the port with a name and type
    /// - Parameters:
    ///   - name: Descriptive label of the port
    ///   - type: Type of port
    public init(name: String, type: PortType = .signal) {
        self.name = name
        self.type = type
    }
}
