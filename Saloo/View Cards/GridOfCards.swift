//
//  GridOfCards.swift
//  GreetMe-2
//
//  Created by Sam Black on 12/17/22.
//
// 
import Foundation
import SwiftUI
import CloudKit
import CoreData
import AVFoundation
import AVFAudio

struct GridofCards: View {
    @State private var toggleProgress: Bool = false
    @State private var hasAnyShare: Bool?
    @State private var isCardShared: Bool?
    @State var isAddingCard = false
    @State var isProcessingShare = false
    @State var showCloudShareController = false
    @State var activeShare: CKShare?
    @State var activeContainer: CKContainer?
    @State private var showStartMenu = false
    @State var cards = [Card]()
    @State private var coreCards: [CoreCard] = []
    @State var segueToEnlarge = false
    @State var share: CKShare?
    @State var showShareSheet = false
    @State var showEditSheet = false
    @State var returnRecord: CKRecord?
    @State var showDeliveryScheduler = false
    @State var whichBoxVal: InOut.SendReceive
    let columns = [GridItem(.adaptive(minimum: 120))]
    @State private var sortByValue = "Card Name"
    @State private var searchText = ""
    @State private var nameToDisplay: String?
    @State private var userID = UserDefaults.standard.object(forKey: "SalooUserID") as? String
    @State private var displayCard = false
    @State var chosenCard: CoreCard?
    @State var cardToReport: CoreCard?
    @State var cardToDelete: CoreCard?
    @State var shouldShareCard: Bool = false
    @EnvironmentObject var wrapper: CoreCardWrapper
    @State var cardQueuedForshare: CoreCard?
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @ObservedObject var gettingRecord = GettingRecord.shared
    @State private var showReportOffensiveContentView = false
    @EnvironmentObject var spotifyManager: SpotifyManager
    @EnvironmentObject var persistenceController: PersistenceController
    @State private var hasShownLaunchView: Bool = true

    var cardsFilteredBySearch: [CoreCard] {
        if searchText.isEmpty { return coreCards}
        //else if sortByValue == "Card Name" {return privateCards.filter { $0.cardName.contains(searchText)}}
        //else if sortByValue == "Date" {return privateCards.filter { $0.cardName.contains(searchText)}}
        //else if sortByValue == "Occassion" {return privateCards.filter { $0.occassion!.contains(searchText)}}
        else {return coreCards.filter {$0.cardName.contains(searchText)}}
    }
    @State var cardSelectionNumber: Int?
    @State var chosenGridCard: CoreCard? = nil
    @EnvironmentObject var appDelegate: AppDelegate
    @State var chosenGridCardType: String?
    @ObservedObject var alertVars = AlertVars.shared
    @EnvironmentObject var cardsForDisplayEnv: CardsForDisplay

    @State private var currentUserRecordID: CKRecord.ID?

