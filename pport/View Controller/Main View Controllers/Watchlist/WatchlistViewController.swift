//
//  WatchlistViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.11.2021.
//

import Foundation
import UIKit
import Combine

struct PopUpCombine {
    var title: String
    var body: String
}

enum WatchlistCollectionViewDataType {
    case search
    case watchlist
}

class WatchlistViewController: InitialBaseViewController {
    
    @IBOutlet weak var watchlistCollectionView: UICollectionView!
    @IBOutlet weak var searchBarStackView: UIStackView!
    @IBOutlet weak var searchBarTextField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    
    private var watchlistVM: WatchlistViewModel = WatchlistViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        self.cancellables.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register Cells
        let nibWCVC = UINib(nibName: "WatchlistCollectionViewCell", bundle: .main)
        watchlistCollectionView.register(nibWCVC, forCellWithReuseIdentifier: "WatchlistCollectionViewCell")
        let nibSCVC = UINib(nibName: "SearchCollectionViewCell", bundle: .main)
        watchlistCollectionView.register(nibSCVC, forCellWithReuseIdentifier: "SearchCollectionViewCell")
        
        // Initialize CollectionView Delegates
        watchlistCollectionView.delegate = self
        watchlistCollectionView.dataSource = self
        watchlistCollectionView.reloadData()
        
        // Init UI
        searchBarTextField.borderStyle = .none
        searchBarTextField.layer.cornerRadius = 8
        searchBarTextField.layer.borderWidth = 1
        searchBarTextField.layer.borderColor = UIColor.gray.cgColor
        searchBarTextField.layer.masksToBounds = true
        searchBarStackView.isHidden = true
        searchBarTextField.setLeftPaddingPoints(10)
        searchBarTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchBtn.setTitle("", for: .normal)
        filterBtn.setTitle("", for: .normal)
        
        addListeners()
        self.watchlistVM.initExchangeCodes()
        self.watchlistVM.initWatchlistData()
    }
    
    private func addListeners() {
        self.watchlistVM.showPopUp
            .receive(on: DispatchQueue.main)
            .sink{ popUp in
                if popUp.body == "" && popUp.title == "" {
                    return
                }
                self.showPopUp(title: popUp.title, body: popUp.body)
            }.store(in: &cancellables)
        
        self.watchlistVM.reloadData
            .receive(on: DispatchQueue.main)
            .sink {
                self.watchlistCollectionView.reloadData()
            }.store(in: &cancellables)
        
        self.watchlistVM.changeUI
            .receive(on: DispatchQueue.main)
            .sink {
                self.changeUI()
            }.store(in: &cancellables)
        
    }
    
    @IBAction func searchBarBtnTapped(_ sender: Any) {
        changeUI()
    }
    
    func changeUI() {
        searchBarStackView.isHidden = !searchBarStackView.isHidden
        if !searchBarStackView.isHidden {
            self.watchlistVM.setCollectionViewDataType(with: .search)
            self.watchlistCollectionView.reloadData()
        } else {
            self.watchlistVM.setCollectionViewDataType(with: .watchlist)
            self.watchlistCollectionView.reloadData()
        }
    }
    @IBAction func filterSearchBtnTapped(_ sender: Any) {
        guard let exchanges = self.watchlistVM.exchanges else {
            NSLog("Exchanges is null", "")
            return
        }
        if grayCoverView == nil {
            grayCoverView = UIView(frame: UIScreen.main.bounds)
            grayCoverView!.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
        self.view.addSubview(grayCoverView!)
        let controller = self.storyboard?.instantiateViewController(identifier: "SearchBarFilterViewController") as! SearchBarFilterViewController
        controller.modalPresentationStyle = .overCurrentContext
        controller.delegate = self
        controller.exchanges = exchanges
        present(controller, animated: true, completion: nil)
    }
}

extension WatchlistViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell with indexPath \(indexPath) is selected.")
    }
}

extension WatchlistViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.watchlistVM.collectionViewDataType {
        case .search:
            return self.watchlistVM.filteredSearchData?.count ?? 0
        case .watchlist:
            return self.watchlistVM.watchlist?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.watchlistVM.collectionViewDataType {
        case .search:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as! SearchCollectionViewCell
            if let searchItem = self.watchlistVM.filteredSearchData?[indexPath.row] {
                cell.setLabels(data: searchItem)
            }
            cell.setPath(with: indexPath)
            cell.delegate = self
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.masksToBounds = true

            cell.layer.shadowColor = UIColor.systemGray3.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 4.0)
            cell.layer.shadowRadius = 4
            cell.layer.shadowOpacity = 0.5
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            return cell

        case .watchlist:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchlistCollectionViewCell", for: indexPath) as! WatchlistCollectionViewCell
            if let watchlistItem = self.watchlistVM.watchlist?[indexPath.row] {
                cell.setItem(with: watchlistItem)
            }
            cell.contentView.layer.cornerRadius = 8
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            cell.contentView.layer.masksToBounds = true

            cell.layer.shadowColor = UIColor.systemGray3.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 4.0)
            cell.layer.shadowRadius = 4
            cell.layer.shadowOpacity = 0.5
            cell.layer.masksToBounds = false
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            return cell
        }
    }
}

extension WatchlistViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch self.watchlistVM.collectionViewDataType {
        case .search:
            return CGSize(width: self.watchlistCollectionView.frame.width-16, height: 60)
        case .watchlist:
            return CGSize(width: self.watchlistCollectionView.frame.width-16, height: 90)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
}

extension WatchlistViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.watchlistVM.filterSearchData(with: textField.text)
    }
}

extension WatchlistViewController: SearchCollectionViewCellDelegate {
    
    func didSelected(indexPath: IndexPath) {
        self.watchlistVM.addItemToWatchlist(indexPath: indexPath)
    }
}

extension WatchlistViewController: SearchBarFilterViewControllerDelegate {
    
    func dismiss(with exchange: ExchangeData? = nil) {
        if self.grayCoverView != nil {
            self.grayCoverView!.removeFromSuperview()
            self.grayCoverView = nil
        }
        
        guard let exchange = exchange?.Code else {
            return
        }
        
        self.watchlistVM.initSearchData(with: exchange)
    }
}
