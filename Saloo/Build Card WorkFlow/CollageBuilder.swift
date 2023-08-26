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
    @State private var hasShownLaunchView: Bool = true

    // Create instance of CollageBuildingBlocks, with blocks sized to fit the CollageBuilder view (menuSize = false)
    @State private var image: Image?
    @State private var chosenImage: UIImage?
    @State var fillColor = Color.secondary
    @EnvironmentObject var appState: AppState
    @Environment(\.colorScheme) var colorScheme

    @State private var imageA: Image?
    @State private var imageB: Image?
    @State private var imageC: Image?
    @State private var imageD: Image?
    @State private var imageNumber: Int?
    @Environment(\.displayScale) var displayScale
    @State var lastScaleValue: CGFloat = 1.0
   // var minWidth = CGFloat(100)
   // var maxWidth = CGFloat(300)
    //var minHeight = CGFloat(100)
    //var maxHeight = CGFloat(320)
    //var width = UIScreen.screenWidth/2
    //var height = UIScreen.screenHeight/3
    var width = UIScreen.screenWidth/1.25
    var height = UIScreen.screenHeight/2.1
    @State private var blockCount: Int?
    @State private var currentStep: Int = 2
    @EnvironmentObject var cardProgress: CardProgress

    @State private var isImageLoading: [Bool] = [false, false, false, false]
    
    @State private var scaleA: CGFloat = 1.0
    @State private var offsetA: CGSize = .zero
    @State private var scaleB: CGFloat = 1.0
    @State private var offsetB: CGSize = .zero
    @State private var scaleC: CGFloat = 1.0
    @State private var offsetC: CGSize = .zero
    @State private var scaleD: CGFloat = 1.0
    @State private var offsetD: CGSize = .zero

    var collageView: some View {
        VStack {chosenTemplate}.frame(width: width, height: height)
    }
    
    var body: some View {
            let pinchText = collageImage.chosenStyle != 1 ? "Pinch the images to zoom and size them to the frame" : "Pinch the image to zoom and size it to the frame"
         let dragText = collageImage.chosenStyle != 1 ? "Drag the images within their frames to position them how you prefer" : "Drag the image within the frame to position it how you prefer"

        NavigationStack {
            VStack {
                CustomNavigationBar(onBackButtonTap: {cardProgress.currentStep = 1; appState.currentScreen = .buildCard([.photoOptionsView])}, titleContent: .text("Build Collage"))
                ProgressBar().frame(height: 20)
                    .frame(height: 20)
                ZStack {
                    VStack {
                        Text(pinchText)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(Font.custom("Papyrus", size: 16))
                            .textCase(.none)
                            .multilineTextAlignment(.center)
                        Text(dragText)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .font(Font.custom("Papyrus", size: 16))
                            .textCase(.none)
                            .multilineTextAlignment(.center)
                        Spacer()
                        collageView//.frame(width: UIScreen.screenHeight/4, height: UIScreen.screenHeight/4)
                        Button(action: resetZoomAndOffset) {
                            Image(systemName: "arrow.uturn.left")
                                .foregroundColor(.blue)
                            Text("Reset to Original Scale")
                                .font(Font.custom("Papyrus", size: 9))
                        }
                        .frame(alignment: .trailing)
                        Spacer()
                        Spacer()
                        Button(action: {
                            if blockCount != (4 - countNilImages()) {
                                alertVars.alertType = .mustSelectPic
                                alertVars.activateAlert = true
                            }
                            else {
                                cardProgress.currentStep = 3
                                appState.currentScreen = .buildCard([.writeNoteView])
                                Task {
                                    if let imageData = await snap2() {collageImage.collageImage = imageData}
                                    else {}
                                }
                                
                            }
                        }) {
                            Text("Confirm Collage")
                                .font(Font.custom("Papyrus", size: 16))
                        }
                        .padding(.bottom, 30)
                    }
                    .onAppear{
                        
                        countBlocks()
                        if chosenImagesObject.chosenImageA != nil {
                            imageA = Image(uiImage: chosenImagesObject.chosenImageA!)
                        }
                        
                    }
                    .alert(isPresented: $explicitPhotoAlert) {
                        Alert(title: Text("Error"), message: Text("The selected image contains explicit content and cannot be used."), dismissButton: .default(Text("OK")))
                    }
                    LoadingOverlay(hasShownLaunchView: $hasShownLaunchView)
                }
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
    
    func blockForPhotoSelection(imageForBlock: Image?, imageNum: Int, scale: Binding<CGFloat>, offset: Binding<CGSize>, onScaleChanged: @escaping (CGFloat) -> Void, onOffsetChanged: @escaping (CGSize) -> Void) -> some View {
        let shapeOptions = defineShapes()
        var thisShape = String()
        if imageNum == 1 { thisShape = shapeOptions.0 }
        if imageNum == 2 { thisShape = shapeOptions.1 }
        if imageNum == 3 { thisShape = shapeOptions.2 }
        if imageNum == 4 { thisShape = shapeOptions.3 }
        let (w2, h2) = shapeToDimensions(shape: thisShape)
        @State var currentZoom = 0.0
        @State var totalZoom = 1.0
        @State var currentOffset: CGSize = .zero
        @State var endingOffset: CGSize = .zero

        return GeometryReader { geometry in
            ZStack(alignment: .center) {
                if imageForBlock == nil {
                    Rectangle().fill(Color.gray)
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .font(Font.custom("Papyrus", size: 16))

                }
                if isImageLoading[imageNum - 1] {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2, anchor: .center)
                }
                imageForBlock?
                    .resizable()
                    .scaledToFit()
                    .frame(width: w2, height: h2)
                    //.clipped()
                    .scaleEffect(scale.wrappedValue, anchor: .center)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let newScale = totalZoom + value - 1
                                scale.wrappedValue = newScale
                                onScaleChanged(newScale)
                            }
                            .onEnded { value in
                                totalZoom += value - 1
                            }
                    )
                    .offset(CGSize(width: offset.wrappedValue.width + currentOffset.width, height: offset.wrappedValue.height + currentOffset.height))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                offset.wrappedValue = gesture.translation
                                onOffsetChanged(gesture.translation)
                            }
                            .onEnded { gesture in
                                let translation = gesture.translation
                                let newOffset = CGSize(width: offset.wrappedValue.width + translation.width, height: offset.wrappedValue.height + translation.height)
                                offset.wrappedValue = newOffset
                                onOffsetChanged(newOffset)
                            }
                    )
                    .clipped()


            }
            .border(Color("SalooTheme"))
        }
        .onTapGesture {
            self.showImagePicker.toggle()
            imageNumber = imageNum
            isImageLoading[imageNum - 1] = true
        }
        .onChange(of: specifyImage(imageNumber: imageNum)) { _ in
            loadImage(chosenImage: specifyImage(imageNumber: imageNum))
            isImageLoading[imageNum - 1] = false
        }
    }


    
    func calculateMinScale(frameSize: CGSize, imageSize: CGSize) -> CGFloat {
        let scaleX = frameSize.width / imageSize.width
        let scaleY = frameSize.height / imageSize.height
        return max(min(scaleX, scaleY), 1.0)
    }




    func block1() -> some View {
        return VStack {
            blockForPhotoSelection(imageForBlock: imageA, imageNum: 1, scale: $scaleA, offset: $offsetA, onScaleChanged: { scale in
                scaleA = scale
            }, onOffsetChanged: { offset in
                offsetA = offset
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageA, explicitPhotoAlert: $explicitPhotoAlert, isImageLoading: $isImageLoading[0])
            }
        }
        .clipped()
    }

    
    func block2() -> some View {
        return VStack {
            blockForPhotoSelection(imageForBlock: imageB, imageNum: 2, scale: $scaleB, offset: $offsetB, onScaleChanged: { scale in
                scaleB = scale
            }, onOffsetChanged: { offset in
                offsetB = offset
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageB, explicitPhotoAlert: $explicitPhotoAlert, isImageLoading: $isImageLoading[1])
            }
        }
        .clipped()
    }
    
    func block3() -> some View {
        return VStack {
            blockForPhotoSelection(imageForBlock: imageC, imageNum: 3, scale: $scaleC, offset: $offsetC, onScaleChanged: { scale in
                scaleC = scale
            }, onOffsetChanged: { offset in
                offsetC = offset
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageC, explicitPhotoAlert: $explicitPhotoAlert, isImageLoading: $isImageLoading[2])
            }
        }
        .clipped()
    }
    
    func block4() -> some View {
        return VStack {
            blockForPhotoSelection(imageForBlock: imageD, imageNum: 4, scale: $scaleD, offset: $offsetD, onScaleChanged: { scale in
                scaleD = scale
            }, onOffsetChanged: { offset in
                offsetD = offset
            })
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $chosenImagesObject.chosenImageD, explicitPhotoAlert: $explicitPhotoAlert, isImageLoading: $isImageLoading[3])
            }
        }
        .clipped()
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

    @MainActor func snap2() async -> Data? {
        let renderer = ImageRenderer(content: collageView)
        renderer.scale = displayScale
        
        guard let uiImage = renderer.uiImage,
              let imageData = uiImage.pngData() else {
            return nil
        }
        return imageData
    }

    func resetZoomAndOffset() {
        scaleA = 1.0
        offsetA = .zero
        scaleB = 1.0
        offsetB = .zero
        scaleC = 1.0
        offsetC = .zero
        scaleD = 1.0
        offsetD = .zero
    }



    func loadImage(chosenImage: UIImage?) {
        
        //chosenImagesObject.imagePlaceHolder = Image(systemName: "rays")
        
        guard let chosenImage = chosenImage else {return}
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
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
