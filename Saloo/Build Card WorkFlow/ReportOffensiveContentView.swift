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

    var card: CoreCard // Assuming CoreCard is defined elsewhere
    
    var body: some View {
        VStack {
            TextEditor(text: $comments)
                .frame(height: 200)
                .onTapGesture {if comments == "Why is this card offensive?" {comments = ""}}
            TextField("Your Name", text: $name)
            TextField("Your Email", text: $email)
            Button(action: {
                let report = createReportObject(userName: name, userEmail: email, userComments: comments, card: card)
                sendReportToAzure(report: report)
                reportComplete = true
            }) {Text("Submit")}

        }
        .padding()
        .alert(isPresented: $reportComplete) {
            Alert(
                title: Text("Feedback Received"),
                message: Text("Thanks for your feedback. We will review these details along with the card itself and will be in touch about your concern."),
                dismissButton: .default(Text("Ok")) {
                    // Dismiss the current view
                    let rootViewController = UIApplication.shared.connectedScenes
                        .filter { $0.activationState == .foregroundActive }
                        .compactMap { $0 as? UIWindowScene }
                        .first?.windows
                        .filter { $0.isKeyWindow }
                        .first?.rootViewController
                    rootViewController?.dismiss(animated: true)
                }
            )
        }
    }
    
    func sendReportToAzure(report: Report) {
        print("called sendReportToAzure")
        // The URL of your Azure Function
        let urlString = "https://salooreportoffensivecontent.azurewebsites.net"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Your Report object would need to be converted to JSON
        let encoder = JSONEncoder()
        guard let reportData = try? encoder.encode(report) else {
            print("Failed to encode report")
            return
        }
        
        request.httpBody = reportData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            print("Report Offensive Content dataTask...")
            print(response)
            
            
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

    struct Report: Codable {
        let userName: String
        let userEmail: String
        let userComments: String
        let coreCard: CardForReport
    }
                   
                   
    func createReportObject(userName: String, userEmail: String, userComments: String, card: CoreCard) -> Report {
        let report = Report(userName: userName, userEmail: userEmail, userComments: userComments, coreCard: coreCardToCardForReport(card: card))
        return report
    }
                   
                   
                   
    func coreCardToCardForReport(card: CoreCard) -> CardForReport {
    
        let cardForReport = CardForReport(
            id: card.id.debugDescription,
            cardName: card.cardName,
            occassion: card.occassion,
            recipient: card.recipient,
            sender: card.sender,
            an1: card.an1,
            an2: card.an2,
            an2URL: card.an2URL,
            an3: card.an3,
            an4: card.an4,
            collage: card.collage,
            coverImage: card.coverImage,
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
            collage1: card.collage1,
            collage2: card.collage2,
            collage3: card.collage3,
            collage4: card.collage4,
            cardType: card.cardType,
            recordID: card.recordID,
            songAlbumName: card.songAlbumName,
            appleAlbumArtist: card.appleAlbumArtist,
            spotAlbumArtist: card.spotAlbumArtist
        )

        return cardForReport
    }
                   
                   
                   
                   
                   
                   

}


struct CardForReport: Codable {
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
    let collage: Data?
    let coverImage: Data?
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
    let collage1: Data?
    let collage2: Data?
    let collage3: Data?
    let collage4: Data?
    let cardType: String?
    let recordID: String?
    let songAlbumName: String?
    let appleAlbumArtist: String?
    let spotAlbumArtist: String?
}
