// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/Flow/

import SwiftUI

/// Provides pan and zoom gestures. Unfortunately it seems this
/// can't be accomplished using purely SwiftUI because MagnificationGesture
/// doesn't provide a center point.
#if os(iOS)
struct WorkspaceView: UIViewRepresentable {
    @Binding var pan: CGSize
    @Binding var zoom: Double
    @Binding var mousePosition: CGPoint

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

class PanView: NSView {
    private static let defaultPanSpeed = 5.0
    
    @Binding var pan: CGSize
    @Binding var zoom: Double
    @Binding var mousePosition: CGPoint
    
    var trackingArea: NSTrackingArea!
    private var panSpeed = PanView.defaultPanSpeed

    init(pan: Binding<CGSize>, zoom: Binding<Double>, mousePosition: Binding<CGPoint>) {
        _pan = pan
        _zoom = zoom
        _mousePosition = mousePosition

        super.init(frame: .zero)

        let panRecognizer = NSPanGestureRecognizer(target: self,
                                                   action: #selector(PanView.panGesture(sender:)))
        addGestureRecognizer(panRecognizer)
        panRecognizer.buttonMask = 2
        panRecognizer.delegate = self

        let optionPanRecognizer = NSPanGestureRecognizer(target: self,
                                                   action: #selector(PanView.panGesture(sender:)))
        addGestureRecognizer(optionPanRecognizer)
        optionPanRecognizer.delegate = self
        self.optionPanRecognizer = optionPanRecognizer

        let zoomRecognizer = NSMagnificationGestureRecognizer(target: self,
                                                              action: #selector(PanView.zoomGesture(sender:)))
        addGestureRecognizer(zoomRecognizer)
        zoomRecognizer.delegate = self


    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if trackingArea != nil {
            removeTrackingArea(trackingArea)
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if trackingArea != nil {
            removeTrackingArea(trackingArea)
        }

        trackingArea = NSTrackingArea(rect: frame, options: [.mouseEnteredAndExited, .mouseMoved, .activeInActiveApp], owner: self, userInfo: nil)

        addTrackingArea(trackingArea)
    }

    override func scrollWheel(with event: NSEvent) {
        var p = convert(event.locationInWindow, from: nil).size
        p.height = frame.size.height - p.height

        if event.subtype == .mouseEvent {
            let rot = event.deltaY
            let scale = rot > 0 ? (1 + rot / 10) : 1.0/(1 - rot/10)
            zoom(at: p, scale: scale)

        } else {
            if event.momentumPhase == .changed {
                panSpeed *= 0.95
            } else {
                panSpeed = PanView.defaultPanSpeed
            }
            
            pan.width += panSpeed * event.deltaX / zoom
            pan.height += panSpeed * event.deltaY / zoom
        }
    }

    @objc func panGesture(sender: NSPanGestureRecognizer) {
        let t = sender.translation(in: self)
        pan.width += t.x / zoom
        pan.height -= t.y / zoom

        // Reset translation.
        sender.setTranslation(CGPoint.zero, in: nil)
    }

    @objc func zoomGesture(sender: NSMagnificationGestureRecognizer) {

        if sender.state == .changed {
            var p = sender.location(in: self).size
            p.height = frame.size.height - p.height

            zoom(at: p, scale: sender.magnification)
        }

        // Reset scale.
        sender.magnification = 1.0
    }

    func zoom(at p: CGSize, scale: CGFloat) {
        let newZoom = scale * zoom

        let pLocal = p * (1.0 / zoom) - pan
        let newPan = p * (1.0 / newZoom) - pLocal

        pan = newPan
        zoom = newZoom
    }
    
    override func mouseMoved(with event: NSEvent) {
        var p = convert(event.locationInWindow, from: nil)
        p.y = frame.size.height - p.y
        mousePosition = p
    }

    weak var optionPanRecognizer: NSGestureRecognizer?
}

extension PanView: NSGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: NSGestureRecognizer) -> Bool {
        if gestureRecognizer == optionPanRecognizer {
            return NSEvent.modifierFlags == .option
        }
        return true
    }

    func gestureRecognizer(_: NSGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith _: NSGestureRecognizer) -> Bool
    {
        return true
    }
}

/// Handles gestures for changing the workspace view.
struct WorkspaceView: NSViewRepresentable {
    @Binding var pan: CGSize
    @Binding var zoom: Double
    
    /// Current mouse position. Note that we can't get this from hovering
    /// in SwiftUI. `onHover` doesn't provide a position.
    @Binding var mousePosition: CGPoint

    func makeNSView(context: Context) -> NSView {
        return PanView(pan: $pan, zoom: $zoom, mousePosition: $mousePosition)
    }

    func updateNSView(_: NSView, context _: Context) {
        // Do nothing.
    }
}

#endif

struct WorkspaceTestView: View {
    @State var pan: CGSize = .zero
    @State var zoom: Double = 0.0
    @State var mousePosition: CGPoint = .zero

    var body: some View {
        WorkspaceView(pan: $pan, zoom: $zoom, mousePosition: $mousePosition)
    }
}

struct WorkspaceView_Previews: PreviewProvider {
    static var previews: some View {
        WorkspaceTestView()
    }
}
