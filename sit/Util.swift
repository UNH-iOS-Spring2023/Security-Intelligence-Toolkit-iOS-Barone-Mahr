//
//  Util.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/28/23.
//

import Foundation
import CoreFoundation

struct Util {
    static func doTCPScan(_ input: String) -> [String: Any] {
        var data: [String: Any] = [:]
        var ips: [String] = []
        
        if(isValidIPv4(input)) {
            ips.append(input)
        } else if(isValidCIDR(input)) {
            ips = parseCIDR(input)
        }
        
        data["attemptedScan"] = input
        data["createdTime"] = Date()
        data["localScan"] = false
        data["networkScan"] = true
        data["results"] = []
        data["scanType"] = "" //Leave empty for network scans, only used for shodan
        data["uid"] = "" //Update this before writing to firestore
        
        let ports: [UInt16] = [
            20,21,22,23,24,25,26,30,32,33,37,42,43,49,53,70,79,80,443,3389,8080,8443
        ] //Common TCP ports
        
        var results: [[String: Any]] = []
        
        for ip in ips {
            var dict: [String: Any] = [:]
            var result: [NSNumber] = []
            for port in ports {
                if(doTCPCheck(host: ip, port: port)) {
                    result.append(NSNumber(value: port))
                }
            }
            dict[ip] = result
            results.append(dict)
        }
        data["results"] = results
        
        return data
    }
    
    static func parseCIDR(_ cidr: String) -> [String] {
        var result: [String] = []
        if let range = cidr.range(of: "/") {
            let addressString = cidr[cidr.startIndex..<range.lowerBound]
            let maskString = cidr[range.upperBound...]
            if(String(maskString) == "32") {
                return [String(addressString)];
            }
            if let address = parseIPAddress(String(addressString)), let mask = UInt8(maskString) {
                let networkAddress = applyMask(address, mask)
                let hostCount = UInt32(pow(2.0, Double(32 - mask))) - 2 //TODO fix: Fatal error if > UInt32.max
                for i in 0..<hostCount {
                    let host = UInt32(bigEndian: address.bigEndian) + i + 1
                    let ipAddress = parseHost(host.littleEndian)
                    result.append(ipAddress)
                }
            }
        }
        return result
    }
    
    static func parseHost(_ host: UInt32) -> String {
        return String(
            format: "%d.%d.%d.%d",
            (host >> 24) & 0xff,
            (host >> 16) & 0xff,
            (host >> 8) & 0xff,
            host & 0xff)
    }
    
    static func parseIPAddress(_ ipAddress: String) -> UInt32? {
        var addr = in_addr()
        if ipAddress.withCString({inet_pton(AF_INET, $0, &addr)}) == 1 {
            return UInt32(bigEndian: addr.s_addr)
        }
        return nil
    }

    static func applyMask(_ address: UInt32, _ mask: UInt8) -> UInt32 {
        return address & ~(UInt32.max >> mask)
    }
    
    static func isValidCIDR(_ cidr: String) -> Bool {
        let components = cidr.split(separator: "/")
        let ip = String(components[0])
        
        guard isValidIPv4(ip) else { return false }
        
        if components.count == 2 {
            guard let subnetMask = Int(components[1]), subnetMask >= 0 && subnetMask <= 32 else { return false }
        } else {
            return false
        }
        
        return true
    }
    
    static func isValidIPv4(_ ip: String) -> Bool {
        let parts = ip.split(separator: ".")
        guard parts.count == 4 else { return false }
        for part in parts {
            guard let value = Int(part), value >= 0 && value <= 255 else { return false }
        }
        
        return true
    }
    
    static func doTCPCheck(host: String, port: UInt16) -> Bool {
        let socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 0, nil, nil)
        var address = sockaddr_in()
        address.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        address.sin_family = sa_family_t(AF_INET)
        address.sin_port = CFSwapInt16HostToBig(UInt16(port))
        address.sin_addr.s_addr = inet_addr(host)

        let cfData = withUnsafePointer(to: &address) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<sockaddr_in>.size) {
                CFDataCreate(kCFAllocatorDefault, $0, MemoryLayout<sockaddr_in>.size)
            }
        }
        let timeoutVal = timeval(tv_sec: 1, tv_usec: 0)
        let timeout = CFTimeInterval(timeoutVal.tv_sec) + CFTimeInterval(timeoutVal.tv_usec) / 1_000_000.0
        let result: CFSocketError = CFSocketConnectToAddress(socket, cfData, timeout)
        
        switch result {
            case .success:
                return true;
            case .error:
                return false;
            case .timeout:
                return false;
            @unknown default:
                return false;
        }
    }
    
}

// https://stackoverflow.com/questions/35700281/date-format-in-swift
extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
