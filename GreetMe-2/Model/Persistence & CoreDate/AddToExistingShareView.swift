//
//  AddToExistingShareView.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/10/23.
//

import SwiftUI
import CoreData
import CloudKit

struct AddToExistingShareView: View {
    @Binding var activeSheet: ActiveSheet?
    var card: CoreCard
    
    @State private var toggleProgress: Bool = false
    @State private var selection: String?

    var body: some View {
        ZStack {
            SharePickerView(activeSheet: $activeSheet, selection: $selection) {
                Button("Add") { shareCard(card, shareTitle: selection) }
                .disabled(selection == nil)
            }
            if toggleProgress {
                ProgressView()
            }
        }
    }
    
    private func shareCard(_ unsharedCard: CoreCard, shareTitle: String?) {
        toggleProgress.toggle()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let persistenceController = PersistenceController.shared
            if let shareTitle = shareTitle, let share = persistenceController.share(with: shareTitle) {
                persistenceController.shareObject(unsharedCard, to: share)
            }
            toggleProgress.toggle()
            activeSheet = nil
        }
    }
}

