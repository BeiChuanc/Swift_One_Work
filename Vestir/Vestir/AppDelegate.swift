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
        Utils_Vestir.setupHUDConfig_Vestir(fontSize_Vestir: 16)
        
        // 初始化本地数据
        LocalData_Vestir.shared_Vestir.initData_Vestir()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Vestir.shared_Vestir.initUser_Vestir()
        }
        
        // 初始化帖子模块
        Task { @MainActor in
            TitleViewModel_Vestir.shared_Vestir.initPosts_Vestir()
        }
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Vestir.shared_Vestir.initChat_Vestir()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Vestir.setRootToTabbar_Vestir(window: window)
        
        return true
    }

}

