# Flow

[![Tests](https://github.com/AudioKit/Flow/actions/workflows/tests.yml/badge.svg)](https://github.com/AudioKit/Flow/actions/workflows/tests.yml)

Generic node graph editor. Generate a `Patch` from your own data model. Update
your data model when the `Patch` changes.

![flow-demo](https://user-images.githubusercontent.com/13122/204678924-64a37ef5-522e-4da5-9c79-c2c6f9f745a6.gif)

```swift
func simplePatch() -> Patch {
    let generator = Node(name: "generator", outputs: ["out"])
    let processor = Node(name: "processor", inputs: ["in"], outputs: ["out"])
    let mixer = Node(name: "mixer", inputs: ["in1", "in2"], outputs: ["out"])
    let output = Node(name: "output", inputs: ["in"])

    let nodes = [generator, processor, generator, processor, mixer, output]

    let wires = Set([Wire(from: OutputID(0, 0), to: InputID(1, 0)),
                     Wire(from: OutputID(1, 0), to: InputID(4, 0)),
                     Wire(from: OutputID(2, 0), to: InputID(3, 0)),
                     Wire(from: OutputID(3, 0), to: InputID(4, 1)),
                     Wire(from: OutputID(4, 0), to: InputID(5, 0))])

    var patch = Patch(nodes: nodes, wires: wires)
    patch.recursiveLayout(nodeIndex: 5, at: CGPoint(x: 800, y: 50))
    return patch
}

struct ContentView: View {
    @State var patch = simplePatch()
    @State var selection = Set<NodeIndex>()

    var body: some View {
        NodeEditor(patch: $patch, selection: $selection)
            .onNodeMoved { index, location in
                print("Node at index \(index) moved to \(location)")
            }
            .onWireAdded { wire in
                print("Added wire: \(wire)")
            }
            .onWireRemoved { wire in
                print("Removed wire: \(wire)")
            }
    }
}
```

## Documentation

The API Reference can be found on [the AudioKit Website](https://www.audiokit.io/Flow). 
Package contains a demo project and a playground to help you get started quickly.
