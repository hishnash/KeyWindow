//
//  HostingWindowFinder.swift
//  
//
//  Created by Matthaus Woolard on 27/12/2020.
//

import SwiftUI

#if canImport(UIKit)
struct HostingWindowFinder: UIViewRepresentable {
    var callback: (Window?) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let window = view.window
        DispatchQueue.main.async { [weak window] in
            self.callback(window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
#elseif canImport(AppKit)
struct HostingWindowFinder: NSViewRepresentable {
    var callback: (Window?) -> Void

    func makeNSView(context: Self.Context) -> NSView {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let window = view.window
        DispatchQueue.main.async { [weak window] in
            self.callback(window)
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
#else
    #error("Unsupported platform")
#endif
