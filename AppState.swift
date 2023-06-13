//
//  AppState.swift
//  Saloo
//
//  Created by Sam Black on 6/13/23.
//

import Foundation
import SwiftUI

class AppState: ObservableObject {
    enum Screen {
        case login
        case launch
        case startMenu
        case buildCard([BuildCardSteps]) // BuildCardSteps is an enum representing each step of the workflow
        case draft// parameters required for GridofCards
        case inbox
        case outbox
        case preferences
    }
    
    enum BuildCardSteps {
        case occasionsMenu
        case unsplashCollectionView
        case confirmFrontCoverView
        case collageStyleMenu
        case collageBuilder
        case writeNoteView
        case musicSearchView
        case finalizeCardView
        // any other steps you have
    }

    @Published var currentScreen: Screen = .startMenu
}

struct ContentView: View {
    @EnvironmentObject var apiManager: APIManager
    @StateObject var appState = AppState()
    @State private var isSignedIn = UserDefaults.standard.string(forKey: "SalooUserID") != nil

    var body: some View {
        Group {
            if isSignedIn {
                switch appState.currentScreen {
                case .login:
                    LoginView()
                case .launch:
                    LaunchView()
                case .startMenu:
                    StartMenu()
                case .buildCard(let steps):
                    BuildCardView(steps: steps)
                case .draft:
                    GridofCards(cardsForDisplay: CoreCardUtils.loadCoreCards(), whichBoxVal: .draftbox)
                case .inbox:
                    GridofCards(cardsForDisplay: CoreCardUtils.loadCoreCards(), whichBoxVal: .inbox)
                case .outbox:
                    GridofCards(cardsForDisplay: CoreCardUtils.loadCoreCards(), whichBoxVal: .outbox)
                case .preferences:
                    PrefMenu()
                }
            } else {
                LoginView()
            }
        }
    }
}

struct BuildCardView: View {
    let steps: [AppState.BuildCardSteps]

    var body: some View {
        ForEach(steps, id: \.self) { step in
            switch step {
            case .occasionsMenu:
                OccassionsMenu()
            case .unsplashCollectionView:
                UnsplashCollectionView()
            case .confirmFrontCoverView:
                ConfirmFrontCoverView()
            case .collageStyleMenu:
                CollageStyleMenu()
            case .collageBuilder:
                CollageBuilder(showImagePicker: false)//.environmentObject(collageImage)
            case .writeNoteView:
                WriteNoteView()
            case .musicSearchView:
                MusicSearchView()//.environmentObject(appDelegate)
            case .finalizeCardView:
                FinalizeCardView(cardType: CardPrep.shared.determineCardType())
                
            }
        }
    }
}

