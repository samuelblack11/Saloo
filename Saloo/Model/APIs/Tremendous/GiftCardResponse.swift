//
//  GiftCardResponse.swift
//  GreetMe-2
//
//  Created by Sam Black on 1/24/23.
//
import Foundation
import UIKit

struct RewardKeyAttributes: Decodable, Identifiable {
    let id: String
    let rewardName: String
    let rewardImageURL: String
    let minValue: Int
    let maxValue: Int
}

struct TremendousProducts: Decodable {
    let products: [Product]
}

struct Product: Decodable {
    let id: String
    let name: String
    let description: String
    let category: String
    let disclosure: String
    let skus: [SKUList]
    let currency_codes: String
    let countries: [Country]
    let images: [TremendousImage]
}


struct SKUList: Decodable {
    let skuVals: [Denominations]
}

struct Denominations: Decodable {
    let minVal: Int
    let maxVal: Int
}

struct Country: Decodable {
    let abbr: String
}

struct TremendousImage: Decodable {
    let src: String
    let type: String
}
