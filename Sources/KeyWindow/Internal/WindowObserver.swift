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
            guard let window = window else { return }
            guard isKeyWindow else {
                self.appState?.didResignKey(window: window)
                return
            }
            self.appState?.didBecomeKey(window: window, values: values)
        }
    }

    private weak var appState: KeyWindowState? = KeyWindowState.shared

    private var becomeKeyObserver: NSObjectProtocol?
    private var resignKeyObserver: NSObjectProtocol?
    
    #if canImport(AppKit)
        private var willCloseObserver: NSObjectProtocol?
    #endif
    
    internal var values: KeyWindowValuesPreference = KeyWindowValuesPreference() {
        didSet {
            guard let window = window else { return }
            guard self.isKeyWindow else {
                self.appState?.didResignKey(window: window)
                return
            }
            self.appState?.didBecomeKey(window: window, values: values)
        }
    }

    weak var window: Window? {
        didSet {
            self.isKeyWindow = window?.isKeyWindow ?? false
            guard let window = window else {
                self.becomeKeyObserver = nil
                self.resignKeyObserver = nil
                #if canImport(AppKit)
                    self.willCloseObserver = nil
                #endif
                return
            }

            self.becomeKeyObserver = NotificationCenter.default.addObserver(
                forName: Window.didBecomeKeyNotification,
                object: window,
                queue: .main
            ) { [weak self] (_) in
                self?.isKeyWindow = true
            }

            self.resignKeyObserver = NotificationCenter.default.addObserver(
                forName: Window.didResignKeyNotification,
                object: window,
                queue: .main
            ) { [weak self] (_) in
                self?.isKeyWindow = false
            }
            
            #if canImport(AppKit)
                self.willCloseObserver = NotificationCenter.default.addObserver(
                    forName: Window.willCloseNotification,
                    object: window,
                    queue: .main
                ) { [weak self] (_) in
                    self?.isKeyWindow = false
                }
            #endif
        }
    }
}
