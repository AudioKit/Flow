import NodeEditor
import SwiftUI

class DemoData: ObservableObject {
    @Published var patch: Patch

    init() {

        let generator = Node(name: "generator",
                             position: CGPoint(x: 100, y: 100),
                             inputs: [],
                             outputs: [Port(name: "out",
                                            type: .signal)])

        let processor = Node(name: "processor",
                             position: CGPoint(x: 400, y: 100),
                             inputs: [Port(name: "in",
                                           type: .signal)],
                             outputs: [Port(name: "out",
                                            type: .signal)])

        let mixer = Node(name: "mixer",
                         position: CGPoint(x: 700, y: 100),
                         inputs: [Port(name: "in1",
                                       type: .signal),
                                  Port(name: "in2",
                                       type: .signal)],
                         outputs: [Port(name: "out",
                                        type: .signal)])

        let output = Node(name: "output",
                          position: CGPoint(x: 1000, y: 100),
                          inputs: [Port(name: "in",
                                        type: .signal)],
                          outputs: [])

        let nodes = [generator, processor,
                     generator.translate(by: CGSize(width: 0, height: 100)),
                     processor.translate(by: CGSize(width: 0, height: 100)),
                     mixer,
                     output]

        let wires = Set([Wire(from: 0, output: 0, to: 1, input: 0),
                         Wire(from: 1, output: 0, to: 4, input: 0),
                         Wire(from: 2, output: 0, to: 3, input: 0),
                         Wire(from: 3, output: 0, to: 4, input: 1),
                         Wire(from: 4, output: 0, to: 5, input: 0)])

        patch = Patch(nodes: nodes, wires: wires)

    }
}


struct ContentView: View {

    @State var demoData = DemoData()

    var body: some View {
        PatchView(patch: $demoData.patch)
    }
}
