import SwiftUI
import Combine

// MARK: - 工具类
// 核心作用：提供全局的提示、加载动画等工具方法
// 设计思路：使用 ObservableObject 管理 HUD 状态，支持各种提示类型
// 关键方法：showLoading（加载动画）、showSuccess（成功提示）、showError（错误提示）

/// HUD 类型枚举
enum HUDType_platbell: Equatable {
    /// 加载中
    case loading_platbell
    /// 成功
    case success_platbell
    /// 错误
    case error_platbell
    /// 警告
    case warning_platbell
    /// 信息
    case info_platbell
    /// 自定义
    case custom_platbell(icon_platbell: String)
    
    /// 实现 Equatable 协议
    static func == (lhs: HUDType_platbell, rhs: HUDType_platbell) -> Bool {
        switch (lhs, rhs) {
        case (.loading_platbell, .loading_platbell),
             (.success_platbell, .success_platbell),
             (.error_platbell, .error_platbell),
             (.warning_platbell, .warning_platbell),
             (.info_platbell, .info_platbell):
            return true
        case (.custom_platbell(let lhsIcon), .custom_platbell(let rhsIcon)):
            return lhsIcon == rhsIcon
        default:
            return false
        }
    }
}

/// HUD 配置
struct HUDConfig_platbell {
    let type_platbell: HUDType_platbell
    let message_platbell: String
    let duration_platbell: TimeInterval
}

/// HUD 管理器
/// 用于管理应用中的所有提示和加载动画
class HUDManager_platbell: ObservableObject {
    
    /// 单例实例
    static let shared_platbell = HUDManager_platbell()
    
    /// 是否显示 HUD
    @Published var isShowing_platbell: Bool = false
    
    /// 当前 HUD 配置
    @Published var config_platbell: HUDConfig_platbell?
    
    /// 进度值（0-1）
    @Published var progress_platbell: Double = 0
    
    /// 是否显示进度
    @Published var showProgress_platbell: Bool = false
    
    /// 私有初始化
    private init() {}
    
    /// 显示 HUD
    func show_platbell(type_platbell: HUDType_platbell, message_platbell: String, duration_platbell: TimeInterval = 0) {
        DispatchQueue.main.async {
            self.config_platbell = HUDConfig_platbell(
                type_platbell: type_platbell,
                message_platbell: message_platbell,
                duration_platbell: duration_platbell
            )
            self.showProgress_platbell = false
            self.isShowing_platbell = true
            
            // 如果设置了持续时间，自动隐藏
            if duration_platbell > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration_platbell) {
                    self.dismiss_platbell()
                }
            }
        }
    }
    
    /// 显示进度
    func showProgress_platbell(progress_platbell: Double, message_platbell: String) {
        DispatchQueue.main.async {
            self.progress_platbell = progress_platbell
            self.config_platbell = HUDConfig_platbell(
                type_platbell: .loading_platbell,
                message_platbell: message_platbell,
                duration_platbell: 0
            )
            self.showProgress_platbell = true
            self.isShowing_platbell = true
        }
    }
    
    /// 隐藏 HUD
    func dismiss_platbell() {
        DispatchQueue.main.async {
            self.isShowing_platbell = false
            self.showProgress_platbell = false
            self.progress_platbell = 0
        }
    }
}

/// 工具类
/// 提供全局的提示、加载动画等静态方法
class Utils_platbell {
    
    // MARK: - 加载动画
    
    /// 显示加载动画
    /// - Parameter message_platbell: 提示文本
    static func showLoading_platbell(message_platbell: String = "Loading...") {
        HUDManager_platbell.shared_platbell.show_platbell(
            type_platbell: .loading_platbell,
            message_platbell: message_platbell
        )
    }
    
    /// 显示带进度的加载动画
    /// - Parameters:
    ///   - progress_platbell: 进度值（0-1）
    ///   - message_platbell: 提示文本
    static func showProgress_platbell(
        progress_platbell: Double,
        message_platbell: String = "Loading..."
    ) {
        HUDManager_platbell.shared_platbell.showProgress_platbell(
            progress_platbell: progress_platbell,
            message_platbell: message_platbell
        )
    }
    
    /// 取消加载动画
    static func dismissLoading_platbell() {
        HUDManager_platbell.shared_platbell.dismiss_platbell()
    }
    
    // MARK: - 成功提示
    
