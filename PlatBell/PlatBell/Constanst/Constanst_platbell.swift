import UIKit
import SwiftUI
import Combine

// MARK: - 屏幕尺寸管理

/// 屏幕尺寸管理类
class ScreenSize_platbell: ObservableObject {
    
    /// 单例实例
    static let shared_platbell = ScreenSize_platbell()
    
    /// 屏幕宽度
    @Published var width_platbell: CGFloat
    
    /// 屏幕高度
    @Published var height_platbell: CGFloat
    
    /// 屏幕尺寸
    var size_platbell: CGSize {
        CGSize(width: width_platbell, height: height_platbell)
    }
    
    /// 私有初始化方法
    private init() {
        // 获取屏幕尺寸
        let bounds_platbell = Self.getCurrentScreenBounds_platbell()
        self.width_platbell = bounds_platbell.width
        self.height_platbell = bounds_platbell.height
        
        // 监听屏幕尺寸变化（如旋转）
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenSizeDidChange_platbell),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    /// 获取当前屏幕边界
    private static func getCurrentScreenBounds_platbell() -> CGRect {
        // 方法 1: 通过 connectedScenes 获取（iOS 13.0+）
        if let windowScene_platbell = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) {
            
            // 优先使用 windowScene 的 screen
            return windowScene_platbell.screen.bounds
        }
        
        // 方法 2: 尝试从任意活动的 windowScene 获取
        if let windowScene_platbell = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
            return windowScene_platbell.screen.bounds
        }
        
        // 方法 3: 降级方案 - 使用默认屏幕尺寸（iPhone 14/15）
        return CGRect(x: 0, y: 0, width: 390, height: 844)
    }
    
    /// 屏幕尺寸变化通知处理
    @objc private func screenSizeDidChange_platbell() {
        let bounds_platbell = Self.getCurrentScreenBounds_platbell()
        DispatchQueue.main.async {
            self.width_platbell = bounds_platbell.width
            self.height_platbell = bounds_platbell.height
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
        ScreenSize_platbell.shared_platbell.width_platbell
    }
    
    /// 屏幕高度
    static var HEIGHT_baseswift: CGFloat {
        ScreenSize_platbell.shared_platbell.height_platbell
    }
}

// MARK: - 媒体展示配置

/// 媒体展示配置常量
enum MediaConfig_platbell {
    
    /// 渐变色方案集合
    /// 用于系统图标背景和占位符
    static let gradientColorSchemes_platbell: [[Color]] = [
        [Color(hex: "667eea"), Color(hex: "764ba2")],  // 紫色
        [Color(hex: "f093fb"), Color(hex: "f5576c")],  // 粉红
        [Color(hex: "4facfe"), Color(hex: "00f2fe")],  // 蓝色
        [Color(hex: "43e97b"), Color(hex: "38f9d7")],  // 绿色
        [Color(hex: "fa709a"), Color(hex: "fee140")]   // 暖色
    ]
    
    /// 根据字符串哈希值获取渐变色方案
    /// - Parameter identifier_platbell: 标识字符串
    /// - Returns: 渐变色数组
    static func getGradientColors_platbell(for identifier_platbell: String) -> [Color] {
        let index_platbell = abs(identifier_platbell.hashValue) % gradientColorSchemes_platbell.count
        return gradientColorSchemes_platbell[index_platbell]
    }
}
