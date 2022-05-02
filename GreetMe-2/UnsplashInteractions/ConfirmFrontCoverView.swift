//
//  ConfirmFrontCoverView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//

import Foundation
import SwiftUI

struct ConfirmFrontCoverView: View {
    
    var coverImageObject: CoverImageObject!
    var coverImage: Image!

    var body: some View {
        VStack {
            Text("Hello")
            coverImageObject.coverImage
            //coverImageObject.coverImage
            //coverImageObject.coverImagePhotographer
        }
    }
    
}
