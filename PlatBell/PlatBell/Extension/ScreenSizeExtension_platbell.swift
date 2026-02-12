import SwiftUI

// MARK: - SwiftUI 屏幕尺寸扩展

/// 屏幕尺寸环境键
private struct ScreenSizeKey_platbell: EnvironmentKey {
    static let defaultValue: CGSize = {
        ScreenSize_platbell.shared_platbell.size_platbell
    }()
}

extension EnvironmentValues {
    /// 屏幕尺寸环境值
    var screenSize_platbell: CGSize {
        get { self[ScreenSizeKey_platbell.self] }
        set { self[ScreenSizeKey_platbell.self] = newValue }
    }
}

// MARK: - View 扩展

extension View {
    
    /// 获取屏幕宽度（便捷方法）
    var screenWidth_platbell: CGFloat {
        ScreenSize_platbell.shared_platbell.width_platbell
    }
    
    /// 获取屏幕高度（便捷方法）
    var screenHeight_platbell: CGFloat {
        ScreenSize_platbell.shared_platbell.height_platbell
    }
    
    /// 根据屏幕宽度计算比例尺寸
    func widthRatio_platbell(_ ratio_platbell: CGFloat) -> CGFloat {
        screenWidth_platbell * ratio_platbell
    }
    
    /// 根据屏幕高度计算比例尺寸
    func heightRatio_platbell(_ ratio_platbell: CGFloat) -> CGFloat {
        screenHeight_platbell * ratio_platbell
    }
}

// MARK: - 屏幕适配常量

/// 屏幕适配工具
enum ScreenAdapter_platbell {
    
    /// 基准屏幕宽度（iPhone 14/15 标准尺寸）
    private static let baseWidth_platbell: CGFloat = 390.0
    
    /// 基准屏幕高度（iPhone 14/15 标准尺寸）
    private static let baseHeight_platbell: CGFloat = 844.0
    
    /// 宽度适配比例
    static var widthRatio_platbell: CGFloat {
        ScreenSize_platbell.shared_platbell.width_platbell / baseWidth_platbell
    }
    
    /// 高度适配比例
    static var heightRatio_platbell: CGFloat {
        ScreenSize_platbell.shared_platbell.height_platbell / baseHeight_platbell
    }
    
    /// 适配宽度
    static func adaptWidth_platbell(_ value_platbell: CGFloat) -> CGFloat {
        return value_platbell * widthRatio_platbell
    }
    
    /// 适配高度
    static func adaptHeight_platbell(_ value_platbell: CGFloat) -> CGFloat {
        return value_platbell * heightRatio_platbell
    }
    
    /// 适配字体大小
    static func adaptFont_platbell(_ size_platbell: CGFloat) -> CGFloat {
        return size_platbell * min(widthRatio_platbell, heightRatio_platbell)
    }
}

// MARK: - CGFloat 扩展

extension CGFloat {
    
    /// 宽度适配
    var w_platbell: CGFloat {
        ScreenAdapter_platbell.adaptWidth_platbell(self)
    }
    
    /// 高度适配
    var h_platbell: CGFloat {
        ScreenAdapter_platbell.adaptHeight_platbell(self)
    }
    
    /// 字体大小适配
    var sp_platbell: CGFloat {
        ScreenAdapter_platbell.adaptFont_platbell(self)
    }
}

extension Int {
    
    /// 宽度适配
    var w_platbell: CGFloat {
        ScreenAdapter_platbell.adaptWidth_platbell(CGFloat(self))
    }
    
    /// 高度适配
    var h_platbell: CGFloat {
        ScreenAdapter_platbell.adaptHeight_platbell(CGFloat(self))
    }
    
    /// 字体大小适配
    var sp_platbell: CGFloat {
        ScreenAdapter_platbell.adaptFont_platbell(CGFloat(self))
    }
}

extension Double {
    
    /// 宽度适配
    var w_platbell: CGFloat {
        ScreenAdapter_platbell.adaptWidth_platbell(CGFloat(self))
    }
    
    /// 高度适配
    var h_platbell: CGFloat {
        ScreenAdapter_platbell.adaptHeight_platbell(CGFloat(self))
    }
    
    /// 字体大小适配
    var sp_platbell: CGFloat {
        ScreenAdapter_platbell.adaptFont_platbell(CGFloat(self))
    }
}
