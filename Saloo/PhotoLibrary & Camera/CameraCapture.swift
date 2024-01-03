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
    @Binding var isImageLoading: Bool

    func makeCoordinator() -> ImagePickerViewCoordinator {
        return ImagePickerViewCoordinator(image: $image, isPresented: $isPresented, explicitPhotoAlert: $explicitPhotoAlert, isImageLoading: $isImageLoading)
     }
     
     func makeUIViewController(context: Context) -> UIImagePickerController {
         let pickerController = UIImagePickerController()
         pickerController.sourceType = sourceType
         pickerController.delegate = context.coordinator
         return pickerController
     }

     func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

}

class ImagePickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
     
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    @Binding var explicitPhotoAlert: Bool
    @Binding var isImageLoading: Bool

    init(image: Binding<UIImage?>, isPresented: Binding<Bool>, explicitPhotoAlert: Binding<Bool>, isImageLoading: Binding<Bool>) {
        self._image = image
        self._isPresented = isPresented
        self._explicitPhotoAlert = explicitPhotoAlert
        self._isImageLoading = isImageLoading
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
     
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }

        // Resize the image to make sure it's within the 4MB limit
        let targetSize = CGSize(width: 800, height: 800)
        let resizedImage = self.resizeImage(image: selectedImage, targetSize: targetSize)
        
        // convert UIImage to base64 string
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.5) else { return }
        let imageStr = imageData.base64EncodedString()

        // start loading indicator
        self.isImageLoading = true
        
        // use the function to check for explicit content
        ContentModerator.checkImageForExplicitContent(imageBase64: imageStr) { isExplicitContent, error in
            DispatchQueue.main.async {
                // stop loading indicator
                self.isImageLoading = false
                if let error = error {
                    print("An error occurred: \(error)")
                    // Handle the error
                } else if let isExplicitContent = isExplicitContent {
                    // If the photo is adult or racy, show an alert
                    if isExplicitContent {
                        print("Detected explicit content..")
                        AlertVars.shared.alertType = .explicitPhoto
                        AlertVars.shared.activateAlert = true
                        self.image = nil
                    }
                    else {
                        print("No explicit content detected...")
                        self.image = selectedImage
                    }
                }
            }
        }
        self.isPresented = false
    }
     
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isImageLoading = false
        picker.dismiss(animated: true)
        self.isPresented = false
    }
}
