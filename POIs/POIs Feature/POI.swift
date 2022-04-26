
// Created by Mate Csengeri on 2022. 04. 20.
	

import Foundation

public struct POI: Equatable {
    let name: String
    let description: String?
    let city: String
    let imageURL: String
    let coordinates: Coordinates
    
    public init(name: String,
                description: String?,
                city: String,
                imageURL: String,
                longitude: Double,
                latitude: Double) {
        self.name = name
        self.description = description
        self.city = city
        self.imageURL = imageURL
        self.coordinates = Coordinates(longitude: longitude, latitude: latitude)
    }
}
