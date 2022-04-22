
// Created by Mate Csengeri on 2022. 04. 20.
	

import XCTest
import POIs

class RemotePOILoaderTests: XCTestCase {

    func test_init_doesNotLoadAnything() {
        
        let client = HTTPClientSpy()
        _ = RemotePOILoader(url: URL(string: "http://anyURL")!, client: client)
        
        
        XCTAssertNil(client.loadedURL)
    }
    
    func test_loadingTwice_loadsTwice() {
        let client = HTTPClientSpy()
        let url = URL(string: "http://anyURL")!
        let sut = RemotePOILoader(url: url, client: client)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.loadedURLs, [url, url])
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        var loadedURL: URL?
        var loadedURLs = [URL]()
        
        func get(from url: URL) {
            loadedURL = url
            loadedURLs.append(url)
        }
    }

}
