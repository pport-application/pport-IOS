//
//  WelcomePageViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 27.01.2022.
//

import Foundation
import UIKit

class WelcomePageViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    @IBAction func signInBtnTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "SignInViewController") as! SignInViewController
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    @IBAction func signUpBtnTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
