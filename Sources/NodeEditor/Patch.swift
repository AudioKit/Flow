
import Foundation

struct Patch {
    var nodes: [Node]
    var wires: [Wire]
}

typealias NodeID = Int

struct Node {
    var name: String
    var position: CGPoint
    var inputs: [String]
    var outputs: [String]
}

struct Wire {
    var from: NodeID
    var output: Int
    var to: NodeID
    var input: Int
}
