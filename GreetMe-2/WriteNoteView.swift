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
    @Environment(\.presentationMode) var presentationMode
    @State private var message: String = "Write Your Note Here"
    @State private var recipient: String = ""
    @State private var cardName: String = ""
    @State private var tappedTextEditor = false
    @State private var namesNotEntered = false
    @State private var handWrite = true
    @State private var willHandWrite = false
    @Binding var frontCoverIsPersonalPhoto: Int
    @State private var segueToFinalize = false
    @Binding var chosenObject: CoverImageObject!
    @Binding var collageImage: CollageImage!
    @Binding var noteField: NoteField!
    @State private var selectedFont = "Papyrus"
    @State var text1: String = ""
    @State var text2: String = ""
    @State var text2URL: URL = URL(string: "https://google.com")!
    @State var text3: String = ""
    @State var text4: String = ""
    @FocusState private var isNoteFieldFocused: Bool

    
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
    
    func annotateIfNeeded() {
        print("annotateIfNeeded was Called")
        print(frontCoverIsPersonalPhoto)
        if frontCoverIsPersonalPhoto == 0 {
            text1 = "Front Cover By "
            text2 = String(chosenObject.coverImagePhotographer)
            text2URL = URL(string: "https://unsplash.com/@\(chosenObject.coverImageUserName)")!
            text3 = "On "
            text4 = "Unsplash"
        }
        else {
            text2URL = URL(string: "https://google.com")!
        }
        print("----------")
        print(text2URL)
    }

    
    var body: some View {
        NavigationView {
            VStack {
            //ScrollView {
        // https://www.hackingwithswift.com/quick-start/swiftui/how-to-read-text-from-a-textfield
        // https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-multi-line-editable-text-with-texteditor
        // https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-focusstate-property-wrapper
        TextEditor(text: $message)
            //.focused($isNoteFieldFocused)
            .font(Font.custom(selectedFont, size: 14))
            //.foregroundColor(.gray)
            //.foregroundColor(tappedTextEditor ? .black: .gray)
            .onTapGesture {
                if message == "Write Your Note Here" {
                    message = ""
                }
                //isNoteFieldFocused.toggle()
                tappedTextEditor = true}
        Image(uiImage: collageImage.collageImage)
                    .resizable()
                    .frame(width: (UIScreen.screenWidth/5)-10, height: (UIScreen.screenWidth/5),alignment: .center)
        //Spacer()
        fontMenu.frame(height: 65)
        TextField("Recipient", text: $recipient)
            .padding(.leading, 5)
            .frame(height:35)
            .onTapGesture {
                //isNoteFieldFocused.toggle()
            }
        TextField("Name Your Card", text: $cardName)
            .padding(.leading, 5)
            .frame(height:35)
            .onTapGesture {
                //isNoteFieldFocused.toggle()
            }
        Button("Confirm Note") {
            checkRequiredFields()
            annotateIfNeeded()
            }
        .alert("Please Enter Values for All Fields!", isPresented: $namesNotEntered) {Button("Ok", role: .cancel) {}}
        .alert("Type Note Here or Hand Write After Printing?", isPresented: $handWrite) {
            Button("Type it Here", action: {})
            Button("Hand Write it", action: {
                message = " "
                willHandWrite = true})}
        .alert("Enter a Recipient & Card Name, Then Confirm", isPresented: $willHandWrite) {Button("Ok", role: .cancel) {}}
        .padding(.bottom, 30)
        .sheet(isPresented: $segueToFinalize) {FinalizeCardView(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, frontCoverIsPersonalPhoto: frontCoverIsPersonalPhoto, text1: $text1, text2: $text2, text2URL: $text2URL, text3: $text3, text4: $text4)}
        }
            //.ignoresSafeArea(.keyboard)
            .navigationBarItems(leading:
                                        Button {presentationMode.wrappedValue.dismiss()} label: {
                                            Image(systemName: "chevron.left").foregroundColor(.blue)
                                                Text("Back")})
        }
    }
    
    func checkRequiredFields() {
        if recipient != "" && cardName != ""  {
            namesNotEntered = false
            segueToFinalize  = true
            noteField = NoteField.init(noteText: message, recipient: recipient, cardName: cardName)
        }
        else {
            namesNotEntered = true
        }
        
    }
    
}
