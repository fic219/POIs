//
// Created by Mate Csengeri on 2022. 06. 09. 
	

import Foundation
import POIs

final class POIsViewModel {
    
    typealias Observer<T> = (T) -> Void
    
    private let poiLoader: POILoader
    private let poiArranger: ([POI]) -> [[POI]]
    
    init(poiLoader: POILoader,
         poiArranger: @escaping ([POI]) -> [[POI]]) {
        self.poiLoader = poiLoader
        self.poiArranger = poiArranger
    }
    
    var onPOILoad: Observer<[[POI]]>?
    var onLoadingStateChange: Observer<Bool>?
    
    func loadPOIs() {
        onLoadingStateChange?(true)
        poiLoader.load { [weak self] result in
            guard let self = self else { return }
            if let pois = try? result.get() {
                let orderedPOIs = self.poiArranger(pois)
                self.onPOILoad?(orderedPOIs)
            }
            self.onLoadingStateChange?(false)
        }
    }
    
}

