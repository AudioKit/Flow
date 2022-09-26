// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import Foundation

/// An (output, input) pair. Represents a connection between nodes.
///
/// Node graphs are often represented with the connections
/// on the inputs instead of a separate set, which doesn't allow multiple inputs connected to
/// a single node. Our data model allows arbitrary connections, though we don't yet support
/// editing of arbitrary connection graphs (an input can only have one wire).
public struct Wire: Equatable, Hashable {
    public let output: OutputID
    public let input: InputID

    /// Initialize the wire with an input and output
    /// - Parameters:
    ///   - from: output from a node
    ///   - to: input into a node
    public init(from: OutputID, to: InputID) {
        output = from
        input = to
    }
}
