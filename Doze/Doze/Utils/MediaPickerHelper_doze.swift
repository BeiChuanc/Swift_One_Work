import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Doze: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Doze = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Doze {
        case photo_Doze           // 仅图片
        case video_Doze           // 仅视频
        case photoAndVideo_Doze   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Doze {
        case photo_Doze(image_Doze: UIImage)      // 图片结果
        case video_Doze(url_Doze: URL)            // 视频结果
        case cancelled_Doze                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Doze = MediaPickerHelper_Doze()
    
    /// 完成回调
    private var completion_Doze: ((PickerResult_Doze) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Doze: MediaType_Doze = .photo_Doze
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Doze(
        from viewController_Doze: UIViewController,
        mediaType_Doze: MediaType_Doze = .photo_Doze,
        selectionLimit_Doze: Int = 1,
        completion_Doze: @escaping (PickerResult_Doze) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Doze = completion_Doze
        self.currentMediaType_Doze = mediaType_Doze
        
        // 配置 PHPicker
        var config_Doze = PHPickerConfiguration()
        config_Doze.selectionLimit = selectionLimit_Doze
        
        // 根据媒体类型设置过滤器
        switch mediaType_Doze {
        case .photo_Doze:
            config_Doze.filter = .images
        case .video_Doze:
            config_Doze.filter = .videos
        case .photoAndVideo_Doze:
            config_Doze.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Doze = PHPickerViewController(configuration: config_Doze)
        picker_Doze.delegate = self
        
        viewController_Doze.present(picker_Doze, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Doze(
        from viewController_Doze: UIViewController,
        completion_Doze: @escaping (UIImage?) -> Void
    ) {
        shared_Doze.showPicker_Doze(
            from: viewController_Doze,
            mediaType_Doze: .photo_Doze
        ) { result_Doze in
            if case .photo_Doze(let image_Doze) = result_Doze {
                completion_Doze(image_Doze)
            } else {
                completion_Doze(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Doze(
        from viewController_Doze: UIViewController,
        completion_Doze: @escaping (URL?) -> Void
    ) {
        shared_Doze.showPicker_Doze(
            from: viewController_Doze,
            mediaType_Doze: .video_Doze
        ) { result_Doze in
            if case .video_Doze(let url_Doze) = result_Doze {
                completion_Doze(url_Doze)
            } else {
                completion_Doze(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Doze(
        from viewController_Doze: UIViewController,
        completion_Doze: @escaping (PickerResult_Doze) -> Void
    ) {
        shared_Doze.showPicker_Doze(
            from: viewController_Doze,
            mediaType_Doze: .photoAndVideo_Doze,
            completion_Doze: completion_Doze
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Doze(_ result_Doze: PickerResult_Doze) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Doze?(result_Doze)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Doze(itemProvider_Doze: NSItemProvider) {
        itemProvider_Doze.loadObject(ofClass: UIImage.self) { [weak self] image_Doze, error_Doze in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Doze = error_Doze {
                print("❌ 加载图片失败: \(error_Doze)")
                self.callCompletion_Doze(.cancelled_Doze)
                return
            }
            
            // 类型转换和回调
            if let image_Doze = image_Doze as? UIImage {
                self.callCompletion_Doze(.photo_Doze(image_Doze: image_Doze))
            } else {
                self.callCompletion_Doze(.cancelled_Doze)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Doze(itemProvider_Doze: NSItemProvider) {
        itemProvider_Doze.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Doze, error_Doze in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Doze = error_Doze {
                print("❌ 加载视频失败: \(error_Doze)")
                self.callCompletion_Doze(.cancelled_Doze)
                return
            }
            
            guard let url_Doze = url_Doze else {
                print("❌ 视频URL为空")
                self.callCompletion_Doze(.cancelled_Doze)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Doze(sourceURL_Doze: url_Doze)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Doze: 原始视频URL
    private func copyVideoToTemp_Doze(sourceURL_Doze: URL) {
        // 生成临时文件路径
        let fileName_Doze = "\(Self.tempVideoPrefix_Doze)\(Date().timeIntervalSince1970)"
        let tempURL_Doze = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Doze)
            .appendingPathExtension(sourceURL_Doze.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Doze(at: tempURL_Doze)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Doze, to: tempURL_Doze)
            print("✅ 视频已复制到临时目录: \(tempURL_Doze.path)")
            
            callCompletion_Doze(.video_Doze(url_Doze: tempURL_Doze))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Doze(.cancelled_Doze)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Doze(at url_Doze: URL) throws {
        if FileManager.default.fileExists(atPath: url_Doze.path) {
            try FileManager.default.removeItem(at: url_Doze)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Doze: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Doze = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Doze(.cancelled_Doze)
            return
        }
        
        let itemProvider_Doze = result_Doze.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Doze.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Doze(itemProvider_Doze: itemProvider_Doze)
        } else if itemProvider_Doze.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Doze(itemProvider_Doze: itemProvider_Doze)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Doze(.cancelled_Doze)
        }
    }
}
