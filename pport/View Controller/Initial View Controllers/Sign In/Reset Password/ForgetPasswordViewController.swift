//
//  ForgetPasswordViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 31.01.2022.
//

import Foundation
import UIKit

class ForgetPasswordViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var grayCoverView: UIView?
    var isCompleted: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
        
        scrollView.isScrollEnabled = false
    }
    
    @IBAction func resetPasswordBtnTapped(_ sender: Any) {
        guard let email = emailTextField.text else {
            return
        }
        APIManager.shared.sendResetRequest(email: email, onFailure: { title, body in
            DispatchQueue.main.async {
                self.showPopUp(title: title, body: body)
                return
            }
        }, onSuccess: {
            DispatchQueue.main.async {
                self.isCompleted = true
                self.showPopUp(title: "Email Sent", body: "We have sent a code tou your email account.")
                return
            }
        })
        
    }
    
    @IBAction func goBackBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
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
}

// MARK: - Delegate Implementation

extension ForgetPasswordViewController: PopUpMessageViewControllerDelegate {
    func dismiss(animated: Bool, input: String?) {
        self.dismiss(animated: animated) {
            if self.grayCoverView != nil {
                self.grayCoverView!.removeFromSuperview()
                self.grayCoverView = nil
            }
            
            if self.isCompleted {
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "ValidateCodeViewController") as! ValidateCodeViewController
                controller.email = self.emailTextField.text
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

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
