import SwiftUI

// MARK: - SwiftUI 屏幕尺寸扩展

/// 屏幕尺寸环境键
private struct ScreenSizeKey_blisslink: EnvironmentKey {
    static let defaultValue: CGSize = {
        ScreenSize_blisslink.shared_blisslink.size_blisslink
    }()
}

extension EnvironmentValues {
    /// 屏幕尺寸环境值
    var screenSize_blisslink: CGSize {
        get { self[ScreenSizeKey_blisslink.self] }
        set { self[ScreenSizeKey_blisslink.self] = newValue }
    }
}

// MARK: - View 扩展

extension View {
    
    /// 获取屏幕宽度（便捷方法）
    var screenWidth_blisslink: CGFloat {
        ScreenSize_blisslink.shared_blisslink.width_blisslink
    }
    
    /// 获取屏幕高度（便捷方法）
    var screenHeight_blisslink: CGFloat {
        ScreenSize_blisslink.shared_blisslink.height_blisslink
    }
    
    /// 根据屏幕宽度计算比例尺寸
    func widthRatio_blisslink(_ ratio_blisslink: CGFloat) -> CGFloat {
        screenWidth_blisslink * ratio_blisslink
    }
    
    /// 根据屏幕高度计算比例尺寸
    func heightRatio_blisslink(_ ratio_blisslink: CGFloat) -> CGFloat {
        screenHeight_blisslink * ratio_blisslink
    }
}

// MARK: - 屏幕适配常量

/// 屏幕适配工具
enum ScreenAdapter_blisslink {
    
    /// 基准屏幕宽度（iPhone 14/15 标准尺寸）
    private static let baseWidth_blisslink: CGFloat = 390.0
    
    /// 基准屏幕高度（iPhone 14/15 标准尺寸）
    private static let baseHeight_blisslink: CGFloat = 844.0
    
    /// 宽度适配比例
    static var widthRatio_blisslink: CGFloat {
        ScreenSize_blisslink.shared_blisslink.width_blisslink / baseWidth_blisslink
    }
    
    /// 高度适配比例
    static var heightRatio_blisslink: CGFloat {
        ScreenSize_blisslink.shared_blisslink.height_blisslink / baseHeight_blisslink
    }
    
    /// 适配宽度
    static func adaptWidth_blisslink(_ value_blisslink: CGFloat) -> CGFloat {
        return value_blisslink * widthRatio_blisslink
    }
    
    /// 适配高度
    static func adaptHeight_blisslink(_ value_blisslink: CGFloat) -> CGFloat {
        return value_blisslink * heightRatio_blisslink
    }
    
    /// 适配字体大小
    static func adaptFont_blisslink(_ size_blisslink: CGFloat) -> CGFloat {
        return size_blisslink * min(widthRatio_blisslink, heightRatio_blisslink)
    }
}

// MARK: - CGFloat 扩展

extension CGFloat {
    
    /// 宽度适配
    var w_blisslink: CGFloat {
        ScreenAdapter_blisslink.adaptWidth_blisslink(self)
    }
    
    /// 高度适配
    var h_blisslink: CGFloat {
        ScreenAdapter_blisslink.adaptHeight_blisslink(self)
    }
    
    /// 字体大小适配
    var sp_blisslink: CGFloat {
        ScreenAdapter_blisslink.adaptFont_blisslink(self)
    }
}

extension Int {
    
    /// 宽度适配
    var w_blisslink: CGFloat {
        ScreenAdapter_blisslink.adaptWidth_blisslink(CGFloat(self))
    }
    
    /// 高度适配
    var h_blisslink: CGFloat {
        ScreenAdapter_blisslink.adaptHeight_blisslink(CGFloat(self))
    }
    
    /// 字体大小适配
    var sp_blisslink: CGFloat {
        ScreenAdapter_blisslink.adaptFont_blisslink(CGFloat(self))
    }
}

extension Double {
    
    /// 宽度适配
    var w_blisslink: CGFloat {
        ScreenAdapter_blisslink.adaptWidth_blisslink(CGFloat(self))
    }
    
    /// 高度适配
    var h_blisslink: CGFloat {
        ScreenAdapter_blisslink.adaptHeight_blisslink(CGFloat(self))
    }
    
    /// 字体大小适配
    var sp_blisslink: CGFloat {
        ScreenAdapter_blisslink.adaptFont_blisslink(CGFloat(self))
    }
}
