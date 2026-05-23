import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
class MediaPickerHelper_Hush: NSObject {
    
    // MARK: - 常量
    
    /// 临时视频文件前缀
    private static let tempVideoPrefix_Hush = "picked_video_"
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    enum MediaType_Hush {
        case photo_Hush           // 仅图片
        case video_Hush           // 仅视频
        case photoAndVideo_Hush   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Hush {
        case photo_Hush(image_Hush: UIImage)      // 图片结果
        case video_Hush(url_Hush: URL)            // 视频结果
        case cancelled_Hush                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Hush = MediaPickerHelper_Hush()
    
    /// 完成回调
    private var completion_Hush: ((PickerResult_Hush) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Hush: MediaType_Hush = .photo_Hush
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    func showPicker_Hush(
        from viewController_Hush: UIViewController,
        mediaType_Hush: MediaType_Hush = .photo_Hush,
        selectionLimit_Hush: Int = 1,
        completion_Hush: @escaping (PickerResult_Hush) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Hush = completion_Hush
        self.currentMediaType_Hush = mediaType_Hush
        
        // 配置 PHPicker
        var config_Hush = PHPickerConfiguration()
        config_Hush.selectionLimit = selectionLimit_Hush
        
        // 根据媒体类型设置过滤器
        switch mediaType_Hush {
        case .photo_Hush:
            config_Hush.filter = .images
        case .video_Hush:
            config_Hush.filter = .videos
        case .photoAndVideo_Hush:
            config_Hush.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_Hush = PHPickerViewController(configuration: config_Hush)
        picker_Hush.delegate = self
        
        viewController_Hush.present(picker_Hush, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    static func pickImage_Hush(
        from viewController_Hush: UIViewController,
        completion_Hush: @escaping (UIImage?) -> Void
    ) {
        shared_Hush.showPicker_Hush(
            from: viewController_Hush,
            mediaType_Hush: .photo_Hush
        ) { result_Hush in
            if case .photo_Hush(let image_Hush) = result_Hush {
                completion_Hush(image_Hush)
            } else {
                completion_Hush(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    static func pickVideo_Hush(
        from viewController_Hush: UIViewController,
        completion_Hush: @escaping (URL?) -> Void
    ) {
        shared_Hush.showPicker_Hush(
            from: viewController_Hush,
            mediaType_Hush: .video_Hush
        ) { result_Hush in
            if case .video_Hush(let url_Hush) = result_Hush {
                completion_Hush(url_Hush)
            } else {
                completion_Hush(nil)
            }
        }
    }
    
    /// 调起系统相机进行拍摄（仅支持真机，模拟器会触发提示）
    /// 功能：检查相机可用性后展示 UIImagePickerController，拍摄完成通过回调返回图片
    /// - Parameters:
    ///   - viewController_Hush: 发起调用的视图控制器
    ///   - completion_Hush: 拍摄结果回调（取消时返回 .cancelled_Hush，成功返回 .photo_Hush）
    static func launchCamera_Hush(
        from viewController_Hush: UIViewController,
        completion_Hush: @escaping (PickerResult_Hush) -> Void
    ) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            // 模拟器或设备无相机时，降级为相册选图
            print("⚠️ 相机不可用，降级为相册选图")
            pickImage_Hush(from: viewController_Hush, completion_Hush: { image_Hush in
                if let image_Hush = image_Hush {
                    completion_Hush(.photo_Hush(image_Hush: image_Hush))
                } else {
                    completion_Hush(.cancelled_Hush)
                }
            })
            return
        }
        
        shared_Hush.completion_Hush = completion_Hush
        
        let picker_Hush = UIImagePickerController()
        picker_Hush.sourceType = .camera
        picker_Hush.cameraCaptureMode = .photo
        picker_Hush.allowsEditing = false
        picker_Hush.delegate = shared_Hush
        
        viewController_Hush.present(picker_Hush, animated: true)
    }
    
    /// 快捷方法：选择图片或视频
    static func pickMedia_Hush(
        from viewController_Hush: UIViewController,
        completion_Hush: @escaping (PickerResult_Hush) -> Void
    ) {
        shared_Hush.showPicker_Hush(
            from: viewController_Hush,
            mediaType_Hush: .photoAndVideo_Hush,
            completion_Hush: completion_Hush
        )
    }
    
    // MARK: - 私有方法
    
    /// 在主线程回调结果
    private func callCompletion_Hush(_ result_Hush: PickerResult_Hush) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Hush?(result_Hush)
        }
    }
    
    /// 处理选中的图片
    private func handleImageSelection_Hush(itemProvider_Hush: NSItemProvider) {
        itemProvider_Hush.loadObject(ofClass: UIImage.self) { [weak self] image_Hush, error_Hush in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Hush = error_Hush {
                print("❌ 加载图片失败: \(error_Hush)")
                self.callCompletion_Hush(.cancelled_Hush)
                return
            }
            
            // 类型转换和回调
            if let image_Hush = image_Hush as? UIImage {
                self.callCompletion_Hush(.photo_Hush(image_Hush: image_Hush))
            } else {
                self.callCompletion_Hush(.cancelled_Hush)
            }
        }
    }
    
    /// 处理选中的视频
    private func handleVideoSelection_Hush(itemProvider_Hush: NSItemProvider) {
        itemProvider_Hush.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_Hush, error_Hush in
            guard let self = self else { return }
            
            // 错误处理
            if let error_Hush = error_Hush {
                print("❌ 加载视频失败: \(error_Hush)")
                self.callCompletion_Hush(.cancelled_Hush)
                return
            }
            
            guard let url_Hush = url_Hush else {
                print("❌ 视频URL为空")
                self.callCompletion_Hush(.cancelled_Hush)
                return
            }
            
            // 复制视频到临时目录
            self.copyVideoToTemp_Hush(sourceURL_Hush: url_Hush)
        }
    }
    
    /// 复制视频到临时目录
    /// 功能：将视频文件复制到临时目录，避免被系统清理
    /// 参数：sourceURL_Hush: 原始视频URL
    private func copyVideoToTemp_Hush(sourceURL_Hush: URL) {
        // 生成临时文件路径
        let fileName_Hush = "\(Self.tempVideoPrefix_Hush)\(Date().timeIntervalSince1970)"
        let tempURL_Hush = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName_Hush)
            .appendingPathExtension(sourceURL_Hush.pathExtension)
        
        do {
            // 如果文件已存在，先删除
            try removeFileIfExists_Hush(at: tempURL_Hush)
            
            // 复制视频文件
            try FileManager.default.copyItem(at: sourceURL_Hush, to: tempURL_Hush)
            print("✅ 视频已复制到临时目录: \(tempURL_Hush.path)")
            
            callCompletion_Hush(.video_Hush(url_Hush: tempURL_Hush))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Hush(.cancelled_Hush)
        }
    }
    
    /// 删除文件（如果存在）
    private func removeFileIfExists_Hush(at url_Hush: URL) throws {
        if FileManager.default.fileExists(atPath: url_Hush.path) {
            try FileManager.default.removeItem(at: url_Hush)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate（相机拍摄）

/// UIImagePickerController 代理实现（处理相机拍摄结果）
extension MediaPickerHelper_Hush: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// 用户完成拍摄，返回照片
    func imagePickerController(_ picker: UIImagePickerController,
                                didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        if let image_Hush = info[.originalImage] as? UIImage {
            callCompletion_Hush(.photo_Hush(image_Hush: image_Hush))
        } else {
            callCompletion_Hush(.cancelled_Hush)
        }
    }
    
    /// 用户取消拍摄
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        callCompletion_Hush(.cancelled_Hush)
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
extension MediaPickerHelper_Hush: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_Hush = results.first else {
            print("⚠️ 用户取消选择")
            callCompletion_Hush(.cancelled_Hush)
            return
        }
        
        let itemProvider_Hush = result_Hush.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_Hush.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Hush(itemProvider_Hush: itemProvider_Hush)
        } else if itemProvider_Hush.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Hush(itemProvider_Hush: itemProvider_Hush)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Hush(.cancelled_Hush)
        }
    }
}
