//
//  CleanMusicData.swift
//  Saloo
//
//  Created by Sam Black on 5/6/23.
//

import Foundation
import SwiftUI
import SystemConfiguration

class CleanMusicData {
    @EnvironmentObject var appDelegate: AppDelegate

    
    func compileMusicString(songOrAlbum: String, artist: String?, removeList: [String]) -> String {
        // musicString is songName followed by artistName
        var cleanString = String()
        if artist != nil {
            let songOrAlbumNameOnly = removeArtistsFromSongOrAlbum(songOrAlbum: songOrAlbum).0
            let artistsInArtistField = removeArtistsFromSongOrAlbum(songOrAlbum: artist!).0
            let artistsInSongOrAlbumName = removeArtistsFromSongOrAlbum(songOrAlbum: songOrAlbum).1
            cleanString = songOrAlbumNameOnly + " " + artistsInArtistField + " " + artistsInSongOrAlbumName
        }
        else {
            cleanString = removeArtistsFromSongOrAlbum(songOrAlbum: songOrAlbum).0
        }
        

        cleanString = cleanMusicString(input: cleanString, removeList: removeList)
        return cleanString
    }
    
    
    func cleanMusicString(input: String, removeList: [String]) -> String {

        var cleanString = removeAccents(from: input)
        cleanString = removeSubstrings(from: cleanString, removeList: removeList)
        cleanString = removeSpecialCharacters(from: cleanString)
        cleanString = convertMultipleSpacesToSingleSpace(cleanString)//.replacingOccurrences(of: " ", with: "%20")
        return cleanString
    }
    

    func isNetworkAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }

    
    
    //func removeArtistsFromSongOrAlbum(songOrAlbum: String, songArtist: String?) -> (String, String) {
    func removeArtistsFromSongOrAlbum(songOrAlbum: String) -> (String, String) {
        var songOrAlbumString = songOrAlbum.replacingOccurrences(of: "[", with: "(").replacingOccurrences(of: "]", with: ")")
        var artistsInSongOrAlbumName = String()
        

        let featStrings = ["(feat.", "[feat."]
        let endStrings = [")", "]"]

        for (index, featString) in featStrings.enumerated() {
            if songOrAlbum.lowercased().contains(featString) {
                let songComponents = songOrAlbum.lowercased().components(separatedBy: featString)
                songOrAlbumString = songComponents[0]
                artistsInSongOrAlbumName = songComponents[1].components(separatedBy: endStrings[index])[0]
                artistsInSongOrAlbumName = artistsInSongOrAlbumName.replacingOccurrences(of: "&", with: "")
                if songComponents[1].components(separatedBy: endStrings[index]).count > 1 {
                    let songOrAlbumStringPt2 = songComponents[1].components(separatedBy: endStrings[index])[1]
                    songOrAlbumString = songOrAlbumString + " " + songOrAlbumStringPt2
                }
                break
            }
        }
        //songOrAlbumString = (songOrAlbumString + " " + cleanSongArtistName + artistsInSongOrAlbumName)
        return (songOrAlbumString,artistsInSongOrAlbumName)
    }
    

    func convertMultipleSpacesToSingleSpace(_ input: String) -> String {
        let components = input.components(separatedBy: .whitespacesAndNewlines)
        let filtered = components.filter { !$0.isEmpty }
        return filtered.joined(separator: " ")
    }
    
    func removeSubstrings(from string: String, removeList: [String]) -> String {
        var result = string.replacingOccurrences(of: "&", with: "And", options: .regularExpression, range: nil)

        for pattern in removeList {
            let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let range = NSRange(location: 0, length: result.utf16.count)
            result = regex?.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "") ?? result
            result = result.capitalized
        }
        return result
    }

    

    
    func containsSameWords(_ str1: String, _ str2: String) -> Bool {
        // Split both strings into arrays of words
        let words1 = str1.split(separator: " ").map { String($0) }
        let words2 = str2.split(separator: " ").map { String($0) }
        // Check if both arrays contain the same set of words
        return Set(words1) == Set(words2)
    }
    
    func removeSpecialCharacters(from string: String) -> String {
        let pattern = "[^a-zA-Z0-9]"
        return string.replacingOccurrences(of: pattern, with: " ", options: .regularExpression, range: nil)
        let allowedCharacters = CharacterSet.whitespacesAndNewlines.union(CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"))
        let newString = string.components(separatedBy: allowedCharacters.inverted).joined(separator: "")
        //return newString
    }
    
    func removeAccents(from input: String) -> String {
        let accentMap: [Character: Character] = [
            "à": "a",
            "á": "a",
            "â": "a",
            "ã": "a",
            "ä": "a",
            "å": "a",
            //"æ": "ae",
            "ç": "c",
            "è": "e",
            "é": "e",
            "ê": "e",
            "ë": "e",
            "ì": "i",
            "í": "i",
            "î": "i",
            "ï": "i",
            "ð": "d",
            "ñ": "n",
            "ò": "o",
            "ó": "o",
            "ô": "o",
            "õ": "o",
            "ö": "o",
            "ø": "o",
            "ù": "u",
            "ú": "u",
            "û": "u",
            "ü": "u",
            "ý": "y",
            //"þ": "th",
            "ÿ": "y"
        ]
    
        var output = ""
        for character in input {
            if let unaccented = accentMap[character] {
                output.append(unaccented)
            } else {
                output.append(character)
            }
        }

        return output
    }
    
    func levenshteinDistance(s1: String, s2: String) -> Int {
        let s1Length = s1.count
        let s2Length = s2.count
        var distanceMatrix = [[Int]](repeating: [Int](repeating: 0, count: s2Length + 1), count: s1Length + 1)
        for i in 1...s1Length {distanceMatrix[i][0] = i}
        for j in 1...s2Length {distanceMatrix[0][j] = j}
        for i in 1...s1Length {
            for j in 1...s2Length {
                let cost = s1[s1.index(s1.startIndex, offsetBy: i - 1)] == s2[s2.index(s2.startIndex, offsetBy: j - 1)] ? 0 : 1
                distanceMatrix[i][j] = min(
                    distanceMatrix[i - 1][j] + 1,
                    distanceMatrix[i][j - 1] + 1,
                    distanceMatrix[i - 1][j - 1] + cost
                )
            }
        }
        return distanceMatrix[s1Length][s2Length]
    }
    
    func removeTextInParentheses(_ text: String) -> String {
        var result = ""
        var skip = false
        for char in text {
            if char == "(" || char == "[" {
                skip = true
            } else if char == ")" || char == "]" {
                skip = false
            } else if !skip {
                result.append(char)
            }
        }
        return result
    }
    
    func containsString(listOfSubStrings: [String], songName: String) -> Bool {
        let lowercasedInString = songName.lowercased()
        for item in listOfSubStrings {
            if lowercasedInString.range(of: item.lowercased(), options: .caseInsensitive) != nil {return true}
        }
        return false
    }
    
    func generateIncrementList(A: Int, B: Int) -> [Int] {
        var list: [Int] = []
        let increment = A
        var currentIncrement = A
        while currentIncrement <= B {
            list.append(currentIncrement)
            currentIncrement += increment
        }
        return list
    }
}
