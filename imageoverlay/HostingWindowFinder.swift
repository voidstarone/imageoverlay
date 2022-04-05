//
//  HostingWindowFinder.swift
//  imageoverlay
//
//  Created by Thomas Lee on 05/04/2022.
//

import Foundation
import Cocoa
import SwiftUI
#if canImport(UIKit)
    typealias Window = UIWindow
#elseif canImport(AppKit)
    typealias Window = NSWindow
#else
    #error("Unsupported platform")
#endif

#if canImport(UIKit)
struct HostingWindowFinder: UIViewRepresentable {
    var callback: (Window?) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
#elseif canImport(AppKit)
struct HostingWindowFinder: NSViewRepresentable {
    var callback: (Window?) -> ()

    func makeNSView(context: Self.Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
#else
    #error("Unsupported platform")
#endif

class WindowObserver: ObservableObject {
    weak var window: Window?
}
