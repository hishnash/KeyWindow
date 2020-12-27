//
//  WindowObserver.swift
//
//
//  Created by Matthaus Woolard on 27/12/2020.
//

import SwiftUI

#if canImport(UIKit)
    typealias Window = UIWindow
#elseif canImport(AppKit)
    typealias Window = NSWindow
#else
    #error("Unsupported platform")
#endif

class WindowObserver: ObservableObject {

    @Published
    internal private(set) var isKeyWindow: Bool = false {
        didSet {
            guard isKeyWindow else {
                return
            }
            self.appState?.values = self.values
        }
    }

    private weak var appState: KeyWindowState? = KeyWindowState.shared

    private var becomeKeyObserver: NSObjectProtocol?
    private var resignKeyObserver: NSObjectProtocol?

    var valueMap: [String: Any] = [:]

    internal var values: KeyWindowValuesPreference = KeyWindowValuesPreference() {
        didSet {
            guard self.isKeyWindow else { return }
            self.appState?.values = self.values
        }
    }

    weak var window: Window? {
        didSet {
            self.isKeyWindow = window?.isKeyWindow ?? false
            guard let window = window else {
                self.becomeKeyObserver = nil
                self.resignKeyObserver = nil
                return
            }

            self.becomeKeyObserver = NotificationCenter.default.addObserver(
                forName: Window.didBecomeKeyNotification,
                object: window,
                queue: .main
            ) { (_) in
                self.isKeyWindow = true
            }

            self.resignKeyObserver = NotificationCenter.default.addObserver(
                forName: Window.didResignKeyNotification,
                object: window,
                queue: .main
            ) { (_) in
                self.isKeyWindow = false
            }
        }
    }
}
