//
//  PortfolioViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.11.2021.
//

import Foundation
import UIKit
import Combine

enum PortfolioAfterPopUpNavigation {
    case cash
    case ticker
}

enum PortfolioCollectionViewDataType {
    case portfolio
    case history
}

class PortfolioViewController: BaseViewController {
    
    
    @IBOutlet weak var portfolioCollectionView: UICollectionView!
    @IBOutlet weak var addToWalletBtn: UIButton!
    @IBOutlet weak var portfolioHistoryBtn: UIButton!
    
    var portfolioVM: PortfolioViewModel = PortfolioViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        self.cancellables.forEach { $0.cancel() }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
    }
    
    private func setUI() {
        let nibPCVC = UINib(nibName: "PortfolioCollectionViewCell", bundle: .main)
        portfolioCollectionView.register(nibPCVC, forCellWithReuseIdentifier: "PortfolioCollectionViewCell")
        let nibHPCVC = UINib(nibName: "HistoryPortfolioCollectionViewCell", bundle: .main)
        portfolioCollectionView.register(nibHPCVC, forCellWithReuseIdentifier: "HistoryPortfolioCollectionViewCell")
        let nibHWCVC = UINib(nibName: "HistoryWalletCollectionViewCell", bundle: .main)
        portfolioCollectionView.register(nibHWCVC, forCellWithReuseIdentifier: "HistoryWalletCollectionViewCell")
        portfolioCollectionView.delegate = self
        portfolioCollectionView.dataSource = self
        portfolioCollectionView.reloadData()
        
        addToWalletBtn.setTitle("", for: .normal)
        portfolioHistoryBtn.setTitle("", for: .normal)
        
        addListeners()
        self.portfolioVM.initData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func addListeners() {
        
        self.portfolioVM.reloadData
            .receive(on: DispatchQueue.main)
            .sink {
                self.portfolioCollectionView.reloadData()
            }.store(in: &cancellables)
    }
        
    
    @IBAction func addToWalletBtnTapped(_ sender: Any) {
//        let controller = self.storyboard?.instantiateViewController(identifier: "AddPortfolioPopUpViewController") as! AddPortfolioPopUpViewController
//        controller.modalPresentationStyle = .overCurrentContext
//        controller.delegate = self
//        present(controller, animated: true, completion: nil)
        showAddPortfolioPopUp(currency: {
            NSLog("Currency is tapped", "")
        }, ticker: {
            NSLog("Ticker is tapped", "")
        })
    }
    
    
    @IBAction func portfolioHistoryBtnTapped(_ sender: Any) {
        // TODO:
        if self.portfolioVM.collectionViewDataType == .portfolio {
            self.portfolioVM.setCollectionViewDataType(with: .history)
            self.portfolioCollectionView.reloadData()
        } else {
            self.portfolioVM.setCollectionViewDataType(with: .portfolio)
            self.portfolioCollectionView.reloadData()
        }
    }
    
}

extension PortfolioViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // do nothing
    }
}

extension PortfolioViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.portfolioVM.collectionViewDataType {
        case .portfolio:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PortfolioCollectionViewCell", for: indexPath) as! PortfolioCollectionViewCell
            // update cell
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
        case .history:
            if let historyItem = self.portfolioVM.history?[indexPath.row], let from = historyItem.from {
                if from == "wallet" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryWalletCollectionViewCell", for: indexPath) as! HistoryWalletCollectionViewCell
                    cell.setItem(with: historyItem)
                    // update cell
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
                } else if from == "portfolio" {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryPortfolioCollectionViewCell", for: indexPath) as! HistoryPortfolioCollectionViewCell
                    cell.setItem(with: historyItem)
                    // update cell
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
        return UICollectionViewCell()
    }
}

extension PortfolioViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch self.portfolioVM.collectionViewDataType {
        case .portfolio:
            return 0
        case .history:
            return self.portfolioVM.history?.count ?? 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch self.portfolioVM.collectionViewDataType {
        case .portfolio:
            // TODO: Set for portolfio cell
            return CGSize(width: self.portfolioCollectionView.frame.width-16, height: 160)
        case .history:
            // TODO: Change height for wallet and portfolio
            if let historyItem = self.portfolioVM.history?[indexPath.row], let from = historyItem.from {
                if from == "wallet" {
                    return CGSize(width: self.portfolioCollectionView.frame.width-16, height: 130)
                } else if from == "portfolio" {
                    return CGSize(width: self.portfolioCollectionView.frame.width-16, height: 174)
                }
            }
            return CGSize(width: self.portfolioCollectionView.frame.width-16, height: 100)
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
