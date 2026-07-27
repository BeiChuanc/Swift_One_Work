import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Maki {
    case image_Maki
    case video_Maki
    case none_Maki
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持 SF Symbols、Assets、网络图片、本地文件及视频缩略图
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Maki: UIView {

    // MARK: - 静态常量

    /// 渐变色配置（用于 SF Symbols 背景，按哈希值循环选取）
    private static let gradientColors_Maki: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Maki: "#667eea"), UIColor(hexstring_Maki: "#764ba2")),
        (UIColor(hexstring_Maki: "#f093fb"), UIColor(hexstring_Maki: "#f5576c")),
        (UIColor(hexstring_Maki: "#4facfe"), UIColor(hexstring_Maki: "#00f2fe")),
        (UIColor(hexstring_Maki: "#43e97b"), UIColor(hexstring_Maki: "#38f9d7")),
        (UIColor(hexstring_Maki: "#fa709a"), UIColor(hexstring_Maki: "#fee140"))
    ]

    /// 占位符渐变色
    private static let placeholderGradientColors_Maki: [CGColor] = [
        UIColor(hexstring_Maki: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Maki: "#764ba2").withAlphaComponent(0.3).cgColor
    ]

    // MARK: - UI组件

    private let imageView_Maki: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.backgroundColor = UIColor(hexstring_Maki: "#F7FAFC")
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 系统图标容器（不拦截触摸）
    private let iconContainerView_Maki: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 视频播放遮罩
    private let playIconView_Maki: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        v.layer.cornerRadius = 30
        v.isHidden = true
        return v
    }()

    private let playIconImageView_Maki: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "play.fill")
        v.tintColor = .white
        v.contentMode = .scaleAspectFit
        return v
    }()

    /// 无媒体时的占位图标
    private let placeholderIconView_Maki: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "photo.on.rectangle.angled")
        v.tintColor = UIColor(hexstring_Maki: "#A0AEC0")
        v.contentMode = .scaleAspectFit
        return v
    }()

    // MARK: - 属性

    private var mediaType_Maki: MediaType_Maki = .none_Maki

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Maki()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI设置

    private func setupUI_Maki() {
        layer.cornerRadius = 12
        clipsToBounds = true

        addSubview(imageView_Maki)
        addSubview(iconContainerView_Maki)
        addSubview(placeholderIconView_Maki)
        addSubview(playIconView_Maki)
        playIconView_Maki.addSubview(playIconImageView_Maki)

        imageView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        iconContainerView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        placeholderIconView_Maki.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        playIconView_Maki.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        playIconImageView_Maki.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(28)
        }
    }

    // MARK: - 公共方法

    /// 直接展示 UIImage（相册选图后使用，无需路径）
    /// 参数：
    /// - image_Maki: 要展示的图片对象
    func configureWithImage_Maki(image_Maki: UIImage) {
        mediaType_Maki = .image_Maki
        clearOldContent_Maki()
        imageView_Maki.image = image_Maki
        placeholderIconView_Maki.isHidden = true
        playIconView_Maki.isHidden = true
    }

    /// 配置媒体展示
    /// 参数：
    /// - mediaPath_Maki: 媒体路径（nil 或空字符串时显示占位符）
    /// - isVideo_Maki: 是否为视频，默认 false
    func configure_Maki(mediaPath_Maki: String?, isVideo_Maki: Bool = false) {
        guard let path_Maki = mediaPath_Maki, !path_Maki.isEmpty else {
            showPlaceholder_Maki()
            return
        }
        mediaType_Maki = isVideo_Maki ? .video_Maki : .image_Maki
        playIconView_Maki.isHidden = !isVideo_Maki
        loadMedia_Maki(path_Maki: path_Maki, isVideo_Maki: isVideo_Maki)
    }

    // MARK: - 私有方法 - 媒体加载

    /// 按优先级依次尝试各来源加载媒体
    private func loadMedia_Maki(path_Maki: String, isVideo_Maki: Bool) {
        // 1. SF Symbols
        if let sysImg_Maki = UIImage(systemName: path_Maki) {
            loadSystemIcon_Maki(image_Maki: sysImg_Maki, path_Maki: path_Maki)
            return
        }

        // 2. Assets
        if let assetImg_Maki = UIImage(named: path_Maki) {
            loadImageSuccess_Maki(image_Maki: assetImg_Maki)
            return
        }

        // 3. 网络图片
        if path_Maki.hasPrefix("http://") || path_Maki.hasPrefix("https://") {
            loadNetworkImage_Maki(urlString_Maki: path_Maki)
            return
        }

        let docsDir_Maki = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // 4. 文档目录（文件名）
        let docFile_Maki = docsDir_Maki.appendingPathComponent(path_Maki)
        if let img_Maki = UIImage(contentsOfFile: docFile_Maki.path) {
            loadImageSuccess_Maki(image_Maki: img_Maki)
            print("✅ 从文档目录加载媒体: \(path_Maki)")
            return
        }

        // 5. 完整本地路径
        if let img_Maki = UIImage(contentsOfFile: path_Maki) {
            loadImageSuccess_Maki(image_Maki: img_Maki)
            return
        }

        // 6. Bundle 视频
        if let url_Maki = Self.bundleVideoURL_Maki(named: path_Maki) {
            showVideoThumbnail_Maki(url_Maki: url_Maki)
            return
        }

        // 7. 文档目录视频
        for ext_Maki in ["mp4", "mov", "m4v"] {
            let videoFile_Maki = docsDir_Maki.appendingPathComponent("\(path_Maki).\(ext_Maki)")
            if FileManager.default.fileExists(atPath: videoFile_Maki.path) {
                showVideoThumbnail_Maki(url_Maki: videoFile_Maki)
                return
            }
        }

        // 8. 所有来源均失败
        print("⚠️ 无法加载媒体: \(path_Maki)")
        showPlaceholder_Maki()
    }

    /// 清理旧内容（图片、渐变图层、图标子视图）
    private func clearOldContent_Maki() {
        imageView_Maki.image = nil
        imageView_Maki.layer.sublayers?.removeAll()
        iconContainerView_Maki.subviews.forEach { $0.removeFromSuperview() }
    }

    /// 展示 SF Symbol 图标（带哈希选色渐变背景）
    private func loadSystemIcon_Maki(image_Maki: UIImage, path_Maki: String) {
        clearOldContent_Maki()

        let gradient_Maki = Self.gradientColors_Maki[abs(path_Maki.hashValue) % Self.gradientColors_Maki.count]
        addGradientLayer_Maki(colors_Maki: [gradient_Maki.0.cgColor, gradient_Maki.1.cgColor])

        let icon_Maki = UIImageView(image: image_Maki)
        icon_Maki.tintColor = .white
        icon_Maki.contentMode = .scaleAspectFit
        icon_Maki.alpha = 0.9
        iconContainerView_Maki.addSubview(icon_Maki)
        icon_Maki.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        placeholderIconView_Maki.isHidden = true
    }

    /// 使用 Kingfisher 加载网络图片
    private func loadNetworkImage_Maki(urlString_Maki: String) {
        clearOldContent_Maki()
        if let url_Maki = URL(string: urlString_Maki) {
            imageView_Maki.kf.setImage(
                with: url_Maki,
                placeholder: createPlaceholderImage_Maki(),
                options: [.transition(.fade(0.3))]
            )
        }
        placeholderIconView_Maki.isHidden = true
    }

    /// 图片加载成功后更新 imageView
    private func loadImageSuccess_Maki(image_Maki: UIImage) {
        clearOldContent_Maki()
        imageView_Maki.image = image_Maki
        placeholderIconView_Maki.isHidden = true
    }

    /// 设置视频类型状态并触发缩略图生成
    /// 参数：
    /// - url_Maki: 视频文件 URL
    private func showVideoThumbnail_Maki(url_Maki: URL) {
        mediaType_Maki = .video_Maki
        playIconView_Maki.isHidden = false
        generateVideoThumbnail_Maki(url_Maki: url_Maki)
    }

    /// 在 imageView 下方插入渐变图层
    private func addGradientLayer_Maki(colors_Maki: [CGColor]) {
        let layer_Maki = CAGradientLayer()
        layer_Maki.frame = bounds
        layer_Maki.colors = colors_Maki
        layer_Maki.startPoint = CGPoint(x: 0, y: 0)
        layer_Maki.endPoint = CGPoint(x: 1, y: 1)
        imageView_Maki.layer.insertSublayer(layer_Maki, at: 0)
    }

    /// 显示占位符状态（带渐变背景）
    private func showPlaceholder_Maki() {
        mediaType_Maki = .none_Maki
        clearOldContent_Maki()
        placeholderIconView_Maki.isHidden = false
        playIconView_Maki.isHidden = true
        addGradientLayer_Maki(colors_Maki: Self.placeholderGradientColors_Maki)
    }

    /// 生成 Kingfisher 占位图（纯色背景块）
    private func createPlaceholderImage_Maki() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        UIColor(hexstring_Maki: "#F7FAFC").setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let img_Maki = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img_Maki
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if mediaType_Maki == .none_Maki {
            imageView_Maki.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中查找视频文件（依次尝试 mp4 / mov / m4v）
    /// 参数：
    /// - named_Maki: 不含扩展名的资源名
    /// 返回值：找到时返回 URL，否则 nil
    static func bundleVideoURL_Maki(named named_Maki: String) -> URL? {
        ["mp4", "mov", "m4v"].lazy
            .compactMap { Bundle.main.url(forResource: named_Maki, withExtension: $0) }
            .first
    }

    /// 从视频 URL 异步提取第一帧作为缩略图
    /// 参数：
    /// - url_Maki: 视频文件 URL
    private func generateVideoThumbnail_Maki(url_Maki: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let generator_Maki = AVAssetImageGenerator(asset: AVURLAsset(url: url_Maki))
            generator_Maki.appliesPreferredTrackTransform = true
            generator_Maki.maximumSize = CGSize(width: 600, height: 600)
            do {
                let cgImage_Maki = try generator_Maki.copyCGImage(
                    at: CMTime(seconds: 0.1, preferredTimescale: 600),
                    actualTime: nil
                )
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Maki(image_Maki: UIImage(cgImage: cgImage_Maki))
                    self?.playIconView_Maki.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Maki() }
            }
        }
    }
}
