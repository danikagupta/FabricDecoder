//
//  FabricInfo.swift
//  FabricDecoder
//
//  Created by Danika Gupta on 2/11/24.
//

import Foundation

import Foundation

// Structure to match the JSON format
struct DetectionData: Codable {
    let time: Double
    let image: ImageData
    let predictions: [Prediction]
    
    struct ImageData: Codable {
        let width: Int
        let height: Int
    }
    
    struct Prediction: Codable {
        let x: Double
        let y: Double
        let width: Double
        let height: Double
        let confidence: Double
        let `class`: String
        let classId: Int
        let detectionId: String
        
        enum CodingKeys: String, CodingKey {
            case x, y, width, height, confidence, `class`, classId = "class_id", detectionId = "detection_id"
        }
    }
    
    func getList() -> [(CGRect,String)] {
        var li : [(CGRect,String)] = []
        for p in predictions {
            let re = CGRect(x: p.x-(p.width/2), y: p.y-(p.height/2), width: p.width, height: p.height)
            let cl = p.`class`
            li.append((re,cl))
        }
        print("DetectionData.getList() returns list \(li)")
        return li
    }
}

struct PatternFabric {
    let p:[String]
    let fabric: String
    let desc: String
}

class FabricInfo {
    static var fabrics = [
        PatternFabric(p: ["cross","circle","cross", "circle"], fabric: "Sorry!! Fabric not found", desc: "Email: dan@gprof.com"),
        PatternFabric(p: ["cross", "cross", "cross", "circle", "circle", "cross", "circle", "cross", "circle"], fabric: "Cotton Twill (100% Cotton)", desc: "Mfr: The Textile District"),
        PatternFabric(p: ["cross", "cross", "circle", "circle", "circle", "cross", "cross", "circle", "circle"], fabric: "Polyester Linen (100% Polyester)", desc: "Mfr: The Textile District"),
        PatternFabric(p: ["cross", "circle", "circle", "circle", "circle", "cross", "cross", "circle", "circle"], fabric: "Polyester Linen (100% Polyester)", desc: "Mfr: The Textile District"),
        PatternFabric(p: ["cross", "circle", "cross", "circle", "circle", "circle", "cross", "cross", "circle", "circle"], fabric: "Polyester Linen (100% Polyester)", desc: "Mfr: The Textile District"),
        PatternFabric(p: ["cross", "cross", "circle", "cross", "circle", "circle", "cross", "circle", "circle"], fabric: "Polyester Linen (100% Polyester)", desc: "Mfr: The Textile District"),
    ]
    
    static func damerauLevenshteinDistance<T: Equatable>(array1: [T], array2: [T]) -> Int {
        let m = array1.count
        let n = array2.count
        
        var matrix = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 1...m {
            matrix[i][0] = i
        }
        for j in 1...n {
            matrix[0][j] = j
        }
        
        for i in 1...m {
            for j in 1...n {
                let cost = array1[i - 1] == array2[j - 1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i - 1][j] + 1,     // Deletion
                    matrix[i][j - 1] + 1,     // Insertion
                    matrix[i - 1][j - 1] + cost  // Substitution
                )
                
                if i > 1, j > 1, array1[i - 1] == array2[j - 2], array1[i - 2] == array2[j - 1] {
                    matrix[i][j] = min(matrix[i][j], matrix[i - 2][j - 2] + cost)  // Transposition
                }
            }
        }
        
        return matrix[m][n]
    }
    
    static func bestMatch(p:[String]) -> Int {
        if(p.count<5) {
            return -1
        }
        
        var bestIndex = 0;
        var bestDistance = damerauLevenshteinDistance(array1: p,array2: fabrics[0].p)
        for i in 1..<fabrics.count {
            let newDistance = damerauLevenshteinDistance(array1: p,array2: fabrics[i].p)
            if(newDistance < bestDistance) {
                bestIndex=i
                bestDistance = newDistance
            }
        }
        if bestDistance<5 {
            return bestIndex
        } else {
            return -1
        }
        
    }

    // Example usage
    //let array1 = [1, 2, 3, 4, 5]
    //let array2 = [1, 3, 2, 4, 6]
    //let distance = damerauLevenshteinDistance(array1: array1, array2: array2)
    //print("Damerau-Levenshtein distance: \(distance)")

    
    static func getMatchingFabric(p:[String]) -> PatternFabric? {
        for f in fabrics {
            let p1 = f.p
            var match = true;
            for i in 0..<p.count {
                if(i < p1.count && p1[i] != p[i]) {
                    match = false;
                }
            }
            if(match) {
                return f
            }
        }
        print("Could not match the fabric for pattern \(p).")
        LOG_COUNT += 1
        LOGS.append("\(LOG_COUNT). \(p) \n\n")
        let b = bestMatch(p: p)
        if(b>=0) {
            return fabrics[b]
        }
        return nil
    }
    
    static var cameraSource = false
    static var useLocalModel = false
    static var RF_API_KEY = "wgeXdok7vRnPLTcXeMDD"
    static var RF_MODEL_ID = "jshs-demo"
    static var LOGS = ""
    static var LOG_COUNT = 0
}
