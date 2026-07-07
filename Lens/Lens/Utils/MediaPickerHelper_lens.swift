import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
/// 功能：封装 PHPicker，支持图片、视频及混合选择
/// 设计：单例 + 代理回调，视频自动复制到临时目录
class MediaPickerHelper_Lens: NSObject {

    // MARK: - 枚举

    /// 媒体类型
    enum MediaType_Lens {
        case photo_Lens
        case video_Lens
        case photoAndVideo_Lens

        /// 对应的 PHPicker 过滤器
        var pickerFilter_Lens: PHPickerFilter {
            switch self {
            case .photo_Lens:         return .images
            case .video_Lens:         return .videos
            case .photoAndVideo_Lens: return .any(of: [.images, .videos])
            }
        }
    }

    /// 选择结果
    enum PickerResult_Lens {
        case photo_Lens(image_Lens: UIImage)
        case video_Lens(url_Lens: URL)
        case cancelled_Lens
    }

    // MARK: - 属性

    static let shared_Lens = MediaPickerHelper_Lens()

    /// 临时视频文件前缀
    private static let tempVideoPrefix_Lens = "picked_video_"

    private var completion_Lens: ((PickerResult_Lens) -> Void)?

    // MARK: - 公开方法

    /// 显示媒体选择器
    /// 参数：
    /// - viewController_Lens: 发起选择的视图控制器
    /// - mediaType_Lens: 允许的媒体类型，默认仅图片
    /// - selectionLimit_Lens: 最大选择数量，默认 1
    /// - completion_Lens: 选择完成回调
    func showPicker_Lens(
        from viewController_Lens: UIViewController,
        mediaType_Lens: MediaType_Lens = .photo_Lens,
        selectionLimit_Lens: Int = 1,
        completion_Lens: @escaping (PickerResult_Lens) -> Void
    ) {
        self.completion_Lens = completion_Lens

        var config_Lens = PHPickerConfiguration()
        config_Lens.selectionLimit = selectionLimit_Lens
        config_Lens.filter = mediaType_Lens.pickerFilter_Lens

        let picker_Lens = PHPickerViewController(configuration: config_Lens)
        picker_Lens.delegate = self
        viewController_Lens.present(picker_Lens, animated: true)
    }

    /// 快捷方法：选择单张图片
    static func pickImage_Lens(from viewController_Lens: UIViewController, completion_Lens: @escaping (UIImage?) -> Void) {
        shared_Lens.showPicker_Lens(from: viewController_Lens, mediaType_Lens: .photo_Lens) { result in
            if case .photo_Lens(let image) = result { completion_Lens(image) } else { completion_Lens(nil) }
        }
    }

    /// 快捷方法：选择单个视频
    static func pickVideo_Lens(from viewController_Lens: UIViewController, completion_Lens: @escaping (URL?) -> Void) {
        shared_Lens.showPicker_Lens(from: viewController_Lens, mediaType_Lens: .video_Lens) { result in
            if case .video_Lens(let url) = result { completion_Lens(url) } else { completion_Lens(nil) }
        }
    }

    /// 快捷方法：选择图片或视频
    static func pickMedia_Lens(
        from viewController_Lens: UIViewController,
        completion_Lens: @escaping (PickerResult_Lens) -> Void
    ) {
        shared_Lens.showPicker_Lens(
            from: viewController_Lens,
            mediaType_Lens: .photoAndVideo_Lens,
            completion_Lens: completion_Lens
        )
    }

    // MARK: - 私有方法

    /// 在主线程回调结果
    private func callCompletion_Lens(_ result_Lens: PickerResult_Lens) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Lens?(result_Lens)
        }
    }

    /// 处理选中的图片
    private func handleImageSelection_Lens(itemProvider_Lens: NSItemProvider) {
        itemProvider_Lens.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self else { return }
            if let error {
                print("❌ 加载图片失败: \(error)")
                return callCompletion_Lens(.cancelled_Lens)
            }
            guard let image = object as? UIImage else {
                return callCompletion_Lens(.cancelled_Lens)
            }
            callCompletion_Lens(.photo_Lens(image_Lens: image))
        }
    }

    /// 处理选中的视频
    private func handleVideoSelection_Lens(itemProvider_Lens: NSItemProvider) {
        itemProvider_Lens.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
            guard let self else { return }
            if let error {
                print("❌ 加载视频失败: \(error)")
                return callCompletion_Lens(.cancelled_Lens)
            }
            guard let url else {
                print("❌ 视频URL为空")
                return callCompletion_Lens(.cancelled_Lens)
            }
            copyVideoToTemp_Lens(sourceURL_Lens: url)
        }
    }

    /// 复制视频到临时目录（避免系统清理原始文件）
    /// 参数：
    /// - sourceURL_Lens: 原始视频 URL
    private func copyVideoToTemp_Lens(sourceURL_Lens: URL) {
        let tempURL_Lens = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(Self.tempVideoPrefix_Lens)\(Date().timeIntervalSince1970)")
            .appendingPathExtension(sourceURL_Lens.pathExtension)

        do {
            if FileManager.default.fileExists(atPath: tempURL_Lens.path) {
                try FileManager.default.removeItem(at: tempURL_Lens)
            }
            try FileManager.default.copyItem(at: sourceURL_Lens, to: tempURL_Lens)
            print("✅ 视频已复制到临时目录: \(tempURL_Lens.path)")
            callCompletion_Lens(.video_Lens(url_Lens: tempURL_Lens))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Lens(.cancelled_Lens)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension MediaPickerHelper_Lens: PHPickerViewControllerDelegate {

    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider_Lens = results.first?.itemProvider else {
            print("⚠️ 用户取消选择")
            callCompletion_Lens(.cancelled_Lens)
            return
        }

        if itemProvider_Lens.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Lens(itemProvider_Lens: itemProvider_Lens)
        } else if itemProvider_Lens.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Lens(itemProvider_Lens: itemProvider_Lens)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Lens(.cancelled_Lens)
        }
    }
}
