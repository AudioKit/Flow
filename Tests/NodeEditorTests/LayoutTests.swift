
import XCTest
import NodeEditor

final class LayoutTests: XCTestCase {

    func testNodeRect() throws {

        let processor = Node(name: "processor",
                             position: CGPoint(x: 400, y: 100),
                             inputs: [Port(name: "in",
                                           type: .signal)],
                             outputs: [Port(name: "out",
                                            type: .signal)])

        XCTAssertEqual(processor.rect(layout: LayoutConstants()),
                       CGRect(origin: processor.position, size: CGSize(width: 200, height: 70)))
    }

}
