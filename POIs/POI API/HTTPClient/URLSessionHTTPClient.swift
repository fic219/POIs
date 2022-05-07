//
// Created by Mate Csengeri on 2022. 05. 07. 
	

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    public init() {}
    
    public func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            
        }.resume()
    }
    
}
