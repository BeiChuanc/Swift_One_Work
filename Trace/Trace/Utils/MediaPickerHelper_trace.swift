import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Trace: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Trace = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Trace {
        case photo_Trace           // 仅图片
        case video_Trace           // 仅视频
        case photoAndVideo_Trace   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Trace {
        case photo_Trace(image_Trace: UIImage)      // 图片结果
        case video_Trace(url_Trace: URL)            // 视频结果
        case cancelled_Trace                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Trace = MediaPickerHelper_Trace()
    
    /// 完成回调
    private var completion_Trace: ((PickerResult_Trace) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Trace: MediaType_Trace = .photo_Trace
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Trace(
        from viewController_Trace: UIViewController,
        mediaType_Trace: MediaType_Trace = .photo_Trace,
        selectionLimit_Trace: Int = 1,
        completion_Trace: @escaping (PickerResult_Trace) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Trace = completion_Trace
        self.currentMediaType_Trace = mediaType_Trace
        
        // 配置 PHPicker
        var config_Trace = PHPickerConfiguration()
        config_Trace.selectionLimit = selectionLimit_Trace
        
        // 根据媒体类型设置过滤器
        switch mediaType_Trace {
        case .photo_Trace:
            config_Trace.filter = .images
        case .video_Trace:
            config_Trace.filter = .videos
        case .photoAndVideo_Trace:
            config_Trace.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Trace = PHPickerViewController(configuration: config_Trace)
        picker_Trace.delegate = self
        
        viewController_Trace.present(picker_Trace, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Trace(
        from viewController_Trace: UIViewController,
        completion_Trace: @escaping (UIImage?) -> Void
    ) {
        shared_Trace.showPicker_Trace(
            from: viewController_Trace,
            mediaType_Trace: .photo_Trace
        ) { result_Trace in
            if case .photo_Trace(let image_Trace) = result_Trace {
                completion_Trace(image_Trace)
            } else {
                completion_Trace(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Trace(
        from viewController_Trace: UIViewController,
        completion_Trace: @escaping (URL?) -> Void
    ) {
        shared_Trace.showPicker_Trace(
            from: viewController_Trace,
            mediaType_Trace: .video_Trace
        ) { result_Trace in
            if case .video_Trace(let url_Trace) = result_Trace {
                completion_Trace(url_Trace)
            } else {
                completion_Trace(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Trace(
        from viewController_Trace: UIViewController,
        completion_Trace: @escaping (PickerResult_Trace) -> Void
    ) {
        shared_Trace.showPicker_Trace(
            from: viewController_Trace,
            mediaType_Trace: .photoAndVideo_Trace,
            completion_Trace: completion_Trace
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Trace(_ result_Trace: PickerResult_Trace) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Trace?(result_Trace)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Trace(itemProvider_Trace: NSItemProvider) {
        itemProvider_Trace.loadObject(ofClass: UIImage.self) { [weak self] image_Trace, error_Trace in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Trace = error_Trace {
                print("❌ 加载图片失败: \(error_Trace)")
                self.callCompletion_Trace(.cancelled_Trace)
                return
            }
            
            // 类型转换和回调
            if let image_Trace = image_Trace as? UIImage {
                self.callCompletion_Trace(.photo_Trace(image_Trace: image_Trace))
            } else {
                self.callCompletion_Trace(.cancelled_Trace)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Trace(itemProvider_Trace: NSItemProvider) {
        itemProvider_Trace.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Trace, error_Trace in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Trace = error_Trace {
                print("❌ 加载视频失败: \(error_Trace)")
                self.callCompletion_Trace(.cancelled_Trace)
                return
            }
            
            guard let url_Trace = url_Trace else {
                print("❌ 视频URL为空")
                self.callCompletion_Trace(.cancelled_Trace)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Trace(sourceURL_Trace: url_Trace)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Trace: 原始视频URL
    private func copyVideoToTemp_Trace(sourceURL_Trace: URL) {
        // 生成临时文件路径
        let fileName_Trace = "\(Self.tempVideoPrefix_Trace)\(Date().timeIntervalSince1970)"
        let tempURL_Trace = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Trace)
            .appendingPathExtension(sourceURL_Trace.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Trace(at: tempURL_Trace)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Trace, to: tempURL_Trace)
            print("✅ 视频已复制到临时目录: \(tempURL_Trace.path)")
            
            callCompletion_Trace(.video_Trace(url_Trace: tempURL_Trace))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Trace(.cancelled_Trace)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Trace(at url_Trace: URL) throws {
        if FileManager.default.fileExists(atPath: url_Trace.path) {
            try FileManager.default.removeItem(at: url_Trace)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Trace: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Trace = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Trace(.cancelled_Trace)
            return
        }
        
        let itemProvider_Trace = result_Trace.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Trace.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Trace(itemProvider_Trace: itemProvider_Trace)
        } else if itemProvider_Trace.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Trace(itemProvider_Trace: itemProvider_Trace)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Trace(.cancelled_Trace)
        }
    }
}
