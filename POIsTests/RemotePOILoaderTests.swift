
// Created by Mate Csengeri on 2022. 04. 20.
	

import XCTest
import POIs

class RemotePOILoaderTests: XCTestCase {

    func test_init_doesNotLoadAnything() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.loadedURL)
    }
    
    func test_loadingTwice_loadsTwice() {
        let url = URL(string: "http://anyURL")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.loadedURLs, [url, url])
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://anyURL")!) -> (sut: RemotePOILoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemotePOILoader(url: url, client: client)
        return (sut, client)
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
