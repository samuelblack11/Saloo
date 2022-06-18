//
//  FinalizeCardView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//

import Foundation
import SwiftUI
import CoreData


//https://medium.com/swiftui-made-easy/activity-view-controller-in-swiftui-593fddadee79

struct FinalizeCardView: View {
    @Environment(\.presentationMode) var presentationMode
    var card: Card!
    @Binding var chosenObject: CoverImageObject!
    @Binding var collageImage: CollageImage!
    @Binding var noteField: NoteField!
    @State var frontCoverIsPersonalPhoto: Int
    @Binding var text1: String
    @Binding var text2: String
    @Binding var text2URL: URL
    @Binding var text3: String
    @Binding var text4: String
    @State var presentMenu = false

    //@Binding var cardForExport: Data!
    @State private var showActivityController = false
    @State var activityItemsArray: [Any] = []
        
    var eCard: some View {
        HStack(spacing: 1) {
            // Front Cover
            Image(uiImage: chosenObject.coverImage).resizable().frame(width: (UIScreen.screenWidth/3)-2, height: (UIScreen.screenWidth/3))
            //upside down message
            Text(noteField.noteText).frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenWidth/3)).font(.system(size: 4))
            //upside down collage
            Image(uiImage: collageImage.collageImage).resizable().frame(width: (UIScreen.screenWidth/3)-2, height: (UIScreen.screenWidth/3))
        }
    }
    
    var cardForPrint: some View {
        VStack(spacing: 1) {
        HStack {
            //upside down collage
            HStack {
                Image(uiImage: collageImage.collageImage).resizable().frame(width: (UIScreen.screenWidth/5)-10, height: (UIScreen.screenWidth/5),alignment: .center)
                }.frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenWidth/3))
            //upside down message
            Text(noteField.noteText)
                .scaledToFill()
                .frame(width: (UIScreen.screenWidth/3)-30)
                //.font(.system(size: 4))
                .font(Font.custom("Papyrus", size: 4))
                
                .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
            }.rotationEffect(Angle(degrees: 180))
        // Front Cover & Back Cover
        HStack(spacing: 0) {
            //Back Cover
            VStack(spacing: 0) {
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue)
                    //.imageScale(.medium)
                    .font(.system(size: 48))
                Spacer()
                Text(text1)
                    .font(.system(size: 4))
                Link(text2, destination: text2URL)
                    .font(.system(size: 4))
                HStack(spacing: 0) {
                    Text(text3).font(.system(size: 4))
                    Link(text4, destination: URL(string: "https://unsplash.com")!).font(.system(size: 4))
                }.padding(.bottom,10)
                Text("Greeting Card by").font(.system(size: 6))
                Text("GreetMe Inc.").font(.system(size: 6)).padding(.bottom,10)
            }
            .frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenWidth/3))
            // Front Cover
            Image(uiImage: chosenObject.coverImage).resizable().frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenWidth/3))
            }
        }
    }


    var body: some View {
        NavigationView {
        VStack(spacing: 0) {
            Spacer()
            Text("Your eCard will be stored like this:").padding(.bottom, 5)
            eCard
            Spacer()
            Text("And will be printed like this:").padding(.bottom, 5)
            cardForPrint
            Spacer()
            HStack {
                VStack {
                Button("Save eCard") {
                    //save to core data
                    
                    let card = Card(context: DataController.shared.viewContext)
                    card.card = eCard.snapshot().pngData()
                    card.collage = collageImage.collageImage.pngData()
                    card.coverImage = chosenObject.coverImage.pngData()
                    card.date = Date.now
                    card.message = noteField.noteText
                    card.occassion = noteField.cardName
                    card.recipient = noteField.recipient
                    self.saveContext()
                    print("Saved card to Core Data")
                    // https://stackoverflow.com/questions/1134289/cocoa-core-data-efficient-way-to-count-entities
                    // Print Count of Cards Saved
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
                    let count = try! DataController.shared.viewContext.count(for: fetchRequest)
                    print("\(count) Cards Saved")  
                }
                    Button("Share eCard") {
                        showActivityController = true
                        let cardForShare = eCard.snapshot()
                        activityItemsArray = []
                        activityItemsArray.append(cardForShare)
                    }
                }
                /////////////////////////////////////////////////////////////////////////////////
                Spacer()
                Button("Export for Print") {
                    showActivityController = true
                    print("*****")
                    print(cardForPrint.snapshot())
                    print("*****")
                    print(prepCardForExport())
                    let cardForExport = prepCardForExport()
                    //print(cardForExport!)
                    activityItemsArray = []
                    activityItemsArray.append(cardForExport)
                }.sheet(isPresented: $showActivityController) {
                    ActivityView(activityItems: $activityItemsArray, applicationActivities: nil)
                }
            }
        }
        .navigationBarItems(
            leading:Button {presentationMode.wrappedValue.dismiss()}
            label: {Image(systemName: "chevron.left").foregroundColor(.blue)
            Text("Back")},
            trailing:Button {
                presentMenu = true
            }
                label: {Image(systemName: "menucard.fill").foregroundColor(.blue)
                Text("Menu")})
        .sheet(isPresented: $presentMenu) {MenuView()}
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
    
    
    func saveContext() {
        if DataController.shared.container.viewContext.hasChanges {
            do {
                try DataController.shared.container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }   
}

// https://stackoverflow.com/questions/57727107/how-to-get-the-iphones-screen-width-in-swiftui
extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
    
    struct ActivityView: UIViewControllerRepresentable {
       @Binding var activityItems: [Any]
       let applicationActivities: [UIActivity]?
       func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
          UIActivityViewController(activityItems: activityItems,
                                applicationActivities: applicationActivities)
       }
       func updateUIViewController(_ uiViewController: UIActivityViewController,
                                   context: UIViewControllerRepresentableContext<ActivityView>) {}
       }


