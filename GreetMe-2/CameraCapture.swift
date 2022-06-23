//
//  CameraCapture.swift
//  GreetMe-2
//
//  Created by Sam Black on 6/22/22.
//

import Foundation
import SwiftUI

// https://medium.com/swlh/how-to-open-the-camera-and-photo-library-in-swiftui-9693f9d4586b
struct CameraCapture: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var isPresented
    var sourceType: UIImagePickerController.SourceType
 
    func makeUIViewController(context: Context) -> UIImagePickerController {
 
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        // Happens when Camera Opens (3)
        print("******")
        return imagePicker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
 
    }
    
    func makeCoordinator() -> Coordinator {
        // Happens when Camera Opens (1)
        print("+++++++")
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: CameraCapture
        
        init(_ picker: CameraCapture) {
            self.picker = picker
            // Happens when Camera Opens (2)
            print("------")

        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.picker.selectedImage = image
            }
            print(self.picker.isPresented)
            self.picker.isPresented.wrappedValue.dismiss()
            print(self.picker.isPresented)
        }
        
    }
}
