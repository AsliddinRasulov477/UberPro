//
//  HomeButton.swift
//  UberPro
//
//  Created by Asliddin Rasulov on 17/12/20.
//

import UIKit

class TabButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)
        layer.cornerRadius = 30
        
        setDemissions(height: 60, width: 60)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

