//
//  CameraCapture.swift
//  GreetMe-2
//
//  Created by Sam Black on 6/22/22.
//

import Foundation
import SwiftUI
import UIKit
//
// Solved debug issue by not using environment isPresented var and toggling it. And by using picker.dismiss(animated: true) instead
struct CameraCapture: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    @Binding var explicitPhotoAlert: Bool
    var sourceType: UIImagePickerController.SourceType
 
    func makeCoordinator() -> ImagePickerViewCoordinator {
         return ImagePickerViewCoordinator(image: $image, isPresented: $isPresented, explicitPhotoAlert: $explicitPhotoAlert)
     }
     
     func makeUIViewController(context: Context) -> UIImagePickerController {
         let pickerController = UIImagePickerController()
         pickerController.sourceType = sourceType
         pickerController.delegate = context.coordinator
         return pickerController
     }

     func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
         // Nothing to update here
     }

}

class ImagePickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
     
     @Binding var image: UIImage?
     @Binding var isPresented: Bool
     @Binding var explicitPhotoAlert: Bool

     init(image: Binding<UIImage?>, isPresented: Binding<Bool>, explicitPhotoAlert: Binding<Bool>) {
         self._image = image
         self._isPresented = isPresented
         self._explicitPhotoAlert = explicitPhotoAlert
     }
     
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
             
             // convert UIImage to base64 string
             guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
             let imageStr = imageData.base64EncodedString(options: .endLineWithLineFeed)
             
             // Now use the function to check for explicit content
             ImageAnalysisService.checkImageForExplicitContent(imageBase64: imageStr) { isExplicitContent, error in
                 if let isExplicitContent = isExplicitContent {
                     if isExplicitContent {
                         print("Explicit content detected")
                         // Show an alert and dismiss the ImagePicker
                         self.explicitPhotoAlert = true
                         self.isPresented = false
                     } else {
                         print("No explicit content detected")
                         // Proceed to add the image to the collage
                         self.image = image
                         self.isPresented = false
                     }
                 } else if let error = error {
                     print("An error occurred: \(error)")
                     // Handle the error
                 }
             }
         }
     }
     
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true)
         self.isPresented = false
     }
     
 }
