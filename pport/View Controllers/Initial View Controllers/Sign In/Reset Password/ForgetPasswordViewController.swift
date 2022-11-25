//
//  ForgetPasswordViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 31.01.2022.
//

import Foundation
import UIKit

class ForgetPasswordViewController: BaseViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        emailTextField.delegate = self
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        scrollView.isScrollEnabled = false
    }
    
    @IBAction func resetPasswordBtnTapped(_ sender: Any) {
        guard let email = emailTextField.text else {
            return
        }
        NetworkManager.shared.check(isAvailable: {
            APIManager.shared.sendResetRequest(email: email, onFailure: { title, body in
                DispatchQueue.main.async {
                    self.showPopUp(title: title, body: body)
                }
            }, onSuccess: {
                DispatchQueue.main.async {
                    self.showPopUp(title: "Email Sent", body: "We have sent a code tou your email account", completion: {
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "ValidateCodeViewController") as! ValidateCodeViewController
                        controller.email = self.emailTextField.text
                        self.navigationController?.pushViewController(controller, animated: true)
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

// MARK: - Delegate Implementation
extension ForgetPasswordViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.isScrollEnabled = true
        scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        scrollView.isScrollEnabled = false
    }
}

extension ForgetPasswordViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if scrollView.contentOffset.y != (textField.superview?.frame.origin.y)! {
            scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
        }
    }
}
