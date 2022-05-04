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
    
    var body: some View {
        // https://www.hackingwithswift.com/quick-start/swiftui/how-to-read-text-from-a-textfield
        TextField("Write Your Note Here", text: $message)
        Spacer()
        TextField("Recipient", text: $recipient).frame(height:35)
        TextField("Name Your Card", text: $cardName).frame(height:35)

        Button("Confirm Note") {
            segueToFinalize  = true
            noteField = NoteField.init(noteText: message, recipient: recipient, cardName: cardName)
        }.padding(.bottom, 30).sheet(isPresented: $segueToFinalize) {FinalizeCardView(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField)}
    }
}
