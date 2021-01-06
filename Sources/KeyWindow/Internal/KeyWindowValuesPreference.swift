//
//  KeyWindowValuesPreference.swift
//  
//
//  Created by Matthaus Woolard on 27/12/2020.
//

import Foundation

import SwiftUI

struct KeyWindowValuesPreference {

    private var values: [AnyKeyWindowValueKey: AnyEquatable] = [:]

    subscript<Key>(_ key: Key.Type) -> Key.Value? where Key: KeyWindowValueKey {
        get {
            guard let value = self.values[AnyKeyWindowValueKey(key.self)] else {
                return nil
            }
            return key.fromAnyEquatable(value)
        } set {
            guard let newValue = newValue else { return }
            self.values[AnyKeyWindowValueKey(key.self)] = key.toAnyEquatable(newValue)
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
