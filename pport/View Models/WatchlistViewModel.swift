//
//  WatchlistViewModel.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 8.03.2022.
//

import Foundation
import Combine

class WatchlistViewModel {
    
    private var session: String?
    private var token: String?
    
    private(set) var watchlist: [WatchlistItemEntity]?
    private(set) var searchData: [TickerData]?
    private(set) var filteredSearchData: [TickerData]?
    private(set) var exchanges: [ExchangeData]?
    private(set) var currentExchange: String?
    private(set) var collectionViewDataType: WatchlistCollectionViewDataType = .watchlist

    private(set) var showPopUp = CurrentValueSubject<PopUpCombine, Never>(PopUpCombine(title: "", body: ""))
    private(set) var reloadData = PassthroughSubject<Void, Never>()
    private(set) var changeUI = PassthroughSubject<Void, Never>()
    private(set) var deleteTickerFromCV = CurrentValueSubject<IndexPath, Never>(IndexPath(row: -1, section: -1))
    private(set) var reloadPicker = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        self.cancellables.forEach { $0.cancel() }  // cancellabes ile hafızadan çıkardık
    }
    
    init() {
        initUserData()
    }
    
    func initUserData() {
        session = KeyChainManager.shared.read(service: .session, type: Session.self)?.session
        token = KeyChainManager.shared.read(service: .token, type: Token.self)?.token
        NSLog("KeyChainManager for session in WatchlistViewModel \(String(describing: session))", "")
        NSLog("KeyChainManager for token in WatchlistViewModel \(String(describing: token))", "")
    }
    
    func initExchangeCodes() {
        
        NetworkManager.shared.check(isAvailable: {
            guard let session = self.session, let token = self.token else {
                return
            }
            APIManager.shared.getExchangeCodes(token: token, session: session, onFailure:  { _, _ in }, onSuccess:  { data in
                self.exchanges = data
                self.reloadPicker.send()
                self.initSearchData()
            })
        }, notAvailable: {})
    }
    
    func initSearchData(with exchange: String? = nil) {
        
        guard let session = session, let token = token else {
            return
        }
        
        if exchange == nil {
            guard let exchange = self.exchanges?[0].Code else {
                return
            }
            self.currentExchange = exchange
        } else {
            self.currentExchange = exchange!
        }
        
        APIManager.shared.getTickers(token: token, session: session, exchange_code: self.currentExchange!, onFailure:  { _, _ in }, onSuccess:  { data in
            self.searchData = data
            self.filteredSearchData = data
            DispatchQueue.main.async {
                self.reloadData.send()
            }
        })
    }
    
    func initWatchlistData() {
        
        guard let session = session, let token = token else {
            return
        }
        
        do {
            self.watchlist = try CoreDataManager.shared.fetch(entity: .watchlist) as? [WatchlistItemEntity]
            self.reloadData.send()
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.getWatchlistData(token: token, session: session, onFailure: { _, _ in }, onSuccess: { data in
                self.saveData(with: data)
            })
        }, notAvailable: {})

    }
    
    func saveData(with tickers: [WatchlistData]) {
        do {
            try CoreDataManager.shared.remove(entity: .watchlist)
        } catch let err {
            NSLog("WatchlistViewModel.saveData: Remove WatchListItem from CoreData error \(err)", "")
            return
        }
        
        for ticker in tickers {
            do {
                let attributes: [String: Any] = [
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
                ]
                try CoreDataManager.shared.store(entity: .watchlist, attributes: attributes)
            } catch let err {
                NSLog(err.localizedDescription, "")
            }
        }
        
        do {
            self.watchlist = try CoreDataManager.shared.fetch(entity: .watchlist) as? [WatchlistItemEntity]
            DispatchQueue.main.async {
                self.reloadData.send()
            }
        } catch let err {
            NSLog(err.localizedDescription, "")
        }
    }
    
    func addItemToWatchlist(indexPath: IndexPath) {
        guard let exchange = self.currentExchange,
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
                self.watchlist?.remove(at: indexPath.row)
                self.deleteTickerFromCV.send(indexPath)
            })
        }, notAvailable: {
            self.showPopUp.send(PopUpCombine(title: "No Network", body: "Please check your network connection."))
        })
    }
    
    func setCollectionViewDataType(with type: WatchlistCollectionViewDataType) {
        self.collectionViewDataType = type
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
