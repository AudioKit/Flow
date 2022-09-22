// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

@testable import Flow
import XCTest

final class NodeTests: XCTestCase {
    /// This test ensures disambiguation for identical `Node` init signature overloads
    /// where inputs and outputs are empty.
    /// It will throw a compiler error if it cannot determine which to use.
    /// No logic testing is necessary here.
    func testNodeInitDisambiguation() throws {
        _ = Node(name: "Name")
        _ = Node(name: "Name", position: .zero, inputs: [], outputs: [])
    }
}
