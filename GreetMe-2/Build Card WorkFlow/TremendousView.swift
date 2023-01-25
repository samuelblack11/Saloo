//
//  TremendousVIew.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/18/23.
//

import Foundation
import SwiftUI
import CoreData
import CloudKit
import StoreKit


struct TremendousView {
    @State private var productsForDisplay: [RewardKeyAttributes] = []
    
    var body: some View {
        List {
        Text("Hello")
        ForEach(productsForDisplay) { product in
            Text(product.rewardName)
        }
    }
        .onAppear {
            getProducts(searchTerm: "Amazon")
        }
    }
}


extension TremendousView {
    
    func getProducts(searchTerm: String) {
        TremendousAPI.browseProducts(searchTerm: "Amazon", completionHandler: { (response, error) in
        if response != nil {
            DispatchQueue.main.async {
                for product in response! {
                    products.append(RewardKeyAttributes(id: product.id, rewardName: product.name, rewardImageURL: product.images.src, minValue: product.skus.SKU.minVal, maxValue: product.skus.SKU.maxVal))
                }
            }
        }
        if response != nil {print("No Response!")}
        else {debugPrint(error?.localizedDescription)}
        })
    }
}

