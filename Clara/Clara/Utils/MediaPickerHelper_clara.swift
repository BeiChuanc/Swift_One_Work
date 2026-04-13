import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Clara: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Clara = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Clara {
        case photo_Clara           // 仅图片
        case video_Clara           // 仅视频
        case photoAndVideo_Clara   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Clara {
        case photo_Clara(image_Clara: UIImage)      // 图片结果
        case video_Clara(url_Clara: URL)            // 视频结果
        case cancelled_Clara                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Clara = MediaPickerHelper_Clara()
    
    /// 完成回调
    private var completion_Clara: ((PickerResult_Clara) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Clara: MediaType_Clara = .photo_Clara
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Clara(
        from viewController_Clara: UIViewController,
        mediaType_Clara: MediaType_Clara = .photo_Clara,
        selectionLimit_Clara: Int = 1,
        completion_Clara: @escaping (PickerResult_Clara) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Clara = completion_Clara
        self.currentMediaType_Clara = mediaType_Clara
        
        // 配置 PHPicker
        var config_Clara = PHPickerConfiguration()
        config_Clara.selectionLimit = selectionLimit_Clara
        
        // 根据媒体类型设置过滤器
        switch mediaType_Clara {
        case .photo_Clara:
            config_Clara.filter = .images
        case .video_Clara:
            config_Clara.filter = .videos
        case .photoAndVideo_Clara:
            config_Clara.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Clara = PHPickerViewController(configuration: config_Clara)
        picker_Clara.delegate = self
        
        viewController_Clara.present(picker_Clara, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Clara(
        from viewController_Clara: UIViewController,
        completion_Clara: @escaping (UIImage?) -> Void
    ) {
        shared_Clara.showPicker_Clara(
            from: viewController_Clara,
            mediaType_Clara: .photo_Clara
        ) { result_Clara in
            if case .photo_Clara(let image_Clara) = result_Clara {
                completion_Clara(image_Clara)
            } else {
                completion_Clara(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Clara(
        from viewController_Clara: UIViewController,
        completion_Clara: @escaping (URL?) -> Void
    ) {
        shared_Clara.showPicker_Clara(
            from: viewController_Clara,
            mediaType_Clara: .video_Clara
        ) { result_Clara in
            if case .video_Clara(let url_Clara) = result_Clara {
                completion_Clara(url_Clara)
            } else {
                completion_Clara(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Clara(
        from viewController_Clara: UIViewController,
        completion_Clara: @escaping (PickerResult_Clara) -> Void
    ) {
        shared_Clara.showPicker_Clara(
            from: viewController_Clara,
            mediaType_Clara: .photoAndVideo_Clara,
            completion_Clara: completion_Clara
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Clara(_ result_Clara: PickerResult_Clara) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Clara?(result_Clara)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Clara(itemProvider_Clara: NSItemProvider) {
        itemProvider_Clara.loadObject(ofClass: UIImage.self) { [weak self] image_Clara, error_Clara in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Clara = error_Clara {
                print("❌ 加载图片失败: \(error_Clara)")
                self.callCompletion_Clara(.cancelled_Clara)
                return
            }
            
            // 类型转换和回调
            if let image_Clara = image_Clara as? UIImage {
                self.callCompletion_Clara(.photo_Clara(image_Clara: image_Clara))
            } else {
                self.callCompletion_Clara(.cancelled_Clara)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Clara(itemProvider_Clara: NSItemProvider) {
        itemProvider_Clara.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Clara, error_Clara in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Clara = error_Clara {
                print("❌ 加载视频失败: \(error_Clara)")
                self.callCompletion_Clara(.cancelled_Clara)
                return
            }
            
            guard let url_Clara = url_Clara else {
                print("❌ 视频URL为空")
                self.callCompletion_Clara(.cancelled_Clara)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Clara(sourceURL_Clara: url_Clara)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Clara: 原始视频URL
    private func copyVideoToTemp_Clara(sourceURL_Clara: URL) {
        // 生成临时文件路径
        let fileName_Clara = "\(Self.tempVideoPrefix_Clara)\(Date().timeIntervalSince1970)"
        let tempURL_Clara = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Clara)
            .appendingPathExtension(sourceURL_Clara.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Clara(at: tempURL_Clara)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Clara, to: tempURL_Clara)
            print("✅ 视频已复制到临时目录: \(tempURL_Clara.path)")
            
            callCompletion_Clara(.video_Clara(url_Clara: tempURL_Clara))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Clara(.cancelled_Clara)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Clara(at url_Clara: URL) throws {
        if FileManager.default.fileExists(atPath: url_Clara.path) {
            try FileManager.default.removeItem(at: url_Clara)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Clara: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Clara = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Clara(.cancelled_Clara)
            return
        }
        
        let itemProvider_Clara = result_Clara.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Clara.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Clara(itemProvider_Clara: itemProvider_Clara)
        } else if itemProvider_Clara.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Clara(itemProvider_Clara: itemProvider_Clara)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Clara(.cancelled_Clara)
        }
    }
}
