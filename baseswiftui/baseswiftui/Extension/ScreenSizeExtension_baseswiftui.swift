import SwiftUI

// MARK: - SwiftUI 屏幕尺寸扩展

/// 屏幕尺寸环境键
private struct ScreenSizeKey_baseswiftui: EnvironmentKey {
    static let defaultValue: CGSize = {
        ScreenSize_baseswiftui.shared_baseswiftui.size_baseswiftui
    }()
}

extension EnvironmentValues {
    /// 屏幕尺寸环境值
    var screenSize_baseswiftui: CGSize {
        get { self[ScreenSizeKey_baseswiftui.self] }
        set { self[ScreenSizeKey_baseswiftui.self] = newValue }
    }
}

// MARK: - View 扩展

extension View {
    
    /// 获取屏幕宽度（便捷方法）
    var screenWidth_baseswiftui: CGFloat {
        ScreenSize_baseswiftui.shared_baseswiftui.width_baseswiftui
    }
    
    /// 获取屏幕高度（便捷方法）
    var screenHeight_baseswiftui: CGFloat {
        ScreenSize_baseswiftui.shared_baseswiftui.height_baseswiftui
    }
    
    /// 根据屏幕宽度计算比例尺寸
    func widthRatio_baseswiftui(_ ratio_baseswiftui: CGFloat) -> CGFloat {
        screenWidth_baseswiftui * ratio_baseswiftui
    }
    
    /// 根据屏幕高度计算比例尺寸
    func heightRatio_baseswiftui(_ ratio_baseswiftui: CGFloat) -> CGFloat {
        screenHeight_baseswiftui * ratio_baseswiftui
    }
}

// MARK: - 屏幕适配常量

/// 屏幕适配工具
enum ScreenAdapter_baseswiftui {
    
    /// 基准屏幕宽度（iPhone 14/15 标准尺寸）
    private static let baseWidth_baseswiftui: CGFloat = 390.0
    
    /// 基准屏幕高度（iPhone 14/15 标准尺寸）
    private static let baseHeight_baseswiftui: CGFloat = 844.0
    
    /// 宽度适配比例
    static var widthRatio_baseswiftui: CGFloat {
        ScreenSize_baseswiftui.shared_baseswiftui.width_baseswiftui / baseWidth_baseswiftui
    }
    
    /// 高度适配比例
    static var heightRatio_baseswiftui: CGFloat {
        ScreenSize_baseswiftui.shared_baseswiftui.height_baseswiftui / baseHeight_baseswiftui
    }
    
    /// 适配宽度
    static func adaptWidth_baseswiftui(_ value_baseswiftui: CGFloat) -> CGFloat {
        return value_baseswiftui * widthRatio_baseswiftui
    }
    
    /// 适配高度
    static func adaptHeight_baseswiftui(_ value_baseswiftui: CGFloat) -> CGFloat {
        return value_baseswiftui * heightRatio_baseswiftui
    }
    
    /// 适配字体大小
    static func adaptFont_baseswiftui(_ size_baseswiftui: CGFloat) -> CGFloat {
        return size_baseswiftui * min(widthRatio_baseswiftui, heightRatio_baseswiftui)
    }
}

// MARK: - CGFloat 扩展

extension CGFloat {
    
    /// 宽度适配
    var w_baseswiftui: CGFloat {
        ScreenAdapter_baseswiftui.adaptWidth_baseswiftui(self)
    }
    
    /// 高度适配
    var h_baseswiftui: CGFloat {
        ScreenAdapter_baseswiftui.adaptHeight_baseswiftui(self)
    }
    
    /// 字体大小适配
    var sp_baseswiftui: CGFloat {
        ScreenAdapter_baseswiftui.adaptFont_baseswiftui(self)
    }
}

extension Int {
    
    /// 宽度适配
    var w_baseswiftui: CGFloat {
        ScreenAdapter_baseswiftui.adaptWidth_baseswiftui(CGFloat(self))
    }
    
    /// 高度适配
    var h_baseswiftui: CGFloat {
        ScreenAdapter_baseswiftui.adaptHeight_baseswiftui(CGFloat(self))
    }
    
    /// 字体大小适配
    var sp_baseswiftui: CGFloat {
        ScreenAdapter_baseswiftui.adaptFont_baseswiftui(CGFloat(self))
    }
}

extension Double {
    
    /// 宽度适配
    var w_baseswiftui: CGFloat {
        ScreenAdapter_baseswiftui.adaptWidth_baseswiftui(CGFloat(self))
    }
    
    /// 高度适配
    var h_baseswiftui: CGFloat {
        ScreenAdapter_baseswiftui.adaptHeight_baseswiftui(CGFloat(self))
    }
    
    /// 字体大小适配
    var sp_baseswiftui: CGFloat {
        ScreenAdapter_baseswiftui.adaptFont_baseswiftui(CGFloat(self))
    }
}
