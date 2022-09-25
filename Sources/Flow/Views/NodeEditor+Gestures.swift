// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

extension NodeEditor {
    /// State for all gestures.
    enum DragInfo {
        case wire(output: OutputID, offset: CGSize = .zero, hideWire: Wire? = nil)
        case node(index: NodeIndex, offset: CGSize = .zero)
        case selection(rect: CGRect = .zero)
        case none
    }

    @inline(__always)
    func toLocal(_ p: CGPoint) -> CGPoint {
        p / self.zoom - self.pan
    }

    @inline(__always)
    func toLocal(_ sz: CGSize) -> CGSize {
        sz / self.zoom
    }

    @inline(__always)
    func toLocal(_ r: CGRect) -> CGRect {
        CGRect(origin: self.toLocal(r.origin), size: self.toLocal(r.size))
    }

    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating(self.$dragInfo) { drag, dragInfo, _ in

                if let d = self.patch.dragUpdated(
                    startLocation: toLocal(drag.startLocation),
                    location: toLocal(drag.location),
                    translation: toLocal(drag.translation),
                    layout: self.layout
                ) {
                    dragInfo = d
                }
            }
            .onEnded { drag in

                self.patch.dragEnded(
                    startLocation: self.toLocal(drag.startLocation),
                    location: self.toLocal(drag.location),
                    translation: self.toLocal(drag.translation),
                    layout: self.layout
                )

            }
    }
}

extension DragGesture.Value {
    @inlinable @inline(__always)
    var distance: CGFloat {
        self.startLocation.distance(to: self.location)
    }
}
