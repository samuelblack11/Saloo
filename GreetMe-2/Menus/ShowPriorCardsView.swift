//
//  ShowPriorCardsView.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import Foundation
import SwiftUI
import CloudKit

struct ShowPriorCardsView: View {
    
    @EnvironmentObject private var cm: CKModel
    @State private var isAddingCard = false
    @State private var isSharing = false
    @State private var isProcessingShare = false
    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    
    @Environment(\.presentationMode) var presentationMode
    // https://www.hackingwithswift.com/read/38/5/loading-core-data-objects-using-nsfetchrequest-and-nssortdescriptor
    @State var cards = [Card]()
    @State private var segueToEnlarge = false
    @State private var chosenCard: Card!
    //@ObservedObject var card: Card
    @State var share: CKShare?
    @State private var showShareSheet = false
    @State private var showEditSheet = false
    @State var returnRecord: CKRecord?
    @State private var showDeliveryScheduler = false
    @State private var privateCards: [Card]?
    @State private var sharedCards: [Card]?
    @State private var allCards: [Card]?

    
    let columns = [GridItem(.adaptive(minimum: 80))]
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
                    case let .loaded(privateCards, sharedCards):
                        List {
                            ForEach(allCards!) {cardView(for: $0, shareable: false)}
                        }
                    }
            }
            .navigationViewStyle(.stack)
            .onAppear {
                Task {
                    try await cm.initialize()
                    try await (privateCards, sharedCards) = cm.fetchPrivateAndSharedCards()
                    allCards = sumLists(privateCards: privateCards!, sharedCards: sharedCards!)
                    try await cm.refresh()
                }}
    }
    
    
    func sumLists(privateCards: [Card], sharedCards: [Card]) -> [Card] {
        if sharedCards != sharedCards {
            allCards = privateCards
        }
        else {
            allCards = privateCards + sharedCards
        }
        return allCards!
    }
    
    private func cardView(for card: Card, shareable: Bool = true) -> some View {
        LazyVGrid(columns: columns, spacing: 10) {

            VStack(spacing: 0) {
                VStack(spacing:1) {
                    Image(uiImage: UIImage(data: card.coverImage!)!)
                        .resizable()
                        .frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/7))
                    Text(card.message!)
                        .font(Font.custom(card.font!, size: 500))
                        .minimumScaleFactor(0.01)
                        .frame(width: (UIScreen.screenWidth/3), height: (UIScreen.screenHeight/8))
                    Image(uiImage: UIImage(data: card.collage!)!)
                        .resizable()
                        .frame(maxWidth: (UIScreen.screenWidth/4), maxHeight: (UIScreen.screenHeight/7))
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            Text(card.an1!).font(.system(size: 4))
                            Link(card.an2!, destination: URL(string: card.an2URL!)!).font(.system(size: 4))
                            Text(card.an3!).font(.system(size: 4))
                            Link(card.an4!, destination: URL(string: "https://unsplash.com")!).font(.system(size: 4))
                        }.padding(.trailing, 5)
                        Spacer()
                        Image(systemName: "greetingcard.fill").foregroundColor(.blue).font(.system(size: 24))
                        Spacer()
                        VStack(spacing:0) {
                            Text("Greeting Card").font(.system(size: 4))
                            Text("by").font(.system(size: 4))
                            Text("GreetMe Inc.").font(.system(size: 4)).padding(.bottom,10).padding(.leading, 5)
                        }}.frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/15))
                }
                .sheet(isPresented: $showDeliveryScheduler) {ScheduleDelivery(card: card)}
                .sheet(isPresented: $segueToEnlarge) {EnlargeECardView(chosenCard: $chosenCard, share: $share)}
                .sheet(isPresented: $isSharing, content: {
                    shareView(card)
                })
                .contextMenu {
                    Button {chosenCard = card; segueToEnlarge = true} label: {Text("Enlarge eCard"); Image(systemName: "plus.magnifyingglass")}
                    Button {} label: {Text("Delete eCard"); Image(systemName: "trash").foregroundColor(.red)}
                    Button {Task {try? await shareCard(card)}; isSharing = true} label: {Text("Share eCard Now")}
                    Button {showDeliveryScheduler = true} label: {Text("Schedule eCard Delivery")}
                }
                Divider().padding(.bottom, 5)
                HStack(spacing: 3) {
                    Text(card.recipient!)
                        .font(.system(size: 8))
                        .minimumScaleFactor(0.1)
                    Spacer()
                    Text(card.occassion!)
                        .font(.system(size: 8))
                        .minimumScaleFactor(0.1)
                }
            }.padding().overlay(RoundedRectangle(cornerRadius: 6).stroke(.blue, lineWidth: 2))
        }
        .font(.headline)
        .padding(.horizontal)
        .frame(maxHeight: 600)
        }
    }

// MARK: Returns CKShare participant permission, methods and properties to share
extension ShowPriorCardsView {
    
    /// Builds a `CloudSharingView` with state after processing a share.
    private func shareView(_ card: Card) -> CloudSharingView? {
        guard let share = activeShare, let container = activeContainer else {
            return nil
        }

        return CloudSharingView(share: share, container: container, card: card)
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
    
  private func string(for permission: CKShare.ParticipantPermission) -> String {
    switch permission {
    case .unknown:
      return "Unknown"
    case .none:
      return "None"
    case .readOnly:
      return "Read-Only"
    case .readWrite:
      return "Read-Write"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.Permission")
    }
  }
    
  private func string(for role: CKShare.ParticipantRole) -> String {
    switch role {
    case .owner:
      return "Owner"
    case .privateUser:
      return "Private User"
    case .publicUser:
      return "Public User"
    case .unknown:
      return "Unknown"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.Role")
    }
  }

  private func string(for acceptanceStatus: CKShare.ParticipantAcceptanceStatus) -> String {
    switch acceptanceStatus {
    case .accepted:
      return "Accepted"
    case .removed:
      return "Removed"
    case .pending:
      return "Invited"
    case .unknown:
      return "Unknown"
    @unknown default:
      fatalError("A new value added to CKShare.Participant.AcceptanceStatus")
    }
  }
}


///// https://www.hackingwithswift.com/read/33/4/writing-to-icloud-with-cloudkit-ckrecord-and-ckasset
