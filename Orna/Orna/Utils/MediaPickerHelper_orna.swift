import UIKit
import PhotosUI
import AVFoundation
import UniformTypeIdentifiers

// MARK: 媒体选择工具类

/// 媒体选择工具类
/// 功能：封装 PHPicker，支持图片、视频及混合选择
/// 设计：单例 + 代理回调，视频自动复制到临时目录
class MediaPickerHelper_Orna: NSObject {

    // MARK: - 枚举

    /// 媒体类型
    enum MediaType_Orna {
        case photo_Orna
        case video_Orna
        case photoAndVideo_Orna

        /// 对应的 PHPicker 过滤器
        var pickerFilter_Orna: PHPickerFilter {
            switch self {
            case .photo_Orna:         return .images
            case .video_Orna:         return .videos
            case .photoAndVideo_Orna: return .any(of: [.images, .videos])
            }
        }
    }

    /// 选择结果
    enum PickerResult_Orna {
        case photo_Orna(image_Orna: UIImage)
        case video_Orna(url_Orna: URL)
        case cancelled_Orna
    }

    // MARK: - 属性

    static let shared_Orna = MediaPickerHelper_Orna()

    /// 临时视频文件前缀
    private static let tempVideoPrefix_Orna = "picked_video_"

    private var completion_Orna: ((PickerResult_Orna) -> Void)?

    // MARK: - 公开方法

    /// 显示媒体选择器
    /// 参数：
    /// - viewController_Orna: 发起选择的视图控制器
    /// - mediaType_Orna: 允许的媒体类型，默认仅图片
    /// - selectionLimit_Orna: 最大选择数量，默认 1
    /// - completion_Orna: 选择完成回调
    func showPicker_Orna(
        from viewController_Orna: UIViewController,
        mediaType_Orna: MediaType_Orna = .photo_Orna,
        selectionLimit_Orna: Int = 1,
        completion_Orna: @escaping (PickerResult_Orna) -> Void
    ) {
        self.completion_Orna = completion_Orna

        var config_Orna = PHPickerConfiguration()
        config_Orna.selectionLimit = selectionLimit_Orna
        config_Orna.filter = mediaType_Orna.pickerFilter_Orna

        let picker_Orna = PHPickerViewController(configuration: config_Orna)
        picker_Orna.delegate = self
        viewController_Orna.present(picker_Orna, animated: true)
    }

    /// 快捷方法：选择单张图片
    static func pickImage_Orna(from viewController_Orna: UIViewController, completion_Orna: @escaping (UIImage?) -> Void) {
        shared_Orna.showPicker_Orna(from: viewController_Orna, mediaType_Orna: .photo_Orna) { result in
            if case .photo_Orna(let image) = result { completion_Orna(image) } else { completion_Orna(nil) }
        }
    }

    /// 快捷方法：选择单个视频
    static func pickVideo_Orna(from viewController_Orna: UIViewController, completion_Orna: @escaping (URL?) -> Void) {
        shared_Orna.showPicker_Orna(from: viewController_Orna, mediaType_Orna: .video_Orna) { result in
            if case .video_Orna(let url) = result { completion_Orna(url) } else { completion_Orna(nil) }
        }
    }

    /// 快捷方法：选择图片或视频
    static func pickMedia_Orna(
        from viewController_Orna: UIViewController,
        completion_Orna: @escaping (PickerResult_Orna) -> Void
    ) {
        shared_Orna.showPicker_Orna(
            from: viewController_Orna,
            mediaType_Orna: .photoAndVideo_Orna,
            completion_Orna: completion_Orna
        )
    }

    // MARK: - 私有方法

    /// 在主线程回调结果
    private func callCompletion_Orna(_ result_Orna: PickerResult_Orna) {
        DispatchQueue.main.async { [weak self] in
            self?.completion_Orna?(result_Orna)
        }
    }

    /// 处理选中的图片
    private func handleImageSelection_Orna(itemProvider_Orna: NSItemProvider) {
        itemProvider_Orna.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let self else { return }
            if let error {
                print("❌ 加载图片失败: \(error)")
                return callCompletion_Orna(.cancelled_Orna)
            }
            guard let image = object as? UIImage else {
                return callCompletion_Orna(.cancelled_Orna)
            }
            callCompletion_Orna(.photo_Orna(image_Orna: image))
        }
    }

    /// 处理选中的视频
    private func handleVideoSelection_Orna(itemProvider_Orna: NSItemProvider) {
        itemProvider_Orna.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { [weak self] url, error in
            guard let self else { return }
            if let error {
                print("❌ 加载视频失败: \(error)")
                return callCompletion_Orna(.cancelled_Orna)
            }
            guard let url else {
                print("❌ 视频URL为空")
                return callCompletion_Orna(.cancelled_Orna)
            }
            copyVideoToTemp_Orna(sourceURL_Orna: url)
        }
    }

    /// 复制视频到临时目录（避免系统清理原始文件）
    /// 参数：
    /// - sourceURL_Orna: 原始视频 URL
    private func copyVideoToTemp_Orna(sourceURL_Orna: URL) {
        let tempURL_Orna = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(Self.tempVideoPrefix_Orna)\(Date().timeIntervalSince1970)")
            .appendingPathExtension(sourceURL_Orna.pathExtension)

        do {
            if FileManager.default.fileExists(atPath: tempURL_Orna.path) {
                try FileManager.default.removeItem(at: tempURL_Orna)
            }
            try FileManager.default.copyItem(at: sourceURL_Orna, to: tempURL_Orna)
            print("✅ 视频已复制到临时目录: \(tempURL_Orna.path)")
            callCompletion_Orna(.video_Orna(url_Orna: tempURL_Orna))
        } catch {
            print("❌ 复制视频失败: \(error)")
            callCompletion_Orna(.cancelled_Orna)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension MediaPickerHelper_Orna: PHPickerViewControllerDelegate {

    /// 用户完成选择（选中或取消）
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let itemProvider_Orna = results.first?.itemProvider else {
            print("⚠️ 用户取消选择")
            callCompletion_Orna(.cancelled_Orna)
            return
        }

        if itemProvider_Orna.canLoadObject(ofClass: UIImage.self) {
            handleImageSelection_Orna(itemProvider_Orna: itemProvider_Orna)
        } else if itemProvider_Orna.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
            handleVideoSelection_Orna(itemProvider_Orna: itemProvider_Orna)
        } else {
            print("⚠️ 不支持的媒体类型")
            callCompletion_Orna(.cancelled_Orna)
        }
    }
}
