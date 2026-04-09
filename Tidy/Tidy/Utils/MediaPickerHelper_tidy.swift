import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Tidy: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Tidy = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Tidy {
        case photo_Tidy           // 仅图片
        case video_Tidy           // 仅视频
        case photoAndVideo_Tidy   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Tidy {
        case photo_Tidy(image_Tidy: UIImage)      // 图片结果
        case video_Tidy(url_Tidy: URL)            // 视频结果
        case cancelled_Tidy                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Tidy = MediaPickerHelper_Tidy()
    
    /// 完成回调
    private var completion_Tidy: ((PickerResult_Tidy) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Tidy: MediaType_Tidy = .photo_Tidy
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Tidy(
        from viewController_Tidy: UIViewController,
        mediaType_Tidy: MediaType_Tidy = .photo_Tidy,
        selectionLimit_Tidy: Int = 1,
        completion_Tidy: @escaping (PickerResult_Tidy) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Tidy = completion_Tidy
        self.currentMediaType_Tidy = mediaType_Tidy
        
        // 配置 PHPicker
        var config_Tidy = PHPickerConfiguration()
        config_Tidy.selectionLimit = selectionLimit_Tidy
        
        // 根据媒体类型设置过滤器
        switch mediaType_Tidy {
        case .photo_Tidy:
            config_Tidy.filter = .images
        case .video_Tidy:
            config_Tidy.filter = .videos
        case .photoAndVideo_Tidy:
            config_Tidy.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Tidy = PHPickerViewController(configuration: config_Tidy)
        picker_Tidy.delegate = self
        
        viewController_Tidy.present(picker_Tidy, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Tidy(
        from viewController_Tidy: UIViewController,
        completion_Tidy: @escaping (UIImage?) -> Void
    ) {
        shared_Tidy.showPicker_Tidy(
            from: viewController_Tidy,
            mediaType_Tidy: .photo_Tidy
        ) { result_Tidy in
            if case .photo_Tidy(let image_Tidy) = result_Tidy {
                completion_Tidy(image_Tidy)
            } else {
                completion_Tidy(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Tidy(
        from viewController_Tidy: UIViewController,
        completion_Tidy: @escaping (URL?) -> Void
    ) {
        shared_Tidy.showPicker_Tidy(
            from: viewController_Tidy,
            mediaType_Tidy: .video_Tidy
        ) { result_Tidy in
            if case .video_Tidy(let url_Tidy) = result_Tidy {
                completion_Tidy(url_Tidy)
            } else {
                completion_Tidy(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Tidy(
        from viewController_Tidy: UIViewController,
        completion_Tidy: @escaping (PickerResult_Tidy) -> Void
    ) {
        shared_Tidy.showPicker_Tidy(
            from: viewController_Tidy,
            mediaType_Tidy: .photoAndVideo_Tidy,
            completion_Tidy: completion_Tidy
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Tidy(_ result_Tidy: PickerResult_Tidy) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Tidy?(result_Tidy)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Tidy(itemProvider_Tidy: NSItemProvider) {
        itemProvider_Tidy.loadObject(ofClass: UIImage.self) { [weak self] image_Tidy, error_Tidy in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Tidy = error_Tidy {
                print("❌ 加载图片失败: \(error_Tidy)")
                self.callCompletion_Tidy(.cancelled_Tidy)
                return
            }
            
            // 类型转换和回调
            if let image_Tidy = image_Tidy as? UIImage {
                self.callCompletion_Tidy(.photo_Tidy(image_Tidy: image_Tidy))
            } else {
                self.callCompletion_Tidy(.cancelled_Tidy)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Tidy(itemProvider_Tidy: NSItemProvider) {
        itemProvider_Tidy.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Tidy, error_Tidy in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Tidy = error_Tidy {
                print("❌ 加载视频失败: \(error_Tidy)")
                self.callCompletion_Tidy(.cancelled_Tidy)
                return
            }
            
            guard let url_Tidy = url_Tidy else {
                print("❌ 视频URL为空")
                self.callCompletion_Tidy(.cancelled_Tidy)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Tidy(sourceURL_Tidy: url_Tidy)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Tidy: 原始视频URL
    private func copyVideoToTemp_Tidy(sourceURL_Tidy: URL) {
        // 生成临时文件路径
        let fileName_Tidy = "\(Self.tempVideoPrefix_Tidy)\(Date().timeIntervalSince1970)"
        let tempURL_Tidy = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Tidy)
            .appendingPathExtension(sourceURL_Tidy.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Tidy(at: tempURL_Tidy)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Tidy, to: tempURL_Tidy)
            print("✅ 视频已复制到临时目录: \(tempURL_Tidy.path)")
            
            callCompletion_Tidy(.video_Tidy(url_Tidy: tempURL_Tidy))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Tidy(.cancelled_Tidy)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Tidy(at url_Tidy: URL) throws {
        if FileManager.default.fileExists(atPath: url_Tidy.path) {
            try FileManager.default.removeItem(at: url_Tidy)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Tidy: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Tidy = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Tidy(.cancelled_Tidy)
            return
        }
        
        let itemProvider_Tidy = result_Tidy.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Tidy.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Tidy(itemProvider_Tidy: itemProvider_Tidy)
        } else if itemProvider_Tidy.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Tidy(itemProvider_Tidy: itemProvider_Tidy)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Tidy(.cancelled_Tidy)
        }
    }
}
