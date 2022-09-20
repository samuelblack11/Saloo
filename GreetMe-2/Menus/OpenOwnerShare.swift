//
//  OpenOwnerShare.swift
//  GreetMe-2
//
//  Created by Sam Black on 9/19/22.
//

import Foundation
import SwiftUI

struct OpenOwnerShare: View {
    
    var body: some View {
        Image(uiImage: UIImage(data: UserDefaults.standard.object(forKey: "ownerCardImage") as! Data)!)
    }
}
