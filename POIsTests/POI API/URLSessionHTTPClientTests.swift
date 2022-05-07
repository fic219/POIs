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
    
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

}

private class URLProtocolStub: URLProtocol {
    private static var onRequestLoaded: ((URLRequest) -> Void)?
    
    static func observeRequest(_ observer: @escaping (URLRequest) -> Void) {
        self.onRequestLoaded = observer
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override func startLoading() {
        Self.onRequestLoaded?(request)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func stopLoading() {}
    
}
