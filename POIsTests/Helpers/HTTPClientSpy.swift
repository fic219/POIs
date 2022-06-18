//
// Created by Mate Csengeri on 2022. 06. 18. 
	

import Foundation
import POIs

class HTTPClientSpy: HTTPClient {
    
    var messages = [(request: URLRequest, completion: (Result<(Data, HTTPURLResponse), Error>) -> Void)]()
    
    var request: URLRequest? {
        return messages.compactMap { $0.request }.first
    }
    
    var loadedURL: URL? {
        return loadedURLs.first
    }
    
    var loadedURLs: [URL] {
        messages.compactMap { $0.request.url }
    }
    
    func execute(_ urlRequest: URLRequest, completion: @escaping (Result<(Data, HTTPURLResponse), Swift.Error>) -> Void) {
        messages.append((urlRequest, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with result: (Data, HTTPURLResponse), at index: Int = 0) {
        messages[index].completion(.success(result))
    }
}
