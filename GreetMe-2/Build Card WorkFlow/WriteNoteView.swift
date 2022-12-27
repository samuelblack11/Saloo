//
//  WriteNoteView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//
import Foundation
import SwiftUI

// https://www.hackingwithswift.com/quick-start/swiftui/how-to-read-text-from-a-textfield
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-create-multi-line-editable-text-with-texteditor
// https://www.hackingwithswift.com/quick-start/swiftui/what-is-the-focusstate-property-wrapper

struct WriteNoteView: View {
    @ObservedObject var viewTransitions: ViewTransitions
    
    @Environment(\.presentationMode) var presentationMode
    @State private var message: String = "Write Your Note Here"
    @ObservedObject var input = TextLimiter(limit: 225)
    @State private var recipient: String = ""
    @State private var cardName: String = ""
    @State private var tappedTextEditor = false
    @State private var namesNotEntered = false
    @State private var handWrite = true
    @State private var handWrite2 = false
    @StateObject var willHandWrite = HandWrite()
    @Binding var frontCoverIsPersonalPhoto: Int
    @State private var segueToFinalize = false
    @State var chosenObject: CoverImageObject!
    @State var collageImage: CollageImage!
    @State var noteField: NoteField?
    @State private var selectedFont = "Papyrus"
    @State var text1: String = ""
    @State var text2: String = ""
    @State var text2URL: URL = URL(string: "https://google.com")!
    @State var text3: String = ""
    @State var text4: String = ""
    @FocusState private var isNoteFieldFocused: Bool
    @Binding var eCardText: String
    @Binding var printCardText: String
    @State var chosenCollection: ChosenCollection


    let allFontNames = UIFont.familyNames
      .flatMap { UIFont.fontNames(forFamilyName: $0) }
    
    var fonts = ["Zapfino","Papyrus","American-Typewriter-Bold"]
    var fontMenu: some View {
        HStack {
            Text("Choose Font Here:  ")
                .padding(.leading, 5)
                .font(Font.custom(selectedFont, size: 12))
            Picker("", selection: $selectedFont) {
                ForEach(fonts, id:\.self) { fontType in
                    Text(fontType).font(Font.custom(fontType, size: 12))
                }
            }
            Spacer()
        }
    }

    
    var body: some View {
        NavigationView {
            ScrollView {
        TextEditor(text: $input.value)
            .border(Color.red, width: $input.hasReachedLimit.wrappedValue ? 1 : 0 )
            .frame(minHeight: 150)
            .font(Font.custom(selectedFont, size: 14))
            .onTapGesture {
                if input.value == "Write Your Note Here" {
                    input.value = ""
                }
                //isNoteFieldFocused.toggle()
                tappedTextEditor = true
            }
        HStack {
        Text("\(225 - input.value.count) Characters Remaining").font(Font.custom(selectedFont, size: 10))
        Image(uiImage: collageImage.collageImage)
                    .resizable()
                    .frame(width: (UIScreen.screenWidth/5)-10, height: (UIScreen.screenWidth/5),alignment: .center)
            
        }
        //Spacer()
        fontMenu.frame(height: 65)
        TextField("Recipient", text: $recipient)
            .padding(.leading, 5)
            .frame(height:35)
        TextField("Name Your Card", text: $cardName)
            .padding(.leading, 5)
            .frame(height:35)
        Button("Confirm Note") {
            cardName = cardName.components(separatedBy: CharacterSet.punctuationCharacters).joined()
            message = input.value
            willHandWritePrintCard()
            checkRequiredFields()
            annotateIfNeeded()
            }
        .alert("Please Enter Values for All Fields!", isPresented: $namesNotEntered) {Button("Ok", role: .cancel) {}}
        .alert("Type Note Here or Hand Write After Printing?", isPresented: $handWrite) {
            Button("Type it Here", action: {})
            Button("Hand Write it"){
                handWrite2 = true
                willHandWrite.willHandWrite = true
            }}
        .alert("Your typed message will only appear in your eCard", isPresented: $handWrite2) {Button("Ok", role: .cancel) {}}
        .padding(.bottom, 30)
        .fullScreenCover(isPresented: $viewTransitions.isShowingFinalize) {FinalizeCardView(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, frontCoverIsPersonalPhoto: frontCoverIsPersonalPhoto, text1: $text1, text2: $text2, text2URL: $text2URL, text3: $text3, text4: $text4, willHandWrite: willHandWrite, eCardText: $eCardText, printCardText: $printCardText, viewTransitions: viewTransitions, chosenCollection: chosenCollection)}
        }
            .navigationBarItems(leading:
                                        Button {presentationMode.wrappedValue.dismiss()} label: {
                                            Image(systemName: "chevron.left").foregroundColor(.blue)
                                                Text("Back")})
        }
    }
    


    // https://programmingwithswift.com/swiftui-textfield-character-limit/
    class TextLimiter: ObservableObject {
        // variable for character limit
        private let limit: Int
        
        init(limit: Int) {
            self.limit = limit
        }
        // value that text field displays
        @Published var value = "Write Your Note Here" {
            didSet {
                if value.count > self.limit {
                    value = String(value.prefix(self.limit))
                    self.hasReachedLimit = true
                } else {
                    self.hasReachedLimit = false
                }
            }
        }
        @Published var hasReachedLimit = false
    }
    
    
    
}


extension WriteNoteView {
    
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
    }
    
    func willHandWritePrintCard() {
        print("called willHandWritePrintCard")
        print(willHandWrite.willHandWrite)
        if willHandWrite.willHandWrite == true {
            if input.value == "Write Note Here" {
                input.value = ""
            }
            eCardText = input.value
            print("eCardText.......")
            print(eCardText)
            printCardText = ""
        }
        else {
            eCardText = input.value
            printCardText = input.value
        }
    }
    
    func checkRequiredFields() {
        if recipient != "" && cardName != "" {
            namesNotEntered = false
            //segueToFinalize  = true
            viewTransitions.isShowingFinalize = true
            noteField = NoteField.init(noteText: message, recipient: recipient, cardName: cardName, font: selectedFont)
        }
        else {
            namesNotEntered = true
        }
    }
    
    
    
}
