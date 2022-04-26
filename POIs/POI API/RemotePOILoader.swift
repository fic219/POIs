//
// Created by Mate Csengeri on 2022. 04. 22. 
	

import Foundation

public final class RemotePOILoader: POILoader {
    
    private struct RemoteCoordinates: Decodable {
        let longitude: Double
        let latitude: Double
    }
    
    private struct RemotePOI: Decodable {
        let name: String
        let description: String?
        let city: String
        let image: String
        let coordinates: RemoteCoordinates
        
        var poi: POI {
            return POI(name: name,
                       description: description,
                       city: city,
                       imageURL: image,
                       longitude: coordinates.longitude,
                       latitude: coordinates.latitude)
        }
    }
    
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
            case let .success((data, response)):
                guard response.statusCode == 200,
                      let pois = try? JSONDecoder().decode([RemotePOI].self, from: data) else {
                    completion(.failure(Error.invalidData))
                    return
                }
                completion(.success(pois.map {$0.poi}))
            case .failure:
                completion(.failure(Error.connectionError))
            }
        }
    }
    
}
