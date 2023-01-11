//
//  EnlargeECard.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/7/22.
//

import Foundation
import SwiftUI
import ConfettiSwiftUI
import CloudKit

//https://www.appcoda.com/swiftui-confetti-animation/
struct EnlargeECardView: View {
    var chosenCard: CoreCard
    @Binding var share: CKShare?
    @State private var counter = 1
    private let stack = PersistenceController.shared

    //key must be SearchItem SearchTerm's field
    @State private var emojiDict: [String: String] = ["Birthday": "🎈",
                                                      "Christmas": "🎄",
                                                      "Hanukkah": "🕎",
                                                      "Fireworks": "🎇",
                                                      "Thanksgiving": "🍁",
                                                      "Clover": "🍀",
                                                      "Floral": "🌸",
                                                      "Valentine": "❤️"]
    func addToCounter() {counter += 1}
    
    func assignEmoji(occassion: String) -> String {return emojiDict[occassion]!}

    //@ViewBuilder func shareComponent() {
       // if let share = share {
            //ForEach(share.participants, id: \.self) { participant in
            // VStack(alignment: .leading) {
            //  Text(participant.userIdentity.nameComponents?.formatted(.name(style: .long)) ?? "")
            //.font(.headline)
            // Text("Acceptance Status: \(string(for: participant.acceptanceStatus))")
            //   .font(.subheadline)
            // Text("Role: \(string(for: participant.role))")
            //  .font(.subheadline)
            //Text("Permissions: \(string(for: participant.permission))")
            // .font(.subheadline)
      //  }
   // }

        //.onAppear(perform: {
                  //  self.share = stack.getShare(chosenCard)
                  //  })

    
    var body: some View {
        //.text("🎈")
        eCardView(eCardText: chosenCard.message, font: chosenCard.font, coverImage: chosenCard.coverImage!, collageImage: chosenCard.collage!, text1: chosenCard.an1, text2: chosenCard.an2, text2URL: URL(string: chosenCard.an2URL)!, text3: chosenCard.an3, text4: chosenCard.an4)
        //eCardView//.confettiCannon(counter: $counter, num: 1, confettis: [ .text(assignEmoji(occassion: chosenCard.chosenCard.occassion))], colors: [.red], confettiSize: 20.0, rainHeight: 600, fadesOut: true, opacity: 1, openingAngle: Angle.degrees(60), closingAngle: Angle.degrees(120), radius: 300, repetitions: 50, repetitionInterval: 0.05)
            .onAppear(perform:addToCounter)
        }
    }


extension EnlargeECardView {
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
