import CoreGraphics
import Foundation

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

    public func translate(by offset: CGSize) -> Node {
        var result = self
        result.position.x += offset.width
        result.position.y += offset.height
        return result
    }
}

public struct Wire: Equatable, Hashable {
    var origin: NodeIndex
    var output: PortIndex
    var destination: NodeIndex
    var input: PortIndex

    public init(from: NodeIndex, output: PortIndex, to: NodeIndex, input: PortIndex) {
        self.origin = from
        self.output = output
        self.destination = to
        self.input = input
    }
}
