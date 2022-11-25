//
//  PortfolioTickerCollectionViewCell.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 21.11.2022.
//

import Foundation
import UIKit

class PortfolioTickerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //addComponents()
    }
    
    func addComponents() {
        self.contentView.layer.cornerRadius = 8
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.systemGray3.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    func setTitle(with ticker: Portfolio) {
        self.tickerLabel.text = ticker.ticker
        self.currencyLabel.text = ticker.currency
        self.countLabel.text = String(ticker.count)
        self.balanceLabel.text = String(ticker.balance)
    }
}
