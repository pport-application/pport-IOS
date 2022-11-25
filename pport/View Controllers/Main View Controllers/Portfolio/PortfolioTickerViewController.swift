//
//  PortfolioTickerViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 24.03.2022.
//

import Foundation
import UIKit

class PortfolioTickerViewController: BaseViewController {
    
    @IBOutlet weak var tickerTableView: UITableView!
    @IBOutlet weak var tickerTextField: UITextField!
    @IBOutlet weak var exchangeLabel: UILabel!
    @IBOutlet weak var exchangeCodeTextField: UITextField!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var doneBtn: UIButton!
    
    private var token: String?
    private var session: String?
    var type: PortfolioProcessType?
    var delegate: PortfolioDepositWithdrawViewControllerDelegate?
    var portfolio: [Portfolio]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.initUserData()
    }
    
    private func setUI() {
        self.tickerTextField.delegate = self
        self.exchangeCodeTextField.delegate = self
        self.countTextField.delegate = self
        self.costTextField.delegate = self
        self.currencyTextField.delegate = self
        
        self.tickerTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        self.tickerTableView.delegate = self
        self.tickerTableView.dataSource = self
        self.tickerTableView.reloadData()
        self.tickerTableView.isHidden = true
        if self.type != nil {
            self.doneBtn.setTitle(self.type == .deposit ? "DEPOSIT" : "WITHDRAW", for: .normal)
        }
        if self.type != nil && self.type == .withdraw {
            self.currencyTextField.isUserInteractionEnabled = false
            self.exchangeLabel.isHidden = true
            self.exchangeCodeTextField.isHidden = true
        }
    }
    
    private func initUserData() {
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
    
    func setTickers(with tickers: [Portfolio]?) {
        self.portfolio = tickers
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
        guard let token = self.token, let session = self.session, let ticker = self.tickerTextField.text, let count = Float(self.countTextField.text ?? ""), let cost = Float(self.costTextField.text ?? ""), let currency = self.currencyTextField.text else {
            return
        }
        
        let timestamp = Date().timeIntervalSince1970
        switch self.type {
        case .deposit:
            guard let exchange = self.exchangeCodeTextField.text else {
                return
            }
            NetworkManager.shared.check(isAvailable: {
                APIManager.shared.validateTicker(token: token, session: session, ticker: ticker, exchange: exchange, onFailure: { title, body in
                    DispatchQueue.main.async {
                        self.showPopUp(title: title, body: body)
                    }
                }, onSuccess: { result in
                    if result == 1 {
                        APIManager.shared.depositTicker(token: token, session: session, ticker: ticker+"."+exchange, count: count, charge: -cost, currency: currency, timestamp: timestamp, onFailure: { title, body in
                            DispatchQueue.main.async {
                                self.showPopUp(title: title, body: body)
                            }
                        }, onSuccess: {
                            self.delegate?.updateData()
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    } else {
                        DispatchQueue.main.async {
                            self.showPopUp(title: "Invalid Ticker", body: "Please make sure that the ticker and exchange are valid.")
                        }
                    }
                })
            }, notAvailable: {
                self.showPopUp(title: "No Network", body: "Please check your network connection.")
            })
        case .withdraw:
            NetworkManager.shared.check(isAvailable: {
                APIManager.shared.withdrawTicker(token: token, session: session, ticker: ticker, count: count, charge: cost, currency: currency, timestamp: timestamp, onFailure: { title, body in
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
    }
}

extension PortfolioTickerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.portfolio?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tickerTableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        cell.textLabel?.text = self.portfolio?[indexPath.row].ticker ?? "---"
        return cell
    }
}

extension PortfolioTickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tickerTextField.text = self.portfolio?[indexPath.row].ticker ?? ""
        self.currencyTextField.text = self.portfolio?[indexPath.row].currency ?? ""
        if !self.tickerTableView.isHidden {
            self.tickerTableView.isHidden = true
        }
    }
}

extension PortfolioTickerViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case self.tickerTextField:
            if self.tickerTableView.isHidden {
                self.tickerTableView.isHidden = false
            }
        default:
            if !self.tickerTableView.isHidden {
                self.tickerTableView.isHidden = true
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !self.tickerTableView.isHidden {
            self.tickerTableView.isHidden = true
        }
    }
}