    func fetchCurrentUserRecordID() {
        persistenceController.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
            DispatchQueue.main.async {self.currentUserRecordID = ckRecordID}
        }
    }
    
    
    
    
    
    

    var sortOptions = ["Date","Card Name","Occassion"]
    
    func determineDisplayName(coreCard: CoreCard) -> String {
        switch whichBoxVal {
        case .outbox: return coreCard.recipient
        case .inbox: return coreCard.sender!
        case .draftbox: return coreCard.recipient
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    sortResults
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(sortedCards(cardsFilteredBySearch, sortBy: sortByValue), id: \.self) { gridCard in
                            cardView(for: gridCard, shareable: false)
                        }
                    }
                }
                LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)

            }
            .onAppear{
            print("Grid Appeared...")
            fetchCurrentUserRecordID()
            loadCards()
                
            }
            .fullScreenCover(item: $cardToReport, onDismiss: didDismiss) {cardToReport in
                ReportOffensiveContentView(card: $cardToReport)}
            .fullScreenCover(item: $chosenCard, onDismiss: didDismiss) {chosenCard in
                NavigationView {
                    eCardView(eCardText: chosenCard.message, font: chosenCard.font, coverImage: chosenCard.coverImage!, collageImage: chosenCard.collage!, text1: chosenCard.an1, text2: chosenCard.an2, text2URL: URL(string: chosenCard.an2URL)!, text3: chosenCard.an3, text4: chosenCard.an4, songID: chosenCard.songID, spotID: chosenCard.spotID, spotName: chosenCard.spotName, spotArtistName: chosenCard.spotArtistName, songName: chosenCard.songName, songArtistName: chosenCard.songArtistName, songAlbumName: chosenCard.songAlbumName, appleAlbumArtist: chosenCard.appleAlbumArtist, spotAlbumArtist: chosenCard.spotAlbumArtist, songArtImageData: chosenCard.songArtImageData, songDuration: Double(chosenCard.songDuration!)!, songPreviewURL: chosenCard.songPreviewURL, inclMusic: chosenCard.inclMusic, spotImageData: chosenCard.spotImageData, spotSongDuration: Double(chosenCard.spotSongDuration!)!, spotPreviewURL: chosenCard.spotPreviewURL, songAddedUsing: chosenCard.songAddedUsing, cardType: chosenCard.cardType!, associatedRecord: chosenCard.associatedRecord, coreCard: chosenCard, chosenCard: $chosenCard, appleSongURL: chosenCard.appleSongURL, spotSongURL: chosenCard.spotSongURL)
                    }
            }
            .navigationTitle("Your Cards")
            .navigationBarItems(leading:Button {print("Back Button pressed to Start menu..."); showStartMenu.toggle()} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
        }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, alertDismissAction: {
            deleteCoreCard(coreCard: cardToDelete!)}))
        // "Search by \(sortByValue)"
        .searchable(text: $searchText, prompt: "Search by Card Name")
        .fullScreenCover(isPresented: $showStartMenu) {StartMenu()}
        
    }
    
    func didDismiss() {chosenCard = nil}
    
    private func cardView(for gridCard: CoreCard, shareable: Bool = true) -> some View {
            VStack(spacing: 0) {
                VStack(spacing:1) {
                    Image(uiImage: UIImage(data: gridCard.coverImage!)!)
                        .resizable()
                        .frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/7))
                    Text(gridCard.message)
                        .font(Font.custom(gridCard.font, size: 500)).minimumScaleFactor(0.01)
                        .frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/8))
                    Image(uiImage: UIImage(data: gridCard.collage!)!)
                        .resizable()
                        .frame(maxWidth: (UIScreen.screenWidth/4), maxHeight: (UIScreen.screenHeight/7))
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            Text(gridCard.an1).font(.system(size: 4))
                            Link(gridCard.an2, destination: URL(string: gridCard.an2URL)!).font(.system(size: 4))
                            Text(gridCard.an3).font(.system(size: 4))
                            Link(gridCard.an4, destination: URL(string: "https://unsplash.com")!).font(.system(size: 4))
                        }.padding(.trailing, 5)
                        Spacer()
                        Image(systemName: "greetingcard.fill").foregroundColor(.blue).font(.system(size: 24))
                        Spacer()
                        VStack(spacing:0) {
                            Text("Greeting Card").font(.system(size: 4))
                            Text("by").font(.system(size: 4))
                            Text("Saloo").font(.system(size: 4)).padding(.bottom,10).padding(.leading, 5)
                        }}.frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/15))
                }
                .onTapGesture {print("gridCard Card Name...\(gridCard.cardName)")}
                //.sheet(isPresented: $showDeliveryScheduler) {ScheduleDelivery(card: card)}
                Divider().padding(.bottom, 5)
                HStack(spacing: 3) {
                    Text(determineDisplayName(coreCard: gridCard)).font(.system(size: 8)).minimumScaleFactor(0.1)
                    Spacer()
                    Text(gridCard.cardName).font(.system(size: 8)).minimumScaleFactor(0.1)
                }
            }
            .contextMenu {
                contextMenuButtons(card: gridCard)
            }
            .padding().overlay(RoundedRectangle(cornerRadius: 6).stroke(.blue, lineWidth: 2))
                .font(.headline).padding(.horizontal).frame(maxHeight: 600)
                
        
        }
}

// MARK: Returns CKShare participant permission, methods and properties to share
extension GridofCards {
    
    private func loadCards() {
        // use whichBoxVal to determine which cards to load
        switch whichBoxVal {
        case .draftbox:
            coreCards = cardsForDisplayEnv.draftboxCards
        case .inbox:
            coreCards = cardsForDisplayEnv.inboxCards
        case .outbox:
            coreCards = cardsForDisplayEnv.outboxCards
        }
    }
    
