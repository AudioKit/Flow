// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import Foundation

public extension Node {
    /// Calculates the bounding rectangle for a node.
    func rect(layout: LayoutConstants) -> CGRect {
        let maxio = CGFloat(max(inputs.count, outputs.count))
        let size = CGSize(width: layout.nodeWidth,
                          height: CGFloat((maxio * (layout.portSize.height + layout.portSpacing)) + layout.nodeTitleHeight + layout.portSpacing))

        return CGRect(origin: position, size: size)
    }

    /// Calculates the bounding rectangle for an input port (not including the name).
    func inputRect(input: PortIndex, layout: LayoutConstants) -> CGRect {
        let y = layout.nodeTitleHeight + CGFloat(input) * (layout.portSize.height + layout.portSpacing) + layout.portSpacing
        return CGRect(origin: position + CGSize(width: layout.portSpacing, height: y),
                      size: layout.portSize)
    }

    /// Calculates the bounding rectangle for an output port (not including the name).
    func outputRect(output: PortIndex, layout: LayoutConstants) -> CGRect {
        let y = layout.nodeTitleHeight + CGFloat(output) * (layout.portSize.height + layout.portSpacing) + layout.portSpacing
        return CGRect(origin: position + CGSize(width: layout.nodeWidth - layout.portSpacing - layout.portSize.width, height: y),
                      size: layout.portSize)
    }
}
