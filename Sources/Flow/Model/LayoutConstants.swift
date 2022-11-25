// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import CoreGraphics
import SwiftUI

/// Define the layout geometry of the nodes.
public struct LayoutConstants {
    public var portSize = CGSize(width: 20, height: 20)
    public var portSpacing: CGFloat = 10
    public var nodeWidth: CGFloat = 200
    public var nodeTitleHeight: CGFloat = 40
    public var nodeSpacing: CGFloat = 40
    public var nodeTitleFont = Font.title
    public var portNameFont = Font.caption

    public init() {}
}
