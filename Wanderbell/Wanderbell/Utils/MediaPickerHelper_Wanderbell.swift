import Foundation
import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
/// 功能：封装 PHPickerViewController，提供图片、视频选择功能
/// 设计思路：
/// - 支持三种选择模式：仅图片、仅视频、图片+视频
/// - 使用闭包回调返回选择结果
/// - 自动处理视频文件的临时存储
/// - 提供单例模式和实例模式两种使用方式
class MediaPickerHelper_Wanderbell: NSObject {
    
    // MARK: - 枚举定义
    
    /// 媒体类型
    /// 功能：定义可选择的媒体类型
    enum MediaType_Wanderbell {
        case photo_Wanderbell           // 仅图片
        case video_Wanderbell           // 仅视频
        case photoAndVideo_Wanderbell   // 图片和视频
    }
    
    /// 选择结果
    /// 功能：封装用户选择的媒体结果
    enum PickerResult_Wanderbell {
        case photo_Wanderbell(image_Wanderbell: UIImage)      // 图片结果
        case video_Wanderbell(url_Wanderbell: URL)            // 视频结果
        case cancelled_Wanderbell                              // 用户取消
    }
    
    // MARK: - 属性
    
    /// 单例实例
    static let shared_Wanderbell = MediaPickerHelper_Wanderbell()
    
    /// 完成回调
    private var completion_Wanderbell: ((PickerResult_Wanderbell) -> Void)?
    
    /// 当前选择的媒体类型
    private var currentMediaType_Wanderbell: MediaType_Wanderbell = .photo_Wanderbell
    
    // MARK: - 公开方法
    
    /// 显示媒体选择器
    /// 功能：在指定视图控制器上展示系统相册选择器
    /// 参数：
    /// - viewController_wanderbell: 用于展示选择器的视图控制器
    /// - mediaType_wanderbell: 媒体类型（图片/视频/图片+视频）
    /// - selectionLimit_wanderbell: 最大选择数量，默认为 1
    /// - completion_wanderbell: 选择完成回调
    /// 异常场景：用户取消时返回 .cancelled_Wanderbell
    func showPicker_Wanderbell(
        from viewController_wanderbell: UIViewController,
        mediaType_wanderbell: MediaType_Wanderbell = .photo_Wanderbell,
        selectionLimit_wanderbell: Int = 1,
        completion_wanderbell: @escaping (PickerResult_Wanderbell) -> Void
    ) {
        // 保存回调和媒体类型
        self.completion_Wanderbell = completion_wanderbell
        self.currentMediaType_Wanderbell = mediaType_wanderbell
        
        // 配置 PHPicker
        var config_wanderbell = PHPickerConfiguration()
        config_wanderbell.selectionLimit = selectionLimit_wanderbell
        
        // 根据媒体类型设置过滤器
        switch mediaType_wanderbell {
        case .photo_Wanderbell:
            config_wanderbell.filter = .images
        case .video_Wanderbell:
            config_wanderbell.filter = .videos
        case .photoAndVideo_Wanderbell:
            config_wanderbell.filter = .any(of: [.images, .videos])
        }
        
        // 创建并展示选择器
        let picker_wanderbell = PHPickerViewController(configuration: config_wanderbell)
        picker_wanderbell.delegate = self
        
        viewController_wanderbell.present(picker_wanderbell, animated: true)
    }
    
    /// 快捷方法：选择单张图片
    /// 功能：快速选择一张图片
    /// 参数：
    /// - viewController_wanderbell: 用于展示选择器的视图控制器
    /// - completion_wanderbell: 完成回调，返回图片或 nil（取消）
    static func pickImage_Wanderbell(
        from viewController_wanderbell: UIViewController,
        completion_wanderbell: @escaping (UIImage?) -> Void
    ) {
        shared_Wanderbell.showPicker_Wanderbell(
            from: viewController_wanderbell,
            mediaType_wanderbell: .photo_Wanderbell
        ) { result_wanderbell in
            switch result_wanderbell {
            case .photo_Wanderbell(let image_wanderbell):
                completion_wanderbell(image_wanderbell)
            case .cancelled_Wanderbell:
                completion_wanderbell(nil)
            default:
                completion_wanderbell(nil)
            }
        }
    }
    
    /// 快捷方法：选择单个视频
    /// 功能：快速选择一个视频
    /// 参数：
    /// - viewController_wanderbell: 用于展示选择器的视图控制器
    /// - completion_wanderbell: 完成回调，返回视频 URL 或 nil（取消）
    static func pickVideo_Wanderbell(
        from viewController_wanderbell: UIViewController,
        completion_wanderbell: @escaping (URL?) -> Void
    ) {
        shared_Wanderbell.showPicker_Wanderbell(
            from: viewController_wanderbell,
            mediaType_wanderbell: .video_Wanderbell
        ) { result_wanderbell in
            switch result_wanderbell {
            case .video_Wanderbell(let url_wanderbell):
                completion_wanderbell(url_wanderbell)
            case .cancelled_Wanderbell:
                completion_wanderbell(nil)
            default:
                completion_wanderbell(nil)
            }
        }
    }
    
