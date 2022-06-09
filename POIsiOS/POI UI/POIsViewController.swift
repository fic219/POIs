//
// Created by Mate Csengeri on 2022. 06. 04. 
	

import UIKit
import POIs

public class POIsViewController: UIViewController {

    @IBOutlet private(set) public weak var collectionView: UICollectionView!
    
    private let viewModel: POIsViewModel
    private var collectionModel = [[POI]]()
    
    private(set) public lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    init(viewModel: POIsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: Bundle(for: POIsViewController.self))
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "POICell", bundle: Bundle(for: POICell.self)), forCellWithReuseIdentifier: POICell.reuseIdentifier)
        collectionView.refreshControl = refreshControl
        bind()
        refresh()

    }
    
    @objc private func refresh() {
        viewModel.loadPOIs()
    }
    
    private func bind() {
        viewModel.onPOILoad = { [weak self] pois in
            self?.collectionModel = pois
        }
        
        viewModel.onLoadingStateChange = { [weak self] isLoading in
            if isLoading {
                self?.refreshControl.beginRefreshing()
            } else {
                self?.refreshControl.endRefreshing()
            }
        }
    }
}

extension POIsViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: POICell.reuseIdentifier, for: indexPath) as? POICell else {
            return UICollectionViewCell()
        }
        let poi = collectionModel[indexPath.section][indexPath.row]
        cell.titleLabel.text = poi.name
        cell.descLabel.text = poi.description
        cell.addressLabel.text = poi.address
        return cell
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
