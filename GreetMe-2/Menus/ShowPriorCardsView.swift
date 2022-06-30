//
//  ShowPriorCardsView.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import Foundation
import SwiftUI

struct ShowPriorCardsView: View {
    @Environment(\.presentationMode) var presentationMode
    // https://www.hackingwithswift.com/read/38/5/loading-core-data-objects-using-nsfetchrequest-and-nssortdescriptor
    @State var cards = [Card]()
    @State private var segueToEnlarge = false
    @State private var chosenCard: Card!
    let columns = [GridItem(.fixed(150))]
    
    var body: some View {
        NavigationView {
            ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(cards, id: \.self) {card in
                    VStack(spacing: 0) {
                        HStack(spacing:0) {
                            // Front Cover
                            Image(uiImage: UIImage(data: card.coverImage!)!)
                                .resizable().frame(width: (UIScreen.screenWidth/3)-2, height: (UIScreen.screenWidth/3))
                            // Note
                            Text(card.message!)
                                .font(Font.custom(card.font!, size: 500))
                                .minimumScaleFactor(0.01)
                                .frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenWidth/3)).scaledToFit()
                            // Inside Cover
                            Image(uiImage: UIImage(data: card.collage!)!).resizable().frame(width: (UIScreen.screenWidth/3)-2, height: (UIScreen.screenWidth/3))
                        }.sheet(isPresented: $segueToEnlarge) {EnlargeECardView(chosenCard: $chosenCard)}
                        .contextMenu {
                            Button {
                                chosenCard = card
                                segueToEnlarge = true
                            } label: {
                                Text("Enlarge eCard")
                                Image(systemName: "plus.magnifyingglass")
                            }
                            Button {
                                deleteCoreData(card: card)
                            } label: {
                                Text("Delete eCard")
                                Image(systemName: "trash")
                                .foregroundColor(.red)
                            }
                        }
                        HStack(spacing: 3) {
                            Text(card.recipient!)
                            Spacer()
                            Text(card.occassion!)
                        }
                    }
                    
                }
            }
            }.navigationBarItems(leading:
                                            Button {
                                                print("Back button tapped")
                                                //presentPrior = true
                                                presentationMode.wrappedValue.dismiss()
                                            } label: {
                                                Image(systemName: "chevron.left").foregroundColor(.blue)
                                                Text("Back")
                                            })
        }
        .font(.headline)
        .padding(.horizontal)
        .frame(maxHeight: 600)
        .onAppear{loadCoreData()}
    }
    
    
    
    func loadCoreData() {
        let request = Card.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        do {
            cards = try DataController.shared.container.viewContext.fetch(request)
            print("Got \(cards.count) Cards")
            //collectionView.reloadData()
        }
        catch {
            print("Fetch failed")
        }
    }
    
    func deleteCoreData(card: Card) {
        do {
            print("Attempting Delete")
            DataController.shared.viewContext.delete(card)
            try DataController.shared.viewContext.save()
            }
            // Save Changes
         catch {
            // Error Handling
            // ...
             print("Couldn't Delete")
         }
        self.loadCoreData()
    }
}
