//
//  WatchlistViewModel.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 8.03.2022.
//

import Foundation
import Combine

// TODO: Sort data before reloading table.

class WatchlistViewModel {
    
    private var session: String?
    private var token: String?
    
    private(set) var watchlist: [WatchlistItemEntity]?
    private(set) var searchData: [TickerData]?
    private(set) var filteredSearchData: [TickerData]?
    private(set) var exchanges: [ExchangeItemEntity]?
    private(set) var currentExchange: ExchangeItemEntity?
    private(set) var collectionViewDataType: WatchlistCollectionViewDataType = .watchlist
    private(set) var collectionViewDisplay: WatchlistCollectionViewDisplay = .change_p

    private(set) var showPopUp = CurrentValueSubject<PopUpCombine, Never>(PopUpCombine(title: "", body: ""))
    private(set) var reloadData = PassthroughSubject<Void, Never>()
    private(set) var changeUI = PassthroughSubject<Void, Never>()
    private(set) var deleteTickerFromCV = CurrentValueSubject<IndexPath, Never>(IndexPath(row: -1, section: -1))
    private(set) var reloadPicker = PassthroughSubject<Void, Never>()
    private(set) var changeWatchlistDisplay = PassthroughSubject<Void, Never>()
    private(set) var setPickerViewIndex = CurrentValueSubject<Int, Never>(0)
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        self.cancellables.forEach { $0.cancel() }  // cancellabes ile hafızadan çıkardık
    }
    
    init() {
        initUserData()
        setCollectionViewMode(with: .change_p)
        initExchangeCodes() // calles initSearchData
        initWatchlistData()
    }
    
    // MARK: init data
    func initData() {
        
    }
    
    func initUserData() {
        if let token = KeyChainManager.shared.read(service: .token, type: Token.self) {
            self.token = token.token
        }
        if let session = KeyChainManager.shared.read(service: .session, type: Session.self) {
            self.session = session.session
        }
        NSLog("KeyChainManager for session in WatchlistViewModel \(String(describing: session))", "")
        NSLog("KeyChainManager for token in WatchlistViewModel \(String(describing: token))", "")
        
        do {
            self.exchanges = (try CoreDataManager.shared.fetch(entity: .exchange) as? [ExchangeItemEntity])?.sorted(by: {$0.country ?? "" < $1.country ?? ""})
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        
        do {
            self.watchlist = (try CoreDataManager.shared.fetch(entity: .watchlist) as? [WatchlistItemEntity])?.sorted(by: {$0.code ?? "" < $1.code ?? ""})
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        self.reloadData.send()
    }
    
    func initExchangeCodes() {
        guard let session = session, let token = token else {
            return
        }
        
        if let date = UserDefaultsManager.shared.get(forKey: "exchange") as? Date, let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
            if date > yesterday && self.exchanges?.count != 0 {
                NSLog("WatchlistViewModel.initExchangeCodes: Not so soon", "")
                self.initSearchData()
                return
            }
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.getExchangeCodes(token: token, session: session, onFailure:  { _, _ in }, onSuccess:  { data in
                self.saveData(with: data)
            })
        }, notAvailable: {})
    }
    
    func initSearchData(with exchange: ExchangeItemEntity? = nil) {
        guard let session = session, let token = token else {
            return
        }
        
        if exchange == nil {
            guard let exchange = self.exchanges?.filter({ $0.code == "IS" }).first,
                  let index = self.exchanges?.firstIndex(where: { $0.code == "IS" }) else {
                return
            }
            self.currentExchange = exchange
            self.setPickerViewIndex.send(index)
        } else {
            self.currentExchange = exchange!
        }
        
        
        guard let code = self.currentExchange?.code else {
            return
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.getTickers(token: token, session: session, exchange_code: code, onFailure:  { _, _ in }, onSuccess:  { data in
                self.searchData = data.sorted(by: {$0.Code > $1.Code})
                self.filteredSearchData = data
                DispatchQueue.main.async {
                    self.reloadData.send()
                }
            })
        }, notAvailable: {})
    }
    
    func initWatchlistData(displayPopUp request: Bool = false) {
        
        guard let session = session, let token = token else {
            return
        }
        
        if let date = UserDefaultsManager.shared.get(forKey: "watchlist") as? Date, let threeMinutesEarly = Calendar.current.date(byAdding: .minute, value: -3, to: Date()) {
            if date > threeMinutesEarly && self.watchlist?.count != 0 {
                NSLog("WatchlistViewModel.initWatchlist: Not so soon", "")
                if request {
                    self.showPopUp.send(PopUpCombine(title: "Sorry", body: "Please repeat same request few minutes later."))
                }
                return
            }
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.getWatchlistData(token: token, session: session, onFailure: { _, _ in }, onSuccess: { data in
                self.saveData(with: data)
            })
        }, notAvailable: {})

    }
    
    // MARK: Save Data to CoreData
    func saveData(with exchanges: [ExchangeData]) {
        do {
            try CoreDataManager.shared.remove(entity: .exchange)
        } catch let err {
            NSLog("WatchlistViewModel.saveData: Remove ExchangeData from CoreData error \(err)", "")
            return
        }
        
        var items: [[String: Any]] = []
        for exchange in exchanges {
            items.append([
                "code": exchange.Code,
                "country": exchange.Country ?? "NA",
                "countryISO2": exchange.CountryISO2 ?? "NA",
                "countryISO3": exchange.CountryISO3 ?? "NA",
                "currency": exchange.Currency ?? "NA",
                "name": exchange.Name,
                "operatingMIC": exchange.OperatingMIC ?? "NA"
            ])
        }
        
        do {
            try CoreDataManager.shared.store(entity: .exchange, attributes: items)
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        
        do {
            UserDefaultsManager.shared.set(params: ["exchange": Date()])
            self.exchanges = (try CoreDataManager.shared.fetch(entity: .exchange) as? [ExchangeItemEntity])?.sorted(by: {$0.country ?? "" < $1.country ?? ""})
            self.reloadPicker.send()
            self.initSearchData()
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
    }
    
    func saveData(with tickers: [WatchlistData]) {
        do {
            try CoreDataManager.shared.remove(entity: .watchlist)
        } catch let err {
            NSLog("WatchlistViewModel.saveData: Remove WatchListItem from CoreData error \(err)", "")
            return
        }
        
        var items: [[String: Any]] = []
        for ticker in tickers {
            items.append([
                "low": ticker.low != nil ? String(ticker.low!) : "NA",
                "previousClose": ticker.previousClose != nil ? String(ticker.previousClose!) : "NA",
                "close": ticker.close != nil ? String(ticker.close!) : "NA",
                "change": ticker.change != nil ? String(ticker.change!) : "NA",
                "change_p": ticker.change_p != nil ? String(ticker.change_p!) : "NA",
                "code": ticker.code,
                "open": ticker.open != nil ? String(ticker.open!) : "NA",
                "timestamp": ticker.timestamp != nil ? String(ticker.timestamp!) : "NA",
                "volume": ticker.volume != nil ? String(ticker.volume!) : "NA",
                "high": ticker.high != nil ? String(ticker.high!) : "NA"
            ])
        }
        do{
            try CoreDataManager.shared.store(entity: .watchlist, attributes: items)
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        do {
            UserDefaultsManager.shared.set(params: ["watchlist": Date()])
            self.watchlist = (try CoreDataManager.shared.fetch(entity: .watchlist) as? [WatchlistItemEntity])?.sorted(by: {$0.code ?? "" < $1.code ?? ""})
            DispatchQueue.main.async {
                self.reloadData.send()
            }
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
    }
    
    // MARK: Watclist functions
    func addItemToWatchlist(indexPath: IndexPath) {
        guard let exchange = self.currentExchange?.code,
                let session = self.session,
                let token = self.token,
                let ticker = self.filteredSearchData?[indexPath.row].Code else {
            return
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.addWatchlistItem(token: token, session: session, ticker: ticker + ".\(exchange)", onFailure: { title, body in
                DispatchQueue.main.async {
                    self.showPopUp.send(PopUpCombine(title: title, body: body))
                }
            }, onSuccess: {
                var params: [String] = []
                params.append(token)
                
                APIManager.shared.getWatchlistData(token: token, session: session, onFailure: { _, _ in }, onSuccess: { data in
                    DispatchQueue.main.async {
                        self.saveData(with: data)
                        self.changeUI.send()
                    }
                })
            })
        }, notAvailable: {
            self.showPopUp.send(PopUpCombine(title: "No Network", body: "Please check your network connection."))
        })
    }
    
    func removeItemFromWatchlist(indexPath: IndexPath) {
        guard let session = self.session,
              let token = self.token,
              let ticker = self.watchlist?[indexPath.row].code else {
            return
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.deleteWatchlistItem(token: token, session: session, ticker: ticker, onFailure: { title, body in
                DispatchQueue.main.async {
                    self.showPopUp.send(PopUpCombine(title: title, body: body))
                }
            }, onSuccess: {
                do {
                    try CoreDataManager.shared.remove(entity: .watchlist, attribute: "code", value: ticker)
                } catch let err {
                    NSLog(err.localizedDescription, "")
                }
                self.watchlist?.remove(at: indexPath.row)
                self.deleteTickerFromCV.send(indexPath)
            })
        }, notAvailable: {
            self.showPopUp.send(PopUpCombine(title: "No Network", body: "Please check your network connection."))
        })
    }
    
    // MARK: Helper
    func setCollectionViewDataType(with type: WatchlistCollectionViewDataType) {
        self.collectionViewDataType = type
    }
    
    func setCollectionViewMode(with type: WatchlistCollectionViewDisplay) {
        self.collectionViewDisplay = type
        self.changeWatchlistDisplay.send()
    }
    
    func filterSearchData(with string: String?) {
        guard let searchData = searchData, let string = string else {
            return
        }
        if string == "" {
            self.filteredSearchData = self.searchData
        } else {
            self.filteredSearchData = searchData.filter { data in
                return data.Name.lowercased().contains(string.lowercased())
            }
        }
        self.reloadData.send()
    }
}
