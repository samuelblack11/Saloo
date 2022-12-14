//
//  FinalizeCardView.swift
//  GreetMe-2
//
//  Created by Sam Black on 5/1/22.
//

import Foundation
import SwiftUI
import CoreData
import CloudKit

struct FinalizeCardView: View {
    @Environment(\.presentationMode) var presentationMode
    var card: Card!
    @Binding var chosenObject: CoverImageObject!
    @Binding var collageImage: CollageImage!
    @Binding var noteField: NoteField!
    @State var frontCoverIsPersonalPhoto: Int
    @Binding var text1: String
    @Binding var text2: String
    @Binding var text2URL: URL
    @Binding var text3: String
    @Binding var text4: String
    @State var presentMenu = false
    @ObservedObject var willHandWrite: HandWrite
    @Binding var eCardText: String
    @Binding var printCardText: String
    //@Binding var cardForExport: Data!
    @State private var showActivityController = false
    @State var activityItemsArray: [Any] = []
    @State var searchObject: SearchParameter
    @State var saveAndShareIsActive = false
    @State private var showCompleteAlert = false
    var field1: String!
    var field2: String!
    @State var string1: String!
    @State var string2: String!
    @State private var showShareSheet = false
    @State var share: CKShare?


    
    var eCardVertical: some View {
        VStack(spacing:1) {
            Image(uiImage: UIImage(data: chosenObject.coverImage!)!)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/8))
            Text(eCardText)
                .font(Font.custom(noteField.font, size: 500))
                .minimumScaleFactor(0.01)
                .frame(maxWidth: (UIScreen.screenWidth/4), maxHeight: (UIScreen.screenHeight/9))
            Image(uiImage: collageImage.collageImage)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/8))
            HStack(spacing: 0) {
                VStack(spacing:0){
                Text(text1)
                    .font(.system(size: 4))
                    .frame(alignment: .center)
                Link(text2, destination: text2URL)
                    .font(.system(size: 4))
                    .frame(alignment: .center)
                HStack(spacing: 0) {
                    Text(text3).font(.system(size: 4))
                        .frame(alignment: .center)
                    Link(text4, destination: URL(string: "https://unsplash.com")!)
                        .font(.system(size: 4))
                        .frame(alignment: .center)
                    }
                }
                Spacer()
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 12))
                    .frame(alignment: .center)
                Spacer()
                //VStack(spacing:0) {
                    //Text("Greeting Card by")
                        //.font(.system(size: 4))
                        //.frame(alignment: .center)
                    //Text("GreetMe Inc.")
                       //.font(.system(size: 4))
                        //.frame(alignment: .center)
                    //}
                }.frame(width: (UIScreen.screenWidth/4), height: (UIScreen.screenHeight/22))
        }.frame(width: (UIScreen.screenWidth/3.5), height: (UIScreen.screenHeight/2.5))
    }
    
    var cardForPrint: some View {
        VStack(spacing: 1) {
            HStack(spacing: 1) {
            //upside down collage
                Image(uiImage: collageImage.collageImage)
                    .resizable()
                    .frame(width: (UIScreen.screenWidth/4.5), height: (UIScreen.screenHeight/7), alignment: .center)
            //upside down message
                Text(printCardText)
                    .frame(width: (UIScreen.screenWidth/4.5), height: (UIScreen.screenHeight/7), alignment: .center)
                    .font(Font.custom(noteField.font, size: 500))
                    .minimumScaleFactor(0.01)
                    .padding(.init(top: 0, leading: 5, bottom: 0, trailing: 5))
                }
                .rotationEffect(Angle(degrees: 180))
                .frame(width: (UIScreen.screenWidth/2.25), height: (UIScreen.screenHeight/7), alignment: .center)

        // Front Cover & Back Cover
        HStack(spacing: 1)  {
            //Back Cover
            VStack(spacing: 1) {
                Image(systemName: "greetingcard.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 32))
                Spacer()
                Text(text1)
                    .font(.system(size: 4))
                Link(text2, destination: text2URL)
                    .font(.system(size: 4))
                HStack(spacing: 0) {
                    Text(text3)
                        .font(.system(size: 4))
                    Link(text4, destination: URL(string: "https://unsplash.com")!)
                        .font(.system(size: 4))
                }
            }
            .frame(width: (UIScreen.screenWidth/4.5), height: (UIScreen.screenHeight/7))
            // Front Cover
            HStack(spacing: 1)  {
                Image(uiImage: UIImage(data: chosenObject.coverImage!)!)
                    .resizable()
            }.frame(width: (UIScreen.screenWidth/4.5), height: (UIScreen.screenHeight/7))
            }.frame(width: (UIScreen.screenWidth/2.25))
        }
    }

    var body: some View {
        NavigationView {
        VStack(spacing: 0) {
            HStack(spacing: 0){
                Text("Your eCard will be stored like this:").frame(width: (UIScreen.screenWidth/3), height: (UIScreen.screenHeight/3))
                eCardVertical
            }
            Spacer()
            Divider()
            Spacer()
            HStack(spacing:0){
                Text("And will be printed like this:")
                HStack(spacing:0){
                    cardForPrint
                }.frame(alignment: .center)
            }
            Spacer()
            HStack {
                Button("Save eCard") {
                    saveECard()
                    //shareECardExternally()
                    saveAndShareIsActive = true
                    showCompleteAlert = true
                }
                .disabled(saveAndShareIsActive)
                .alert("Save Complete", isPresented: $showCompleteAlert) {
                    Button("Ok", role: .cancel) {
                        presentMenu = true
                    }
                }
                Spacer()
                Button("Export for Print") {
                    showActivityController = true
                    let cardForExport = prepCardForExport()
                    activityItemsArray = []
                    activityItemsArray.append(cardForExport)
                }.sheet(isPresented: $showActivityController) {
                    ActivityView(activityItems: $activityItemsArray, applicationActivities: nil)
                }
            }
        }
        .navigationBarItems(
            leading:Button {presentationMode.wrappedValue.dismiss()}
            label: {Image(systemName: "chevron.left").foregroundColor(.blue)
            Text("Back")},
            trailing:Button {
                presentMenu = true
            }
                label: {Image(systemName: "menucard.fill").foregroundColor(.blue)
                Text("Menu")})
        .sheet(isPresented: $presentMenu) {
            OccassionsMenu(searchType: $string1, noneSearch: $string2, calViewModel: CalViewModel(), showDetailView: ShowDetailView(), oo2: false)
            }
        .onAppear(){

            }
        .sheet(isPresented: $showShareSheet, content: {
            if let share = share {
                CloudSharingView(share: share, container: CoreDataStack.shared.ckContainer, card: card)
            }
          })
        }
        }
    }


