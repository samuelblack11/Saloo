//
//  WriteNoteView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//
import Foundation
import SwiftUI



struct WriteNoteView: View {
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @EnvironmentObject var collageImage: CollageImage
    @EnvironmentObject var chosenOccassion: Occassion
    @EnvironmentObject var appDelegate: AppDelegate
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var annotation: Annotation
    @EnvironmentObject var addMusic: AddMusic
    @EnvironmentObject var chosenSong: ChosenSong
    @EnvironmentObject var noteField: NoteField
    @ObservedObject var alertVars = AlertVars.shared
    @ObservedObject var message = MaximumText(limit: 225, value: "Write Your Message Here")
    @ObservedObject var recipient = MaximumText(limit: 20, value: "To:")
    @ObservedObject var sender = MaximumText(limit: 20, value: "From:")
    @ObservedObject var cardName = MaximumText(limit: 20, value: "Name Your Card")
    @State private var namesNotEntered = false
    @EnvironmentObject var gettingRecord: GettingRecord
    @State private var isEditing = false
    @State private var hasShownLaunchView: Bool = true
    @EnvironmentObject var cardProgress: CardProgress
    @Environment(\.colorScheme) var colorScheme

    var fonts = ["Zapfino", "Papyrus", "American-Typewriter-Bold", "Bradley Hand", "Chalkduster", "Noteworthy", "Marker Felt", "Snell Roundhand", "Baskerville", "Copperplate", "Cochin", "Didot"]
    var fontMenu: some View {
        HStack {
            Text("Choose Font Here:  ")
                .padding(.leading, 5)
                .font(Font.custom(noteField.font, size: 12))
            Picker("", selection: $noteField.font) {
                ForEach(fonts, id:\.self) { fontType in
                    Text(fontType).font(Font.custom(fontType, size: 12))
                }
            }
            Spacer()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                CustomNavigationBar(onBackButtonTap: {cardProgress.currentStep = 2; appState.currentScreen = .buildCard([.collageBuilder])}, titleContent: .text("Write Message"))
                ProgressBar().frame(height: 20)
                    .frame(height: 20)
                ZStack {
                    ScrollView {
                        Text("Scroll Down to Confirm Your Message")
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(Font.custom("Papyrus", size: 16))
                            .textCase(.none)
                            .multilineTextAlignment(.center)
                        TextEditor(text: $message.value)
                            .onTapGesture {if message.value == "Write Your Message Here" {message.value = ""}}
                            .border(Color.red, width: message.hasReachedLimit ? 1 : 0)
                            .frame(minHeight: UIScreen.screenHeight/3.0)
                            .font(Font.custom(noteField.font, size: 16))
                        fontMenu
                        Text("Enter the following details to save your card")
                            .font(.custom("Papyrus", size: 12))
                            .foregroundColor(.gray)
                            .textCase(.none)
                            .multilineTextAlignment(.center)
                        Text("This will not appear in the card")
                            .font(.custom("Papyrus", size: 12))
                            .foregroundColor(.gray)
                            .textCase(.none)
                            .multilineTextAlignment(.center)
                        TextField("To:", text: Binding(
                            get: {
                                if noteField.recipient.value == "To:" {return ""}
                                else { return noteField.recipient.value}
                            },
                            set: {noteField.recipient.value = $0}
                        ), onEditingChanged: { isEditing in
                            if isEditing && noteField.recipient.value == "To:" {noteField.recipient.value = ""}
                        }).font(.custom("Papyrus", size: 16)).border(Color.red, width: $noteField.recipient.hasReachedLimit.wrappedValue ? 1 : 0 )
                        TextField("From:", text: Binding(
                            get: {
                                if noteField.sender.value == "From:" {return ""} else {return noteField.sender.value}
                            },
                            set: {noteField.sender.value = $0}
                        ), onEditingChanged: { isEditing in
                            if isEditing && noteField.sender.value == "From:" {noteField.sender.value = ""}
                        }).font(.custom("Papyrus", size: 16))
                        .border(Color.red, width: noteField.sender.hasReachedLimit ? 1 : 0 )
                        
                        TextField("Name Your Card", text: Binding(
                            get: {
                                if noteField.cardName.value == "Name Your Card" {return ""} else {return noteField.cardName.value}
                            },
                            set: {noteField.cardName.value = $0}
                        ), onEditingChanged: { isEditing in
                            if isEditing && noteField.cardName.value == "Name Your Card" { noteField.cardName.value = ""}
                        }).font(.custom("Papyrus", size: 16))
                        .border(Color.red, width: noteField.cardName.hasReachedLimit ? 1 : 0 )
                        Button(action: {
                            let fullTextDetails = noteField.noteText.value + " " + noteField.recipient.value + " " + noteField.sender.value + " " + noteField.cardName.value
                            WriteNoteView.checkTextForOffensiveContent(text: fullTextDetails) { (textIsOffensive, error) in
                                noteField.noteText = message
                                if textIsOffensive! {alertVars.alertType = .offensiveText; alertVars.activateAlert = true}
                                else {
                                    noteField.cardName.value = noteField.cardName.value.components(separatedBy: CharacterSet.punctuationCharacters).joined()
                                    if appDelegate.musicSub.type == .Apple {
                                        DispatchQueue.main.async{GettingRecord.shared.isLoadingAlert = false}
                                        alertVars.alertType = .addMusicPrompt
                                        alertVars.activateAlert = true
                                    }
                                    if appDelegate.musicSub.type == .Spotify {
                                        DispatchQueue.main.async{GettingRecord.shared.isLoadingAlert = false}
                                        alertVars.alertType = .addMusicPrompt
                                        alertVars.activateAlert = true
                                    }
                                    if appDelegate.musicSub.type == .Neither {checkRequiredFields(); annotateIfNeeded();CardPrep.shared.chosenSong = chosenSong;
                                        DispatchQueue.main.async{GettingRecord.shared.isLoadingAlert = false} ;cardProgress.currentStep = 4; appState.currentScreen = .buildCard([.finalizeCardView])}
                                }
                            }
                        }) {
                            Text("Confirm Note")
                                .font(Font.custom("Papyrus", size: 16))
                        }
                        .padding(.bottom, 30)
                    }
                    LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
                }
            }
            .onAppear{
                if noteField.noteText.value != "" && noteField.noteText.value != "Write Your Message Here"{message.value = noteField.noteText.value}
            }
        }
        
