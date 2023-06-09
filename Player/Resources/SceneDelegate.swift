import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        setupView()
    }

    func setupView() {
        let mainViewController = UINavigationController(rootViewController: MediaViewController())
        mainViewController.tabBarItem = UITabBarItem(title: "media",
                                                       image: UIImage(systemName: "music.note.list"),
                                                       tag: 0)
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        searchVC.tabBarItem = UITabBarItem(title: "search",
                                                       image: UIImage(systemName: "magnifyingglass"),
                                                       tag: 1)
        let tabBarController = UITabBarController()
        tabBarController.tabBar.backgroundColor = .black
        tabBarController.tabBar.barTintColor = .black
        tabBarController.tabBar.tintColor = .white
        tabBarController.tabBar.unselectedItemTintColor = .gray
        tabBarController.viewControllers = [mainViewController, searchVC]
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {        
        let fileManager = FileManager.default
        guard let documentDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        do {
            let fileURLs = try fileManager.contentsOfDirectory(
                at: documentDirectoryURL,
                includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                if APManager.shared.songs.contains(where: { Audio in
                    Audio.fileName == fileURL.lastPathComponent
                }) {
                    print("существует \(fileURL.lastPathComponent)")
                } else {
                    try fileManager.removeItem(at: fileURL)
                    print("removed successfully \(fileURL.lastPathComponent)")
                }
            }
        } catch {
            print("Error listing files in document directory: \(error.localizedDescription)")
        }
        StorageManager.shared.save(songs: APManager.shared.songs)
        StorageManager.shared.saveSettings(settings: SettingsManager.shared.settings)
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

