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
import MessageUI

struct GridofCards: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var toggleProgress: Bool = false
    @State private var hasAnyShare: Bool?
    @State private var isCardShared: Bool?
    @State var isAddingCard = false
    @State var isProcessingShare = false
    @State var showCloudShareController = false
    @State var activeShare: CKShare?
    @State var activeContainer: CKContainer?
    @State var cards = [Card]()
    @State var coreCards: [CoreCard] = []
    @State var segueToEnlarge = false
    @State var share: CKShare?
    @State var showShareSheet = false
    @State var showEditSheet = false
    @State var returnRecord: CKRecord?
    @State var showDeliveryScheduler = false
    @State var whichBoxVal: InOut.SendReceive
    @State private var sortByValue = "Card Name"
    @State private var searchText = ""
    @State private var nameToDisplay: String?
    @State private var userID = UserDefaults.standard.object(forKey: "SalooUserID") as? String
    @State private var displayCard = false
    //@State var chosenCard: CoreCard?
    //@EnvironmentObject var chosenCardParent: ChosenCoreCard
    @State var cardToReport: CoreCard?
    @State var cardToReportThenDelete: CoreCard?
    @State var cardToDelete: CoreCard?
    @State var shouldShareCard: Bool = false
    @EnvironmentObject var wrapper: CoreCardWrapper
    @State var cardQueuedForshare: CoreCard?
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @ObservedObject var gettingRecord = GettingRecord.shared
    @State private var showReportOffensiveContentView = false
    @EnvironmentObject var spotifyManager: SpotifyManager
    @EnvironmentObject var persistenceController: PersistenceController
    @EnvironmentObject var appState: AppState
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
    let columns = [GridItem(.adaptive(minimum: 120))]
    @State private var isShowingMessageComposer = false
    @EnvironmentObject var linkURL: LinkURL
    @State private var currentUserRecordID: CKRecord.ID?

    func fetchCurrentUserRecordID() {
        persistenceController.cloudKitContainer.fetchUserRecordID { ckRecordID, error in
            DispatchQueue.main.async {self.currentUserRecordID = ckRecordID}
        }
    }
    
    
    func calculateGridColumns() -> [GridItem] {
        let screenWidth = UIScreen.main.bounds.width
        let columns = Int(screenWidth / 160) // Adjust the width (160) based on your desired card width
        return Array(repeating: .init(.flexible()), count: columns)
    }
    
    
    

    var sortOptions = ["Date (New to Old)", "Date (Old to New)","Card Name","Occassion","Sender"]
    
    func determineDisplayName(coreCard: CoreCard) -> String {
        switch whichBoxVal {
        case .outbox: return coreCard.recipient
        case .inbox: return coreCard.sender!
        case .draftbox: return coreCard.recipient
        }
    }
    
    struct SearchBar: View {
        @Binding var text: String
        var body: some View {
            ZStack(alignment: .leading) {
                TextField("Search by Card Name", text: $text)
                    .font(Font.custom("Papyrus", size: 16))
                    .padding(7)
                    .padding(.leading, 30) // padding to position the text after the icon
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 10) // padding to position the icon
            }
            .padding(.horizontal)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                CustomNavigationBar(onBackButtonTap: {appState.currentScreen = .startMenu}, titleContent: whichBoxVal == .inbox ? .text("Cards from Others") : .text("Cards from Me"))
                SearchBar(text: $searchText)
                ZStack {
                    ScrollView {
                        sortResults
                        LazyVGrid(columns: calculateGridColumns(), spacing: 10) {
                            ForEach(sortedCards(cardsFilteredBySearch, sortBy: sortByValue), id: \.self) { gridCard in
                                cardView(for: gridCard, shareable: false)
                            }
                        }
                       // .searchable(text: $searchText, prompt: "Search by Card Name")
                    }
                    LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
                }
            }
            .onAppear{
            fetchCurrentUserRecordID()
            loadCards()
                
            }
            .fullScreenCover(item: $cardToReport, onDismiss: didDismiss) {cardToReport in
                ReportOffensiveContentView(card: $cardToReport, whichBoxVal: $whichBoxVal, coreCards: $coreCards)}
        }
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, alertDismissAction: {
            deleteCoreCard(coreCard: cardToDelete!)}))
        // "Search by \(sortByValue)"
        .sheet(isPresented: $isShowingMessageComposer) {MessageComposerView(linkURL: URL(string: linkURL.linkURL)!, fromFinalize: false)}
    }
    
    func didDismiss() {appState.cardFromShare = nil}
    
    private func cardView(for gridCard: CoreCard, shareable: Bool = true) -> some View {
        VStack(spacing: 0) {
            VStack(spacing:1) {
                VStack {
                    if gridCard.unsplashImageURL != "https://salooapp.com" {
                        AsyncImage(url: URL(string: gridCard.unsplashImageURL!)) { image in
                            image.resizable()} placeholder: {ProgressView()}
                    } else if let coverUIImage = UIImage(data: gridCard.coverImage!) {
                        Image(uiImage: coverUIImage).resizable()
                    }
                }
                .frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/7))
                Text(gridCard.message)
                    .font(Font.custom(gridCard.font, size: 500)).minimumScaleFactor(0.01)
                    .frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/8))
                Image(uiImage: UIImage(data: gridCard.collage!)!)
                    .resizable()
                    .frame(maxWidth: (UIScreen.screenWidth/4), maxHeight: (UIScreen.screenHeight/7))
                HStack(spacing: 0) {
                    Image(systemName: "greetingcard.fill").foregroundColor(Color("SalooTheme")).font(.system(size: 24))
                }
            }
            .onTapGesture {}
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
            .padding().overlay(RoundedRectangle(cornerRadius: 6).stroke(Color("SalooTheme"), lineWidth: 2))
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
        if card.creator == userID  {
            Button {
                if networkMonitor.isConnected{createLink(uniqueName: card.uniqueName)}
                else{alertVars.alertType = .failedConnection; alertVars.activateAlert = true}
            } label: {Text("Share Card"); Image(systemName: "person.badge.plus")}
        }
        Button {
            if networkMonitor.isConnected {
                ImageLoader.shared.loadImage(from: card.unsplashImageURL!) { data in
                    DispatchQueue.main.async {
                        appState.cardFromShare?.coverImage = data
                        appState.cardFromShare = card; chosenGridCardType = card.cardType;segueToEnlarge = true; displayCard = true
                    }
                }
            }
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
    
    func createLink(uniqueName: String) {
          var components = URLComponents()
          components.scheme = "https"
          components.host = Config.shared.shareURL
          
          let queryItems = [
              URLQueryItem(name: "uniqueName", value: uniqueName)
          ]
          
          components.queryItems = queryItems

          if let richLinkURL = components.url {
              linkURL.linkURL = richLinkURL.absoluteString
              sendViaMessages(richLinkURL: richLinkURL)
          } else {
              print("Failed to create rich link URL")
          }
      }



    func sendViaMessages(richLinkURL: URL) {
        if MFMessageComposeViewController.canSendText() && MFMessageComposeViewController.canSendAttachments() {
            let messageComposer = MFMessageComposeViewController()
            messageComposer.body = richLinkURL.absoluteString
            
            // Present the message composer view controller
            isShowingMessageComposer = true
        } else {
            print("Cannot send message")
        }
    }
    
    func sortedCards(_ cards: [CoreCard], sortBy: String) -> [CoreCard] {
        var sortedCards = cards
        if sortBy == "Date (New to Old)" {sortedCards.sort {$0.date > $1.date}}
        if sortBy == "Date (Old to New)" {sortedCards.sort {$0.date < $1.date}}
        if sortBy == "Card Name" {sortedCards.sort {$0.cardName < $1.cardName}}
        if sortBy == "Occasion" {sortedCards.sort {$0.occassion < $1.occassion}}
        if sortBy == "Sender" {sortedCards.sort {$0.sender ?? "" < $1.sender ?? ""}}
        return sortedCards
    }
    
    var sortResults: some View {
        VStack {
            HStack {
                Text("Sort By:").padding(.leading, 5).font(Font.custom("Papyrus", size: 16))
                Picker("", selection: $sortByValue) {ForEach(sortOptions, id:\.self) {sortOption in Text(sortOption)}}
                Spacer()
            }
            if coreCards.count > 0 {
                Text("Tap and Hold to Access Card")
                    .font(Font.custom("Papyrus", size: 16))
                    .textCase(.none)
            }
        }
    }
    
    

    
    func deleteCoreCard(coreCard: CoreCard) {
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
