import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Lens {
    case image_Lens
    case video_Lens
    case none_Lens
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持 SF Symbols、Assets、网络图片、本地文件及视频缩略图
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Lens: UIView {

    // MARK: - 静态常量

    /// 渐变色配置（用于 SF Symbols 背景，按哈希值循环选取）
    private static let gradientColors_Lens: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Lens: "#667eea"), UIColor(hexstring_Lens: "#764ba2")),
        (UIColor(hexstring_Lens: "#f093fb"), UIColor(hexstring_Lens: "#f5576c")),
        (UIColor(hexstring_Lens: "#4facfe"), UIColor(hexstring_Lens: "#00f2fe")),
        (UIColor(hexstring_Lens: "#43e97b"), UIColor(hexstring_Lens: "#38f9d7")),
        (UIColor(hexstring_Lens: "#fa709a"), UIColor(hexstring_Lens: "#fee140"))
    ]

    /// 占位符渐变色
    private static let placeholderGradientColors_Lens: [CGColor] = [
        UIColor(hexstring_Lens: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Lens: "#764ba2").withAlphaComponent(0.3).cgColor
    ]

    // MARK: - UI组件

    private let imageView_Lens: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.backgroundColor = UIColor(hexstring_Lens: "#F7FAFC")
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 系统图标容器（不拦截触摸）
    private let iconContainerView_Lens: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 视频播放遮罩
    private let playIconView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        v.layer.cornerRadius = 30
        v.isHidden = true
        return v
    }()

    private let playIconImageView_Lens: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "play.fill")
        v.tintColor = .white
        v.contentMode = .scaleAspectFit
        return v
    }()

    /// 无媒体时的占位图标
    private let placeholderIconView_Lens: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "photo.on.rectangle.angled")
        v.tintColor = UIColor(hexstring_Lens: "#A0AEC0")
        v.contentMode = .scaleAspectFit
        return v
    }()

    // MARK: - 属性

    private var mediaType_Lens: MediaType_Lens = .none_Lens

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Lens()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI设置

    private func setupUI_Lens() {
        layer.cornerRadius = 12
        clipsToBounds = true

        addSubview(imageView_Lens)
        addSubview(iconContainerView_Lens)
        addSubview(placeholderIconView_Lens)
        addSubview(playIconView_Lens)
        playIconView_Lens.addSubview(playIconImageView_Lens)

        imageView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        iconContainerView_Lens.snp.makeConstraints { $0.edges.equalToSuperview() }
        placeholderIconView_Lens.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        playIconView_Lens.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        playIconImageView_Lens.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(28)
        }
    }

    // MARK: - 公共方法

    /// 直接展示 UIImage（相册选图后使用，无需路径）
    /// 参数：
    /// - image_Lens: 要展示的图片对象
    func configureWithImage_Lens(image_Lens: UIImage) {
        mediaType_Lens = .image_Lens
        clearOldContent_Lens()
        imageView_Lens.image = image_Lens
        placeholderIconView_Lens.isHidden = true
        playIconView_Lens.isHidden = true
    }

    /// 配置媒体展示
    /// 参数：
    /// - mediaPath_Lens: 媒体路径（nil 或空字符串时显示占位符）
    /// - isVideo_Lens: 是否为视频，默认 false
    func configure_Lens(mediaPath_Lens: String?, isVideo_Lens: Bool = false) {
        imageView_Lens.kf.cancelDownloadTask()
        guard let path_Lens = mediaPath_Lens, !path_Lens.isEmpty else {
            showPlaceholder_Lens()
            return
        }
        mediaType_Lens = isVideo_Lens ? .video_Lens : .image_Lens
        playIconView_Lens.isHidden = !isVideo_Lens
        loadMedia_Lens(path_Lens: path_Lens, isVideo_Lens: isVideo_Lens)
    }

    /// 外部指定展示圆角，用于 Cell 内与卡片圆角对齐
    /// 参数：
    /// - radius_Lens: 圆角半径（pt）
    func applyDisplayCornerRadius_Lens(_ radius_Lens: CGFloat) {
        layer.cornerRadius = radius_Lens
        clipsToBounds = true
        imageView_Lens.layer.cornerRadius = radius_Lens
        imageView_Lens.clipsToBounds = true
    }

    // MARK: - 私有方法 - 媒体加载

    /// 按优先级依次尝试各来源加载媒体
    private func loadMedia_Lens(path_Lens: String, isVideo_Lens: Bool) {
        // 1. SF Symbols
        if let sysImg_Lens = UIImage(systemName: path_Lens) {
            loadSystemIcon_Lens(image_Lens: sysImg_Lens, path_Lens: path_Lens)
            return
        }

        // 2. Assets
        if let assetImg_Lens = UIImage(named: path_Lens) {
            loadImageSuccess_Lens(image_Lens: assetImg_Lens)
            return
        }

        // 3. 网络图片
        if path_Lens.hasPrefix("http://") || path_Lens.hasPrefix("https://") {
            loadNetworkImage_Lens(urlString_Lens: path_Lens)
            return
        }

        let docsDir_Lens = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // 4. 文档目录（文件名）
        let docFile_Lens = docsDir_Lens.appendingPathComponent(path_Lens)
        if let img_Lens = UIImage(contentsOfFile: docFile_Lens.path) {
            loadImageSuccess_Lens(image_Lens: img_Lens)
            print("✅ 从文档目录加载媒体: \(path_Lens)")
            return
        }

        // 5. 完整本地路径
        if let img_Lens = UIImage(contentsOfFile: path_Lens) {
            loadImageSuccess_Lens(image_Lens: img_Lens)
            return
        }

        // 6. Bundle 视频
        if let url_Lens = Self.bundleVideoURL_Lens(named: path_Lens) {
            showVideoThumbnail_Lens(url_Lens: url_Lens)
            return
        }

        // 7. 文档目录视频
        for ext_Lens in ["mp4", "mov", "m4v"] {
            let videoFile_Lens = docsDir_Lens.appendingPathComponent("\(path_Lens).\(ext_Lens)")
            if FileManager.default.fileExists(atPath: videoFile_Lens.path) {
                showVideoThumbnail_Lens(url_Lens: videoFile_Lens)
                return
            }
        }

        // 8. 所有来源均失败
        print("⚠️ 无法加载媒体: \(path_Lens)")
        showPlaceholder_Lens()
    }

    /// 清理旧内容（图片、渐变图层、图标子视图）
    private func clearOldContent_Lens() {
        imageView_Lens.image = nil
        imageView_Lens.layer.sublayers?.removeAll()
        iconContainerView_Lens.subviews.forEach { $0.removeFromSuperview() }
    }

    /// 展示 SF Symbol 图标（带哈希选色渐变背景）
    private func loadSystemIcon_Lens(image_Lens: UIImage, path_Lens: String) {
        clearOldContent_Lens()

        let gradient_Lens = Self.gradientColors_Lens[abs(path_Lens.hashValue) % Self.gradientColors_Lens.count]
        addGradientLayer_Lens(colors_Lens: [gradient_Lens.0.cgColor, gradient_Lens.1.cgColor])

        let icon_Lens = UIImageView(image: image_Lens)
        icon_Lens.tintColor = .white
        icon_Lens.contentMode = .scaleAspectFit
        icon_Lens.alpha = 0.9
        iconContainerView_Lens.addSubview(icon_Lens)
        icon_Lens.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        placeholderIconView_Lens.isHidden = true
    }

    /// 使用 Kingfisher 加载网络图片
    private func loadNetworkImage_Lens(urlString_Lens: String) {
        clearOldContent_Lens()
        if let url_Lens = URL(string: urlString_Lens) {
            imageView_Lens.kf.setImage(
                with: url_Lens,
                placeholder: createPlaceholderImage_Lens(),
                options: [.transition(.fade(0.3))]
            )
        }
        placeholderIconView_Lens.isHidden = true
    }

    /// 图片加载成功后更新 imageView
    private func loadImageSuccess_Lens(image_Lens: UIImage) {
        clearOldContent_Lens()
        imageView_Lens.image = image_Lens
        placeholderIconView_Lens.isHidden = true
    }

    /// 设置视频类型状态并触发缩略图生成
    /// 参数：
    /// - url_Lens: 视频文件 URL
    private func showVideoThumbnail_Lens(url_Lens: URL) {
        mediaType_Lens = .video_Lens
        playIconView_Lens.isHidden = false
        generateVideoThumbnail_Lens(url_Lens: url_Lens)
    }

    /// 在 imageView 下方插入渐变图层
    private func addGradientLayer_Lens(colors_Lens: [CGColor]) {
        let layer_Lens = CAGradientLayer()
        layer_Lens.frame = bounds
        layer_Lens.colors = colors_Lens
        layer_Lens.startPoint = CGPoint(x: 0, y: 0)
        layer_Lens.endPoint = CGPoint(x: 1, y: 1)
        imageView_Lens.layer.insertSublayer(layer_Lens, at: 0)
    }

    /// 显示占位符状态（带渐变背景）
    private func showPlaceholder_Lens() {
        mediaType_Lens = .none_Lens
        clearOldContent_Lens()
        placeholderIconView_Lens.isHidden = false
        playIconView_Lens.isHidden = true
        addGradientLayer_Lens(colors_Lens: Self.placeholderGradientColors_Lens)
    }

    /// 生成 Kingfisher 占位图（纯色背景块）
    private func createPlaceholderImage_Lens() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        UIColor(hexstring_Lens: "#F7FAFC").setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let img_Lens = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img_Lens
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if mediaType_Lens == .none_Lens {
            imageView_Lens.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中查找视频文件（依次尝试 mp4 / mov / m4v）
    /// 参数：
    /// - named_Lens: 不含扩展名的资源名
    /// 返回值：找到时返回 URL，否则 nil
    static func bundleVideoURL_Lens(named named_Lens: String) -> URL? {
        ["mp4", "mov", "m4v"].lazy
            .compactMap { Bundle.main.url(forResource: named_Lens, withExtension: $0) }
            .first
    }

    /// 从视频 URL 异步提取第一帧作为缩略图
    /// 参数：
    /// - url_Lens: 视频文件 URL
    private func generateVideoThumbnail_Lens(url_Lens: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let generator_Lens = AVAssetImageGenerator(asset: AVURLAsset(url: url_Lens))
            generator_Lens.appliesPreferredTrackTransform = true
            generator_Lens.maximumSize = CGSize(width: 600, height: 600)
            do {
                let cgImage_Lens = try generator_Lens.copyCGImage(
                    at: CMTime(seconds: 0.1, preferredTimescale: 600),
                    actualTime: nil
                )
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Lens(image_Lens: UIImage(cgImage: cgImage_Lens))
                    self?.playIconView_Lens.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Lens() }
            }
        }
    }
}
