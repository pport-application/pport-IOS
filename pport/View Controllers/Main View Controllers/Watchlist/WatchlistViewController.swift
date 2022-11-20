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

class WatchlistViewController: BaseViewController {
    
    @IBOutlet weak var watchlistCollectionView: UICollectionView!
    @IBOutlet weak var searchBarStackView: UIStackView!
    @IBOutlet weak var searchBarTextField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var exchangePickerUIView: UIView!
    @IBOutlet weak var exchangePickerView: UIPickerView!
    
    private var watchlistVM: WatchlistViewModel = WatchlistViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        self.cancellables.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    private func setUI() {
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
        
        watchlistCollectionView.delegate = self
        setupLongGestureRecognizerOnCollection()
        
        // Init picker view
        self.exchangePickerView.delegate = self
        self.exchangePickerView.dataSource = self
        self.exchangePickerUIView.isHidden = true
        
        self.exchangePickerUIView.layer.masksToBounds = false
        self.exchangePickerUIView.layer.cornerRadius = 8
        self.exchangePickerUIView.layer.borderWidth = 1
        self.exchangePickerUIView.layer.borderColor = UIColor.clear.cgColor
        
        self.exchangePickerUIView.layer.shadowColor = UIColor.systemGray3.cgColor
        self.exchangePickerUIView.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.exchangePickerUIView.layer.shadowRadius = 3
        self.exchangePickerUIView.layer.shadowOpacity = 0.5
        self.exchangePickerUIView.layer.shadowOffset = .zero
        self.exchangePickerUIView.layer.shadowPath = UIBezierPath(rect: self.exchangePickerUIView.bounds).cgPath
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
        self.watchlistVM.deleteTickerFromCV
            .receive(on: DispatchQueue.main)
            .sink{ indexPath in
                if indexPath.row == -1 && indexPath.section == -1{
                    return
                }
                self.watchlistCollectionView.deleteItems(at: [indexPath])
            }.store(in: &cancellables)
        self.watchlistVM.reloadPicker
            .receive(on: DispatchQueue.main)
            .sink{
                self.exchangePickerView.reloadAllComponents()
            }.store(in: &cancellables)
    }
    
    @IBAction func searchBarBtnTapped(_ sender: Any) {
        changeUI()
    }
    
    @IBAction func cancelToolBarBtnTapped(_ sender: Any) {
        self.exchangePickerUIView.isHidden = true
    }
    

    @IBAction func doneToolBarBtnTapped(_ sender: Any) {
        self.exchangePickerUIView.isHidden = true
        let row = self.exchangePickerView.selectedRow(inComponent: 0)
        guard let exchange = self.watchlistVM.exchanges?[row].Code else {
            return
        }
        self.watchlistVM.initSearchData(with: exchange)
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
        self.exchangePickerUIView.isHidden = false
    }
    
    private func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        watchlistCollectionView?.addGestureRecognizer(longPressedGesture)
    }

    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if (gestureRecognizer.state != .began) {
            return
        }
        let p = gestureRecognizer.location(in: watchlistCollectionView)

        if let indexPath = watchlistCollectionView?.indexPathForItem(at: p), let ticker = self.watchlistVM.watchlist?[indexPath.row].code {
            self.showWatchlistDeletePopUp(title: "Confirmation",
                                          body: "Please confirm your removal of ticker \(ticker) from your watchlist",
                                          remove: {
                self.watchlistVM.removeItemFromWatchlist(indexPath: indexPath)
            })
        }
    }
}

extension WatchlistViewController: UIGestureRecognizerDelegate {

}

// MARK: Picker View elements
extension WatchlistViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // do nothing
    }
}

extension WatchlistViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.watchlistVM.exchanges?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let exchange = self.watchlistVM.exchanges?[row] else {
            NSLog("fail loading from exchanges", "")
            return ""
        }
        return exchange.Code + ", " + exchange.Country
    }
}

// MARK: Collection View elements
extension WatchlistViewController: UICollectionViewDelegate {

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

            cell.layer.shadowColor = UIColor.black.cgColor
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

            cell.layer.shadowColor = UIColor.black.cgColor
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

// MARK: TextField element

extension WatchlistViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.watchlistVM.filterSearchData(with: textField.text)
    }
}

// MARK: Search exchanges elemenets

extension WatchlistViewController: SearchCollectionViewCellDelegate {
    
    func didSelected(indexPath: IndexPath) {
        self.watchlistVM.addItemToWatchlist(indexPath: indexPath)
    }
}
