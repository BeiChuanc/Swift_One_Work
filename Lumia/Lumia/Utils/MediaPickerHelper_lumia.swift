import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Lumia: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Lumia = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Lumia {
        case photo_Lumia           // 仅图片
        case video_Lumia           // 仅视频
        case photoAndVideo_Lumia   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Lumia {
        case photo_Lumia(image_Lumia: UIImage)      // 图片结果
        case video_Lumia(url_Lumia: URL)            // 视频结果
        case cancelled_Lumia                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Lumia = MediaPickerHelper_Lumia()
    
    /// 完成回调
    private var completion_Lumia: ((PickerResult_Lumia) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Lumia: MediaType_Lumia = .photo_Lumia
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Lumia(
        from viewController_Lumia: UIViewController,
        mediaType_Lumia: MediaType_Lumia = .photo_Lumia,
        selectionLimit_Lumia: Int = 1,
        completion_Lumia: @escaping (PickerResult_Lumia) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Lumia = completion_Lumia
        self.currentMediaType_Lumia = mediaType_Lumia
        
        // 配置 PHPicker
        var config_Lumia = PHPickerConfiguration()
        config_Lumia.selectionLimit = selectionLimit_Lumia
        
        // 根据媒体类型设置过滤器
        switch mediaType_Lumia {
        case .photo_Lumia:
            config_Lumia.filter = .images
        case .video_Lumia:
            config_Lumia.filter = .videos
        case .photoAndVideo_Lumia:
            config_Lumia.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Lumia = PHPickerViewController(configuration: config_Lumia)
        picker_Lumia.delegate = self
        
        viewController_Lumia.present(picker_Lumia, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Lumia(
        from viewController_Lumia: UIViewController,
        completion_Lumia: @escaping (UIImage?) -> Void
    ) {
        shared_Lumia.showPicker_Lumia(
            from: viewController_Lumia,
            mediaType_Lumia: .photo_Lumia
        ) { result_Lumia in
            if case .photo_Lumia(let image_Lumia) = result_Lumia {
                completion_Lumia(image_Lumia)
            } else {
                completion_Lumia(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Lumia(
        from viewController_Lumia: UIViewController,
        completion_Lumia: @escaping (URL?) -> Void
    ) {
        shared_Lumia.showPicker_Lumia(
            from: viewController_Lumia,
            mediaType_Lumia: .video_Lumia
        ) { result_Lumia in
            if case .video_Lumia(let url_Lumia) = result_Lumia {
                completion_Lumia(url_Lumia)
            } else {
                completion_Lumia(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Lumia(
        from viewController_Lumia: UIViewController,
        completion_Lumia: @escaping (PickerResult_Lumia) -> Void
    ) {
        shared_Lumia.showPicker_Lumia(
            from: viewController_Lumia,
            mediaType_Lumia: .photoAndVideo_Lumia,
            completion_Lumia: completion_Lumia
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Lumia(_ result_Lumia: PickerResult_Lumia) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Lumia?(result_Lumia)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Lumia(itemProvider_Lumia: NSItemProvider) {
        itemProvider_Lumia.loadObject(ofClass: UIImage.self) { [weak self] image_Lumia, error_Lumia in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Lumia = error_Lumia {
                print("❌ 加载图片失败: \(error_Lumia)")
                self.callCompletion_Lumia(.cancelled_Lumia)
                return
            }
            
            // 类型转换和回调
            if let image_Lumia = image_Lumia as? UIImage {
                self.callCompletion_Lumia(.photo_Lumia(image_Lumia: image_Lumia))
            } else {
                self.callCompletion_Lumia(.cancelled_Lumia)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Lumia(itemProvider_Lumia: NSItemProvider) {
        itemProvider_Lumia.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Lumia, error_Lumia in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Lumia = error_Lumia {
                print("❌ 加载视频失败: \(error_Lumia)")
                self.callCompletion_Lumia(.cancelled_Lumia)
                return
            }
            
            guard let url_Lumia = url_Lumia else {
                print("❌ 视频URL为空")
                self.callCompletion_Lumia(.cancelled_Lumia)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Lumia(sourceURL_Lumia: url_Lumia)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Lumia: 原始视频URL
    private func copyVideoToTemp_Lumia(sourceURL_Lumia: URL) {
        // 生成临时文件路径
        let fileName_Lumia = "\(Self.tempVideoPrefix_Lumia)\(Date().timeIntervalSince1970)"
        let tempURL_Lumia = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Lumia)
            .appendingPathExtension(sourceURL_Lumia.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Lumia(at: tempURL_Lumia)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Lumia, to: tempURL_Lumia)
            print("✅ 视频已复制到临时目录: \(tempURL_Lumia.path)")
            
            callCompletion_Lumia(.video_Lumia(url_Lumia: tempURL_Lumia))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Lumia(.cancelled_Lumia)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Lumia(at url_Lumia: URL) throws {
        if FileManager.default.fileExists(atPath: url_Lumia.path) {
            try FileManager.default.removeItem(at: url_Lumia)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Lumia: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Lumia = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Lumia(.cancelled_Lumia)
            return
        }
        
        let itemProvider_Lumia = result_Lumia.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Lumia.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Lumia(itemProvider_Lumia: itemProvider_Lumia)
        } else if itemProvider_Lumia.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Lumia(itemProvider_Lumia: itemProvider_Lumia)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Lumia(.cancelled_Lumia)
        }
    }
}
