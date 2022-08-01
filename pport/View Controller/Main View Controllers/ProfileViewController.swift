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

class ProfileViewController: InitialBaseViewController {
    
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
    @IBOutlet weak var upgradeToPremiumBtn: UIButton!
    
    @IBOutlet weak var saveANDlogoutBtn: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var profileVM: ProfileViewModel = ProfileViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        self.cancellables.forEach { $0.cancel() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = 45
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.shadowColor = UIColor.black.cgColor
        profileImageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        profileImageView.layer.shadowOpacity = 0.5
        
        profileImageView.layer.cornerRadius = 15
        settingsANDeditImageView.layer.cornerRadius = 15
        
        settingsANDeditImageView.image = UIImage(systemName: "gearshape")
        profileImageView.image = UIImage(systemName: "person.circle")
        
        settingsANDeditBtn.setTitle("", for: .normal)
        editProfileBtn.layer.cornerRadius = 8
        changePasswordBtn.layer.cornerRadius = 8
        upgradeToPremiumBtn.layer.cornerRadius = 8
        
        nameTextField.delegate = self
        surnameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        surnameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        emailTextField.isEnabled = false
        scrollView.isScrollEnabled = false
        
        addListeners()
        setProfileInfo()
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
        print("changePasswordBtnTapped tapped.")
    }
    
    @IBAction func saveANDlogoutBtnTapped(_ sender: Any) {
        self.profileVM.saveANDlogutBtnTapped()
    }
    
    func updateUI() {
        nameTextField.endEditing(true)
        surnameTextField.endEditing(true)
        scrollView.isScrollEnabled = false
        
        switch self.profileVM.mode {
        case .view:
            self.infoStackView.isHidden = false
            self.settingsStackView.isHidden = true
            nameTextField.isEnabled = false
            surnameTextField.isEnabled = false
            saveANDlogoutBtn.setTitle("Error", for: .normal)
            saveANDlogoutBtn.isHidden = true
        case .settings:
            self.infoStackView.isHidden = true
            self.settingsStackView.isHidden = false
            saveANDlogoutBtn.setTitle("LOGOUT", for: .normal)
            saveANDlogoutBtn.isHidden = false
        case .edit:
            self.infoStackView.isHidden = false
            self.settingsStackView.isHidden = true
            nameTextField.isEnabled = true
            surnameTextField.isEnabled = true
            saveANDlogoutBtn.setTitle("SAVE", for: .normal)
            saveANDlogoutBtn.isHidden = false
        }
    }
    
    func logout() {
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.returnWelcomePageViewController()
    }
}

extension ProfileViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.isScrollEnabled = true
        scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        scrollView.isScrollEnabled = false
    }
}

extension ProfileViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if scrollView.contentOffset.y != (textField.superview?.frame.origin.y)! {
            scrollView.setContentOffset(CGPoint(x: 0, y: (textField.superview?.frame.origin.y)!), animated: true)
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
