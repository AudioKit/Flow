// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics

/// Define the layout geometry of the nodes.
public struct LayoutConstants {
    let portSize = CGSize(width: 20, height: 20)
    let portSpacing: CGFloat = 10
    let nodeWidth: CGFloat = 200
    let nodeTitleHeight: CGFloat = 40
    let nodeSpacing: CGFloat = 40
    
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
}
