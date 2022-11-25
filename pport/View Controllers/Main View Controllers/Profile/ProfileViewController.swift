//
//  ProfileViewController.swift
//  pport
//
//  Created by Akmuhammet Ashyralyyev on 20.11.2021.
//

import Foundation
import UIKit
import CoreData
import Combine

struct ProfileCombine {
    var name: String
    var surname: String
    var email: String
}

enum ProfileMode: String {
    case view
    case settings
    case edit
}

class ProfileViewController: BaseViewController {
    
    @IBOutlet weak var settingsANDeditImageView: UIImageView!
    @IBOutlet weak var settingsANDeditBtn: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var settingsStackView: UIStackView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var changePasswordBtn: UIButton!
    @IBOutlet weak var saveANDlogoutBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var profileVM: ProfileViewModel = ProfileViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        self.cancellables.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setProfileInfo()
    }
    
    private func setUI() {
        self.profileImageView.layer.cornerRadius = 45
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.shadowColor = UIColor.black.cgColor
        self.profileImageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.profileImageView.layer.shadowOpacity = 0.5
        
        self.profileImageView.layer.cornerRadius = 15
        self.settingsANDeditImageView.layer.cornerRadius = 15
        
        self.settingsANDeditImageView.image = UIImage(systemName: "gearshape")
        self.profileImageView.image = UIImage(systemName: "person.circle")
        
        self.settingsANDeditBtn.setTitle("", for: .normal)
        self.editProfileBtn.layer.cornerRadius = 8
        self.changePasswordBtn.layer.cornerRadius = 8
        
        self.nameTextField.delegate = self
        self.surnameTextField.delegate = self
        self.nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.surnameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        self.emailTextField.isEnabled = false
        self.scrollView.isScrollEnabled = false
        
        self.addListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.profileVM.change(mode: .view)
    }
    
    func addListeners() {
        self.profileVM.updateUI
            .receive(on: DispatchQueue.main)
            .sink{
                self.updateUI()
            }.store(in: &cancellables)
        
        self.profileVM.logout
            .receive(on: DispatchQueue.main)
            .sink {
                self.logout()
            }.store(in: &cancellables)
        
        self.profileVM.setProfile
            .receive(on: DispatchQueue.main)
            .sink { data in
                self.setProfileText(with: data)
            }.store(in: &cancellables)
    }
    
    @IBAction func editBtnTapped(_ sender: Any) {
        switch self.profileVM.mode {
        case .view:
            self.profileVM.change(mode: .settings)
        case .settings:
            self.profileVM.change(mode: .view)
        case .edit:
            self.profileVM.change(mode: .view)
        }
    }
    
    @IBAction func editProfileBtnTapped(_ sender: Any) {
        self.profileVM.change(mode: .edit)
    }
    
    @IBAction func changePasswordBtnTapped(_ sender: Any) {
        let controller = self.storyboard?.instantiateViewController(identifier: "ChangePasswordViewController") as! ChangePasswordViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func saveANDlogoutBtnTapped(_ sender: Any) {
        self.profileVM.saveANDlogutBtnTapped()
    }
    
    func updateUI() {
        self.nameTextField.endEditing(true)
        self.surnameTextField.endEditing(true)
        self.scrollView.isScrollEnabled = false
        
        switch self.profileVM.mode {
        case .view:
            if self.infoStackView.isHidden {
                self.infoStackView.isHidden = false
            }
            if !self.settingsStackView.isHidden {
                self.settingsStackView.isHidden = true
            }
            self.nameTextField.isEnabled = false
            self.surnameTextField.isEnabled = false
            self.saveANDlogoutBtn.setTitle("Error", for: .normal)
            if !self.saveANDlogoutBtn.isHidden {
                self.saveANDlogoutBtn.isHidden = true
            }
        case .settings:
            if !self.infoStackView.isHidden {
                self.infoStackView.isHidden = true
            }
            if self.settingsStackView.isHidden {
                self.settingsStackView.isHidden = false
            }
            self.saveANDlogoutBtn.setTitle("LOGOUT", for: .normal)
            if self.saveANDlogoutBtn.isHidden {
                self.saveANDlogoutBtn.isHidden = false
            }
        case .edit:
            if self.infoStackView.isHidden {
                self.infoStackView.isHidden = false
            }
            if !self.settingsStackView.isHidden {
                self.settingsStackView.isHidden = true
            }
            self.nameTextField.isEnabled = true
            self.surnameTextField.isEnabled = true
            self.saveANDlogoutBtn.setTitle("SAVE", for: .normal)
            if self.saveANDlogoutBtn.isHidden {
                self.saveANDlogoutBtn.isHidden = false
            }
        }
    }
    
    func logout() {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.returnWelcomePageViewController()
    }
}

extension ProfileViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.scrollView.isScrollEnabled = true
        self.scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        self.scrollView.isScrollEnabled = false
    }
}

extension ProfileViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if self.scrollView.contentOffset.y != (textField.superview?.frame.origin.y)! {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
        }
    }
}

extension ProfileViewController {
    
    func setProfileInfo() {
        self.profileVM.setProfileInfo()
    }
    
    func setProfileText(with data: ProfileCombine) {
        self.nameTextField.text = data.name
        self.surnameTextField.text = data.surname
        self.emailTextField.text = data.email
    }
}
