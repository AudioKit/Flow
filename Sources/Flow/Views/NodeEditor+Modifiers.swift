// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

// View Modifiers

extension NodeEditor {
    /// Called when a node is moved.
    public func onNodeMoved(_ handler: @escaping NodeMovedHandler) -> Self {
        var viewCopy = self
        viewCopy.nodeMoved = handler
        return viewCopy
    }
    
    /// Called when a wire is added.
    public func onWireAdded(_ handler: @escaping WireAddedHandler) -> Self {
        var viewCopy = self
        viewCopy.wireAdded = handler
        return viewCopy
    }
    
    public func onWireRemoved(_ handler: @escaping WireRemovedHandler) -> Self {
        var viewCopy = self
        viewCopy.wireRemoved = handler
        return viewCopy
    }
}
