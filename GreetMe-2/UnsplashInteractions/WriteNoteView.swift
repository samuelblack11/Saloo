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
    //var font: String
}

struct WriteNoteView: View {
    
    @State private var message: String = ""
    @State private var segueToFinalize = false
    @Binding var chosenObject: CoverImageObject!
    @Binding var collageImage: CollageImage!
    @Binding var noteField: NoteField!
    
    var body: some View {
        // https://www.hackingwithswift.com/quick-start/swiftui/how-to-read-text-from-a-textfield
        TextField("Write Your Note Here", text: $message)
        Spacer()
        Button("Confirm Note") {
            segueToFinalize  = true
            noteField = NoteField.init(noteText: message)
        }.padding(.bottom, 30).sheet(isPresented: $segueToFinalize ) {FinalizeCardView(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField)}
    }
}
