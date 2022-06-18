//
// Created by Mate Csengeri on 2022. 06. 18. 
	

import Foundation
import POIs

class HTTPClientSpy: HTTPClient {
    
    var messages = [(url: URL, completion: (Result<(Data, HTTPURLResponse), Error>) -> Void)]()
    
    var loadedURL: URL? {
        return loadedURLs.first
    }
    
    var loadedURLs: [URL] {
        messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with result: (Data, HTTPURLResponse), at index: Int = 0) {
        messages[index].completion(.success(result))
    }
}
