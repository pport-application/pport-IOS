//
//  PortfolioViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.11.2021.
//

import Foundation
import UIKit
import Charts

enum PortfolioAfterPopUpNavigation {
    case cash
    case ticker
}

protocol PortfolioViewControllerDelegate {
    func dismiss(animated: Bool, navigate: PortfolioAfterPopUpNavigation?)
}

class PortfolioViewController: InitialBaseViewController {
    
    @IBOutlet weak var entryDataCollectionView: UICollectionView!
    @IBOutlet weak var addToWalletBtn: UIButton!
    @IBOutlet weak var portfolioHistoryBtn: UIButton!
    
    var portfolioVM: PortfolioViewModel = PortfolioViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibPCVC = UINib(nibName: "PortfolioCollectionViewCell", bundle: .main)
        entryDataCollectionView.register(nibPCVC, forCellWithReuseIdentifier: "PortfolioCollectionViewCell")
        let nibPGCVC = UINib(nibName: "PortfolioChartCollectionViewCell", bundle: .main)
        entryDataCollectionView.register(nibPGCVC, forCellWithReuseIdentifier: "PortfolioChartCollectionViewCell")
        entryDataCollectionView.delegate = self
        entryDataCollectionView.dataSource = self
        entryDataCollectionView.reloadData()
        
        addToWalletBtn.setTitle("", for: .normal)
        portfolioHistoryBtn.setTitle("", for: .normal)
        
        self.portfolioVM.initData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func addToWalletBtnTapped(_ sender: Any) {
        NSLog("addToWalletBtnTapped tapped", "")
        self.showGrayCover()
        
        let controller = self.storyboard?.instantiateViewController(identifier: "AddPortfolioPopUpViewController") as! AddPortfolioPopUpViewController
        controller.modalPresentationStyle = .overCurrentContext
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func portfolioHistoryBtnTapped(_ sender: Any) {
        NSLog("portfolioHistoryBtnTapped tapped", "")
    }
    
}

extension PortfolioViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell with indexPath \(indexPath) is selected.")
    }
}

extension PortfolioViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    }
}

extension PortfolioViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: self.entryDataCollectionView.frame.width-16, height: self.entryDataCollectionView.frame.width-16)
        } else {
            return CGSize(width: self.entryDataCollectionView.frame.width-16, height: 60)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
    }
}

extension PortfolioViewController: PortfolioViewControllerDelegate {
    
    func dismiss(animated: Bool, navigate: PortfolioAfterPopUpNavigation? = nil) {
        self.dismiss(animated: animated) {
            self.removeGrayCover()
            guard let navigate = navigate else {
                return
            }
            switch navigate {
            case .cash:
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "PortfolioAddCashViewController") as! PortfolioAddCashViewController
                controller.setCurrencies(with: self.portfolioVM.currencies ?? [])
                self.navigationController?.pushViewController(controller, animated: true)
            case .ticker:
                NSLog("navigate to ticker", "")
            }
        }
    }
}
