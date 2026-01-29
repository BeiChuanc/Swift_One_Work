import UIKit
import IQKeyboardManager

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 初始化键盘管理器
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        // 配置HUD全局样式（使用默认字体大小30和艺术字体）
        Utils_Wanderbell.setupHUDConfig_Wanderbell()
        
        // 初始化本地数据
        LocalData_Wanderbell.shared_Wanderbell.initData_Wanderbell()
        
        // 初始化模块（按依赖顺序）
        Task { @MainActor in
            // 1. 初始化情绪记录模块（必须最先，因为用户需要读取情绪数据）
            EmotionViewModel_Wanderbell.shared_Wanderbell.initEmotionRecords_Wanderbell()
            
            // 2. 初始化用户模块（会加载情绪记录到用户模型）
            UserViewModel_Wanderbell.shared_Wanderbell.initUser_Wanderbell()
            
            // 3. 初始化帖子模块
            TitleViewModel_Wanderbell.shared_Wanderbell.initPosts_Wanderbell()
            
            // 4. 初始化消息模块
            MessageViewModel_Wanderbell.shared_Wanderbell.initChat_Wanderbell()
        }
        
        // 设置窗口
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .clear
        Navigation_Wanderbell.setRootToTabbar_Wanderbell(window: window)
        
        return true
    }

}

