//
//  PortfolioViewModel.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.03.2022.
//

import Foundation
import Combine

class PortfolioViewModel {
    
    var session: String?
    var token: String?
    private(set) var currencies: [CurrencyCodeData]?
    private(set) var history: [HistoryItemEntity]?
    private(set) var portfolio: [PortfolioItemEntity]?
    private(set) var collectionViewDataType: PortfolioCollectionViewDataType = .portfolio
    
    
    private(set) var reloadData = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        self.cancellables.forEach { $0.cancel() }  // cancellabes ile hafızadan çıkardık
    }
    
    init() {
        initUserData()
        initHistoryData()
        initPortfolioData()
    }
    
    func initUserData() {
        if let token = KeyChainManager.shared.read(service: .token, type: Token.self) {
            self.token = token.token
        }
        if let session = KeyChainManager.shared.read(service: .session, type: Session.self) {
            self.session = session.session
        }
    }
    
    // MARK: init data
    func initData() {
//        guard let session = session, let token = token else {
//            return
//        }
//
//        APIManager.shared.getCurrencyCodes(token: token, session: session, onFailure: { _, _ in
//            NSLog("PortfolioVoewModel.initData: Unable to retrieve currencies", "")
//        }, onSuccess: { currencies in
//            self.currencies = currencies
//        })
    }
    
    func initHistoryData() {
        guard let token = self.token, let session = self.session else {
            return
        }
        
        do {
            self.history = try CoreDataManager.shared.fetch(entity: .history) as? [HistoryItemEntity]
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.getHistory(token: token, session: session, onFailure: { title, body in
                NSLog("PortfolioViewModel:initHistoryData: Unable to retrieve history data", "")
            }, onSuccess: { data in
                self.saveData(with: data)
            })
        }, notAvailable: {})
    }
    
    func initPortfolioData() {
        guard let token = self.token, let session = self.session else {
            return
        }
        
        do {
            self.portfolio = try CoreDataManager.shared.fetch(entity: .portfolio) as? [PortfolioItemEntity]
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.getPortfolio(token: token, session: session, onFailure: { title, body in
                NSLog("PortfolioViewModel:initPortfolioData: Unable to retrieve portfolio data", "")
            }, onSuccess: { data in
                self.saveData(with: data)
            })
        }, notAvailable: {})
    }
    
    // MARK: Save Data to CoreData
    func saveData(with history: [HistoryData]) {
        do {
            try CoreDataManager.shared.remove(entity: .history)
        } catch let err {
            NSLog("PortfolioViewModel.saveData: Remove WatchListItem from CoreData error \(err)", "")
            return
        }
        
        for item in history {
            switch item {
            case .portfolio(let portfolio):
                do {
                    let attributes: [String: Any] = [
                        "from": String(portfolio.from),
                        "ticker": String(portfolio.ticker),
                        "count": String(portfolio.count),
                        "revenue": String(portfolio.revenue),
                        "currency": String(portfolio.currency),
                        "type": String(portfolio.type),
                        "timestamp": String(portfolio.timestamp)
                    ]
                    try CoreDataManager.shared.store(entity: .history, attributes: attributes)
                } catch let err {
                    NSLog(err.localizedDescription, "")
                }
            case .wallet(let wallet):
                do {
                    let attributes: [String: Any] = [
                        "from": String(wallet.from),
                        "amount": String(wallet.amount),
                        "currency": String(wallet.currency),
                        "type": String(wallet.type),
                        "balance": String(wallet.balance),
                        "timestamp": String(wallet.timestamp)
                    ]
                    try CoreDataManager.shared.store(entity: .history, attributes: attributes)
                } catch let err {
                    NSLog(err.localizedDescription, "")
                }
            }
        }
        do {
            self.history = try CoreDataManager.shared.fetch(entity: .history) as? [HistoryItemEntity]
            DispatchQueue.main.async {
                // TODO: - Update UI table
                self.reloadData.send()
            }
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
    }
    
    func saveData(with portfolio: PortfolioData) {
        do {
            try CoreDataManager.shared.remove(entity: .portfolio)
        } catch let err {
            NSLog("PortfolioViewModel.saveData: Remove WatchListItem from CoreData error \(err)", "")
            return
        }
        
        if let p = try? JSONEncoder().encode(portfolio.portfolio), let w = try? JSONEncoder().encode(portfolio.wallet) {
            do {
                let attributes: [String: Any] = [
                    "portfolio": p,
                    "wallet": w
                ]
                try CoreDataManager.shared.store(entity: .portfolio, attributes: attributes)
            } catch let err {
                NSLog(err.localizedDescription, "")
            }
            
            do {
                self.portfolio = try CoreDataManager.shared.fetch(entity: .portfolio) as? [PortfolioItemEntity]
                DispatchQueue.main.async {
                    // TODO: - Update UI table
                }
            } catch let err {
                NSLog(err.localizedDescription, "")
            }
        }
    }
    
    // MARK: Helper
    func setCollectionViewDataType(with type: PortfolioCollectionViewDataType) {
        self.collectionViewDataType = type
    }
}
