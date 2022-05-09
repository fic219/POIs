//
// Created by Mate Csengeri on 2022. 05. 07. 
	

import XCTest
import POIs

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    func test_getFromURL_performGetRequestFromURL() {
        let sut = makeSut()
        let url = anyURL()
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(url, request.url)
            XCTAssertEqual("GET", request.httpMethod)
        }
        
        sut.get(from: url) { _ in }
    }
    
    func test_getFromURL_returnErrorOnHTTPError() {
        let sut = makeSut()
        let errorToPerformWith = anyNSError
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
    }
    
    func test_getFromURL_completeWithErrorOnInvalidCases() {
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: anyURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse, error: anyNSError))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyURLResponse, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    }
    
    func test_getFromURL_returnsREsponseAndDataOnValidLoad() {
        let expectedData = anyData
        let expectedResponse = anyHTTPURLResponse
        
        let result = resultFor(data: expectedData, response: expectedResponse, error: nil)
        
        XCTAssertEqual(expectedData, result.data)
        XCTAssertEqual(expectedResponse.url, result.response?.url)
        XCTAssertEqual(expectedResponse.statusCode, result.response?.statusCode)
    }
    
    func test_getFromURL_returnsEmptyDataOnURLSessionClientReturnsWithNilData() {
        
        let expectedResponse = anyHTTPURLResponse
        
        let result = resultFor(data: nil, response: expectedResponse, error: nil)
        
        XCTAssertEqual(Data(), result.data)
        XCTAssertEqual(expectedResponse.url, result.response?.url)
        XCTAssertEqual(expectedResponse.statusCode, result.response?.statusCode)
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?) -> Error? {
        URLProtocolStub.stub = URLProtocolStub.Stub(data: data, response: response, error: error)
        let exp = expectation(description: "Wait for complete")
        var receivedError: Error?
        makeSut().get(from: anyURL()) { result in
            if case let .failure(error) = result {
                receivedError = error
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return receivedError
    }
    
    private func resultFor(data: Data?, response: URLResponse?, error: Error?) -> (data: Data?, response: HTTPURLResponse?) {
        URLProtocolStub.stub = URLProtocolStub.Stub(data: data, response: response, error: error)
        let exp = expectation(description: "Wait for complete")
        var receivedData: Data?
        var receivedResponse: HTTPURLResponse?
        makeSut().get(from: anyURL()) { result in
            if case let .success((data, response)) = result {
                receivedData = data
                receivedResponse = response
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return (receivedData, receivedResponse)
    }
    
    private func makeSut(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private var anyNSError: Error {
        return NSError(domain: "test.error", code: 0)
    }
    
    private var anyURLResponse: URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private var anyHTTPURLResponse: HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}

private class URLProtocolStub: URLProtocol {
    
    struct Stub {
        let data: Data?
        let response: URLResponse?
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
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func stopLoading() {}
    
}
