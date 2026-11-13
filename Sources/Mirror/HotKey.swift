import Carbon.HIToolbox

/// Global ⌃⌘M. Carbon hotkeys need no Accessibility permission.
enum HotKey {
    private static var action: (() -> Void)?
    private static var ref: EventHotKeyRef?

    /// False when registration failed, for example when another app holds ⌃⌘M.
    private(set) static var isRegistered = false

    static func register(_ action: @escaping () -> Void) {
        self.action = action
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        var handler: EventHandlerRef?
        // The application event target delivers on the main thread.
        guard InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in
            HotKey.action?()
            return noErr
        }, 1, &spec, nil, &handler) == noErr else { return }
        let id = EventHotKeyID(signature: OSType(0x4D49_5252), id: 1) // "MIRR"
        isRegistered = RegisterEventHotKey(UInt32(kVK_ANSI_M), UInt32(cmdKey | controlKey), id,
                                           GetApplicationEventTarget(), 0, &ref) == noErr
        if !isRegistered { RemoveEventHandler(handler) }
    }
}
