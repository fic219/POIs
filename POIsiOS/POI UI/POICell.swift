//
// Created by Mate Csengeri on 2022. 06. 08. 
	

import UIKit

public class POICell: UICollectionViewCell {

    static let reuseIdentifier = "reuseIdentifier_POICell"
    
    @IBOutlet private(set) public weak var iconImageView: UIImageView!
    @IBOutlet private(set) public weak var titleLabel: UILabel!
    @IBOutlet private(set) public weak var addressLabel: UILabel!
    @IBOutlet private(set) public weak var descLabel: UILabel!
    

}
