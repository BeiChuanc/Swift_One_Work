import SwiftUI
import Combine

// MARK: - 工具类
// 核心作用：提供全局的提示、加载动画等工具方法
// 设计思路：使用 ObservableObject 管理 HUD 状态，支持各种提示类型
// 关键方法：showLoading（加载动画）、showSuccess（成功提示）、showError（错误提示）

/// HUD 类型枚举
enum HUDType_baseswiftui: Equatable {
    /// 加载中
    case loading_baseswiftui
    /// 成功
    case success_baseswiftui
    /// 错误
    case error_baseswiftui
    /// 警告
    case warning_baseswiftui
    /// 信息
    case info_baseswiftui
    /// 自定义
    case custom_baseswiftui(icon_baseswiftui: String)
    
    /// 实现 Equatable 协议
    static func == (lhs: HUDType_baseswiftui, rhs: HUDType_baseswiftui) -> Bool {
        switch (lhs, rhs) {
        case (.loading_baseswiftui, .loading_baseswiftui),
             (.success_baseswiftui, .success_baseswiftui),
             (.error_baseswiftui, .error_baseswiftui),
             (.warning_baseswiftui, .warning_baseswiftui),
             (.info_baseswiftui, .info_baseswiftui):
            return true
        case (.custom_baseswiftui(let lhsIcon), .custom_baseswiftui(let rhsIcon)):
            return lhsIcon == rhsIcon
        default:
            return false
        }
    }
}

/// HUD 配置
struct HUDConfig_baseswiftui {
    let type_baseswiftui: HUDType_baseswiftui
    let message_baseswiftui: String
    let duration_baseswiftui: TimeInterval
}

/// HUD 管理器
/// 用于管理应用中的所有提示和加载动画
class HUDManager_baseswiftui: ObservableObject {
    
    /// 单例实例
    static let shared_baseswiftui = HUDManager_baseswiftui()
    
    /// 是否显示 HUD
    @Published var isShowing_baseswiftui: Bool = false
    
    /// 当前 HUD 配置
    @Published var config_baseswiftui: HUDConfig_baseswiftui?
    
    /// 进度值（0-1）
    @Published var progress_baseswiftui: Double = 0
    
    /// 是否显示进度
    @Published var showProgress_baseswiftui: Bool = false
    
    /// 私有初始化
    private init() {}
    
    /// 显示 HUD
    func show_baseswiftui(type_baseswiftui: HUDType_baseswiftui, message_baseswiftui: String, duration_baseswiftui: TimeInterval = 0) {
        DispatchQueue.main.async {
            self.config_baseswiftui = HUDConfig_baseswiftui(
                type_baseswiftui: type_baseswiftui,
                message_baseswiftui: message_baseswiftui,
                duration_baseswiftui: duration_baseswiftui
            )
            self.showProgress_baseswiftui = false
            self.isShowing_baseswiftui = true
            
            // 如果设置了持续时间，自动隐藏
            if duration_baseswiftui > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration_baseswiftui) {
                    self.dismiss_baseswiftui()
                }
            }
        }
    }
    
    /// 显示进度
    func showProgress_baseswiftui(progress_baseswiftui: Double, message_baseswiftui: String) {
        DispatchQueue.main.async {
            self.progress_baseswiftui = progress_baseswiftui
            self.config_baseswiftui = HUDConfig_baseswiftui(
                type_baseswiftui: .loading_baseswiftui,
                message_baseswiftui: message_baseswiftui,
                duration_baseswiftui: 0
            )
            self.showProgress_baseswiftui = true
            self.isShowing_baseswiftui = true
        }
    }
    
    /// 隐藏 HUD
    func dismiss_baseswiftui() {
        DispatchQueue.main.async {
            self.isShowing_baseswiftui = false
            self.showProgress_baseswiftui = false
            self.progress_baseswiftui = 0
        }
    }
}

/// 工具类
/// 提供全局的提示、加载动画等静态方法
class Utils_baseswiftui {
    
    // MARK: - 加载动画
    
    /// 显示加载动画
    /// - Parameter message_baseswiftui: 提示文本
    static func showLoading_baseswiftui(message_baseswiftui: String = "Loading...") {
        HUDManager_baseswiftui.shared_baseswiftui.show_baseswiftui(
            type_baseswiftui: .loading_baseswiftui,
            message_baseswiftui: message_baseswiftui
        )
    }
    
