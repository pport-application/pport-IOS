//
//  SignInViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 27.01.2022.
//

import Foundation
import UIKit

class SignInViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var forgetPasswordBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
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
    
    @IBAction func signInBtnTapped(_ sender: Any) {
        
        guard let email = self.emailTextField.text, let password = self.passwordTextField.text else {
            self.showPopUp(title: "Missing Infirmation", body: "Please enter all informations")
            return
        }
        if email.count == 0 || password.count == 0 {
            self.showPopUp(title: "Missing Infirmation", body: "Please enter all informations")
            return
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.signIn(email: email, password: password, onFailure: { title, body in
                DispatchQueue.main.async {
                    self.showPopUp(title: title, body: body)
                }
            }, onSuccess: { data in
                
                KeyChainManager.shared.save(Session(session: data.session), service: .session)
                KeyChainManager.shared.save(Token(token: data.token), service: .token)
                
                let attributes = [
                    "name": data.name,
                    "surname": data.surname,
                    "email": data.email,
                    "watchlist": data.watchlist
                ] as [String : Any]
                UserDefaultsManager.shared.set(params: attributes)
                NSLog("SignInViewController.signInBtnTapped: Profile saved to UserDefaults succesfully", "")
                
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "TabControllers", bundle: nil)
                    let controller = storyboard.instantiateViewController(identifier: "NavigationMenuBaseController") as! NavigationMenuBaseController
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(controller)
                }
            })
        }, notAvailable: {
            self.showPopUp(title: "No Network", body: "Please check your network connection.")
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
