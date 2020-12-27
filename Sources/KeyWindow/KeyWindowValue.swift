//
//  KeyWindowValue.swift
//  
//
//  Created by Matthaus Woolard on 27/12/2020.
//

import SwiftUI

@propertyWrapper
public struct KeyWindowValue<Key: KeyWindowValueKey>: DynamicProperty {

    @ObservedObject
    var keyWindowState: KeyWindowState = KeyWindowState.shared

    public var wrappedValue: Key.Value? {
        keyWindowState[Key.self]
    }

    public init(_ key: Key.Type) {}
}
