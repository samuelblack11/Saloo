//
//  ShowPriorCardsView.swift
//  GreetMe-2
//
//  Created by Sam Black on 4/30/22.
//

import Foundation
import SwiftUI

struct ShowPriorCardsView: View {
    let columns = [GridItem(.fixed(150)),GridItem(.fixed(150))]

    var body: some View {
        NavigationView {
            LazyVGrid(columns: columns, spacing: 10) {
                Text("Hello")
            }
        }
    }
}

struct ShowPriorCardsView_Previews: PreviewProvider {
    static var previews: some View {
        CollageOneView()
    }
}
