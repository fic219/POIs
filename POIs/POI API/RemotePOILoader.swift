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
        let address: String
        let city: String
        let image: URL
        let coordinates: RemoteCoordinates
        
        private enum CodingKeys: String, CodingKey {
            case name, description, address, city, image, coordinates
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            description = try? container.decode(String.self, forKey: .description)
            address = try container.decode(String.self, forKey: .address)
            city = try container.decode(String.self, forKey: .city)
            let imageURLStr = try container.decode(String.self, forKey: .image)
            guard let url = imageURLStr.percentEncodedURL else {
                throw DecodingError.dataCorruptedError(forKey: .image, in: container, debugDescription: "Malformed image URL")
            }
            image = url
            coordinates = try container.decode(RemoteCoordinates.self, forKey: .coordinates)
        }
        
        var poi: POI {
            return POI(name: name,
                       description: description,
                       city: city,
                       address: address,
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
    
    private var request: URLRequest {
        var retValue = URLRequest(url: url)
        retValue.httpMethod = "GET"
        return retValue
    }
    
    public func load(completion: @escaping (POILoader.Result) -> Void) {
        client.execute(request) { result in
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
