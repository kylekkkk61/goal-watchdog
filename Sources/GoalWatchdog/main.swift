import AppKit
import ApplicationServices
import Foundation

let chatGPTBundleIdentifier = "com.openai.codex"
let pollInterval: TimeInterval = 5
let retryCooldown: TimeInterval = 15
let resumeDescriptions = Set(["恢復目標", "恢复目标", "Resume goal"])
let appLanguageDefaultsKey = "appLanguage"

enum AppLanguage: String, CaseIterable {
    case system
    case english = "en"
    case traditionalChinese = "zh-Hant"

    var menuTitleKey: String {
        switch self {
        case .system: "language.system"
        case .english: "language.english"
        case .traditionalChinese: "language.traditionalChinese"
        }
    }
}

func selectedAppLanguage() -> AppLanguage {
    guard let value = UserDefaults.standard.string(forKey: appLanguageDefaultsKey) else {
        return .system
    }
    return AppLanguage(rawValue: value) ?? .system
}

func localized(_ key: String, language: AppLanguage? = nil) -> String {
    let language = language ?? selectedAppLanguage()
    guard language != .system,
          let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
          let bundle = Bundle(path: path) else {
        return NSLocalizedString(key, comment: "")
    }
    return bundle.localizedString(forKey: key, value: nil, table: nil)
}

func formattedTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium

    switch selectedAppLanguage() {
    case .system:
        formatter.locale = .current
    case .english:
        formatter.locale = Locale(identifier: "en")
    case .traditionalChinese:
        formatter.locale = Locale(identifier: "zh-Hant")
    }

    return formatter.string(from: date)
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
    private let languageMenuItem = NSMenuItem(title: localized("menu.language"), action: nil, keyEquivalent: "")
    private let permissionsMenuItem = NSMenuItem(title: localized("action.settings"), action: #selector(openAccessibilitySettings), keyEquivalent: "")
    private let quitMenuItem = NSMenuItem(title: localized("action.quit"), action: #selector(quit), keyEquivalent: "q")
    private var languageMenuItems: [AppLanguage: NSMenuItem] = [:]
    private var timer: Timer?
    private var monitoring = true
    private var nextAllowedPress = Date.distantPast
    private var currentStatusKey = "status.monitoring"
    private var lastResumeDate: Date?

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

        permissionsMenuItem.target = self
        toggleMenuItem.target = self
        quitMenuItem.target = self

        let languageMenu = NSMenu()
        for language in AppLanguage.allCases {
            let item = NSMenuItem(title: "", action: #selector(selectLanguage(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = language.rawValue
            languageMenuItems[language] = item
            languageMenu.addItem(item)
        }
        languageMenuItem.submenu = languageMenu

        let menu = NSMenu()
        menu.addItem(statusMenuItem)
        menu.addItem(lastResumeMenuItem)
        menu.addItem(.separator())
        menu.addItem(toggleMenuItem)
        menu.addItem(languageMenuItem)
        menu.addItem(permissionsMenuItem)
        menu.addItem(.separator())
        menu.addItem(quitMenuItem)
        statusItem.menu = menu
        updateLocalizedMenu()
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

    private func setStatus(_ key: String, icon: String) {
        currentStatusKey = key
        statusMenuItem.title = localized(key)
        setIcon(icon)
    }

    private func updateLocalizedMenu() {
        statusMenuItem.title = localized(currentStatusKey)
        if let lastResumeDate {
            lastResumeMenuItem.title = String(format: localized("lastResume.format"), formattedTime(lastResumeDate))
        } else {
            lastResumeMenuItem.title = localized("lastResume.none")
        }
        toggleMenuItem.title = localized(monitoring ? "action.pause" : "action.resume")
        languageMenuItem.title = localized("menu.language")
        permissionsMenuItem.title = localized("action.settings")
        quitMenuItem.title = localized("action.quit")

        let selectedLanguage = selectedAppLanguage()
        for language in AppLanguage.allCases {
            languageMenuItems[language]?.title = localized(language.menuTitleKey)
            languageMenuItems[language]?.state = language == selectedLanguage ? .on : .off
        }
    }

    @objc private func checkGoal() {
        guard monitoring else {
            return
        }
        guard AXIsProcessTrusted() else {
            setStatus("status.permissionRequired", icon: "exclamationmark.triangle")
            return
        }
        guard Date() >= nextAllowedPress, currentResumeButton() != nil else {
            setStatus("status.monitoring", icon: "dog.fill")
            return
        }

        if clickResumeButton() {
            lastResumeDate = Date()
            updateLocalizedMenu()
            setStatus("status.resumeSent", icon: "checkmark.circle")
        } else {
            setStatus("status.clickFailed", icon: "exclamationmark.triangle")
        }
        nextAllowedPress = Date().addingTimeInterval(retryCooldown)
    }

    @objc private func toggleMonitoring() {
        monitoring.toggle()
        toggleMenuItem.title = localized(monitoring ? "action.pause" : "action.resume")
        if monitoring {
            setStatus("status.monitoring", icon: "dog.fill")
            checkGoal()
        } else {
            setStatus("status.paused", icon: "pause.circle")
        }
    }

    @objc private func selectLanguage(_ sender: NSMenuItem) {
        guard let value = sender.representedObject as? String,
              let language = AppLanguage(rawValue: value) else {
            return
        }
        UserDefaults.standard.set(language.rawValue, forKey: appLanguageDefaultsKey)
        updateLocalizedMenu()
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
    precondition(localized("cli.selfTestPassed", language: .system) != "cli.selfTestPassed")
    precondition(localized("cli.selfTestPassed", language: .english) == "Self-test passed.")
    precondition(localized("cli.selfTestPassed", language: .traditionalChinese) == "自我測試通過。")
    print(localized("cli.selfTestPassed", language: .system))
    exit(0)
}

let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.run()
