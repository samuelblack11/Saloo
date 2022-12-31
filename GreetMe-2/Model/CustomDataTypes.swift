//
//  CustomDataTypes.swift
//  GreetMe-2
//
//  Created by Sam Black on 12/24/22.
//

import Foundation
import UIKit
import SwiftUI
import CloudKit

struct ChosenCollection {@State var occassion: String!; @State var collectionID: String!}
class Occassion: ObservableObject {@Published var occassion = String(); @Published var collectionID = String()}
public class ShowDetailView: ObservableObject {@Published public var showDetailView: Bool = false}

class ChosenCoverImageObject: ObservableObject {
    @Published var id = UUID()
    @Published var coverImage = Data()
    @Published var smallImageURLString = String()
    @Published var coverImagePhotographer = String()
    @Published var coverImageUserName = String()
    @Published var downloadLocation = String()
    @Published var index = Int()
    //func hash(into hasher: inout Hasher) {
    //    hasher.combine(downloadLocation)
    //}
}

class NoteField: ObservableObject  {
    @Published var noteText = String()
    @Published var recipient =  String()
    @Published var cardName = String()
    @Published var font = String()
    @Published var willHandWrite = Bool()
    @Published var eCardText = String()
    @Published var printCardText = String()
}


struct CoverImageObject: Identifiable, Hashable {
    let id = UUID()
    let coverImage: Data?
    let smallImageURL: URL
    let coverImagePhotographer: String
    let coverImageUserName: String
    let downloadLocation: String
    let index: Int
    func hash(into hasher: inout Hasher) {
        hasher.combine(downloadLocation)
    }
}

struct CollageImage {let collageImage: UIImage}
class HandWrite: ObservableObject { @Published var willHandWrite: Bool = false}

// https://programmingwithswift.com/swiftui-textfield-character-limit/
class TextLimiter: ObservableObject {
    // variable for character limit
    private let limit: Int
    init(limit: Int) {self.limit = limit}
    // value that text field displays
    @Published var value = "Write Your Note Here" {
        didSet {
            if value.count > self.limit {
                value = String(value.prefix(self.limit))
                self.hasReachedLimit = true
            } else {self.hasReachedLimit = false}
        }
    }
    @Published var hasReachedLimit = false
}

class CollageStyles {
    enum choices {case one; case two; case three; case four; case five; case six}
}

public class CollageBuildingBlocks {
    var menuSize: Bool
    var smallDim: CGFloat
    var largeDim: CGFloat
    
    init(menuSize: Bool) {
        self.menuSize = menuSize
        if menuSize {smallDim = 0.45; largeDim = 0.9}
        else {smallDim = 0.45; largeDim = 0.9}
    }
    
    @ViewBuilder var smallSquare: some View {
        GeometryReader {geometry in
            HStack(spacing: 0) {Rectangle().fill(Color.gray).frame(width: geometry.size.width * self.smallDim, height: geometry.size.width * self.smallDim ).border(Color.black)}}
    }
    @ViewBuilder var wideRectangle: some View {
        GeometryReader {geometry in
            HStack(spacing: 0) {Rectangle().fill(Color.gray).frame(width: geometry.size.width * self.largeDim, height: geometry.size.width * self.smallDim).border(Color.black)}}
    }
    @ViewBuilder var tallRectangle: some View {
        GeometryReader {geometry in
            HStack(spacing: 0) {Rectangle().fill(Color.gray).frame(width: geometry.size.width * self.smallDim, height: geometry.size.width * self.largeDim).border(Color.black)}}
    }

    func createLargeSquare() -> GeometryReader<VStack<some View>> {
        return GeometryReader {geometry in
            VStack {Rectangle().fill(Color.gray).frame(width: geometry.size.width * self.largeDim, height: geometry.size.width * self.largeDim).padding(.vertical)}}
    }
    
    @ViewBuilder var onePhotoView: some View {createLargeSquare()}
    @ViewBuilder var twoPhotoWide: some View {VStack(spacing:0){wideRectangle; wideRectangle}}
    @ViewBuilder var twoPhotoLong: some View {HStack(spacing:0){tallRectangle; tallRectangle}}
    @ViewBuilder var twoShortOneLong: some View {HStack(spacing:0){VStack(spacing:0){smallSquare; smallSquare}; tallRectangle}}
    @ViewBuilder var twoNarrowOneWide: some View {VStack(spacing:0){HStack(spacing:0){smallSquare; smallSquare}; wideRectangle}}
    @ViewBuilder var fourPhoto: some View {HStack(spacing:0){smallSquare; smallSquare}; HStack(spacing:0){smallSquare; smallSquare}}
    

}











































// https://www.hackingwithswift.com/quick-start/swiftui/how-to-convert-a-swiftui-view-to-an-image
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        print("Target Size: \(targetSize)")
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
