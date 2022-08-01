//
//  AddPortfolioPopUpViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 23.03.2022.
//

import Foundation
import UIKit

class AddPortfolioPopUpViewController: UIViewController {
    
    var grayCoverView: UIView?
    @IBOutlet weak var popUpView: UIView!
    var delegate: PortfolioViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 8
        
        view.isOpaque = false
        view.backgroundColor = .clear
        popUpView.backgroundColor = .white
        
        grayCoverView = UIView(frame: UIScreen.main.bounds)
        grayCoverView!.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    }
    
    @IBAction func cashBtnTapped(_ sender: Any) {
        guard let delegate = delegate else {
            NSLog("PortfolioViewControllerDelegate is null", "")
            return
        }
        delegate.dismiss(animated: true, navigate: .cash)
    }
    
    @IBAction func newTickerBtnTapped(_ sender: Any) {
        
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        guard let delegate = delegate else {
            NSLog("PortfolioViewControllerDelegate is null", "")
            return
        }
        delegate.dismiss(animated: true, navigate: nil)
    }
}
