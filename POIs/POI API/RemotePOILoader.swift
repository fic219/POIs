//
// Created by Mate Csengeri on 2022. 04. 22. 
	

import Foundation

public final class RemotePOILoader: POILoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load(completion: @escaping (POILoader.Result) -> Void) {
        
    }
    
}
