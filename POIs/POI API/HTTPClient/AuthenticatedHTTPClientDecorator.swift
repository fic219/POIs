//
// Created by Mate Csengeri on 2022. 06. 18. 
	

import Foundation

public protocol APICredentialsProvider {
    var username: String { get }
    var password: String { get }
}

public class AuthenticatedHTTPClientDecorator: HTTPClient {
    
    private let decoratee: HTTPClient
    private let credentialsProvider: APICredentialsProvider
    
    public init(decoratee: HTTPClient,
         credentialsProvider: APICredentialsProvider) {
        self.decoratee = decoratee
        self.credentialsProvider = credentialsProvider
    }
    
    public func execute(_ urlRequest: URLRequest, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
        var request = urlRequest
        request.addValue(basicAuthValue, forHTTPHeaderField: "Authorization")
        decoratee.execute(request, completion: completion)
    }
    
    private var basicAuthValue: String {
        let authHeaderValue = "\(credentialsProvider.username):\(credentialsProvider.password)".data(using: .utf8)?.base64EncodedString()
        return "Basic \(authHeaderValue ?? "-")"
    }
    
}
