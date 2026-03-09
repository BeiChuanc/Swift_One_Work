import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Moode: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Moode = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Moode {
        case photo_Moode           // 仅图片
        case video_Moode           // 仅视频
        case photoAndVideo_Moode   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Moode {
        case photo_Moode(image_Moode: UIImage)      // 图片结果
        case video_Moode(url_Moode: URL)            // 视频结果
        case cancelled_Moode                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Moode = MediaPickerHelper_Moode()
    
    /// 完成回调
    private var completion_Moode: ((PickerResult_Moode) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Moode: MediaType_Moode = .photo_Moode
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Moode(
        from viewController_Moode: UIViewController,
        mediaType_Moode: MediaType_Moode = .photo_Moode,
        selectionLimit_Moode: Int = 1,
        completion_Moode: @escaping (PickerResult_Moode) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Moode = completion_Moode
        self.currentMediaType_Moode = mediaType_Moode
        
        // 配置 PHPicker
        var config_Moode = PHPickerConfiguration()
        config_Moode.selectionLimit = selectionLimit_Moode
        
        // 根据媒体类型设置过滤器
        switch mediaType_Moode {
        case .photo_Moode:
            config_Moode.filter = .images
        case .video_Moode:
            config_Moode.filter = .videos
        case .photoAndVideo_Moode:
            config_Moode.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Moode = PHPickerViewController(configuration: config_Moode)
        picker_Moode.delegate = self
        
        viewController_Moode.present(picker_Moode, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Moode(
        from viewController_Moode: UIViewController,
        completion_Moode: @escaping (UIImage?) -> Void
    ) {
        shared_Moode.showPicker_Moode(
            from: viewController_Moode,
            mediaType_Moode: .photo_Moode
        ) { result_Moode in
            if case .photo_Moode(let image_Moode) = result_Moode {
                completion_Moode(image_Moode)
            } else {
                completion_Moode(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Moode(
        from viewController_Moode: UIViewController,
        completion_Moode: @escaping (URL?) -> Void
    ) {
        shared_Moode.showPicker_Moode(
            from: viewController_Moode,
            mediaType_Moode: .video_Moode
        ) { result_Moode in
            if case .video_Moode(let url_Moode) = result_Moode {
                completion_Moode(url_Moode)
            } else {
                completion_Moode(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Moode(
        from viewController_Moode: UIViewController,
        completion_Moode: @escaping (PickerResult_Moode) -> Void
    ) {
        shared_Moode.showPicker_Moode(
            from: viewController_Moode,
            mediaType_Moode: .photoAndVideo_Moode,
            completion_Moode: completion_Moode
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Moode(_ result_Moode: PickerResult_Moode) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Moode?(result_Moode)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Moode(itemProvider_Moode: NSItemProvider) {
        itemProvider_Moode.loadObject(ofClass: UIImage.self) { [weak self] image_Moode, error_Moode in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Moode = error_Moode {
                print("❌ 加载图片失败: \(error_Moode)")
                self.callCompletion_Moode(.cancelled_Moode)
                return
            }
            
            // 类型转换和回调
            if let image_Moode = image_Moode as? UIImage {
                self.callCompletion_Moode(.photo_Moode(image_Moode: image_Moode))
            } else {
                self.callCompletion_Moode(.cancelled_Moode)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Moode(itemProvider_Moode: NSItemProvider) {
        itemProvider_Moode.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Moode, error_Moode in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Moode = error_Moode {
                print("❌ 加载视频失败: \(error_Moode)")
                self.callCompletion_Moode(.cancelled_Moode)
                return
            }
            
            guard let url_Moode = url_Moode else {
                print("❌ 视频URL为空")
                self.callCompletion_Moode(.cancelled_Moode)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Moode(sourceURL_Moode: url_Moode)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Moode: 原始视频URL
    private func copyVideoToTemp_Moode(sourceURL_Moode: URL) {
        // 生成临时文件路径
        let fileName_Moode = "\(Self.tempVideoPrefix_Moode)\(Date().timeIntervalSince1970)"
        let tempURL_Moode = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Moode)
            .appendingPathExtension(sourceURL_Moode.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Moode(at: tempURL_Moode)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Moode, to: tempURL_Moode)
            print("✅ 视频已复制到临时目录: \(tempURL_Moode.path)")
            
            callCompletion_Moode(.video_Moode(url_Moode: tempURL_Moode))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Moode(.cancelled_Moode)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Moode(at url_Moode: URL) throws {
        if FileManager.default.fileExists(atPath: url_Moode.path) {
            try FileManager.default.removeItem(at: url_Moode)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Moode: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Moode = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Moode(.cancelled_Moode)
            return
        }
        
        let itemProvider_Moode = result_Moode.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Moode.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Moode(itemProvider_Moode: itemProvider_Moode)
        } else if itemProvider_Moode.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Moode(itemProvider_Moode: itemProvider_Moode)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Moode(.cancelled_Moode)
        }
    }
}