        .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType, alertDismissAction: {
            addMusic.addMusic = true
            appDelegate.musicSub.timeToAddMusic = true
            checkRequiredFields()
            annotateIfNeeded()
            CardPrep.shared.cardType = "musicNoGift"
            
        }, secondDismissAction: {
            checkRequiredFields(); annotateIfNeeded(); addMusic.addMusic = false
            CardPrep.shared.cardType = "noMusicNoGift"
            CardPrep.shared.chosenSong = chosenSong
            cardProgress.currentStep = 5
            appState.currentScreen = .buildCard([.finalizeCardView])
        }))
    }
}

extension WriteNoteView {
    
    func annotateIfNeeded() {
        if chosenObject.frontCoverIsPersonalPhoto == 0 {
            annotation.text1 = "Photograph by"
            annotation.text2 = String(chosenObject.coverImagePhotographer)
            annotation.text2URL = URL(string: "https://unsplash.com/@\(chosenObject.coverImageUserName)?utm_source=salooGreetings&utm_medium=referral")!
            annotation.text3 = " On "
            annotation.text4 = "Unsplash"
        }
        else {annotation.text2URL = URL(string: "https://salooapp.com")!}
    }
    
    func checkRequiredFields() {
        if noteField.recipient.value != "" && noteField.cardName.value != "" {
            if addMusic.addMusic {cardProgress.currentStep = 4; appState.currentScreen = .buildCard([.musicSearchView])}
            else {
                CardPrep.shared.chosenSong = chosenSong
                cardProgress.currentStep = 4
                appState.currentScreen = .buildCard([.finalizeCardView])
            }
        }
        else {
            alertVars.alertType = .namesNotEntered
            alertVars.activateAlert = true
        }
    }
    
    
    static let endpoint = Config.shared.contentModEndpoint
    static let textModerationEndpoint = Config.shared.contentModTextEndpoint
    static let textBase = endpoint + Config.shared.contentModText

    static func checkTextForOffensiveContent(text: String, completion: @escaping (Bool?, Error?) -> Void) {

        guard let url = URL(string: textBase) else {
            DispatchQueue.main.async {
                GettingRecord.shared.isLoadingAlert = false
                completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            }
            return
        }

        DispatchQueue.main.async { GettingRecord.shared.isLoadingAlert = true }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = text.data(using: .utf8)
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.addValue(Config.shared.contentModSubKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { GettingRecord.shared.isLoadingAlert = false }
            guard let data = data, error == nil else {
                completion(nil, error)
                return
            }
            do {
                if let responseData = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let classification = responseData["Classification"] as? [String: Any],
                   let category1 = classification["Category1"] as? [String: Any],
                   let score1 = category1["Score"] as? Double,
                   let category2 = classification["Category2"] as? [String: Any],
                   let score2 = category2["Score"] as? Double,
                   let category3 = classification["Category3"] as? [String: Any],
                   let score3 = category3["Score"] as? Double {
                    let maxScore = max(score1, score2, score3)
                    if maxScore >= 0.99 { completion(true, nil) }
                    else { completion(false, nil) }
                } else {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON or extract classification scores"])
                    completion(false, error)
                }
            } catch {
                completion(false, error)
            }
        }
        task.resume()
    }

}
