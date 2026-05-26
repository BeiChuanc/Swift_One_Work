import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Niche: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Niche = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Niche {
        case photo_Niche           // 仅图片
        case video_Niche           // 仅视频
        case photoAndVideo_Niche   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Niche {
        case photo_Niche(image_Niche: UIImage)      // 图片结果
        case video_Niche(url_Niche: URL)            // 视频结果
        case cancelled_Niche                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Niche = MediaPickerHelper_Niche()
    
    /// 完成回调
    private var completion_Niche: ((PickerResult_Niche) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Niche: MediaType_Niche = .photo_Niche
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Niche(
        from viewController_Niche: UIViewController,
        mediaType_Niche: MediaType_Niche = .photo_Niche,
        selectionLimit_Niche: Int = 1,
        completion_Niche: @escaping (PickerResult_Niche) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Niche = completion_Niche
        self.currentMediaType_Niche = mediaType_Niche
        
        // 配置 PHPicker
        var config_Niche = PHPickerConfiguration()
        config_Niche.selectionLimit = selectionLimit_Niche
        
        // 根据媒体类型设置过滤器
        switch mediaType_Niche {
        case .photo_Niche:
            config_Niche.filter = .images
        case .video_Niche:
            config_Niche.filter = .videos
        case .photoAndVideo_Niche:
            config_Niche.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Niche = PHPickerViewController(configuration: config_Niche)
        picker_Niche.delegate = self
        
        viewController_Niche.present(picker_Niche, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Niche(
        from viewController_Niche: UIViewController,
        completion_Niche: @escaping (UIImage?) -> Void
    ) {
        shared_Niche.showPicker_Niche(
            from: viewController_Niche,
            mediaType_Niche: .photo_Niche
        ) { result_Niche in
            if case .photo_Niche(let image_Niche) = result_Niche {
                completion_Niche(image_Niche)
            } else {
                completion_Niche(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Niche(
        from viewController_Niche: UIViewController,
        completion_Niche: @escaping (URL?) -> Void
    ) {
        shared_Niche.showPicker_Niche(
            from: viewController_Niche,
            mediaType_Niche: .video_Niche
        ) { result_Niche in
            if case .video_Niche(let url_Niche) = result_Niche {
                completion_Niche(url_Niche)
            } else {
                completion_Niche(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Niche(
        from viewController_Niche: UIViewController,
        completion_Niche: @escaping (PickerResult_Niche) -> Void
    ) {
        shared_Niche.showPicker_Niche(
            from: viewController_Niche,
            mediaType_Niche: .photoAndVideo_Niche,
            completion_Niche: completion_Niche
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Niche(_ result_Niche: PickerResult_Niche) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Niche?(result_Niche)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Niche(itemProvider_Niche: NSItemProvider) {
        itemProvider_Niche.loadObject(ofClass: UIImage.self) { [weak self] image_Niche, error_Niche in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Niche = error_Niche {
                print("❌ 加载图片失败: \(error_Niche)")
                self.callCompletion_Niche(.cancelled_Niche)
                return
            }
            
            // 类型转换和回调
            if let image_Niche = image_Niche as? UIImage {
                self.callCompletion_Niche(.photo_Niche(image_Niche: image_Niche))
            } else {
                self.callCompletion_Niche(.cancelled_Niche)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Niche(itemProvider_Niche: NSItemProvider) {
        itemProvider_Niche.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Niche, error_Niche in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Niche = error_Niche {
                print("❌ 加载视频失败: \(error_Niche)")
                self.callCompletion_Niche(.cancelled_Niche)
                return
            }
            
            guard let url_Niche = url_Niche else {
                print("❌ 视频URL为空")
                self.callCompletion_Niche(.cancelled_Niche)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Niche(sourceURL_Niche: url_Niche)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Niche: 原始视频URL
    private func copyVideoToTemp_Niche(sourceURL_Niche: URL) {
        // 生成临时文件路径
        let fileName_Niche = "\(Self.tempVideoPrefix_Niche)\(Date().timeIntervalSince1970)"
        let tempURL_Niche = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Niche)
            .appendingPathExtension(sourceURL_Niche.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Niche(at: tempURL_Niche)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Niche, to: tempURL_Niche)
            print("✅ 视频已复制到临时目录: \(tempURL_Niche.path)")
            
            callCompletion_Niche(.video_Niche(url_Niche: tempURL_Niche))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Niche(.cancelled_Niche)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Niche(at url_Niche: URL) throws {
        if FileManager.default.fileExists(atPath: url_Niche.path) {
            try FileManager.default.removeItem(at: url_Niche)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Niche: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Niche = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Niche(.cancelled_Niche)
            return
        }
        
        let itemProvider_Niche = result_Niche.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Niche.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Niche(itemProvider_Niche: itemProvider_Niche)
        } else if itemProvider_Niche.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Niche(itemProvider_Niche: itemProvider_Niche)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Niche(.cancelled_Niche)
        }
    }
}
