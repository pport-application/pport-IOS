//
//  PortfolioCollectionViewCellInteractiveHeader.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 21.11.2022.
//

import Foundation
import UIKit

class PortfolioCollectionViewCellInteractiveHeader: UICollectionReusableView {
    
    @IBOutlet weak var collectionViewSectionTitle: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setTitle(with title: String) {
        self.collectionViewSectionTitle.text = title
    }
}
