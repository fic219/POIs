//
// Created by Mate Csengeri on 2022. 06. 18. 
	

import XCTest
import POIs

protocol APICredentialsProvider {
    var username: String { get }
    var password: String { get }
}

class AuthenticatedHTTPClientDecorator: HTTPClient {
    
    private let decoratee: HTTPClient
    private let credentialsProvider: APICredentialsProvider
    
    init(decoratee: HTTPClient,
         credentialsProvider: APICredentialsProvider) {
        self.decoratee = decoratee
        self.credentialsProvider = credentialsProvider
    }
    
    func execute(_ urlRequest: URLRequest, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        var request = urlRequest
        request.addValue(basicAuthValue, forHTTPHeaderField: "Authorization")
        decoratee.execute(request, completion: completion)
    }
    
    private var basicAuthValue: String {
        let authHeaderValue = "\(credentialsProvider.username):\(credentialsProvider.password)".data(using: .utf8)?.base64EncodedString()
        return "Basic \(authHeaderValue ?? "-")"
    }
    
}

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {

    func test_execute_applyBasicAuthentication() {
        let httpClient = HTTPClientSpy()
        let username = "username"
        let password = "password"
        let credentialsProvider = APICredentialsProviderStub(username: username, password: password)
        let sut = AuthenticatedHTTPClientDecorator(decoratee: httpClient, credentialsProvider: credentialsProvider)
        let urlRequest = anyRequest()
        sut.execute(urlRequest) { _ in }
        XCTAssertTrue(httpClient.request!.containsBasicAuthHeaderWith(username: username, password: password))
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
