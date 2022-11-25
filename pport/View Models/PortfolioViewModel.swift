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
    private(set) var currencies: [CurrencyItemEntity]?
    private(set) var history: [HistoryItemEntity]?
    private(set) var portfolio: PortfolioData?
    private(set) var collectionViewDataType: PortfolioCollectionViewDataType = .portfolio
    
    private(set) var showPopUp = CurrentValueSubject<PopUpCombine, Never>(PopUpCombine(title: "", body: ""))
    private(set) var reloadData = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        self.cancellables.forEach { $0.cancel() }  // cancellabes ile hafızadan çıkardık
    }
    
    init() {
        initUserData()
        initHistoryData()
        initPortfolioData()
        initCurrencyData()
    }
    
    // MARK: init data
    func initData() {
        
    }
    
    private func initUserData() {
        if let token = KeyChainManager.shared.read(service: .token, type: Token.self) {
            self.token = token.token
        }
        if let session = KeyChainManager.shared.read(service: .session, type: Session.self) {
            self.session = session.session
        }
    }
    
    func initHistoryData() {
        guard let token = self.token, let session = self.session else {
            return
        }
        
        do {
            self.history = (try CoreDataManager.shared.fetch(entity: .history) as? [HistoryItemEntity])?.sorted(by: {$0.timestamp ?? "" > $1.timestamp ?? ""})
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.getHistory(token: token, session: session, onFailure: { title, body in
                NSLog("PortfolioViewModel:initHistoryData: Unable to retrieve history data", "")
            }, onSuccess: { data in
                self.saveData(with: data)
            })
        }, notAvailable: {
            DispatchQueue.main.async {
                self.reloadData.send()
            }
        })
    }
    
    func initPortfolioData() {
        guard let token = self.token, let session = self.session else {
            return
        }
        
        do {
            let entities = try CoreDataManager.shared.fetch(entity: .portfolio) as? [PortfolioItemEntity]
            if entities?.count != 0 {
                guard let portfolio = entities?[0], let data = portfolio.portfolio else {
                    return
                }
                
                let decoder = JSONDecoder()
                if let decodedData = try? decoder.decode(PortfolioData.self, from: data) {
                    self.portfolio = decodedData
                }
            }
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.getPortfolio(token: token, session: session, onFailure: { title, body in
                NSLog("PortfolioViewModel:initPortfolioData: Unable to retrieve portfolio data", "")
            }, onSuccess: { data in
                self.saveData(with: data)
            })
        }, notAvailable: {
            DispatchQueue.main.async {
                self.reloadData.send()
            }
        })
    }
    
    func initCurrencyData() {
        guard let token = self.token, let session = self.session else {
            return
        }
        
        do {
            self.currencies = (try CoreDataManager.shared.fetch(entity: .currency) as? [CurrencyItemEntity])?.sorted(by: {$0.code ?? "" > $1.code ?? ""})
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        
        if let date = UserDefaultsManager.shared.get(forKey: "currency") as? Date, let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
            if date > yesterday && self.currencies?.count != 0 {
                NSLog("WatchlistViewModel.initCurrencyData: Not so soon", "")
                return
            }
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.getCurrencyCodes(token: token, session: session, onFailure: { title, body in
                NSLog("PortfolioViewModel:initCurrencyData: Unable to retrieve currency data", "")
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
            NSLog("PortfolioViewModel.saveData: Remove HistoryItemEntity from CoreData error \(err)", "")
            return
        }
        
        var items: [[String: Any]] = []
        for item in history {
            switch item {
            case .portfolio(let portfolio):
                items.append([
                    "from": String(portfolio.from),
                    "ticker": String(portfolio.ticker),
                    "count": String(portfolio.count),
                    "charge": String(portfolio.charge),
                    "currency": String(portfolio.currency),
                    "balance": String(portfolio.balance),
                    "type": String(portfolio.type),
                    "timestamp": String(portfolio.timestamp)
                ])
            case .wallet(let wallet):
                items.append([
                    "from": String(wallet.from),
                    "amount": String(wallet.amount),
                    "currency": String(wallet.currency),
                    "type": String(wallet.type),
                    "balance": String(wallet.balance),
                    "timestamp": String(wallet.timestamp)
                ])
            }
        }
        
        do {
            try CoreDataManager.shared.store(entity: .history, attributes: items)
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        
        do {
            self.history = (try CoreDataManager.shared.fetch(entity: .history) as? [HistoryItemEntity])?.sorted(by: {$0.timestamp ?? "" > $1.timestamp ?? ""})
            DispatchQueue.main.async {
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
            NSLog("PortfolioViewModel.saveData: Remove PortfolioItemEntity from CoreData error \(err)", "")
            return
        }
        
        if let data = try? JSONEncoder().encode(portfolio) {
            do {
                try CoreDataManager.shared.store(entity: .portfolio, attributes: [["portfolio": data]])
            } catch let err {
                NSLog(err.localizedDescription, "")
            }
            
            do {
                let entities = try CoreDataManager.shared.fetch(entity: .portfolio) as? [PortfolioItemEntity]

                guard let portfolio = entities?[0], let data = portfolio.portfolio else {
                    return
                }
                
                let decoder = JSONDecoder()
                if let decodedData = try? decoder.decode(PortfolioData.self, from: data) {
                    self.portfolio = decodedData
                    DispatchQueue.main.async {
                        self.reloadData.send()
                    }
                }
            } catch let err {
                NSLog(err.localizedDescription, "")
            }
        }
    }
    
    func saveData(with currencies: [CurrencyCodeData]) {
        do {
            try CoreDataManager.shared.remove(entity: .currency)
        } catch let err {
            NSLog("PortfolioViewModel.saveData: Remove CurrencyItemEntity from CoreData error \(err)", "")
            return
        }
        
        var items: [[String: Any]] = []
        for currency in currencies {
            items.append([
                "code": currency.Code,
                "country": currency.Country ?? "NA",
                "currency": currency.Currency ?? "NA",
                "exchange": currency.Exchange ?? "NA",
                "isin": currency.Isin ?? "NA",
                "name": currency.Name,
                "type": currency.`Type` ?? "NA"
                ])
        }
        do {
            try CoreDataManager.shared.store(entity: .currency, attributes: items)
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        
        do {
            UserDefaultsManager.shared.set(params: ["currency": Date()])
            self.currencies = (try CoreDataManager.shared.fetch(entity: .currency) as? [CurrencyItemEntity])?.sorted(by: {$0.code ?? "" > $1.code ?? ""})
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
    }
    
    // MARK: Helper
    func setCollectionViewDataType(with type: PortfolioCollectionViewDataType) {
        self.collectionViewDataType = type
    }
}
