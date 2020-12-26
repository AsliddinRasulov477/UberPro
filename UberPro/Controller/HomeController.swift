//
//  HomeController.swift
//  UberTutorial
//
//  Created by Stephen Dowless on 9/13/19.
//  Copyright © 2019 Stephan Dowless. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import YandexMapsMobile


class HomeController: UIViewController {
    
    // MARK: - Properties
    
    private let mapView = YMKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    
    private let tabView = TabView()
    private let profileView = ProfileTableView()
    private let balanceView = ProfileTableView()
    private let settingView = ProfileTableView()

    private var worker = Worker()
   
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfWorkerLoggedIn()
        
        if traitCollection.userInterfaceStyle == .dark {
            mapView.mapWindow.map.isNightModeEnabled = true
        } else {
            mapView.mapWindow.map.isNightModeEnabled = false
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle == .dark {
            mapView.mapWindow.map.isNightModeEnabled = true
        } else {
            mapView.mapWindow.map.isNightModeEnabled = false
        }
    }

    
    // MARK: - API
     
    func checkIfWorkerLoggedIn() {
        if UserDefaults.standard.string(forKey: "ID") == nil {
            DispatchQueue.main.async {
                let navC = UINavigationController(rootViewController: LoginController())
                navC.modalPresentationStyle = .fullScreen
                self.present(navC, animated: true, completion: nil)
            }
        } else
        if UserDefaults.standard.stringArray(forKey: "SELECTEDJOBS") == nil ||
            UserDefaults.standard.stringArray(forKey: "SELECTEDJOBS")?.count == 0 {
            DispatchQueue.main.async {
                let vc = SelectJobsController(controller: "Home")
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            configure()
        }
    }


    // MARK: - Helper Functions
    
    func configure() {
        hasLocationPermission()
        configureMapView()
        configureTabView()
        configureTabSubViews()
    }
    
   
    private func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
    
    func configurePlacemark() {
        guard let coordinate = locationManager.location?.coordinate else {
            return
        }
        
        mapView.mapWindow.map.isRotateGesturesEnabled = false
        
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(target: YMKPoint(latitude: coordinate.latitude, longitude: coordinate.longitude), zoom: 15, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 2),
            cameraCallback: nil
        )
       
        let mapObjects = mapView.mapWindow.map.mapObjects
        
        mapObjects.clear()
        
        mapObjects.addPlacemark(with: YMKPoint(latitude: coordinate.latitude, longitude: coordinate.longitude), image: #imageLiteral(resourceName: "worker"), style: YMKIconStyle())
        
    }
    
    private func configureTabView() {
        view.addSubview(tabView)
        tabView.delegate = self
        tabView.anchor(
            left: view.leftAnchor, bottom: view.bottomAnchor,
            right: view.rightAnchor, height: 100
        )
    }
    
    private func configureTabSubViews() {
        view.addSubview(profileView)
        profileView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
            bottom: tabView.topAnchor, right: view.rightAnchor
        )
        
        view.addSubview(balanceView)
        balanceView.alpha = 0
        balanceView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
            bottom: tabView.topAnchor, right: view.rightAnchor
        )
        
        view.addSubview(settingView)
        settingView.alpha = 0
        settingView.anchor(
            top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
            bottom: tabView.topAnchor, right: view.rightAnchor
        )
    }
}


// MARK: - LocationServices

extension HomeController: CLLocationManagerDelegate {
    func hasLocationPermission() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                UserDefaults.standard.setValue("notDetermined", forKey: "authorizationStatus")
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                UserDefaults.standard.setValue("denied", forKey: "authorizationStatus")
                deniedAuthorization()
            case .authorizedWhenInUse:
                locationManager.requestAlwaysAuthorization()
                UserDefaults.standard.setValue("authorizedWhenInUse", forKey: "authorizationStatus")
            case .authorizedAlways:
                UserDefaults.standard.setValue("authorizedAlways", forKey: "authorizationStatus")
            default:
                UserDefaults.standard.setValue("", forKey: "authorizationStatus")
            }
        } else {
            UserDefaults.standard.setValue("", forKey: "authorizationStatus")
        }
    }
    
    func deniedAuthorization() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Location Permission Required", message: "Please enable location permissions in settings.", preferredStyle: UIAlertController.Style.alert)

            let okAction = UIAlertAction(title: "Settings", style: .default, handler: {(cAlertAction) in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })

           
            alertController.addAction(okAction)
        
            self.present(alertController, animated: true, completion: nil)
        }
    }
}


// MARK: - TabViewDelegate

extension HomeController: TabViewDelegate {
    func presentProfile() {
        profileView.alpha = 1
        balanceView.alpha = 0
        settingView.alpha = 0
    }
    
    func presentBalance() {
        profileView.alpha = 0
        balanceView.alpha = 1
        settingView.alpha = 0
    }
    
    func presentSetting() {
        profileView.alpha = 0
        balanceView.alpha = 0
        settingView.alpha = 1
    }
}
