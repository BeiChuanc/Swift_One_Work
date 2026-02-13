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
        Utils_Glasspaint.setupHUDConfig_Glasspaint(fontSize_Glasspaint: 16)
        
        // 初始化本地数据
        LocalData_Glasspaint.shared_Glasspaint.initData_Glasspaint()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Glasspaint.shared_Glasspaint.initUser_Glasspaint()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Glasspaint.shared_Glasspaint.initPosts_Glasspaint()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Glasspaint.shared_Glasspaint.initChat_Glasspaint()
        }
        
        // 初始化挑战模块
        Task { @MainActor in
            ChallengeViewModel_Glasspaint.shared_Glasspaint.initChallenges_Glasspaint()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Glasspaint.setRootToTabbar_Glasspaint(window: window)
        
        return true
    }

}

