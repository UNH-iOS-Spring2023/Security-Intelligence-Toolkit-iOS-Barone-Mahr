//
//  ScanResult.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 3/19/23.
//

import Foundation
import Firebase

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
        let createdTime = data["createdTime"] as? Timestamp != nil ? data["createdTime"] as! Timestamp : Timestamp()
        let localScan = data["localScan"] as? Bool != nil ? data["localScan"] as! Bool : false
        let networkScan = data["networkScan"] as? Bool != nil ? data["networkScan"] as! Bool : false
        let results = data["results"] as? [Any] != nil ? data["results"] as! [Any] : []
        let scanType = data["scanType"] as? String != nil ? data["scanType"] as! String : ""
        let uid = data["uid"] as? String != nil ? data["uid"] as! String : ""
        
        self.id = id
        self.attemptedScan = attemptedScan
        self.createdTime = createdTime.dateValue()
        self.localScan = localScan
        self.networkScan = networkScan
        self.results = results
        self.scanType = scanType
        self.uid = uid
    }
    
    /// Returns an array containing network scan results, where the first element in each is an IP address and the second element is an array of strings representing open ports.
    ///
    /// - Returns: An array containing network scan results.
    func getNetworkScanResults() -> [(String, [String])] {
        var list: [(String, [String])] = []
        
        if(self.networkScan || (!self.networkScan && self.scanType == "SHODAN_SEARCH_IP")) {
            for result in self.results {
                guard let resultDict = result as? [String: [NSNumber]] else {
                    continue // Skip to the next iteration if the result dictionary is not in the expected format
                }
                for (ip, ports) in resultDict {
                    let stringPorts = ports.map { $0.stringValue } // Convert each port in the array to a string
                    list.append((ip, stringPorts))
                }
            }
        }
        
        return list
    }
    
    func getShodanFilterResults() -> [String] {
        var output = [String]()
        
        if(self.scanType == "SHODAN_FILTER_SEARCH") {
            let original = ((self.results as? [[String: Any]])?.first?.keys.first as? String)!
            let lines = original.components(separatedBy: "\n")
            
            for line in lines {
                if line.starts(with: "Title:") && output.count > 0 {
                    output.append("")
                }
                if let index = line.range(of: "Title:")?.lowerBound {
                    output.append(String(line[..<index]))
                    output.append(String(line[index...]))
                } else {
                    output.append(String(line))
                }
            }
        }
        
        return output
    }
}

