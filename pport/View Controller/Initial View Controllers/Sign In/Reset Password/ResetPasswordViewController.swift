//
//  ResetPasswordViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 10.02.2022.
//

import Foundation
import UIKit

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    var grayCoverView: UIView?
    
    var email: String?
    var reset_code: Int?
    
    var isCompleted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
        
        passwordTextField.autocorrectionType = .no
        passwordTextField.enablePasswordToggle()
        confirmPasswordTextField.autocorrectionType = .no
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
                  NSLog("resetPasswordBtnTapped, missing information.", "")
                  return
              }
        if !password.isValid(type: .password) {
            showPopUp(title: "Invalid Password", body: "Your password must be at least 8 charecters and contain one digit, special charecter, uppercase and lowercase chareters.")
            return
        }
        if password != passwordConfirm {
            showPopUp(title: "Mismatching Passwords", body: "Please make sure that your passwords are same.")
            return
        }
        
        APIManager.shared.changePassword(email: email, reset_code: reset_code, password: password, onFailure: { title, body in
            DispatchQueue.main.async {
                self.showPopUp(title: title, body: body)
                return
            }
        }, onSuccess: {
            DispatchQueue.main.async {
                self.isCompleted = true
                self.showPopUp(title: "Successful Operation", body: "The password has been succesfully changed.")
                return
            }
        })
    }
    
    @IBAction func goBackBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showPopUp(title: String, body: String) {
        
        self.hideKeyboard()
        
        if grayCoverView == nil {
            grayCoverView = UIView(frame: UIScreen.main.bounds)
            grayCoverView!.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
        self.view.addSubview(grayCoverView!)

        let storyboard = UIStoryboard(name: "PopUp", bundle: nil)
        let controller = storyboard.instantiateViewController(identifier: "PopUpMessageViewController") as! PopUpMessageViewController
        controller.modalPresentationStyle = .overCurrentContext
        controller.setTexts(title: title, body: body)
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
}

// MARK: - Delegate Implementation

extension ResetPasswordViewController: PopUpMessageViewControllerDelegate {
    func dismiss(animated: Bool, input: String?) {
        self.dismiss(animated: animated) {
            if self.grayCoverView != nil {
                self.grayCoverView!.removeFromSuperview()
                self.grayCoverView = nil
            }
            
            if self.isCompleted {
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.returnWelcomePageViewController()
                return
            }
        }
    }
}

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
