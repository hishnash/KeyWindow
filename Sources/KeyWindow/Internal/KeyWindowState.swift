//
//  KeyWindowState.swift
//  ExampleWindowReader
//
//  Created by Matthaus Woolard on 26/12/2020.
//

import SwiftUI

public class KeyWindowState: ObservableObject {
    @Published
    var values = KeyWindowValuesPreference()
    
    weak var window: Window?

    init () {}
    
    public subscript<Key>(_ key: Key.Type) -> Key.Value? where Key: KeyWindowValueKey {
        self.values[key]
    }
    
    public static var shared: KeyWindowState = KeyWindowState()
    
    internal func didBecomeKey(window: Window, values: KeyWindowValuesPreference) {
        self.window = window
        self.values = values
    }

    internal func didResignKey(window: Window) {
        guard window === self.window else {
            return
        }
        self.window = nil
        self.values = KeyWindowValuesPreference()
    }
}
