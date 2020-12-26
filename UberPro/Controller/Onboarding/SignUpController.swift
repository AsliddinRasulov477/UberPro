import UIKit
import Alamofire
import SwiftyJSON

class SignUpController: UIViewController {
    
    // MARK: - Properties
    
    private var location = LocationHandler.shared.locationManager.location
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.setText("mardex", withColorPart: "mard", color: #colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1))
        label.font = UIFont(name: "SpartanMB-Bold", size: 36)
        return label
    }()
    
    private lazy var phoneNumberContainerView: UIView = {
        let view = UIView().inputContainerView(
            image: #imageLiteral(resourceName: "phone"), textField: phoneNumberTextField
        )
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var firstnameContainerView: UIView = {
        let view = UIView().inputContainerView(
            image: #imageLiteral(resourceName: "fullname"), textField: firstnameTextField
        )
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var lastnameContainerView: UIView = {
        let view = UIView().inputContainerView(
            image: #imageLiteral(resourceName: "fullname"), textField: lastnameTextField
        )
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(image: #imageLiteral(resourceName: "password"), textField: passwordTextField)
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        return view
    }()
    
    private let phoneNumberTextField: UITextField = {
        var textField = UITextField()
        textField = textField.textField(
            withPlaceholder: "+998",
            isSecureTextEntry: false
        )
        textField.keyboardType = .phonePad
        return textField
    }()
    
    private let firstnameTextField: UITextField = {
        var textField = UITextField()
        textField = textField.textField(
            withPlaceholder: "first_name".localized,
            isSecureTextEntry: false
        )
        return textField
    }()
    
    private let lastnameTextField: UITextField = {
        var textField = UITextField()
        textField = textField.textField(
            withPlaceholder: "last_name".localized,
            isSecureTextEntry: false
        )
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        var textField = UITextField()
        textField = textField.textField(
            withPlaceholder: "password".localized,
            isSecureTextEntry: true
        )
        return textField
    }()
    
    private let signUpButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("sign_up".localized, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        return button
    }()
    
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "already_have_an_account".localized, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "log_in".localized, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)]))
        
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(
            target: self, action: #selector(tappedView)
        )
        view.addGestureRecognizer(tap)
        
        phoneNumberTextField.delegate = self
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        passwordTextField.delegate = self

        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func handleSignUp() {
        
        phoneNumberTextField.resignFirstResponder()
        firstnameTextField.resignFirstResponder()
        lastnameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let phone = phoneNumberTextField.text, !phone.isEmpty,
              let firstname = firstnameTextField.text, !firstname.isEmpty,
              let lastname = lastnameTextField.text, !lastname.isEmpty,
              let password = passwordTextField.text, !password.isEmpty, password.count >= 8
        else { return }
        
        let coordinate = LocationHandler.shared.locationManager.location?.coordinate
        let location = "\(coordinate?.latitude ?? 41), \(coordinate?.longitude ?? 69)"
        
        
        let params = ["phone": phone,
                      "password": password,
                      "firstName": firstname,
                      "lastName": lastname,
                      "location": location] as [String: Any]
        configureVerifyView(params: params, phone: phone)
    }
    
    
    
    @objc func handleShowLogin() {
        phoneNumberTextField.text = ""
        firstnameTextField.text = ""
        lastnameTextField.text = ""
        passwordTextField.text = ""
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func tappedView() {
        phoneNumberTextField.resignFirstResponder()
        firstnameTextField.resignFirstResponder()
        lastnameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
   
    
    // MARK: - Helper Functions
    
    
    func configureUI() {
        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 10)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [phoneNumberContainerView,
                                                   firstnameContainerView,
                                                   lastnameContainerView,
                                                   passwordContainerView,
                                                   signUpButton])
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(top: titleLabel.bottomAnchor, left: view.leftAnchor,
                     right: view.rightAnchor, paddingTop: 30, paddingLeft: 16,
                     paddingRight: 16)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            paddingBottom: 5, height: 32
        )
    }
    
    func configureVerifyView(params: Parameters, phone: String) {
        let verifyView = VerifyView(
            params: params, phone: phone, frame: .zero
        )
        verifyView.delegate = self
        view.addSubview(verifyView)
        verifyView.anchor(
            top: view.topAnchor, left: view.leftAnchor,
            bottom: view.bottomAnchor, right: view.rightAnchor
        )
        
        verifyView.frame.origin.y = view.frame.height
        
        UIView.animate(withDuration: 0.3) {
            verifyView.frame.origin.y = 0
        }
        
        verifyView.backgroundColor = .secondarySystemBackground
    }
    
}


// MARK: UITextFieldDelegate
extension SignUpController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "" && textField == phoneNumberTextField {
            textField.text = "+998"
        }
    }
    
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneNumberTextField {
            firstnameTextField.becomeFirstResponder()
        } else
        if textField == firstnameTextField {
            lastnameTextField.becomeFirstResponder()
        } else
        if textField == lastnameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            handleSignUp()
        }
        return true
    }
}

// MARK: - VerifyViewDelegate

extension SignUpController: VerifyViewDelegate {
    func handleEdit() {
        phoneNumberTextField.becomeFirstResponder()
    }
    
    func handleNext() {
        let selectJobsController = SelectJobsController(controller: "SignIn")
        selectJobsController.delegate = self
        selectJobsController.modalPresentationStyle = .fullScreen
        present(selectJobsController, animated: true, completion: nil)
    }
}

// MARK: - SelectJobsControllerDelegate

extension SignUpController: SelectJobsControllerDelegate {
    func gohome() {
        guard let controller = UIApplication.shared.keyWindow?.rootViewController
                as? HomeController else { return }
        controller.configure()
        dismiss(animated: false, completion: nil)
    }
    
    
}

