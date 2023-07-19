//
//  AppState.swift
//  Saloo
//
//  Created by Sam Black on 6/13/23.
//

import Foundation
import SwiftUI
import CloudKit
class AppState: ObservableObject {
    static let shared = AppState()
    @Published var pauseMusic = false
    @Published var cardFromShare: CoreCard?
    enum Screen {
        case login
        case launch
        case startMenu
        case buildCard([BuildCardSteps]) // BuildCardSteps is an enum representing each step of the workflow
        case draft
        case inbox
        case outbox
        case preferences
    }
    
    
    enum BuildCardSteps {
        case photoOptionsView
        case occasionsMenu
        case unsplashCollectionView
        case confirmFrontCoverView
        case collageBuilder
        case writeNoteView
        case musicSearchView
        case finalizeCardView
        // any other steps you have
    }

    @Published var currentScreen: Screen = UserDefaults.standard.bool(forKey: "FirstLaunch") ? .preferences : .startMenu
}

struct ContentView: View {
    @EnvironmentObject var apiManager: APIManager
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var cardsForDisplay: CardsForDisplay
    @EnvironmentObject var userSession: UserSession
    @EnvironmentObject var screenManager: ScreenManager
    @State private var hasShownLaunchView: Bool
    @State private var offsetLaunchView = CGFloat.zero
    // An array of IDs to cycle through
    private let ids = Array(1...5)
    // The current index in the ID array
    @State private var currentIndex = 0
    @State var falseBool = false
    @State var emptyCard: CoreCard? = CoreCard()
    @State var cardFromShare: CoreCard?
    func didDismiss() {cardFromShare = nil}
    var animationDuration  = 0.3

    // custom initializer
    init(hasShownLaunchView: Bool? = nil, cardFromShare: CoreCard? = nil) {
        _hasShownLaunchView = State(initialValue: hasShownLaunchView ?? false)
        _cardFromShare = State(initialValue: cardFromShare)
    }

    var body: some View {
        ZStack {
            Group {
                if userSession.isSignedIn {
                    switch appState.currentScreen {
                    case .login:
                        EmptyView()
                    case .launch:
                        EmptyView()
                    case .startMenu:
                        StartMenu()
                    case .buildCard(let steps):
                        BuildCardView(steps: steps)
                    case .draft:
                        GridofCards(whichBoxVal: .draftbox)
                            .id(screenManager.currentId)
                    case .inbox:
                        GridofCards(whichBoxVal: .inbox)
                            .id(screenManager.currentId)
                    case .outbox:
                        GridofCards(whichBoxVal: .outbox)
                            .id(screenManager.currentId)
                    case .preferences:
                        PrefMenu()
                    }
                    
                    if !hasShownLaunchView  && userSession.isSignedIn {
                        LaunchView(isFirstLaunch: false, isPresentedFromECardView: $falseBool, cardFromShare: $emptyCard)
                            .offset(x: offsetLaunchView, y: 0)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation {offsetLaunchView = -UIScreen.main.bounds.width}
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        hasShownLaunchView = true
                                        appState.currentScreen = UserDefaults.standard.bool(forKey: "FirstLaunch") ? .preferences : .startMenu
                                    }
                                }
                            }
                    }
                } else {LaunchView(isFirstLaunch: true, isPresentedFromECardView: $falseBool, cardFromShare: $cardFromShare)}
            }
        }
        .onReceive(appState.$cardFromShare){cardFromShare in self.cardFromShare = cardFromShare}
        .fullScreenCover(item: $cardFromShare, onDismiss: didDismiss) {cardFromShare in
            NavigationView {
                
                
                eCardView(eCardText: cardFromShare.message, font: cardFromShare.font, collageImage: cardFromShare.collage, text1: cardFromShare.an1, text2: cardFromShare.an2, text2URL: URL(string: cardFromShare.an2URL)!, text3: cardFromShare.an3, text4: cardFromShare.an4, songID: cardFromShare.songID, spotID: cardFromShare.spotID, spotName: cardFromShare.spotName, spotArtistName: cardFromShare.spotArtistName, songName: cardFromShare.songName, songArtistName: cardFromShare.songArtistName, songAlbumName: cardFromShare.songAlbumName, appleAlbumArtist: cardFromShare.appleAlbumArtist, spotAlbumArtist: cardFromShare.spotAlbumArtist, songArtImageData: cardFromShare.songArtImageData, songDuration: Double(cardFromShare.songDuration!)!, songPreviewURL: cardFromShare.songPreviewURL, inclMusic: cardFromShare.inclMusic, spotImageData: cardFromShare.spotImageData, spotSongDuration: Double(cardFromShare.spotSongDuration!)!, spotPreviewURL: cardFromShare.spotPreviewURL, songAddedUsing: cardFromShare.songAddedUsing, cardType: computeCardType(from: cardFromShare), coreCard: cardFromShare, chosenCard: $cardFromShare, appleSongURL: cardFromShare.appleSongURL, spotSongURL: cardFromShare.spotSongURL, unsplashImageURL: cardFromShare.unsplashImageURL, coverSizeDetails: cardFromShare.coverSizeDetails!)
                }
        }
    }
    func computeCardType(from card: CoreCard) -> String {
        let noPreview = (card.spotPreviewURL ?? "").isEmpty && (card.songPreviewURL ?? "").isEmpty
        if appDelegate.musicSub.type == .Neither && noPreview {
            CardPrep.shared.cardType = "noMusicNoGift"
            return "noMusicNoGift"
        }
        else {
            CardPrep.shared.cardType = card.cardType!
            return card.cardType!
        }
    }
}




struct BuildCardView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var cardProgress: CardProgress
    let steps: [AppState.BuildCardSteps]
    var animationDuration  = 5.0
    var body: some View {
        ForEach(steps, id: \.self) { step in
            switch step {
            case .photoOptionsView:
                PhotoOptionsView()
            case .occasionsMenu:
                OccassionsMenu()
            case .unsplashCollectionView:
                UnsplashCollectionView()
            case .confirmFrontCoverView:
                ConfirmFrontCoverView()
            case .collageBuilder:
                CollageBuilder(showImagePicker: false)
            case .writeNoteView:
                WriteNoteView()
            case .musicSearchView:
                MusicSearchView()
            case .finalizeCardView:
                FinalizeCardView(cardType: CardPrep.shared.cardType)
            }
        }
    }
}


