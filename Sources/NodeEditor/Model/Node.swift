
import Foundation

/// Nodes are identified by index in `Patch.nodes`
public typealias NodeIndex = Int

/// Nodes are identified by index in `Patch.nodes`
///
/// Using indices as IDs has proven to be easy and fast for our use cases. The `Patch` should be
/// generated from your own data model, not used as your data model, so there isn't a requirement that
/// the indices be consistent across your editing operations (such as deleting nodes).
public struct Node: Equatable {
    public var name: String
    public var position: CGPoint
    public var inputs: [Port]
    public var outputs: [Port]

    public init(name: String, position: CGPoint = .zero, inputs: [Port] = [], outputs: [Port] = []) {
        self.name = name
        self.position = position
        self.inputs = inputs
        self.outputs = outputs
    }

    public init(name: String, position: CGPoint = .zero, inputs: [String] = [], outputs: [String] = []) {
        self.name = name
        self.position = position
        self.inputs = inputs.map { Port(name: $0) }
        self.outputs = outputs.map { Port(name: $0) }
    }

    public func translate(by offset: CGSize) -> Node {
        var result = self
        result.position.x += offset.width
        result.position.y += offset.height
        return result
    }

    /// Calculates the boudning rectangle for a node.
    func rect(layout: LayoutConstants) -> CGRect {
        let maxio = CGFloat(max(inputs.count, outputs.count))
        let size = CGSize(width: layout.nodeWidth, height: CGFloat(maxio * 30 + layout.nodeTitleHeight))

        return CGRect(origin: position, size: size)
    }

    /// Calculates the bounding rectangle for an input port (not including the name).
    func inputRect(input: PortIndex, layout: LayoutConstants) -> CGRect {
        let y = layout.nodeTitleHeight + CGFloat(input) * (layout.portSize.height + layout.portSpacing)
        return CGRect(origin: position + CGSize(width: layout.portSpacing, height: y),
                      size: layout.portSize)
    }

    /// Calculates the bounding rectangle for an output port (not including the name).
    func outputRect(output: PortIndex, layout: LayoutConstants) -> CGRect {
        let y = layout.nodeTitleHeight + CGFloat(output) * (layout.portSize.height + layout.portSpacing)
        return CGRect(origin: position + CGSize(width: layout.nodeWidth - layout.portSpacing - layout.portSize.width, height: y),
                      size: layout.portSize)
    }
}
