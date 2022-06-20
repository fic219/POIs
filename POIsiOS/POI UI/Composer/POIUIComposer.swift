//
// Created by Mate Csengeri on 2022. 06. 09. 
	

import Foundation
import POIs

public final class POIUIComposer {
    private init() {}
    
    public static func poiListComposed(poiLoader: POILoader) -> POIsViewController {
        let viewModel = POIsViewModel(poiLoader: MainThreadDispatchDecorator(decoratee: poiLoader),
                                      poiArranger: Self.arrangedPOIs(from:))
        return POIsViewController(viewModel: viewModel)
    }
    
    private static func arrangedPOIs(from pois: [POI]) -> [[POI]] {
        
        var groupedPOIs: [String:[POI]] = [:]
        
        for poi in pois {
            if var poisForCity = groupedPOIs[poi.city] {
                poisForCity.append(poi)
                groupedPOIs[poi.city] = poisForCity
            } else {
                let poisForCity = [poi]
                groupedPOIs[poi.city] = poisForCity
            }
            
        }
        
        // order keys alphabetically:
        let keys = groupedPOIs.keys
        let orderedKeys = keys.sorted { $1 > $0 }
        
        var retValue: [[POI]] = []
        for key in orderedKeys {
            if let poisForKey = groupedPOIs[key] {
                retValue.append(poisForKey)
            }
        }
        
        return retValue
    }
}
