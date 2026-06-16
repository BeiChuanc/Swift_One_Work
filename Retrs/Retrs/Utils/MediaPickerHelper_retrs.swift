import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Retrs: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Retrs = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Retrs {
        case photo_Retrs           // 仅图片
        case video_Retrs           // 仅视频
        case photoAndVideo_Retrs   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Retrs {
        case photo_Retrs(image_Retrs: UIImage)      // 图片结果
        case video_Retrs(url_Retrs: URL)            // 视频结果
        case cancelled_Retrs                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Retrs = MediaPickerHelper_Retrs()
    
    /// 完成回调
    private var completion_Retrs: ((PickerResult_Retrs) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Retrs: MediaType_Retrs = .photo_Retrs
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Retrs(
        from viewController_Retrs: UIViewController,
        mediaType_Retrs: MediaType_Retrs = .photo_Retrs,
        selectionLimit_Retrs: Int = 1,
        completion_Retrs: @escaping (PickerResult_Retrs) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Retrs = completion_Retrs
        self.currentMediaType_Retrs = mediaType_Retrs
        
        // 配置 PHPicker
        var config_Retrs = PHPickerConfiguration()
        config_Retrs.selectionLimit = selectionLimit_Retrs
        
        // 根据媒体类型设置过滤器
        switch mediaType_Retrs {
        case .photo_Retrs:
            config_Retrs.filter = .images
        case .video_Retrs:
            config_Retrs.filter = .videos
        case .photoAndVideo_Retrs:
            config_Retrs.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Retrs = PHPickerViewController(configuration: config_Retrs)
        picker_Retrs.delegate = self
        
        viewController_Retrs.present(picker_Retrs, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Retrs(
        from viewController_Retrs: UIViewController,
        completion_Retrs: @escaping (UIImage?) -> Void
    ) {
        shared_Retrs.showPicker_Retrs(
            from: viewController_Retrs,
            mediaType_Retrs: .photo_Retrs
        ) { result_Retrs in
            if case .photo_Retrs(let image_Retrs) = result_Retrs {
                completion_Retrs(image_Retrs)
            } else {
                completion_Retrs(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Retrs(
        from viewController_Retrs: UIViewController,
        completion_Retrs: @escaping (URL?) -> Void
    ) {
        shared_Retrs.showPicker_Retrs(
            from: viewController_Retrs,
            mediaType_Retrs: .video_Retrs
        ) { result_Retrs in
            if case .video_Retrs(let url_Retrs) = result_Retrs {
                completion_Retrs(url_Retrs)
            } else {
                completion_Retrs(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Retrs(
        from viewController_Retrs: UIViewController,
        completion_Retrs: @escaping (PickerResult_Retrs) -> Void
    ) {
        shared_Retrs.showPicker_Retrs(
            from: viewController_Retrs,
            mediaType_Retrs: .photoAndVideo_Retrs,
            completion_Retrs: completion_Retrs
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Retrs(_ result_Retrs: PickerResult_Retrs) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Retrs?(result_Retrs)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Retrs(itemProvider_Retrs: NSItemProvider) {
        itemProvider_Retrs.loadObject(ofClass: UIImage.self) { [weak self] image_Retrs, error_Retrs in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Retrs = error_Retrs {
                print("❌ 加载图片失败: \(error_Retrs)")
                self.callCompletion_Retrs(.cancelled_Retrs)
                return
            }
            
            // 类型转换和回调
            if let image_Retrs = image_Retrs as? UIImage {
                self.callCompletion_Retrs(.photo_Retrs(image_Retrs: image_Retrs))
            } else {
                self.callCompletion_Retrs(.cancelled_Retrs)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Retrs(itemProvider_Retrs: NSItemProvider) {
        itemProvider_Retrs.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Retrs, error_Retrs in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Retrs = error_Retrs {
                print("❌ 加载视频失败: \(error_Retrs)")
                self.callCompletion_Retrs(.cancelled_Retrs)
                return
            }
            
            guard let url_Retrs = url_Retrs else {
                print("❌ 视频URL为空")
                self.callCompletion_Retrs(.cancelled_Retrs)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Retrs(sourceURL_Retrs: url_Retrs)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Retrs: 原始视频URL
    private func copyVideoToTemp_Retrs(sourceURL_Retrs: URL) {
        // 生成临时文件路径
        let fileName_Retrs = "\(Self.tempVideoPrefix_Retrs)\(Date().timeIntervalSince1970)"
        let tempURL_Retrs = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Retrs)
            .appendingPathExtension(sourceURL_Retrs.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Retrs(at: tempURL_Retrs)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Retrs, to: tempURL_Retrs)
            print("✅ 视频已复制到临时目录: \(tempURL_Retrs.path)")
            
            callCompletion_Retrs(.video_Retrs(url_Retrs: tempURL_Retrs))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Retrs(.cancelled_Retrs)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Retrs(at url_Retrs: URL) throws {
        if FileManager.default.fileExists(atPath: url_Retrs.path) {
            try FileManager.default.removeItem(at: url_Retrs)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Retrs: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Retrs = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Retrs(.cancelled_Retrs)
            return
        }
        
        let itemProvider_Retrs = result_Retrs.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Retrs.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Retrs(itemProvider_Retrs: itemProvider_Retrs)
        } else if itemProvider_Retrs.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Retrs(itemProvider_Retrs: itemProvider_Retrs)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Retrs(.cancelled_Retrs)
        }
    }
}
