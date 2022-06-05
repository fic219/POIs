//
// Created by Mate Csengeri on 2022. 06. 04. 
	

import UIKit
import POIs

public class POIsViewController: UIViewController {

    private let loader: POILoader
    
    private(set) public lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    public init(loader: POILoader) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()

    }
    
    @objc private func refresh() {
        refreshControl.beginRefreshing()
        loader.load { [weak self] _ in
            self?.refreshControl.endRefreshing()
        }
    }
    
    
    
}
