// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import Foundation
import SwiftUI

/// Caches "resolved" text.
///
/// XXX: we will need to know when to clear the cache.
class TextCache: ObservableObject {
    var cache: [String: GraphicsContext.ResolvedText] = [:]

    func text(string: String,
              caption: Bool,
              _ cx: GraphicsContext) -> GraphicsContext.ResolvedText {
        if let resolved = cache[string] {
            return resolved
        }

        let resolved = caption ? cx.resolve(Text(string).font(.caption)) : cx.resolve(Text(string))
        cache[string] = resolved
        return resolved
    }
}
