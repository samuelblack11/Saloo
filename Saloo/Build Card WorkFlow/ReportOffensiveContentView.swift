//
//  ReportOffensiveContentView.swift
//  Saloo
//
//  Created by Sam Black on 5/24/23.
//

import Foundation
import SwiftUI
struct ReportOffensiveContentView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var comments = "Why is this card offensive?"
    @State private var reportComplete = false
    @ObservedObject var alertVars = AlertVars.shared
    @State private var showGrid = false
    @Binding var card: CoreCard? // Assuming CoreCard is defined elsewhere
    //@Binding var cardToReport: CoreCard?
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var persistenceController: PersistenceController
    @EnvironmentObject var cardsForDisplayEnv: CardsForDisplay
    @Binding var whichBoxVal: InOut.SendReceive
    @Binding var coreCards: [CoreCard]

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $comments)
                    .frame(height: 200)
                    .onTapGesture {if comments == "Why is this card offensive?" {comments = ""}}
                TextField("Your Name", text: $name)
                TextField("Your Email", text: $email)
                Button(action: {
                    let report = createReportObject(userName: name, userEmail: email, userComments: comments, card: card!)
                    sendReportToAzure(report: report)
                    alertVars.alertType = .reportComplete
                    alertVars.activateAlert = true
                }) {Text("Submit")}
            }
            .navigationBarItems(leading:Button {card = nil} label: {Image(systemName: "chevron.left").foregroundColor(.blue); Text("Back")})
        }
        .padding()
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, alertDismissAction: {deleteCoreCard(coreCard: card!); loadCards(); card = nil}, secondDismissAction: {card = nil}))
    }
    
    func sendReportToAzure(report: Report) {
        // The URL of your Azure Function
        let urlString = "https://salooreportoffensivecontent.azurewebsites.net/api/SalooReportOffensiveContent"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Your Report object would need to be converted to JSON
        let encoder = JSONEncoder()
        guard let reportData = try? encoder.encode(report) else {
            return
        }
        request.httpBody = reportData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let str = String(data: data, encoding: .utf8)
                print("Response data: \(str ?? "")")
            }
            
            // check for fundamental networking error
            guard error == nil else {
                print("Error: \(error!.localizedDescription)")
                return
            }
            
            // check for http errors
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode)")
                return
            }
            
            // check for data
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                // if you're expecting a JSON response, you can convert it to a Swift object here
                //let responseObj = try JSONDecoder().decode(SomeType.self, from: data)
                //print("Response: \(responseObj)")
            } catch let parseError {
                print("Parsing Error: \(parseError)")
            }
            
        }.resume()

    }

                   
                   
    func createReportObject(userName: String, userEmail: String, userComments: String, card: CoreCard) -> Report {
        let report = Report(userName: userName, userEmail: userEmail, userComments: userComments, salooUserID: card.salooUserID,
                            id:card.id.debugDescription,
                            cardName: card.cardName,
                            occassion: card.occassion,
                            recipient: card.recipient,
                            sender: card.sender,
                            an1: card.an1,
                            an2: card.an2,
                            an2URL: card.an2URL,
                            an3: card.an3,
                            an4: card.an4,
                            date: card.date,
                            font: card.font,
                            message: card.message,
                            songID: card.songID,
                            spotID: card.spotID,
                            spotName: card.spotName,
                            spotArtistName: card.spotArtistName,
                            songName: card.songName,
                            songArtistName: card.songArtistName,
                            songArtImageData: card.songArtImageData,
                            songPreviewURL: card.songPreviewURL,
                            songDuration: card.songDuration,
                            inclMusic: card.inclMusic,
                            spotImageData: card.spotImageData,
                            spotSongDuration: card.spotSongDuration,
                            spotPreviewURL: card.spotPreviewURL,
                            creator: card.creator,
                            songAddedUsing: card.songAddedUsing,
                            cardType: card.cardType,
                            recordID: card.recordID,
                            songAlbumName: card.songAlbumName,
                            appleAlbumArtist: card.appleAlbumArtist,
                            spotAlbumArtist: card.spotAlbumArtist,
                            collage: card.collage,
                            coverImage: card.coverImage)
        return report
    }

    struct Report: Codable {
        let userName: String
        let userEmail: String
        let userComments: String
        let salooUserID: String?
        let id: String
        let cardName: String
        let occassion: String?
        let recipient: String?
        let sender: String?
        let an1: String?
        let an2: String?
        let an2URL: String?
        let an3: String?
        let an4: String?
        let date: Date?
        let font: String?
        let message: String?
        let songID: String?
        let spotID: String?
        let spotName: String?
        let spotArtistName: String?
        let songName: String?
        let songArtistName: String?
        let songArtImageData: Data?
        let songPreviewURL: String?
        let songDuration: String?
        let inclMusic: Bool?
        let spotImageData: Data?
        let spotSongDuration: String?
        let spotPreviewURL: String?
        let creator: String?
        let songAddedUsing: String?
        let cardType: String?
        let recordID: String?
        let songAlbumName: String?
        let appleAlbumArtist: String?
        let spotAlbumArtist: String?
        let collage: Data?
        let coverImage: Data?
    }
    
    func deleteCoreCard(coreCard: CoreCard) {
        cardsForDisplayEnv.deleteCoreCard(card: coreCard, box: whichBoxVal)
    }
    
    func loadCards() {
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
}
