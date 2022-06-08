//
// Created by Mate Csengeri on 2022. 06. 04. 
	

import UIKit
import POIs

public class POIsViewController: UIViewController {

    @IBOutlet private(set) public weak var collectionView: UICollectionView!
    private let loader: POILoader
    private var collectionModel = [[POI]]()
    
    private(set) public lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }()
    
    public init(loader: POILoader) {
        self.loader = loader
        super.init(nibName: nil, bundle: Bundle(for: POIsViewController.self))
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.refreshControl = refreshControl
        refresh()

    }
    
    @objc private func refresh() {
        refreshControl.beginRefreshing()
        loader.load { [weak self] result in
            guard let self = self else { return }
            if let pois = try? result.get() {
                self.collectionModel = self.arrangedPOIs(from: pois)
                self.collectionView.reloadData()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    private func arrangedPOIs(from pois: [POI]) -> [[POI]] {
        
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
        let orderedKeys = keys.sorted { (key1, key2) -> Bool in
            return key2 > key1
        }
        
        var retValue: [[POI]] = []
        for key in orderedKeys {
            if let poisForKey = groupedPOIs[key] {
                retValue.append(poisForKey)
            }
        }
        
        return retValue
    }
    
    
}

extension POIsViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

extension POIsViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionModel[section].count
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionModel.count
    }
    
    
}
