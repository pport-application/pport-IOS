//
//  ChangePasswordViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 24.11.2022.
//

import Foundation
import UIKit

class ChangePasswordViewController: BaseViewController {
    
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    
    private var session: String?
    private var token: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.initData()
    }
    
    private func setUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.oldPasswordTextField.enablePasswordToggle()
        self.newPasswordTextField.enablePasswordToggle()
        self.confirmNewPasswordTextField.enablePasswordToggle()
    }
    
    private func initData() {
        if let token = KeyChainManager.shared.read(service: .token, type: Token.self) {
            self.token = token.token
        }
        if let session = KeyChainManager.shared.read(service: .session, type: Session.self) {
            self.session = session.session
        }
    }
    
    @IBAction func changePasswordBtnTapped(_ sender: Any) {
        guard let oldPassword = self.oldPasswordTextField.text,
              let newPassword = self.newPasswordTextField.text,
              let confirmNewPassword = self.confirmNewPasswordTextField.text,
              let session = self.session,
              let token = self.token else {
                  return
              }
        if !newPassword.isValid(type: .password) {
            self.showPopUp(title: "Invalid Password", body: "Your password must be at least 8 charecters and contain one digit, special charecter, uppercase and lowercase chareters")
            return
        }
        if newPassword != confirmNewPassword {
            self.showPopUp(title: "Mismatching Passwords", body: "Please make sure that your passwords are same")
            return
        }
        
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.updatePassword(token: token, session: session, old_password: oldPassword, new_password: newPassword, new_password_confirm: confirmNewPassword, onFailure: { title, body in
                DispatchQueue.main.async {
                    self.showPopUp(title: title, body: body)
                }
            }, onSuccess: {
                DispatchQueue.main.async {
                    self.showPopUp(title: "Success", body: "Password succesfully changed.", completion: {
                        UserDefaultsManager.shared.removeAll()
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.returnWelcomePageViewController()
                    })
                }
            })
        }, notAvailable: {
            self.showPopUp(title: "No Network", body: "Please check your network connection.")
        })
        
    }
    
    @IBAction func goBackBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}


