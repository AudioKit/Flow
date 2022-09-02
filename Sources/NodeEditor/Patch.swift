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
