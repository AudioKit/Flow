import NodeEditor
import SwiftUI

struct ContentView: View {

    @State var patch = Patch(nodes: [Node(name: "test",
                                          position: CGPoint(x: 100, y: 100),
                                          inputs: [Port(name: "in",
                                                        type: .signal)],
                                          outputs: [Port(name: "out",
                                                         type: .signal)])], wires: [])

    var body: some View {
        PatchView(patch: $patch)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
