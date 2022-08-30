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

        let output = Node(name: "output",
                          position: CGPoint(x: 700, y: 100),
                          inputs: [Port(name: "in",
                                        type: .signal)],
                          outputs: [])

        let nodes = [generator, processor, output]

        let wire1 = Wire(from: 0, output: 0, to: 1, input: 0)
        let wire2 = Wire(from: 1, output: 0, to: 2, input: 0)
        let wires = [wire1, wire2]

        patch = Patch(nodes: nodes, wires: wires)

    }
}


struct ContentView: View {

    @State var demoData = DemoData()

    var body: some View {
        PatchView(patch: $demoData.patch)
    }
}
