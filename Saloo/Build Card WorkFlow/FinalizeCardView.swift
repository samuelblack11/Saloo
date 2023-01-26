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
    
    @State var coreCard: CoreCard!
    @State var cardRecord: CKRecord!
    @ObservedObject var chosenObject: ChosenCoverImageObject
    @ObservedObject var collageImage: CollageImage
    @ObservedObject var noteField: NoteField
    @State var frontCoverIsPersonalPhoto: Int
    @Binding var text1: String
    @Binding var text2: String
    @Binding var text2URL: URL
    @Binding var text3: String
    @Binding var text4: String
    @ObservedObject var addMusic: AddMusic
    @Binding var eCardText: String
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
    @State private var isAddingCard = false
    @State private var isSharing = false
    @State private var isProcessingShare = false
    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    @State private var pageCount = 1
    @ObservedObject var chosenOccassion: Occassion
    @ObservedObject var chosenSong: ChosenSong
    
    var body: some View {
        NavigationView {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0){
                eCardView(eCardText: eCardText, font: noteField.font, coverImage: chosenObject.coverImage, collageImage: collageImage.collageImage.pngData()!, text1: text1, text2: text2, text2URL: text2URL, text3: text3, text4: text4, songName: chosenSong.name, songArtistName: chosenSong.artistName, songArtImageData: chosenSong.artwork, songDuration: chosenSong.durationInSeconds).frame(width: (UIScreen.screenWidth/1.8), height: (UIScreen.screenHeight/1.4))
                Spacer()
            }
            Spacer()
            HStack {
                Button("Save eCard") {
                    //isAddingCard = true
                    Task {
                        saveCard(noteField: noteField, chosenOccassion: chosenOccassion, an1: text1, an2: text2, an2URL: text2URL.absoluteString, an3: text3, an4: text4, chosenObject: chosenObject, collageImage: collageImage)
                    }
                    //saveAndShareIsActive = true
                    showCompleteAlert = true
                }
                .fullScreenCover(isPresented: $showOccassions) {OccassionsMenu(calViewModel: CalViewModel(), showDetailView: ShowDetailView())}
                .fullScreenCover(isPresented: $showCollageMenu) {CollageStyleMenu(chosenObject: chosenObject, chosenOccassion: chosenOccassion, pageCount: pageCount, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)}
                .fullScreenCover(isPresented: $showUCV) {
                    UnsplashCollectionView(chosenOccassion: chosenOccassion, pageCount: pageCount, chosenObject: chosenObject, frontCoverIsPersonalPhoto: $frontCoverIsPersonalPhoto)
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
                //.fullScreenCover(isPresented: $isSharing, content: {shareView(coreCard: coreCard)})
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
        .fullScreenCover(isPresented: $showShareSheet, content: {if let share = share {}})
        .fullScreenCover(isPresented: $showActivityController) {ActivityView(activityItems: $activityItemsArray, applicationActivities: nil)}
        }
    }
    }

extension FinalizeCardView {
    
    private func saveCard(noteField: NoteField, chosenOccassion: Occassion, an1: String, an2: String, an2URL: String, an3: String, an4: String, chosenObject: ChosenCoverImageObject, collageImage: CollageImage) {
        let controller = PersistenceController.shared
        let taskContext = controller.persistentContainer.newTaskContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        controller.addCoreCard(noteField: noteField, chosenOccassion: chosenOccassion, an1: an1, an2: an2, an2URL: an2URL, an3: an3, an4: an4, chosenObject: chosenObject, collageImage: collageImage,context: taskContext)
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
