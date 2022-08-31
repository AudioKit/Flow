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

        let wires = Set([Wire(from: OutputID(0, 0), to: InputID(1, 0)),
                         Wire(from: OutputID(1, 0), to: InputID(4, 0)),
                         Wire(from: OutputID(2, 0), to: InputID(3, 0)),
                         Wire(from: OutputID(3, 0), to: InputID(4, 1)),
                         Wire(from: OutputID(4, 0), to: InputID(5, 0))])

        patch = Patch(nodes: nodes, wires: wires)

        var randomNodes: [Node] = []
        for n in 0 ..< 50 {
            let randomPoint = CGPoint(x: 1000 * Double.random(in: 0...1), y: 1000 * Double.random(in: 0...1))
            randomNodes.append(Node(name: "node\(n)",
                                    position: randomPoint,
                                    inputs: [Port(name: "In", type: .signal)],
                                    outputs: [Port(name: "Out", type: .signal)]))
        }

        var randomWires: Set<Wire> = []
        for n in 0 ..< 50 {
            randomWires.insert(Wire(from: OutputID(n, 0), to: InputID(Int.random(in: 0...49), 0)))
        }
        patch = Patch(nodes: randomNodes, wires: randomWires)

    }
}

struct ContentView: View {
    @State var demoData = DemoData()
    @State var selection = Set<NodeIndex>()

    var body: some View {
        PatchView(patch: $demoData.patch, selection: $selection)
    }
}
