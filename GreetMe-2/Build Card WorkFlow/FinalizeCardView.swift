//
//  FinalizeCardView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//

import Foundation
import SwiftUI
import CoreData
import CloudKit


struct FinalizeCardView: View {
    
    @State private var showOccassions = false
    @State private var showUCV = false
    @State private var showCollageMenu = false
    @State private var showCollageBuilder = false
    @State private var showWriteNote = false
    
    @State var card: Card!
    @State var cardRecord: CKRecord!
    @ObservedObject var chosenObject: ChosenCoverImageObject
    @Binding var collageImage: CollageImage!
    @ObservedObject var noteField: NoteField
    @State var frontCoverIsPersonalPhoto: Int
    @Binding var text1: String
    @Binding var text2: String
    @Binding var text2URL: URL
    @Binding var text3: String
    @Binding var text4: String
    @ObservedObject var willHandWrite: HandWrite
    @Binding var eCardText: String
    @Binding var printCardText: String
    //@Binding var cardForExport: Data!
    @State private var showActivityController = false
    @State var activityItemsArray: [Any] = []
    @State var saveAndShareIsActive = false
    @State private var showCompleteAlert = false
    var field1: String!
    var field2: String!
    @State var string1: String!
    @State var string2: String!
    @State private var showShareSheet = false
    @State var share: CKShare?
    @EnvironmentObject private var cm: CKModel
    @State private var isAddingCard = false
    @State private var isSharing = false
    @State private var isProcessingShare = false
    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    @State private var pageCount = 1
    @State var chosenCollection: ChosenCollection

    var eCardVertical: some View {
        VStack(spacing:1) {
            Image(uiImage: UIImage(data: chosenObject.coverImage)!)
                .interpolation(.none).resizable().scaledToFit()
                .frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/8))
            Text(eCardText)
                .font(Font.custom(noteField.font, size: 500)).minimumScaleFactor(0.01)
                .frame(maxWidth: (UIScreen.screenWidth/4), maxHeight: (UIScreen.screenHeight/9))
            Image(uiImage: collageImage.collageImage)
                .interpolation(.none).resizable().scaledToFit()
                .frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/8))
            HStack(spacing: 0) {
                VStack(spacing:0){
                Text(text1)
                    .font(.system(size: 4)).frame(alignment: .center)
                Link(text2, destination: text2URL)
                    .font(.system(size: 4)).frame(alignment: .center)
                HStack(spacing: 0) {
                    Text(text3).font(.system(size: 4))
                        .frame(alignment: .center)
                    Link(text4, destination: URL(string: "https://unsplash.com")!)
                        .font(.system(size: 4)).frame(alignment: .center)
                    }
                }
                Spacer()
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue).font(.system(size: 12)).frame(alignment: .center)
                Spacer()
                //VStack(spacing:0) {
                    //Text("Greeting Card by")
                        //.font(.system(size: 4))
                        //.frame(alignment: .center)
                    //Text("GreetMe Inc.")
                       //.font(.system(size: 4))
                        //.frame(alignment: .center)
                    //}
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
                    .frame(width: (UIScreen.screenWidth/4.5), height: (UIScreen.screenHeight/7), alignment: .center)
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
            }
            .frame(width: (UIScreen.screenWidth/4.5), height: (UIScreen.screenHeight/7))
            // Front Cover
            HStack(spacing: 1)  {
                Image(uiImage: UIImage(data: chosenObject.coverImage)!)
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
                HStack(spacing:0){cardForPrint}.frame(alignment: .center)
            }
            Spacer()
            HStack {
                Button("Save eCard") {
                    //isAddingCard = true
                    Task {
                        print("trying to save....")
                        try await cm.initialize()
                        try? await addCard(noteField: noteField, chosenCollection: chosenCollection, an1: text1, an2: text2, an2URL: text2URL.absoluteString, an3: text3, an4: text4, chosenObject: chosenObject, collageImage: collageImage)
                        //try? await shareCard(card)
                        print("saved")
                    }
                    //saveAndShareIsActive = true
                    showCompleteAlert = true
                }
                .fullScreenCover(isPresented: $showOccassions) {OccassionsMenu(calViewModel: CalViewModel(), showDetailView: ShowDetailView())}
                .fullScreenCover(isPresented: $showCollageMenu) {CollageStyleMenu(chosenObject: chosenObject, chosenCollection: chosenCollection, pageCount: pageCount, collageImage: collageImage, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)}
                .fullScreenCover(isPresented: $showUCV) {
                    UnsplashCollectionView(chosenCollection: chosenCollection, pageCount: pageCount, chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
                }
                .disabled(saveAndShareIsActive)
                .alert("Save Complete", isPresented: $showCompleteAlert) {
                    Button("Ok", role: .cancel) {
                        showCollageBuilder = false
                        showWriteNote = false
                        showCollageMenu = false
                        showUCV = false
                        showOccassions = true
                        let rootViewController = UIApplication.shared.connectedScenes
                                .filter {$0.activationState == .foregroundActive }
                                .map {$0 as? UIWindowScene }
                                .compactMap { $0 }
                                .first?.windows
                                .filter({ $0.isKeyWindow }).first?.rootViewController
                           rootViewController?.dismiss(animated: true)
                    }
                }
                .fullScreenCover(isPresented: $isSharing, content: {shareView(card: card)})
                Spacer()
                Button("Export for Print") {
                    showActivityController = true; let cardForExport = prepCardForExport()
                    activityItemsArray = []; activityItemsArray.append(cardForExport)
                }
            }
        }
        .navigationBarItems(
            leading:Button {}
            label: {Image(systemName: "chevron.left").foregroundColor(.blue)
            Text("Back")},
            trailing: Button {showOccassions = true} label: {Image(systemName: "menucard.fill").foregroundColor(.blue)
            Text("Menu")}
            )
        .fullScreenCover(isPresented: $showOccassions) {OccassionsMenu(calViewModel: CalViewModel(), showDetailView: ShowDetailView())}
        .fullScreenCover(isPresented: $showShareSheet, content: {if let share = share {CloudSharingView(share: share, container: CoreDataStack.shared.ckContainer, card: card)}})
        .fullScreenCover(isPresented: $showActivityController) {ActivityView(activityItems: $activityItemsArray, applicationActivities: nil)}
        }
    }
    }

