//
//  InitialBaseViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 10.02.2022.
//

import Foundation
import UIKit

class InitialBaseViewController: UIViewController {
    
    var grayCoverView: UIView?
    var popUpMessageDismissCompletion: ( (String?)->Void )?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
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
    
    func showGrayCover() {
        if grayCoverView == nil {
            grayCoverView = UIView(frame: UIScreen.main.bounds)
            grayCoverView!.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        }
        self.view.addSubview(grayCoverView!)
    }
    
    func removeGrayCover() {
        if self.grayCoverView != nil {
            self.grayCoverView!.removeFromSuperview()
            self.grayCoverView = nil
        }
    }
    
}

extension InitialBaseViewController: PopUpMessageViewControllerDelegate {
    
    func dismiss(animated: Bool, input: String?) {
        self.dismiss(animated: animated) {
            if self.grayCoverView != nil {
                self.grayCoverView!.removeFromSuperview()
                self.grayCoverView = nil
            }
            
            if self.popUpMessageDismissCompletion != nil {
                self.popUpMessageDismissCompletion!(input)
            }
            
        }
    }
}
