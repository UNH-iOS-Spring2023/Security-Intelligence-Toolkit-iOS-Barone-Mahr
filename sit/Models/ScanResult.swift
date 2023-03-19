//
//  ScanResult.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 3/19/23.
//

import Foundation

class ScanResult: ObservableObject {
    let id: String
    
    @Published var attemptedScan: String
    @Published var createdTime: Date
    @Published var localScan: Bool
    @Published var networkScan: Bool
    @Published var results: [Any]
    @Published var scanType: String
    @Published var uid: String
    
    required init?(id: String, data: [String: Any]) {
        let attemptedScan = data["attemptedScan"] as? String != nil ? data["attemptedScan"] as! String : ""
        let createdTime = data["createdTime"] as? Date != nil ? data["createdTime"] as! Date : Date()
        let localScan = data["localScan"] as? Bool != nil ? data["localScan"] as! Bool : false
        let networkScan = data["networkScan"] as? Bool != nil ? data["networkScan"] as! Bool : false
        let results = data["results"] as? [Any] != nil ? data["results"] as! [Any] : []
        let scanType = data["scanType"] as? String != nil ? data["scanType"] as! String : ""
        let uid = data["uid"] as? String != nil ? data["uid"] as! String : ""
        
        self.id = id
        self.attemptedScan = attemptedScan
        self.createdTime = createdTime
        self.localScan = localScan
        self.networkScan = networkScan
        self.results = results
        self.scanType = scanType
        self.uid = uid
    }
}
