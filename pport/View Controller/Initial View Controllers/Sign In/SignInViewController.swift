//
//  SignInViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 27.01.2022.
//

import Foundation
import UIKit

class SignInViewController: InitialBaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        passwordTextField.autocorrectionType = .no
        passwordTextField.enablePasswordToggle()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        scrollView.isScrollEnabled = false
    }
    
    @IBAction func goBackBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func singInBtnTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showPopUp(title: "Missing Infirmation", body: "Please enter all informations.")
            return
        }
        if email.count == 0 || password.count == 0 {
            showPopUp(title: "Missing Infirmation", body: "Please enter all informations.")
            return
        }
        
        APIManager.shared.signIn(email: email, password: password, onFailure: { title, body in
            DispatchQueue.main.async {
                self.showPopUp(title: title, body: body)
            }
        }, onSuccess: { data in
            let defaults = UserDefaults.standard
            
            defaults.set(data.body.session, forKey: "session")
            defaults.set(data.body.user_id, forKey: "user_id")
            
            let attributes = [
                "name": data.body.name,
                "surname": data.body.surname,
                "email": data.body.email,
                "session": data.body.session,
                "user_id": data.body.user_id
            ] as [String : Any]
            UserDefaultsManager.shared.set(params: attributes)
            NSLog("Profile saved to UserDefaults succesfully.", "")
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "TabControllers", bundle: nil)
                let controller = storyboard.instantiateViewController(identifier: "NavigationMenuBaseController") as! NavigationMenuBaseController
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller)
            }
        })
    }
    
    @IBAction func forgetPasswordBtnTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "ForgetPasswordViewController") as! ForgetPasswordViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.isScrollEnabled = true
        scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        scrollView.isScrollEnabled = false
    }
}

extension SignInViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if scrollView.contentOffset.y != (textField.superview?.frame.origin.y)! {
            scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
        }
    }
}
