//
// Created by Mate Csengeri on 2022. 05. 07. 
	

import XCTest
import POIs

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_performGetRequestFromURL() {
        let sut = makeSut()
        let url = anyURL()
        
        URLProtocol.registerClass(URLProtocolStub.self)
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(url, request.url)
            XCTAssertEqual("GET", request.httpMethod)
        }
        
        sut.get(from: url) { _ in }
        
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    func test_getFromURL_returnErrorOnHTTPError() {
        URLProtocol.registerClass(URLProtocolStub.self)
        let sut = makeSut()
        let errorToPerformWith = anyNSError()
        URLProtocolStub.stub = URLProtocolStub.Stub(data: nil, response: nil, error: errorToPerformWith)
        
        let exp = expectation(description: "Wait for complete")
        sut.get(from: anyURL()) { result in
            if case let .failure(receivedError) = result {
                XCTAssertEqual((errorToPerformWith as NSError).code, (receivedError as NSError).code, "Expected to complete with \(errorToPerformWith), got \(receivedError)")
                XCTAssertEqual((errorToPerformWith as NSError).domain, (receivedError as NSError).domain, "Expected to complete with \(errorToPerformWith), got \(receivedError)")
            } else {
                XCTFail("Expected to fail, got: \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyNSError() -> Error {
        return NSError(domain: "test.error", code: 0)
    }
}

private class URLProtocolStub: URLProtocol {
    
    struct Stub {
        let data: Data?
        let response: HTTPURLResponse?
        let error: Error?
    }
    
    static var stub: Stub?
    private static var onRequestLoaded: ((URLRequest) -> Void)?
    
    static func observeRequest(_ observer: @escaping (URLRequest) -> Void) {
        self.onRequestLoaded = observer
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override func startLoading() {
        
        if let data = Self.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = Self.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = Self.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
        
        Self.onRequestLoaded?(request)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func stopLoading() {}
    
}
