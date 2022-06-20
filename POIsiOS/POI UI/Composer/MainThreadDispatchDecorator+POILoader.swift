//
// Created by Mate Csengeri on 2022. 06. 20. 
	

import Foundation
import POIs

final class MainThreadDispatchDecorator<T> {
    let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async(execute: completion)
            return
        }
        completion()
    }
}

extension MainThreadDispatchDecorator: POILoader where T == POILoader {
    func load(completion: @escaping (POILoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
