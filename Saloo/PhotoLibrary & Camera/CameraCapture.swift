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
    //@Environment(\.presentationMode) private var isPresented
    var sourceType: UIImagePickerController.SourceType
 
    func makeCoordinator() -> ImagePickerViewCoordinator {
         return ImagePickerViewCoordinator(image: $image, isPresented: $isPresented)
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
     
     init(image: Binding<UIImage?>, isPresented: Binding<Bool>) {
         self._image = image
         self._isPresented = isPresented
     }
     
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         picker.dismiss(animated: true)
         if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
             self.image = image
         }
         //self.isPresented = false
     }
     
     func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         picker.dismiss(animated: true)

         //self.isPresented = false
         print(self.isPresented)
     }
     
 }
