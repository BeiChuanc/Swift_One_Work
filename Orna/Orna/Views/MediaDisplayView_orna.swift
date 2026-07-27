import Foundation
import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: 媒体展示组件

/// 媒体类型枚举
enum MediaType_Orna {
    case image_Orna
    case video_Orna
    case none_Orna
}

/// 媒体展示视图
/// 功能：展示图片或视频封面，支持 SF Symbols、Assets、网络图片、本地文件及视频缩略图
/// 设计：圆角、占位符、视频播放图标
class MediaDisplayView_Orna: UIView {

    // MARK: - 静态常量

    /// 渐变色配置（用于 SF Symbols 背景，按哈希值循环选取）
    private static let gradientColors_Orna: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Orna: "#667eea"), UIColor(hexstring_Orna: "#764ba2")),
        (UIColor(hexstring_Orna: "#f093fb"), UIColor(hexstring_Orna: "#f5576c")),
        (UIColor(hexstring_Orna: "#4facfe"), UIColor(hexstring_Orna: "#00f2fe")),
        (UIColor(hexstring_Orna: "#43e97b"), UIColor(hexstring_Orna: "#38f9d7")),
        (UIColor(hexstring_Orna: "#fa709a"), UIColor(hexstring_Orna: "#fee140"))
    ]

    /// 占位符渐变色
    private static let placeholderGradientColors_Orna: [CGColor] = [
        UIColor(hexstring_Orna: "#667eea").withAlphaComponent(0.3).cgColor,
        UIColor(hexstring_Orna: "#764ba2").withAlphaComponent(0.3).cgColor
    ]

    // MARK: - UI组件

    private let imageView_Orna: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.backgroundColor = UIColor(hexstring_Orna: "#F7FAFC")
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 系统图标容器（不拦截触摸）
    private let iconContainerView_Orna: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 视频播放遮罩
    private let playIconView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        v.layer.cornerRadius = 30
        v.isHidden = true
        return v
    }()

    private let playIconImageView_Orna: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "play.fill")
        v.tintColor = .white
        v.contentMode = .scaleAspectFit
        return v
    }()

    /// 无媒体时的占位图标
    private let placeholderIconView_Orna: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(systemName: "photo.on.rectangle.angled")
        v.tintColor = UIColor(hexstring_Orna: "#A0AEC0")
        v.contentMode = .scaleAspectFit
        return v
    }()

    // MARK: - 属性

    private var mediaType_Orna: MediaType_Orna = .none_Orna

    /// 是否展示内置的无媒体占位图标（默认展示）。
    /// 当宿主页面自行叠加了更丰富的占位提示视图（如发布页的渐变徽标 + 文案）时，
    /// 应将其设为 false，避免内置占位图标与宿主自定义提示视图重叠形成"双重遮盖"
    var showsBuiltInPlaceholder_Orna: Bool = true {
        didSet {
            if mediaType_Orna == .none_Orna {
                placeholderIconView_Orna.isHidden = !showsBuiltInPlaceholder_Orna
            }
        }
    }

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Orna()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI设置

    private func setupUI_Orna() {
        layer.cornerRadius = 12
        clipsToBounds = true

        addSubview(imageView_Orna)
        addSubview(iconContainerView_Orna)
        addSubview(placeholderIconView_Orna)
        addSubview(playIconView_Orna)
        playIconView_Orna.addSubview(playIconImageView_Orna)

        imageView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        iconContainerView_Orna.snp.makeConstraints { $0.edges.equalToSuperview() }
        placeholderIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        playIconView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(60)
        }
        playIconImageView_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(28)
        }
    }

    // MARK: - 公共方法

    /// 直接展示 UIImage（相册选图后使用，无需路径）
    /// 参数：
    /// - image_Orna: 要展示的图片对象
    func configureWithImage_Orna(image_Orna: UIImage) {
        mediaType_Orna = .image_Orna
        clearOldContent_Orna()
        imageView_Orna.image = image_Orna
        placeholderIconView_Orna.isHidden = true
        playIconView_Orna.isHidden = true
    }

    /// 配置媒体展示
    /// 参数：
    /// - mediaPath_Orna: 媒体路径（nil 或空字符串时显示占位符）
    /// - isVideo_Orna: 是否为视频，默认 false
    func configure_Orna(mediaPath_Orna: String?, isVideo_Orna: Bool = false) {
        guard let path_Orna = mediaPath_Orna, !path_Orna.isEmpty else {
            showPlaceholder_Orna()
            return
        }
        mediaType_Orna = isVideo_Orna ? .video_Orna : .image_Orna
        playIconView_Orna.isHidden = !isVideo_Orna
        loadMedia_Orna(path_Orna: path_Orna, isVideo_Orna: isVideo_Orna)
    }

    // MARK: - 私有方法 - 媒体加载

    /// 按优先级依次尝试各来源加载媒体
    /// 说明：isVideo_Orna 为 true 时优先按视频来源解析（完整路径 / 文档目录 / Bundle），
    ///       避免被前置的图片类判断误吞
    private func loadMedia_Orna(path_Orna: String, isVideo_Orna: Bool) {
        if isVideo_Orna {
            loadVideoMedia_Orna(path_Orna: path_Orna)
            return
        }

        // 1. SF Symbols
        if let sysImg_Orna = UIImage(systemName: path_Orna) {
            loadSystemIcon_Orna(image_Orna: sysImg_Orna, path_Orna: path_Orna)
            return
        }

        // 2. Assets
        if let assetImg_Orna = UIImage(named: path_Orna) {
            loadImageSuccess_Orna(image_Orna: assetImg_Orna)
            return
        }

        // 3. 网络图片
        if path_Orna.hasPrefix("http://") || path_Orna.hasPrefix("https://") {
            loadNetworkImage_Orna(urlString_Orna: path_Orna)
            return
        }

        let docsDir_Orna = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // 4. 文档目录（文件名）
        let docFile_Orna = docsDir_Orna.appendingPathComponent(path_Orna)
        if let img_Orna = UIImage(contentsOfFile: docFile_Orna.path) {
            loadImageSuccess_Orna(image_Orna: img_Orna)
            print("✅ 从文档目录加载媒体: \(path_Orna)")
            return
        }

        // 5. 完整本地路径
        if let img_Orna = UIImage(contentsOfFile: path_Orna) {
            loadImageSuccess_Orna(image_Orna: img_Orna)
            return
        }

        // 6. 所有来源均失败
        print("⚠️ 无法加载媒体: \(path_Orna)")
        showPlaceholder_Orna()
    }

    /// 加载视频类媒体：依次尝试完整本地路径 / 文档目录（基础文件名+扩展名） / Bundle 资源
    private func loadVideoMedia_Orna(path_Orna: String) {
        // 1. 完整本地路径（如相册选择后复制到临时目录的视频）
        if FileManager.default.fileExists(atPath: path_Orna) {
            showVideoThumbnail_Orna(url_Orna: URL(fileURLWithPath: path_Orna))
            return
        }

        // 2. 文档目录（基础文件名，自动补全常见视频扩展名）
        let docsDir_Orna = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Orna in ["mp4", "mov", "m4v"] {
            let videoFile_Orna = docsDir_Orna.appendingPathComponent("\(path_Orna).\(ext_Orna)")
            if FileManager.default.fileExists(atPath: videoFile_Orna.path) {
                showVideoThumbnail_Orna(url_Orna: videoFile_Orna)
                return
            }
        }

        // 3. Bundle 内置视频资源
        if let url_Orna = Self.bundleVideoURL_Orna(named: path_Orna) {
            showVideoThumbnail_Orna(url_Orna: url_Orna)
            return
        }

        // 4. 所有来源均失败
        print("⚠️ 无法加载视频: \(path_Orna)")
        showPlaceholder_Orna()
    }

    /// 清理旧内容（图片、渐变图层、图标子视图）
    private func clearOldContent_Orna() {
        imageView_Orna.image = nil
        imageView_Orna.layer.sublayers?.removeAll()
        iconContainerView_Orna.subviews.forEach { $0.removeFromSuperview() }
    }

    /// 展示 SF Symbol 图标（带哈希选色渐变背景）
    private func loadSystemIcon_Orna(image_Orna: UIImage, path_Orna: String) {
        clearOldContent_Orna()

        let gradient_Orna = Self.gradientColors_Orna[abs(path_Orna.hashValue) % Self.gradientColors_Orna.count]
        addGradientLayer_Orna(colors_Orna: [gradient_Orna.0.cgColor, gradient_Orna.1.cgColor])

        let icon_Orna = UIImageView(image: image_Orna)
        icon_Orna.tintColor = .white
        icon_Orna.contentMode = .scaleAspectFit
        icon_Orna.alpha = 0.9
        iconContainerView_Orna.addSubview(icon_Orna)
        icon_Orna.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        placeholderIconView_Orna.isHidden = true
    }

    /// 使用 Kingfisher 加载网络图片
    private func loadNetworkImage_Orna(urlString_Orna: String) {
        clearOldContent_Orna()
        if let url_Orna = URL(string: urlString_Orna) {
            imageView_Orna.kf.setImage(
                with: url_Orna,
                placeholder: createPlaceholderImage_Orna(),
                options: [.transition(.fade(0.3))]
            )
        }
        placeholderIconView_Orna.isHidden = true
    }

    /// 图片加载成功后更新 imageView
    private func loadImageSuccess_Orna(image_Orna: UIImage) {
        clearOldContent_Orna()
        imageView_Orna.image = image_Orna
        placeholderIconView_Orna.isHidden = true
    }

    /// 设置视频类型状态并触发缩略图生成
    /// 参数：
    /// - url_Orna: 视频文件 URL
    private func showVideoThumbnail_Orna(url_Orna: URL) {
        mediaType_Orna = .video_Orna
        playIconView_Orna.isHidden = false
        generateVideoThumbnail_Orna(url_Orna: url_Orna)
    }

    /// 在 imageView 下方插入渐变图层
    private func addGradientLayer_Orna(colors_Orna: [CGColor]) {
        let layer_Orna = CAGradientLayer()
        layer_Orna.frame = bounds
        layer_Orna.colors = colors_Orna
        layer_Orna.startPoint = CGPoint(x: 0, y: 0)
        layer_Orna.endPoint = CGPoint(x: 1, y: 1)
        imageView_Orna.layer.insertSublayer(layer_Orna, at: 0)
    }

    /// 显示占位符状态（带渐变背景）
    private func showPlaceholder_Orna() {
        mediaType_Orna = .none_Orna
        clearOldContent_Orna()
        placeholderIconView_Orna.isHidden = !showsBuiltInPlaceholder_Orna
        playIconView_Orna.isHidden = true
        addGradientLayer_Orna(colors_Orna: Self.placeholderGradientColors_Orna)
    }

    /// 生成 Kingfisher 占位图（纯色背景块）
    private func createPlaceholderImage_Orna() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 100, height: 100), false, 0)
        UIColor(hexstring_Orna: "#F7FAFC").setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: 100, height: 100))
        let img_Orna = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img_Orna
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if mediaType_Orna == .none_Orna {
            imageView_Orna.layer.sublayers?.first?.frame = bounds
        }
    }

    // MARK: - 视频工具方法

    /// 在 Bundle 中查找视频文件（依次尝试 mp4 / mov / m4v）
    /// 参数：
    /// - named_Orna: 不含扩展名的资源名
    /// 返回值：找到时返回 URL，否则 nil
    static func bundleVideoURL_Orna(named named_Orna: String) -> URL? {
        ["mp4", "mov", "m4v"].lazy
            .compactMap { Bundle.main.url(forResource: named_Orna, withExtension: $0) }
            .first
    }

    /// 从视频 URL 异步提取第一帧作为缩略图
    /// 参数：
    /// - url_Orna: 视频文件 URL
    private func generateVideoThumbnail_Orna(url_Orna: URL) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let generator_Orna = AVAssetImageGenerator(asset: AVURLAsset(url: url_Orna))
            generator_Orna.appliesPreferredTrackTransform = true
            generator_Orna.maximumSize = CGSize(width: 600, height: 600)
            do {
                let cgImage_Orna = try generator_Orna.copyCGImage(
                    at: CMTime(seconds: 0.1, preferredTimescale: 600),
                    actualTime: nil
                )
                DispatchQueue.main.async {
                    self?.loadImageSuccess_Orna(image_Orna: UIImage(cgImage: cgImage_Orna))
                    self?.playIconView_Orna.isHidden = false
                }
            } catch {
                print("⚠️ 视频缩略图提取失败: \(error.localizedDescription)")
                DispatchQueue.main.async { self?.showPlaceholder_Orna() }
            }
        }
    }
}
