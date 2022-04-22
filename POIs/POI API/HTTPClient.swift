//
// Created by Mate Csengeri on 2022. 04. 22. 
	

import Foundation

public protocol HTTPClient {
    func get(from url: URL)
}