extension FinalizeCardView {
    
    func shareECardExternally() {
        showActivityController = true
        let cardForShare = SnapShotECard(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, eCardText: $eCardText, text1: $text1, text2: $text2, text2URL: $text2URL, text3: $text3, text4: $text4).snapShotECardViewVertical.snapshot()
        activityItemsArray = []
        activityItemsArray.append(cardForShare)
    }
    
    
    func saveECard() {
        //save to core data
        let card = Card(context: CoreDataStack.shared.context)
        card.card = eCardVertical.snapshot().pngData()
        card.cardName = noteField.cardName
        card.collage = collageImage.collageImage.pngData()
        card.coverImage = chosenObject.coverImage!
        card.date = Date.now
        card.message = noteField.noteText
        card.occassion = searchObject.searchText
        card.cardName = noteField.cardName
        card.recipient = noteField.recipient
        card.font = noteField.font
        card.an1 = text1
        card.an2 = text2
        card.an2URL = text2URL.absoluteString
        card.an3 = text3
        card.an4 = text4
        self.saveContext()
        
        
        let recordName = CKRecord.ID(recordName: "\(card.cardName!)-\(card.objectID)")
        //let cardRecord = CKRecord(recordType: "CD_Card", recordID: recordName)
        let cardRecord = CKRecord(recordType: "CD_Card", recordID: .init(zoneID: Card.SharedZone.ID))

        let coverURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(card.cardName!).png")
        let collageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(card.cardName!).png")

        do {
            print("trying save....")
            try card.coverImage?.write(to: coverURL)
            try card.collage?.write(to: collageURL)
            print("Save Success.....")
        }
        catch {
            print(error.localizedDescription)
        }
        cardRecord["CD_an1"] = card.an1 as? CKRecordValue
        cardRecord["CD_an2"] = card.an2 as? CKRecordValue
        cardRecord["CD_an2URL"] = card.an2URL as? CKRecordValue
        cardRecord["CD_an3"] = card.an3 as? CKRecordValue
        cardRecord["CD_an4"] = card.an4 as? CKRecordValue
        cardRecord["CD_font"] = card.font as? CKRecordValue
        cardRecord["CD_recipient"] = card.recipient as? CKRecordValue
        cardRecord["CD_occassion"] = card.occassion as? CKRecordValue
        cardRecord["CD_date"] = card.date as? CKRecordValue
        cardRecord["CD_cardName"] = card.cardName as? CKRecordValue
        cardRecord["CD_message"] = card.message as? CKRecordValue

        let coverAsset = CKAsset(fileURL: coverURL)
        let collageAsset = CKAsset(fileURL: collageURL)
        cardRecord["coverImage"] = coverAsset
        cardRecord["collage"] = collageAsset
        
        print("set card assets")
        // can sub in .publicCloudDatabase
        Task {
            print("$$$")
            saveToCloudKit(cardRecord: cardRecord, container: CoreDataStack.shared.ckContainer, card: card)
        }
    }
    
