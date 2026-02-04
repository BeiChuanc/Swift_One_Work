import UIKit
import SwiftUI
import Combine

// MARK: - 屏幕尺寸管理

/// 屏幕尺寸管理类
class ScreenSize_blisslink: ObservableObject {
    
    /// 单例实例
    static let shared_blisslink = ScreenSize_blisslink()
    
    /// 屏幕宽度
    @Published var width_blisslink: CGFloat
    
    /// 屏幕高度
    @Published var height_blisslink: CGFloat
    
    /// 屏幕尺寸
    var size_blisslink: CGSize {
        CGSize(width: width_blisslink, height: height_blisslink)
    }
    
    /// 私有初始化方法
    private init() {
        // 获取屏幕尺寸
        let bounds_blisslink = Self.getCurrentScreenBounds_blisslink()
        self.width_blisslink = bounds_blisslink.width
        self.height_blisslink = bounds_blisslink.height
        
        // 监听屏幕尺寸变化（如旋转）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenSizeDidChange_blisslink),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    /// 获取当前屏幕边界
    private static func getCurrentScreenBounds_blisslink() -> CGRect {
        // 方法 1: 通过 connectedScenes 获取（iOS 13.0+）
        if let windowScene_blisslink = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) {
            
            // 优先使用 windowScene 的 screen
            return windowScene_blisslink.screen.bounds
        }
        
        // 方法 2: 尝试从任意活动的 windowScene 获取
        if let windowScene_blisslink = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
            return windowScene_blisslink.screen.bounds
        }
        
        // 方法 3: 降级方案 - 使用默认屏幕尺寸（iPhone 14/15）
        return CGRect(x: 0, y: 0, width: 390, height: 844)
    }
    
    /// 屏幕尺寸变化通知处理
    @objc private func screenSizeDidChange_blisslink() {
        let bounds_blisslink = Self.getCurrentScreenBounds_blisslink()
        DispatchQueue.main.async {
            self.width_blisslink = bounds_blisslink.width
            self.height_blisslink = bounds_blisslink.height
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
        ScreenSize_blisslink.shared_blisslink.width_blisslink
    }
    
    /// 屏幕高度
    static var HEIGHT_baseswift: CGFloat {
        ScreenSize_blisslink.shared_blisslink.height_blisslink
    }
}
