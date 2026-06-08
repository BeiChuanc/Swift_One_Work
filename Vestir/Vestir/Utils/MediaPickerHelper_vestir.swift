import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Vestir: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Vestir = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Vestir {
        case photo_Vestir           // 仅图片
        case video_Vestir           // 仅视频
        case photoAndVideo_Vestir   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Vestir {
        case photo_Vestir(image_Vestir: UIImage)      // 图片结果
        case video_Vestir(url_Vestir: URL)            // 视频结果
        case cancelled_Vestir                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Vestir = MediaPickerHelper_Vestir()
    
    /// 完成回调
    private var completion_Vestir: ((PickerResult_Vestir) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Vestir: MediaType_Vestir = .photo_Vestir
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Vestir(
        from viewController_Vestir: UIViewController,
        mediaType_Vestir: MediaType_Vestir = .photo_Vestir,
        selectionLimit_Vestir: Int = 1,
        completion_Vestir: @escaping (PickerResult_Vestir) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Vestir = completion_Vestir
        self.currentMediaType_Vestir = mediaType_Vestir
        
        // 配置 PHPicker
        var config_Vestir = PHPickerConfiguration()
        config_Vestir.selectionLimit = selectionLimit_Vestir
        
        // 根据媒体类型设置过滤器
        switch mediaType_Vestir {
        case .photo_Vestir:
            config_Vestir.filter = .images
        case .video_Vestir:
            config_Vestir.filter = .videos
        case .photoAndVideo_Vestir:
            config_Vestir.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Vestir = PHPickerViewController(configuration: config_Vestir)
        picker_Vestir.delegate = self
        
        viewController_Vestir.present(picker_Vestir, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Vestir(
        from viewController_Vestir: UIViewController,
        completion_Vestir: @escaping (UIImage?) -> Void
    ) {
        shared_Vestir.showPicker_Vestir(
            from: viewController_Vestir,
            mediaType_Vestir: .photo_Vestir
        ) { result_Vestir in
            if case .photo_Vestir(let image_Vestir) = result_Vestir {
                completion_Vestir(image_Vestir)
            } else {
                completion_Vestir(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Vestir(
        from viewController_Vestir: UIViewController,
        completion_Vestir: @escaping (URL?) -> Void
    ) {
        shared_Vestir.showPicker_Vestir(
            from: viewController_Vestir,
            mediaType_Vestir: .video_Vestir
        ) { result_Vestir in
            if case .video_Vestir(let url_Vestir) = result_Vestir {
                completion_Vestir(url_Vestir)
            } else {
                completion_Vestir(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Vestir(
        from viewController_Vestir: UIViewController,
        completion_Vestir: @escaping (PickerResult_Vestir) -> Void
    ) {
        shared_Vestir.showPicker_Vestir(
            from: viewController_Vestir,
            mediaType_Vestir: .photoAndVideo_Vestir,
            completion_Vestir: completion_Vestir
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Vestir(_ result_Vestir: PickerResult_Vestir) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Vestir?(result_Vestir)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Vestir(itemProvider_Vestir: NSItemProvider) {
        itemProvider_Vestir.loadObject(ofClass: UIImage.self) { [weak self] image_Vestir, error_Vestir in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Vestir = error_Vestir {
                print("❌ 加载图片失败: \(error_Vestir)")
                self.callCompletion_Vestir(.cancelled_Vestir)
                return
            }
            
            // 类型转换和回调
            if let image_Vestir = image_Vestir as? UIImage {
                self.callCompletion_Vestir(.photo_Vestir(image_Vestir: image_Vestir))
            } else {
                self.callCompletion_Vestir(.cancelled_Vestir)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Vestir(itemProvider_Vestir: NSItemProvider) {
        itemProvider_Vestir.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Vestir, error_Vestir in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Vestir = error_Vestir {
                print("❌ 加载视频失败: \(error_Vestir)")
                self.callCompletion_Vestir(.cancelled_Vestir)
                return
            }
            
            guard let url_Vestir = url_Vestir else {
                print("❌ 视频URL为空")
                self.callCompletion_Vestir(.cancelled_Vestir)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Vestir(sourceURL_Vestir: url_Vestir)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Vestir: 原始视频URL
    private func copyVideoToTemp_Vestir(sourceURL_Vestir: URL) {
        // 生成临时文件路径
        let fileName_Vestir = "\(Self.tempVideoPrefix_Vestir)\(Date().timeIntervalSince1970)"
        let tempURL_Vestir = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Vestir)
            .appendingPathExtension(sourceURL_Vestir.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Vestir(at: tempURL_Vestir)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Vestir, to: tempURL_Vestir)
            print("✅ 视频已复制到临时目录: \(tempURL_Vestir.path)")
            
            callCompletion_Vestir(.video_Vestir(url_Vestir: tempURL_Vestir))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Vestir(.cancelled_Vestir)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Vestir(at url_Vestir: URL) throws {
        if FileManager.default.fileExists(atPath: url_Vestir.path) {
            try FileManager.default.removeItem(at: url_Vestir)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Vestir: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Vestir = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Vestir(.cancelled_Vestir)
            return
        }
        
        let itemProvider_Vestir = result_Vestir.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Vestir.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Vestir(itemProvider_Vestir: itemProvider_Vestir)
        } else if itemProvider_Vestir.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Vestir(itemProvider_Vestir: itemProvider_Vestir)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Vestir(.cancelled_Vestir)
        }
    }
}
