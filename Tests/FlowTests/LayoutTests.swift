// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import Flow
import XCTest

final class LayoutTests: XCTestCase {
    func testNodeRects() throws {
        let processor = Node(name: "processor",
                             position: CGPoint(x: 400, y: 100),
                             inputs: [Port(name: "in", type: .signal)],
                             outputs: [Port(name: "out", type: .signal)])

        XCTAssertEqual(processor.rect(layout: LayoutConstants()),
                       CGRect(origin: processor.position, size: CGSize(width: 200, height: 80)))

        XCTAssertEqual(processor.inputRect(input: 0, layout: LayoutConstants()),
                       CGRect(origin: CGPoint(x: 410, y: 150), size: CGSize(width: 20, height: 20)))

        XCTAssertEqual(processor.outputRect(output: 0, layout: LayoutConstants()),
                       CGRect(origin: CGPoint(x: 570, y: 150), size: CGSize(width: 20, height: 20)))
    }
}
