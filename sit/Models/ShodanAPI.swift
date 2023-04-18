//
//  Shodan.swift
//  Security Intelligence Toolkit
//
//  Created by Charles Barone on 4/2/23.
//

import Foundation

class ShodanAPI {
    let apiKey: String
    let baseURL = "https://api.shodan.io"
    
    required init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func get(path: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let urlString = baseURL + path + "key=" + apiKey
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { semaphore.signal() }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data {
                completion(.success(data))
            }
        }
        task.resume()
        semaphore.wait()
    }
    
    func testAPIConnection(completion: @escaping (Result<Bool, Error>) -> Void) {
        get(path: "/api-info?") { result in
            switch result {
            case .success(let data):
                if let _ = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(true))
                } else {
                    completion(.success(false))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getHostInformation(ipAddress: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        get(path: "/shodan/host/\(ipAddress)?") { result in
            switch result {
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getPublicIPAddress(completion: @escaping (Result<String, Error>) -> Void) {
        get(path: "/tools/myip?") { result in
            switch result {
            case .success(let data):
                if let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    completion(.success(ip))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse IP address"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func search(query: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode query"])))
            return
        }
        let path = "/shodan/query/search?query=\(encodedQuery)&"
        get(path: path) { result in
            switch result {
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


}
