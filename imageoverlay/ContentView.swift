//
//  ContentView.swift
//  imageoverlay
//
//  Created by Thomas Lee on 05/04/2022.
//

import SwiftUI
import Cocoa

class ImageStore: ObservableObject {
    @Published var image: NSImage?
}

var imageStore = ImageStore()

func imgPathFromClipboard() -> URL? {
    let pb = NSPasteboard.general
    if let read = pb.string(forType: NSPasteboard.PasteboardType(
        rawValue: "public.file-url"
    )) {
        return URL(string:read)!
    }
    return nil
}

func imgFromClipboard() -> NSImage {
    let pb = NSPasteboard.general
    let type = NSPasteboard.PasteboardType.png
    guard let imgData = pb.data(forType: type) else {
        if let read = pb.string(forType: NSPasteboard.PasteboardType(
            rawValue: "public.file-url"
        )) {
            return NSImage(byReferencing: URL(string:read)!)
        }
        return NSImage()
    }
    return NSImage(data: imgData) ?? NSImage()
}


struct ContentView: View {
    @StateObject
    var windowObserver: WindowObserver = WindowObserver()
    @State var opacity: CGFloat = 0.6
    @State var lastOpacity: CGFloat = 0
    @State var window: NSWindow?
    @ObservedObject var imgStore = imageStore
    var dropArea = DroppableArea()
    
    var body: some View {
        HostingWindowFinder { [weak windowObserver] window in
            windowObserver?.window = window
            window?.isOpaque = false
            self.window = window!
        }.background(
            dropArea
        ).background(
             KeyAwareView() {
                 event in
                 if event == .paste {
                     let img = imgFromClipboard()
                     imgStore.image = img
                 }
                 if event == .enter {
                     if window?.level == .floating {
                         window?.level = .normal
                     } else {
                         window?.level = .floating
                     }
                 }
                 if event == .space {
                     if opacity > 0 {
                         lastOpacity = opacity
                         opacity = 0
                     } else {
                         opacity = lastOpacity
                     }
                 }
                 if event == .upArrow {
                     opacity += 0.1
                 }
                 if event == .downArrow {
                     opacity -= 0.1
                 }
                 if event == .keyboard0 {
                     opacity = 1
                 }
                 if event == .section { opacity = 0.0 }
                 if event == .keyboard1 { opacity = 0.1 }
                 if event == .keyboard2 { opacity = 0.2 }
                 if event == .keyboard3 { opacity = 0.3 }
                 if event == .keyboard4 { opacity = 0.4 }
                 if event == .keyboard5 { opacity = 0.5 }
                 if event == .keyboard6 { opacity = 0.6 }
                 if event == .keyboard7 { opacity = 0.7 }
                 if event == .keyboard8 { opacity = 0.8 }
                 if event == .keyboard9 { opacity = 0.9 }
                 window?.backgroundColor = NSColor(calibratedWhite: 1, alpha: opacity)
             }
        ).opacity(opacity)
    }
    
}



struct ImageDropView: View {
    
    @State var url: URL?
    @State var image: NSImage?
    @ObservedObject var imgStore = imageStore
    var body: some View {
        let img = Image(nsImage: imgStore.image ?? (url != nil ? NSImage(byReferencing: url!) : {
            let pb = NSPasteboard.general
            let type = NSPasteboard.PasteboardType.png
            guard let imgData = pb.data(forType: type) else {
                if let read = pb.string(
                    forType: NSPasteboard.PasteboardType(rawValue: "public.file-url")
                ) {
                    imageStore.image = NSImage(byReferencing: URL(string:read)!)
                    return imageStore.image!
                }
                return NSImage()
            }
            image = NSImage(data: imgData)
            return image ?? NSImage()
        }())).resizable().aspectRatio(contentMode: .fit)
        return Rectangle().overlay(img)
    }
}

struct DroppableArea: View {
    var dropView = ImageDropView(url: nil)
    
    @State internal var imageUrl: URL? {
        mutating didSet {
            dropView.url = imageUrl
        }
    }
    
    mutating func setNewUrl(_ url: URL?) {
        dropView.url = url
    }
    
    var body: some View {
        let dropDelegate = MyDropDelegate()
        
        return dropView.background(Rectangle().fill(Color.gray))
        .onDrop(of: ["public.file-url"], delegate: dropDelegate)
        
    }
}

struct MyDropDelegate: DropDelegate {
    @ObservedObject var imgStore = imageStore
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: ["public.file-url"])
    }

    func performDrop(info: DropInfo) -> Bool {
        if let item = info.itemProviders(for: ["public.file-url"]).first {
            item.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                DispatchQueue.main.async {
                    if let urlData = urlData as? Data {
                        let imageUrl = NSURL(
                            absoluteURLWithDataRepresentation: urlData,
                            relativeTo: nil
                        ) as URL
                        imageStore.image = NSImage(byReferencing: imageUrl)
                    }
                }
            }
            return true
        }
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
