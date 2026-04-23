import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Nest: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Nest = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Nest {
        case photo_Nest           // 仅图片
        case video_Nest           // 仅视频
        case photoAndVideo_Nest   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Nest {
        case photo_Nest(image_Nest: UIImage)      // 图片结果
        case video_Nest(url_Nest: URL)            // 视频结果
        case cancelled_Nest                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Nest = MediaPickerHelper_Nest()
    
    /// 完成回调
    private var completion_Nest: ((PickerResult_Nest) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Nest: MediaType_Nest = .photo_Nest
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Nest(
        from viewController_Nest: UIViewController,
        mediaType_Nest: MediaType_Nest = .photo_Nest,
        selectionLimit_Nest: Int = 1,
        completion_Nest: @escaping (PickerResult_Nest) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Nest = completion_Nest
        self.currentMediaType_Nest = mediaType_Nest
        
        // 配置 PHPicker
        var config_Nest = PHPickerConfiguration()
        config_Nest.selectionLimit = selectionLimit_Nest
        
        // 根据媒体类型设置过滤器
        switch mediaType_Nest {
        case .photo_Nest:
            config_Nest.filter = .images
        case .video_Nest:
            config_Nest.filter = .videos
        case .photoAndVideo_Nest:
            config_Nest.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Nest = PHPickerViewController(configuration: config_Nest)
        picker_Nest.delegate = self
        
        viewController_Nest.present(picker_Nest, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Nest(
        from viewController_Nest: UIViewController,
        completion_Nest: @escaping (UIImage?) -> Void
    ) {
        shared_Nest.showPicker_Nest(
            from: viewController_Nest,
            mediaType_Nest: .photo_Nest
        ) { result_Nest in
            if case .photo_Nest(let image_Nest) = result_Nest {
                completion_Nest(image_Nest)
            } else {
                completion_Nest(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Nest(
        from viewController_Nest: UIViewController,
        completion_Nest: @escaping (URL?) -> Void
    ) {
        shared_Nest.showPicker_Nest(
            from: viewController_Nest,
            mediaType_Nest: .video_Nest
        ) { result_Nest in
            if case .video_Nest(let url_Nest) = result_Nest {
                completion_Nest(url_Nest)
            } else {
                completion_Nest(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Nest(
        from viewController_Nest: UIViewController,
        completion_Nest: @escaping (PickerResult_Nest) -> Void
    ) {
        shared_Nest.showPicker_Nest(
            from: viewController_Nest,
            mediaType_Nest: .photoAndVideo_Nest,
            completion_Nest: completion_Nest
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Nest(_ result_Nest: PickerResult_Nest) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Nest?(result_Nest)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Nest(itemProvider_Nest: NSItemProvider) {
        itemProvider_Nest.loadObject(ofClass: UIImage.self) { [weak self] image_Nest, error_Nest in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Nest = error_Nest {
                print("❌ 加载图片失败: \(error_Nest)")
                self.callCompletion_Nest(.cancelled_Nest)
                return
            }
            
            // 类型转换和回调
            if let image_Nest = image_Nest as? UIImage {
                self.callCompletion_Nest(.photo_Nest(image_Nest: image_Nest))
            } else {
                self.callCompletion_Nest(.cancelled_Nest)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Nest(itemProvider_Nest: NSItemProvider) {
        itemProvider_Nest.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Nest, error_Nest in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Nest = error_Nest {
                print("❌ 加载视频失败: \(error_Nest)")
                self.callCompletion_Nest(.cancelled_Nest)
                return
            }
            
            guard let url_Nest = url_Nest else {
                print("❌ 视频URL为空")
                self.callCompletion_Nest(.cancelled_Nest)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Nest(sourceURL_Nest: url_Nest)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Nest: 原始视频URL
    private func copyVideoToTemp_Nest(sourceURL_Nest: URL) {
        // 生成临时文件路径
        let fileName_Nest = "\(Self.tempVideoPrefix_Nest)\(Date().timeIntervalSince1970)"
        let tempURL_Nest = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Nest)
            .appendingPathExtension(sourceURL_Nest.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Nest(at: tempURL_Nest)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Nest, to: tempURL_Nest)
            print("✅ 视频已复制到临时目录: \(tempURL_Nest.path)")
            
            callCompletion_Nest(.video_Nest(url_Nest: tempURL_Nest))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Nest(.cancelled_Nest)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Nest(at url_Nest: URL) throws {
        if FileManager.default.fileExists(atPath: url_Nest.path) {
            try FileManager.default.removeItem(at: url_Nest)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Nest: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Nest = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Nest(.cancelled_Nest)
            return
        }
        
        let itemProvider_Nest = result_Nest.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Nest.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Nest(itemProvider_Nest: itemProvider_Nest)
        } else if itemProvider_Nest.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Nest(itemProvider_Nest: itemProvider_Nest)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Nest(.cancelled_Nest)
        }
    }
}
