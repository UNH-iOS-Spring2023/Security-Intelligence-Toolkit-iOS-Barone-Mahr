//
//  Util.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/28/23.
//

import Foundation
import CoreFoundation

struct Util {
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
