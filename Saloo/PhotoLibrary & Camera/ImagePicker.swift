//
//  ImagePicker2.swift
//  GreetMe-2
//
//  Created by Sam Black on 12/30/22.
//

import Foundation
import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    //@State private var showingAlert = false
    @Binding var explicitPhotoAlert: Bool
    @Binding var isImageLoading: Bool
    
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
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
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        //self.parent.image = image as? UIImage
                        //guard let image = self.parent.image else { return }
                        guard let selectedImage = image as? UIImage else { return }
                        let targetSize = CGSize(width: 800, height: 800)
                        let resizedImage = self.resizeImage(image: selectedImage, targetSize: targetSize)
                        //self.parent.image = resizedImage

                        // convert UIImage to base64 string
                        guard let imageData = resizedImage.jpegData(compressionQuality: 0.5) else { return }
                        let imageStr = imageData.base64EncodedString()
                        
                        // start loading indicator
                        self.parent.isImageLoading = true
                        
                        // use the function to check for explicit content
                        ContentModerator.checkImageForExplicitContent(imageBase64: imageStr) { isExplicitContent, error in
                            DispatchQueue.main.async {
                                // stop loading indicator
                                self.parent.isImageLoading = false
                                if let error = error {
                                    print("Content Mod Error...")
                                    print("An error occurred: \(error)")
                                    // Handle the error
                                } else if let isExplicitContent = isExplicitContent {
                                    // If the photo is adult or racy, show an alert
                                    if isExplicitContent {
                                        print("Detected explicit content..")
                                        AlertVars.shared.alertType = .explicitPhoto
                                        AlertVars.shared.activateAlert = true
                                        self.parent.image = nil // Reset the image
                                    }
                                    else {
                                        print("No explicit content detected...")
                                        self.parent.image = selectedImage
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
