import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Bague: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Bague = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Bague {
        case photo_Bague           // 仅图片
        case video_Bague           // 仅视频
        case photoAndVideo_Bague   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Bague {
        case photo_Bague(image_Bague: UIImage)      // 图片结果
        case video_Bague(url_Bague: URL)            // 视频结果
        case cancelled_Bague                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Bague = MediaPickerHelper_Bague()
    
    /// 完成回调
    private var completion_Bague: ((PickerResult_Bague) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Bague: MediaType_Bague = .photo_Bague
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Bague(
        from viewController_Bague: UIViewController,
        mediaType_Bague: MediaType_Bague = .photo_Bague,
        selectionLimit_Bague: Int = 1,
        completion_Bague: @escaping (PickerResult_Bague) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Bague = completion_Bague
        self.currentMediaType_Bague = mediaType_Bague
        
        // 配置 PHPicker
        var config_Bague = PHPickerConfiguration()
        config_Bague.selectionLimit = selectionLimit_Bague
        
        // 根据媒体类型设置过滤器
        switch mediaType_Bague {
        case .photo_Bague:
            config_Bague.filter = .images
        case .video_Bague:
            config_Bague.filter = .videos
        case .photoAndVideo_Bague:
            config_Bague.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Bague = PHPickerViewController(configuration: config_Bague)
        picker_Bague.delegate = self
        
        viewController_Bague.present(picker_Bague, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Bague(
        from viewController_Bague: UIViewController,
        completion_Bague: @escaping (UIImage?) -> Void
    ) {
        shared_Bague.showPicker_Bague(
            from: viewController_Bague,
            mediaType_Bague: .photo_Bague
        ) { result_Bague in
            if case .photo_Bague(let image_Bague) = result_Bague {
                completion_Bague(image_Bague)
            } else {
                completion_Bague(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Bague(
        from viewController_Bague: UIViewController,
        completion_Bague: @escaping (URL?) -> Void
    ) {
        shared_Bague.showPicker_Bague(
            from: viewController_Bague,
            mediaType_Bague: .video_Bague
        ) { result_Bague in
            if case .video_Bague(let url_Bague) = result_Bague {
                completion_Bague(url_Bague)
            } else {
                completion_Bague(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Bague(
        from viewController_Bague: UIViewController,
        completion_Bague: @escaping (PickerResult_Bague) -> Void
    ) {
        shared_Bague.showPicker_Bague(
            from: viewController_Bague,
            mediaType_Bague: .photoAndVideo_Bague,
            completion_Bague: completion_Bague
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Bague(_ result_Bague: PickerResult_Bague) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Bague?(result_Bague)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Bague(itemProvider_Bague: NSItemProvider) {
        itemProvider_Bague.loadObject(ofClass: UIImage.self) { [weak self] image_Bague, error_Bague in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Bague = error_Bague {
                print("❌ 加载图片失败: \(error_Bague)")
                self.callCompletion_Bague(.cancelled_Bague)
                return
            }
            
            // 类型转换和回调
            if let image_Bague = image_Bague as? UIImage {
                self.callCompletion_Bague(.photo_Bague(image_Bague: image_Bague))
            } else {
                self.callCompletion_Bague(.cancelled_Bague)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Bague(itemProvider_Bague: NSItemProvider) {
        itemProvider_Bague.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Bague, error_Bague in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Bague = error_Bague {
                print("❌ 加载视频失败: \(error_Bague)")
                self.callCompletion_Bague(.cancelled_Bague)
                return
            }
            
            guard let url_Bague = url_Bague else {
                print("❌ 视频URL为空")
                self.callCompletion_Bague(.cancelled_Bague)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Bague(sourceURL_Bague: url_Bague)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Bague: 原始视频URL
    private func copyVideoToTemp_Bague(sourceURL_Bague: URL) {
        // 生成临时文件路径
        let fileName_Bague = "\(Self.tempVideoPrefix_Bague)\(Date().timeIntervalSince1970)"
        let tempURL_Bague = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Bague)
            .appendingPathExtension(sourceURL_Bague.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Bague(at: tempURL_Bague)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Bague, to: tempURL_Bague)
            print("✅ 视频已复制到临时目录: \(tempURL_Bague.path)")
            
            callCompletion_Bague(.video_Bague(url_Bague: tempURL_Bague))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Bague(.cancelled_Bague)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Bague(at url_Bague: URL) throws {
        if FileManager.default.fileExists(atPath: url_Bague.path) {
            try FileManager.default.removeItem(at: url_Bague)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Bague: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Bague = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Bague(.cancelled_Bague)
            return
        }
        
        let itemProvider_Bague = result_Bague.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Bague.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Bague(itemProvider_Bague: itemProvider_Bague)
        } else if itemProvider_Bague.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Bague(itemProvider_Bague: itemProvider_Bague)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Bague(.cancelled_Bague)
        }
    }
}
