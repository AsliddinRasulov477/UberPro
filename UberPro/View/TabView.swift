//
//  TabView.swift
//  UberPro
//
//  Created by Asliddin Rasulov on 25/12/20.
//

import UIKit

protocol TabViewDelegate: AnyObject {
    func presentProfile()
    func presentBalance()
    func presentSetting()
}


class TabView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: TabViewDelegate?
        
    private let profileTabButton: UIButton = {
        let button = TabButton()
        button.imageEdgeInsets = UIEdgeInsets(
            top: 15, left: 15, bottom: 15, right: 15
        )
        button.setImage(#imageLiteral(resourceName: "user-1").withTintColor(.systemBackground), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let balanceTabButton: UIButton = {
        let button = TabButton()
        button.imageEdgeInsets = UIEdgeInsets(
            top: 15, left: 15, bottom: 15, right: 15
        )
        button.setImage(#imageLiteral(resourceName: "credit-card-2").withTintColor(.systemBackground), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let settingButton: UIButton = {
        let button = TabButton()
        button.imageEdgeInsets = UIEdgeInsets(
            top: 15, left: 15, bottom: 15, right: 15
        )
        button.setImage(#imageLiteral(resourceName: "settings").withTintColor(.systemBackground), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        
        addSubviews()
    }
   
    private func addSubviews() {
        
        let const = UIScreen.main.bounds.width / 4 - 45
        
        addSubview(profileTabButton)
        profileTabButton.anchor(
            top: topAnchor, left: leftAnchor,
            paddingTop: 10, paddingLeft: const, width: 60, height: 60
        )
        profileTabButton.addTarget(
            self, action: #selector(presentProfile), for: .touchUpInside
        )
        
        addSubview(balanceTabButton)
        balanceTabButton.anchor(
            top: topAnchor, left: profileTabButton.rightAnchor,
            paddingTop: 10, paddingLeft: const, width: 60, height: 60
        )
        balanceTabButton.addTarget(
            self, action: #selector(presentBalance), for: .touchUpInside
        )
        
        addSubview(settingButton)
        settingButton.anchor(
            top: topAnchor, left: balanceTabButton.rightAnchor,
            paddingTop: 10, paddingLeft: const, width: 60, height: 60
        )
        settingButton.addTarget(
            self, action: #selector(presentSetting), for: .touchUpInside
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    
    @objc func presentProfile() {
        delegate?.presentProfile()
    }
    
    @objc func presentBalance() {
        delegate?.presentBalance()
    }
    
    @objc func presentSetting() {
        delegate?.presentSetting()
    }
}

