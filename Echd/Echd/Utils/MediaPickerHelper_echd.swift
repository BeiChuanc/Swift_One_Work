import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Echd: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Echd = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Echd {
        case photo_Echd           // 仅图片
        case video_Echd           // 仅视频
        case photoAndVideo_Echd   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Echd {
        case photo_Echd(image_Echd: UIImage)      // 图片结果
        case video_Echd(url_Echd: URL)            // 视频结果
        case cancelled_Echd                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Echd = MediaPickerHelper_Echd()
    
    /// 完成回调
    private var completion_Echd: ((PickerResult_Echd) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Echd: MediaType_Echd = .photo_Echd
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Echd(
        from viewController_Echd: UIViewController,
        mediaType_Echd: MediaType_Echd = .photo_Echd,
        selectionLimit_Echd: Int = 1,
        completion_Echd: @escaping (PickerResult_Echd) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Echd = completion_Echd
        self.currentMediaType_Echd = mediaType_Echd
        
        // 配置 PHPicker
        var config_Echd = PHPickerConfiguration()
        config_Echd.selectionLimit = selectionLimit_Echd
        
        // 根据媒体类型设置过滤器
        switch mediaType_Echd {
        case .photo_Echd:
            config_Echd.filter = .images
        case .video_Echd:
            config_Echd.filter = .videos
        case .photoAndVideo_Echd:
            config_Echd.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Echd = PHPickerViewController(configuration: config_Echd)
        picker_Echd.delegate = self
        
        viewController_Echd.present(picker_Echd, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Echd(
        from viewController_Echd: UIViewController,
        completion_Echd: @escaping (UIImage?) -> Void
    ) {
        shared_Echd.showPicker_Echd(
            from: viewController_Echd,
            mediaType_Echd: .photo_Echd
        ) { result_Echd in
            if case .photo_Echd(let image_Echd) = result_Echd {
                completion_Echd(image_Echd)
            } else {
                completion_Echd(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Echd(
        from viewController_Echd: UIViewController,
        completion_Echd: @escaping (URL?) -> Void
    ) {
        shared_Echd.showPicker_Echd(
            from: viewController_Echd,
            mediaType_Echd: .video_Echd
        ) { result_Echd in
            if case .video_Echd(let url_Echd) = result_Echd {
                completion_Echd(url_Echd)
            } else {
                completion_Echd(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Echd(
        from viewController_Echd: UIViewController,
        completion_Echd: @escaping (PickerResult_Echd) -> Void
    ) {
        shared_Echd.showPicker_Echd(
            from: viewController_Echd,
            mediaType_Echd: .photoAndVideo_Echd,
            completion_Echd: completion_Echd
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Echd(_ result_Echd: PickerResult_Echd) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Echd?(result_Echd)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Echd(itemProvider_Echd: NSItemProvider) {
        itemProvider_Echd.loadObject(ofClass: UIImage.self) { [weak self] image_Echd, error_Echd in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Echd = error_Echd {
                print("❌ 加载图片失败: \(error_Echd)")
                self.callCompletion_Echd(.cancelled_Echd)
                return
            }
            
            // 类型转换和回调
            if let image_Echd = image_Echd as? UIImage {
                self.callCompletion_Echd(.photo_Echd(image_Echd: image_Echd))
            } else {
                self.callCompletion_Echd(.cancelled_Echd)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Echd(itemProvider_Echd: NSItemProvider) {
        itemProvider_Echd.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Echd, error_Echd in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Echd = error_Echd {
                print("❌ 加载视频失败: \(error_Echd)")
                self.callCompletion_Echd(.cancelled_Echd)
                return
            }
            
            guard let url_Echd = url_Echd else {
                print("❌ 视频URL为空")
                self.callCompletion_Echd(.cancelled_Echd)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Echd(sourceURL_Echd: url_Echd)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Echd: 原始视频URL
    private func copyVideoToTemp_Echd(sourceURL_Echd: URL) {
        // 生成临时文件路径
        let fileName_Echd = "\(Self.tempVideoPrefix_Echd)\(Date().timeIntervalSince1970)"
        let tempURL_Echd = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Echd)
            .appendingPathExtension(sourceURL_Echd.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Echd(at: tempURL_Echd)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Echd, to: tempURL_Echd)
            print("✅ 视频已复制到临时目录: \(tempURL_Echd.path)")
            
            callCompletion_Echd(.video_Echd(url_Echd: tempURL_Echd))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Echd(.cancelled_Echd)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Echd(at url_Echd: URL) throws {
        if FileManager.default.fileExists(atPath: url_Echd.path) {
            try FileManager.default.removeItem(at: url_Echd)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Echd: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Echd = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Echd(.cancelled_Echd)
            return
        }
        
        let itemProvider_Echd = result_Echd.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Echd.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Echd(itemProvider_Echd: itemProvider_Echd)
        } else if itemProvider_Echd.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Echd(itemProvider_Echd: itemProvider_Echd)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Echd(.cancelled_Echd)
        }
    }
}
