import AppKit
import AVFoundation

/// Live preview of the built-in camera, or a message when there is no access.
final class CameraView: NSView {
    private let session = AVCaptureSession()
    private let preview: AVCaptureVideoPreviewLayer
    private let queue = DispatchQueue(label: "camera")
    private let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
        ?? AVCaptureDevice.default(for: .video)
    private let flip = NSButton(image: NSImage(systemSymbolName: "arrow.left.and.right.righttriangle.left.righttriangle.right",
                                               accessibilityDescription: "Mirror image")!, target: nil, action: nil)
    private var messageShown = false

    /// Width / height of the camera image.
    var ratio: CGFloat {
        guard let device else { return 16 / 9 }
        let size = CMVideoFormatDescriptionGetDimensions(device.activeFormat.formatDescription)
        return CGFloat(size.width) / CGFloat(size.height)
    }

    override init(frame: NSRect) {
        preview = AVCaptureVideoPreviewLayer(session: session)
        super.init(frame: frame)
        wantsLayer = true
        preview.videoGravity = .resizeAspectFill
        preview.frame = bounds
        preview.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        layer?.addSublayer(preview)

        flip.target = self
        flip.action = #selector(toggleMirror)
        flip.toolTip = "Mirror image"
        flip.isBordered = false
        flip.contentTintColor = .white
        flip.wantsLayer = true
        flip.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
        flip.layer?.cornerRadius = 14
        flip.frame = NSRect(x: frame.width - 36, y: frame.height - 36, width: 28, height: 28)
        flip.autoresizingMask = [.minXMargin, .minYMargin]
        flip.isHidden = true
        addSubview(flip)
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                                       owner: self))
    }

    required init?(coder: NSCoder) { fatalError() }

    func start() {
        guard let device else { return showMessage("No camera found.") }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            queue.async { [session] in
                if session.inputs.isEmpty, let input = try? AVCaptureDeviceInput(device: device) {
                    session.addInput(input)
                }
                session.startRunning()
                DispatchQueue.main.async { self.applyMirror() }
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { _ in
                // The popup can close while the prompt is up; do not start the camera then.
                DispatchQueue.main.async { if self.window?.isVisible == true { self.start() } }
            }
        default:
            showMessage("Camera access is off.", settingsButton: true)
        }
    }

    func stop() {
        queue.async { [session] in session.stopRunning() }
    }

    // Show the flip button only on hover.
    override func mouseEntered(with event: NSEvent) { flip.isHidden = false }
    override func mouseExited(with event: NSEvent) { flip.isHidden = true }

    @objc private func toggleMirror() {
        UserDefaults.standard.set(!UserDefaults.standard.bool(forKey: "mirrored"), forKey: "mirrored")
        applyMirror()
    }

    private func applyMirror() {
        guard let connection = preview.connection else { return }
        connection.automaticallyAdjustsVideoMirroring = false
        connection.isVideoMirrored = UserDefaults.standard.bool(forKey: "mirrored")
    }

    private func showMessage(_ text: String, settingsButton: Bool = false) {
        guard !messageShown else { return }
        messageShown = true
        let label = NSTextField(wrappingLabelWithString: text)
        label.textColor = .white
        let stack = NSStackView(views: [label])
        stack.orientation = .vertical
        if settingsButton {
            stack.addArrangedSubview(NSButton(title: "Open Settings", target: self, action: #selector(openSettings)))
        }
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    @objc private func openSettings() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Camera")!)
    }
}
