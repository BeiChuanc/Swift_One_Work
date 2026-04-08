import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Somnia: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Somnia = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Somnia {
        case photo_Somnia           // 仅图片
        case video_Somnia           // 仅视频
        case photoAndVideo_Somnia   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Somnia {
        case photo_Somnia(image_Somnia: UIImage)      // 图片结果
        case video_Somnia(url_Somnia: URL)            // 视频结果
        case cancelled_Somnia                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Somnia = MediaPickerHelper_Somnia()
    
    /// 完成回调
    private var completion_Somnia: ((PickerResult_Somnia) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Somnia: MediaType_Somnia = .photo_Somnia
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Somnia(
        from viewController_Somnia: UIViewController,
        mediaType_Somnia: MediaType_Somnia = .photo_Somnia,
        selectionLimit_Somnia: Int = 1,
        completion_Somnia: @escaping (PickerResult_Somnia) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Somnia = completion_Somnia
        self.currentMediaType_Somnia = mediaType_Somnia
        
        // 配置 PHPicker
        var config_Somnia = PHPickerConfiguration()
        config_Somnia.selectionLimit = selectionLimit_Somnia
        
        // 根据媒体类型设置过滤器
        switch mediaType_Somnia {
        case .photo_Somnia:
            config_Somnia.filter = .images
        case .video_Somnia:
            config_Somnia.filter = .videos
        case .photoAndVideo_Somnia:
            config_Somnia.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Somnia = PHPickerViewController(configuration: config_Somnia)
        picker_Somnia.delegate = self
        
        viewController_Somnia.present(picker_Somnia, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Somnia(
        from viewController_Somnia: UIViewController,
        completion_Somnia: @escaping (UIImage?) -> Void
    ) {
        shared_Somnia.showPicker_Somnia(
            from: viewController_Somnia,
            mediaType_Somnia: .photo_Somnia
        ) { result_Somnia in
            if case .photo_Somnia(let image_Somnia) = result_Somnia {
                completion_Somnia(image_Somnia)
            } else {
                completion_Somnia(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Somnia(
        from viewController_Somnia: UIViewController,
        completion_Somnia: @escaping (URL?) -> Void
    ) {
        shared_Somnia.showPicker_Somnia(
            from: viewController_Somnia,
            mediaType_Somnia: .video_Somnia
        ) { result_Somnia in
            if case .video_Somnia(let url_Somnia) = result_Somnia {
                completion_Somnia(url_Somnia)
            } else {
                completion_Somnia(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Somnia(
        from viewController_Somnia: UIViewController,
        completion_Somnia: @escaping (PickerResult_Somnia) -> Void
    ) {
        shared_Somnia.showPicker_Somnia(
            from: viewController_Somnia,
            mediaType_Somnia: .photoAndVideo_Somnia,
            completion_Somnia: completion_Somnia
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Somnia(_ result_Somnia: PickerResult_Somnia) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Somnia?(result_Somnia)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Somnia(itemProvider_Somnia: NSItemProvider) {
        itemProvider_Somnia.loadObject(ofClass: UIImage.self) { [weak self] image_Somnia, error_Somnia in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Somnia = error_Somnia {
                print("❌ 加载图片失败: \(error_Somnia)")
                self.callCompletion_Somnia(.cancelled_Somnia)
                return
            }
            
            // 类型转换和回调
            if let image_Somnia = image_Somnia as? UIImage {
                self.callCompletion_Somnia(.photo_Somnia(image_Somnia: image_Somnia))
            } else {
                self.callCompletion_Somnia(.cancelled_Somnia)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Somnia(itemProvider_Somnia: NSItemProvider) {
        itemProvider_Somnia.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Somnia, error_Somnia in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Somnia = error_Somnia {
                print("❌ 加载视频失败: \(error_Somnia)")
                self.callCompletion_Somnia(.cancelled_Somnia)
                return
            }
            
            guard let url_Somnia = url_Somnia else {
                print("❌ 视频URL为空")
                self.callCompletion_Somnia(.cancelled_Somnia)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Somnia(sourceURL_Somnia: url_Somnia)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Somnia: 原始视频URL
    private func copyVideoToTemp_Somnia(sourceURL_Somnia: URL) {
        // 生成临时文件路径
        let fileName_Somnia = "\(Self.tempVideoPrefix_Somnia)\(Date().timeIntervalSince1970)"
        let tempURL_Somnia = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Somnia)
            .appendingPathExtension(sourceURL_Somnia.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Somnia(at: tempURL_Somnia)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Somnia, to: tempURL_Somnia)
            print("✅ 视频已复制到临时目录: \(tempURL_Somnia.path)")
            
            callCompletion_Somnia(.video_Somnia(url_Somnia: tempURL_Somnia))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Somnia(.cancelled_Somnia)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Somnia(at url_Somnia: URL) throws {
        if FileManager.default.fileExists(atPath: url_Somnia.path) {
            try FileManager.default.removeItem(at: url_Somnia)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Somnia: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Somnia = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Somnia(.cancelled_Somnia)
            return
        }
        
        let itemProvider_Somnia = result_Somnia.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Somnia.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Somnia(itemProvider_Somnia: itemProvider_Somnia)
        } else if itemProvider_Somnia.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Somnia(itemProvider_Somnia: itemProvider_Somnia)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Somnia(.cancelled_Somnia)
        }
    }
}
