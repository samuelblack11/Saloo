//
//  LearningSwiftUI
//
//  Created by Sam Black on 4/28/22.
//
// 

import Foundation
import SwiftUI

struct MiniCollageMenu: View {
    // The image, and it's components, selected by the user
    // Object for collection selected by user
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    @EnvironmentObject var chosenOccassion: Occassion
    @EnvironmentObject var collageImage: CollageImage
    @State private var showImagePicker = false
    @EnvironmentObject var appDelegate: AppDelegate
    // Is front cover a personal photo? (selected from camera or library)
    // Tracks which collage type (#) was selected by the user
    @State private var collageBlocks = CollageBlocksAndViews()
    @ObservedObject var gettingRecord = GettingRecord.shared
    @ObservedObject var alertVars = AlertVars.shared
    let columns = [GridItem(.flexible()),GridItem(.flexible())]
    @EnvironmentObject var appState: AppState
    @State private var hasShownLaunchView: Bool = true
    @State private var selectedStyle: Int? = nil
    var miniWidth = UIScreen.screenWidth/4
    var miniHeight = UIScreen.screenHeight/8
    var body: some View {
                VStack {
                    HStack {
                        NumberView(number: 1, selectedStyle: $selectedStyle) {
                            collageImage.imageCount = 1
                            selectedStyle = 1
                        }
                        .frame(width: miniWidth, height: miniHeight)
                        .bordered(style: 1, selectedStyle: $selectedStyle)

                        NumberView(number: 2, selectedStyle: $selectedStyle) {
                            collageImage.imageCount = 2
                            selectedStyle = 2
                        }
                        .frame(width: miniWidth, height: miniHeight)
                        .bordered(style: 2, selectedStyle: $selectedStyle)

                    }
                    HStack {
                        NumberView(number: 3, selectedStyle: $selectedStyle) {
                            collageImage.imageCount = 3
                            selectedStyle = 3
                        }
                        .frame(width: miniWidth, height: miniHeight)
                        .bordered(style: 3, selectedStyle: $selectedStyle)

                        NumberView(number: 4, selectedStyle: $selectedStyle) {
                            collageImage.imageCount = 4
                            selectedStyle = 4
                        }
                        .frame(width: miniWidth, height: miniHeight)
                        .bordered(style: 4, selectedStyle: $selectedStyle)
                    }
                }
            .environmentObject(collageImage)
    }
}

extension View {
    func bordered(style: Int, selectedStyle: Binding<Int?>, color: Color = Color("SalooTheme"), width: CGFloat = 5) -> some View {
        self.modifier(BorderedStyleModifier(style: style, selectedStyle: selectedStyle, width: width))
    }
}

struct BorderedStyleModifier: ViewModifier {
    let style: Int
    @Binding var selectedStyle: Int?
    let color = Color("SalooTheme")
    let width: CGFloat
    
    func body(content: Content) -> some View {
        Group {
            if style == selectedStyle {content.border(color, width: width)}
            else {content}
        }
    }
}

struct NumberView: View {
    let number: Int
    @Binding var selectedStyle: Int?
    let onTap: () -> Void
    
    var body: some View {
        Text(String(number))
            .font(.title)
            .onTapGesture {onTap()}
    }
}