    /// 显示带进度的加载动画
    /// - Parameters:
    ///   - progress_baseswiftui: 进度值（0-1）
    ///   - message_baseswiftui: 提示文本
    static func showProgress_baseswiftui(
        progress_baseswiftui: Double,
        message_baseswiftui: String = "Loading..."
    ) {
        HUDManager_baseswiftui.shared_baseswiftui.showProgress_baseswiftui(
            progress_baseswiftui: progress_baseswiftui,
            message_baseswiftui: message_baseswiftui
        )
    }
    
    /// 取消加载动画
    static func dismissLoading_baseswiftui() {
        HUDManager_baseswiftui.shared_baseswiftui.dismiss_baseswiftui()
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    /// - Parameters:
    ///   - message_baseswiftui: 提示文本
    ///   - image_baseswiftui: 图标（可选）
    ///   - delay_baseswiftui: 显示时长
    static func showSuccess_baseswiftui(
        message_baseswiftui: String = "Success",
        image_baseswiftui: UIImage? = nil,
        delay_baseswiftui: TimeInterval = 1.5
    ) {
        HUDManager_baseswiftui.shared_baseswiftui.show_baseswiftui(
            type_baseswiftui: .success_baseswiftui,
            message_baseswiftui: message_baseswiftui,
            duration_baseswiftui: delay_baseswiftui
        )
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    /// - Parameters:
    ///   - message_baseswiftui: 提示文本
    ///   - image_baseswiftui: 图标（可选）
    ///   - delay_baseswiftui: 显示时长
    static func showError_baseswiftui(
        message_baseswiftui: String = "Error",
        image_baseswiftui: UIImage? = nil,
        delay_baseswiftui: TimeInterval = 2.0
    ) {
        HUDManager_baseswiftui.shared_baseswiftui.show_baseswiftui(
            type_baseswiftui: .error_baseswiftui,
            message_baseswiftui: message_baseswiftui,
            duration_baseswiftui: delay_baseswiftui
        )
    }
    
    // MARK: - 警告提示
    
    /// 显示警告提示
    /// - Parameters:
    ///   - message_baseswiftui: 提示文本
    ///   - delay_baseswiftui: 显示时长
    static func showWarning_baseswiftui(
        message_baseswiftui: String,
        delay_baseswiftui: TimeInterval = 2.0
    ) {
        HUDManager_baseswiftui.shared_baseswiftui.show_baseswiftui(
            type_baseswiftui: .warning_baseswiftui,
            message_baseswiftui: message_baseswiftui,
            duration_baseswiftui: delay_baseswiftui
        )
    }
    
    // MARK: - 信息提示
    
    /// 显示信息提示
    /// - Parameters:
    ///   - message_baseswiftui: 提示文本
    ///   - delay_baseswiftui: 显示时长
    static func showInfo_baseswiftui(
        message_baseswiftui: String,
        delay_baseswiftui: TimeInterval = 1.5
    ) {
        HUDManager_baseswiftui.shared_baseswiftui.show_baseswiftui(
            type_baseswiftui: .info_baseswiftui,
            message_baseswiftui: message_baseswiftui,
            duration_baseswiftui: delay_baseswiftui
        )
    }
    
    // MARK: - 自定义提示
    
    /// 显示自定义图标提示
    /// - Parameters:
    ///   - message_baseswiftui: 提示文本
    ///   - symbolName_baseswiftui: SF Symbol 名称
    ///   - delay_baseswiftui: 显示时长
    static func showMessageWithSymbol_baseswiftui(
        message_baseswiftui: String,
        symbolName_baseswiftui: String,
        delay_baseswiftui: TimeInterval = 1.5
    ) {
        HUDManager_baseswiftui.shared_baseswiftui.show_baseswiftui(
            type_baseswiftui: .custom_baseswiftui(icon_baseswiftui: symbolName_baseswiftui),
            message_baseswiftui: message_baseswiftui,
            duration_baseswiftui: delay_baseswiftui
        )
    }
    
    // MARK: - 移除所有提示
    
    /// 移除所有 HUD
    static func removeAll_baseswiftui() {
        HUDManager_baseswiftui.shared_baseswiftui.dismiss_baseswiftui()
    }
}

// MARK: - HUD 视图组件

/// HUD 视图
/// 用于在应用中展示各种提示
struct HUDView_baseswiftui: View {
    
    @ObservedObject var manager_baseswiftui = HUDManager_baseswiftui.shared_baseswiftui
    
    var body: some View {
        ZStack {
            if manager_baseswiftui.isShowing_baseswiftui, let config = manager_baseswiftui.config_baseswiftui {
                // 背景遮罩
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // 点击遮罩不关闭 HUD（除非是非加载类型）
                        if config.type_baseswiftui != .loading_baseswiftui {
                            manager_baseswiftui.dismiss_baseswiftui()
                        }
                    }
                
                // HUD 内容
                hudContent_baseswiftui(config: config)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: manager_baseswiftui.isShowing_baseswiftui)
    }
    
    // MARK: - HUD 内容
    
    @ViewBuilder
    private func hudContent_baseswiftui(config: HUDConfig_baseswiftui) -> some View {
        VStack(spacing: 16) {
            // 图标
            iconView_baseswiftui(for: config.type_baseswiftui)
            
            // 消息文本
            if !config.message_baseswiftui.isEmpty {
                Text(config.message_baseswiftui)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // 进度条
            if manager_baseswiftui.showProgress_baseswiftui {
                ProgressView(value: manager_baseswiftui.progress_baseswiftui)
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
    private func iconView_baseswiftui(for type: HUDType_baseswiftui) -> some View {
        switch type {
        case .loading_baseswiftui:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
        case .success_baseswiftui:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
        case .error_baseswiftui:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
        case .warning_baseswiftui:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
        case .info_baseswiftui:
            Image(systemName: "info.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
        case .custom_baseswiftui(let icon):
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
    }
}

// MARK: - View 扩展

extension View {
    /// 添加 HUD 覆盖层
    func hudOverlay_baseswiftui() -> some View {
        self.overlay(
            HUDView_baseswiftui()
        )
    }
}

// MARK: - Toast 管理器

/// Toast 类型枚举
enum ToastType_baseswiftui {
    case success_baseswiftui
    case error_baseswiftui
    case warning_baseswiftui
    case info_baseswiftui
}

/// Toast 配置
struct ToastConfig_baseswiftui {
    let type_baseswiftui: ToastType_baseswiftui
    let message_baseswiftui: String
}

/// Toast 管理器
/// 用于显示轻量级的提示信息
class ToastManager_baseswiftui: ObservableObject {
    
    /// 单例实例
    static let shared_baseswiftui = ToastManager_baseswiftui()
    
    /// 是否显示 Toast
    @Published var isShowing_baseswiftui: Bool = false
    
    /// Toast 配置
    @Published var config_baseswiftui: ToastConfig_baseswiftui?
    
    /// 私有初始化
    private init() {}
    
    /// 显示 Toast
    func show_baseswiftui(type_baseswiftui: ToastType_baseswiftui, message_baseswiftui: String, duration_baseswiftui: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            self.config_baseswiftui = ToastConfig_baseswiftui(
                type_baseswiftui: type_baseswiftui,
                message_baseswiftui: message_baseswiftui
            )
            self.isShowing_baseswiftui = true
            
            // 自动隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + duration_baseswiftui) {
                self.dismiss_baseswiftui()
            }
        }
    }
    
    /// 隐藏 Toast
    func dismiss_baseswiftui() {
        DispatchQueue.main.async {
            self.isShowing_baseswiftui = false
        }
    }
}

// MARK: - Toast 视图

/// Toast 视图
struct ToastView_baseswiftui: View {
    
    @ObservedObject var manager_baseswiftui = ToastManager_baseswiftui.shared_baseswiftui
    
    var body: some View {
        VStack {
            Spacer()
            
            if manager_baseswiftui.isShowing_baseswiftui, let config = manager_baseswiftui.config_baseswiftui {
                HStack(spacing: 12) {
                    // 图标
                    iconView_baseswiftui(for: config.type_baseswiftui)
                    
                    // 文本
                    Text(config.message_baseswiftui)
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
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: manager_baseswiftui.isShowing_baseswiftui)
    }
    
    @ViewBuilder
    private func iconView_baseswiftui(for type: ToastType_baseswiftui) -> some View {
        Group {
            switch type {
            case .success_baseswiftui:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .error_baseswiftui:
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            case .warning_baseswiftui:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
            case .info_baseswiftui:
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .font(.system(size: 20))
    }
}

extension View {
    /// 添加 Toast 覆盖层
    func toastOverlay_baseswiftui() -> some View {
        self.overlay(
            ToastView_baseswiftui(),
            alignment: .bottom
        )
    }
}

// MARK: - 媒体工具类

import AVKit

/// 媒体工具类
/// 提供图片加载、视频缩略图生成等媒体处理功能
class MediaUtils_baseswiftui {
    
    // MARK: - 系统图标判断
    
    /// 判断是否是系统图标（SF Symbol）
    /// - Parameter name_baseswiftui: 图标名称
    /// - Returns: 是否是有效的系统图标
    static func isSystemIcon_baseswiftui(name_baseswiftui: String) -> Bool {
        return UIImage(systemName: name_baseswiftui) != nil
    }
    
    // MARK: - 图片加载
    
    /// 从文档目录加载图片
    /// - Parameter imageName_baseswiftui: 图片名称（可能带或不带扩展名）
    /// - Returns: UIImage 或 nil
    static func loadImageFromDocuments_baseswiftui(imageName_baseswiftui: String) -> UIImage? {
        let fileManager_baseswiftui = FileManager.default
        guard let documentsDirectory_baseswiftui = fileManager_baseswiftui.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("⚠️ 无法获取文档目录")
            return nil
        }
        
        // 尝试带 .jpg 扩展名
        var fileURL_baseswiftui = documentsDirectory_baseswiftui.appendingPathComponent("\(imageName_baseswiftui).jpg")
        if let image_baseswiftui = UIImage(contentsOfFile: fileURL_baseswiftui.path) {
            print("✅ 从文档目录加载图片：\(imageName_baseswiftui).jpg")
            return image_baseswiftui
        }
        
        // 尝试带 .png 扩展名
        fileURL_baseswiftui = documentsDirectory_baseswiftui.appendingPathComponent("\(imageName_baseswiftui).png")
        if let image_baseswiftui = UIImage(contentsOfFile: fileURL_baseswiftui.path) {
            print("✅ 从文档目录加载图片：\(imageName_baseswiftui).png")
            return image_baseswiftui
        }
        
        // 尝试不带扩展名（文件名本身可能已包含扩展名）
        fileURL_baseswiftui = documentsDirectory_baseswiftui.appendingPathComponent(imageName_baseswiftui)
        if let image_baseswiftui = UIImage(contentsOfFile: fileURL_baseswiftui.path) {
            print("✅ 从文档目录加载图片：\(imageName_baseswiftui)")
            return image_baseswiftui
        }
        
        print("⚠️ 无法从文档目录加载图片：\(imageName_baseswiftui)")
        return nil
    }
    
    // MARK: - 视频缩略图生成
    
    /// 从Bundle中的视频文件生成缩略图
    /// - Parameters:
    ///   - videoName_baseswiftui: 视频文件名（不带扩展名或带.mp4扩展名）
    ///   - time_baseswiftui: 截取时间点（秒），默认1.0秒
    /// - Returns: UIImage 或 nil
    static func loadVideoThumbnail_baseswiftui(
        videoName_baseswiftui: String,
        time_baseswiftui: Double = 1.0
    ) -> UIImage? {
        // 1. 处理文件名，确保有.mp4扩展名
        let fileName_baseswiftui: String
        if videoName_baseswiftui.hasSuffix(".mp4") {
            fileName_baseswiftui = videoName_baseswiftui
        } else {
            fileName_baseswiftui = "\(videoName_baseswiftui).mp4"
        }
        
        // 2. 从主Bundle中查找视频文件
        let resourceName_baseswiftui = fileName_baseswiftui.replacingOccurrences(of: ".mp4", with: "")
        guard let videoPath_baseswiftui = Bundle.main.path(
            forResource: resourceName_baseswiftui,
            ofType: "mp4"
        ) else {
            print("⚠️ 无法在Bundle中找到视频文件：\(fileName_baseswiftui)")
            return nil
        }
        
        return generateThumbnail_baseswiftui(
            from: URL(fileURLWithPath: videoPath_baseswiftui),
            at: time_baseswiftui
        )
    }
    
    /// 从视频URL生成缩略图
    /// - Parameters:
    ///   - videoURL_baseswiftui: 视频URL
    ///   - time_baseswiftui: 截取时间点（秒）
    /// - Returns: UIImage 或 nil
    static func generateThumbnail_baseswiftui(
        from videoURL_baseswiftui: URL,
        at time_baseswiftui: Double
    ) -> UIImage? {
        // 创建 AVAsset
        let asset_baseswiftui = AVAsset(url: videoURL_baseswiftui)
        let imageGenerator_baseswiftui = AVAssetImageGenerator(asset: asset_baseswiftui)
        imageGenerator_baseswiftui.appliesPreferredTrackTransform = true  // 保持视频方向
        
        // 设置生成缩略图的时间点
        let cmTime_baseswiftui = CMTime(seconds: time_baseswiftui, preferredTimescale: 600)
        
        do {
            let cgImage_baseswiftui = try imageGenerator_baseswiftui.copyCGImage(
                at: cmTime_baseswiftui,
                actualTime: nil
            )
            let thumbnail_baseswiftui = UIImage(cgImage: cgImage_baseswiftui)
            print("✅ 成功生成视频缩略图")
            return thumbnail_baseswiftui
        } catch {
            print("❌ 生成视频缩略图失败：\(error.localizedDescription)")
            return nil
        }
    }
}
