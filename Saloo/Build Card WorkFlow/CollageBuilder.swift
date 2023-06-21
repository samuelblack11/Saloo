//
//  CollageBuilder2.swift
//  GreetMe-2
//
//  Created by Sam Black on 12/30/22.
//

import Foundation
import SwiftUI
import PDFKit

struct CollageBuilder: View {
    // The image, and it's components, selected by the user
    @EnvironmentObject var chosenObject: ChosenCoverImageObject
    // Object for collection selected by user
    @EnvironmentObject var chosenOccassion: Occassion
    //@State public var chosenCollageStyle: CollageStyles.choices
    @EnvironmentObject var chosenStyle: ChosenCollageStyle
    // Variable for collageImage object
    @EnvironmentObject var collageImage: CollageImage
    @EnvironmentObject var chosenImagesObject: ChosenImages
    @State var explicitPhotoAlert: Bool = false
    @State var showImagePicker: Bool
    // Counts the page of the response being viewed by the user. 30 images per page maximum
    // Is front cover a personal photo? (selected from camera or library)
    // Tracks which collage type (#) was selected by the user
    @State private var cBB = CollageBlocksAndViews()
    @ObservedObject var gettingRecord = GettingRecord.shared
    @ObservedObject var alertVars = AlertVars.shared
    
    // Create instance of CollageBuildingBlocks, with blocks sized to fit the CollageBuilder view (menuSize = false)
    @State private var image: Image?
    @State private var chosenImage: UIImage?
    @State var fillColor = Color.secondary
    @EnvironmentObject var appState: AppState
    
    @State private var imageA: Image?
    @State private var imageB: Image?
    @State private var imageC: Image?
    @State private var imageD: Image?
    @State private var imageNumber: Int?
    @Environment(\.displayScale) var displayScale
    @State var lastScaleValue: CGFloat = 1.0
    var minWidth = CGFloat(100)
    var maxWidth = CGFloat(300)
    var minHeight = CGFloat(100)
    var maxHeight = CGFloat(320)
    var width = UIScreen.screenWidth/2
    var height = UIScreen.screenHeight/3
    @State private var blockCount: Int?
    
    @State private var isImageLoading: [Bool] = [false, false, false, false]

    
    var collageView: some View {
        VStack {chosenTemplate}.frame(width: width, height: height)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Spacer()
                    collageView//.frame(width: UIScreen.screenHeight/4, height: UIScreen.screenHeight/4)
                    Spacer()
                    Button("Confirm Collage") {
                        if blockCount != (4 - countNilImages()) {
                            alertVars.alertType = .mustSelectPic
                            alertVars.activateAlert = true
                        }
                        else {
                            appState.currentScreen = .buildCard([.writeNoteView])
                            collageImage.collageImage = snap2()
                        }
                    }.padding(.bottom, 30)
                        .navigationBarItems(leading: Button {appState.currentScreen = .buildCard([.collageStyleMenu])} label: {
                            Image(systemName: "chevron.left").foregroundColor(.blue)
                            Text("Back")}.disabled(gettingRecord.isShowingActivityIndicator))
                }
                .onAppear{countBlocks()}
                .alert(isPresented: $explicitPhotoAlert) {
                    Alert(title: Text("Error"), message: Text("The selected image contains explicit content and cannot be used."), dismissButton: .default(Text("OK")))
                }
                LoadingOverlay()
            }
            .modifier(AlertViewMod(showAlert: alertVars.activateAlertBinding, activeAlert: alertVars.alertType))
        }
    }
        @ViewBuilder var chosenTemplate: some View {
            if collageImage.chosenStyle == 1 {onePhotoView(block: block1())}
            if collageImage.chosenStyle == 2 {twoPhotoWide(block1: block1(),block2: block2())}
            if collageImage.chosenStyle == 3 {twoPhotoLong(block1: block1(),block2: block2())}
            if collageImage.chosenStyle == 4 { twoShortOneLong(block1: block1(), block2: block2(), block3: block3())}
            if collageImage.chosenStyle == 5 {twoNarrowOneWide(block1: block1(),block2: block2(),block3: block3())}
            if collageImage.chosenStyle == 6 {fourPhoto(block1: block1(),block2: block2(), block3: block3(), block4: block4())}
        }
    
}

extension CollageBuilder {
    
    func countBlocks() {
        if collageImage.chosenStyle == 1 {blockCount = 1}
        if collageImage.chosenStyle == 2 {blockCount = 2}
        if collageImage.chosenStyle == 3 {blockCount = 2}
        if collageImage.chosenStyle == 4 {blockCount = 3}
        if collageImage.chosenStyle == 5 {blockCount = 3}
        if collageImage.chosenStyle == 6 {blockCount = 4}
    }
    
    
    
    
    
    
    func specifyImage(imageNumber: Int) -> UIImage? {
        let imageDict: [Int : UIImage?] = [
            1 : chosenImagesObject.chosenImageA,
            2 : chosenImagesObject.chosenImageB,
            3 : chosenImagesObject.chosenImageC,
            4 : chosenImagesObject.chosenImageD,
        ]
        return imageDict[imageNumber]!
    }
    
