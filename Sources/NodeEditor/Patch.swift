
import Foundation

public struct Patch {
    var nodes: [Node]
    var wires: [Wire]
}

typealias NodeID = Int

public struct Node {
    var name: String
    var position: CGPoint
    var inputs: [String]
    var outputs: [String]
}

public struct Wire {
    var from: NodeID
    var output: Int
    var to: NodeID
    var input: Int
}
