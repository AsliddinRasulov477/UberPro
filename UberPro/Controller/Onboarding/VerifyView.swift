//
//  VerifyController.swift
//  Uber
//
//  Created by Asliddin Rasulov on 14/12/20.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol VerifyViewDelegate: AnyObject {
    func handleNext()
    func handleEdit()
}

class VerifyView: UIView {
    
    // MARK: - Properties
    
    private var phone: String = ""
    private var params: [String: Any] = [:]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "enter_code".localized
        label.textColor = .label
        label.font = .systemFont(ofSize: 30, weight: .bold)
        return label
    }()
    
    private lazy var phoneNumberContainerView: UIView = {
        let view = UIView().inputContainerView(
            image: #imageLiteral(resourceName: "phone"), textField: phoneNumberTextField
        )
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let editButton = UIButton()
        editButton.setTitle("edit".localized, for: .normal)
        editButton.setTitleColor(#colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1), for: .normal)
        editButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        editButton.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        view.addSubview(editButton)
        editButton.anchor(right: view.rightAnchor, paddingRight: 20)
        editButton.centerY(inView: view)
        
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "password"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let phoneNumberTextField: UITextField = {
        var textField = UITextField()
        textField = textField.textField()
        textField.isEnabled = false
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        var textField = UITextField()
        textField = textField.textField(
            withPlaceholder: "code".localized
        )
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = "mardex_message".localized
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)
        button.setTitle("next_verify".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    weak var delegate: VerifyViewDelegate?
    
    
    // MARK: - Lifecycle
    
    init(params: [String: Any], phone: String, frame: CGRect) {
        super.init(frame: frame)
        self.params = params
        self.phone = phone
        
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(tappedView)
        )
        addGestureRecognizer(tap)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Helper Functions
    
    func configureUI() {
        backgroundColor = .secondarySystemBackground
        
        addSubview(titleLabel)
        titleLabel.anchor(top: safeAreaLayoutGuide.topAnchor, paddingTop: 50)
        titleLabel.centerX(inView: self)
        
        let stack = UIStackView(arrangedSubviews: [phoneNumberContainerView,
                                                   passwordContainerView])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        
        addSubview(stack)
        stack.anchor(
            top: titleLabel.bottomAnchor, left: leftAnchor,
            right: rightAnchor, paddingTop: 30, paddingLeft: 16,
            paddingRight: 16
        )
        
        phoneNumberTextField.text = phone
        
        addSubview(infoLabel)
        infoLabel.anchor(
            top: stack.bottomAnchor, left: stack.leftAnchor, right: stack.rightAnchor,
            paddingTop: 30
        )
        infoLabel.centerX(inView: self)
        
        addSubview(nextButton)
        nextButton.addTarget(
            self, action: #selector(handleNext), for: .touchUpInside
        )
        nextButton.anchor(
            top: infoLabel.bottomAnchor, paddingTop: 20,
            width: 100, height: 50
        )
        nextButton.centerX(inView: self)
        
    }
    
    
    // MARK: - Selectors
    
    @objc func tappedView() {
        passwordTextField.resignFirstResponder()
    }
    
    @objc func handleNext() {
        passwordTextField.resignFirstResponder()
        if passwordTextField.text != "" {
            DispatchQueue.main.async {
                self.postUserSignUp(parameters: self.params) { (json) in
                    if json["success"] == true {
                        UserDefaults.standard.setValue(
                            json["data"]["_id"].string, forKey: "ID"
                        )
                        UserDefaults.standard.setValue(
                            json["token"].string, forKey: "TOKEN"
                        )
                    }
                }
                self.removeFromSuperview()
                self.delegate?.handleNext()
            }
            
        } else {
            passwordTextField.becomeFirstResponder()
        }
    }
    
    @objc func handleEdit() {
        UIView.animate(withDuration: 0.3) {
            self.delegate?.handleEdit()
            self.removeFromSuperview()
        }
    }
    
    // MARK: - API
    
    func postUserSignUp(parameters: [String: Any], comletion: @escaping(JSON) -> Void) {
        let headers: HTTPHeaders = [
            .contentType("application/json")
        ]
        AF.request(
            "http://167.99.33.2/api/users/signup", method: .post, parameters: parameters,
            encoding: JSONEncoding.default, headers: headers
        ).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                comletion(json)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
