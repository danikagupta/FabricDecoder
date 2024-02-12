//
//  FabricInfo.swift
//  FabricDecoder
//
//  Created by Danika Gupta on 2/11/24.
//

import Foundation

struct PatternFabric {
    let p:[String]
    let fabric: String
    let desc: String
}

class FabricInfo {
    static var fabrics = [
        PatternFabric(p: ["cross", "circle", "circle", "circle", "circle", "circle", "cross", "circle", "circle"], fabric: "SuperSilk", desc: "Desc of super silk"),
        PatternFabric(p: ["cross", "cross", "cross", "circle", "circle", "cross", "circle", "cross", "circle"], fabric: "Cotton Twill", desc: "Desc of Cotton Twill"),
        PatternFabric(p: ["cross", "cross", "circle", "circle", "circle", "cross", "cross", "circle", "circle"], fabric: "Poly Linen", desc: "Linen")
    ]
    
    static func getMatchingFabric(p:[String]) -> PatternFabric? {
        for f in fabrics {
            let p1 = f.p
            var match = true;
            for i in 0..<p.count {
                if(p1[i] != p[i]) {
                    match = false;
                }
            }
            if(match) {
                return f
            }
        }
        print("Could not match the fabric for pattern \(p).")
        return nil
    }
    
    static var cameraSource = false
}
