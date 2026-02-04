import SwiftUI
import Combine

// MARK: - 工具类
// 核心作用：提供全局的提示、加载动画等工具方法
// 设计思路：使用 ObservableObject 管理 HUD 状态，支持各种提示类型
// 关键方法：showLoading（加载动画）、showSuccess（成功提示）、showError（错误提示）

/// HUD 类型枚举
enum HUDType_lite: Equatable {
    /// 加载中
    case loading_lite
    /// 成功
    case success_lite
    /// 错误
    case error_lite
    /// 警告
    case warning_lite
    /// 信息
    case info_lite
    /// 自定义
    case custom_lite(icon_lite: String)
    
    /// 实现 Equatable 协议
    static func == (lhs: HUDType_lite, rhs: HUDType_lite) -> Bool {
        switch (lhs, rhs) {
        case (.loading_lite, .loading_lite),
             (.success_lite, .success_lite),
             (.error_lite, .error_lite),
             (.warning_lite, .warning_lite),
             (.info_lite, .info_lite):
            return true
        case (.custom_lite(let lhsIcon), .custom_lite(let rhsIcon)):
            return lhsIcon == rhsIcon
        default:
            return false
        }
    }
}

/// HUD 配置
struct HUDConfig_lite {
    let type_lite: HUDType_lite
    let message_lite: String
    let duration_lite: TimeInterval
}

/// HUD 管理器
/// 用于管理应用中的所有提示和加载动画
class HUDManager_lite: ObservableObject {
    
    /// 单例实例
    static let shared_lite = HUDManager_lite()
    
    /// 是否显示 HUD
    @Published var isShowing_lite: Bool = false
    
    /// 当前 HUD 配置
    @Published var config_lite: HUDConfig_lite?
    
    /// 进度值（0-1）
    @Published var progress_lite: Double = 0
    
    /// 是否显示进度
    @Published var showProgress_lite: Bool = false
    
    /// 私有初始化
    private init() {}
    
    /// 显示 HUD
    func show_lite(type_lite: HUDType_lite, message_lite: String, duration_lite: TimeInterval = 0) {
        DispatchQueue.main.async {
            self.config_lite = HUDConfig_lite(
                type_lite: type_lite,
                message_lite: message_lite,
                duration_lite: duration_lite
            )
            self.showProgress_lite = false
            self.isShowing_lite = true
            
            // 如果设置了持续时间，自动隐藏
            if duration_lite > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration_lite) {
                    self.dismiss_lite()
                }
            }
        }
    }
    
    /// 显示进度
    func showProgress_lite(progress_lite: Double, message_lite: String) {
        DispatchQueue.main.async {
            self.progress_lite = progress_lite
            self.config_lite = HUDConfig_lite(
                type_lite: .loading_lite,
                message_lite: message_lite,
                duration_lite: 0
            )
            self.showProgress_lite = true
            self.isShowing_lite = true
        }
    }
    
    /// 隐藏 HUD
    func dismiss_lite() {
        DispatchQueue.main.async {
            self.isShowing_lite = false
            self.showProgress_lite = false
            self.progress_lite = 0
        }
    }
}

/// 工具类
/// 提供全局的提示、加载动画等静态方法
class Utils_lite {
    
    // MARK: - 加载动画
    
    /// 显示加载动画
    /// - Parameter message_lite: 提示文本
    static func showLoading_lite(message_lite: String = "Loading...") {
        HUDManager_lite.shared_lite.show_lite(
            type_lite: .loading_lite,
            message_lite: message_lite
        )
    }
    
    /// 显示带进度的加载动画
    /// - Parameters:
    ///   - progress_lite: 进度值（0-1）
    ///   - message_lite: 提示文本
    static func showProgress_lite(
        progress_lite: Double,
        message_lite: String = "Loading..."
    ) {
        HUDManager_lite.shared_lite.showProgress_lite(
            progress_lite: progress_lite,
            message_lite: message_lite
        )
    }
    
