//
//  SearchBarFilterViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 8.03.2022.
//

import Foundation
import UIKit

class SearchBarFilterViewController: UIViewController {
    
    var delegate: SearchBarFilterViewControllerDelegate?
    @IBOutlet weak var exchangesTableView: UITableView!
    @IBOutlet weak var popUpMainView: UIView!
    var exchanges: [ExchangeData]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isOpaque = false
        view.backgroundColor = .clear
        
        popUpMainView.layer.cornerRadius = 8
        
        exchangesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        exchangesTableView.delegate = self
        exchangesTableView.dataSource = self
        exchangesTableView.reloadData()
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        guard let delegate = self.delegate else {
            NSLog("No delegate in SearchBarFilterViewController", "")
            return
        }
        self.dismiss(animated: true, completion: {
            delegate.dismiss(with: nil)
        })
    }
}

extension SearchBarFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exchanges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = exchangesTableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath)
        cell.textLabel?.text = exchanges[indexPath.row].Name + ", " + exchanges[indexPath.row].Country
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = self.delegate else {
            NSLog("SearchBarFilterViewControllerDelegate is nil", "")
            return
        }
        delegate.dismiss(with: exchanges[indexPath.row])
        self.dismiss(animated: true)
    }
    
}
