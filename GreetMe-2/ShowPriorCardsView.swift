//
//  ShowPriorCardsView.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import Foundation
import SwiftUI

struct ShowPriorCardsView: View {
    // https://www.hackingwithswift.com/read/38/5/loading-core-data-objects-using-nsfetchrequest-and-nssortdescriptor
    @State var cards = [Card]()
    let columns = [GridItem(.fixed(150))]

    var body: some View {
        NavigationView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(cards, id: \.self) {card in
                    VStack(spacing: 0) {
                        HStack(spacing:0) {
                        Image(uiImage: UIImage(data: card.coverImage!)!).resizable().frame(width: (UIScreen.screenWidth/3)-2, height: (UIScreen.screenWidth/3))
                            Text(card.message!).font(.system(size: 6)).frame(width: (UIScreen.screenWidth/3)-10, height: (UIScreen.screenWidth/3))
                        Image(uiImage: UIImage(data: card.collage!)!).resizable().frame(width: (UIScreen.screenWidth/3)-2, height: (UIScreen.screenWidth/3))
                        }
                        HStack(spacing: 3) {
                            Text(card.recipient!)
                            Spacer()
                            Text(card.occassion!)
                        }
                    }
                    
                }
            }
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
    
    func deleteCoreData() {
        // https://cocoacasts.com/how-to-delete-every-record-of-a-core-data-entity
        let request = Card.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        do {
            cards = try DataController.shared.container.viewContext.fetch(request)
            for card in cards {
                DataController.shared.viewContext.delete(card)
            }
            // Save Changes
            try DataController.shared.viewContext.save()

        } catch {
            // Error Handling
            // ...
        }
    }
}
