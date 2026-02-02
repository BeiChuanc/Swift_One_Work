import UIKit
import SwiftUI
import Combine

// MARK: - 屏幕尺寸管理

/// 屏幕尺寸管理类
class ScreenSize_baseswiftui: ObservableObject {
    
    /// 单例实例
    static let shared_baseswiftui = ScreenSize_baseswiftui()
    
    /// 屏幕宽度
    @Published var width_baseswiftui: CGFloat
    
    /// 屏幕高度
    @Published var height_baseswiftui: CGFloat
    
    /// 屏幕尺寸
    var size_baseswiftui: CGSize {
        CGSize(width: width_baseswiftui, height: height_baseswiftui)
    }
    
    /// 私有初始化方法
    private init() {
        // 获取屏幕尺寸
        let bounds_baseswiftui = Self.getCurrentScreenBounds_baseswiftui()
        self.width_baseswiftui = bounds_baseswiftui.width
        self.height_baseswiftui = bounds_baseswiftui.height
        
        // 监听屏幕尺寸变化（如旋转）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenSizeDidChange_baseswiftui),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    /// 获取当前屏幕边界
    private static func getCurrentScreenBounds_baseswiftui() -> CGRect {
        // 方法 1: 通过 connectedScenes 获取（iOS 13.0+）
        if let windowScene_baseswiftui = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) {
            
            // 优先使用 windowScene 的 screen
            return windowScene_baseswiftui.screen.bounds
        }
        
        // 方法 2: 尝试从任意活动的 windowScene 获取
        if let windowScene_baseswiftui = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
            return windowScene_baseswiftui.screen.bounds
        }
        
        // 方法 3: 降级方案 - 使用默认屏幕尺寸（iPhone 14/15）
        return CGRect(x: 0, y: 0, width: 390, height: 844)
    }
    
    /// 屏幕尺寸变化通知处理
    @objc private func screenSizeDidChange_baseswiftui() {
        let bounds_baseswiftui = Self.getCurrentScreenBounds_baseswiftui()
        DispatchQueue.main.async {
            self.width_baseswiftui = bounds_baseswiftui.width
            self.height_baseswiftui = bounds_baseswiftui.height
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

/// 屏幕尺寸常量（兼容旧代码）
enum APPSCREEN_baseswift {
    
    /// 屏幕宽度
    static var WIDTH_baseswift: CGFloat {
        ScreenSize_baseswiftui.shared_baseswiftui.width_baseswiftui
    }
    
    /// 屏幕高度
    static var HEIGHT_baseswift: CGFloat {
        ScreenSize_baseswiftui.shared_baseswiftui.height_baseswiftui
    }
}
