//
//  SignUpViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 27.01.2022.
//

import Foundation
import UIKit
import SwiftyJSON

class SignUpViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        self.navigationController?.navigationItem.hidesBackButton = true
        
        passwordTextField.autocorrectionType = .no
        passwordTextField.enablePasswordToggle()
        passwordConfirmTextField.autocorrectionType = .no
        passwordConfirmTextField.enablePasswordToggle()
        
        
        nameTextField.delegate = self
        surnameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        surnameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        passwordConfirmTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        scrollView.isScrollEnabled = false
    }
    
    @IBAction func goBackBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpBtnTapped(_ sender: Any) {
        // Input validation
        guard let password = passwordTextField.text,
              let passwordConfirm = passwordConfirmTextField.text,
              let name = nameTextField.text,
              let surname = surnameTextField.text,
              let email = emailTextField.text else {
                  showPopUp(title: "Invalid Input", body: "Please enter all informations")
                  return
        }
        if name.count == 0 || surname.count == 0 || email.count == 0 {
            showPopUp(title: "Missing Input", body: "Please enter all informations")
            return
        }
        if !password.isValid(type: .password) {
            showPopUp(title: "Invalid Password", body: "Your password must be at least 8 charecters and contain one digit, special charecter, uppercase and lowercase chareters")
            return
        }
        if (password != passwordConfirm) {
            showPopUp(title: "Mismatching Passwords", body: "Please make sure that your passwords are same")
            return
        }
        if !email.isValid(type: .email) {
            showPopUp(title: "Invalid Email", body: "Please enter valid email")
            return
        }
        
        // Establish Communication with backend
        APIManager.shared.signUp(name: name, surname: surname, email: email, password1: password, password2: passwordConfirm, onFailure: { title, body in
            DispatchQueue.main.async {
                self.showPopUp(title: title, body: body)
            }
        }, onSuccess: {
            DispatchQueue.main.async {
                self.showPopUp(title: "Thank you", body: "You have succesfully registered")
            }
        })
    }
}

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.isScrollEnabled = true
        scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        scrollView.isScrollEnabled = false
    }
}

extension SignUpViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if scrollView.contentOffset.y != (textField.superview?.frame.origin.y)! {
            scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
        }
    }
}
