//
//  KeyWindowValueKey.swift
//  
//
//  Created by Matthaus Woolard on 27/12/2020.
//

import SwiftUI

public protocol KeyWindowValueKey {
    associatedtype Value
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
