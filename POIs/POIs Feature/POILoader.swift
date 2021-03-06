//
// Created by Mate Csengeri on 2022. 04. 20. 
	

import Foundation

public protocol POILoader {
    typealias Result = Swift.Result<[POI], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
