//
//  ProfessionsCell.swift
//  Uber
//
//  Created by Asliddin Rasulov on 25/11/20.
//

import UIKit

class ProfessionsTableCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifire = "ProfessionsCell"
    
    
    // MARK: - Lifecycle
    
    override var frame: CGRect {
        get {
            return super.frame
        } set (newFrame) {
            var frame = newFrame
            frame.origin.x += 20
            frame.size.width -= 40
            frame.origin.y += 10
            frame.size.height -= 20
            super.frame = frame
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        textLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        
        contentView.backgroundColor = .systemBackground
        
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 16
        
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = #colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1).cgColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
