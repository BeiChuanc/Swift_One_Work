import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Epoch: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Epoch = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Epoch {
        case photo_Epoch           // 仅图片
        case video_Epoch           // 仅视频
        case photoAndVideo_Epoch   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Epoch {
        case photo_Epoch(image_Epoch: UIImage)      // 图片结果
        case video_Epoch(url_Epoch: URL)            // 视频结果
        case cancelled_Epoch                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Epoch = MediaPickerHelper_Epoch()
    
    /// 完成回调
    private var completion_Epoch: ((PickerResult_Epoch) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Epoch: MediaType_Epoch = .photo_Epoch
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Epoch(
        from viewController_Epoch: UIViewController,
        mediaType_Epoch: MediaType_Epoch = .photo_Epoch,
        selectionLimit_Epoch: Int = 1,
        completion_Epoch: @escaping (PickerResult_Epoch) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Epoch = completion_Epoch
        self.currentMediaType_Epoch = mediaType_Epoch
        
        // 配置 PHPicker
        var config_Epoch = PHPickerConfiguration()
        config_Epoch.selectionLimit = selectionLimit_Epoch
        
        // 根据媒体类型设置过滤器
        switch mediaType_Epoch {
        case .photo_Epoch:
            config_Epoch.filter = .images
        case .video_Epoch:
            config_Epoch.filter = .videos
        case .photoAndVideo_Epoch:
            config_Epoch.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Epoch = PHPickerViewController(configuration: config_Epoch)
        picker_Epoch.delegate = self
        
        viewController_Epoch.present(picker_Epoch, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Epoch(
        from viewController_Epoch: UIViewController,
        completion_Epoch: @escaping (UIImage?) -> Void
    ) {
        shared_Epoch.showPicker_Epoch(
            from: viewController_Epoch,
            mediaType_Epoch: .photo_Epoch
        ) { result_Epoch in
            if case .photo_Epoch(let image_Epoch) = result_Epoch {
                completion_Epoch(image_Epoch)
            } else {
                completion_Epoch(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Epoch(
        from viewController_Epoch: UIViewController,
        completion_Epoch: @escaping (URL?) -> Void
    ) {
        shared_Epoch.showPicker_Epoch(
            from: viewController_Epoch,
            mediaType_Epoch: .video_Epoch
        ) { result_Epoch in
            if case .video_Epoch(let url_Epoch) = result_Epoch {
                completion_Epoch(url_Epoch)
            } else {
                completion_Epoch(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Epoch(
        from viewController_Epoch: UIViewController,
        completion_Epoch: @escaping (PickerResult_Epoch) -> Void
    ) {
        shared_Epoch.showPicker_Epoch(
            from: viewController_Epoch,
            mediaType_Epoch: .photoAndVideo_Epoch,
            completion_Epoch: completion_Epoch
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Epoch(_ result_Epoch: PickerResult_Epoch) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Epoch?(result_Epoch)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Epoch(itemProvider_Epoch: NSItemProvider) {
        itemProvider_Epoch.loadObject(ofClass: UIImage.self) { [weak self] image_Epoch, error_Epoch in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Epoch = error_Epoch {
                print("❌ 加载图片失败: \(error_Epoch)")
                self.callCompletion_Epoch(.cancelled_Epoch)
                return
            }
            
            // 类型转换和回调
            if let image_Epoch = image_Epoch as? UIImage {
                self.callCompletion_Epoch(.photo_Epoch(image_Epoch: image_Epoch))
            } else {
                self.callCompletion_Epoch(.cancelled_Epoch)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Epoch(itemProvider_Epoch: NSItemProvider) {
        itemProvider_Epoch.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Epoch, error_Epoch in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Epoch = error_Epoch {
                print("❌ 加载视频失败: \(error_Epoch)")
                self.callCompletion_Epoch(.cancelled_Epoch)
                return
            }
            
            guard let url_Epoch = url_Epoch else {
                print("❌ 视频URL为空")
                self.callCompletion_Epoch(.cancelled_Epoch)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Epoch(sourceURL_Epoch: url_Epoch)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Epoch: 原始视频URL
    private func copyVideoToTemp_Epoch(sourceURL_Epoch: URL) {
        // 生成临时文件路径
        let fileName_Epoch = "\(Self.tempVideoPrefix_Epoch)\(Date().timeIntervalSince1970)"
        let tempURL_Epoch = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Epoch)
            .appendingPathExtension(sourceURL_Epoch.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Epoch(at: tempURL_Epoch)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Epoch, to: tempURL_Epoch)
            print("✅ 视频已复制到临时目录: \(tempURL_Epoch.path)")
            
            callCompletion_Epoch(.video_Epoch(url_Epoch: tempURL_Epoch))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Epoch(.cancelled_Epoch)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Epoch(at url_Epoch: URL) throws {
        if FileManager.default.fileExists(atPath: url_Epoch.path) {
            try FileManager.default.removeItem(at: url_Epoch)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Epoch: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Epoch = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Epoch(.cancelled_Epoch)
            return
        }
        
        let itemProvider_Epoch = result_Epoch.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Epoch.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Epoch(itemProvider_Epoch: itemProvider_Epoch)
        } else if itemProvider_Epoch.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Epoch(itemProvider_Epoch: itemProvider_Epoch)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Epoch(.cancelled_Epoch)
        }
    }
}
