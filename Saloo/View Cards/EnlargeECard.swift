//
//  EnlargeECard.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/7/22.
//

import Foundation
import SwiftUI
import CloudKit

//https://www.appcoda.com/swiftui-confetti-animation/
struct EnlargeECardView: View {
    var chosenCard: CoreCard
    @Binding var share: CKShare?
    @State private var counter = 1
    private let stack = PersistenceController.shared
    @State private var showGrid = false
    @State var cardsForDisplay: [CoreCard]
    @State var whichBoxVal: InOut.SendReceive
    var body: some View {
        NavigationView {
            VStack {
                eCardView(eCardText: chosenCard.message, font: chosenCard.font, coverImage: chosenCard.coverImage!, collageImage: chosenCard.collage!, text1: chosenCard.an1, text2: chosenCard.an2, text2URL: URL(string: chosenCard.an2URL)!, text3: chosenCard.an3, text4: chosenCard.an4, songID: chosenCard.songID , songName: chosenCard.songName, songArtistName: chosenCard.songArtistName, songArtImageData: chosenCard.songArtImageData, songDuration: Double(chosenCard.songDuration!)!)
            }
            .navigationBarItems(
                leading:Button {showGrid = true}
                label: {Image(systemName: "chevron.left").foregroundColor(.blue)
                Text("Back")})
            .fullScreenCover(isPresented: $showGrid) {GridofCards(cardsForDisplay: cardsForDisplay, whichBoxVal: whichBoxVal)}
        }
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
