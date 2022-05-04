//
//  FinalizeCardView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//

import Foundation
import SwiftUI

struct Card {
    var card: Image
    var coverImage: Image
    var collage: Image
    var date: Date
    //var message: TextField
    var occassion: String
    var recipient: String
}

struct FinalizeCardView: View {
    
    @Binding var chosenObject: CoverImageObject!
    @Binding var collageImage: CollageImage!
    @Binding var noteField: NoteField!
    
    var eCard: some View {
        HStack(spacing: 1) {
            // Front Cover
            chosenObject.coverImage.resizable().frame(width: (UIScreen.screenWidth/3)-2, height: (UIScreen.screenWidth/3))
            //upside down message
            Text(noteField.noteText).frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenWidth/3))
            //upside down collage
            collageImage.collageImage.resizable().frame(width: (UIScreen.screenWidth/3)-2, height: (UIScreen.screenWidth/3))
        }
    }
    
    
    var cardForPrint: some View {
        VStack {
        HStack(spacing: 0) {
            //upside down collage
            collageImage.collageImage.resizable().frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenWidth/3))
            //upside down message
            Text(noteField.noteText).frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenWidth/3)).font(.system(size: 12))
            }.rotationEffect(Angle(degrees: 180))
        // Front Cover & Back Cover
        HStack(spacing: 0) {
            //Back Cover
            VStack(spacing: 0) {
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue)
                    //.imageScale(.medium)
                    .font(.system(size: 30))
                Spacer()
                Text("Front Cover By ").font(.system(size: 8))
                Link(String(chosenObject.coverImagePhotographer), destination: URL(string: "https://unsplash.com/@\(chosenObject.coverImageUserName)")!).font(.system(size: 8))
                HStack(spacing: 0) {
                Text("On ").font(.system(size: 8))
                Link("Unsplash", destination: URL(string: "https://unsplash.com")!).font(.system(size: 8))
                }.padding(.bottom,10)
                Text("Greeting Card by").font(.system(size: 12))
                Text("GreetMe Inc.").font(.system(size: 12))
            }.frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenWidth/3))
            // Front Cover
            chosenObject.coverImage.resizable().frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenWidth/3))
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("Your eCard will be stored like this:")
            eCard
            Spacer()
            Text("And will be printed like this:")
            cardForPrint
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    //https://stackoverflow.com/questions/56533564/showing-uiactivityviewcontroller-in-swiftui
                    let shareController = UIActivityViewController(activityItems: [prepCardForExport()], applicationActivities: nil)
                    if let vc = UIApplication.shared.windows.first?.rootViewController{
                    shareController.popoverPresentationController?.sourceView = vc.view
                    //Setup share activity position on screen on bottom center
                    shareController.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height, width: 0, height: 0)
                    shareController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
                    vc.present(shareController, animated: true, completion: nil)
                    }
                }) {Text("Export Card for Print")}
            }
        }
    }
    
    
    func prepCardForExport() -> Data {
        
        // https://www.advancedswift.com/resize-uiimage-no-stretching-swift/
        let image = cardForPrint.snapshot()
        //let imageRect_w = 350
        //let imageRect_h = 325
        let a4_width = 595.2 - 20
        let a4_height = 841.8
        //let imageRect = CGRect(x: 0, y: 0, width: imageRect_w , height: imageRect_h)
        // https://www.hackingwithswift.com/example-code/uikit/how-to-render-pdfs-using-uigraphicspdfrenderer
        let pageRect = CGRect(x: 0, y: 0, width: a4_width, height: a4_height)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        //let textAttributes = [NSAttributedString.Key.font: noteView.font]
        //let formattedText = NSAttributedString(string: noteView.text, attributes: textAttributes as [NSAttributedString.Key : Any])
        
        let data = renderer.pdfData(actions: {ctx in ctx.beginPage()
            // Append formattedText to collageView
                //.insetBy(dx: 50, dy: 50)
            // https://www.hackingwithswift.com/articles/103/seven-useful-methods-from-cgrect
            image.draw(in: pageRect)
            //formattedText.draw(in: pageRect.offsetBy(dx: pageRect_X_offset, dy: pageRect_Y_offset))
        })
        return data
    }
    
    
    
    
    
    
}

// https://stackoverflow.com/questions/57727107/how-to-get-the-iphones-screen-width-in-swiftui
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
