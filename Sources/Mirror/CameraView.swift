import AppKit
import AVFoundation

/// Live preview of the built-in camera, or a message when there is no access.
final class CameraView: NSView {
    private let session = AVCaptureSession()
    private let preview: AVCaptureVideoPreviewLayer
    private let queue = DispatchQueue(label: "camera")
    private let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
        ?? AVCaptureDevice.default(for: .video)
    private var buttons: [NSButton] = []
    private var centerStage: NSButton?
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

        addButton("arrow.left.and.right.righttriangle.left.righttriangle.right", "Mirror image", #selector(toggleMirror))
        if device?.activeFormat.isCenterStageSupported == true {
            AVCaptureDevice.centerStageControlMode = .cooperative // app and Control Center both control it
            centerStage = addButton("person.crop.rectangle", "Center Stage", #selector(toggleCenterStage))
        }
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                                       owner: self))
    }

    /// Adds a hover button to the top-right row, right to left.
    @discardableResult
    private func addButton(_ symbol: String, _ label: String, _ action: Selector) -> NSButton {
        let button = NSButton(image: NSImage(systemSymbolName: symbol, accessibilityDescription: label)!,
                              target: self, action: action)
        button.toolTip = label
        if #available(macOS 26, *) {
            button.bezelStyle = .glass
        } else {
            button.isBordered = false
            button.contentTintColor = .white
            button.wantsLayer = true
            button.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.5).cgColor
            button.layer?.cornerRadius = 14
        }
        button.frame = NSRect(x: frame.width - 36 * CGFloat(buttons.count + 1), y: frame.height - 36, width: 28, height: 28)
        button.autoresizingMask = [.minXMargin, .minYMargin]
        button.isHidden = true
        addSubview(button)
        buttons.append(button)
        return button
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

    // Show the buttons only on hover.
    override func mouseEntered(with event: NSEvent) {
        showCenterStageState() // Control Center can change it too
        buttons.forEach { $0.isHidden = false }
    }
    override func mouseExited(with event: NSEvent) { buttons.forEach { $0.isHidden = true } }

    @objc private func toggleCenterStage() {
        AVCaptureDevice.isCenterStageEnabled.toggle()
        showCenterStageState()
    }

    private func showCenterStageState() {
        let symbol = AVCaptureDevice.isCenterStageEnabled ? "person.crop.rectangle.fill" : "person.crop.rectangle"
        centerStage?.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "Center Stage")
    }

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