    /// 取消加载动画
    static func dismissLoading_lite() {
        HUDManager_lite.shared_lite.dismiss_lite()
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    /// - Parameters:
    ///   - message_lite: 提示文本
    ///   - image_lite: 图标（可选）
    ///   - delay_lite: 显示时长
    static func showSuccess_lite(
        message_lite: String = "Success",
        image_lite: UIImage? = nil,
        delay_lite: TimeInterval = 1.5
    ) {
        HUDManager_lite.shared_lite.show_lite(
            type_lite: .success_lite,
            message_lite: message_lite,
            duration_lite: delay_lite
        )
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    /// - Parameters:
    ///   - message_lite: 提示文本
    ///   - image_lite: 图标（可选）
    ///   - delay_lite: 显示时长
    static func showError_lite(
        message_lite: String = "Error",
        image_lite: UIImage? = nil,
        delay_lite: TimeInterval = 2.0
    ) {
        HUDManager_lite.shared_lite.show_lite(
            type_lite: .error_lite,
            message_lite: message_lite,
            duration_lite: delay_lite
        )
    }
    
    // MARK: - 警告提示
    
    /// 显示警告提示
    /// - Parameters:
    ///   - message_lite: 提示文本
    ///   - delay_lite: 显示时长
    static func showWarning_lite(
        message_lite: String,
        delay_lite: TimeInterval = 2.0
    ) {
        HUDManager_lite.shared_lite.show_lite(
            type_lite: .warning_lite,
            message_lite: message_lite,
            duration_lite: delay_lite
        )
    }
    
    // MARK: - 信息提示
    
    /// 显示信息提示
    /// - Parameters:
    ///   - message_lite: 提示文本
    ///   - delay_lite: 显示时长
    static func showInfo_lite(
        message_lite: String,
        delay_lite: TimeInterval = 1.5
    ) {
        HUDManager_lite.shared_lite.show_lite(
            type_lite: .info_lite,
            message_lite: message_lite,
            duration_lite: delay_lite
        )
    }
    
    // MARK: - 自定义提示
    
    /// 显示自定义图标提示
    /// - Parameters:
    ///   - message_lite: 提示文本
    ///   - symbolName_lite: SF Symbol 名称
    ///   - delay_lite: 显示时长
    static func showMessageWithSymbol_lite(
        message_lite: String,
        symbolName_lite: String,
        delay_lite: TimeInterval = 1.5
    ) {
        HUDManager_lite.shared_lite.show_lite(
            type_lite: .custom_lite(icon_lite: symbolName_lite),
            message_lite: message_lite,
            duration_lite: delay_lite
        )
    }
    
    // MARK: - 移除所有提示
    
    /// 移除所有 HUD
    static func removeAll_lite() {
        HUDManager_lite.shared_lite.dismiss_lite()
    }
}

// MARK: - HUD 视图组件

/// HUD 视图
/// 用于在应用中展示各种提示
struct HUDView_lite: View {
    
    @ObservedObject var manager_lite = HUDManager_lite.shared_lite
    
    var body: some View {
        ZStack {
            if manager_lite.isShowing_lite, let config = manager_lite.config_lite {
                // 背景遮罩
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // 点击遮罩不关闭 HUD（除非是非加载类型）
                        if config.type_lite != .loading_lite {
                            manager_lite.dismiss_lite()
                        }
                    }
                
                // HUD 内容
                hudContent_lite(config: config)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: manager_lite.isShowing_lite)
    }
    
    // MARK: - HUD 内容
    
    @ViewBuilder
    private func hudContent_lite(config: HUDConfig_lite) -> some View {
        VStack(spacing: 16) {
            // 图标
            iconView_lite(for: config.type_lite)
            
            // 消息文本
            if !config.message_lite.isEmpty {
                Text(config.message_lite)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // 进度条
            if manager_lite.showProgress_lite {
                ProgressView(value: manager_lite.progress_lite)
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
    private func iconView_lite(for type: HUDType_lite) -> some View {
        switch type {
        case .loading_lite:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
        case .success_lite:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
        case .error_lite:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
        case .warning_lite:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
        case .info_lite:
            Image(systemName: "info.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
        case .custom_lite(let icon):
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
    }
}

// MARK: - View 扩展

extension View {
    /// 添加 HUD 覆盖层
    func hudOverlay_lite() -> some View {
        self.overlay(
            HUDView_lite()
        )
    }
}

// MARK: - Toast 管理器

/// Toast 类型枚举
enum ToastType_lite {
    case success_lite
    case error_lite
    case warning_lite
    case info_lite
}

/// Toast 配置
struct ToastConfig_lite {
    let type_lite: ToastType_lite
    let message_lite: String
}

/// Toast 管理器
/// 用于显示轻量级的提示信息
class ToastManager_lite: ObservableObject {
    
    /// 单例实例
    static let shared_lite = ToastManager_lite()
    
    /// 是否显示 Toast
    @Published var isShowing_lite: Bool = false
    
    /// Toast 配置
    @Published var config_lite: ToastConfig_lite?
    
    /// 私有初始化
    private init() {}
    
    /// 显示 Toast
    func show_lite(type_lite: ToastType_lite, message_lite: String, duration_lite: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            self.config_lite = ToastConfig_lite(
                type_lite: type_lite,
                message_lite: message_lite
            )
            self.isShowing_lite = true
            
            // 自动隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + duration_lite) {
                self.dismiss_lite()
            }
        }
    }
    
    /// 隐藏 Toast
    func dismiss_lite() {
        DispatchQueue.main.async {
            self.isShowing_lite = false
        }
    }
}

// MARK: - Toast 视图

/// Toast 视图
struct ToastView_lite: View {
    
    @ObservedObject var manager_lite = ToastManager_lite.shared_lite
    
    var body: some View {
        VStack {
            Spacer()
            
            if manager_lite.isShowing_lite, let config = manager_lite.config_lite {
                HStack(spacing: 12) {
                    // 图标
                    iconView_lite(for: config.type_lite)
                    
                    // 文本
                    Text(config.message_lite)
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
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: manager_lite.isShowing_lite)
    }
    
    @ViewBuilder
    private func iconView_lite(for type: ToastType_lite) -> some View {
        Group {
            switch type {
            case .success_lite:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .error_lite:
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            case .warning_lite:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
            case .info_lite:
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .font(.system(size: 20))
    }
}

extension View {
    /// 添加 Toast 覆盖层
    func toastOverlay_lite() -> some View {
        self.overlay(
            ToastView_lite(),
            alignment: .bottom
        )
    }
}

// MARK: - 媒体工具类

import AVKit

/// 媒体工具类
/// 提供图片加载、视频缩略图生成等媒体处理功能
class MediaUtils_lite {
    
    // MARK: - 系统图标判断
    
    /// 判断是否是系统图标（SF Symbol）
    /// - Parameter name_lite: 图标名称
    /// - Returns: 是否是有效的系统图标
    static func isSystemIcon_lite(name_lite: String) -> Bool {
        return UIImage(systemName: name_lite) != nil
    }
    
    // MARK: - 图片加载
    
    /// 从文档目录加载图片
    /// - Parameter imageName_lite: 图片名称（可能带或不带扩展名）
    /// - Returns: UIImage 或 nil
    static func loadImageFromDocuments_lite(imageName_lite: String) -> UIImage? {
        let fileManager_lite = FileManager.default
        guard let documentsDirectory_lite = fileManager_lite.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("⚠️ 无法获取文档目录")
            return nil
        }
        
        // 尝试带 .jpg 扩展名
        var fileURL_lite = documentsDirectory_lite.appendingPathComponent("\(imageName_lite).jpg")
        if let image_lite = UIImage(contentsOfFile: fileURL_lite.path) {
            print("✅ 从文档目录加载图片：\(imageName_lite).jpg")
            return image_lite
        }
        
        // 尝试带 .png 扩展名
        fileURL_lite = documentsDirectory_lite.appendingPathComponent("\(imageName_lite).png")
        if let image_lite = UIImage(contentsOfFile: fileURL_lite.path) {
            print("✅ 从文档目录加载图片：\(imageName_lite).png")
            return image_lite
        }
        
        // 尝试不带扩展名（文件名本身可能已包含扩展名）
        fileURL_lite = documentsDirectory_lite.appendingPathComponent(imageName_lite)
        if let image_lite = UIImage(contentsOfFile: fileURL_lite.path) {
            print("✅ 从文档目录加载图片：\(imageName_lite)")
            return image_lite
        }
        
        print("⚠️ 无法从文档目录加载图片：\(imageName_lite)")
        return nil
    }
    
    // MARK: - 视频缩略图生成
    
    /// 从Bundle中的视频文件生成缩略图
    /// - Parameters:
    ///   - videoName_lite: 视频文件名（不带扩展名或带.mp4扩展名）
    ///   - time_lite: 截取时间点（秒），默认1.0秒
    /// - Returns: UIImage 或 nil
    static func loadVideoThumbnail_lite(
        videoName_lite: String,
        time_lite: Double = 1.0
    ) -> UIImage? {
        // 1. 处理文件名，确保有.mp4扩展名
        let fileName_lite: String
        if videoName_lite.hasSuffix(".mp4") {
            fileName_lite = videoName_lite
        } else {
            fileName_lite = "\(videoName_lite).mp4"
        }
        
        // 2. 从主Bundle中查找视频文件
        let resourceName_lite = fileName_lite.replacingOccurrences(of: ".mp4", with: "")
        guard let videoPath_lite = Bundle.main.path(
            forResource: resourceName_lite,
            ofType: "mp4"
        ) else {
            print("⚠️ 无法在Bundle中找到视频文件：\(fileName_lite)")
            return nil
        }
        
        return generateThumbnail_lite(
            from: URL(fileURLWithPath: videoPath_lite),
            at: time_lite
        )
    }
    
    /// 从视频URL生成缩略图
    /// - Parameters:
    ///   - videoURL_lite: 视频URL
    ///   - time_lite: 截取时间点（秒）
    /// - Returns: UIImage 或 nil
    static func generateThumbnail_lite(
        from videoURL_lite: URL,
        at time_lite: Double
    ) -> UIImage? {
        // 创建 AVAsset
        let asset_lite = AVAsset(url: videoURL_lite)
        let imageGenerator_lite = AVAssetImageGenerator(asset: asset_lite)
        imageGenerator_lite.appliesPreferredTrackTransform = true  // 保持视频方向
        
        // 设置生成缩略图的时间点
        let cmTime_lite = CMTime(seconds: time_lite, preferredTimescale: 600)
        
        do {
            let cgImage_lite = try imageGenerator_lite.copyCGImage(
                at: cmTime_lite,
                actualTime: nil
            )
            let thumbnail_lite = UIImage(cgImage: cgImage_lite)
            print("✅ 成功生成视频缩略图")
            return thumbnail_lite
        } catch {
            print("❌ 生成视频缩略图失败：\(error.localizedDescription)")
            return nil
        }
    }
}