    @ViewBuilder func contextMenuButtons(card: CoreCard) -> some View {
        if let currentUserRecordID = self.currentUserRecordID, card.creator == currentUserRecordID.recordName {
            if persistenceController.privatePersistentStore.contains(manageObject: card) {
                Button("Share Card") {showCloudShareController = true;
                    if networkMonitor.isConnected{createNewShare(coreCard: card)}
                    else{alertVars.alertType = .failedConnection; alertVars.activateAlert = true}}
                .disabled(cardsForDisplayEnv.shareStatus(card: card).0)
            }
            Button {
                if networkMonitor.isConnected{manageParticipation(coreCard: card)}
                else{alertVars.alertType = .failedConnection; alertVars.activateAlert = true}
            } label: {Text("Manage Participation"); Image(systemName: "person.badge.plus")}
        }
        Button {
            if networkMonitor.isConnected {chosenCard = card; chosenGridCardType = card.cardType;segueToEnlarge = true; displayCard = true}
            else {alertVars.alertType = .failedConnection; alertVars.activateAlert = true}
        } label: {Text("View Card"); Image(systemName: "plus.magnifyingglass")}
        Button(action: {
            alertVars.alertType = .deleteCard
            alertVars.activateAlert = true
            cardToDelete = card
        }) {HStack {Text("Delete Card"); Image(systemName: "trash") }}
        Button(action: {cardToReport = card}) {
            HStack {Text("Report Offensive Content"); Image(systemName: "exclamationmark.octagon")}}
        }
    
    private func createNewShare(coreCard: CoreCard) {persistenceController.presentCloudSharingController(coreCard: coreCard)}
    private func manageParticipation(coreCard: CoreCard) {persistenceController.presentCloudSharingController(coreCard: coreCard)}
    private func processStoreChangeNotification(_ notification: Notification) {
        guard let storeUUID = notification.userInfo?[UserInfoKey.storeUUID] as? String,
              storeUUID == persistenceController.privatePersistentStore.identifier else {
            return
        }
        guard let transactions = notification.userInfo?[UserInfoKey.transactions] as? [NSPersistentHistoryTransaction],
              transactions.isEmpty else {
            return
        }
        //isCardShared = (persistenceController.existingShare(coreCard: card) != nil)
        hasAnyShare = persistenceController.shareTitles().isEmpty ? false : true
    }

    func sortedCards(_ cards: [CoreCard], sortBy: String) -> [CoreCard] {
        var sortedCards = cards
        if sortBy == "Date" {sortedCards.sort {$0.date < $1.date}}
        if sortBy == "Card Name" {sortedCards.sort {$0.cardName < $1.cardName}}
        if sortBy == "Occasion" {sortedCards.sort {$0.occassion < $1.occassion}}
        return sortedCards
    }
    
    var sortResults: some View {
        VStack {
            HStack {
                Text("Sort By:").padding(.leading, 5).font(Font.custom(sortByValue, size: 12))
                Picker("", selection: $sortByValue) {ForEach(sortOptions, id:\.self) {sortOption in Text(sortOption)}}
                Spacer()
            }
            if coreCards.count > 0 {
                Text("Tap and Hold to Access Card")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .textCase(.none)
            }
        }
    }
    
    func deleteCoreCard(coreCard: CoreCard) {
        do {persistenceController.persistentContainer.viewContext.delete(coreCard);try persistenceController.persistentContainer.viewContext.save()}
        catch {}
        cardsForDisplayEnv.deleteCoreCard(card: coreCard, box: whichBoxVal)
        loadCards()
    }
    
    func deleteAllCoreCards() {
        let request = CoreCard.createFetchRequest()
        var cardsFromCore: [CoreCard] = []
        do {cardsFromCore = try persistenceController.persistentContainer.viewContext.fetch(request); for card in cardsFromCore {deleteCoreCard(coreCard: card)}}
        catch{}
    }
    
    struct RedTextButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .foregroundColor(.red)
        }
    }

}

extension CKRecord{
    var wasCreatedByThisUser: Bool{
        return (creatorUserRecordID == nil) || (creatorUserRecordID?.recordName == "__defaultOwner__")
    }
}
