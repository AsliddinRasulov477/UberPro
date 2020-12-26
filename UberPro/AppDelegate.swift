import UIKit
import YandexMapsMobile

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
        YMKMapKit.setApiKey("1e769904-20d0-4b98-b22c-f9810c68a5d2")
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = HomeController()
       
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if UserDefaults.standard.string(forKey: "ID") != nil &&
            (UserDefaults.standard.stringArray(forKey: "SELECTEDJOBS") != nil ||
            UserDefaults.standard.stringArray(forKey: "SELECTEDJOBS")?.count != 0) {
            guard let controller = UIApplication.shared.keyWindow?.rootViewController
                    as? HomeController else { return }
            controller.hasLocationPermission()
            switch UserDefaults.standard.string(forKey: "authorizationStatus") {
            case "denied":
                DispatchQueue.main.async {
                    controller.deniedAuthorization()
                }
            default: controller.configurePlacemark()
            }
        }
    }
}