    func blockForPhotoSelection(imageForBlock: Image?, imageNum: Int) -> some View {
        let shapeOptions = defineShapes()
        var thisShape = String()
        if imageNum == 1 {thisShape = shapeOptions.0}
        if imageNum == 2 {thisShape = shapeOptions.1}
        if imageNum == 3 {thisShape = shapeOptions.2}
        if imageNum == 4 {thisShape = shapeOptions.3}
        let (w2, h2) = shapeToDimensions(shape: thisShape)
        
        return GeometryReader {geometry in
            ZStack(alignment: .center) {
                Rectangle().fill(Color.gray).border(Color.black)
                Text("Tap to select a picture").foregroundColor(.white).font(.headline)
                if isImageLoading[imageNum - 1]  {
                    ProgressView() // Shows activity indicator when image is loading
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2, anchor: .center)
                }
                imageForBlock?
                    .resizable()
                    .scaledToFill()
                    .frame(width: w2, height: h2)
                    //.border(Color.pink)
                    .clipped()
            }
        }
        .onTapGesture {
            self.showImagePicker.toggle();
            imageNumber = imageNum
            isImageLoading[imageNum - 1]  = true // Start loading
        }
        .onChange(of: specifyImage(imageNumber: imageNum)) { _ in
            loadImage(chosenImage: specifyImage(imageNumber: imageNum))
            isImageLoading[imageNum - 1]  = false // Finish loading
        }
    }
    
    func block1() -> some View {
        return blockForPhotoSelection(imageForBlock: imageA, imageNum: 1)
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageA, explicitPhotoAlert: $explicitPhotoAlert, isImageLoading: $isImageLoading[0])
            }
    }
    
    func block2() -> some View {
        return blockForPhotoSelection(imageForBlock: imageB, imageNum: 2)
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageB, explicitPhotoAlert: $explicitPhotoAlert, isImageLoading: $isImageLoading[1])
            }
    }
    
    func block3() -> some View {
        return blockForPhotoSelection(imageForBlock: imageC, imageNum: 3)
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageC, explicitPhotoAlert: $explicitPhotoAlert, isImageLoading: $isImageLoading[2])
            }
    }
    
    func block4() -> some View {
        return blockForPhotoSelection(imageForBlock: imageD, imageNum: 4)
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageD, explicitPhotoAlert: $explicitPhotoAlert, isImageLoading: $isImageLoading[3])
            }
    }
    
    func onePhotoView(block: some View) -> some View {return block}
    func twoPhotoWide(block1: some View, block2: some View) -> some View {return VStack(spacing:0){block1; block2}}
    func twoPhotoLong(block1: some View, block2: some View) -> some View {return HStack(spacing:0){block1; block2}}
    func twoShortOneLong(block1: some View, block2: some View, block3: some View) -> some View {return HStack(spacing:0){VStack(spacing:0){block1; block2}; block3}}
    func twoNarrowOneWide(block1: some View, block2: some View, block3: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block1; block2}; block3}}
    func fourPhoto(block1: some View, block2: some View, block3: some View, block4: some View) -> some View {return VStack(spacing:0){HStack(spacing:0){block1; block2}; HStack(spacing:0){block3; block4}}}
    
    func defineShapes() -> (String, String, String, String) {
        var shape1 = ""; var shape2 = ""; var shape3 = ""; var shape4 = ""
        // List shape of each block for each collage styl e
        if collageImage.chosenStyle == 1{shape1 = "largeSquare" }
        if collageImage.chosenStyle == 2{shape1 = "wide"; shape2 = "wide"}
        if collageImage.chosenStyle == 3{shape1 = "tall"; shape2 = "tall" }
        if collageImage.chosenStyle == 4{shape1 = "smallSquare"; shape2 = "smallSquare"; shape3 = "tall"}
        if collageImage.chosenStyle == 5{shape1 = "smallSquare"; shape2 = "smallSquare"; shape3 = "wide"}
        if collageImage.chosenStyle == 6{shape1 = "smallSquare"; shape2 = "smallSquare"; shape3 = "smallSquare"; shape4 = "smallSquare"}

        return (shape1, shape2, shape3, shape4)
    }
    
    func shapeToDimensions(shape: String) -> (CGFloat, CGFloat){
        var w = CGFloat(0.0)
        var h = CGFloat(0.0)
        if shape == "largeSquare" {w = width; h = height}
        if shape == "wide" {w = width; h = height/2}
        if shape == "tall" {w = width/2; h = height}
        if shape == "smallSquare" {w = width/2; h = height/2}
        return (w, h)
    }

    @MainActor func snap2() -> Data {
        let renderer = ImageRenderer(content: collageView)
        
        renderer.scale = displayScale
        var data = Data()
        if let uiImage = renderer.uiImage {
            data = uiImage.jpegData(compressionQuality: 1.0)!
            //data = uiImage.pngData()!
        }
        return data
    }

    func loadImage(chosenImage: UIImage?) {
        
        //chosenImagesObject.imagePlaceHolder = Image(systemName: "rays")
        
        print("called load image.....")
        guard let chosenImage = chosenImage else {return print("loadImage() failed....")}
        if imageNumber == 1 {imageA = Image(uiImage: chosenImage); collageImage.image1 = chosenImage.pngData()!}
        if imageNumber == 2 {imageB = Image(uiImage: chosenImage); collageImage.image2 = chosenImage.pngData()!}
        if imageNumber == 3 {imageC = Image(uiImage: chosenImage); collageImage.image3 = chosenImage.pngData()!}
        if imageNumber == 4 {imageD = Image(uiImage: chosenImage); collageImage.image4 = chosenImage.pngData()!}
    }
    
    func countNilImages() -> Int {
        let images: [Image?] = [imageA, imageB, imageC, imageD]
        let nonNilImages = images.compactMap { $0 }
        return images.count - nonNilImages.count
    }

    
}

struct PhotoDetailView: UIViewRepresentable {
    let image: UIImage

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.document = PDFDocument()
        guard let page = PDFPage(image: image) else { return view }
        view.document?.insert(page, at: 0)
        view.autoScales = true
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // empty
    }
}

// 
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

