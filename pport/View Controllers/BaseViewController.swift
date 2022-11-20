//
//  BaseViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 10.02.2022.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    func showPopUp(title: String, body: String) {
        
        self.hideKeyboard()
        
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default) { (_) in }
        alert.addAction(closeAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showPopUp(title: String, body: String, completion: @escaping ()->() ) {
        
        self.hideKeyboard()
        
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let closeAction = UIAlertAction(title: "Close", style: .default) { (_) in }
        alert.addAction(closeAction)
        present(alert, animated: true, completion: completion)
    }
    
    func showWatchlistDeletePopUp(title: String, body: String, remove: @escaping ()->Void) {
        
        self.hideKeyboard()
        
        let alert = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { _ in
            remove()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showAddPortfolioPopUp(currency: @escaping ()->Void, ticker: @escaping ()->Void) {
        
        self.hideKeyboard()
        
        let alert = UIAlertController(title: "Add to Portoflio", message: "Please select one of the following to proceed.", preferredStyle: .actionSheet)
        let addToWalletAction = UIAlertAction(title: "Currency", style: .default) { _ in
            currency()
        }
        let addToPortfolioAction = UIAlertAction(title: "Ticker", style: .default) { _ in
            ticker()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alert.addAction(addToWalletAction)
        alert.addAction(addToPortfolioAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
