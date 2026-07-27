import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
/// 功能：封装 PHPicker，支持图片、视频及混合选择
/// 设计：单例 + 代理回调，视频自动复制到临时目录
class MediaPickerHelper_Maki: NSObject {

    // MARK: - 枚举

    /// 媒体类型
    enum MediaType_Maki {
        case photo_Maki
        case video_Maki
        case photoAndVideo_Maki

        /// 对应的 PHPicker 过滤器
        var pickerFilter_Maki: PHPickerFilter {
            switch self {
            case .photo_Maki:         return .images
            case .video_Maki:         return .videos
            case .photoAndVideo_Maki: return .any(of: [.images, .videos])
            }
        }
    }

    /// 选择结果
    enum PickerResult_Maki {
        case photo_Maki(image_Maki: UIImage)
        case video_Maki(url_Maki: URL)
        case cancelled_Maki
    }

    // MARK: - 属性

    static let shared_Maki = MediaPickerHelper_Maki()

    /// 临时视频文件前缀
    private static let tempVideoPrefix_Maki = "picked_video_"

    private var completion_Maki: ((PickerResult_Maki) -> Void)?

    // MARK: - 公开方法

    /// 显示媒体选择器
    /// 参数：
    /// - viewController_Maki: 发起选择的视图控制器
    /// - mediaType_Maki: 允许的媒体类型，默认仅图片
    /// - selectionLimit_Maki: 最大选择数量，默认 1
    /// - completion_Maki: 选择完成回调
    func showPicker_Maki(
        from viewController_Maki: UIViewController,
        mediaType_Maki: MediaType_Maki = .photo_Maki,
        selectionLimit_Maki: Int = 1,
        completion_Maki: @escaping (PickerResult_Maki) -> Void
    ) {
        self.completion_Maki = completion_Maki

        var config_Maki = PHPickerConfiguration()
        config_Maki.selectionLimit = selectionLimit_Maki
        config_Maki.filter = mediaType_Maki.pickerFilter_Maki

        let picker_Maki = PHPickerViewController(configuration: config_Maki)
        picker_Maki.delegate = self
        viewController_Maki.present(picker_Maki, animated: true)
    }

    /// 快捷方法：选择单张图片
    static func pickImage_Maki(from viewController_Maki: UIViewController, completion_Maki: @escaping (UIImage?) -> Void) {
        shared_Maki.showPicker_Maki(from: viewController_Maki, mediaType_Maki: .photo_Maki) { result in
            if case .photo_Maki(let image) = result { completion_Maki(image) } else { completion_Maki(nil) }
        }
    }

    /// 快捷方法：选择单个视频
    static func pickVideo_Maki(from viewController_Maki: UIViewController, completion_Maki: @escaping (URL?) -> Void) {
        shared_Maki.showPicker_Maki(from: viewController_Maki, mediaType_Maki: .video_Maki) { result in
            if case .video_Maki(let url) = result { completion_Maki(url) } else { completion_Maki(nil) }
        }
    }

    /// 快捷方法：选择图片或视频
    static func pickMedia_Maki(
        from viewController_Maki: UIViewController,
        completion_Maki: @escaping (PickerResult_Maki) -> Void
    ) {
        shared_Maki.showPicker_Maki(
            from: viewController_Maki,
            mediaType_Maki: .photoAndVideo_Maki,
            completion_Maki: completion_Maki
        )
    }

    // MARK: - 私有方法

    /// 在主线程回调结果
    private func callCompletion_Maki(_ result_Maki: PickerResult_Maki) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Maki?(result_Maki)
        }
    }

    /// 处理选中的图片
    private func handleImageSelection_Maki(itemProvider_Maki: NSItemProvider) {
        itemProvider_Maki.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self else { return }
            if let error {
                print("❌ 加载图片失败: \(error)")
                return callCompletion_Maki(.cancelled_Maki)
            }
            guard let image = object as? UIImage else {
                return callCompletion_Maki(.cancelled_Maki)
            }
            callCompletion_Maki(.photo_Maki(image_Maki: image))
        }
    }

    /// 处理选中的视频
    private func handleVideoSelection_Maki(itemProvider_Maki: NSItemProvider) {
        itemProvider_Maki.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
            guard let self else { return }
            if let error {
                print("❌ 加载视频失败: \(error)")
                return callCompletion_Maki(.cancelled_Maki)
            }
            guard let url else {
                print("❌ 视频URL为空")
                return callCompletion_Maki(.cancelled_Maki)
            }
            copyVideoToTemp_Maki(sourceURL_Maki: url)
        }
    }

    /// 复制视频到临时目录（避免系统清理原始文件）
    /// 参数：
    /// - sourceURL_Maki: 原始视频 URL
    private func copyVideoToTemp_Maki(sourceURL_Maki: URL) {
        let tempURL_Maki = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(Self.tempVideoPrefix_Maki)\(Date().timeIntervalSince1970)")
            .appendingPathExtension(sourceURL_Maki.pathExtension)

        do {
            if FileManager.default.fileExists(atPath: tempURL_Maki.path) {
                try FileManager.default.removeItem(at: tempURL_Maki)
            }
            try FileManager.default.copyItem(at: sourceURL_Maki, to: tempURL_Maki)
            print("✅ 视频已复制到临时目录: \(tempURL_Maki.path)")
            callCompletion_Maki(.video_Maki(url_Maki: tempURL_Maki))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Maki(.cancelled_Maki)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension MediaPickerHelper_Maki: PHPickerViewControllerDelegate {

    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider_Maki = results.first?.itemProvider else {
            print("⚠️ 用户取消选择")
            callCompletion_Maki(.cancelled_Maki)
            return
        }

        if itemProvider_Maki.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Maki(itemProvider_Maki: itemProvider_Maki)
        } else if itemProvider_Maki.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Maki(itemProvider_Maki: itemProvider_Maki)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Maki(.cancelled_Maki)
        }
    }
}
