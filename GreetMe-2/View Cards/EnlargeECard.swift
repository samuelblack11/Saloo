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
    @Binding var chosenCard: Card!
    @Binding var share: CKShare?
    @State private var counter = 1
    private let stack = CoreDataStack.shared

    //key must be SearchItem SearchTerm's field
    @State private var emojiDict: [String: String] = ["Birthday": "🎈",
                                                      "Christmas": "🎄",
                                                      "Hanukkah": "🕎",
                                                      "Fireworks": "🎇",
                                                      "Thanksgiving": "🍁",
                                                      "Clover": "🍀",
                                                      "Floral": "🌸",
                                                      "Valentine": "❤️"]
    func addToCounter() {
        counter += 1
    }
    
    func assignEmoji(occassion: String) -> String {
        return emojiDict[occassion]!
    }

    var eCardView: some View {
        VStack(spacing:1) {
            Image(uiImage: UIImage(data: chosenCard.coverImage!)!)
                .resizable()
                .frame(maxWidth: (UIScreen.screenWidth/1.5), maxHeight: (UIScreen.screenHeight/3.7))
            Text(chosenCard.message!)
                .font(Font.custom(chosenCard.font!, size: 500))
                .minimumScaleFactor(0.01)
                .frame(maxWidth: (UIScreen.screenWidth/1.5), maxHeight: (UIScreen.screenHeight/5.5))
            
            VStack(spacing:0) {
                Image(uiImage: UIImage(data: chosenCard.collage!)!)
                    .resizable()
                    .frame(maxWidth: (UIScreen.screenWidth/1.5), maxHeight: (UIScreen.screenHeight/3.7))
                
                HStack(spacing: 0) {
                    
                    VStack(spacing: 0) {
                        Text(chosenCard.an1!)
                            .font(.system(size: 8))
                        Link(chosenCard.an2!, destination: URL(string: chosenCard.an2URL!)!)
                            .font(.system(size: 8))
                        HStack(spacing: 0) {
                            Text(chosenCard.an3!).font(.system(size: 8))
                            Link(chosenCard.an4!, destination: URL(string: "https://unsplash.com")!).font(.system(size: 8))
                            }
                        }.padding(.bottom,10)
                    Spacer()
                    Image(systemName: "greetingcard.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 24))
                        .padding(.bottom,10)
                    Spacer()
                    VStack(spacing:0) {
                    Text("Greeting Card by").font(.system(size: 8))
                    Text("GreetMe Inc.").font(.system(size: 8))
                    }
                }.frame(maxWidth: (UIScreen.screenWidth/1.5), maxHeight: (UIScreen.screenHeight/12))
            }
            if let share = share {
                ForEach(share.participants, id: \.self) { participant in
                  VStack(alignment: .leading) {
                    Text(participant.userIdentity.nameComponents?.formatted(.name(style: .long)) ?? "")
                      .font(.headline)
                    Text("Acceptance Status: \(string(for: participant.acceptanceStatus))")
                      .font(.subheadline)
                    Text("Role: \(string(for: participant.role))")
                      .font(.subheadline)
                    Text("Permissions: \(string(for: participant.permission))")
                      .font(.subheadline)
                  }
                  .padding(.bottom, 8)
                }
            }
            
            
            
        }.frame(height: (UIScreen.screenHeight/1.1))
    }
        //.onAppear(perform: {
                  //  self.share = stack.getShare(chosenCard)
                  //  })

    
    var body: some View {
        //.text("🎈")
        eCardView.confettiCannon(counter: $counter, num: 1, confettis: [ .text(assignEmoji(occassion: chosenCard.occassion!))], colors: [.red], confettiSize: 20.0, rainHeight: 600, fadesOut: true, opacity: 1, openingAngle: Angle.degrees(60), closingAngle: Angle.degrees(120), radius: 300, repetitions: 50, repetitionInterval: 0.05)
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