    func saveToCloudKit(cardRecord: CKRecord, container: CKContainer, card: Card) {
        
        var share = CKShare(rootRecord: cardRecord, shareID: cardRecord.recordID)
        share[CKShare.SystemFieldKey.title] = card.cardName
        share[CKShare.SystemFieldKey.thumbnailImageData] = card.coverImage
        share[CKShare.SystemFieldKey.shareType] = "Greeting"
        share.publicPermission = .readOnly
        
        let operation = CKModifyRecordsOperation.init(recordsToSave: [cardRecord, share], recordIDsToDelete: nil)
        print("Created Operation....")
        operation.modifyRecordsResultBlock = { result in
            print("#@#@")
            print(result)
        }
        let cardZone = CKRecordZone(zoneID: CKRecordZone.ID(zoneName: "\(card.cardName!)-\(card.objectID)"))
        let op2 = CKModifyRecordZonesOperation.init(recordZonesToSave: [cardZone])
        op2.modifyRecordZonesResultBlock = { result in
            print("#@#@")
            print(result)
        }
        
        let pdb = container.privateCloudDatabase
        pdb.add(operation)
        pdb.add(op2)
    }
    
    
    func shareCards(container: CKContainer, cardZone: CKRecordZone) async throws -> CKShare {
        let pdb = container.privateCloudDatabase
        _ = try await pdb.modifyRecordZones(saving: [cardZone], deleting: []
        )
        let share = CKShare(recordZoneID: cardZone.zoneID)
        share.publicPermission = .readOnly
        let result = try await pdb.save(share)
        return result as! CKShare
    }
    
    func prepCardForExport() -> Data {
        let image = SnapShotCardForPrint(chosenObject: $chosenObject, collageImage: $collageImage, noteField: $noteField, text1: $text1, text2: $text2, text2URL: $text2URL, text3: $text3, text4: $text4, printCardText: $printCardText).snapshot()
        let a4_width = 595.2 - 20
        let a4_height = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: a4_width, height: a4_height)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let data = renderer.pdfData(actions: {ctx in ctx.beginPage()
        image.draw(in: pageRect)
        })
        return data
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



//extension Card {
    
    //var asRecord: CKRecord {
    //    let record = CKRecord(
    //        recordType: CardRecordKeys.type,
    //        recordID: .init(zoneID: SharedZone.ID)
    //    )
        
