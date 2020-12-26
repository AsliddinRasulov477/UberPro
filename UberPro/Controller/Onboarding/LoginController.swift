import UIKit
import Alamofire
import SwiftyJSON

class LoginController: UIViewController {
    
    // MARK: - Properties
    
    private let locationManager = LocationHandler.shared.locationManager
    
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
    
    private lazy var passwordContainerView: UIView = {
        let view = UIView().inputContainerView(
            image: #imageLiteral(resourceName: "password"), textField: passwordTextField
        )
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
    
    private let passwordTextField: UITextField = {
        var textField = UITextField()
        textField = textField.textField(
            withPlaceholder: "password".localized,
            isSecureTextEntry: true
        )
        return textField
    }()
    
    private let loginButton: AuthButton = {
        let button = AuthButton(type: .system)
        button.setTitle("log_in".localized, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "dont_have_an_account".localized, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        attributedTitle.append(NSAttributedString(string: "sign_up".localized, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)]))
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
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
        configureUI()
    }
    
    // MARK: - Selectors
    
    @objc func handleLogin() {
        guard let phone = phoneNumberTextField.text, !phone.isEmpty,
              let password = passwordTextField.text, !password.isEmpty, password.count >= 8
        else { return }
        
        let params = ["phone": phone,
                      "password": password] as [String: Any]
        
        postUserSignIn(parameters: params) { (json) in
            if json["success"].boolValue {
                UserDefaults.standard.setValue(
                    json["data"]["_id"].string, forKey: "ID"
                )
                UserDefaults.standard.setValue(
                    json["token"].string, forKey: "TOKEN"
                )
                UserDefaults.standard.setValue(
                    json["data"]["jobs"].arrayObject as? [String], forKey: "SELECTEDJOBS"
                )
                guard let controller = UIApplication.shared.keyWindow?.rootViewController
                        as? HomeController else { return }
                controller.configure()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func handleShowSignUp() {
        let controller = SignUpController()
        
        phoneNumberTextField.text = ""
        passwordTextField.text = ""
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func tappedView() {
        phoneNumberTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    
    // MARK: - API
    
    func postUserSignIn(parameters: [String: Any], comletion: @escaping(JSON) -> Void) {
        let headers: HTTPHeaders = [
            .contentType("application/json")
        ]
        AF.request(
            "http://167.99.33.2/api/users/login", method: .post, parameters: parameters,
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
    
    
    // MARK: - Helper Functions
    
    func configureUI() {
        configureNavigationBar()
        
        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 10)
        titleLabel.centerX(inView: view)
        
        let stack = UIStackView(arrangedSubviews: [phoneNumberContainerView,
                                                   passwordContainerView,
                                                   loginButton])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 24
        
        view.addSubview(stack)
        stack.anchor(
            top: titleLabel.bottomAnchor, left: view.leftAnchor,
            right: view.rightAnchor,
            paddingTop: 30, paddingLeft: 16, paddingRight: 16
        )
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            paddingBottom: 5, height: 32
        )
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
    }
}


// MARK: - UITextFieldDelegate

extension LoginController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.text = "+998"
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneNumberTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            handleLogin()
        }
        return true
    }
}
