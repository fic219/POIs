//
// Created by Mate Csengeri on 2022. 05. 07. 
	

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    public init() {}
    
    private enum Error: Swift.Error {
        case unexpectedResponseRepresentation
    }
    
    public func execute(_ urlRequest: URLRequest, completion: @escaping (Result<(Data, HTTPURLResponse), Swift.Error>) -> Void) {
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((data, response)))
            } else {
                completion(.failure(Error.unexpectedResponseRepresentation))
            }
        }.resume()
    }
    
}