        //record[Card.CardRecordKeys.card] = FinalizeCardView.eCardVertical.snapshot().pngData()
        //record[Card.CardRecordKeys.cardName] = noteField.cardName
        //record[Card.CardRecordKeys.collage] = collageImage.collageImage.pngData()
        //record[Card.CardRecordKeys.coverImage] = chosenObject.coverImage!
        //record[Card.CardRecordKeys.date] = Date.now
        //record[Card.CardRecordKeys.message] = noteField.noteText
        //record[Card.CardRecordKeys.occassion] = searchObject.searchText
        //record[Card.CardRecordKeys.recipient] = noteField.recipient
        //record[Card.CardRecordKeys.font] = noteField.font
        //record[Card.CardRecordKeys.an1] = text1
        //record[Card.CardRecordKeys.an2] = text2
        //record[Card.CardRecordKeys.an2URL] = text2URL.absoluteString
        //record[Card.CardRecordKeys.an3] = text3
        //record[Card.CardRecordKeys.an4] = text4

    
        //return record
   // }
    
   // init?(from record: CKRecord) {
    //    guard
    //        let card = record[CardRecordKeys.card] as? Data,
    //        let cardName = record[CardRecordKeys.cardName] as? String,
    //        //let collage = record[CardRecordKeys.collage] as Data,
    //        let date = record[CardRecordKeys.date] as? Date,
    //        let message = record[CardRecordKeys.message] as? String,
     //       let occassion = record[CardRecordKeys.occassion] as? String,
    //        let recipient = record[CardRecordKeys.recipient] as? String,
     //       let font = record[CardRecordKeys.font] as? String,
     //       let an1 = record[CardRecordKeys.an1] as? String,
    //        let an2 = record[CardRecordKeys.an2] as? String,
    //        let an2URL = record[CardRecordKeys.an2URL] as? String,
    //        let an3 = record[CardRecordKeys.an3] as? String,
    //        let an4 = record[CardRecordKeys.an4] as? String
            //let goal = Fasting.Goal(rawValue: goalRawValue)
            //let card = Card(context: CoreDataStack.shared.context)
    //    else { return nil }
        
        //self = .init(
            //card: card,
            //cardName: cardName,
            //collage: collage,
            //date: date,
            //message: message,
            //occassion: occassion,
            //recipient: recipient,
            //font: font,
            //an1: an1,
            //an2: an2,
            //an2URL: an2URL,
            //an3: an3,
            //an4: an4,
            //name: record.recordID.recordName
           // )
    //}
//}

//final class CloudKitService {
//    static let container = CKContainer(
//        identifier: "iCloud.GreetMe_2"
//    )
    
//    func save(_ card: Card) async throws {
//        _ = try await Self.container.privateCloudDatabase.modifyRecordZones(
 //           saving: [CKRecordZone(zoneName: Card.SharedZone.name)],
 //           deleting: []
 //       )
 //       _ = try await Self.container.privateCloudDatabase.modifyRecords(
  //          saving: [card.asRecord],
  //          deleting: []
  //      )
  //  }
//}



extension UIScreen{
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}
    
    struct ActivityView: UIViewControllerRepresentable {
       @Binding var activityItems: [Any]
       let applicationActivities: [UIActivity]?
       func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
          UIActivityViewController(activityItems: activityItems,
                                applicationActivities: applicationActivities)
       }
       func updateUIViewController(_ uiViewController: UIActivityViewController,
                                   context: UIViewControllerRepresentableContext<ActivityView>) {}
       }
    
// https://medium.com/swiftui-made-easy/activity-view-controller-in-swiftui-593fddadee79
// https://www.hackingwithswift.com/example-code/uikit/how-to-render-pdfs-using-uigraphicspdfrenderer
// https://stackoverflow.com/questions/1134289/cocoa-core-data-efficient-way-to-count-entities
// https://www.advancedswift.com/resize-uiimage-no-stretching-swift/
// https://www.hackingwithswift.com/articles/103/seven-useful-methods-from-cgrect
// https://stackoverflow.com/questions/57727107/how-to-get-the-iphones-screen-width-in-swiftui
// https://www.hackingwithswift.com/read/33/4/writing-to-icloud-with-cloudkit-ckrecord-and-ckasset
// https://swiftwithmajid.com/2022/03/29/zone-sharing-in-cloudkit/
// https://swiftwithmajid.com/2022/03/29/zone-sharing-in-cloudkit/
// https://www.techotopia.com/index.php/An_Introduction_to_CloudKit_Data_Storage_on_iOS_8#Record_Zones
