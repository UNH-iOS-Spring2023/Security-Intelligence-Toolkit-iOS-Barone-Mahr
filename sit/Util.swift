//
//  Util.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 2/28/23.
//

import Foundation
import CoreFoundation
import FirebaseFirestore

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
    
    
    /// Retrieves the Broadcast Address and Netmask address from the device
    /// - Returns: A tuple containing the broadcast address and netmask for the WIFI Adapter on the given iOS device
    static func getWifiBroadcastAndNetmask() -> (gateway: String?, netmask: String?) {
        // Get the list of all network interfaces on the device
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return (nil, nil) }
        defer { freeifaddrs(ifaddr) }
        
        // Loop through the list of interfaces
        var broadcastAddress: String?
        var netmaskAddress: String?
        var ptr = ifaddr // pointer to keep track of which interface you are on
        while ptr != nil {
            let interface = ptr!.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) {
                // Found an interface with an IPV4 address value
                let ifaName = String(cString: interface.ifa_name)
                if ifaName == "en0" {
                    // the name of the interface maps to the WIFI adapter
                    var addrBuf = [CChar](repeating: 0, count: Int(NI_MAXHOST)) //create a buffer to hold the value of the broadcast address
                    if getnameinfo(interface.ifa_dstaddr, socklen_t(interface.ifa_dstaddr.pointee.sa_len), &addrBuf, socklen_t(addrBuf.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                        // Convert the broadcast address buffer to a string
                        let broadcastAddrStr = String(cString: addrBuf)
                        broadcastAddress = broadcastAddrStr
                    }
                    // Get the netmask address
                    var netmaskAddrBuf = [CChar](repeating: 0, count: Int(NI_MAXHOST)) //buffer to hold the netmask address
                    if getnameinfo(interface.ifa_netmask, socklen_t(interface.ifa_netmask.pointee.sa_len), &netmaskAddrBuf, socklen_t(netmaskAddrBuf.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
                        // Convert the netmask address buffer to a string
                        let netmaskAddrStr = String(cString: netmaskAddrBuf)
                        netmaskAddress = netmaskAddrStr
                    }
                    break
                }
            }
            ptr = ptr!.pointee.ifa_next // move on to the next network interface
        }
        
        return (broadcastAddress, netmaskAddress)
    }
    
    
    ///  Calculates and returns the CIDR notation for the subnet of the iOS device's IP Address.
    ///
    /// - Parameters:
    ///     - broadcastAddress : String containing the broadcast address
    ///     - netmask : String containing the netmask address
    ///
    /// - Returns: The string containing the complete CIDR notation for the subnet of the iOS device IP Address.
    ///
    static func getCIDRNotation(broadcastAddress: String, netmask: String) -> String? {
        
        // Convert the broadcast address and netmask to binary format
        guard let broadcastBinary = ipAddressToBinary(ipAddress: broadcastAddress),
              let netmaskBinary = ipAddressToBinary(ipAddress: netmask) else {
            return nil
        }

        // Convert the binary strings to integers
        guard let broadcastInt = Int(broadcastBinary, radix: 2),
              let netmaskInt = Int(netmaskBinary, radix: 2) else {
            return nil
        }
 
        // Calculate the bitwise AND of the broadcast address and netmask - this will produce the lowest IP address value of the IP Address subnet range.
        let bitwiseResult = broadcastInt & netmaskInt
    
        
        // Convert the bitwise result back to binary string format to be used for later calculations
        let baseIPstring = String(bitwiseResult, radix: 2)
        
        // Convert the lowest ip address from binary format to IPv4 format for later usage
        guard let baseIPForCidrString = binaryToIPv4(binary: baseIPstring) else { return "" }
        
        // pass the lowest ip address, the broadcast (top adddress) and the subnet mask to calculate the cidr notation of the subnet
        guard let cidrValue = getCIDRValue( subnetMask: netmaskBinary) else { return "" }
        
        // concatenate the lowest ipaddress string and the cidr notation value for the subnet
        let completeCIDR = baseIPForCidrString + "/" + cidrValue
        
        return completeCIDR
    }

    // Helper function to convert an IPv4 address to binary format
    /// - Parameters:
    ///    - ipAddress: String containing the ip address you wish to convert to binary
    ///
    /// - Returns: The binary string representation of the inputted ipaddress
    ///
    static func ipAddressToBinary(ipAddress: String) -> String? {
        let components = ipAddress.components(separatedBy: ".") //separate out the values by removing the "."
        guard components.count == 4 else { //check to make sure the format is correct
            return nil
        }
        
        var binaryString = ""
        for component in components {
            guard let octet = Int(component), octet >= 0 && octet <= 255 else {
                return nil
            }
            let binaryOctet = String(octet, radix: 2).padLeft(toLength: 8, withPad: "0")
            binaryString += binaryOctet
        }
        
        return binaryString
    }
    
    
    // Helper function to convert an ip address in its binary format to its normal IPv4 address "xxx.xxx.xxx.xxx"
    /// - Parameters:
    ///    - binary: String containing the binary representation of the ip address
    ///
    /// - Returns: String containing the ip address converted from binary format
    ///
    static func binaryToIPv4(binary: String) -> String? {
        // Ensure that the binary string is a valid IPv4 address in binary format and of length 32
        guard binary.count == 32,
              let decimal = UInt32(binary, radix: 2)
        else {
            return nil
        }
        
        // Extract the octets from the decimal value (ie. break the ip address into its 4 components)
        let octet1 = decimal >> 24 & 0xff
        let octet2 = decimal >> 16 & 0xff
        let octet3 = decimal >> 8 & 0xff
        let octet4 = decimal & 0xff
        
        // Return the formatted IPv4 address string
        return "\(octet1).\(octet2).\(octet3).\(octet4)"
    }
    
    // Helper function to get the subnet cidr notation value
    /// - Parameters:
    ///    - baseIP: string containing the subnetMask value in order to calculate the subnet CIDR notation
    ///
    /// - Returns: String containing the subnet value in CIDR notation
    static func getCIDRValue(subnetMask: String) -> String? {
        // Convert the binary string to an integer
        guard let mask = UInt32(subnetMask, radix: 2) else {
            return nil
        }
        
        // Calculate the number of host bits
        let numHostBits = 32 - mask.nonzeroBitCount
        
        // Calculate the cidr notation number by subtracting number of host bits from 32
        let cidrNotation = "\(32 - numHostBits)"
        
        return cidrNotation
    }

    static func doShodanQuery(apiKey: String, scanType: ShodanScanType, uid: String, input: String) {
        let api = ShodanAPI(apiKey: apiKey)
        
        let dispatchGroup = DispatchGroup()
        var apiConnectionSuccessful = false
        var returnData: Any?
        var errorData: String?
        
        dispatchGroup.enter()
        api.testAPIConnection { result in
            switch result {
            case .success(let isConnected):
                if isConnected {
                    apiConnectionSuccessful = true
                } else {
                    errorData = "ERROR: API connection failed, verify API Key!"
                }
            case .failure(let error):
                errorData = "ERROR: \(error.localizedDescription)"
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        
        if(apiConnectionSuccessful) {
            switch scanType {
            case .SHODAN_PUBLIC_IP:
                api.getPublicIPAddress { result in
                    switch result {
                    case .success(let publicIP):
                        returnData = publicIP
                    case .failure(let error):
                        errorData = "ERROR: \(error.localizedDescription)"
                        apiConnectionSuccessful = false
                    }
                    dispatchGroup.leave()
                }
            case .SHODAN_SEARCH_IP:
                api.getHostInformation(ipAddress: input) { result in
                    switch result {
                    case .success(let hostInfo):
                        returnData = hostInfo
                    case .failure(let error):
                        errorData = "ERROR: \(error.localizedDescription)"
                        apiConnectionSuccessful = false
                    }
                    dispatchGroup.leave()
                }
            case .SHODAN_FILTER_SEARCH:
                api.search(query: input) { result in
                    switch result {
                    case .success(let searchResults):
                        returnData = searchResults
                    case .failure(let error):
                        errorData = "ERROR: \(error.localizedDescription)"
                        apiConnectionSuccessful = false
                    }
                    dispatchGroup.leave()
                }
            }
        } else {
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            if apiConnectionSuccessful, let returnData = returnData {
                //print("Shodan Return Data: \(returnData)")
                saveShodanQuery(queryData: returnData, scanType: scanType, uid: uid, input: input)
            } else {
                print(errorData!)
            }
        }
    }
    
    static func saveShodanQuery(queryData: Any, scanType: ShodanScanType, uid: String, input: String) {
        var data: [String: Any] = [:]
        
        data["attemptedScan"] = ""
        data["createdTime"] = Date()
        data["localScan"] = false
        data["networkScan"] = false
        data["results"] = []
        var results: [[String: Any]] = []
        var dict: [String: Any] = [:]
        
        switch scanType {
        case .SHODAN_PUBLIC_IP:
            data["scanType"] = "SHODAN_PUBLIC_IP"
            data["attemptedScan"] = (queryData as? String)?.dropFirst().dropLast() // Shodan ouput puts IP in "s, this removes them.
            var result: [String] = []
            dict["SHODAN_PUBLIC_SCAN"] = result
            results.append(dict)
        case .SHODAN_SEARCH_IP:
            data["scanType"] = "SHODAN_SEARCH_IP"
            
            let queryDict = queryData as! [String: Any]
            
            var result: [NSNumber] = []
            result = queryDict["ports"] as! [NSNumber]
            dict[input] = result
            results.append(dict)
            
            data["attemptedScan"] = "\(queryDict["org"] ?? "Org Unknown"), \(queryDict["city"] ?? "City Unknown"), \(queryDict["region_code"] ?? "Region Unknown"), \(queryDict["country_code"] ?? "Country Unknown")"
            
            
        case .SHODAN_FILTER_SEARCH:
            data["scanType"] = "SHODAN_FILTER_SEARCH"
            data["attemptedScan"] = input
            
            let queryDict = queryData as! [String: Any]
            let matches = queryDict["matches"] as! [[String: Any]]
            
            var info = ""
            
            matches.forEach { match in
                info.append("Title: \(match["title"] ?? "")")
                if let query = match["query"] as? String, !query.isEmpty {
                    info.append("\nQuery Found: \(String(describing: match["query"]))")
                }
                if let description = match["description"] as? String, !description.isEmpty {
                    info.append("\nDescription: \(String(describing: match["description"]))\n\n")
                }
            }
            
            var result: [String] = []
            dict[info] = result
            results.append(dict)
        }
        
        data["uid"] = uid
        data["results"] = results
        
        let db = Firestore.firestore()
        db.collection("scans").addDocument(data: data) { error in
            if let error = error {
                
            } else {
                
            }
        }
    }
}

enum ShodanScanType {
    case SHODAN_PUBLIC_IP
    case SHODAN_FILTER_SEARCH
    case SHODAN_SEARCH_IP
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

// Helper function to pad a binary string to a specified length with leading zeroes
/// - Parameters:
///    - toLength: string value that sets the end desrired length
///    - withPad: string containing the binary value that needs to be padded for proper handling
/// - Returns: the binary string with any padding needed to make it the proper length for ip address handling
extension String {
    func padLeft(toLength length: Int, withPad pad: String) -> String {
        let padCount = length - self.count
        guard padCount > 0 else { return self }
        return String(repeating: pad, count: padCount) + self
    }
}
