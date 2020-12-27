//
//  KeyWindowValuesPreference.swift
//  
//
//  Created by Matthaus Woolard on 27/12/2020.
//

import Foundation

import SwiftUI

struct KeyWindowValuesPreference {

    private var values: [String: AnyEquatable] = [:]

    subscript<Key>(_ key: Key.Type) -> Key.Value? where Key: KeyWindowValueKey, Key.Value: Equatable {
        get {
            guard let value = self.values[String(reflecting: Key.self)]?.base as? Key.Value else {
                return nil
            }
            return value
        } set {
            self.values[String(reflecting: Key.self)] = AnyEquatable(newValue)
        }
    }

    subscript<Key>(_ key: Key.Type) -> Key.Value? where Key: KeyWindowValueKey {
        get {
            guard let value = self.values[String(reflecting: Key.self)]?.base as? NonEquitableWrapper else {
                return nil
            }
            return value.base as? Key.Value
        } set {
            guard let newValue = newValue else { return }
            self.values[String(reflecting: Key.self)] = AnyEquatable(NonEquitableWrapper(base: newValue))
        }
    }
}

extension KeyWindowValuesPreference: Equatable {
    static func == (lhs: KeyWindowValuesPreference, rhs: KeyWindowValuesPreference) -> Bool {
        lhs.values == rhs.values
    }
}

extension KeyWindowValuesPreference: PreferenceKey {
    static var defaultValue: KeyWindowValuesPreference {
        KeyWindowValuesPreference()
    }

    static func reduce(value: inout KeyWindowValuesPreference, nextValue: () -> KeyWindowValuesPreference) {
        value.values += nextValue().values
    }
}

func += <K, V> (left: inout [K: V], right: [K: V]) {
    for (k, v) in right {
        left[k] = v
    }
}
