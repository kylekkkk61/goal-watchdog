import AppKit
import ApplicationServices
import Foundation

let chatGPTBundleIdentifier = "com.openai.codex"
let pollInterval: TimeInterval = 5
let retryCooldown: TimeInterval = 15
let resumeDescriptions = Set(["恢復目標", "恢复目标", "Resume goal"])

func localized(_ key: String) -> String {
    NSLocalizedString(key, comment: "")
}

func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
    var value: CFTypeRef?
    return AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success ? value : nil
}

func stringAttribute(_ element: AXUIElement, _ name: String) -> String? {
    attribute(element, name) as? String
}

func windowAttribute(_ element: AXUIElement, _ name: String) -> AXUIElement? {
    guard let value = attribute(element, name), CFGetTypeID(value) == AXUIElementGetTypeID() else {
        return nil
    }
    return (value as! AXUIElement)
}

func isResumeDescription(_ description: String?) -> Bool {
    description.map(resumeDescriptions.contains) ?? false
}

func findResumeButton(in root: AXUIElement) -> AXUIElement? {
    var queue = [root]
    var index = 0

    while index < queue.count && index < 10_000 {
        let element = queue[index]
        index += 1

        if stringAttribute(element, kAXRoleAttribute) == kAXButtonRole,
           isResumeDescription(stringAttribute(element, kAXDescriptionAttribute)) {
            return element
        }

        if let children = attribute(element, kAXChildrenAttribute) as? [AXUIElement] {
            queue.append(contentsOf: children)
        }
    }

    return nil
}

func currentResumeButton() -> AXUIElement? {
    guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: chatGPTBundleIdentifier).first else {
        return nil
    }

    let application = AXUIElementCreateApplication(app.processIdentifier)
    let window = windowAttribute(application, kAXMainWindowAttribute)
        ?? windowAttribute(application, kAXFocusedWindowAttribute)

    return window.flatMap(findResumeButton)
}

func frame(of element: AXUIElement) -> CGRect? {
    guard let rawPosition = attribute(element, kAXPositionAttribute),
          let rawSize = attribute(element, kAXSizeAttribute) else {
        return nil
    }

    var position = CGPoint.zero
    var size = CGSize.zero
    guard AXValueGetValue(rawPosition as! AXValue, .cgPoint, &position),
          AXValueGetValue(rawSize as! AXValue, .cgSize, &size) else {
        return nil
    }

    return CGRect(origin: position, size: size)
}

func activateChatGPT() -> Bool {
    var error: NSDictionary?
    NSAppleScript(source: "tell application id \"\(chatGPTBundleIdentifier)\" to activate")?
        .executeAndReturnError(&error)
    return error == nil
}