extension FinalizeCardView {
    
    private func addCard(noteField: NoteField, chosenCollection: ChosenCollection
                         , an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: ChosenCoverImageObject, collageImage: CollageImage) async throws {
        try await cm.addCard(noteField: noteField, chosenCollection: chosenCollection, an1: an1, an2: an2, an2URL: an2URL, an3: an3, an4: an4, chosenObject: chosenObject, collageImage: collageImage)
        try await cm.refresh()
        isAddingCard = false
    }
    
    private func shareCard(_ card: Card) async throws {
        isProcessingShare = true
        do {
            let (share, container) = try await cm.fetchOrCreateShare(card: card)
            isProcessingShare = false
            activeShare = share
            activeContainer = container
            isSharing = true
        } catch {
            debugPrint("Error sharing contact record: \(error)")
        }
    }
    
    /// Builds a `CloudSharingView` with state after processing a share.
    private func shareView(card: Card) -> CloudSharingView? {
        guard let share = activeShare, let container = activeContainer else {
            return nil
        }

        return CloudSharingView(share: share, container: container, card: card)
    }
    
    func prepCardForExport() -> Data {
        let image = SnapShotCardForPrint(chosenObject: chosenObject, collageImage: $collageImage, noteField: noteField, text1: $text1, text2: $text2, text2URL: $text2URL, text3: $text3, text4: $text4, printCardText: $printCardText).snapshot()
        let a4_width = 595.2 - 20
        let a4_height = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: a4_width, height: a4_height)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData(actions: {ctx in ctx.beginPage()
        image.draw(in: pageRect)
        })
        return data
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
    
// https://medium.com/swiftui-made-easy/activity-view-controller-in-swiftui-593fddadee79
// https://www.hackingwithswift.com/example-code/uikit/how-to-render-pdfs-using-uigraphicspdfrenderer
// https://stackoverflow.com/questions/1134289/cocoa-core-data-efficient-way-to-count-entities
// https://www.advancedswift.com/resize-uiimage-no-stretching-swift/
// https://www.hackingwithswift.com/articles/103/seven-useful-methods-from-cgrect
// https://stackoverflow.com/questions/57727107/how-to-get-the-iphones-screen-width-in-swiftui
// https://www.hackingwithswift.com/read/33/4/writing-to-icloud-with-cloudkit-ckrecord-and-ckasset
// https://swiftwithmajid.com/2022/03/29/zone-sharing-in-cloudkit/
// https://swiftwithmajid.com/2022/03/29/zone-sharing-in-cloudkit/
// https://www.techotopia.com/index.php/An_Introduction_to_CloudKit_Data_Storage_on_iOS_8#Record_Zones
// https://github.com/apple/sample-cloudkit-sharing
// https://stackoverflow.com/questions/66313845/swiftui-dismiss-all-active-sheet-views
