// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import Foundation

extension Node {

    public func translate(by offset: CGSize) -> Node {
        var result = self
        result.position.x += offset.width
        result.position.y += offset.height
        return result
    }

    func hitTest(nodeIndex: Int, point: CGPoint, layout: LayoutConstants) -> Patch.HitTestResult? {
        for (inputIndex, _) in self.inputs.enumerated() {
            if self.inputRect(input: inputIndex, layout: layout).contains(point) {
                return .input(nodeIndex, inputIndex)
            }
        }
        for (outputIndex, _) in self.outputs.enumerated() {
            if self.outputRect(output: outputIndex, layout: layout).contains(point) {
                return .output(nodeIndex, outputIndex)
            }
        }

        if self.rect(layout: layout).contains(point) {
            return .node(nodeIndex)
        }

        return nil
    }

}
