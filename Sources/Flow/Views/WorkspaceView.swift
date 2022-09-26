// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

/// Provides pan and zoom gestures. Unfortunately it seems this
/// can't be accomplished using purely SwiftUI because MagnificationGesture
/// doesn't provide a center point.
#if os(iOS)
struct WorkspaceView: UIViewRepresentable {
    @Binding var pan: CGSize
    @Binding var zoom: Double

    class Coordinator: NSObject {
        @Binding var pan: CGSize
        @Binding var zoom: Double

        init(pan: Binding<CGSize>, zoom: Binding<Double>) {
            _pan = pan
            _zoom = zoom
        }

        @objc func panGesture(sender: UIPanGestureRecognizer) {
            let t = sender.translation(in: nil)
            pan.width += t.x / zoom
            pan.height += t.y / zoom

            // Reset translation.
            sender.setTranslation(CGPoint.zero, in: nil)
        }

        @objc func zoomGesture(sender: UIPinchGestureRecognizer) {
            let p = sender.location(in: nil).size

            let newZoom = sender.scale * zoom

            let pLocal = p * (1.0 / zoom) - pan
            let newPan = p * (1.0 / newZoom) - pLocal

            pan = newPan
            zoom = newZoom

            // Reset scale.
            sender.scale = 1.0
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(pan: $pan, zoom: $zoom)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        let coordinator = context.coordinator

        let panRecognizer = UIPanGestureRecognizer(target: coordinator,
                                                   action: #selector(Coordinator.panGesture(sender:)))
        view.addGestureRecognizer(panRecognizer)
        panRecognizer.delegate = coordinator
        panRecognizer.minimumNumberOfTouches = 2

        let pinchGesture = UIPinchGestureRecognizer(target: coordinator, action:
            #selector(Coordinator.zoomGesture(sender:)))
        view.addGestureRecognizer(pinchGesture)
        pinchGesture.delegate = coordinator

        return view
    }

    func updateUIView(_: UIView, context _: Context) {
        // Do nothing.
    }
}

extension WorkspaceView.Coordinator: UIGestureRecognizerDelegate {
    func gestureRecognizer(_: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool
    {
        return true
    }
}

#else
struct WorkspaceView: NSViewRepresentable {
    @Binding var pan: CGSize
    @Binding var zoom: Double

    class Coordinator: NSObject {
        @Binding var pan: CGSize
        @Binding var zoom: Double

        init(pan: Binding<CGSize>, zoom: Binding<Double>) {
            _pan = pan
            _zoom = zoom
        }

        @objc func panGesture(sender: NSPanGestureRecognizer) {
            print("pan at location: \(sender.location(in: nil))")
            let t = sender.translation(in: nil)
            pan.width += t.x / zoom
            pan.height -= t.y / zoom

            // Reset translation.
            sender.setTranslation(CGPoint.zero, in: nil)
        }

        @objc func zoomGesture(sender: NSMagnificationGestureRecognizer) {
            print("pinch at location: \(sender.location(in: nil)), scale: \(sender.magnification)")

            let p = sender.location(in: nil).size

            let newZoom = sender.magnification * zoom

            let pLocal = p * (1.0 / zoom) - pan
            let newPan = p * (1.0 / newZoom) - pLocal

            pan = newPan
            zoom = newZoom

            // Reset scale.
            sender.magnification = 1.0
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(pan: $pan, zoom: $zoom)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()

        let coordinator = context.coordinator

        let panRecognizer = NSPanGestureRecognizer(target: coordinator,
                                                   action: #selector(Coordinator.panGesture(sender:)))
        view.addGestureRecognizer(panRecognizer)
        panRecognizer.buttonMask = 2
        panRecognizer.delegate = coordinator

        let zoomRecognizer = NSMagnificationGestureRecognizer(target: coordinator,
                                                              action: #selector(Coordinator.zoomGesture(sender:)))
        view.addGestureRecognizer(zoomRecognizer)
        zoomRecognizer.delegate = coordinator

        return view
    }

    func updateNSView(_: NSView, context _: Context) {
        // Do nothing.
    }
}

extension WorkspaceView.Coordinator: NSGestureRecognizerDelegate {
    func gestureRecognizer(_: NSGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith _: NSGestureRecognizer) -> Bool
    {
        return true
    }
}

#endif

struct WorkspaceTestView: View {
    @State var pan: CGSize = .zero
    @State var zoom: Double = 0.0

    var body: some View {
        WorkspaceView(pan: $pan, zoom: $zoom)
    }
}

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceTestView()
    }
}
