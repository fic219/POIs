
// Created by Mate Csengeri on 2022. 04. 20.
	

import Foundation

public struct POI: Equatable {
    public let name: String
    public let description: String?
    public let city: String
    public let address: String
    public let imageURL: URL
    public let coordinates: Coordinates
    
    public init(name: String,
                description: String?,
                city: String,
                address: String,
                imageURL: URL,
                longitude: Double,
                latitude: Double) {
        self.name = name
        self.description = description
        self.city = city
        self.address = address
        self.imageURL = imageURL
        self.coordinates = Coordinates(longitude: longitude, latitude: latitude)
    }
}
