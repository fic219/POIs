//
// Created by Mate Csengeri on 2022. 04. 22. 
	

import Foundation

public protocol HTTPClient {
    func execute(_ urlRequest: URLRequest, completion: @escaping (Result<(Data, HTTPURLResponse), Swift.Error>) -> Void)
}
