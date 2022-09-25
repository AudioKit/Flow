// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics

/// Nodes are identified by index in `Patch/nodes``.
public typealias NodeIndex = Int

/// Nodes are identified by index in ``Patch/nodes``.
///
/// Using indices as IDs has proven to be easy and fast for our use cases. The ``Patch`` should be
/// generated from your own data model, not used as your data model, so there isn't a requirement that
/// the indices be consistent across your editing operations (such as deleting nodes).
public struct Node: Equatable {
    public var name: String
    public var position: CGPoint

    /// Is the node position fixed so it can't be edited in the UI?
    public var locked = false

    public var inputs: [Port]
    public var outputs: [Port]
    
    @_disfavoredOverload
    public init(name: String,
                position: CGPoint = .zero,
                locked: Bool = false,
                inputs: [Port] = [],
                outputs: [Port] = []) {
        self.name = name
        self.position = position
        self.locked = locked
        self.inputs = inputs
        self.outputs = outputs
    }

    public init(name: String,
                position: CGPoint = .zero,
                locked: Bool = false,
                inputs: [String] = [],
                outputs: [String] = []) {
        self.name = name
        self.position = position
        self.locked = locked
        self.inputs = inputs.map { Port(name: $0) }
        self.outputs = outputs.map { Port(name: $0) }
    }

    public func translate(by offset: CGSize) -> Node {
        var result = self
        result.position.x += offset.width
        result.position.y += offset.height
        return result
    }

    func hitTest(nodeIndex: Int, point: CGPoint, layout: LayoutConstants) -> Patch.HitTestResult? {
        for (inputIndex, _) in self.inputs.enumerated() {
            if self.inputRect(input: inputIndex, layout: layout).contains(point) {
                return .input(nodeIndex, inputIndex)
            }
        }
        for (outputIndex, _) in self.outputs.enumerated() {
            if self.outputRect(output: outputIndex, layout: layout).contains(point) {
                return .output(nodeIndex, outputIndex)
            }
        }

        if self.rect(layout: layout).contains(point) {
            return .node(nodeIndex)
        }

        return nil
    }
}
