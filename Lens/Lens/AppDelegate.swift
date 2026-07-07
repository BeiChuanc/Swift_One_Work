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
        Load_Lens.setupHUDConfig_Lens(fontSize_Lens: 16)
        
        // 初始化本地数据
        LocalData_Lens.shared_Lens.initData_Lens()
        
        // 初始化用户模块
        Task { @MainActor in
            UserViewModel_Lens.shared_Lens.initUser_Lens()
        }
        
        // 初始化帖子模块（同步完成，避免 Discover 首次加载时数据未就绪）
        TitleViewModel_Lens.shared_Lens.initPosts_Lens()
        
        // 初始化消息模块
        Task { @MainActor in
            MessageViewModel_Lens.shared_Lens.initChat_Lens()
        }

        // 初始化调制画盘工作室模块
        Task { @MainActor in
            StudioViewModel_Lens.shared_Lens.initStudio_Lens()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Lens.setRootToTabbar_Lens(window: window)
        
        return true
    }

}

