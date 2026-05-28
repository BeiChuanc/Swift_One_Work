import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Ornit: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Ornit = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Ornit {
        case photo_Ornit           // 仅图片
        case video_Ornit           // 仅视频
        case photoAndVideo_Ornit   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Ornit {
        case photo_Ornit(image_Ornit: UIImage)      // 图片结果
        case video_Ornit(url_Ornit: URL)            // 视频结果
        case cancelled_Ornit                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Ornit = MediaPickerHelper_Ornit()
    
    /// 完成回调
    private var completion_Ornit: ((PickerResult_Ornit) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Ornit: MediaType_Ornit = .photo_Ornit
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Ornit(
        from viewController_Ornit: UIViewController,
        mediaType_Ornit: MediaType_Ornit = .photo_Ornit,
        selectionLimit_Ornit: Int = 1,
        completion_Ornit: @escaping (PickerResult_Ornit) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Ornit = completion_Ornit
        self.currentMediaType_Ornit = mediaType_Ornit
        
        // 配置 PHPicker
        var config_Ornit = PHPickerConfiguration()
        config_Ornit.selectionLimit = selectionLimit_Ornit
        
        // 根据媒体类型设置过滤器
        switch mediaType_Ornit {
        case .photo_Ornit:
            config_Ornit.filter = .images
        case .video_Ornit:
            config_Ornit.filter = .videos
        case .photoAndVideo_Ornit:
            config_Ornit.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Ornit = PHPickerViewController(configuration: config_Ornit)
        picker_Ornit.delegate = self
        
        viewController_Ornit.present(picker_Ornit, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Ornit(
        from viewController_Ornit: UIViewController,
        completion_Ornit: @escaping (UIImage?) -> Void
    ) {
        shared_Ornit.showPicker_Ornit(
            from: viewController_Ornit,
            mediaType_Ornit: .photo_Ornit
        ) { result_Ornit in
            if case .photo_Ornit(let image_Ornit) = result_Ornit {
                completion_Ornit(image_Ornit)
            } else {
                completion_Ornit(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Ornit(
        from viewController_Ornit: UIViewController,
        completion_Ornit: @escaping (URL?) -> Void
    ) {
        shared_Ornit.showPicker_Ornit(
            from: viewController_Ornit,
            mediaType_Ornit: .video_Ornit
        ) { result_Ornit in
            if case .video_Ornit(let url_Ornit) = result_Ornit {
                completion_Ornit(url_Ornit)
            } else {
                completion_Ornit(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Ornit(
        from viewController_Ornit: UIViewController,
        completion_Ornit: @escaping (PickerResult_Ornit) -> Void
    ) {
        shared_Ornit.showPicker_Ornit(
            from: viewController_Ornit,
            mediaType_Ornit: .photoAndVideo_Ornit,
            completion_Ornit: completion_Ornit
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Ornit(_ result_Ornit: PickerResult_Ornit) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Ornit?(result_Ornit)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Ornit(itemProvider_Ornit: NSItemProvider) {
        itemProvider_Ornit.loadObject(ofClass: UIImage.self) { [weak self] image_Ornit, error_Ornit in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Ornit = error_Ornit {
                print("❌ 加载图片失败: \(error_Ornit)")
                self.callCompletion_Ornit(.cancelled_Ornit)
                return
            }
            
            // 类型转换和回调
            if let image_Ornit = image_Ornit as? UIImage {
                self.callCompletion_Ornit(.photo_Ornit(image_Ornit: image_Ornit))
            } else {
                self.callCompletion_Ornit(.cancelled_Ornit)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Ornit(itemProvider_Ornit: NSItemProvider) {
        itemProvider_Ornit.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Ornit, error_Ornit in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Ornit = error_Ornit {
                print("❌ 加载视频失败: \(error_Ornit)")
                self.callCompletion_Ornit(.cancelled_Ornit)
                return
            }
            
            guard let url_Ornit = url_Ornit else {
                print("❌ 视频URL为空")
                self.callCompletion_Ornit(.cancelled_Ornit)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Ornit(sourceURL_Ornit: url_Ornit)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Ornit: 原始视频URL
    private func copyVideoToTemp_Ornit(sourceURL_Ornit: URL) {
        // 生成临时文件路径
        let fileName_Ornit = "\(Self.tempVideoPrefix_Ornit)\(Date().timeIntervalSince1970)"
        let tempURL_Ornit = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Ornit)
            .appendingPathExtension(sourceURL_Ornit.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Ornit(at: tempURL_Ornit)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Ornit, to: tempURL_Ornit)
            print("✅ 视频已复制到临时目录: \(tempURL_Ornit.path)")
            
            callCompletion_Ornit(.video_Ornit(url_Ornit: tempURL_Ornit))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Ornit(.cancelled_Ornit)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Ornit(at url_Ornit: URL) throws {
        if FileManager.default.fileExists(atPath: url_Ornit.path) {
            try FileManager.default.removeItem(at: url_Ornit)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Ornit: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Ornit = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Ornit(.cancelled_Ornit)
            return
        }
        
        let itemProvider_Ornit = result_Ornit.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Ornit.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Ornit(itemProvider_Ornit: itemProvider_Ornit)
        } else if itemProvider_Ornit.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Ornit(itemProvider_Ornit: itemProvider_Ornit)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Ornit(.cancelled_Ornit)
        }
    }
}
