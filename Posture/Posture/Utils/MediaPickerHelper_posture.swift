import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Posture: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Posture = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Posture {
        case photo_Posture           // 仅图片
        case video_Posture           // 仅视频
        case photoAndVideo_Posture   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Posture {
        case photo_Posture(image_Posture: UIImage)      // 图片结果
        case video_Posture(url_Posture: URL)            // 视频结果
        case cancelled_Posture                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Posture = MediaPickerHelper_Posture()
    
    /// 完成回调
    private var completion_Posture: ((PickerResult_Posture) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Posture: MediaType_Posture = .photo_Posture
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Posture(
        from viewController_Posture: UIViewController,
        mediaType_Posture: MediaType_Posture = .photo_Posture,
        selectionLimit_Posture: Int = 1,
        completion_Posture: @escaping (PickerResult_Posture) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Posture = completion_Posture
        self.currentMediaType_Posture = mediaType_Posture
        
        // 配置 PHPicker
        var config_Posture = PHPickerConfiguration()
        config_Posture.selectionLimit = selectionLimit_Posture
        
        // 根据媒体类型设置过滤器
        switch mediaType_Posture {
        case .photo_Posture:
            config_Posture.filter = .images
        case .video_Posture:
            config_Posture.filter = .videos
        case .photoAndVideo_Posture:
            config_Posture.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Posture = PHPickerViewController(configuration: config_Posture)
        picker_Posture.delegate = self
        
        viewController_Posture.present(picker_Posture, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Posture(
        from viewController_Posture: UIViewController,
        completion_Posture: @escaping (UIImage?) -> Void
    ) {
        shared_Posture.showPicker_Posture(
            from: viewController_Posture,
            mediaType_Posture: .photo_Posture
        ) { result_Posture in
            if case .photo_Posture(let image_Posture) = result_Posture {
                completion_Posture(image_Posture)
            } else {
                completion_Posture(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Posture(
        from viewController_Posture: UIViewController,
        completion_Posture: @escaping (URL?) -> Void
    ) {
        shared_Posture.showPicker_Posture(
            from: viewController_Posture,
            mediaType_Posture: .video_Posture
        ) { result_Posture in
            if case .video_Posture(let url_Posture) = result_Posture {
                completion_Posture(url_Posture)
            } else {
                completion_Posture(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Posture(
        from viewController_Posture: UIViewController,
        completion_Posture: @escaping (PickerResult_Posture) -> Void
    ) {
        shared_Posture.showPicker_Posture(
            from: viewController_Posture,
            mediaType_Posture: .photoAndVideo_Posture,
            completion_Posture: completion_Posture
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Posture(_ result_Posture: PickerResult_Posture) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Posture?(result_Posture)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Posture(itemProvider_Posture: NSItemProvider) {
        itemProvider_Posture.loadObject(ofClass: UIImage.self) { [weak self] image_Posture, error_Posture in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Posture = error_Posture {
                print("❌ 加载图片失败: \(error_Posture)")
                self.callCompletion_Posture(.cancelled_Posture)
                return
            }
            
            // 类型转换和回调
            if let image_Posture = image_Posture as? UIImage {
                self.callCompletion_Posture(.photo_Posture(image_Posture: image_Posture))
            } else {
                self.callCompletion_Posture(.cancelled_Posture)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Posture(itemProvider_Posture: NSItemProvider) {
        itemProvider_Posture.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Posture, error_Posture in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Posture = error_Posture {
                print("❌ 加载视频失败: \(error_Posture)")
                self.callCompletion_Posture(.cancelled_Posture)
                return
            }
            
            guard let url_Posture = url_Posture else {
                print("❌ 视频URL为空")
                self.callCompletion_Posture(.cancelled_Posture)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Posture(sourceURL_Posture: url_Posture)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Posture: 原始视频URL
    private func copyVideoToTemp_Posture(sourceURL_Posture: URL) {
        // 生成临时文件路径
        let fileName_Posture = "\(Self.tempVideoPrefix_Posture)\(Date().timeIntervalSince1970)"
        let tempURL_Posture = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Posture)
            .appendingPathExtension(sourceURL_Posture.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Posture(at: tempURL_Posture)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Posture, to: tempURL_Posture)
            print("✅ 视频已复制到临时目录: \(tempURL_Posture.path)")
            
            callCompletion_Posture(.video_Posture(url_Posture: tempURL_Posture))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Posture(.cancelled_Posture)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Posture(at url_Posture: URL) throws {
        if FileManager.default.fileExists(atPath: url_Posture.path) {
            try FileManager.default.removeItem(at: url_Posture)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Posture: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Posture = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Posture(.cancelled_Posture)
            return
        }
        
        let itemProvider_Posture = result_Posture.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Posture.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Posture(itemProvider_Posture: itemProvider_Posture)
        } else if itemProvider_Posture.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Posture(itemProvider_Posture: itemProvider_Posture)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Posture(.cancelled_Posture)
        }
    }
}
