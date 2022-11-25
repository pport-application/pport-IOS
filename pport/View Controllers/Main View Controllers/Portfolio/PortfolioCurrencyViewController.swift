//
//  PortfolioCurrencyViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 24.03.2022.
//

import Foundation
import UIKit

enum PortfolioProcessType {
    case deposit
    case withdraw
}

class PortfolioCurrencyViewController: BaseViewController {
    
    
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var currencyTableView: UITableView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    
    private var token: String?
    private var session: String?
    private var currencies: [String?]?
    var type: PortfolioProcessType?
    var delegate: PortfolioDepositWithdrawViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.initUserData()
    }
    
    private func setUI() {
        self.currencyTextField.delegate = self
        
        self.currencyTableView.allowsSelection = true
        self.currencyTableView.isUserInteractionEnabled = true
        
        self.currencyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        self.currencyTableView.delegate = self
        self.currencyTableView.dataSource = self
        self.currencyTableView.reloadData()
        self.currencyTableView.isHidden = true
        if type != nil {
            self.doneBtn.setTitle(type == .deposit ? "DEPOSIT" : "WITHDRAW", for: .normal)
        }
    }
    
    func initUserData() {
        if let token = KeyChainManager.shared.read(service: .token, type: Token.self) {
            self.token = token.token
        }
        if let session = KeyChainManager.shared.read(service: .session, type: Session.self) {
            self.session = session.session
        }
    }
    
    func setType(with type: PortfolioProcessType) {
        self.type = type
    }
    
    func setCurrencies(with data: [String]?) {
        self.currencies = data
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
        guard let token = self.token, let session = self.session, let amount = Float(amountTextField.text ?? ""), let currency = currencyTextField.text, let currencies = self.currencies else {
            return
        }
        if let _ = currencies.firstIndex(of: currency) {
            let timestamp = Date().timeIntervalSince1970
            switch self.type {
            case .deposit:
                NetworkManager.shared.check(isAvailable: {
                    APIManager.shared.depositCurrency(token: token, session: session, currency: currency, amount: amount,  timestamp: timestamp, onFailure: {title, body in
                        DispatchQueue.main.async {
                            self.showPopUp(title: title, body: body)
                        }
                    }, onSuccess: {
                        self.delegate?.updateData()
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }, notAvailable: {
                    self.showPopUp(title: "No Network", body: "Please check your network connection.")
                })
            case .withdraw:
                NetworkManager.shared.check(isAvailable: {
                    APIManager.shared.withdrawCurrency(token: token, session: session, currency: currency, amount: amount,  timestamp: timestamp, onFailure: {title, body in
                        DispatchQueue.main.async {
                            self.showPopUp(title: title, body: body)
                        }
                    }, onSuccess: {
                        self.delegate?.updateData()
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    })
                }, notAvailable: {
                    self.showPopUp(title: "No Network", body: "Please check your network connection.")
                })
            case .none:
                return
            }
        } else {
            self.showPopUp(title: "Invalid Currency", body: "Please enter the currency exists in list.")
        }
    }
}

extension PortfolioCurrencyViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currencies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.currencyTableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        cell.textLabel?.text = self.currencies?[indexPath.row] ?? "---"
        return cell
    }
}

extension PortfolioCurrencyViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currencyTextField.text = self.currencies?[indexPath.row] ?? ""
        if !self.currencyTableView.isHidden {
            self.currencyTableView.isHidden = true
        }
    }
}

extension PortfolioCurrencyViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.currencyTextField:
            if self.currencyTableView.isHidden {
                self.currencyTableView.isHidden = false
            }
        default:
            if !self.currencyTableView.isHidden {
                self.currencyTableView.isHidden = true
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !self.currencyTableView.isHidden {
            self.currencyTableView.isHidden = true
        }
    }
}
