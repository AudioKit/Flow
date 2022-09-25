// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics

/// Define the layout geometry of the nodes.
public struct LayoutConstants {
    public let portSize = CGSize(width: 20, height: 20)
    public let portSpacing: CGFloat = 10
    public let nodeWidth: CGFloat = 200
    public let nodeTitleHeight: CGFloat = 40
    public let nodeSpacing: CGFloat = 40
    
    public init() {}

    public func inputRect(input: PortIndex) -> CGRect {
        let y = self.nodeTitleHeight + CGFloat(input) * (self.portSize.height + self.portSpacing)
        let origin = CGPoint(x: self.portSpacing, y: y)
        return CGRect(
            origin: origin,
            size: self.portSize
        )
    }

    public func outputRect(output: PortIndex) -> CGRect {
        let y = self.nodeTitleHeight + CGFloat(output) * (self.portSize.height + self.portSpacing)
        let origin = CGPoint(x: self.nodeWidth - self.portSpacing - self.portSize.width, y: y)
        return CGRect(
            origin: origin,
            size: self.portSize
        )
    }

    @inlinable @inline(__always)
    func rectSize(for portCount: Int) -> CGSize {
        CGSize(
            width: self.nodeWidth,
            height: CGFloat((CGFloat(portCount) * (self.portSize.height + self.portSpacing)) + self.nodeTitleHeight)
        )
    }
}
