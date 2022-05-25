//
// Created by Mate Csengeri on 2022. 05. 25. 
	

import XCTest
import POIs

class POIAPIEndToEndTests: XCTestCase {

    func test_entToEndTestGetPOIS_matchFixedData() {
        let mockURL = URL(string: "https://apimocha.com/pois/mock")!
        let httpClient = URLSessionHTTPClient()
        let loader = RemotePOILoader(url: mockURL, client: httpClient)
        
        let exp = expectation(description: "Waiting the server to complete")
        var receivedResult: POILoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5)
        
        switch receivedResult {
        case .success(let pois)?:
            XCTAssertEqual(pois.count, 4)
            expectPoi(pois[0], at: 0)
            expectPoi(pois[1], at: 1)
            expectPoi(pois[2], at: 2)
            expectPoi(pois[3], at: 3)
            
        case .failure?:
            XCTFail("Should have succeded")
        default:
            XCTFail("Should have succeded")
        }
    }
    
    private func expectPoi(_ poi: POI, at index: Int) {
        XCTAssertEqual(poi, expectedPOIS[index])
    }
    
    private let expectedPOIS = [
        POI(name: "Budapest office",
            description: "This is our main base of operation, where the majority of the team works.",
            city: "Budapest",
            address: "1037 Budapest, Montevideo utca 9.",
            imageURL: "http://candidate.mondriaan.com/img/Budapest office.jpg",
            longitude: 19.034413,
            latitude: 47.529783),
        POI(name: "Future office",
            description: "We're starting to outgrow our current office, this is where our next home is going to be.",
            city: "Budapest",
            address: "1036 Budapest, Lajos utca 48-66.",
            imageURL: "http://candidate.mondriaan.com/img/Future office.jpg",
            longitude: 19.03889,
            latitude: 47.529865),
        POI(name: "Daubner Cukrászda",
            description: "The <i>best</i> confectionery in town, located well within walking range.",
            city: "Budapest",
            address: "1025 Budapest, Szépvölgyi út 50.",
            imageURL: "http://candidate.mondriaan.com/img/Daubner Cukraszda.jpg",
            longitude: 19.031758,
            latitude: 47.528469),
        POI(name: "Déjá-Vu Étterem",
            description: "Many colleagues are daily regular guests at this cafeteria. <i>Big</i> portions and homemade taste.",
            city: "Budapest",
            address: "1037 Budapest, Montevideo utca 3.",
            imageURL: "http://candidate.mondriaan.com/img/Deja-Vu Etterem.jpg",
            longitude: 19.032864,
            latitude: 47.529506),
    ]

}
