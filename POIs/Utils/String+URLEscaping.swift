//
// Created by Mate Csengeri on 2022. 06. 05. 
	

import Foundation

public extension String {
    var percentEncodedURL: URL? {
        guard let encoded = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: encoded)
    }
}
