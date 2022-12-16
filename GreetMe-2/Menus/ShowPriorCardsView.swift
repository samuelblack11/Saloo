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
    private let stack = CoreDataStack.shared
    @State var returnRecord: CKRecord?
    @State private var showDeliveryScheduler = false

    let columns = [GridItem(.fixed(140)), GridItem(.fixed(140))]
    
    var body: some View {
        NavigationView {
            ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(cards, id: \.self) {card in
                    VStack(spacing: 0) {
                        VStack(spacing:1) {
                            Image(uiImage: UIImage(data: card.coverImage!)!)
                                .resizable()
                                .frame(width: (UIScreen.screenWidth/3), height: (UIScreen.screenHeight/7))
                            Text(card.message!)
                                .font(Font.custom(card.font!, size: 500))
                                .minimumScaleFactor(0.01)
                                .frame(width: (UIScreen.screenWidth/3), height: (UIScreen.screenHeight/8))
                            Image(uiImage: UIImage(data: card.collage!)!)
                                .resizable()
                                .frame(maxWidth: (UIScreen.screenWidth/4), maxHeight: (UIScreen.screenHeight/7))
                            HStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    Text(card.an1!)
                                        .font(.system(size: 4))
                                    Link(card.an2!, destination: URL(string: card.an2URL!)!)
                                        .font(.system(size: 4))
                                    Text(card.an3!).font(.system(size: 4))
                                    Link(card.an4!, destination: URL(string: "https://unsplash.com")!).font(.system(size: 4))
                                    }
                                    .padding(.trailing, 5)
                                Spacer()
                                Image(systemName: "greetingcard.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 24))
                                Spacer()
                                VStack(spacing:0) {
                                    Text("Greeting Card")
                                        .font(.system(size: 4))
                                    Text("by")
                                        .font(.system(size: 4))
                                    Text("GreetMe Inc.")
                                        .font(.system(size: 4))
                                        .padding(.bottom,10)
                                        .padding(.leading, 5)
                                    }
                            }.frame(width: (UIScreen.screenWidth/3), height: (UIScreen.screenHeight/15))
                        }
                        .sheet(isPresented: $showDeliveryScheduler) {ScheduleDelivery(card: card)}
                        .sheet(isPresented: $segueToEnlarge) {EnlargeECardView(chosenCard: $chosenCard, share: $share)}
                        .sheet(isPresented: $showShareSheet, content: {
                            if let share = share {
                                
                                //CloudSharingView(share: share, container: stack.ckContainer, card: card)
                                CloudSharingView(share: share, container: stack.ckContainer, card: card)
                                    
                                
                            }
                          })
                        .contextMenu {
                            Button {
                                chosenCard = card
                                segueToEnlarge = true
                            } label: {
                                Text("Enlarge eCard")
                                Image(systemName: "plus.magnifyingglass")
                            }
                            Button {
                                //deleteCoreData(card: card)
                            } label: {
                                Text("Delete eCard")
                                Image(systemName: "trash")
                                .foregroundColor(.red)
                            }
                            Button {
                                chosenCard = card
                                //print(!stack.isShared(object: card))
                                //if !stack.isShared(object: card) {
                                //      // createShare shows blank screen on first attempt
                                //    Task {
                                //    }
                                //}
                                showShareSheet = true
                            } label: {
                                Text("Share eCard Now")
                            }
                            Button {
                                showDeliveryScheduler = true
                                
                            } label: {
                                Text("Schedule eCard Delivery")
                            }
                        }.onAppear(perform: {
                            //self.share = stack.getShare(card)
                          })
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
                        }
                    .padding()
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(.blue, lineWidth: 2))
                    }
                }
            }.navigationBarItems(leading:
                Button {
                    print("Back button tapped")
                    //presentPrior = true
                    presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left").foregroundColor(.blue)
                        Text("Back")
                    })
        }
        .font(.headline)
        .padding(.horizontal)
        .frame(maxHeight: 600)
        //.onAppear{loadCoreData()}
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
//let recordZone: CKRecordZone = CKRecordZone(zoneName: "\(card.cardName)-\(card.objectID)")
//let cardRecord = CKRecord(recordType: "Card")
//cardRecord["card"] = card as? CKRecordValue
//let cardAsset = CKAsset(fileURL: cardURL)

//share[CKShare.SystemFieldKey.title] = card.cardName
//share[CKShare.SystemFieldKey.thumbnailImageData] = card.coverImage


//let recordIdName = CKRecord.ID(recordName: "\(card.cardName!)-\(card.objectID)")

//CoreDataStack.shared.ckContainer.privateCloudDatabase.fetch(withRecordID: recordIdName) //{ [self] record, error in
//        if let error = error {
 //           DispatchQueue.main.async {
                // meaningful error message here!
 //               print("!!!!!")
  //              print(error.localizedDescription)
  //          }
  //      } else {
    //        if let record = record {
    //            self.returnRecord = record
    //            let share3 = CKShare(rootRecord: record)
    //            share3[CKShare.SystemFieldKey.title] = card.cardName
    //            share3[CKShare.SystemFieldKey.thumbnailImageData] = card.coverImage
     //           share3[CKShare.SystemFieldKey.shareType] = "Your Greeting Card from GreetMe"
     //           self.share = share3
     //        }
      //  }
    //}
