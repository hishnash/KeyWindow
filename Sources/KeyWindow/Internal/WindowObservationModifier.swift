//
//  WindowObservationModifier.swift
//  
//
//  Created by Matthaus Woolard on 27/12/2020.
//

import SwiftUI

struct WindowObservationModifier: ViewModifier {
    @StateObject
    var windowObserver: WindowObserver = WindowObserver()

    func body(content: Content) -> some View {
        content
        .environment(\.isKeyWindow, windowObserver.isKeyWindow)
        .background(
            HostingWindowFinder { [weak windowObserver] window in
                windowObserver?.window = window
            }
        )
        .onPreferenceChange(KeyWindowValuesPreference.self, perform: { value in
            windowObserver.values = value
        })
    }
}

public extension View {
    func observeWindow() -> some View {
        self.modifier(WindowObservationModifier())
    }
}
