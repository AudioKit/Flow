// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import Foundation
import SwiftUI

/// Caches "resolved" text.
///
/// XXX: we will need to know when to clear the cache.
class TextCache: ObservableObject {
    
    struct Key: Equatable, Hashable {
        var string: String
        var font: Font
    }
    
    var cache: [Key: GraphicsContext.ResolvedText] = [:]

    func text(string: String,
              font: Font,
              _ cx: GraphicsContext) -> GraphicsContext.ResolvedText {
        
        let key = Key(string: string, font: font)
        
        if let resolved = cache[key] {
            return resolved
        }

        let resolved = cx.resolve(Text(string).font(font))
        cache[key] = resolved
        return resolved
    }
}
