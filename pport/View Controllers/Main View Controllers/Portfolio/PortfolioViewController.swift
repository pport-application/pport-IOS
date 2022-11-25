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
        
        self.setUI()
    }
    
    private func setUI() {
        
        let nibPCVC = UINib(nibName: "PortfolioWalletCollectionViewCell", bundle: .main)
        self.portfolioCollectionView.register(nibPCVC, forCellWithReuseIdentifier: "PortfolioWalletCollectionViewCell")
        let nibPTVC = UINib(nibName: "PortfolioTickerCollectionViewCell", bundle: .main)
        self.portfolioCollectionView.register(nibPTVC, forCellWithReuseIdentifier: "PortfolioTickerCollectionViewCell")
        let nibHPCVC = UINib(nibName: "HistoryPortfolioCollectionViewCell", bundle: .main)
        self.portfolioCollectionView.register(nibHPCVC, forCellWithReuseIdentifier: "HistoryPortfolioCollectionViewCell")
        let nibHWCVC = UINib(nibName: "HistoryWalletCollectionViewCell", bundle: .main)
        self.portfolioCollectionView.register(nibHWCVC, forCellWithReuseIdentifier: "HistoryWalletCollectionViewCell")
        let nibPCVCIH = UINib(nibName: "PortfolioCollectionViewCellInteractiveHeader", bundle: .main)
        self.portfolioCollectionView.register(nibPCVCIH, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PortfolioCollectionViewCellInteractiveHeader")
        self.portfolioCollectionView.delegate = self
        self.portfolioCollectionView.dataSource = self
        self.portfolioCollectionView.reloadData()
        
        self.addToWalletBtn.setTitle("", for: .normal)
        self.portfolioHistoryBtn.setTitle("", for: .normal)
        
        self.addListeners()
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
        self.showTickerCurrencyChoicePopUp(currency: {
            self.showDepositWithdrawChoicePopUp(deposit: {
                let controller = self.storyboard?.instantiateViewController(identifier: "PortfolioCurrencyViewController") as! PortfolioCurrencyViewController
                controller.delegate = self
                controller.setType(with: .deposit)
                controller.setCurrencies(with: self.portfolioVM.currencies?.reduce(into: [String]()) { $0.append( $1.code ?? "--" )})
                self.navigationController?.pushViewController(controller, animated: true)
            }, withdraw: {
                let controller = self.storyboard?.instantiateViewController(identifier: "PortfolioCurrencyViewController") as! PortfolioCurrencyViewController
                controller.delegate = self
                controller.setType(with: .withdraw)
                controller.setCurrencies(with: Array(self.portfolioVM.portfolio?.wallet.keys ?? [:].keys) )
                self.navigationController?.pushViewController(controller, animated: true)
            })
        }, ticker: {
            self.showDepositWithdrawChoicePopUp(deposit: {
                let controller = self.storyboard?.instantiateViewController(identifier: "PortfolioTickerViewController") as! PortfolioTickerViewController
                controller.delegate = self
                controller.setType(with: .deposit)
                self.navigationController?.pushViewController(controller, animated: true)
            }, withdraw: {
                let controller = self.storyboard?.instantiateViewController(identifier: "PortfolioTickerViewController") as! PortfolioTickerViewController
                controller.delegate = self
                controller.setType(with: .withdraw)
                controller.setTickers(with: self.portfolioVM.portfolio?.portfolio ?? [])
                self.navigationController?.pushViewController(controller, animated: true)
            })
        })
    }
    
    @IBAction func portfolioHistoryBtnTapped(_ sender: Any) {
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
            if indexPath.section == 0 {
                if let wallet = self.portfolioVM.portfolio?.wallet  {
                    let currency = Array(wallet)[indexPath.row].0
                    let amount = Array(wallet)[indexPath.row].1
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PortfolioWalletCollectionViewCell", for: indexPath) as! PortfolioWalletCollectionViewCell
                    // update cell
                    cell.setTitle(with: currency, amount: amount)
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
            } else {
                if let portfolio = self.portfolioVM.portfolio?.portfolio  {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PortfolioTickerCollectionViewCell", for: indexPath) as! PortfolioTickerCollectionViewCell
                    // update cell
                    cell.setTitle(with: portfolio[indexPath.row])
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
            if section == 0 {
                return self.portfolioVM.portfolio?.wallet.count ?? 0
            } else {
                return self.portfolioVM.portfolio?.portfolio.count ?? 0
            }
        case .history:
            return self.portfolioVM.history?.count ?? 0
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch self.portfolioVM.collectionViewDataType {
        case .portfolio:
            return 2
        case .history:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch self.portfolioVM.collectionViewDataType {
        case .portfolio:
            if indexPath.section == 0 {
                return CGSize(width: self.portfolioCollectionView.frame.width-16, height: 40)
            } else {
                return CGSize(width: self.portfolioCollectionView.frame.width-16, height: 80)
            }
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.portfolioCollectionView.frame.width-16, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PortfolioCollectionViewCellInteractiveHeader", for: indexPath) as! PortfolioCollectionViewCellInteractiveHeader
        if self.portfolioVM.collectionViewDataType == .portfolio {
            if indexPath.section == 0 {
                sectionHeader.setTitle(with: "Wallet")
            } else {
                sectionHeader.setTitle(with: "Portfolio")
            }
        } else {
            sectionHeader.setTitle(with: "History")
        }
        return sectionHeader
        
    }
}

extension PortfolioViewController: PortfolioDepositWithdrawViewControllerDelegate {
    func updateData() {
        self.portfolioVM.initHistoryData()
        self.portfolioVM.initPortfolioData()
    }
}
