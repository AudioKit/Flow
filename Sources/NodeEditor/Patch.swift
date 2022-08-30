import CoreGraphics
import Foundation

public struct Patch: Equatable {
    var nodes: [Node]
    var wires: [Wire]

    public init(nodes: [Node], wires: [Wire]) {
        self.nodes = nodes
        self.wires = wires
    }
}

public typealias NodeID = Int

public enum PortType: Equatable, Hashable {
    case control
    case signal
    case custom(String)
}

public struct Port: Equatable, Hashable {
    var name: String
    var type: PortType

    public init(name: String, type: PortType) {
        self.name = name
        self.type = type
    }
}

public struct Node: Equatable {
    var name: String
    var position: CGPoint
    var inputs: [Port]
    var outputs: [Port]

    public init(name: String, position: CGPoint, inputs: [Port], outputs: [Port]) {
        self.name = name
        self.position = position
        self.inputs = inputs
        self.outputs = outputs
    }
}

public struct Wire: Equatable, Hashable {
    var from: NodeID
    var output: Int
    var to: NodeID
    var input: Int

    public init(from: NodeID, output: Int, to: NodeID, input: Int) {
        self.from = from
        self.output = output
        self.to = to
        self.input = input
    }
}
