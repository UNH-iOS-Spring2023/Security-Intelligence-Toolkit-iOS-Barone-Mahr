//
//  Util.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/28/23.
//

import Foundation
import CoreFoundation

struct Util {
    /// Performs a network TCP port scan on an IPv4 address or CIDR subnet range
    ///
    /// - Parameters:
    ///   - input: String containing an IPv4 address or CIDR
    ///
    /// - Returns: Results of the network TCP scan (which ports were found to be open)
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
    
    /// Converts a CIDR notation to an array of IPv4 addresses
    ///
    /// - Parameters:
    ///   - cidr: String containing a CIDR notation
    ///
    /// - Returns: An array of IPv4 addresses
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
    
    /// Converts an IPv4 Address in an unsigned 32-bit integer representation to a string in dot-decimal notation
    ///
    /// - Parameters:
    ///   - host: The numerical host address to convert
    ///
    /// - Returns: A string containing an IPv4 address in dot-decimal notation
    static func parseHost(_ host: UInt32) -> String {
        return String(
            format: "%d.%d.%d.%d",
            (host >> 24) & 0xff,
            (host >> 16) & 0xff,
            (host >> 8) & 0xff,
            host & 0xff)
    }
    
    /// Converts an IPv4 address in string format to an unsigned 32-bit integer representation
    ///
    /// - Parameters:
    ///  - ipAddress: String containing an IPv4 address in dot-decimal notation
    ///
    /// - Returns: An optional UInt32 representing the IPv4 address, or nil if the conversion failed
    static func parseIPAddress(_ ipAddress: String) -> UInt32? {
        var addr = in_addr()
        if ipAddress.withCString({inet_pton(AF_INET, $0, &addr)}) == 1 {
            return UInt32(bigEndian: addr.s_addr)
        }
        return nil
    }

    /// Applies a subnet mask to an IPv4 address represented as an unsigned 32-bit integer
    ///
    /// - Parameters:
    ///  - address: An unsigned 32-bit integer representing an IPv4 address
    ///  - mask: An unsigned 8-bit integer representing the subnet mask
    ///
    /// - Returns: An unsigned 32-bit integer representing the network address obtained by applying the subnet mask to the given address
    static func applyMask(_ address: UInt32, _ mask: UInt8) -> UInt32 {
        return address & ~(UInt32.max >> mask)
    }
    
    /// Determines whether a string containing a CIDR notation is valid
    ///
    /// - Parameters:
    ///  - cidr: String containing a CIDR notation
    ///
    /// - Returns: A boolean indicating whether the CIDR notation is valid, by checking whether the IP address and subnet mask are valid, and whether the subnet mask is within the range of 0-32.
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
    
    /// Determines whether a string containing an IPv4 address in dot-decimal notation is valid
    ///
    /// - Parameters:
    ///  - ip: String containing an IPv4 address in dot-decimal notation
    ///
    /// - Returns: A boolean indicating whether the IPv4 address is valid, by checking whether it has four parts separated by dots, and whether each part is within the range of 0-255.
    static func isValidIPv4(_ ip: String) -> Bool {
        let parts = ip.split(separator: ".")
        guard parts.count == 4 else { return false }
        for part in parts {
            guard let value = Int(part), value >= 0 && value <= 255 else { return false }
        }
        
        return true
    }
    
    /// Performs a TCP connection check to a specified host and port
    ///
    /// - Parameters:
    ///  - host: String containing an IPv4 address in dot-decimal notation
    ///  - port: An unsigned 16-bit integer representing the TCP port number to connect to
    ///
    /// - Returns: A boolean indicating whether the TCP connection check succeeded, by attempting to create a socket and connect to the specified host and port with a timeout of 1 second. If the connection is successful, returns true, otherwise returns false.
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
    /// Returns the formatted string representation of a date object
    ///
    /// - Parameters:
    ///  - format: A string representing the desired format of the date, using the format syntax of the DateFormatter class
    ///
    /// - Returns: A string containing the formatted representation of the date object, based on the specified format string.
    func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
