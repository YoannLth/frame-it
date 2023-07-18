//
//  WelcomeScreen.swift
//  frame-it
//
//  Created by Yoann LATHUILIERE on 18/07/2023.
//

import SwiftUI
import UniformTypeIdentifiers

let devices: [Device] = [
    Device(name: "iPhone 13 Pro", frame: Image("iPhone_13_Pro")),
    Device(name: "iPhone 8", frame: Image("iPhone_8")),
    Device(name: "Pixel 5", frame: Image("pixel_5"))
]

struct WelcomeScreen: View {
    @State private var images: [ImageWrapper] = []
    @State private var selectedDevice: Device = devices.first!
    @State private var showContextMenu = false
    
    
    
    struct DropView: View {
        var body: some View {
            VStack {
                Image(systemName: "plus.circle")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.white)
                
                Text("Drop image(s) here")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
            }
            .frame(maxWidth: .infinity, minHeight: 200)
            .background(Color.gray.opacity(0.2))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundColor(.white)
            )
        }
    }
    
    var body: some View {
        VStack {
            DropView()
                .padding()
                .onDrop(of: [.fileURL], isTargeted: nil) { providers, _ in
                    for provider in providers {
                        if provider.hasItemConformingToTypeIdentifier("public.file-url") {
                            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { urlData, error in
                                if let error = error {
                                    print("Error loading image: \(error.localizedDescription)")
                                    return
                                }
                                
                                if let urlData = urlData as? Data, let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                                    if let image = NSImage(contentsOf: url) {
                                        let fileName = provider.suggestedName ?? url.lastPathComponent
                                        DispatchQueue.main.async {
                                            images.append(ImageWrapper(image: Image(nsImage: image), fileName: fileName))
                                        }
                                    } else {
                                        print("Error loading image: Invalid image data at \(url)")
                                    }
                                } else {
                                    print("Error loading image: Invalid URL data")
                                }
                            }
                        } else {
                            print("Error loading image: Item is not a valid file URL")
                        }
                    }
                    return true
                }
            
            
            
            
            
            List(images, id: \.id) { imageWrapper in
                HStack {
                    imageWrapper.image
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text(imageWrapper.fileName)
                }
            }
            .frame(maxHeight: 150)
            .listStyle(SidebarListStyle())
            
            Picker("Select Device", selection: $selectedDevice) {
                ForEach(devices) { device in
                    Text(device.name).tag(device)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            HStack {
                Button(action: {
                    images.removeAll()
                }) {
                    Text("Clear")
                }
                
                Button(action: {
                    showContextMenu = true
                    
                    Task {
                        await processImages()
                    }
                }) {
                    Text("Frame it!")
                }
            }
            
        }
        .contextMenu(menuItems: {
            Button(action: {
                Task {
                    await processImages()
                }
            }) {
                Text("Select Location")
            }
        })
        .padding()
    }
    
    func processImages() async {
        // Process the images and add the device overlay
        for (index, imageWrapper) in images.enumerated() {
            let deviceFrame = selectedDevice.frame
            
            let processedImage = deviceFrame // add the device frame first in order to init the image with the size of the frame
                .resizable()
                .aspectRatio(contentMode: .fit)
                .overlay(imageWrapper.image) // add the screenshot on top of the frame
                .overlay(deviceFrame) // add again the device frame, otherwhise the screenshot would cover some part of the frame
            
            // Save the processed image
            guard let cgImage = await ImageRenderer(content: processedImage).cgImage else {
                return
            }
            
            let nsImage = NSImage(cgImage: cgImage, size: .init(width: 1024, height: 1024))
            let tiffData = nsImage.tiffRepresentation
            let bitmapImageRep = NSBitmapImageRep(data: tiffData!)
            let pngData = bitmapImageRep?.representation(using: .png, properties: [:])
            
            let downloadsFolderURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            let fileURL = downloadsFolderURL
                .appendingPathComponent("framed_\(imageWrapper.fileName.removingExtension).png")
            
            do {
                try pngData?.write(to: fileURL)
                print("Saved processed image at: \(fileURL.path)")
            } catch {
                print("Error saving processed image: \(error.localizedDescription)")
            }
            
            
            // Print the processed image name
            print("Processed Image \(index+1)")
        }
        
        // Clear the images
        images.removeAll()
    }
}

struct WelcomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeScreen()
    }
}