    /// 显示成功提示
    /// - Parameters:
    ///   - message_platbell: 提示文本
    ///   - image_platbell: 图标（可选）
    ///   - delay_platbell: 显示时长
    static func showSuccess_platbell(
        message_platbell: String = "Success",
        image_platbell: UIImage? = nil,
        delay_platbell: TimeInterval = 1.5
    ) {
        HUDManager_platbell.shared_platbell.show_platbell(
            type_platbell: .success_platbell,
            message_platbell: message_platbell,
            duration_platbell: delay_platbell
        )
    }
    
    // MARK: - 错误提示
    
    /// 显示错误提示
    /// - Parameters:
    ///   - message_platbell: 提示文本
    ///   - image_platbell: 图标（可选）
    ///   - delay_platbell: 显示时长
    static func showError_platbell(
        message_platbell: String = "Error",
        image_platbell: UIImage? = nil,
        delay_platbell: TimeInterval = 2.0
    ) {
        HUDManager_platbell.shared_platbell.show_platbell(
            type_platbell: .error_platbell,
            message_platbell: message_platbell,
            duration_platbell: delay_platbell
        )
    }
    
    // MARK: - 警告提示
    
    /// 显示警告提示
    /// - Parameters:
    ///   - message_platbell: 提示文本
    ///   - delay_platbell: 显示时长
    static func showWarning_platbell(
        message_platbell: String,
        delay_platbell: TimeInterval = 2.0
    ) {
        HUDManager_platbell.shared_platbell.show_platbell(
            type_platbell: .warning_platbell,
            message_platbell: message_platbell,
            duration_platbell: delay_platbell
        )
    }
    
    // MARK: - 信息提示
    
    /// 显示信息提示
    /// - Parameters:
    ///   - message_platbell: 提示文本
    ///   - delay_platbell: 显示时长
    static func showInfo_platbell(
        message_platbell: String,
        delay_platbell: TimeInterval = 1.5
    ) {
        HUDManager_platbell.shared_platbell.show_platbell(
            type_platbell: .info_platbell,
            message_platbell: message_platbell,
            duration_platbell: delay_platbell
        )
    }
    
    // MARK: - 自定义提示
    
    /// 显示自定义图标提示
    /// - Parameters:
    ///   - message_platbell: 提示文本
    ///   - symbolName_platbell: SF Symbol 名称
    ///   - delay_platbell: 显示时长
    static func showMessageWithSymbol_platbell(
        message_platbell: String,
        symbolName_platbell: String,
        delay_platbell: TimeInterval = 1.5
    ) {
        HUDManager_platbell.shared_platbell.show_platbell(
            type_platbell: .custom_platbell(icon_platbell: symbolName_platbell),
            message_platbell: message_platbell,
            duration_platbell: delay_platbell
        )
    }
    
    // MARK: - 移除所有提示
    
    /// 移除所有 HUD
    static func removeAll_platbell() {
        HUDManager_platbell.shared_platbell.dismiss_platbell()
    }
}

// MARK: - HUD 视图组件

/// HUD 视图
/// 用于在应用中展示各种提示
struct HUDView_platbell: View {
    
    @ObservedObject var manager_platbell = HUDManager_platbell.shared_platbell
    
    var body: some View {
        ZStack {
            if manager_platbell.isShowing_platbell, let config = manager_platbell.config_platbell {
                // 背景遮罩
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // 点击遮罩不关闭 HUD（除非是非加载类型）
                        if config.type_platbell != .loading_platbell {
                            manager_platbell.dismiss_platbell()
                        }
                    }
                
                // HUD 内容
                hudContent_platbell(config: config)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: manager_platbell.isShowing_platbell)
    }
    
    // MARK: - HUD 内容
    
