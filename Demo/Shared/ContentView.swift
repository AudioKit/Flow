import NodeEditor
import SwiftUI

struct DemoData {
    var patch: Patch

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

        let wires = Set([Wire(from: PortID(0, 0), to: PortID(1, 0)),
                         Wire(from: PortID(1, 0), to: PortID(4, 0)),
                         Wire(from: PortID(2, 0), to: PortID(3, 0)),
                         Wire(from: PortID(3, 0), to: PortID(4, 1)),
                         Wire(from: PortID(4, 0), to: PortID(5, 0))])

        patch = Patch(nodes: nodes, wires: wires)
    }
}

struct ContentView: View {
    @State var demoData = DemoData()
    @State var selection = Set<NodeIndex>()

    var body: some View {
        PatchView(patch: $demoData.patch, selection: $selection)
    }
}
