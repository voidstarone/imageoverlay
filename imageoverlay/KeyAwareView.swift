//
//  KeyAwareView.swift
//  imageoverlay
//
//  Created by Thomas Lee on 05/04/2022.
//

import Foundation
import SwiftUI

struct KeyAwareView: NSViewRepresentable {
    let onEvent: (Event) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = KeyView()
        view.onEvent = onEvent
        DispatchQueue.main.async {
            view.window?.makeFirstResponder(view)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension KeyAwareView {
    enum Event {
        case upArrow
        case downArrow
        case leftArrow
        case rightArrow
        case space
        case delete
        case cmdC
        case enter
        case section
        case keyboard0
        case keyboard1
        case keyboard2
        case keyboard3
        case keyboard4
        case keyboard5
        case keyboard6
        case keyboard7
        case keyboard8
        case keyboard9
        case paste
    }
}

private class KeyView: NSView {
    var onEvent: (KeyAwareView.Event) -> Void = { _ in }

    static let keyMap: [Int: KeyAwareView.Event] = [
        51: .delete,
        126: .upArrow,
        125: .downArrow,
        123: .leftArrow,
        124: .rightArrow,
        49: .space,
        10: .section,
        29: .keyboard0, // Why
        18: .keyboard1,
        19: .keyboard2,
        20: .keyboard3,
        21: .keyboard4,
        23: .keyboard5,
        22: .keyboard6, // Seriously?
        26: .keyboard7, // Who came up with this shit?
        28: .keyboard8,
        25: .keyboard9,
        76: .enter,
        36: .enter
    ]
    
    override var acceptsFirstResponder: Bool { true }
    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            if event.keyCode == 9 { // cmd + v
                onEvent(.paste)
            }
        }
        if let key = KeyView.keyMap[Int(event.keyCode)] {
            onEvent(key)
        }
    }
}
