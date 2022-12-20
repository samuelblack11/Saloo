//
//  ShowPriorCardsView.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import Foundation
import SwiftUI
import CloudKit

struct Outbox: View {
    @EnvironmentObject private var cm: CKModel
    @State private var privateCards: [Card] = []
    @State private var sharedCards: [Card]?
    // mycards = private + shared
    @State private var myCards: [Card]?
    

    var body: some View {
        NavigationView {
                    switch cm.state {
                    case .loading:
                        VStack{EmptyView()}
                    case .error(let error):
                        VStack {
                            Text("An error occurred: \(error.localizedDescription)").padding()
                            Spacer()
                        }
                    case let .loaded(sentCards: privateCards, receivedCards: privateCards):
                        //Text("Great Success")
                        GridofCards(privateCards: $privateCards, receivedCards: privateCards)
                    }
            }
            .onAppear {
                Task {
                    try await cm.initialize()
                    try await (privateCards, sharedCards) = cm.fetchPrivateAndSharedCards()
                    try await cm.refresh()

                }
        }
    }
}
