//
//  WatchlistCollectionViewCell.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 2.02.2022.
//

import Foundation
import UIKit

class WatchlistCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var latestValueLabel: UILabel!
    
    var watchlistItemEntity: WatchlistItemEntity!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addComponents()
    }
    
    private func addComponents() {
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
    
    func setItem(with item: WatchlistItemEntity, with display: WatchlistCollectionViewDisplay?) {
        self.watchlistItemEntity = item
        setLabels(with: display)
    }
    
    private func setLabels(with display: WatchlistCollectionViewDisplay?) {
        guard let item = self.watchlistItemEntity else {
            return
        }
        self.symbolLabel.text = item.code
        if let timestamp = item.timestamp {
            self.dateLabel.text = timestamp.fromTimeInterval()
        }
        
        guard let mode = display else {
            guard let change_p = item.change_p else {
                self.latestValueLabel.text = "% --.--"
                return
            }
            self.latestValueLabel.text = "% " + change_p
            return
        }
        
        switch mode {
        case .change:
            guard let change = item.change else {
                return
            }
            let c = Float(change) ?? 0
            self.latestValueLabel.text = String(round(c * 100) / 100.0)
        case .change_p:
            guard let change_p = item.change_p else {
                return
            }
            let c = Float(change_p) ?? 0
            self.latestValueLabel.text = "% " + String(round(c * 100) / 100.0)
        case .price:
            guard let change = item.change, let close = item.previousClose else {
                return
            }
            let price = round(((Float(change) ?? 0) + (Float(close) ?? 0)) * 100) / 100.0
            self.latestValueLabel.text = String(price)
        }
        
    }
}

