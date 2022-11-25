//
//  ResetPasswordViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 10.02.2022.
//

import Foundation
import UIKit

class ResetPasswordViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var email: String?
    var reset_code: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        passwordTextField.enablePasswordToggle()
        confirmPasswordTextField.enablePasswordToggle()
        
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        scrollView.isScrollEnabled = false
    }
    
    @IBAction func resetPasswordBtnTapped(_ sender: Any) {
        guard let password = passwordTextField.text,
              let passwordConfirm = confirmPasswordTextField.text,
              let email = email,
              let reset_code = reset_code else {
                  return
              }
        if !password.isValid(type: .password) {
            showPopUp(title: "Invalid Password", body: "Your password must be at least 8 charecters and contain one digit, special charecter, uppercase and lowercase chareters")
            return
        }
        if password != passwordConfirm {
            showPopUp(title: "Mismatching Passwords", body: "Please make sure that your passwords are same")
            return
        }
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.changePassword(email: email, reset_code: reset_code, password1: password, password2: passwordConfirm, onFailure: { title, body in
                DispatchQueue.main.async {
                    self.showPopUp(title: title, body: body)
                }
            }, onSuccess: {
                DispatchQueue.main.async {
                    self.showPopUp(title: "Success", body: "The password has been succesfully changed")
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.returnWelcomePageViewController()
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

// MARK: - Delegate Implementation
extension ResetPasswordViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.isScrollEnabled = true
        scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        scrollView.isScrollEnabled = false
    }
}

extension ResetPasswordViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if scrollView.contentOffset.y != (textField.superview?.frame.origin.y)! {
            scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
        }
    }
}
