import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Sylva: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Sylva = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Sylva {
        case photo_Sylva           // 仅图片
        case video_Sylva           // 仅视频
        case photoAndVideo_Sylva   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Sylva {
        case photo_Sylva(image_Sylva: UIImage)      // 图片结果
        case video_Sylva(url_Sylva: URL)            // 视频结果
        case cancelled_Sylva                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Sylva = MediaPickerHelper_Sylva()
    
    /// 完成回调
    private var completion_Sylva: ((PickerResult_Sylva) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Sylva: MediaType_Sylva = .photo_Sylva
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Sylva(
        from viewController_Sylva: UIViewController,
        mediaType_Sylva: MediaType_Sylva = .photo_Sylva,
        selectionLimit_Sylva: Int = 1,
        completion_Sylva: @escaping (PickerResult_Sylva) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Sylva = completion_Sylva
        self.currentMediaType_Sylva = mediaType_Sylva
        
        // 配置 PHPicker
        var config_Sylva = PHPickerConfiguration()
        config_Sylva.selectionLimit = selectionLimit_Sylva
        
        // 根据媒体类型设置过滤器
        switch mediaType_Sylva {
        case .photo_Sylva:
            config_Sylva.filter = .images
        case .video_Sylva:
            config_Sylva.filter = .videos
        case .photoAndVideo_Sylva:
            config_Sylva.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Sylva = PHPickerViewController(configuration: config_Sylva)
        picker_Sylva.delegate = self
        
        viewController_Sylva.present(picker_Sylva, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Sylva(
        from viewController_Sylva: UIViewController,
        completion_Sylva: @escaping (UIImage?) -> Void
    ) {
        shared_Sylva.showPicker_Sylva(
            from: viewController_Sylva,
            mediaType_Sylva: .photo_Sylva
        ) { result_Sylva in
            if case .photo_Sylva(let image_Sylva) = result_Sylva {
                completion_Sylva(image_Sylva)
            } else {
                completion_Sylva(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Sylva(
        from viewController_Sylva: UIViewController,
        completion_Sylva: @escaping (URL?) -> Void
    ) {
        shared_Sylva.showPicker_Sylva(
            from: viewController_Sylva,
            mediaType_Sylva: .video_Sylva
        ) { result_Sylva in
            if case .video_Sylva(let url_Sylva) = result_Sylva {
                completion_Sylva(url_Sylva)
            } else {
                completion_Sylva(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Sylva(
        from viewController_Sylva: UIViewController,
        completion_Sylva: @escaping (PickerResult_Sylva) -> Void
    ) {
        shared_Sylva.showPicker_Sylva(
            from: viewController_Sylva,
            mediaType_Sylva: .photoAndVideo_Sylva,
            completion_Sylva: completion_Sylva
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Sylva(_ result_Sylva: PickerResult_Sylva) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Sylva?(result_Sylva)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Sylva(itemProvider_Sylva: NSItemProvider) {
        itemProvider_Sylva.loadObject(ofClass: UIImage.self) { [weak self] image_Sylva, error_Sylva in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Sylva = error_Sylva {
                print("❌ 加载图片失败: \(error_Sylva)")
                self.callCompletion_Sylva(.cancelled_Sylva)
                return
            }
            
            // 类型转换和回调
            if let image_Sylva = image_Sylva as? UIImage {
                self.callCompletion_Sylva(.photo_Sylva(image_Sylva: image_Sylva))
            } else {
                self.callCompletion_Sylva(.cancelled_Sylva)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Sylva(itemProvider_Sylva: NSItemProvider) {
        itemProvider_Sylva.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Sylva, error_Sylva in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Sylva = error_Sylva {
                print("❌ 加载视频失败: \(error_Sylva)")
                self.callCompletion_Sylva(.cancelled_Sylva)
                return
            }
            
            guard let url_Sylva = url_Sylva else {
                print("❌ 视频URL为空")
                self.callCompletion_Sylva(.cancelled_Sylva)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Sylva(sourceURL_Sylva: url_Sylva)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Sylva: 原始视频URL
    private func copyVideoToTemp_Sylva(sourceURL_Sylva: URL) {
        // 生成临时文件路径
        let fileName_Sylva = "\(Self.tempVideoPrefix_Sylva)\(Date().timeIntervalSince1970)"
        let tempURL_Sylva = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Sylva)
            .appendingPathExtension(sourceURL_Sylva.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Sylva(at: tempURL_Sylva)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Sylva, to: tempURL_Sylva)
            print("✅ 视频已复制到临时目录: \(tempURL_Sylva.path)")
            
            callCompletion_Sylva(.video_Sylva(url_Sylva: tempURL_Sylva))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Sylva(.cancelled_Sylva)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Sylva(at url_Sylva: URL) throws {
        if FileManager.default.fileExists(atPath: url_Sylva.path) {
            try FileManager.default.removeItem(at: url_Sylva)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Sylva: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Sylva = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Sylva(.cancelled_Sylva)
            return
        }
        
        let itemProvider_Sylva = result_Sylva.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Sylva.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Sylva(itemProvider_Sylva: itemProvider_Sylva)
        } else if itemProvider_Sylva.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Sylva(itemProvider_Sylva: itemProvider_Sylva)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Sylva(.cancelled_Sylva)
        }
    }
}
