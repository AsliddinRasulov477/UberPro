//
//  PhotoCollectionViewCell.swift
//  Uber
//
//  Created by Asliddin Rasulov on 15/12/20.
//

import UIKit
import Alamofire
import SDWebImage

class PhotoCollectionViewCell: UICollectionViewCell {
    
    
    static let identifire = "PhotoCollectionViewCell"
    
    // MARK: - Properties
    
    private let photoCollectionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(photoCollectionImageView)
        photoCollectionImageView.anchor(
            top: contentView.topAnchor, left: contentView.leftAnchor,
            bottom: contentView.bottomAnchor, right: contentView.rightAnchor
        )
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoCollectionImageView.image = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helper Functions
    
    
    func configure(image: String) {
        if image == "no-image" {
            photoCollectionImageView.image = #imageLiteral(resourceName: "image").withTintColor(.label)
        } else
        if let imageURL = getURLFromString("http://167.99.33.2/" + image) {
            let width = UIScreen.main.bounds.width
            photoCollectionImageView.setDemissions(height: width, width: width)
            photoCollectionImageView.sd_imageIndicator = SDWebImageActivityIndicator.whiteLarge
            photoCollectionImageView.sd_setImage(with: imageURL)
        }
    }
    
    private func getURLFromString(_ str: String) -> URL? {
        return URL(string: str)
    }
}
