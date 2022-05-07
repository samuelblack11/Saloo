//
//  WriteNoteView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//
import Foundation
import SwiftUI

struct NoteField {
    var noteText: String
    var recipient: String
    var cardName: String
    //var font: String
}

struct WriteNoteView: View {
    
    @State private var message: String = ""
    @State private var recipient: String = ""
    @State private var cardName: String = ""

    @State private var segueToFinalize = false
    @Binding var chosenObject: CoverImageObject!
    @Binding var collageImage: CollageImage!
    @Binding var noteField: NoteField!
    @State private var selectedFont = "Papyrus"
    let allFontNames = UIFont.familyNames
      .flatMap { UIFont.fontNames(forFamilyName: $0) }
    
    
    var fonts = ["Zapfino","Papyrus","American-Typewriter-Bold"]
    var fontMenu: some View {
        HStack {
            Text("Choose Font Here:  ").padding(.leading, 5).font(Font.custom(selectedFont, size: 12))
            Picker("", selection: $selectedFont) {
                ForEach(fonts, id:\.self) { fontType in
                    Text(fontType).font(Font.custom(fontType, size: 12))
                }
            }
            Spacer()
        }
    }

    
    var body: some View {
        // https://www.hackingwithswift.com/quick-start/swiftui/how-to-read-text-from-a-textfield
        TextField("Write Your Note Here", text: $message).font(Font.custom(selectedFont, size: 12))
        Spacer()
        fontMenu.frame(height: 65)
        TextField("Recipient", text: $recipient).padding(.leading, 5).frame(height:35)
        TextField("Name Your Card", text: $cardName).padding(.leading, 5).frame(height:35)

        Button("Confirm Note") {
            segueToFinalize  = true
            noteField = NoteField.init(noteText: message, recipient: recipient, cardName: cardName)
        }.padding(.bottom, 30).sheet(isPresented: $segueToFinalize) {FinalizeCardView(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField)}
    }
}
