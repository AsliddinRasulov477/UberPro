import UIKit
import Alamofire
import SwiftyJSON

protocol SelectJobsControllerDelegate: AnyObject {
    func gohome()
}

class SelectJobsController: UIViewController {
    
    // MARK: - Properties
    
    private var controller: String = ""
   
    private var jobs: [[String: String]] = []
    private var selectedJobs: [String] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.text = "jobs".localized
        label.font = UIFont(name: "SpartanMB-Bold", size: 36)
        return label
    }()
    
    private let professionsTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(
            ProfessionsTableCell.self,
            forCellReuseIdentifier: ProfessionsTableCell.identifire
        )
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 35
        button.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        button.setImage(#imageLiteral(resourceName: "continue").withTintColor(.systemBackground), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    weak var delegate: SelectJobsControllerDelegate?
    
    
    // MARK: - Lifecycle
    
    public init(controller: String) {
        super.init(nibName: nil, bundle: nil)
        self.controller = controller
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        configure()
        
        AF.request("http://167.99.33.2/api/jobs", method: .get).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                DispatchQueue.main.async {
                    let json = JSON(value)
                    for i in 1..<json["data"].count {
                        let jobID = json["data"][i]["_id"].string ?? ""
                        let jobTitle = json["data"][i]["title"].string ?? ""
                        self.jobs.append([jobID: jobTitle])
                        self.professionsTableView.reloadData()
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
   
    
    // MARK: Helper Functions
    
    func configure() {
        configureProfessionsTableView()
    }
    
    func configureTitleLabel() {
        view.addSubview(titleLabel)
    
        titleLabel.anchor(
            top: view.topAnchor, paddingTop: view.safeAreaInsets.top + 40
        )
        titleLabel.centerX(inView: view)
    }
    
    func configureProfessionsTableView() {
        
        configureTitleLabel()
        
        view.addSubview(professionsTableView)
            
        professionsTableView.delegate = self
        professionsTableView.dataSource = self
        
        professionsTableView.anchor(
            top: titleLabel.bottomAnchor, left: view.leftAnchor,
            bottom: view.bottomAnchor, right: view.rightAnchor,
            paddingTop: 10
        )
    }
    
    func configureNextButton() {
        DispatchQueue.main.async {
            guard let keyWindow = UIApplication.shared.keyWindow else { return }
            keyWindow.addSubview(self.nextButton)
            self.nextButton.anchor(
                bottom: keyWindow.bottomAnchor, right: keyWindow.rightAnchor,
                paddingBottom: 30, paddingRight: 30,
                width: 70, height: 70
            )
            self.nextButton.addTarget(
                self, action: #selector(self.handleNextButton),
                for: .touchUpInside
            )
        }
        
    }
    
    
    // MARK: - Selectors
    
    @objc private func handleNextButton() {
        postSelectedJobs { (json) in
            if json["success"].boolValue {
                UserDefaults.standard.setValue(
                    self.selectedJobs, forKey: "SELECTEDJOBS"
                )
                self.nextButton.removeFromSuperview()
                if self.controller == "Home" {
                    guard let controller = UIApplication.shared.keyWindow?.rootViewController
                            as? HomeController else { return }
                    controller.configure()
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.dismiss(animated: false) {
                        self.delegate?.gohome()
                    }
                }
            }
        }
    }
    
    
    // MARK: - API
    
    private func postSelectedJobs(completion: @escaping(JSON) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "TOKEN") else {
            return
        }
        
        let headers: HTTPHeaders = [
            "Authorization": token
        ]
        
        AF.request(
            "http://167.99.33.2/api/users/addjobs/", method: .post, parameters: ["jobs": selectedJobs], encoding: JSONEncoding.default, headers: headers
        ).responseJSON { (response) in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                completion(json)
            case .failure(let error):
                print(error)
            }
        }
    }
    
}

   
// MARK: - UITableViewDelegate, UITableViewDataSource

extension SelectJobsController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ProfessionsTableCell.identifire, for: indexPath
        ) as! ProfessionsTableCell
        
        if selectedJobs.count == 0 {
            cell.contentView.backgroundColor = .systemBackground
        }
        
        for (key, value) in jobs[indexPath.row] {
            cell.textLabel?.text = value
            if selectedJobs.contains(key) {
                cell.contentView.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)
            } else {
                cell.contentView.backgroundColor = .systemBackground
            }
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ProfessionsTableCell

        for (key, _) in jobs[indexPath.row] {
            if selectedJobs.contains(key) {
                cell.contentView.backgroundColor = .systemBackground
                selectedJobs = selectedJobs.filter { $0 != key }
            } else {
                cell.contentView.backgroundColor = #colorLiteral(red: 0.2549019608, green: 0.831372549, blue: 0.0431372549, alpha: 1)
                selectedJobs.append(key)
            }
        }

        if selectedJobs.count == 1 {
            configureNextButton()
        } else
        if selectedJobs.count == 0  {
            nextButton.removeFromSuperview()
        }
    }
}
