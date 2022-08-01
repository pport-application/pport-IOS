//
//  UITextFieldExtension.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 30.01.2022.
//

import UIKit

extension UITextField {
    
    func enablePasswordToggle() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(togglePasswordView), for: .touchUpInside)
        rightView = button
        rightViewMode = .always
        button.alpha = 0.4
    }
    
    @objc func togglePasswordView(_ sender: Any) {
        let button = sender as! UIButton
        isSecureTextEntry.toggle()
        button.isSelected.toggle()
    }
    
    func setLeftPaddingPoints(_ amount: CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
}
