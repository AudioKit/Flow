
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

public struct Node: Equatable {
    var name: String
    var position: CGPoint
    var inputs: [String]
    var outputs: [String]

    public init(name: String, position: CGPoint, inputs: [String], outputs: [String]) {
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
