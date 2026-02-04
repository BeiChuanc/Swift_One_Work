import SwiftUI
import Combine

// MARK: - 工具类
// 核心作用：提供全局的提示、加载动画等工具方法
// 设计思路：使用 ObservableObject 管理 HUD 状态，支持各种提示类型
// 关键方法：showLoading（加载动画）、showSuccess（成功提示）、showError（错误提示）

/// HUD 类型枚举
enum HUDType_blisslink: Equatable {
    /// 加载中
    case loading_blisslink
    /// 成功
    case success_blisslink
    /// 错误
    case error_blisslink
    /// 警告
    case warning_blisslink
    /// 信息
    case info_blisslink
    /// 自定义
    case custom_blisslink(icon_blisslink: String)
    
    /// 实现 Equatable 协议
    static func == (lhs: HUDType_blisslink, rhs: HUDType_blisslink) -> Bool {
        switch (lhs, rhs) {
        case (.loading_blisslink, .loading_blisslink),
             (.success_blisslink, .success_blisslink),
             (.error_blisslink, .error_blisslink),
             (.warning_blisslink, .warning_blisslink),
             (.info_blisslink, .info_blisslink):
            return true
        case (.custom_blisslink(let lhsIcon), .custom_blisslink(let rhsIcon)):
            return lhsIcon == rhsIcon
        default:
            return false
        }
    }
}

/// HUD 配置
struct HUDConfig_blisslink {
    let type_blisslink: HUDType_blisslink
    let message_blisslink: String
    let duration_blisslink: TimeInterval
}

/// HUD 管理器
/// 用于管理应用中的所有提示和加载动画
class HUDManager_blisslink: ObservableObject {
    
    /// 单例实例
    static let shared_blisslink = HUDManager_blisslink()
    
    /// 是否显示 HUD
    @Published var isShowing_blisslink: Bool = false
    
    /// 当前 HUD 配置
    @Published var config_blisslink: HUDConfig_blisslink?
    
    /// 进度值（0-1）
    @Published var progress_blisslink: Double = 0
    
    /// 是否显示进度
    @Published var showProgress_blisslink: Bool = false
    
    /// 私有初始化
    private init() {}
    
    /// 显示 HUD
    func show_blisslink(type_blisslink: HUDType_blisslink, message_blisslink: String, duration_blisslink: TimeInterval = 0) {
        DispatchQueue.main.async {
            self.config_blisslink = HUDConfig_blisslink(
                type_blisslink: type_blisslink,
                message_blisslink: message_blisslink,
                duration_blisslink: duration_blisslink
            )
            self.showProgress_blisslink = false
            self.isShowing_blisslink = true
            
            // 如果设置了持续时间，自动隐藏
            if duration_blisslink > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration_blisslink) {
                    self.dismiss_blisslink()
                }
            }
        }
    }
    
    /// 显示进度
    func showProgress_blisslink(progress_blisslink: Double, message_blisslink: String) {
        DispatchQueue.main.async {
            self.progress_blisslink = progress_blisslink
            self.config_blisslink = HUDConfig_blisslink(
                type_blisslink: .loading_blisslink,
                message_blisslink: message_blisslink,
                duration_blisslink: 0
            )
            self.showProgress_blisslink = true
            self.isShowing_blisslink = true
        }
    }
    
    /// 隐藏 HUD
    func dismiss_blisslink() {
        DispatchQueue.main.async {
            self.isShowing_blisslink = false
            self.showProgress_blisslink = false
            self.progress_blisslink = 0
        }
    }
}

/// 工具类
/// 提供全局的提示、加载动画等静态方法
class Utils_blisslink {
    
    // MARK: - 加载动画
    
    /// 显示加载动画
    /// - Parameter message_blisslink: 提示文本
    static func showLoading_blisslink(message_blisslink: String = "Loading...") {
        HUDManager_blisslink.shared_blisslink.show_blisslink(
            type_blisslink: .loading_blisslink,
            message_blisslink: message_blisslink
        )
    }
    
