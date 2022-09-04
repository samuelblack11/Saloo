//
//  ScheduleDelivery.swift
//  GreetMe-2
//
//  Created by Sam Black on 9/1/22.
//

import Foundation
import SwiftUI
import CloudKit
// https://developer.apple.com/documentation/swiftui/datepicker
// https://www.hackingwithswift.com/books/ios-swiftui/adding-to-a-list-of-words
// https://www.hackingwithswift.com/articles/117/the-ultimate-guide-to-timer

struct ScheduleDelivery: View {
    @State var card: Card
    @State private var deliveryDate = Date()
    @State private var recipientList = [String]()
    @State private var newRecipient = ""
    @State private var scheduleButtonIsInactive = false
    @State var delivery: FutureDelivery!
    private let stack = CoreDataStack.shared
    @State var share: CKShare?
    @State var showShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(selection: $deliveryDate, in: dateRange, displayedComponents: [.hourAndMinute, .date, ]) {
                    Text("Select a date")
                }
                Section {
                    Text("Add Recipients:")
                    TextField("Enter Recipient Phone or Email", text: $newRecipient)
                        .autocapitalization(.none)
                }
                Section {
                    Text("Recipient List:")
                    ForEach(recipientList, id: \.self) { word in
                        Text(word)
                    }
                }
                Spacer()
                Button("Schedule Delivery") {
                    saveDelivery()
                    scheduleButtonIsInactive = true
                    }
                    .disabled(scheduleButtonIsInactive)
                }
                .sheet(isPresented: $showShareSheet, content: {
                    if let share = share {
                        CloudSharingView(share: share, container: stack.ckContainer, card: card)
                    }
              })
            }
            .onSubmit {
                addNewRecipient()
            }
    }
    
    func scheduleDelivery(delivery: FutureDelivery) {
        //let date = Date.now.addingTimeInterval(5)
        let schedDelC = ScheduleDeliveryC.init(card: card, share: share!, showShareSheet: showShareSheet)
        let timer = Timer(fireAt: delivery.deliveryDate!, interval: 0, target: self, selector: #selector(schedDelC.determineHowToShare), userInfo: nil, repeats: false)
        showShareSheet = true
        RunLoop.main.add(timer, forMode: .common)
    }
       
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())
        let day = calendar.component(.day, from: Date())
        let startComponents = DateComponents(year: year, month: month, day: day)
        let endComponents = DateComponents(year: 2030, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
}

class ScheduleDeliveryC {

    private let stack = CoreDataStack.shared
    var share: CKShare
    var card: Card
    var showShareSheet: Bool
    
    init(card: Card, share: CKShare, showShareSheet: Bool) {
        self.card = card
        self.share = share
        self.showShareSheet = showShareSheet
    }
    
    @objc func determineHowToShare() {
        if !stack.isShared(object: card) {
            Task {
                await createShare(card)
            }
        }
        if stack.isOwner(object: card) {
            getPrevShare(card)
        }
        // Show Share Controller
        showShareSheet = true
        
        // From CloudSharingController, Select Send via Messages
        
        // Auto Add Recipients
        
        // Send
    }
    
    private func getPrevShare(_ card: Card) {
           let share2 = stack.getShare(card)!
           self.share = share2
       }
    
    private func createShare(_ card: Card) async {
          do {
              let (_, share, _) = try await stack.persistentContainer.share([card], to: nil)
              share[CKShare.SystemFieldKey.title] = card.cardName
              share[CKShare.SystemFieldKey.thumbnailImageData] = card.coverImage
              share[CKShare.SystemFieldKey.shareType] = "Your Greeting Card from GreetMe"
              self.share = share
              }
          catch {
              print("Error+++++")
          }
    }
    
}

// MARK: Returns CKShare participant permission, methods and properties to share
extension ScheduleDelivery {
    
    func addNewRecipient() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newRecipient.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        guard answer.count > 0 else { return }

        // extra validation to come
        recipientList.insert(answer, at: 0)
        newRecipient = ""
    }
    
    func saveDelivery() {
        //save to core data
        let del = FutureDelivery(context: CoreDataStack.shared.context)
        del.card = card.card
        del.recipientList = recipientList
        del.deliveryDate = deliveryDate
        self.saveContext()
        delivery = del
    }
    
    func saveContext() {
        if CoreDataStack.shared.context.hasChanges {
            do {
                try CoreDataStack.shared.context.save()
                }
            catch {
                print("An error occurred while saving: \(error)")
                }
            }
        }

 private func getPrevShare(_ card: Card) {
        let share2 = stack.getShare(card)!
        self.share = share2
    }
    
  private func createShare(_ card: Card) async {
        do {
            let (_, share, _) = try await stack.persistentContainer.share([card], to: nil)
            share[CKShare.SystemFieldKey.title] = card.cardName
            share[CKShare.SystemFieldKey.thumbnailImageData] = card.coverImage
            share[CKShare.SystemFieldKey.shareType] = "Your Greeting Card from GreetMe"
            self.share = share
            }
        catch {
            print("Error+++++")
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
