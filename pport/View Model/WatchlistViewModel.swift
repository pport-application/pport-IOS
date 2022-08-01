//
//  WatchlistViewModel.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 8.03.2022.
//

import Foundation
import Combine

class WatchlistViewModel {
    
    private(set) var watchlist: [WatchListItem]?
    private(set) var searchData: [SearchData]?
    private(set) var filteredSearchData: [SearchData]?
    private(set) var exchanges: [ExchangeData]?
    private(set) var user_id: String?
    private(set) var session: String?
    private(set) var currentExchange: String?
    private(set) var collectionViewDataType: WatchlistCollectionViewDataType = .watchlist

    private(set) var showPopUp = CurrentValueSubject<PopUpCombine, Never>(PopUpCombine(title: "", body: ""))
    private(set) var reloadData = PassthroughSubject<Void, Never>()
    private(set) var changeUI = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        self.cancellables.forEach { $0.cancel() }  // cancellabes ile hafızadan çıkardık
    }
    
    init() {
        initUserData()
    }
    
    func initUserData() {
        self.user_id = UserDefaultsManager.shared.get(forKey: "user_id") as? String
        self.session = UserDefaultsManager.shared.get(forKey: "session") as? String
        
        NSLog("user_id \(user_id)", "")
        NSLog("session \(session)", "")
    }
    
    func initExchangeCodes() {
        APIManager.shared.getExchanges(onFailure:  { title, body in
            NSLog("Unable to retrieve search data, \(title), \(body)", "")
        }, onSuccess:  { data in
            self.exchanges = data
            self.initSearchData()
        })
    }
    
    func initSearchData(with exchange: String? = nil) {
        if exchange == nil {
            guard let exchange = self.exchanges?[0].Code else {
                NSLog("Unable to retrieve first item of exchanges", "")
                return
            }
            self.currentExchange = exchange
        } else {
            self.currentExchange = exchange!
        }
        
        APIManager.shared.getStockNames(exchangeCode: self.currentExchange!, onFailure:  { title, body in
            NSLog("Unable to retrieve search data, \(title), \(body)", "")
        }, onSuccess:  { data in
            self.searchData = data
            self.filteredSearchData = data
            if self.collectionViewDataType == .search {
                DispatchQueue.main.async {
                    self.reloadData.send()
                }
            }
        })
    }
    
    func initWatchlistData() {
        
        guard let user_id = user_id, let session = session else {
            NSLog("user_id or session is nill", "")
            return
        }

        APIManager.shared.getWatchlistData(user_id: user_id, session: session, onFailure: { title, body in
            NSLog("getWatchlistData \(title), \(body)", "")
        }, onSuccess: { data in
            DispatchQueue.main.async {
                self.saveData(with: data)
                self.reloadData.send()
            }
        })

    }
    
    func saveData(with tickers: [TickerItem]) {
        do {
            try CoreDataManager.shared.remove(entity: "WatchListItem")
        } catch let err {
            NSLog("Remove WatchListItem from CoreData error \(err)", "")
            return
        }
        
        for ticker in tickers {
            do {
                let attributes: [String: Any] = [
                    "low": ticker.low,
                    "previousClose": ticker.previousClose,
                    "close": ticker.close,
                    "change": ticker.change,
                    "change_p": ticker.change_p,
                    "code": ticker.code,
                    "open": ticker.open,
                    "timestamp": ticker.timestamp,
                    "volume": ticker.volume,
                    "high": ticker.high
                ]
                try CoreDataManager.shared.store(entity: "WatchListItem", attributes: attributes)
                self.watchlist = try CoreDataManager.shared.fetch(entity: "WatchListItem") as? [WatchListItem]
                DispatchQueue.main.async {
                    self.reloadData.send()
                }
            } catch let err {
                NSLog(err.localizedDescription, "")
            }
        }
    }
    
//    func updateData(with tickers: [TickerItem]) {
//        for ticker in tickers {
//            do {
//                let predicate = NSPredicate(format: "code == %@", ticker.code)
//                try CoreDataManager.shared.update(entity: "WatchListItem", predicate: predicate, low: ticker.low, previousClose: ticker.previousClose, close: ticker.close, change: ticker.change, change_p: ticker.change_p, code: ticker.code, open: ticker.open, timestamp: ticker.timestamp, volume: ticker.volume, high: ticker.high)
//                self.watchlist = try CoreDataManager.shared.fetch(entity: "WatchListItem") as? [WatchListItem]
//            } catch let err {
//                NSLog(err.localizedDescription, "")
//            }
//        }
//    }
    
    func addItemToWatchlist(indexPath: IndexPath) {
        guard let exchange = self.currentExchange else {
            NSLog("currentExchange is nill", "")
            return
        }
        guard let session = self.session else {
            NSLog("SearchCollectionViewCellDelegate, no session", "")
            return
        }
        guard let user_id = self.user_id else {
            NSLog("SearchCollectionViewCellDelegate, no user id", "")
            return
        }
        guard let item_name = self.filteredSearchData?[indexPath.row].Code else {
            NSLog("SearchCollectionViewCellDelegate, invalid item name.", "")
            return
        }
        APIManager.shared.addItemToWatchlist(user_id: user_id, session: session, item_name: item_name + ".\(exchange)", onFailure: { title, body in
            DispatchQueue.main.async {
                self.showPopUp.send(PopUpCombine(title: title, body: body))
            }
        }, onSuccess: {
            var params: [String] = []
            params.append(item_name)
            
            APIManager.shared.getWatchlistData(user_id: user_id, session: session, onFailure: { title, body in
                NSLog("Error \(title), \(body)", "")
            }, onSuccess: { data in
                DispatchQueue.main.async {
                    self.saveData(with: data)
                    self.changeUI.send()
                }
            })
            
        })
    }
    
    func setCollectionViewDataType(with type: WatchlistCollectionViewDataType) {
        self.collectionViewDataType = type
    }
    
    func filterSearchData(with string: String?) {
        guard let searchData = searchData, let string = string else {
            NSLog("filterSearchData, No searchData", "")
            return
        }
        if string == "" {
            self.filteredSearchData = self.searchData
        } else {
            self.filteredSearchData = searchData.filter { data in
                return data.Name.contains(string)
            }
        }
        self.reloadData.send()
    }
}
