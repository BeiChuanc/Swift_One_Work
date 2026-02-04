import SwiftUI

// MARK: - SwiftUI 屏幕尺寸扩展

/// 屏幕尺寸环境键
private struct ScreenSizeKey_lite: EnvironmentKey {
    static let defaultValue: CGSize = {
        ScreenSize_lite.shared_lite.size_lite
    }()
}

extension EnvironmentValues {
    /// 屏幕尺寸环境值
    var screenSize_lite: CGSize {
        get { self[ScreenSizeKey_lite.self] }
        set { self[ScreenSizeKey_lite.self] = newValue }
    }
}

// MARK: - View 扩展

extension View {
    
    /// 获取屏幕宽度（便捷方法）
    var screenWidth_lite: CGFloat {
        ScreenSize_lite.shared_lite.width_lite
    }
    
    /// 获取屏幕高度（便捷方法）
    var screenHeight_lite: CGFloat {
        ScreenSize_lite.shared_lite.height_lite
    }
    
    /// 根据屏幕宽度计算比例尺寸
    func widthRatio_lite(_ ratio_lite: CGFloat) -> CGFloat {
        screenWidth_lite * ratio_lite
    }
    
    /// 根据屏幕高度计算比例尺寸
    func heightRatio_lite(_ ratio_lite: CGFloat) -> CGFloat {
        screenHeight_lite * ratio_lite
    }
}

// MARK: - 屏幕适配常量

/// 屏幕适配工具
enum ScreenAdapter_lite {
    
    /// 基准屏幕宽度（iPhone 14/15 标准尺寸）
    private static let baseWidth_lite: CGFloat = 390.0
    
    /// 基准屏幕高度（iPhone 14/15 标准尺寸）
    private static let baseHeight_lite: CGFloat = 844.0
    
    /// 宽度适配比例
    static var widthRatio_lite: CGFloat {
        ScreenSize_lite.shared_lite.width_lite / baseWidth_lite
    }
    
    /// 高度适配比例
    static var heightRatio_lite: CGFloat {
        ScreenSize_lite.shared_lite.height_lite / baseHeight_lite
    }
    
    /// 适配宽度
    static func adaptWidth_lite(_ value_lite: CGFloat) -> CGFloat {
        return value_lite * widthRatio_lite
    }
    
    /// 适配高度
    static func adaptHeight_lite(_ value_lite: CGFloat) -> CGFloat {
        return value_lite * heightRatio_lite
    }
    
    /// 适配字体大小
    static func adaptFont_lite(_ size_lite: CGFloat) -> CGFloat {
        return size_lite * min(widthRatio_lite, heightRatio_lite)
    }
}

// MARK: - CGFloat 扩展

extension CGFloat {
    
    /// 宽度适配
    var w_lite: CGFloat {
        ScreenAdapter_lite.adaptWidth_lite(self)
    }
    
    /// 高度适配
    var h_lite: CGFloat {
        ScreenAdapter_lite.adaptHeight_lite(self)
    }
    
    /// 字体大小适配
    var sp_lite: CGFloat {
        ScreenAdapter_lite.adaptFont_lite(self)
    }
}

extension Int {
    
    /// 宽度适配
    var w_lite: CGFloat {
        ScreenAdapter_lite.adaptWidth_lite(CGFloat(self))
    }
    
    /// 高度适配
    var h_lite: CGFloat {
        ScreenAdapter_lite.adaptHeight_lite(CGFloat(self))
    }
    
    /// 字体大小适配
    var sp_lite: CGFloat {
        ScreenAdapter_lite.adaptFont_lite(CGFloat(self))
    }
}

extension Double {
    
    /// 宽度适配
    var w_lite: CGFloat {
        ScreenAdapter_lite.adaptWidth_lite(CGFloat(self))
    }
    
    /// 高度适配
    var h_lite: CGFloat {
        ScreenAdapter_lite.adaptHeight_lite(CGFloat(self))
    }
    
    /// 字体大小适配
    var sp_lite: CGFloat {
        ScreenAdapter_lite.adaptFont_lite(CGFloat(self))
    }
}
