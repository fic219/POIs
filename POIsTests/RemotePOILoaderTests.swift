
// Created by Mate Csengeri on 2022. 04. 20.
	

import XCTest
import POIs

class RemotePOILoaderTests: XCTestCase {

    func test_init_doesNotLoadAnything() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.loadedURL)
    }
    
    func test_loadingTwice_loadsTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.loadedURLs, [url, url])
        
    }
    
    func test_load_deliversErrorOnClientReturningError() {
        let (sut, client) = makeSUT()

        expectComplete(sut: sut, with: RemotePOILoader.Error.connectionError as NSError) {
            let clientError = NSError(domain: "RemotePoiLoader.test", code: 0)
            client.complete(with: clientError)
        }
    }
    
    func test_receivingNon200ClientReponse_returnError() {
        let (sut, client) = makeSUT()
            
        expectComplete(sut: sut, with: RemotePOILoader.Error.invalidData as NSError) {
            client.complete(with: httpResponse(with: 199))
        }
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://anyURL")!) -> (sut: RemotePOILoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemotePOILoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expectComplete(sut: RemotePOILoader,
                                with expectedError: NSError,
                                action: () -> Void,
                                file: StaticString = #filePath,
                                line: UInt = #line) {
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            guard case let .failure(error) = result else {
                XCTFail("Loading should failed", file: file, line: line)
                exp.fulfill()
                return
            }
            let receivedError = error as NSError
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private func httpResponse(with code: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(),
                               statusCode: code,
                               httpVersion: nil,
                               headerFields: nil)!
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var messages = [(url: URL, completion: (Result<HTTPURLResponse, Error>) -> Void)]()
        
        var loadedURL: URL? {
            return loadedURLs.first
        }
        
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (Result<HTTPURLResponse, Error>) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with response: HTTPURLResponse, at index: Int = 0) {
            messages[index].completion(.success(response))
        }
    }
    
    private func anyURL() -> URL {
        URL(string: "http://anyURL")!
    }

}
