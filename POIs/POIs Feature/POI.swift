
// Created by Mate Csengeri on 2022. 04. 20.
	

import Foundation

public struct POI: Equatable {
    let name: String
    let description: String?
    let city: String
    let imageURL: String
    let coordinates: Coordinates
}
