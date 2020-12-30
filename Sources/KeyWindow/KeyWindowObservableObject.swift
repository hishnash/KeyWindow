//
//  KeyWindowObservableObject.swift
//  
//
//  Created by Matthaus Woolard on 28/12/2020.
//

import SwiftUI


@propertyWrapper
public struct KeyWindowObservableObject<Key: KeyWindowObservableObjectKey>: DynamicProperty {

    @ObservedObject
    var keyWindowState: KeyWindowState = KeyWindowState.shared

    @ObservedObject
    public var wrappedValue: Key.Value

    public init(_ key: Key.Type) {
        self.wrappedValue = KeyWindowState.shared[Key.self] ?? Key.defaultValue
    }
    
    public init() where Key == Key.Value {
        self.wrappedValue = KeyWindowState.shared[Key.self] ?? Key.defaultValue
    }
    
    mutating public func update() {
        self._keyWindowState.update()
        self.wrappedValue = KeyWindowState.shared[Key.self] ?? Key.defaultValue
    }
}

public protocol KeyWindowObservableObjectKey: KeyWindowValueKey where Value: ObservableObject {
    static var defaultValue: Value { get }
}
