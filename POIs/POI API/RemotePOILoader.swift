//
// Created by Mate Csengeri on 2022. 04. 22. 
	

import Foundation

public final class RemotePOILoader: POILoader {
    
    public enum Error: Swift.Error {
        case connectionError
        case invalidData
    }
    
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (POILoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success(response):
                guard response.statusCode == 200 else {
                    completion(.failure(Error.invalidData))
                    return
                }
                completion(.success([]))
            case .failure:
                completion(.failure(Error.invalidData))
            }
            
        }
    }
    
}
