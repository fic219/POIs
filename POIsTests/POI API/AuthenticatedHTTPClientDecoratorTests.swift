//
// Created by Mate Csengeri on 2022. 06. 18. 
	

import XCTest
import POIs

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {

    func test_execute_applyBasicAuthentication() throws {
        let username = "username"
        let password = "password"
        let (httpClient, sut) = makeSut(username: username, password: password)
        
        sut.execute(anyRequest()) { _ in }
        XCTAssertTrue(try XCTUnwrap(httpClient.request).containsBasicAuthHeaderWith(username: username, password: password))
    }
    
    func test_execute_completesdWithDecorateeResult() throws {
        let (httpClient, sut) = makeSut()
        
        let result = (Data("data".utf8), httpResponse(with: 200))
        var receivedResult: Result<(Data, HTTPURLResponse), Error>?
        sut.execute(anyRequest()) { receivedResult = $0 }
        
        httpClient.complete(with: result)
        
        let receivedValues = try XCTUnwrap(receivedResult).get()
        XCTAssertEqual(receivedValues.0, result.0)
        XCTAssertEqual(receivedValues.1, result.1)
    }
    
    private func makeSut(username: String = "username",
                         password: String = "password",
                         file: StaticString = #filePath,
                         line: UInt = #line) -> (HTTPClientSpy, AuthenticatedHTTPClientDecorator) {
        let httpClient = HTTPClientSpy()
        let credentialsProvider = APICredentialsProviderStub(username: username, password: password)
        let sut = AuthenticatedHTTPClientDecorator(decoratee: httpClient, credentialsProvider: credentialsProvider)
        trackForMemoryLeaks(httpClient, file: file, line: line)
        trackForMemoryLeaks(credentialsProvider, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (httpClient, sut)
    }

}

private extension URLRequest {
    func containsBasicAuthHeaderWith(username: String, password: String) -> Bool {
        guard let expectedAuthHeaderValue = "\(username):\(password)".data(using: .utf8)?.base64EncodedString(),
                let authHeader = self.allHTTPHeaderFields?["Authorization"],
              "Basic \(expectedAuthHeaderValue)" == authHeader else {
            return false
        }
        
        return true
    }
}

private class APICredentialsProviderStub: APICredentialsProvider {
    private(set) var username: String
    
    private(set) var password: String
    
    init(username: String,
         password: String) {
        self.username = username
        self.password = password
    }
    
    
}