    @ViewBuilder
    private func hudContent_platbell(config: HUDConfig_platbell) -> some View {
        VStack(spacing: 16) {
            // 图标
            iconView_platbell(for: config.type_platbell)
            
            // 消息文本
            if !config.message_platbell.isEmpty {
                Text(config.message_platbell)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            // 进度条
            if manager_platbell.showProgress_platbell {
                ProgressView(value: manager_platbell.progress_platbell)
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
    private func iconView_platbell(for type: HUDType_platbell) -> some View {
        switch type {
        case .loading_platbell:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
        case .success_platbell:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.green)
            
        case .error_platbell:
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
        case .warning_platbell:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
        case .info_platbell:
            Image(systemName: "info.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
        case .custom_platbell(let icon):
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(.white)
        }
    }
}

// MARK: - View 扩展

extension View {
    /// 添加 HUD 覆盖层
    func hudOverlay_platbell() -> some View {
        self.overlay(
            HUDView_platbell()
        )
    }
}

// MARK: - Toast 管理器

/// Toast 类型枚举
enum ToastType_platbell {
    case success_platbell
    case error_platbell
    case warning_platbell
    case info_platbell
}

/// Toast 配置
struct ToastConfig_platbell {
    let type_platbell: ToastType_platbell
    let message_platbell: String
}

/// Toast 管理器
/// 用于显示轻量级的提示信息
class ToastManager_platbell: ObservableObject {
    
    /// 单例实例
    static let shared_platbell = ToastManager_platbell()
    
    /// 是否显示 Toast
    @Published var isShowing_platbell: Bool = false
    
    /// Toast 配置
    @Published var config_platbell: ToastConfig_platbell?
    
    /// 私有初始化
    private init() {}
    
    /// 显示 Toast
    func show_platbell(type_platbell: ToastType_platbell, message_platbell: String, duration_platbell: TimeInterval = 2.0) {
        DispatchQueue.main.async {
            self.config_platbell = ToastConfig_platbell(
                type_platbell: type_platbell,
                message_platbell: message_platbell
            )
            self.isShowing_platbell = true
            
            // 自动隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + duration_platbell) {
                self.dismiss_platbell()
            }
        }
    }
    
    /// 隐藏 Toast
    func dismiss_platbell() {
        DispatchQueue.main.async {
            self.isShowing_platbell = false
        }
    }
}

// MARK: - Toast 视图

/// Toast 视图
struct ToastView_platbell: View {
    
    @ObservedObject var manager_platbell = ToastManager_platbell.shared_platbell
    
    var body: some View {
        VStack {
            Spacer()
            
            if manager_platbell.isShowing_platbell, let config = manager_platbell.config_platbell {
                HStack(spacing: 12) {
                    // 图标
                    iconView_platbell(for: config.type_platbell)
                    
                    // 文本
                    Text(config.message_platbell)
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
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: manager_platbell.isShowing_platbell)
    }
    
    @ViewBuilder
    private func iconView_platbell(for type: ToastType_platbell) -> some View {
        Group {
            switch type {
            case .success_platbell:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            case .error_platbell:
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            case .warning_platbell:
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
            case .info_platbell:
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .font(.system(size: 20))
    }
}

extension View {
    /// 添加 Toast 覆盖层
    func toastOverlay_platbell() -> some View {
        self.overlay(
            ToastView_platbell(),
            alignment: .bottom
        )
    }
}

// MARK: - 媒体工具类

import AVKit

/// 媒体工具类
/// 提供图片加载、视频缩略图生成等媒体处理功能
class MediaUtils_platbell {
    
    // MARK: - 系统图标判断
    
    /// 判断是否是系统图标（SF Symbol）
    /// - Parameter name_platbell: 图标名称
    /// - Returns: 是否是有效的系统图标
    static func isSystemIcon_platbell(name_platbell: String) -> Bool {
        return UIImage(systemName: name_platbell) != nil
    }
    
    // MARK: - 图片保存
    
    /// 保存图片到文档目录
    /// - Parameters:
    ///   - image_platbell: 要保存的UIImage
    ///   - imageName_platbell: 图片名称（包含扩展名）
    /// - Returns: 是否保存成功
    static func saveImageToDocuments_platbell(image_platbell: UIImage, imageName_platbell: String) -> Bool {
        let fileManager_platbell = FileManager.default
        guard let documentsDirectory_platbell = fileManager_platbell.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("⚠️ 无法获取文档目录")
            return false
        }
        
        let fileURL_platbell = documentsDirectory_platbell.appendingPathComponent(imageName_platbell)
        
        // 根据文件扩展名决定压缩格式
        let imageData_platbell: Data?
        if imageName_platbell.lowercased().hasSuffix(".png") {
            imageData_platbell = image_platbell.pngData()
        } else {
            // 默认使用 JPEG 格式，压缩质量 0.8
            imageData_platbell = image_platbell.jpegData(compressionQuality: 0.8)
        }
        
        guard let data_platbell = imageData_platbell else {
            print("⚠️ 无法生成图片数据")
            return false
        }
        
        do {
            try data_platbell.write(to: fileURL_platbell)
            print("✅ 图片保存成功：\(imageName_platbell)")
            return true
        } catch {
            print("❌ 图片保存失败：\(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - 图片加载
    
    /// 从文档目录加载图片
    /// - Parameter imageName_platbell: 图片名称（可能带或不带扩展名）
    /// - Returns: UIImage 或 nil
    static func loadImageFromDocuments_platbell(imageName_platbell: String) -> UIImage? {
        let fileManager_platbell = FileManager.default
        guard let documentsDirectory_platbell = fileManager_platbell.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            print("⚠️ 无法获取文档目录")
            return nil
        }
        
        // 尝试带 .jpg 扩展名
        var fileURL_platbell = documentsDirectory_platbell.appendingPathComponent("\(imageName_platbell).jpg")
        if let image_platbell = UIImage(contentsOfFile: fileURL_platbell.path) {
            print("✅ 从文档目录加载图片：\(imageName_platbell).jpg")
            return image_platbell
        }
        
        // 尝试带 .png 扩展名
        fileURL_platbell = documentsDirectory_platbell.appendingPathComponent("\(imageName_platbell).png")
        if let image_platbell = UIImage(contentsOfFile: fileURL_platbell.path) {
            print("✅ 从文档目录加载图片：\(imageName_platbell).png")
            return image_platbell
        }
        
        // 尝试不带扩展名（文件名本身可能已包含扩展名）
        fileURL_platbell = documentsDirectory_platbell.appendingPathComponent(imageName_platbell)
        if let image_platbell = UIImage(contentsOfFile: fileURL_platbell.path) {
            print("✅ 从文档目录加载图片：\(imageName_platbell)")
            return image_platbell
        }
        
        print("⚠️ 无法从文档目录加载图片：\(imageName_platbell)")
        return nil
    }
    
    // MARK: - 视频缩略图生成
    
    /// 从Bundle中的视频文件生成缩略图
    /// - Parameters:
    ///   - videoName_platbell: 视频文件名（不带扩展名或带.mp4扩展名）
    ///   - time_platbell: 截取时间点（秒），默认1.0秒
    /// - Returns: UIImage 或 nil
    static func loadVideoThumbnail_platbell(
        videoName_platbell: String,
        time_platbell: Double = 1.0
    ) -> UIImage? {
        // 1. 处理文件名，确保有.mp4扩展名
        let fileName_platbell: String
        if videoName_platbell.hasSuffix(".mp4") {
            fileName_platbell = videoName_platbell
        } else {
            fileName_platbell = "\(videoName_platbell).mp4"
        }
        
        // 2. 从主Bundle中查找视频文件
        let resourceName_platbell = fileName_platbell.replacingOccurrences(of: ".mp4", with: "")
        guard let videoPath_platbell = Bundle.main.path(
            forResource: resourceName_platbell,
            ofType: "mp4"
        ) else {
            print("⚠️ 无法在Bundle中找到视频文件：\(fileName_platbell)")
            return nil
        }
        
        return generateThumbnail_platbell(
            from: URL(fileURLWithPath: videoPath_platbell),
            at: time_platbell
        )
    }
    
    /// 从视频URL生成缩略图
    /// - Parameters:
    ///   - videoURL_platbell: 视频URL
    ///   - time_platbell: 截取时间点（秒）
    /// - Returns: UIImage 或 nil
    static func generateThumbnail_platbell(
        from videoURL_platbell: URL,
        at time_platbell: Double
    ) -> UIImage? {
        // 创建 AVAsset
        let asset_platbell = AVAsset(url: videoURL_platbell)
        let imageGenerator_platbell = AVAssetImageGenerator(asset: asset_platbell)
        imageGenerator_platbell.appliesPreferredTrackTransform = true  // 保持视频方向
        
        // 设置生成缩略图的时间点
        let cmTime_platbell = CMTime(seconds: time_platbell, preferredTimescale: 600)
        
        do {
            let cgImage_platbell = try imageGenerator_platbell.copyCGImage(
                at: cmTime_platbell,
                actualTime: nil
            )
            let thumbnail_platbell = UIImage(cgImage: cgImage_platbell)
            print("✅ 成功生成视频缩略图")
            return thumbnail_platbell
        } catch {
            print("❌ 生成视频缩略图失败：\(error.localizedDescription)")
            return nil
        }
    }
}
