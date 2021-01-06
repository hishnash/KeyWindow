//
//  KeyWindowValueKey.swift
//  
//
//  Created by Matthaus Woolard on 27/12/2020.
//

import SwiftUI

public protocol KeyWindowValueKey {
    associatedtype Value
    
    static func toAnyEquatable(_ value: Value) ->  AnyEquatable
    static func fromAnyEquatable(_ value: AnyEquatable) -> Value?
}

public extension KeyWindowValueKey where Value: Equatable {
    static func toAnyEquatable(_ value: Value) ->  AnyEquatable {
        AnyEquatable(value)
    }
    
    static func fromAnyEquatable(_ value: AnyEquatable) -> Value? {
        value.base as? Value
    }
}

public extension KeyWindowValueKey {
    static func toAnyEquatable(_ value: Value) ->  AnyEquatable {
        AnyEquatable(NonEquitableWrapper(base: value))
    }
    
    static func fromAnyEquatable(_ value: AnyEquatable) -> Value? {
        (value.base as? NonEquitableWrapper)?.base as? Value
    }
}


public extension View {
    func keyWindow<Key>(_ key: Key.Type, _ value: Key.Value) -> some View where Key: KeyWindowValueKey {
        self.transformPreference(KeyWindowValuesPreference.self) { existingValue in
            existingValue[key] = value
        }
    }
    
    func keyWindow<Key>(_ key: Key.Type, _ value: Optional<Key.Value>) -> some View where Key: KeyWindowValueKey {
        self.transformPreference(KeyWindowValuesPreference.self) { existingValue in
            guard let value = value else { return }
            existingValue[key] = value
        }
    }
    
    func keyWindow<Value>(_ value: Value) -> some View where Value: KeyWindowValueKey, Value.Value == Value {
        self.transformPreference(KeyWindowValuesPreference.self) { existingValue in
            existingValue[Value.self] = value
        }
    }
    
    func keyWindow<Value>(_ value: Optional<Value>) -> some View where Value: KeyWindowValueKey, Value.Value == Value {
        self.transformPreference(KeyWindowValuesPreference.self) { existingValue in
            guard let value = value else { return }
            existingValue[Value.self] = value
        }
    }
    
    func keyWindow<Value>(_ value: Binding<Value>) -> some View where Value: KeyWindowValueKey, Value.Value == Binding<Value> {
        self.transformPreference(KeyWindowValuesPreference.self) { existingValue in
            existingValue[Value.self] = value
        }
    }
}

/// A type-erased `AnyKeyWindowValueKey`
internal struct AnyKeyWindowValueKey {
    /// The key's type represented erased to an `Any.Type`.
    internal let keyType: Any.Type

    internal init<Key>(_ keyType: Key.Type) where Key: KeyWindowValueKey {
        self.keyType = keyType
    }
}

extension AnyKeyWindowValueKey: Hashable {
    static func == (lhs: AnyKeyWindowValueKey, rhs: AnyKeyWindowValueKey) -> Bool {
        return ObjectIdentifier(lhs.keyType) == ObjectIdentifier(rhs.keyType)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self.keyType))
    }
}

extension AnyKeyWindowValueKey: CustomStringConvertible {
  var description: String {
    return String(describing: self.keyType.self)
  }
}

extension AnyKeyWindowValueKey: CustomDebugStringConvertible {
  var debugDescription: String {
    return "AnyKeyWindowValueKey(" + String(reflecting: self.keyType.self) + ")"
  }
}

extension AnyKeyWindowValueKey: CustomReflectable {
  var customMirror: Mirror {
    Mirror(
        self,
        children: ["value": self.keyType.self]
    )
  }
}
