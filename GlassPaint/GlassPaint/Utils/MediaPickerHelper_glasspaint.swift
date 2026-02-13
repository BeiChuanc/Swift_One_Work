import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Glasspaint: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Glasspaint = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Glasspaint {
        case photo_Glasspaint           // 仅图片
        case video_Glasspaint           // 仅视频
        case photoAndVideo_Glasspaint   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Glasspaint {
        case photo_Glasspaint(image_Glasspaint: UIImage)      // 图片结果
        case video_Glasspaint(url_Glasspaint: URL)            // 视频结果
        case cancelled_Glasspaint                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Glasspaint = MediaPickerHelper_Glasspaint()
    
    /// 完成回调
    private var completion_Glasspaint: ((PickerResult_Glasspaint) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Glasspaint: MediaType_Glasspaint = .photo_Glasspaint
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Glasspaint(
        from viewController_Glasspaint: UIViewController,
        mediaType_Glasspaint: MediaType_Glasspaint = .photo_Glasspaint,
        selectionLimit_Glasspaint: Int = 1,
        completion_Glasspaint: @escaping (PickerResult_Glasspaint) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Glasspaint = completion_Glasspaint
        self.currentMediaType_Glasspaint = mediaType_Glasspaint
        
        // 配置 PHPicker
        var config_Glasspaint = PHPickerConfiguration()
        config_Glasspaint.selectionLimit = selectionLimit_Glasspaint
        
        // 根据媒体类型设置过滤器
        switch mediaType_Glasspaint {
        case .photo_Glasspaint:
            config_Glasspaint.filter = .images
        case .video_Glasspaint:
            config_Glasspaint.filter = .videos
        case .photoAndVideo_Glasspaint:
            config_Glasspaint.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Glasspaint = PHPickerViewController(configuration: config_Glasspaint)
        picker_Glasspaint.delegate = self
        
        viewController_Glasspaint.present(picker_Glasspaint, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Glasspaint(
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: @escaping (UIImage?) -> Void
    ) {
        shared_Glasspaint.showPicker_Glasspaint(
            from: viewController_Glasspaint,
            mediaType_Glasspaint: .photo_Glasspaint
        ) { result_Glasspaint in
            if case .photo_Glasspaint(let image_Glasspaint) = result_Glasspaint {
                completion_Glasspaint(image_Glasspaint)
            } else {
                completion_Glasspaint(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Glasspaint(
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: @escaping (URL?) -> Void
    ) {
        shared_Glasspaint.showPicker_Glasspaint(
            from: viewController_Glasspaint,
            mediaType_Glasspaint: .video_Glasspaint
        ) { result_Glasspaint in
            if case .video_Glasspaint(let url_Glasspaint) = result_Glasspaint {
                completion_Glasspaint(url_Glasspaint)
            } else {
                completion_Glasspaint(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Glasspaint(
        from viewController_Glasspaint: UIViewController,
        completion_Glasspaint: @escaping (PickerResult_Glasspaint) -> Void
    ) {
        shared_Glasspaint.showPicker_Glasspaint(
            from: viewController_Glasspaint,
            mediaType_Glasspaint: .photoAndVideo_Glasspaint,
            completion_Glasspaint: completion_Glasspaint
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Glasspaint(_ result_Glasspaint: PickerResult_Glasspaint) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Glasspaint?(result_Glasspaint)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Glasspaint(itemProvider_Glasspaint: NSItemProvider) {
        itemProvider_Glasspaint.loadObject(ofClass: UIImage.self) { [weak self] image_Glasspaint, error_Glasspaint in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Glasspaint = error_Glasspaint {
                print("❌ 加载图片失败: \(error_Glasspaint)")
                self.callCompletion_Glasspaint(.cancelled_Glasspaint)
                return
            }
            
            // 类型转换和回调
            if let image_Glasspaint = image_Glasspaint as? UIImage {
                self.callCompletion_Glasspaint(.photo_Glasspaint(image_Glasspaint: image_Glasspaint))
            } else {
                self.callCompletion_Glasspaint(.cancelled_Glasspaint)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Glasspaint(itemProvider_Glasspaint: NSItemProvider) {
        itemProvider_Glasspaint.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Glasspaint, error_Glasspaint in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Glasspaint = error_Glasspaint {
                print("❌ 加载视频失败: \(error_Glasspaint)")
                self.callCompletion_Glasspaint(.cancelled_Glasspaint)
                return
            }
            
            guard let url_Glasspaint = url_Glasspaint else {
                print("❌ 视频URL为空")
                self.callCompletion_Glasspaint(.cancelled_Glasspaint)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Glasspaint(sourceURL_Glasspaint: url_Glasspaint)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Glasspaint: 原始视频URL
    private func copyVideoToTemp_Glasspaint(sourceURL_Glasspaint: URL) {
        // 生成临时文件路径
        let fileName_Glasspaint = "\(Self.tempVideoPrefix_Glasspaint)\(Date().timeIntervalSince1970)"
        let tempURL_Glasspaint = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Glasspaint)
            .appendingPathExtension(sourceURL_Glasspaint.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Glasspaint(at: tempURL_Glasspaint)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Glasspaint, to: tempURL_Glasspaint)
            print("✅ 视频已复制到临时目录: \(tempURL_Glasspaint.path)")
            
            callCompletion_Glasspaint(.video_Glasspaint(url_Glasspaint: tempURL_Glasspaint))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Glasspaint(.cancelled_Glasspaint)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Glasspaint(at url_Glasspaint: URL) throws {
        if FileManager.default.fileExists(atPath: url_Glasspaint.path) {
            try FileManager.default.removeItem(at: url_Glasspaint)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Glasspaint: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Glasspaint = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Glasspaint(.cancelled_Glasspaint)
            return
        }
        
        let itemProvider_Glasspaint = result_Glasspaint.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Glasspaint.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Glasspaint(itemProvider_Glasspaint: itemProvider_Glasspaint)
        } else if itemProvider_Glasspaint.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Glasspaint(itemProvider_Glasspaint: itemProvider_Glasspaint)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Glasspaint(.cancelled_Glasspaint)
        }
    }
}
