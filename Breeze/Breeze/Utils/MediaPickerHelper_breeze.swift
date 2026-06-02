import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Breeze: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Breeze = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Breeze {
        case photo_Breeze           // 仅图片
        case video_Breeze           // 仅视频
        case photoAndVideo_Breeze   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Breeze {
        case photo_Breeze(image_Breeze: UIImage)      // 图片结果
        case video_Breeze(url_Breeze: URL)            // 视频结果
        case cancelled_Breeze                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Breeze = MediaPickerHelper_Breeze()
    
    /// 完成回调
    private var completion_Breeze: ((PickerResult_Breeze) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Breeze: MediaType_Breeze = .photo_Breeze
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Breeze(
        from viewController_Breeze: UIViewController,
        mediaType_Breeze: MediaType_Breeze = .photo_Breeze,
        selectionLimit_Breeze: Int = 1,
        completion_Breeze: @escaping (PickerResult_Breeze) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Breeze = completion_Breeze
        self.currentMediaType_Breeze = mediaType_Breeze
        
        // 配置 PHPicker
        var config_Breeze = PHPickerConfiguration()
        config_Breeze.selectionLimit = selectionLimit_Breeze
        
        // 根据媒体类型设置过滤器
        switch mediaType_Breeze {
        case .photo_Breeze:
            config_Breeze.filter = .images
        case .video_Breeze:
            config_Breeze.filter = .videos
        case .photoAndVideo_Breeze:
            config_Breeze.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Breeze = PHPickerViewController(configuration: config_Breeze)
        picker_Breeze.delegate = self
        
        viewController_Breeze.present(picker_Breeze, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Breeze(
        from viewController_Breeze: UIViewController,
        completion_Breeze: @escaping (UIImage?) -> Void
    ) {
        shared_Breeze.showPicker_Breeze(
            from: viewController_Breeze,
            mediaType_Breeze: .photo_Breeze
        ) { result_Breeze in
            if case .photo_Breeze(let image_Breeze) = result_Breeze {
                completion_Breeze(image_Breeze)
            } else {
                completion_Breeze(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Breeze(
        from viewController_Breeze: UIViewController,
        completion_Breeze: @escaping (URL?) -> Void
    ) {
        shared_Breeze.showPicker_Breeze(
            from: viewController_Breeze,
            mediaType_Breeze: .video_Breeze
        ) { result_Breeze in
            if case .video_Breeze(let url_Breeze) = result_Breeze {
                completion_Breeze(url_Breeze)
            } else {
                completion_Breeze(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Breeze(
        from viewController_Breeze: UIViewController,
        completion_Breeze: @escaping (PickerResult_Breeze) -> Void
    ) {
        shared_Breeze.showPicker_Breeze(
            from: viewController_Breeze,
            mediaType_Breeze: .photoAndVideo_Breeze,
            completion_Breeze: completion_Breeze
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Breeze(_ result_Breeze: PickerResult_Breeze) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Breeze?(result_Breeze)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Breeze(itemProvider_Breeze: NSItemProvider) {
        itemProvider_Breeze.loadObject(ofClass: UIImage.self) { [weak self] image_Breeze, error_Breeze in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Breeze = error_Breeze {
                print("❌ 加载图片失败: \(error_Breeze)")
                self.callCompletion_Breeze(.cancelled_Breeze)
                return
            }
            
            // 类型转换和回调
            if let image_Breeze = image_Breeze as? UIImage {
                self.callCompletion_Breeze(.photo_Breeze(image_Breeze: image_Breeze))
            } else {
                self.callCompletion_Breeze(.cancelled_Breeze)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Breeze(itemProvider_Breeze: NSItemProvider) {
        itemProvider_Breeze.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Breeze, error_Breeze in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Breeze = error_Breeze {
                print("❌ 加载视频失败: \(error_Breeze)")
                self.callCompletion_Breeze(.cancelled_Breeze)
                return
            }
            
            guard let url_Breeze = url_Breeze else {
                print("❌ 视频URL为空")
                self.callCompletion_Breeze(.cancelled_Breeze)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Breeze(sourceURL_Breeze: url_Breeze)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Breeze: 原始视频URL
    private func copyVideoToTemp_Breeze(sourceURL_Breeze: URL) {
        // 生成临时文件路径
        let fileName_Breeze = "\(Self.tempVideoPrefix_Breeze)\(Date().timeIntervalSince1970)"
        let tempURL_Breeze = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Breeze)
            .appendingPathExtension(sourceURL_Breeze.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Breeze(at: tempURL_Breeze)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Breeze, to: tempURL_Breeze)
            print("✅ 视频已复制到临时目录: \(tempURL_Breeze.path)")
            
            callCompletion_Breeze(.video_Breeze(url_Breeze: tempURL_Breeze))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Breeze(.cancelled_Breeze)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Breeze(at url_Breeze: URL) throws {
        if FileManager.default.fileExists(atPath: url_Breeze.path) {
            try FileManager.default.removeItem(at: url_Breeze)
        }
    }
    
    // MARK: - 持久化助手（供发布等场景复用）
    
    /// 将选取的图片保存到文档目录
    /// - Parameter image_breeze: 待保存的图片
    /// - Returns: 保存成功后的文件名（供 MediaDisplayView 加载），失败返回 nil
    static func saveImageToDocuments_Breeze(image_breeze: UIImage) -> String? {
        guard let data_breeze = image_breeze.jpegData(compressionQuality: 0.9) else {
            print("❌ 图片转换数据失败")
            return nil
        }
        let fileName_breeze = "breeze_img_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
        let fileURL_breeze = documentsURL_Breeze().appendingPathComponent(fileName_breeze)
        do {
            try data_breeze.write(to: fileURL_breeze)
            print("✅ 图片已保存到文档目录: \(fileName_breeze)")
            return fileName_breeze
        } catch {
            print("❌ 保存图片失败: \(error)")
            return nil
        }
    }
    
    /// 将选取的视频拷贝到文档目录（去扩展名，便于 MediaDisplayView 自动探测）
    /// - Parameter sourceURL_breeze: 视频源地址（通常为临时目录）
    /// - Returns: 保存成功后的文件名（不含扩展名），失败返回 nil
    static func saveVideoToDocuments_Breeze(sourceURL_breeze: URL) -> String? {
        let ext_breeze = sourceURL_breeze.pathExtension.isEmpty ? "mp4" : sourceURL_breeze.pathExtension
        let baseName_breeze = "breeze_video_\(Int(Date().timeIntervalSince1970 * 1000))"
        let fileName_breeze = "\(baseName_breeze).\(ext_breeze)"
        let destURL_breeze = documentsURL_Breeze().appendingPathComponent(fileName_breeze)
        do {
            if FileManager.default.fileExists(atPath: destURL_breeze.path) {
                try FileManager.default.removeItem(at: destURL_breeze)
            }
            try FileManager.default.copyItem(at: sourceURL_breeze, to: destURL_breeze)
            print("✅ 视频已保存到文档目录: \(fileName_breeze)")
            // 返回不含扩展名的名称，MediaDisplayView 会自动补全扩展名探测视频
            return baseName_breeze
        } catch {
            print("❌ 保存视频失败: \(error)")
            return nil
        }
    }
    
    /// 获取文档目录 URL
    private static func documentsURL_Breeze() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Breeze: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Breeze = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Breeze(.cancelled_Breeze)
            return
        }
        
        let itemProvider_Breeze = result_Breeze.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Breeze.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Breeze(itemProvider_Breeze: itemProvider_Breeze)
        } else if itemProvider_Breeze.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Breeze(itemProvider_Breeze: itemProvider_Breeze)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Breeze(.cancelled_Breeze)
        }
    }
}
