
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

        let expectedError = RemotePOILoader.Error.connectionError as NSError
        expect(sut: sut, toCompleteWithResult: .failure(expectedError) , when: {
            let clientError = NSError(domain: "RemotePoiLoader.test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_receivingNon200ClientReponse_returnError() {
        let (sut, client) = makeSUT()
        let expectedError = RemotePOILoader.Error.invalidData as NSError
        
        let statusCodes = [199, 201, 300, 401, 500]
        statusCodes.enumerated().forEach { index, code in
            
            expect(sut: sut, toCompleteWithResult: .failure(expectedError), when: {
                client.complete(with: (anyData, httpResponse(with: code)), at: index)
            })
        }
    }
    
    func test_load_receivingEmptyListDeliversEmptyList() {
        let (sut, client) = makeSUT()
        
        expect(sut: sut, toCompleteWithResult: .success([]), when: {
            client.complete(with: (makeJSON([]), successResponse))
        })
       
    }
    
    func test_load_receiveErrorOnInvalidData() {
        let (sut, client) = makeSUT()
        expect(sut: sut, toCompleteWithResult: .failure(RemotePOILoader.Error.invalidData), when: {
            client.complete(with: (anyData, successResponse))
        })
    }
    
    func test_load_deliversPOIListOnClientDeliversList() {
        let (sut, client) = makeSUT()
        
        let poiItem1 = makePOIItem(name: "Budapest office",
                              description: "a desc",
                              city: "Budapest",
                              address: "anyAddress",
                              imageURL: "http://anyImage.jpg",
                              longitude: 47.529783,
                              latitude: 19.034413)
        
        let poiItem2 = makePOIItem(name: "Amsterdam office",
                              description: "a desc",
                              city: "Amsterdam",
                              address: "other Address",
                              imageURL: "http://otherImage.jpg",
                              longitude: 47.529783,
                              latitude: 19.034413)
        
        expect(sut: sut, toCompleteWithResult: .success([poiItem1.model, poiItem2.model]), when: {
            client.complete(with: (makeJSON([poiItem1.json, poiItem2.json]), successResponse))
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://anyURL")!) -> (sut: RemotePOILoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemotePOILoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(sut: RemotePOILoader,
                        toCompleteWithResult expectedResult: POILoader.Result,
                                when action: () -> Void,
                                file: StaticString = #filePath,
                                line: UInt = #line) {
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedPOIs), .success(expectedPOIs)):
                XCTAssertEqual(receivedPOIs, expectedPOIs, "Received: \(receivedPOIs), expected: \(expectedPOIs)")
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError as NSError, expectedError as NSError, "Received: \(receivedError), expected: \(expectedError)")
            default:
                XCTFail("Result should be equals. Expected: \(expectedResult), received: \(receivedResult)")
            }
        }
        
        action()
    }
    
    private func makePOIItem(name: String,
                             description: String? = nil,
                             city: String,
                             address: String,
                             imageURL: String,
                             longitude: Double,
                             latitude: Double) -> (model: POI, json: [String: Any]) {
        let poiItem = POI(name: name,
                          description: description,
                          city: city,
                          address: address,
                          imageURL: imageURL,
                          longitude: longitude,
                          latitude: latitude)
        let json: [String : Any] = ["name": name,
                                    "city": city,
                                    "address": address,
                                    "image": imageURL,
                                    "description": description,
                                    "coordinates": ["latitude": latitude,
                                                    "longitude": longitude]].compactMapValues { $0 }
        return (poiItem, json)
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
