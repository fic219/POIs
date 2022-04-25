
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

        expect(sut: sut, toCompleteWithError: RemotePOILoader.Error.connectionError as NSError, when: {
            let clientError = NSError(domain: "RemotePoiLoader.test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_receivingNon200ClientReponse_returnError() {
        let (sut, client) = makeSUT()
        
        let statusCodes = [199, 201, 300, 401, 500]
        statusCodes.enumerated().forEach { index, code in
            expect(sut: sut, toCompleteWithError: RemotePOILoader.Error.invalidData as NSError, when: {
                client.complete(with: (anyData, httpResponse(with: code)), at: index)
            })
        }
    }
    
    func test_load_receivingEmptyListDeliversEmptyList() {
        let (sut, client) = makeSUT()
        
        var receivedPOIs: [POI]?
        
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            guard case let .success(pois) = result else {
                XCTFail("Loading should succeed")
                exp.fulfill()
                return
            }
            receivedPOIs = pois
            XCTAssertEqual(receivedPOIs, [])
            exp.fulfill()
        }
        client.complete(with: (makeJSON([]), successResponse))
        wait(for: [exp], timeout: 1)
       
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://anyURL")!) -> (sut: RemotePOILoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemotePOILoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(sut: RemotePOILoader,
                                toCompleteWithError expectedError: NSError,
                                when action: () -> Void,
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
    
    private var successResponse: HTTPURLResponse {
        httpResponse(with: 200)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
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
    
    private func anyURL() -> URL {
        URL(string: "http://anyURL")!
    }
    
    private var anyData: Data {
        Data("data".utf8)
    }
    
    private func makeJSON(_ pois: [[String: Any]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: pois)
    }

}
