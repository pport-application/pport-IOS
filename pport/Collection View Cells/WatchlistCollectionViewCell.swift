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
    
    let containerView = UIView()
    
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
    
    func setItem(with item: WatchlistItemEntity) {
        self.watchlistItemEntity = item
        setLabels()
    }
    
    private func setLabels() {
        guard let item = self.watchlistItemEntity else {
            return
        }
        self.symbolLabel.text = item.code
        if let timestamp = item.timestamp {
            if let doubleTimestamp = Double(timestamp) {
                let epochTime = TimeInterval(doubleTimestamp)
                let date = Date(timeIntervalSince1970: epochTime)
                let dateFormatter = DateFormatter()
                dateFormatter.timeStyle = .medium
                dateFormatter.dateStyle = .medium
                dateFormatter.timeZone = .current
                let localDate = dateFormatter.string(from: date)
                self.dateLabel.text = "\(localDate)"
            } else {
                self.dateLabel.text = timestamp
            }
        }
        if let change_p = item.change_p {
            self.latestValueLabel.text = change_p
        }
    }
}
