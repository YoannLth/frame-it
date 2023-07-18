//
//  WelcomeScreen.swift
//  frame-it
//
//  Created by Yoann LATHUILIERE on 18/07/2023.
//

import SwiftUI

struct ImageWrapper: Identifiable {
    let id = UUID()
    let image: Image
}

struct WelcomeScreen: View {
    @State private var images: [ImageWrapper] = []
    @State private var selectedDevice: Device?
    @State private var showContextMenu = false
    
    let devices: [Device] = [
        Device(name: "iPhone 8", frame: Image("iphone8-frame")),
        Device(name: "iPhone Xr", frame: Image("iphonexr-frame"))
        // Add more devices and their corresponding frames here
    ]
    
    var body: some View {
        VStack {
            Text("Drop image(s) here")
                .padding()
                .onDrop(of: [.fileURL], isTargeted: nil) { providers, _ in
                    for provider in providers {
                        provider.loadDataRepresentation(forTypeIdentifier: "public.image") { data, error in
                            if let error = error {
                                print("Error loading image: \(error.localizedDescription)")
                                return
                            }
                            
                            if let data = data, let image = NSImage(data: data) {
                                DispatchQueue.main.async {
                                    images.append(ImageWrapper(image: Image(nsImage: image)))
                                }
                            }
                        }
                    }
                    return true
                }
            
            List(images, id: \.id) { imageWrapper in
                HStack {
                    imageWrapper.image
                        .resizable()
                        .frame(width: 50, height: 50)
                    Text("Image Name")
                }
            }
            .frame(maxHeight: 200)
            .listStyle(SidebarListStyle())
            
            Picker("Select Device", selection: $selectedDevice) {
                ForEach(devices) { device in
                    Text(device.name).tag(device)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Button(action: {
                showContextMenu = true
            }) {
                Text("Frame it!")
            }
        }
        .contextMenu(menuItems: {
            Button(action: processImages) {
                Text("Select Location")
            }
        })
        .padding()
    }
    
    func processImages() {
        guard let selectedDevice = selectedDevice else {
            return
        }
        
        // Process the images and add the device overlay
        for (index, image) in images.enumerated() {
            let deviceFrame = selectedDevice.frame
            // Apply device frame overlay to the image here
            
            // Save the processed image
            // ...
            
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
