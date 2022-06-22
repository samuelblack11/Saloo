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
        //imagePicker.allowsEditing = false
        imagePicker.sourceType = self.sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
 
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(picker: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var picker: CameraCapture
        
        init(picker: CameraCapture) {
            self.picker = picker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else { return }
            self.picker.selectedImage = selectedImage
            self.picker.isPresented.wrappedValue.dismiss()
        }
        
    }
}
