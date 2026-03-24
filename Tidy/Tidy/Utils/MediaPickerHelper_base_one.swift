import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Base_one: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Base_one = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Base_one {
        case photo_Base_one           // 仅图片
        case video_Base_one           // 仅视频
        case photoAndVideo_Base_one   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Base_one {
        case photo_Base_one(image_Base_one: UIImage)      // 图片结果
        case video_Base_one(url_Base_one: URL)            // 视频结果
        case cancelled_Base_one                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Base_one = MediaPickerHelper_Base_one()
    
    /// 完成回调
    private var completion_Base_one: ((PickerResult_Base_one) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Base_one: MediaType_Base_one = .photo_Base_one
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Base_one(
        from viewController_Base_one: UIViewController,
        mediaType_Base_one: MediaType_Base_one = .photo_Base_one,
        selectionLimit_Base_one: Int = 1,
        completion_Base_one: @escaping (PickerResult_Base_one) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Base_one = completion_Base_one
        self.currentMediaType_Base_one = mediaType_Base_one
        
        // 配置 PHPicker
        var config_Base_one = PHPickerConfiguration()
        config_Base_one.selectionLimit = selectionLimit_Base_one
        
        // 根据媒体类型设置过滤器
        switch mediaType_Base_one {
        case .photo_Base_one:
            config_Base_one.filter = .images
        case .video_Base_one:
            config_Base_one.filter = .videos
        case .photoAndVideo_Base_one:
            config_Base_one.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Base_one = PHPickerViewController(configuration: config_Base_one)
        picker_Base_one.delegate = self
        
        viewController_Base_one.present(picker_Base_one, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Base_one(
        from viewController_Base_one: UIViewController,
        completion_Base_one: @escaping (UIImage?) -> Void
    ) {
        shared_Base_one.showPicker_Base_one(
            from: viewController_Base_one,
            mediaType_Base_one: .photo_Base_one
        ) { result_Base_one in
            if case .photo_Base_one(let image_Base_one) = result_Base_one {
                completion_Base_one(image_Base_one)
            } else {
                completion_Base_one(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Base_one(
        from viewController_Base_one: UIViewController,
        completion_Base_one: @escaping (URL?) -> Void
    ) {
        shared_Base_one.showPicker_Base_one(
            from: viewController_Base_one,
            mediaType_Base_one: .video_Base_one
        ) { result_Base_one in
            if case .video_Base_one(let url_Base_one) = result_Base_one {
                completion_Base_one(url_Base_one)
            } else {
                completion_Base_one(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Base_one(
        from viewController_Base_one: UIViewController,
        completion_Base_one: @escaping (PickerResult_Base_one) -> Void
    ) {
        shared_Base_one.showPicker_Base_one(
            from: viewController_Base_one,
            mediaType_Base_one: .photoAndVideo_Base_one,
            completion_Base_one: completion_Base_one
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Base_one(_ result_Base_one: PickerResult_Base_one) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Base_one?(result_Base_one)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Base_one(itemProvider_Base_one: NSItemProvider) {
        itemProvider_Base_one.loadObject(ofClass: UIImage.self) { [weak self] image_Base_one, error_Base_one in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Base_one = error_Base_one {
                print("❌ 加载图片失败: \(error_Base_one)")
                self.callCompletion_Base_one(.cancelled_Base_one)
                return
            }
            
            // 类型转换和回调
            if let image_Base_one = image_Base_one as? UIImage {
                self.callCompletion_Base_one(.photo_Base_one(image_Base_one: image_Base_one))
            } else {
                self.callCompletion_Base_one(.cancelled_Base_one)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Base_one(itemProvider_Base_one: NSItemProvider) {
        itemProvider_Base_one.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Base_one, error_Base_one in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Base_one = error_Base_one {
                print("❌ 加载视频失败: \(error_Base_one)")
                self.callCompletion_Base_one(.cancelled_Base_one)
                return
            }
            
            guard let url_Base_one = url_Base_one else {
                print("❌ 视频URL为空")
                self.callCompletion_Base_one(.cancelled_Base_one)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Base_one(sourceURL_Base_one: url_Base_one)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Base_one: 原始视频URL
    private func copyVideoToTemp_Base_one(sourceURL_Base_one: URL) {
        // 生成临时文件路径
        let fileName_Base_one = "\(Self.tempVideoPrefix_Base_one)\(Date().timeIntervalSince1970)"
        let tempURL_Base_one = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Base_one)
            .appendingPathExtension(sourceURL_Base_one.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Base_one(at: tempURL_Base_one)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Base_one, to: tempURL_Base_one)
            print("✅ 视频已复制到临时目录: \(tempURL_Base_one.path)")
            
            callCompletion_Base_one(.video_Base_one(url_Base_one: tempURL_Base_one))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Base_one(.cancelled_Base_one)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Base_one(at url_Base_one: URL) throws {
        if FileManager.default.fileExists(atPath: url_Base_one.path) {
            try FileManager.default.removeItem(at: url_Base_one)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Base_one: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Base_one = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Base_one(.cancelled_Base_one)
            return
        }
        
        let itemProvider_Base_one = result_Base_one.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Base_one.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Base_one(itemProvider_Base_one: itemProvider_Base_one)
        } else if itemProvider_Base_one.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Base_one(itemProvider_Base_one: itemProvider_Base_one)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Base_one(.cancelled_Base_one)
        }
    }
}
