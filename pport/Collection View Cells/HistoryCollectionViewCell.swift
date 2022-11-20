//
//  HistoryCollectionViewCell.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.11.2022.
//

import Foundation
import UIKit

class HistoryPortfolioCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var historyItemEntity: HistoryItemEntity!
    
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
    
    func setItem(with item: HistoryItemEntity) {
        self.historyItemEntity = item
        setLabels()
    }
    
    private func setLabels() {
        guard let item = self.historyItemEntity else {
            return
        }
        
        guard let from = item.from, let ticker = item.ticker, let type = item.type, let currency = item.currency, let count = item.count, let revenue = item.revenue, let balance = item.balance, let timestamp = item.timestamp else {
            return
        }
        self.fromLabel.text = from
        self.typeLabel.text = type
        self.tickerLabel.text = ticker
        self.currencyLabel.text = currency
        self.countLabel.text = count
        self.revenueLabel.text = revenue
        self.balanceLabel.text = balance
        if let doubleTimestamp = Double(timestamp) {
            let epochTime = TimeInterval(doubleTimestamp)
            let date = Date(timeIntervalSince1970: epochTime)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            dateFormatter.dateStyle = .medium
            dateFormatter.timeZone = .current
            let localDate = dateFormatter.string(from: date)
            self.timestampLabel.text = "\(localDate)"
        }
    }
}

class HistoryWalletCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    var historyItemEntity: HistoryItemEntity!
    
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
    
    func setItem(with item: HistoryItemEntity) {
        self.historyItemEntity = item
        setLabels()
    }
    
    private func setLabels() {
        guard let item = self.historyItemEntity else {
            return
        }
        
        guard let from = item.from, let currency = item.currency, let type = item.type, let timestamp = item.timestamp, let amount = item.amount, let balance = item.balance else {
            return
        }
        self.fromLabel.text = from
        self.currencyLabel.text = currency
        self.typeLabel.text = type
        if let doubleTimestamp = Double(timestamp) {
            let epochTime = TimeInterval(doubleTimestamp)
            let date = Date(timeIntervalSince1970: epochTime)
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .medium
            dateFormatter.dateStyle = .medium
            dateFormatter.timeZone = .current
            let localDate = dateFormatter.string(from: date)
            self.timestampLabel.text = "\(localDate)"
        }
        self.amountLabel.text = amount
        self.balanceLabel.text = balance
        NSLog("Labels are set", "")
    }
}
