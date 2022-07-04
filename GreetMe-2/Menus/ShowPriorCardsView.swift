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
    let columns = [GridItem(.fixed(140)), GridItem(.fixed(140))]
    
    var body: some View {
        NavigationView {
            ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(cards, id: \.self) {card in
                    VStack(spacing: 0) {
                        VStack(spacing:1) {
                            Image(uiImage: UIImage(data: card.coverImage!)!)
                                .resizable()
                                .frame(width: (UIScreen.screenWidth/3), height: (UIScreen.screenHeight/7))
                            Text(card.message!)
                                .font(Font.custom(card.font!, size: 500))
                                .minimumScaleFactor(0.01)
                                .frame(width: (UIScreen.screenWidth/3), height: (UIScreen.screenHeight/8))
                            Image(uiImage: UIImage(data: card.collage!)!)
                                .resizable()
                                .frame(maxWidth: (UIScreen.screenWidth/4), maxHeight: (UIScreen.screenHeight/7))
                            HStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    Text(card.an1!)
                                        .font(.system(size: 4))
                                    Link(card.an2!, destination: URL(string: card.an2URL!)!)
                                        .font(.system(size: 4))
                                    Text(card.an3!).font(.system(size: 4))
                                    Link(card.an4!, destination: URL(string: "https://unsplash.com")!).font(.system(size: 4))
                                    }
                                    .padding(.trailing, 5)

                                Spacer()
                                Image(systemName: "greetingcard.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 24))
                                Spacer()
                                VStack(spacing:0) {
                                    Text("Greeting Card")
                                        .font(.system(size: 4))
                                    Text("by")
                                        .font(.system(size: 4))
                                    Text("GreetMe Inc.")
                                        .font(.system(size: 4))
                                        .padding(.bottom,10)
                                        .padding(.leading, 5)
                                    }
                            }.frame(width: (UIScreen.screenWidth/3), height: (UIScreen.screenHeight/15))
                                
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
                        Divider().padding(.bottom, 5)
                        HStack(spacing: 3) {
                            Text(card.recipient!)
                                .font(.system(size: 8))
                                .minimumScaleFactor(0.1)
                            Spacer()
                            Text(card.occassion!)
                                .font(.system(size: 8))
                                .minimumScaleFactor(0.1)
                        }
                        //Divider()
                            //.padding(.top, 20)
                            //.padding(.bottom, 20)
                        }
                    .padding()
                        .overlay(RoundedRectangle(cornerRadius: 6)
                            .stroke(.blue, lineWidth: 2))
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
