//
//  PortfolioDepositCurrencyViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 24.03.2022.
//

import Foundation
import UIKit

class PortfolioDepositCurrencyViewController: BaseViewController {
    
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var currencyTableView: UITableView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var backBtn: UIButton!
    
    private var currencies: [CurrencyCodeData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        currencyTextField.delegate = self
        
        backBtn.setTitle("", for: .normal)
        
        currencyTableView.allowsSelection = true
        currencyTableView.isUserInteractionEnabled = true
        
        currencyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        currencyTableView.delegate = self
        currencyTableView.dataSource = self
        currencyTableView.reloadData()
    }
    
    func setCurrencies(with data: [CurrencyCodeData]) {
        self.currencies = data
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addBtnTapped(_ sender: Any) {
        
    }
    
    
}

extension PortfolioDepositCurrencyViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = currencyTableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        cell.textLabel?.text = currencies?[indexPath.row].Code ?? "---"
        return cell
    }
}

extension PortfolioDepositCurrencyViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currencyTextField.text = self.currencies?[indexPath.row].Code ?? ""
        self.currencyTableView.isHidden = false
    }
    
}

extension PortfolioDepositCurrencyViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case currencyTextField:
            self.currencyTableView.isHidden = false
        case amountTextField:
            self.currencyTableView.isHidden = true
        default:
            self.currencyTableView.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.currencyTableView.isHidden = true
    }
}
