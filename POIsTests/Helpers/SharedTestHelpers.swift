//
// Created by Mate Csengeri on 2022. 05. 07. 
	

import Foundation

func anyURL() -> URL {
    URL(string: "http://anyURL")!
}

var anyData: Data {
    Data("data".utf8)
}

func request(from url: URL) -> URLRequest {
    var retValue = URLRequest(url: url)
    retValue.httpMethod = "GET"
    return retValue
}

func anyRequest() -> URLRequest {
    request(from: anyURL())
}
