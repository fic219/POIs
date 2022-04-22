
// Created by Mate Csengeri on 2022. 04. 20.
	

import XCTest
import POIs

class RemotePOILoaderTests: XCTestCase {

    func test_init_doesNotLoadAnything() {
        
        let client = HTTPClientSpy()
        _ = RemotePOILoader(url: URL(string: "http://anyURL")!, client: client)
        
        
        XCTAssertNil(client.loadedURL)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var loadedURL: URL?
        
        func get(from url: URL) {
            loadedURL = url
        }
    }

}