    /// 显示带进度的加载动画
    /// - Parameters:
    ///   - progress_blisslink: 进度值（0-1）
    ///   - message_blisslink: 提示文本
    static func showProgress_blisslink(
        progress_blisslink: Double,
        message_blisslink: String = "Loading..."
    ) {
        HUDManager_blisslink.shared_blisslink.showProgress_blisslink(
            progress_blisslink: progress_blisslink,
            message_blisslink: message_blisslink
        )
    }
    
    /// 取消加载动画
    static func dismissLoading_blisslink() {
        HUDManager_blisslink.shared_blisslink.dismiss_blisslink()
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    /// - Parameters:
    ///   - message_blisslink: 提示文本
    ///   - image_blisslink: 图标（可选）
    ///   - delay_blisslink: 显示时长
    static func showSuccess_blisslink(
        message_blisslink: String = "Success",
        image_blisslink: UIImage? = nil,
        delay_blisslink: TimeInterval = 1.5
    ) {
        HUDManager_blisslink.shared_blisslink.show_blisslink(
            type_blisslink: .success_blisslink,
            message_blisslink: message_blisslink,
            duration_blisslink: delay_blisslink
        )
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    /// - Parameters:
    ///   - message_blisslink: 提示文本
    ///   - image_blisslink: 图标（可选）
    ///   - delay_blisslink: 显示时长
    static func showError_blisslink(
        message_blisslink: String = "Error",
        image_blisslink: UIImage? = nil,
        delay_blisslink: TimeInterval = 2.0
    ) {
        HUDManager_blisslink.shared_blisslink.show_blisslink(
            type_blisslink: .error_blisslink,
            message_blisslink: message_blisslink,
            duration_blisslink: delay_blisslink
        )
    }
    
    // MARK: - 警告提示
    
    /// 显示警告提示
    /// - Parameters:
    ///   - message_blisslink: 提示文本
    ///   - delay_blisslink: 显示时长
    static func showWarning_blisslink(
        message_blisslink: String,
        delay_blisslink: TimeInterval = 2.0
    ) {
        HUDManager_blisslink.shared_blisslink.show_blisslink(
            type_blisslink: .warning_blisslink,
            message_blisslink: message_blisslink,
            duration_blisslink: delay_blisslink
        )
    }
    
    // MARK: - 信息提示
    
    /// 显示信息提示
    /// - Parameters:
    ///   - message_blisslink: 提示文本
    ///   - delay_blisslink: 显示时长
    static func showInfo_blisslink(
        message_blisslink: String,
        delay_blisslink: TimeInterval = 1.5
    ) {
        HUDManager_blisslink.shared_blisslink.show_blisslink(
            type_blisslink: .info_blisslink,
            message_blisslink: message_blisslink,
            duration_blisslink: delay_blisslink
        )
    }
    
    // MARK: - 自定义提示
    
    /// 显示自定义图标提示
    /// - Parameters:
    ///   - message_blisslink: 提示文本
    ///   - symbolName_blisslink: SF Symbol 名称
    ///   - delay_blisslink: 显示时长
    static func showMessageWithSymbol_blisslink(
        message_blisslink: String,
        symbolName_blisslink: String,
        delay_blisslink: TimeInterval = 1.5
    ) {
        HUDManager_blisslink.shared_blisslink.show_blisslink(
            type_blisslink: .custom_blisslink(icon_blisslink: symbolName_blisslink),
            message_blisslink: message_blisslink,
            duration_blisslink: delay_blisslink
        )
    }
    
    // MARK: - 移除所有提示
    
    /// 移除所有 HUD
    static func removeAll_blisslink() {
        HUDManager_blisslink.shared_blisslink.dismiss_blisslink()
    }
}

// MARK: - HUD 视图组件

/// HUD 视图
/// 用于在应用中展示各种提示
struct HUDView_blisslink: View {
    
    @ObservedObject var manager_blisslink = HUDManager_blisslink.shared_blisslink
    
    var body: some View {
        ZStack {
            if manager_blisslink.isShowing_blisslink, let config = manager_blisslink.config_blisslink {
                // 背景遮罩
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // 点击遮罩不关闭 HUD（除非是非加载类型）
                        if config.type_blisslink != .loading_blisslink {
                            manager_blisslink.dismiss_blisslink()
                        }
                    }
                
                // HUD 内容
                hudContent_blisslink(config: config)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: manager_blisslink.isShowing_blisslink)
    }
    
    // MARK: - HUD 内容
    
    @ViewBuilder
    private func hudContent_blisslink(config: HUDConfig_blisslink) -> some View {
        VStack(spacing: 16) {
            // 图标
            iconView_blisslink(for: config.type_blisslink)
            
            // 消息文本
            if !config.message_blisslink.isEmpty {
                Text(config.message_blisslink)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // 进度条
            if manager_blisslink.showProgress_blisslink {
                ProgressView(value: manager_blisslink.progress_blisslink)
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .frame(width: 120)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.85))
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - 图标视图
    
    @ViewBuilder
    private func iconView_blisslink(for type: HUDType_blisslink) -> some View {
        switch type {
        case .loading_blisslink:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
        case .success_blisslink:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
        case .error_blisslink:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
        case .warning_blisslink:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
        case .info_blisslink:
            Image(systemName: "info.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
        case .custom_blisslink(let icon):
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
    }
}

// MARK: - View 扩展

extension View {
    /// 添加 HUD 覆盖层
    func hudOverlay_blisslink() -> some View {
        self.overlay(
            HUDView_blisslink()
        )
    }
}

// MARK: - Toast 管理器

/// Toast 类型枚举
enum ToastType_blisslink {
    case success_blisslink
    case error_blisslink
    case warning_blisslink
    case info_blisslink
}

/// Toast 配置
struct ToastConfig_blisslink {
    let type_blisslink: ToastType_blisslink
    let message_blisslink: String
}

/// Toast 管理器
/// 用于显示轻量级的提示信息
class ToastManager_blisslink: ObservableObject {
    
    /// 单例实例
    static let shared_blisslink = ToastManager_blisslink()
    
    /// 是否显示 Toast
    @Published var isShowing_blisslink: Bool = false
    
    /// Toast 配置
    @Published var config_blisslink: ToastConfig_blisslink?
    
    /// 私有初始化
    private init() {}
    
    /// 显示 Toast
    func show_blisslink(type_blisslink: ToastType_blisslink, message_blisslink: String, duration_blisslink: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            self.config_blisslink = ToastConfig_blisslink(
                type_blisslink: type_blisslink,
                message_blisslink: message_blisslink
            )
            self.isShowing_blisslink = true
            
            // 自动隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + duration_blisslink) {
                self.dismiss_blisslink()
            }
        }
    }
    
    /// 隐藏 Toast
    func dismiss_blisslink() {
        DispatchQueue.main.async {
            self.isShowing_blisslink = false
        }
    }
}

// MARK: - Toast 视图

/// Toast 视图
struct ToastView_blisslink: View {
    
    @ObservedObject var manager_blisslink = ToastManager_blisslink.shared_blisslink
    
    var body: some View {
        VStack {
            Spacer()
            
            if manager_blisslink.isShowing_blisslink, let config = manager_blisslink.config_blisslink {
                HStack(spacing: 12) {
                    // 图标
                    iconView_blisslink(for: config.type_blisslink)
                    
                    // 文本
                    Text(config.message_blisslink)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.85))
                )
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: manager_blisslink.isShowing_blisslink)
    }
    
    @ViewBuilder
    private func iconView_blisslink(for type: ToastType_blisslink) -> some View {
        Group {
            switch type {
            case .success_blisslink:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .error_blisslink:
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            case .warning_blisslink:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
            case .info_blisslink:
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .font(.system(size: 20))
    }
}

extension View {
    /// 添加 Toast 覆盖层
    func toastOverlay_blisslink() -> some View {
        self.overlay(
            ToastView_blisslink(),
            alignment: .bottom
        )
    }
}