    /// 快捷方法：选择图片或视频
    /// 功能：选择一张图片或一个视频
    /// 参数：
    /// - viewController_wanderbell: 用于展示选择器的视图控制器
    /// - completion_wanderbell: 完成回调，返回选择结果
    static func pickMedia_Wanderbell(
        from viewController_wanderbell: UIViewController,
        completion_wanderbell: @escaping (PickerResult_Wanderbell) -> Void
    ) {
        shared_Wanderbell.showPicker_Wanderbell(
            from: viewController_wanderbell,
            mediaType_wanderbell: .photoAndVideo_Wanderbell,
            completion_wanderbell: completion_wanderbell
        )
    }
    
    // MARK: - 私有方法
    
    /// 处理选中的图片
    /// 功能：从 NSItemProvider 加载图片
    /// 参数：
    /// - itemProvider_wanderbell: 提供图片数据的对象
    private func handleImageSelection_Wanderbell(itemProvider_wanderbell: NSItemProvider) {
        itemProvider_wanderbell.loadObject(ofClass: UIImage.self) { [weak self] image_wanderbell, error_wanderbell in
            if let error_wanderbell = error_wanderbell {
                print("❌ 加载图片失败: \(error_wanderbell)")
                DispatchQueue.main.async {
                    self?.completion_Wanderbell?(.cancelled_Wanderbell)
                }
                return
            }
            
            if let image_wanderbell = image_wanderbell as? UIImage {
                DispatchQueue.main.async {
                    self?.completion_Wanderbell?(.photo_Wanderbell(image_Wanderbell: image_wanderbell))
                }
            } else {
                DispatchQueue.main.async {
                    self?.completion_Wanderbell?(.cancelled_Wanderbell)
                }
            }
        }
    }
    
    /// 处理选中的视频
    /// 功能：从 NSItemProvider 加载视频，并复制到临时目录
    /// 参数：
    /// - itemProvider_wanderbell: 提供视频数据的对象
    private func handleVideoSelection_Wanderbell(itemProvider_wanderbell: NSItemProvider) {
        itemProvider_wanderbell.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url_wanderbell, error_wanderbell in
            if let error_wanderbell = error_wanderbell {
                print("❌ 加载视频失败: \(error_wanderbell)")
                DispatchQueue.main.async {
                    self?.completion_Wanderbell?(.cancelled_Wanderbell)
                }
                return
            }
            
            guard let url_wanderbell = url_wanderbell else {
                print("❌ 视频URL为空")
                DispatchQueue.main.async {
                    self?.completion_Wanderbell?(.cancelled_Wanderbell)
                }
                return
            }
            
            // 将视频复制到临时目录（因为原始 URL 会被系统清理）
            let tempURL_wanderbell = FileManager.default.temporaryDirectory
                .appendingPathComponent("picked_video_\(Date().timeIntervalSince1970)")
                .appendingPathExtension(url_wanderbell.pathExtension)
            
            do {
                // 如果文件已存在，先删除
                if FileManager.default.fileExists(atPath: tempURL_wanderbell.path) {
                    try FileManager.default.removeItem(at: tempURL_wanderbell)
                }
                
                // 复制视频文件
                try FileManager.default.copyItem(at: url_wanderbell, to: tempURL_wanderbell)
                print("✅ 视频已复制到临时目录: \(tempURL_wanderbell.path)")
                
                DispatchQueue.main.async {
                    self?.completion_Wanderbell?(.video_Wanderbell(url_Wanderbell: tempURL_wanderbell))
                }
            } catch {
                print("❌ 复制视频失败: \(error)")
                DispatchQueue.main.async {
                    self?.completion_Wanderbell?(.cancelled_Wanderbell)
                }
            }
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

/// PHPickerViewController 代理实现
/// 功能：处理用户从相册选择的媒体
extension MediaPickerHelper_Wanderbell: PHPickerViewControllerDelegate {
    
    /// 用户完成选择（选中或取消）
    /// 功能：处理选中的媒体项，区分图片和视频
    /// 参数：
    /// - picker: PHPickerViewController 实例
    /// - results: 选中的结果数组
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // 关闭选择器
        picker.dismiss(animated: true)
        
        // 检查是否有选中项
        guard let result_wanderbell = results.first else {
            print("⚠️ 用户取消选择")
            completion_Wanderbell?(.cancelled_Wanderbell)
            return
        }
        
        let itemProvider_wanderbell = result_wanderbell.itemProvider
        
        // 判断是图片还是视频
        if itemProvider_wanderbell.canLoadObject(ofClass: UIImage.self) {
            // 处理图片
            handleImageSelection_Wanderbell(itemProvider_wanderbell: itemProvider_wanderbell)
        } else if itemProvider_wanderbell.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            // 处理视频
            handleVideoSelection_Wanderbell(itemProvider_wanderbell: itemProvider_wanderbell)
        } else {
            print("⚠️ 不支持的媒体类型")
            completion_Wanderbell?(.cancelled_Wanderbell)
        }
    }
}