func clickResumeButton() -> Bool {
    guard CGPreflightPostEventAccess(),
          let app = NSRunningApplication.runningApplications(withBundleIdentifier: chatGPTBundleIdentifier).first else {
        return false
    }

    let previousApplication = NSWorkspace.shared.frontmostApplication
    guard activateChatGPT() else {
        return false
    }

    defer {
        if previousApplication?.processIdentifier != app.processIdentifier {
            previousApplication?.activate()
        }
    }

    Thread.sleep(forTimeInterval: 0.25)
    guard NSWorkspace.shared.frontmostApplication?.processIdentifier == app.processIdentifier,
          let button = currentResumeButton(),
          let buttonFrame = frame(of: button),
          let previousPointerPosition = CGEvent(source: nil)?.location,
          let move = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: CGPoint(x: buttonFrame.midX, y: buttonFrame.midY), mouseButton: .left),
          let down = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: CGPoint(x: buttonFrame.midX, y: buttonFrame.midY), mouseButton: .left),
          let up = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: CGPoint(x: buttonFrame.midX, y: buttonFrame.midY), mouseButton: .left),
          let restore = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: previousPointerPosition, mouseButton: .left) else {
        return false
    }

    for event in [move, down, up] {
        event.post(tap: .cghidEventTap)
    }
    Thread.sleep(forTimeInterval: 0.15)
    restore.post(tap: .cghidEventTap)
    return true
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let statusMenuItem = NSMenuItem(title: localized("status.monitoring"), action: nil, keyEquivalent: "")
    private let lastResumeMenuItem = NSMenuItem(title: localized("lastResume.none"), action: nil, keyEquivalent: "")
    private let toggleMenuItem = NSMenuItem(title: localized("action.pause"), action: #selector(toggleMonitoring), keyEquivalent: "")
    private var timer: Timer?
    private var monitoring = true
    private var nextAllowedPress = Date.distantPast

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureMenu()
        promptForAccessibilityPermission()
        checkGoal()
        timer = Timer.scheduledTimer(timeInterval: pollInterval, target: self, selector: #selector(checkGoal), userInfo: nil, repeats: true)
    }

    private func configureMenu() {
        setIcon("dog.fill")
        statusItem.button?.toolTip = "Goal Watchdog"

        statusMenuItem.isEnabled = false
        lastResumeMenuItem.isEnabled = false

        let permissionsItem = NSMenuItem(title: localized("action.settings"), action: #selector(openAccessibilitySettings), keyEquivalent: "")
        permissionsItem.target = self
        toggleMenuItem.target = self

        let quitItem = NSMenuItem(title: localized("action.quit"), action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self

        let menu = NSMenu()
        menu.addItem(statusMenuItem)
        menu.addItem(lastResumeMenuItem)
        menu.addItem(.separator())
        menu.addItem(toggleMenuItem)
        menu.addItem(permissionsItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)
        statusItem.menu = menu
    }

    private func promptForAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        AXIsProcessTrustedWithOptions(options)
    }

    private func setIcon(_ symbolName: String) {
        let icon: NSImage?
        if symbolName == "dog.fill",
           let url = Bundle.main.url(forResource: "MenuBarIcon", withExtension: "png"),
           let menuBarIcon = NSImage(contentsOf: url) {
            menuBarIcon.size = NSSize(width: 18, height: 18)
            icon = menuBarIcon
        } else {
            icon = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Goal Watchdog")
        }
        icon?.isTemplate = true
        statusItem.button?.image = icon
    }

    private func setStatus(_ title: String, icon: String) {
        statusMenuItem.title = title
        setIcon(icon)
    }

    @objc private func checkGoal() {
        guard monitoring else {
            return
        }
        guard AXIsProcessTrusted() else {
            setStatus(localized("status.permissionRequired"), icon: "exclamationmark.triangle")
            return
        }
        guard Date() >= nextAllowedPress, currentResumeButton() != nil else {
            setStatus(localized("status.monitoring"), icon: "dog.fill")
            return
        }

        if clickResumeButton() {
            let time = Date().formatted(date: .omitted, time: .standard)
            lastResumeMenuItem.title = String(format: localized("lastResume.format"), time)
            setStatus(localized("status.resumeSent"), icon: "checkmark.circle")
        } else {
            setStatus(localized("status.clickFailed"), icon: "exclamationmark.triangle")
        }
        nextAllowedPress = Date().addingTimeInterval(retryCooldown)
    }

    @objc private func toggleMonitoring() {
        monitoring.toggle()
        toggleMenuItem.title = localized(monitoring ? "action.pause" : "action.resume")
        if monitoring {
            setStatus(localized("status.monitoring"), icon: "dog.fill")
            checkGoal()
        } else {
            setStatus(localized("status.paused"), icon: "pause.circle")
        }
    }

    @objc private func openAccessibilitySettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") else {
            return
        }
        NSWorkspace.shared.open(url)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

if CommandLine.arguments.contains("--self-test") {
    precondition(isResumeDescription("恢復目標"))
    precondition(isResumeDescription("恢复目标"))
    precondition(isResumeDescription("Resume goal"))
    precondition(!isResumeDescription("停止"))
    precondition(localized("cli.selfTestPassed") != "cli.selfTestPassed")
    print(localized("cli.selfTestPassed"))
    exit(0)
}

let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.run()
