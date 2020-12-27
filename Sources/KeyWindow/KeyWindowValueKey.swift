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
}
