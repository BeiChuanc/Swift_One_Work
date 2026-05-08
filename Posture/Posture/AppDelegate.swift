import UIKit
import IQKeyboardManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 初始化键盘管理器
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        // 配置HUD全局样式
        Utils_Posture.setupHUDConfig_Posture(fontSize_Posture: 16)
        
        // 初始化本地数据
        LocalData_Posture.shared_Posture.initData_Posture()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Posture.shared_Posture.initUser_Posture()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Posture.shared_Posture.initPosts_Posture()
            TitleViewModel_Posture.shared_Posture.initTopics_Posture()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Posture.shared_Posture.initChat_Posture()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Posture.setRootToTabbar_Posture(window: window)
        
        return true
    }

}

