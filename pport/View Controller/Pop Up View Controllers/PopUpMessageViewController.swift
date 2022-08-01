//
//  PopUpMessageViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 31.01.2022.
//

import Foundation
import UIKit

class PopUpMessageViewController: UIViewController {
    
    var delegate: PopUpMessageViewControllerDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var popUpView: UIView!
    
    var titleText: String? = nil
    var bodyText: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isOpaque = false
        view.backgroundColor = .clear
        
        popUpView.backgroundColor = .white
        
        popUpView.layer.cornerRadius = 8
        bodyLabel.numberOfLines = 0
        bodyLabel.lineBreakMode = .byWordWrapping
        bodyLabel.sizeToFit()
        
        titleLabel.text = titleText
        bodyLabel.text = bodyText
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        let _ = delegate?.dismiss(animated: true, input: nil)
    }
    
    func setTexts(title: String, body: String) {
        titleText = title
        bodyText = body
    }
}
