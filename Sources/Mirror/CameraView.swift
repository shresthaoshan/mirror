import AppKit
import AVFoundation

/// Live preview of the built-in camera, or a message when there is no access.
final class CameraView: NSView {
    private let session = AVCaptureSession()
    private let preview: AVCaptureVideoPreviewLayer
    private let queue = DispatchQueue(label: "camera")
    private let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)
        ?? AVCaptureDevice.default(for: .video)

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

    private func showMessage(_ text: String, settingsButton: Bool = false) {
        guard subviews.isEmpty else { return }
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
