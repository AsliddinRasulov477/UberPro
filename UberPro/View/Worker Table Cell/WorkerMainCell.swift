//
//  WorkersCell.swift
//  Uber
//
//  Created by Asliddin Rasulov on 28/11/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

protocol WorkerMainCellDelegate: AnyObject {
    func handleAddProfilePhoto()
}

class WorkerMainCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifire = "WorkerMainCell"
    
    private var worker = Worker()
    
    private let profilePhoto: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 50
        button.setBackgroundImage(#imageLiteral(resourceName: "fullname").withTintColor(.label), for: .normal)
        button.layer.borderWidth = 3
        button.layer.borderColor = #colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)
        return button
    }()
    
    private let addProfilePhoto: UIButton = {
        let button = UIButton()
        button.alpha = 0.8
        button.setBackgroundImage(#imageLiteral(resourceName: "photo-camera-interface-symbol-for-button").withTintColor(#colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)), for: .normal)
        return button
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .label
        return label
    }()
    
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    weak var delegate: WorkerMainCellDelegate?
    
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fullnameLabel.text = nil
        phoneLabel.text = nil
    }
    
    
    // MARK: - Helper Functions
    
    private func addSubviews() {
        
        selectionStyle = .none
        
        contentView.addSubview(profilePhoto)
        profilePhoto.anchor(
            top: contentView.topAnchor, left: contentView.leftAnchor,
            paddingTop: 15, paddingLeft: 15, width: 100, height: 100
        )
        
        contentView.addSubview(addProfilePhoto)
        addProfilePhoto.addTarget(
            self, action: #selector(handleAddProfilePhoto), for: .touchUpInside
        )
        addProfilePhoto.centerX(inView: profilePhoto)
        addProfilePhoto.anchor(
            bottom: profilePhoto.bottomAnchor, paddingBottom: 10,
            width: 25, height: 25
        )
        
        contentView.addSubview(fullnameLabel)
        fullnameLabel.anchor(
            top: profilePhoto.topAnchor, left: profilePhoto.rightAnchor, right: contentView.rightAnchor,
            paddingTop: 15, paddingRight: 15
        )
        
        contentView.addSubview(phoneLabel)
        phoneLabel.anchor(
            top: fullnameLabel.bottomAnchor, left: profilePhoto.rightAnchor,
            right: contentView.rightAnchor, paddingTop: 10, paddingRight: 15
        )
        
        contentView.bottomAnchor.constraint(
            equalTo: profilePhoto.bottomAnchor, constant: 5
        ).isActive = true
    }
    
  
    func configure(with worker: Worker) {
        
        self.worker = worker
        
        if let imageURL = getURLFromString("http://167.99.33.2/" + worker.avatar) {
            if worker.avatar == "" {
                profilePhoto.setImage(#imageLiteral(resourceName: "fullname").withTintColor(.label).withAlignmentRectInsets(
                    UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
                ), for: .normal)
            } else {
                profilePhoto.sd_imageIndicator = SDWebImageActivityIndicator.gray
                profilePhoto.sd_setImage(with: imageURL, for: .normal)
            }
        }
        fullnameLabel.text = worker.firstName + " " + worker.lastName
        phoneLabel.text = worker.phone
    }
    
    private func getURLFromString(_ str: String) -> URL? {
        return URL(string: str)
    }
    
    // MARK: - Selectors
    
    @objc func handleAddProfilePhoto() {
        showAlert()
        delegate?.handleAddProfilePhoto()
    }
}


//MARK:- Image Picker
extension WorkerMainCell: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    private func showAlert() {

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: "Photo Album", style: .default, handler: {(action: UIAlertAction) in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        UIApplication.shared.keyWindow?.rootViewController?.present(
            alert, animated: true, completion: nil
        )
    }

    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            UIApplication.shared.keyWindow?.rootViewController?.present(
                imagePickerController, animated: true, completion: nil
            )
        }
    }

    //MARK: - UIImagePickerViewDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true) {
            guard let image = info[UIImagePickerController.InfoKey.originalImage]
                    as? UIImage else { return }
            
            guard let imageData = image.sd_imageData() else {
                return
            }
            print(imageData)
            AF.upload(
                imageData, to: "http://167.99.33.2/api/users/upload", method: .post
            ).responseJSON { (response) in
                print(response)
            }
        }
    }
    
//    func patchWorkerAvatar() {
//        guard let token = UserDefaults.standard.string(forKey: "TOKEN") else {
//            return
//        }
//
//        let headers: HTTPHeaders = [
//            "Authorization": token
//        ]
//
//        let params: Parameters = [
//            "firstName": worker.firstName,
//            "lastName": worker.lastName,
//            "phone": worker.phone,
//            "avatar": "avatar",
//            "description": worker.description,
//            "location": worker.location,
//            "images": worker.images,
//        ]
//
//        AF.request(
//            "http://167.99.33.2/api/users/", method: .patch, parameters: params, headers: headers
//        ).responseJSON { (response) in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                if json["success"].boolValue {
//                    profilePhoto.setImage("image", for: .normal)
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
