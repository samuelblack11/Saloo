//
//  ScheduleDelivery.swift
//  GreetMe-2
//
//  Created by Sam Black on 9/1/22.
//

import Foundation
import SwiftUI
import CloudKit
// https://developer.apple.com/documentation/swiftui/datepicker
// https://www.hackingwithswift.com/books/ios-swiftui/adding-to-a-list-of-words

struct ScheduleDelivery: View {
    @State var card: Card
    @State private var deliveryDate = Date()
    @State private var recipientList = [String]()
    @State private var newRecipient = ""
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())
        let day = calendar.component(.day, from: Date())
        let startComponents = DateComponents(year: year, month: month, day: day)
        let endComponents = DateComponents(year: 2030, month: 12, day: 31, hour: 23, minute: 59, second: 59)
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(selection: $deliveryDate, in: dateRange, displayedComponents: [.hourAndMinute, .date, ]) {
                    Text("Select a date")
                }
                Section {
                    Text("Add Recipients:")
                    TextField("Enter Recipient Phone or Email", text: $newRecipient)
                        .autocapitalization(.none)
                }
                Section {
                    Text("Recipient List:")
                    ForEach(recipientList, id: \.self) { word in
                        Text(word)
                    }
                }
                Spacer()
                Button {
                    
                    } label: {
                        Text("Schedule Delivery")
                        }
                }
            }
            .onSubmit {
                addNewWord()
            }
    }
    
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newRecipient.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        guard answer.count > 0 else { return }

        // extra validation to come
        recipientList.insert(answer, at: 0)
        newRecipient = ""
    }
    
    func saveDelivery() {
        //save to core data
        let del = FutureDelivery(context: CoreDataStack.shared.context)
        //del.recipientList = recipientList
        //del.deliveryDate = deliveryDate
        self.saveContext()
        
    }
    
    func saveContext() {
        if CoreDataStack.shared.context.hasChanges {
            do {
                try CoreDataStack.shared.context.save()
                }
            catch {
                print("An error occurred while saving: \(error)")
                }
            }
        }
    
}
