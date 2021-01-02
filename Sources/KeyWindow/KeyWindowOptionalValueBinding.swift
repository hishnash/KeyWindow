//
//  KeyWindowOptionalValueBinding.swift
//  
//
//  Created by Matthaus Woolard on 02/01/2021.
//

import SwiftUI


@propertyWrapper
public struct KeyWindowOptionalValueBinding<Key: KeyWindowValueKey, Value>: DynamicProperty where Key.Value == Binding<Optional<Value>> {

    public init(_ key: Key.Type) {}
    
    public init() where Key == Value {}
    
    // The`@ObservedObject` object needs to be set on a value type
    @ObservedObject
    var keyWindowState: KeyWindowState = KeyWindowState.shared

    // This needs to be wrapped in a Class type so that it is mutable
    @KeyWindowOptionalValueBindingMutableWrapper<Key, Value>
    public var wrappedValue: Value?

    public var projectedValue: Binding<Value?> {
        Binding {
            self.keyWindowState[Key.self]?.wrappedValue
        } set: { newValue in
            guard let binding = self.keyWindowState[Key.self] else { return }
            binding.wrappedValue = newValue
        }
    }

    public mutating func update() {
        // This method is called by SwiftUI just before the body is called.
        self._keyWindowState.update()
        // Pass key window State through to the mutable wrapper
        self._wrappedValue.keyWindowState = self.keyWindowState
    }
}

@propertyWrapper
public class KeyWindowOptionalValueBindingMutableWrapper<Key: KeyWindowValueKey, Value> where Key.Value == Binding<Optional<Value>> {

    public init() {}

    internal weak var keyWindowState: KeyWindowState?

    public var wrappedValue: Value? {
        get {
          self.keyWindowState?[Key.self]?.wrappedValue
        }
        set {
          guard let binding = self.keyWindowState?[Key.self] else { return }
          binding.wrappedValue = newValue
        }
    }
}
