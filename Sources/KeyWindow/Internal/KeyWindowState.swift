//
//  KeyWindowState.swift
//  ExampleWindowReader
//
//  Created by Matthaus Woolard on 26/12/2020.
//

import SwiftUI

internal class KeyWindowState: ObservableObject {
    @Published
    var values = KeyWindowValuesPreference()

    init () {}
    
    subscript<Key>(_ key: Key.Type) -> Key.Value? where Key: KeyWindowValueKey {
        self.values[key]
    }
    
    static var shared: KeyWindowState = KeyWindowState()
}
