//
//  SignUpViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 27.01.2022.
//

import Foundation
import UIKit

class SignUpViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var termsAndConditionsLabel: UILabel!
    @IBOutlet weak var termsAndConditionsBtn: UIButton!
    
    private var isAccepted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    
    private func setUI() {
        self.navigationController?.navigationItem.hidesBackButton = true
        
        self.passwordTextField.autocorrectionType = .no
        self.passwordTextField.enablePasswordToggle()
        self.passwordConfirmTextField.autocorrectionType = .no
        self.passwordConfirmTextField.enablePasswordToggle()
        
        
        self.nameTextField.delegate = self
        self.surnameTextField.delegate = self
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.passwordConfirmTextField.delegate = self
        
        self.nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.surnameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.passwordConfirmTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        self.scrollView.isScrollEnabled = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(termsAndConditionsLabelTapped))
        self.termsAndConditionsLabel.isUserInteractionEnabled = true
        self.termsAndConditionsLabel.addGestureRecognizer(tap)
        self.termsAndConditionsLabel.layer.cornerRadius = 8
        self.termsAndConditionsBtn.tintColor = UIColor.gray
    }
    
    @IBAction func goBackBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signUpBtnTapped(_ sender: Any) {
        if !self.isAccepted {
            self.showPopUp(title: "Ups", body: "Please read and agree the Terms and Conditions")
            return
        }
        
        guard let password = passwordTextField.text,
              let passwordConfirm = passwordConfirmTextField.text,
              let name = nameTextField.text,
              let surname = surnameTextField.text,
              let email = emailTextField.text else {
                  showPopUp(title: "Invalid Input", body: "Please enter all informations")
                  return
        }
        if name.count == 0 || surname.count == 0 || email.count == 0 {
            self.showPopUp(title: "Missing Input", body: "Please enter all informations")
            return
        }
        if !password.isValid(type: .password) {
            self.showPopUp(title: "Invalid Password", body: "Your password must be at least 8 charecters and contain one digit, special charecter, uppercase and lowercase chareters")
            return
        }
        if (password != passwordConfirm) {
            self.showPopUp(title: "Mismatching Passwords", body: "Please make sure that your passwords are same")
            return
        }
        if !email.isValid(type: .email) {
            self.showPopUp(title: "Invalid Email", body: "Please enter valid email")
            return
        }
        
        // Establish Communication with backend
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.signUp(name: name, surname: surname, email: email, password1: password.encrypt(), password2: passwordConfirm.encrypt(), onFailure: { title, body in
                DispatchQueue.main.async {
                    self.showPopUp(title: title, body: body)
                }
            }, onSuccess: {
                DispatchQueue.main.async {
                    self.showPopUp(title: "Thank you", body: "You have succesfully registered", completion: {
                        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.returnWelcomePageViewController()
                    })
                }
            })
        }, notAvailable: {
            self.showPopUp(title: "No Network", body: "Please check your network connection.")
        })
    }
    
    @IBAction func termsAndConditionsBtnTapped(_ sender: Any) {
        self.isAccepted = !self.isAccepted
        if self.isAccepted {
            self.termsAndConditionsBtn.tintColor = UIColor.green
        } else {
            self.termsAndConditionsBtn.tintColor = UIColor.gray
        }
    }
    
    @objc func termsAndConditionsLabelTapped() {
        guard let url = URL(string: "https://pport-application.github.io/Licences/eula.html") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: { _ in 
            self.isAccepted = true
            self.termsAndConditionsBtn.tintColor = UIColor.green
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
