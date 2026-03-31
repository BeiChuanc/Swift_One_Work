import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Flick: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Flick = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Flick {
        case photo_Flick           // 仅图片
        case video_Flick           // 仅视频
        case photoAndVideo_Flick   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Flick {
        case photo_Flick(image_Flick: UIImage)      // 图片结果
        case video_Flick(url_Flick: URL)            // 视频结果
        case cancelled_Flick                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Flick = MediaPickerHelper_Flick()
    
    /// 完成回调
    private var completion_Flick: ((PickerResult_Flick) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Flick: MediaType_Flick = .photo_Flick
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Flick(
        from viewController_Flick: UIViewController,
        mediaType_Flick: MediaType_Flick = .photo_Flick,
        selectionLimit_Flick: Int = 1,
        completion_Flick: @escaping (PickerResult_Flick) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Flick = completion_Flick
        self.currentMediaType_Flick = mediaType_Flick
        
        // 配置 PHPicker
        var config_Flick = PHPickerConfiguration()
        config_Flick.selectionLimit = selectionLimit_Flick
        
        // 根据媒体类型设置过滤器
        switch mediaType_Flick {
        case .photo_Flick:
            config_Flick.filter = .images
        case .video_Flick:
            config_Flick.filter = .videos
        case .photoAndVideo_Flick:
            config_Flick.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Flick = PHPickerViewController(configuration: config_Flick)
        picker_Flick.delegate = self
        
        viewController_Flick.present(picker_Flick, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Flick(
        from viewController_Flick: UIViewController,
        completion_Flick: @escaping (UIImage?) -> Void
    ) {
        shared_Flick.showPicker_Flick(
            from: viewController_Flick,
            mediaType_Flick: .photo_Flick
        ) { result_Flick in
            if case .photo_Flick(let image_Flick) = result_Flick {
                completion_Flick(image_Flick)
            } else {
                completion_Flick(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Flick(
        from viewController_Flick: UIViewController,
        completion_Flick: @escaping (URL?) -> Void
    ) {
        shared_Flick.showPicker_Flick(
            from: viewController_Flick,
            mediaType_Flick: .video_Flick
        ) { result_Flick in
            if case .video_Flick(let url_Flick) = result_Flick {
                completion_Flick(url_Flick)
            } else {
                completion_Flick(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Flick(
        from viewController_Flick: UIViewController,
        completion_Flick: @escaping (PickerResult_Flick) -> Void
    ) {
        shared_Flick.showPicker_Flick(
            from: viewController_Flick,
            mediaType_Flick: .photoAndVideo_Flick,
            completion_Flick: completion_Flick
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Flick(_ result_Flick: PickerResult_Flick) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Flick?(result_Flick)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Flick(itemProvider_Flick: NSItemProvider) {
        itemProvider_Flick.loadObject(ofClass: UIImage.self) { [weak self] image_Flick, error_Flick in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Flick = error_Flick {
                print("❌ 加载图片失败: \(error_Flick)")
                self.callCompletion_Flick(.cancelled_Flick)
                return
            }
            
            // 类型转换和回调
            if let image_Flick = image_Flick as? UIImage {
                self.callCompletion_Flick(.photo_Flick(image_Flick: image_Flick))
            } else {
                self.callCompletion_Flick(.cancelled_Flick)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Flick(itemProvider_Flick: NSItemProvider) {
        itemProvider_Flick.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Flick, error_Flick in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Flick = error_Flick {
                print("❌ 加载视频失败: \(error_Flick)")
                self.callCompletion_Flick(.cancelled_Flick)
                return
            }
            
            guard let url_Flick = url_Flick else {
                print("❌ 视频URL为空")
                self.callCompletion_Flick(.cancelled_Flick)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Flick(sourceURL_Flick: url_Flick)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Flick: 原始视频URL
    private func copyVideoToTemp_Flick(sourceURL_Flick: URL) {
        // 生成临时文件路径
        let fileName_Flick = "\(Self.tempVideoPrefix_Flick)\(Date().timeIntervalSince1970)"
        let tempURL_Flick = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Flick)
            .appendingPathExtension(sourceURL_Flick.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Flick(at: tempURL_Flick)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Flick, to: tempURL_Flick)
            print("✅ 视频已复制到临时目录: \(tempURL_Flick.path)")
            
            callCompletion_Flick(.video_Flick(url_Flick: tempURL_Flick))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Flick(.cancelled_Flick)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Flick(at url_Flick: URL) throws {
        if FileManager.default.fileExists(atPath: url_Flick.path) {
            try FileManager.default.removeItem(at: url_Flick)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Flick: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Flick = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Flick(.cancelled_Flick)
            return
        }
        
        let itemProvider_Flick = result_Flick.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Flick.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Flick(itemProvider_Flick: itemProvider_Flick)
        } else if itemProvider_Flick.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Flick(itemProvider_Flick: itemProvider_Flick)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Flick(.cancelled_Flick)
        }
    }
}
