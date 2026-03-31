import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Sprig: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Sprig = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Sprig {
        case photo_Sprig           // 仅图片
        case video_Sprig           // 仅视频
        case photoAndVideo_Sprig   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Sprig {
        case photo_Sprig(image_Sprig: UIImage)      // 图片结果
        case video_Sprig(url_Sprig: URL)            // 视频结果
        case cancelled_Sprig                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Sprig = MediaPickerHelper_Sprig()
    
    /// 完成回调
    private var completion_Sprig: ((PickerResult_Sprig) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Sprig: MediaType_Sprig = .photo_Sprig
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Sprig(
        from viewController_Sprig: UIViewController,
        mediaType_Sprig: MediaType_Sprig = .photo_Sprig,
        selectionLimit_Sprig: Int = 1,
        completion_Sprig: @escaping (PickerResult_Sprig) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Sprig = completion_Sprig
        self.currentMediaType_Sprig = mediaType_Sprig
        
        // 配置 PHPicker
        var config_Sprig = PHPickerConfiguration()
        config_Sprig.selectionLimit = selectionLimit_Sprig
        
        // 根据媒体类型设置过滤器
        switch mediaType_Sprig {
        case .photo_Sprig:
            config_Sprig.filter = .images
        case .video_Sprig:
            config_Sprig.filter = .videos
        case .photoAndVideo_Sprig:
            config_Sprig.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Sprig = PHPickerViewController(configuration: config_Sprig)
        picker_Sprig.delegate = self
        
        viewController_Sprig.present(picker_Sprig, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Sprig(
        from viewController_Sprig: UIViewController,
        completion_Sprig: @escaping (UIImage?) -> Void
    ) {
        shared_Sprig.showPicker_Sprig(
            from: viewController_Sprig,
            mediaType_Sprig: .photo_Sprig
        ) { result_Sprig in
            if case .photo_Sprig(let image_Sprig) = result_Sprig {
                completion_Sprig(image_Sprig)
            } else {
                completion_Sprig(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Sprig(
        from viewController_Sprig: UIViewController,
        completion_Sprig: @escaping (URL?) -> Void
    ) {
        shared_Sprig.showPicker_Sprig(
            from: viewController_Sprig,
            mediaType_Sprig: .video_Sprig
        ) { result_Sprig in
            if case .video_Sprig(let url_Sprig) = result_Sprig {
                completion_Sprig(url_Sprig)
            } else {
                completion_Sprig(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Sprig(
        from viewController_Sprig: UIViewController,
        completion_Sprig: @escaping (PickerResult_Sprig) -> Void
    ) {
        shared_Sprig.showPicker_Sprig(
            from: viewController_Sprig,
            mediaType_Sprig: .photoAndVideo_Sprig,
            completion_Sprig: completion_Sprig
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Sprig(_ result_Sprig: PickerResult_Sprig) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Sprig?(result_Sprig)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Sprig(itemProvider_Sprig: NSItemProvider) {
        itemProvider_Sprig.loadObject(ofClass: UIImage.self) { [weak self] image_Sprig, error_Sprig in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Sprig = error_Sprig {
                print("❌ 加载图片失败: \(error_Sprig)")
                self.callCompletion_Sprig(.cancelled_Sprig)
                return
            }
            
            // 类型转换和回调
            if let image_Sprig = image_Sprig as? UIImage {
                self.callCompletion_Sprig(.photo_Sprig(image_Sprig: image_Sprig))
            } else {
                self.callCompletion_Sprig(.cancelled_Sprig)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Sprig(itemProvider_Sprig: NSItemProvider) {
        itemProvider_Sprig.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Sprig, error_Sprig in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Sprig = error_Sprig {
                print("❌ 加载视频失败: \(error_Sprig)")
                self.callCompletion_Sprig(.cancelled_Sprig)
                return
            }
            
            guard let url_Sprig = url_Sprig else {
                print("❌ 视频URL为空")
                self.callCompletion_Sprig(.cancelled_Sprig)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Sprig(sourceURL_Sprig: url_Sprig)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Sprig: 原始视频URL
    private func copyVideoToTemp_Sprig(sourceURL_Sprig: URL) {
        // 生成临时文件路径
        let fileName_Sprig = "\(Self.tempVideoPrefix_Sprig)\(Date().timeIntervalSince1970)"
        let tempURL_Sprig = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Sprig)
            .appendingPathExtension(sourceURL_Sprig.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Sprig(at: tempURL_Sprig)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Sprig, to: tempURL_Sprig)
            print("✅ 视频已复制到临时目录: \(tempURL_Sprig.path)")
            
            callCompletion_Sprig(.video_Sprig(url_Sprig: tempURL_Sprig))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Sprig(.cancelled_Sprig)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Sprig(at url_Sprig: URL) throws {
        if FileManager.default.fileExists(atPath: url_Sprig.path) {
            try FileManager.default.removeItem(at: url_Sprig)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Sprig: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Sprig = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Sprig(.cancelled_Sprig)
            return
        }
        
        let itemProvider_Sprig = result_Sprig.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Sprig.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Sprig(itemProvider_Sprig: itemProvider_Sprig)
        } else if itemProvider_Sprig.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Sprig(itemProvider_Sprig: itemProvider_Sprig)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Sprig(.cancelled_Sprig)
        }
    }
}
