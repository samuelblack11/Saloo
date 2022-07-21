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
// https://www.hackingwithswift.com/example-code/uikit/how-to-render-pdfs-using-uigraphicspdfrenderer
// https://stackoverflow.com/questions/1134289/cocoa-core-data-efficient-way-to-count-entities
// https://www.advancedswift.com/resize-uiimage-no-stretching-swift/
// https://www.hackingwithswift.com/articles/103/seven-useful-methods-from-cgrect
// https://stackoverflow.com/questions/57727107/how-to-get-the-iphones-screen-width-in-swiftui

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
    @ObservedObject var willHandWrite: HandWrite
    @Binding var eCardText: String
    @Binding var printCardText: String
    //@Binding var cardForExport: Data!
    @State private var showActivityController = false
    @State var activityItemsArray: [Any] = []
    @State var searchObject: SearchParameter
    //@State private var isPhotoShared: Bool
    //@State private var hasAnyShare: Bool

    func coverSource() -> Image {
        if chosenObject.coverImage != nil {
            return Image(uiImage: UIImage(data: chosenObject.coverImage!)!)
        }
        else {
            return Image(uiImage: UIImage(data: try! Data(contentsOf: chosenObject.smallImageURL))!)
        }
    }
    
    func coverData() -> Data? {
        if chosenObject.coverImage != nil {
            return chosenObject.coverImage!
        }
        else {
            return try! Data(contentsOf: chosenObject.smallImageURL)
        }
    }
    
    
    func shareECardInternally() {
        print("&&&&&&")
        print(PersistenceController.shared.privatePersistentStore.options?.count)
        if PersistenceController.shared.privatePersistentStore.contains(manageObject: compileCard()) {
            createNewShare(card: compileCard())
        }
    }
    
    func compileCard() -> Card {
        //save to core data
        let card = Card(context: PersistenceController.shared.persistentContainer.viewContext)
        card.card = eCardVertical.snapshot().pngData()
        card.collage = collageImage.collageImage.pngData()
        card.coverImage = coverData()!
        card.date = Date.now
        card.message = noteField.noteText
        card.occassion = searchObject.searchText
        card.cardName = noteField.cardName
        card.recipient = noteField.recipient
        card.font = noteField.font
        card.an1 = text1
        card.an2 = text2
        card.an2URL = text2URL.absoluteString
        card.an3 = text3
        card.an4 = text4
        return card
    }
    
    func saveECard() {
        //save to core data
        let card = Card(context: PersistenceController.shared.persistentContainer.viewContext)
        card.card = eCardVertical.snapshot().pngData()
        card.collage = collageImage.collageImage.pngData()
        card.coverImage = coverData()!
        card.date = Date.now
        card.message = noteField.noteText
        card.occassion = searchObject.searchText
        card.cardName = noteField.cardName
        card.recipient = noteField.recipient
        card.font = noteField.font
        card.an1 = text1
        card.an2 = text2
        card.an2URL = text2URL.absoluteString
        card.an3 = text3
        card.an4 = text4

        self.saveContext()
        print("Saved card to Core Data")
        // Print Count of Cards Saved
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
        let count = try! PersistenceController.shared.persistentContainer.viewContext.count(for: fetchRequest)
        print("\(count) Cards Saved")
    }
        
    func shareECardExternally() {
        showActivityController = true
        let cardForShare = SnapShotECard(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, eCardText: $eCardText, text1: $text1, text2: $text2, text2URL: $text2URL, text3: $text3, text4: $text4).snapShotECardViewVertical.snapshot()
        activityItemsArray = []
        activityItemsArray.append(cardForShare)
    }
    
    var eCardVertical: some View {
        VStack(spacing:1) {
            coverSource()
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/8))
            Text(eCardText)
                .font(Font.custom(noteField.font, size: 500))
                .minimumScaleFactor(0.01)
                .frame(maxWidth: (UIScreen.screenWidth/4), maxHeight: (UIScreen.screenHeight/9))
            Image(uiImage: collageImage.collageImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/8))
            HStack(spacing: 0) {
                VStack(spacing:0){
                Text(text1)
                    .font(.system(size: 4))
                    .frame(alignment: .center)
                Link(text2, destination: text2URL)
                    .font(.system(size: 4))
                    .frame(alignment: .center)
                HStack(spacing: 0) {
                    Text(text3).font(.system(size: 4))
                        .frame(alignment: .center)
                    Link(text4, destination: URL(string: "https://unsplash.com")!)
                        .font(.system(size: 4))
                        .frame(alignment: .center)
                    }
                }
                Spacer()
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 12))
                    .frame(alignment: .center)
                Spacer()
                VStack(spacing:0) {
                    Text("Greeting Card by")
                        .font(.system(size: 4))
                        .frame(alignment: .center)
                    Text("GreetMe Inc.")
                        .font(.system(size: 4))
                        .frame(alignment: .center)
                    }
                }.frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/22))
        }.frame(width: (UIScreen.screenWidth/3.5), height: (UIScreen.screenHeight/2.5))
    }
    
    var cardForPrint: some View {
        VStack(spacing: 1) {
            HStack(spacing: 1) {
            //upside down collage
                Image(uiImage: collageImage.collageImage)
                    .resizable()
                    .frame(width: (UIScreen.screenWidth/4.5), height: (UIScreen.screenHeight/7), alignment: .center)
            //upside down message
                Text(printCardText)
                    .font(Font.custom(noteField.font, size: 500))
                    .minimumScaleFactor(0.01)
                    .padding(.init(top: 0, leading: 5, bottom: 0, trailing: 5))
                }
                .rotationEffect(Angle(degrees: 180))
                .frame(width: (UIScreen.screenWidth/2.25), height: (UIScreen.screenHeight/7), alignment: .center)

        // Front Cover & Back Cover
        HStack(spacing: 1)  {
            //Back Cover
            VStack(spacing: 1) {
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 32))
                Spacer()
                Text(text1)
                    .font(.system(size: 4))
                Link(text2, destination: text2URL)
                    .font(.system(size: 4))
                HStack(spacing: 0) {
                    Text(text3)
                        .font(.system(size: 4))
                    Link(text4, destination: URL(string: "https://unsplash.com")!)
                        .font(.system(size: 4))
                }
                .padding(.bottom,10)
                Text("Greeting Card by")
                    .font(.system(size: 6))
                Text("GreetMe Inc.")
                    .font(.system(size: 6))
                    .padding(.bottom,5)
            }
            .frame(width: (UIScreen.screenWidth/4.5), height: (UIScreen.screenHeight/7))
            // Front Cover
            HStack(spacing: 1)  {
                coverSource()
                    .resizable()
            }.frame(width: (UIScreen.screenWidth/4.5), height: (UIScreen.screenHeight/7))
            }.frame(width: (UIScreen.screenWidth/2.25))
        }
    }


    var body: some View {
        NavigationView {
        VStack(spacing: 0) {
            HStack(spacing: 0){
                Text("Your eCard will be stored like this:").frame(width: (UIScreen.screenWidth/3), height: (UIScreen.screenHeight/3))
                eCardVertical
            }
            Spacer()
            Divider()
            Spacer()
            HStack(spacing:0){
                Text("And will be printed like this:")
                HStack(spacing:0){
                    cardForPrint
                }.frame(alignment: .center)
            }
            Spacer()
            HStack {
                VStack {
                    Button("Share eCard In App") {
                        shareECardInternally()
                    }
                    Button("Share eCard Externally") {
                        shareECardExternally()
                    }
                }
                /////////////////////////////////////////////////////////////////////////////////
                Spacer()
                VStack {
                    Button("Save eCard") {
                        saveECard()
                    }
                    
                    Button("Export for Print") {
                        showActivityController = true
                        print(prepCardForExport())
                        let cardForExport = prepCardForExport()
                        activityItemsArray = []
                        activityItemsArray.append(cardForExport)
                    }.sheet(isPresented: $showActivityController) {
                        ActivityView(activityItems: $activityItemsArray, applicationActivities: nil)
                    }
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
        let image = SnapShotCardForPrint(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, text1: $text1, text2: $text2, text2URL: $text2URL, text3: $text3, text4: $text4, printCardText: $printCardText).snapshot()
        let a4_width = 595.2 - 20
        let a4_height = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: a4_width, height: a4_height)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData(actions: {ctx in ctx.beginPage()
        image.draw(in: pageRect)
        })
        return data
    }
    
    
    /**
     Use UICloudSharingController to manage the share in iOS.
     In watchOS, UICloudSharingController is unavailable, so create the share using Core Data API.
     */
    #if os(iOS)
    private func createNewShare(card: Card) {
         PersistenceController.shared.presentCloudSharingController(card: card)
    }
    
    private func manageParticipation(card: Card) {
        PersistenceController.shared.presentCloudSharingController(card: card)
    }
    
    #elseif os(watchOS)
    /**
     Sharing a photo can take a while, so dispatch to a global queue so SwiftUI has a chance to show the progress view.
     @State variables are thread-safe, so there's no need to dispatch back the main queue.
     */
    private func createNewShare(card: Card) {
        toggleProgress.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            PersistenceController.shared.shareObject(card, to: nil) { share, error in
                toggleProgress.toggle()
                if let share = share {
                    nextSheet = .participantView(share)
                    activeSheet = nil
                }
            }
        }
    }
    
    private func manageParticipation(card: Card) {
        nextSheet = .managingSharesView
        activeSheet = nil
    }
    #endif
    
    /**
     Ignore the notification in the following cases:
     - It isn't relevant to the private database.
     - It doesn't have a transaction. When a share changes, Core Data triggers a store remote change notification with no transaction.
     */
    private func processStoreChangeNotification(_ notification: Notification) {
        guard let storeUUID = notification.userInfo?[UserInfoKey.storeUUID] as? String,
              storeUUID == PersistenceController.shared.privatePersistentStore.identifier else {
            return
        }
        guard let transactions = notification.userInfo?[UserInfoKey.transactions] as? [NSPersistentHistoryTransaction],
              transactions.isEmpty else {
            return
        }
        //isPhotoShared = (PersistenceController.shared.existingShare(card: card) != nil)
       // hasAnyShare = PersistenceController.shared.shareTitles().isEmpty ? false : true
    }
    
    
    func saveContext() {
        if PersistenceController.shared.persistentContainer.viewContext.hasChanges {
            do {
                try PersistenceController.shared.persistentContainer.viewContext.save()
                }
            catch {
                print("An error occurred while saving: \(error)")
                }
            }
        }
}

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


