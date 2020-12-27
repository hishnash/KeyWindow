//
//  EnvironmentValues.swift
//  
//
//  Created by Matthaus Woolard on 27/12/2020.
//

import SwiftUI

extension EnvironmentValues {
    internal struct IsKeyWindowKey: EnvironmentKey {
        static var defaultValue: Bool = false
        typealias Value = Bool
    }

    public internal(set) var isKeyWindow: Bool {
        get {
            self[IsKeyWindowKey.self]
        }
        set {
            self[IsKeyWindowKey.self] = newValue
        }
    }
}
