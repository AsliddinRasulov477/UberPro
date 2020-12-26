//
//  ProfileView.swift
//  UberPro
//
//  Created by Asliddin Rasulov on 25/12/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileTableView: UIView {
    
    // MARK: - Properties
    
    private var worker = Worker()
    private let locationManager = LocationHandler.shared.locationManager
    
    private let workersTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(
            WorkerMainCell.self,
            forCellReuseIdentifier: WorkerMainCell.identifire
        )
        
        tableView.register(
            WorkerDescriptionCell.self,
            forCellReuseIdentifier: WorkerDescriptionCell.identifire
        )
        
        tableView.register(
            WorkerPhotoCollectionCell.self,
            forCellReuseIdentifier: WorkerPhotoCollectionCell.identifire
        )
    
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        return tableView
    }()
    

    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Helper Functions
   
    private func addSubviews() {
        fetchWorkersData { [self] (success) in
            if success {
                addSubview(workersTableView)
                
                workersTableView.delegate = self
                workersTableView.dataSource = self
                
                workersTableView.anchor(
                    top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor
                )
            }
        }
    }
    
    
    // MARK - API
    
    private func fetchWorkersData(completion: @escaping(Bool) -> Void) {
        
        guard let uid = UserDefaults.standard.string(forKey: "ID") else {
            return
        }
        
        AF.request("http://167.99.33.2/api/users/" + uid,
                   method: .get).responseJSON { [self] (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                worker.distance = json["data"]["distance"].double ?? 0.0
                worker.firstName = json["data"]["firstName"].string ?? ""
                worker.lastName = json["data"]["lastName"].string ?? ""
                worker.phone = json["data"]["phone"].string ?? ""
                worker.description = json["data"]["description"].string ?? ""
//                worker.images = json["data"]["images"].arrayObject as! [String]
                worker.avatar = json["data"]["avatar"].string ?? ""
                let location = json["data"]["location"].object as? Location
                worker.location = location ?? Location(coordinate: [0, 0])
                completion(true)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension ProfileTableView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let workerMainCell = tableView.dequeueReusableCell(
                withIdentifier: WorkerMainCell.identifire, for: indexPath
            ) as! WorkerMainCell
                        
            workerMainCell.configure(with: worker)
            
            return workerMainCell
        } else
        if indexPath.section == 1 {
            let workerDescriptionCell = tableView.dequeueReusableCell(
                withIdentifier: WorkerDescriptionCell.identifire, for: indexPath
            ) as! WorkerDescriptionCell
            
            workerDescriptionCell.configure(with: worker)
            
            return workerDescriptionCell
        } else
        if indexPath.section == 2 {
            let workerPhotoCollectionCell = tableView.dequeueReusableCell(
                withIdentifier: WorkerPhotoCollectionCell.identifire, for: indexPath
            ) as! WorkerPhotoCollectionCell
            
            workerPhotoCollectionCell.configure(worker: worker)
            
            return workerPhotoCollectionCell
        }
        
        return UITableViewCell()
    }
}



