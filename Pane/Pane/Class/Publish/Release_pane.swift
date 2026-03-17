import UIKit
import SnapKit
import AVFoundation

// MARK: 发布页

// MARK: - 媒体预览区组件

/// 发布页媒体选择/预览区域
/// 核心作用：未选择时展示"窗框"占位引导，选中后展示图片/视频缩略图；
///          右上角提供 X 删除按钮，整体点击触发选取回调
/// 设计理念：虚线边框窗框隐喻 → 选中后切换为沉浸式预览卡片
class ReleaseMediaZoneView_Pane: UIView {

    // MARK: - 回调

    /// 点击选取媒体的回调
    var onPickTapped_Pane: (() -> Void)?
    /// 点击删除已选媒体的回调
    var onRemoveTapped_Pane: (() -> Void)?

    // MARK: - 状态

    private var hasMedia_Pane = false

    // MARK: - 占位状态 UI

    private let placeholderContainer_Pane: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    private let windowIconLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "🪟"
        l.font = .systemFont(ofSize: 46)
        l.textAlignment = .center
        return l
    }()

    private let placeholderTitle_Pane: UILabel = {
        let l = UILabel()
        l.text = "Frame Your View"
        l.font = .systemFont(ofSize: 16, weight: .bold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        l.textAlignment = .center
        return l
    }()

    private let placeholderSub_Pane: UILabel = {
        let l = UILabel()
        l.text = "Tap to add a photo or video"
        l.font = .systemFont(ofSize: 12)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        l.textAlignment = .center
        return l
    }()

    // MARK: - 预览状态 UI

    private let previewImageView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()

    /// 视频播放角标
    private let videoPlayBadge_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.alpha_Pane(0.5)
        v.layer.cornerRadius = 22
        v.isHidden = true
        let iv = UIImageView(image: UIImage(systemName: "play.fill"))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.tag = 99
        v.addSubview(iv)
        iv.snp.makeConstraints { $0.center.equalToSuperview(); $0.width.height.equalTo(20) }
        return v
    }()

    /// 删除按钮（预览时右上角）
    private let removeButton_Pane: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
        b.tintColor = .white
        b.backgroundColor = UIColor.black.alpha_Pane(0.55)
        b.layer.cornerRadius = 14
        b.isHidden = true
        return b
    }()

    // MARK: - 虚线边框层

    private var dashedBorderLayer_Pane: CAShapeLayer?

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped_Pane)))
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateDashedBorder_Pane()
    }

    // MARK: - UI 布局

    private func setupUI_Pane() {
        backgroundColor = ColorConfig_Pane.backgroundSecondary_Pane
        layer.cornerRadius = 20
        clipsToBounds = true

        // 预览图层（底层）
        addSubview(previewImageView_Pane)
        previewImageView_Pane.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 视频角标
        addSubview(videoPlayBadge_Pane)
        videoPlayBadge_Pane.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(44)
        }

        // 占位内容（中央）
        addSubview(placeholderContainer_Pane)
        placeholderContainer_Pane.addSubview(windowIconLabel_Pane)
        placeholderContainer_Pane.addSubview(placeholderTitle_Pane)
        placeholderContainer_Pane.addSubview(placeholderSub_Pane)
        placeholderContainer_Pane.snp.makeConstraints { $0.center.equalToSuperview() }
        windowIconLabel_Pane.snp.makeConstraints {
            $0.top.centerX.equalToSuperview()
        }
        placeholderTitle_Pane.snp.makeConstraints {
            $0.top.equalTo(windowIconLabel_Pane.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        placeholderSub_Pane.snp.makeConstraints {
            $0.top.equalTo(placeholderTitle_Pane.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        // 删除按钮（右上角，预览时显示）
        addSubview(removeButton_Pane)
        removeButton_Pane.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(10)
            $0.width.height.equalTo(28)
        }
        removeButton_Pane.addTarget(self, action: #selector(removeTapped_Pane), for: .touchUpInside)
    }

    /// 绘制虚线边框（仅占位状态下可见）
    private func updateDashedBorder_Pane() {
        dashedBorderLayer_Pane?.removeFromSuperlayer()
        guard !hasMedia_Pane else { return }

        let shape = CAShapeLayer()
        shape.strokeColor = ColorConfig_Pane.border_Pane.cgColor
        shape.fillColor   = UIColor.clear.cgColor
        shape.lineWidth   = 1.5
        shape.lineDashPattern = [6, 4]
        shape.path        = UIBezierPath(roundedRect: bounds, cornerRadius: 20).cgPath
        layer.addSublayer(shape)
        dashedBorderLayer_Pane = shape
    }

    // MARK: - 公开方法

    /// 展示选中的图片预览
    /// - Parameter image_pane: 用户从相册选取的 UIImage
    func showImagePreview_Pane(image_pane: UIImage) {
        hasMedia_Pane = true
        previewImageView_Pane.image = image_pane
        previewImageView_Pane.isHidden = false
        videoPlayBadge_Pane.isHidden  = true
        placeholderContainer_Pane.isHidden = true
        removeButton_Pane.isHidden = false
        dashedBorderLayer_Pane?.removeFromSuperlayer()
        // 入场动画
        previewImageView_Pane.alpha = 0
        UIView.animate(withDuration: 0.3) { self.previewImageView_Pane.alpha = 1 }
    }

    /// 展示选中的视频缩略图
    /// - Parameter url_pane: 视频文件 URL
    func showVideoPreview_Pane(url_pane: URL) {
        hasMedia_Pane = true
        let thumb_pane = generateVideoThumbnail_Pane(url_pane: url_pane)
        previewImageView_Pane.image   = thumb_pane
        previewImageView_Pane.isHidden = false
        videoPlayBadge_Pane.isHidden   = false
        placeholderContainer_Pane.isHidden = true
        removeButton_Pane.isHidden = false
        dashedBorderLayer_Pane?.removeFromSuperlayer()
        previewImageView_Pane.alpha = 0
        UIView.animate(withDuration: 0.3) { self.previewImageView_Pane.alpha = 1 }
    }

    /// 重置为占位状态
    func resetToPlaceholder_Pane() {
        hasMedia_Pane = false
        previewImageView_Pane.image   = nil
        previewImageView_Pane.isHidden = true
        videoPlayBadge_Pane.isHidden   = true
        placeholderContainer_Pane.isHidden = false
        removeButton_Pane.isHidden = true
        setNeedsLayout()
    }

    // MARK: - 私有方法

    /// 生成视频缩略图（取第一帧）
    private func generateVideoThumbnail_Pane(url_pane: URL) -> UIImage? {
        let asset_pane    = AVAsset(url: url_pane)
        let generator_pane = AVAssetImageGenerator(asset: asset_pane)
        generator_pane.appliesPreferredTrackTransform = true
        let time_pane = CMTime(seconds: 0, preferredTimescale: 1)
        guard let cgImg_pane = try? generator_pane.copyCGImage(at: time_pane, actualTime: nil)
        else { return nil }
        return UIImage(cgImage: cgImg_pane)
    }

    @objc private func viewTapped_Pane() {
        onPickTapped_Pane?()
    }

    @objc private func removeTapped_Pane() {
        onRemoveTapped_Pane?()
    }
}

// MARK: - 发布页主视图控制器

/// 发布页面
/// 核心作用：提供标题、内容、媒体的输入表单；发布前验证登录状态及字段完整性；
///          发布成功后清空表单并关闭页面
/// 设计理念：窗框隐喻 + 渐变头部 + 分区卡片式输入 + 主题胶囊
/// 关键方法：
///   - validateAndPublish_Pane(): 校验 + 发布 + 清空
///   - clearForm_Pane():          发布成功后清空所有输入
class Release_Pane: UIViewController {

    // MARK: - 常量

    /// 内容占位符文本
    private let contentPlaceholder_Pane = "Describe what you see through your window today..."
    /// 标题最大字符数
    private let titleMaxLength_Pane = 40

    // MARK: - 数据状态

    /// 已选媒体的存储路径（传递给 ViewModel）
    private var selectedMediaPath_Pane: String?
    /// 已选图片（用于预览，不直接传递）
    private var selectedImage_Pane: UIImage?
    /// 已选视频 URL
    private var selectedVideoURL_Pane: URL?

    // MARK: - UI 组件：头部

    /// 渐变头部容器
    private let headerView_Pane: UIView = {
        let v = UIView()
        v.clipsToBounds = false
        return v
    }()

    private let headerTitleLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "New Window"
        l.font = UIFont(name: "Georgia-Bold", size: 22) ?? .systemFont(ofSize: 22, weight: .black)
        l.textColor = ColorConfig_Pane.textPrimary_Pane
        l.textAlignment = .center
        return l
    }()

    private let headerSubLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "Share your view with the world"
        l.font = .systemFont(ofSize: 11, weight: .medium)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        l.textAlignment = .center
        return l
    }()

    // MARK: - UI 组件：滚动区域

    private let scrollView_Pane: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .interactive
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentContainer_Pane: UIView = UIView()

    // MARK: - UI 组件：媒体区域

    private let mediaZoneView_Pane = ReleaseMediaZoneView_Pane()

    // MARK: - UI 组件：标题输入卡片

    private let titleCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius = 16
        v.layer.shadowColor  = ColorConfig_Pane.shadowColor_Pane.cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 3)
        v.layer.shadowRadius  = 8
        v.layer.masksToBounds = false
        return v
    }()

    private let titleIconLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "✏️"
        l.font = .systemFont(ofSize: 18)
        return l
    }()

    private let titleField_Pane: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Give your window a title..."
        tf.font        = .systemFont(ofSize: 15, weight: .semibold)
        tf.textColor   = ColorConfig_Pane.textPrimary_Pane
        tf.returnKeyType = .next
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    /// 标题字数计数标签
    private let titleCountLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "0/40"
        l.font = .systemFont(ofSize: 10)
        l.textColor = ColorConfig_Pane.textPlaceholder_Pane
        return l
    }()

    // MARK: - UI 组件：内容输入卡片

    private let contentCard_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.cardBackground_Pane
        v.layer.cornerRadius = 16
        v.layer.shadowColor  = ColorConfig_Pane.shadowColor_Pane.cgColor
        v.layer.shadowOpacity = 1
        v.layer.shadowOffset  = CGSize(width: 0, height: 3)
        v.layer.shadowRadius  = 8
        v.layer.masksToBounds = false
        return v
    }()

    private let contentIconLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "💬"
        l.font = .systemFont(ofSize: 16)
        return l
    }()

    private let contentTextView_Pane: UITextView = {
        let tv = UITextView()
        tv.font          = .systemFont(ofSize: 14)
        tv.textColor     = ColorConfig_Pane.textPlaceholder_Pane
        tv.backgroundColor = .clear
        tv.showsVerticalScrollIndicator = false
        tv.isScrollEnabled = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.returnKeyType = .default
        return tv
    }()

    // MARK: - UI 组件：主题标签区

    private let themeSectionLabel_Pane: UILabel = {
        let l = UILabel()
        l.text = "🏷️  Theme  (optional)"
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = ColorConfig_Pane.textSecondary_Pane
        return l
    }()

    /// 预设主题标签数据
    private let themeOptions_Pane = [
        "🌅 Sunrise", "🌆 Cityscape", "🌿 Nature",
        "🌧️ Rainy Day", "🌃 Nightscape", "🏔️ Mountains",
        "🌊 Ocean", "🌸 Bloom", "☁️ Clouds"
    ]

    private var selectedTheme_Pane: String = ""
    private var themeChipButtons_Pane: [UIButton] = []

    private let themeScrollView_Pane: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator   = false
        return sv
    }()

    private let themeChipsContainer_Pane = UIView()

    // MARK: - UI 组件：发布按钮（底部悬浮）

    private let publishBarView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        return v
    }()

    private let publishButton_Pane: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("✦  Publish Window", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 26
        b.layer.masksToBounds = false
        b.layer.shadowColor   = UIColor(hexstring_Pane: "#B794F6").alpha_Pane(0.4).cgColor
        b.layer.shadowOpacity = 1
        b.layer.shadowOffset  = CGSize(width: 0, height: 6)
        b.layer.shadowRadius  = 14
        return b
    }()

    private var publishButtonGradient_Pane: CAGradientLayer?

    /// EULA 协议富文本标签（发布按钮下方 10pt）
    private var eulaLabel_Pane: UILabel = UILabel()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView_Pane()
        setupHeader_Pane()
        setupScrollContent_Pane()
        setupPublishBar_Pane()
        setupInteractions_Pane()
        setupKeyboardObservers_Pane()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        publishButtonGradient_Pane?.frame = publishButton_Pane.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 发布页使用自定义头部，隐藏系统导航栏
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 离开发布页时恢复导航栏，确保跳转的子页面（如 EULA 协议页）能正常显示导航栏和返回按钮
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 初始化

    private func setupView_Pane() {
        view.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
    }

    /// 构建顶部头部区域（标题 + 副标题 + 底部分割线，背景与页面一致无色差）
    private func setupHeader_Pane() {
        view.addSubview(headerView_Pane)
        headerView_Pane.backgroundColor = ColorConfig_Pane.backgroundPrimary_Pane
        headerView_Pane.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            // 使用 safeAreaLayoutGuide 而非 safeAreaInsets，避免 viewDidLoad 时 insets 为 0 导致头部高度不足被遮盖
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
        }

        // 标题 + 副标题
        headerView_Pane.addSubview(headerTitleLabel_Pane)
        headerView_Pane.addSubview(headerSubLabel_Pane)
        headerTitleLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(14)
            $0.centerX.equalToSuperview()
        }
        headerSubLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(headerTitleLabel_Pane.snp.bottom).offset(3)
            $0.centerX.equalToSuperview()
        }

        // 底部分割线
        let sep = UIView()
        sep.backgroundColor = ColorConfig_Pane.divider_Pane
        headerView_Pane.addSubview(sep)
        sep.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }

    /// 构建滚动内容区域
    private func setupScrollContent_Pane() {
        view.addSubview(scrollView_Pane)
        scrollView_Pane.snp.makeConstraints {
            $0.top.equalTo(headerView_Pane.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-120)
        }

        scrollView_Pane.addSubview(contentContainer_Pane)
        contentContainer_Pane.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView_Pane)
        }

        setupMediaZone_Pane()
        setupTitleCard_Pane()
        setupContentCard_Pane()
        setupThemeSection_Pane()

        // 底部留白
        let spacer = UIView()
        contentContainer_Pane.addSubview(spacer)
        spacer.snp.makeConstraints {
            $0.top.equalTo(themeScrollView_Pane.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(20)
        }
    }

    /// 媒体选取区域
    private func setupMediaZone_Pane() {
        contentContainer_Pane.addSubview(mediaZoneView_Pane)
        mediaZoneView_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(220)
        }
        mediaZoneView_Pane.onPickTapped_Pane   = { [weak self] in self?.pickMedia_Pane() }
        mediaZoneView_Pane.onRemoveTapped_Pane = { [weak self] in self?.removeMedia_Pane() }
    }

    /// 标题输入卡片
    private func setupTitleCard_Pane() {
        contentContainer_Pane.addSubview(titleCard_Pane)
        titleCard_Pane.snp.makeConstraints {
            $0.top.equalTo(mediaZoneView_Pane.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(56)
        }

        titleCard_Pane.addSubview(titleIconLabel_Pane)
        titleCard_Pane.addSubview(titleField_Pane)
        titleCard_Pane.addSubview(titleCountLabel_Pane)

        titleIconLabel_Pane.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(26)
        }
        titleCountLabel_Pane.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
        titleField_Pane.snp.makeConstraints {
            $0.leading.equalTo(titleIconLabel_Pane.snp.trailing).offset(8)
            $0.trailing.equalTo(titleCountLabel_Pane.snp.leading).offset(-6)
            $0.centerY.equalToSuperview()
        }
    }

    /// 内容输入卡片
    private func setupContentCard_Pane() {
        contentContainer_Pane.addSubview(contentCard_Pane)
        contentCard_Pane.snp.makeConstraints {
            $0.top.equalTo(titleCard_Pane.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        contentCard_Pane.addSubview(contentIconLabel_Pane)
        contentCard_Pane.addSubview(contentTextView_Pane)

        contentIconLabel_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(14)
            $0.width.equalTo(24)
        }
        contentTextView_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalTo(contentIconLabel_Pane.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(12)
            $0.height.greaterThanOrEqualTo(90)
        }

        // 初始化占位符
        contentTextView_Pane.text = contentPlaceholder_Pane
    }

    /// 主题标签行
    private func setupThemeSection_Pane() {
        contentContainer_Pane.addSubview(themeSectionLabel_Pane)
        contentContainer_Pane.addSubview(themeScrollView_Pane)

        themeSectionLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(contentCard_Pane.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(18)
        }

        themeScrollView_Pane.addSubview(themeChipsContainer_Pane)
        themeChipsContainer_Pane.snp.makeConstraints { $0.edges.height.equalToSuperview() }

        themeScrollView_Pane.snp.makeConstraints {
            $0.top.equalTo(themeSectionLabel_Pane.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(36)
        }

        // 动态生成胶囊按钮
        var prevButton_pane: UIButton? = nil
        for (i_pane, theme_pane) in themeOptions_Pane.enumerated() {
            let btn_pane = buildThemeChip_Pane(title_pane: theme_pane)
            btn_pane.tag = i_pane
            themeChipsContainer_Pane.addSubview(btn_pane)
            btn_pane.snp.makeConstraints {
                $0.centerY.equalToSuperview()
                $0.height.equalTo(32)
                if let prev = prevButton_pane {
                    $0.leading.equalTo(prev.snp.trailing).offset(8)
                } else {
                    $0.leading.equalToSuperview().offset(16)
                }
                if i_pane == themeOptions_Pane.count - 1 {
                    $0.trailing.equalToSuperview().inset(16)
                }
            }
            themeChipButtons_Pane.append(btn_pane)
            prevButton_pane = btn_pane
        }
    }

    /// 构建单个主题胶囊按钮
    private func buildThemeChip_Pane(title_pane: String) -> UIButton {
        let b = UIButton(type: .custom)
        b.setTitle(title_pane, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 12, weight: .medium)
        b.setTitleColor(ColorConfig_Pane.textSecondary_Pane, for: .normal)
        b.backgroundColor = ColorConfig_Pane.backgroundSecondary_Pane
        b.layer.cornerRadius = 14
        b.layer.borderWidth  = 1
        b.layer.borderColor  = ColorConfig_Pane.border_Pane.cgColor
        b.contentEdgeInsets  = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        b.addTarget(self, action: #selector(themeChipTapped_Pane(_:)), for: .touchUpInside)
        return b
    }

    /// 构建底部发布按钮栏（按钮距底部 120pt，无顶部阴影遮罩）
    private func setupPublishBar_Pane() {
        view.addSubview(publishBarView_Pane)
        publishBarView_Pane.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-200)
        }

        publishBarView_Pane.addSubview(publishButton_Pane)
        publishButton_Pane.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        publishButton_Pane.addTarget(self, action: #selector(publishTapped_Pane), for: .touchUpInside)

        // 按钮渐变背景
        let gl = CAGradientLayer()
        gl.colors = [
            ColorConfig_Pane.primaryGradientStart_Pane.cgColor,
            ColorConfig_Pane.primaryGradientEnd_Pane.cgColor
        ]
        gl.startPoint    = CGPoint(x: 0, y: 0)
        gl.endPoint      = CGPoint(x: 1, y: 1)
        gl.cornerRadius  = 26
        publishButton_Pane.layer.insertSublayer(gl, at: 0)
        publishButtonGradient_Pane = gl

        // EULA 协议标签（发布按钮下方 10pt，点击展示本地 eula.png）
        eulaLabel_Pane.attributedText = NSAttributedString(
            string: "EULA",
            attributes: [
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                .foregroundColor: ColorConfig_Pane.primaryGradientStart_Pane,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: ColorConfig_Pane.primaryGradientStart_Pane
            ]
        )
        eulaLabel_Pane.textAlignment        = .center
        eulaLabel_Pane.isUserInteractionEnabled = true
        eulaLabel_Pane.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(eulaTapped_Pane))
        )
        publishBarView_Pane.addSubview(eulaLabel_Pane)
        eulaLabel_Pane.snp.makeConstraints {
            $0.top.equalTo(publishButton_Pane.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(22)
        }
    }

    /// 点击 EULA 标签：展示本地协议图片（eula.png）
    @objc private func eulaTapped_Pane() {
        ProtocolHelper_Pane.showProtocol_Pane(
            type_Pane: .eula_Pane,
            content_Pane: "eula.png",
            from: self
        )
    }

    /// 绑定所有交互事件
    private func setupInteractions_Pane() {
        titleField_Pane.delegate = self
        contentTextView_Pane.delegate = self
        titleField_Pane.addTarget(self, action: #selector(titleDidChange_Pane), for: .editingChanged)

        // 点击空白收键盘
        let tap_pane = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Pane))
        tap_pane.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_pane)
    }

    // MARK: - 键盘处理

    private func setupKeyboardObservers_Pane() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Pane(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Pane(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func keyboardWillShow_Pane(_ notification: Notification) {
        guard let kbFrame_pane = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_pane = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        let bottom_pane = kbFrame_pane.height - view.safeAreaInsets.bottom
        scrollView_Pane.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-(bottom_pane + 120))
        }
        UIView.animate(withDuration: duration_pane) { self.view.layoutIfNeeded() }
    }

    @objc private func keyboardWillHide_Pane(_ notification: Notification) {
        guard let duration_pane = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        scrollView_Pane.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-120)
        }
        UIView.animate(withDuration: duration_pane) { self.view.layoutIfNeeded() }
    }

    @objc private func dismissKeyboard_Pane() {
        view.endEditing(true)
    }

    // MARK: - 事件处理

    @objc private func titleDidChange_Pane() {
        let text_pane = titleField_Pane.text ?? ""
        titleCountLabel_Pane.text = "\(text_pane.count)/\(titleMaxLength_Pane)"
        titleCountLabel_Pane.textColor = text_pane.count >= titleMaxLength_Pane
            ? UIColor(hexstring_Pane: "#E07060")
            : ColorConfig_Pane.textPlaceholder_Pane
    }

    @objc private func themeChipTapped_Pane(_ sender: UIButton) {
        let theme_pane = themeOptions_Pane[sender.tag]
        // 切换选中状态
        if selectedTheme_Pane == theme_pane {
            selectedTheme_Pane = ""
            resetChip_Pane(sender)
        } else {
            // 先重置所有胶囊
            themeChipButtons_Pane.forEach { resetChip_Pane($0) }
            selectedTheme_Pane = theme_pane
            activateChip_Pane(sender)
        }
    }

    @objc private func publishTapped_Pane() {
        view.endEditing(true)
        validateAndPublish_Pane()
    }

    // MARK: - 胶囊选中/重置样式

    private func activateChip_Pane(_ button_pane: UIButton) {
        UIView.animate(withDuration: 0.2) {
            button_pane.backgroundColor = ColorConfig_Pane.primaryGradientStart_Pane.alpha_Pane(0.15)
            button_pane.setTitleColor(ColorConfig_Pane.primaryGradientStart_Pane, for: .normal)
            button_pane.layer.borderColor = ColorConfig_Pane.primaryGradientStart_Pane.cgColor
            button_pane.transform = CGAffineTransform(scaleX: 1.06, y: 1.06)
        }
    }

    private func resetChip_Pane(_ button_pane: UIButton) {
        UIView.animate(withDuration: 0.2) {
            button_pane.backgroundColor = ColorConfig_Pane.backgroundSecondary_Pane
            button_pane.setTitleColor(ColorConfig_Pane.textSecondary_Pane, for: .normal)
            button_pane.layer.borderColor = ColorConfig_Pane.border_Pane.cgColor
            button_pane.transform = .identity
        }
    }

    // MARK: - 媒体选取

    /// 调起相册媒体选择器（图片或视频）
    private func pickMedia_Pane() {
        MediaPickerHelper_Pane.shared_Pane.showPicker_Pane(
            from: self,
            mediaType_Pane: .photoAndVideo_Pane
        ) { [weak self] result_pane in
            guard let self = self else { return }
            switch result_pane {
            case .photo_Pane(let image_pane):
                self.handlePickedImage_Pane(image_pane: image_pane)
            case .video_Pane(let url_pane):
                self.handlePickedVideo_Pane(url_pane: url_pane)
            case .cancelled_Pane:
                break
            }
        }
    }

    /// 处理已选图片：保存到临时目录并更新预览
    /// - Parameter image_pane: 用户选取的 UIImage
    private func handlePickedImage_Pane(image_pane: UIImage) {
        selectedImage_Pane    = image_pane
        selectedVideoURL_Pane = nil
        // 将图片保存为临时 JPEG 文件，路径传递给 ViewModel
        selectedMediaPath_Pane = saveImageToTemp_Pane(image_pane: image_pane)
        mediaZoneView_Pane.showImagePreview_Pane(image_pane: image_pane)
    }

    /// 处理已选视频：记录 URL 并更新预览
    /// - Parameter url_pane: 视频临时文件 URL（由 MediaPickerHelper 已复制）
    private func handlePickedVideo_Pane(url_pane: URL) {
        selectedVideoURL_Pane  = url_pane
        selectedImage_Pane     = nil
        selectedMediaPath_Pane = url_pane.path
        mediaZoneView_Pane.showVideoPreview_Pane(url_pane: url_pane)
    }

    /// 删除已选媒体，恢复占位状态
    private func removeMedia_Pane() {
        selectedMediaPath_Pane = nil
        selectedImage_Pane     = nil
        selectedVideoURL_Pane  = nil
        mediaZoneView_Pane.resetToPlaceholder_Pane()
    }

    /// 将 UIImage 保存为 JPEG 临时文件
    /// - Parameter image_pane: 需要保存的图片
    /// - Returns: 临时文件路径；保存失败时返回 nil
    private func saveImageToTemp_Pane(image_pane: UIImage) -> String? {
        guard let data_pane = image_pane.jpegData(compressionQuality: 0.85) else { return nil }
        let fileName_pane = "release_img_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_pane = FileManager.default.temporaryDirectory.appendingPathComponent(fileName_pane)
        do {
            try data_pane.write(to: url_pane)
            return url_pane.path
        } catch {
            print("❌ 保存图片到临时目录失败: \(error)")
            return nil
        }
    }

    // MARK: - 校验与发布

    /// 校验所有输入项后执行发布；失败时给出对应提示并执行震动反馈
    private func validateAndPublish_Pane() {
        // ── 1. 登录检查 ──
        guard UserViewModel_Pane.shared_Pane.isLoggedIn_Pane else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                Navigation_Pane.toLogin_Pane(style_pane: .present_pane)
            }
            return
        }

        // ── 2. 标题非空 ──
        let title_pane = titleField_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title_pane.isEmpty else {
            Utils_Pane.showWarning_Pane(message_Pane: "Please enter a title.")
            shakeView_Pane(view: titleCard_Pane)
            titleField_Pane.becomeFirstResponder()
            return
        }

        // ── 3. 内容非空 ──
        let content_pane = contentTextView_Pane.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !content_pane.isEmpty, content_pane != contentPlaceholder_Pane else {
            Utils_Pane.showWarning_Pane(message_Pane: "Please describe what you see.")
            shakeView_Pane(view: contentCard_Pane)
            contentTextView_Pane.becomeFirstResponder()
            return
        }

        // ── 4. 媒体非空 ──
        guard let mediaPath_pane = selectedMediaPath_Pane else {
            Utils_Pane.showWarning_Pane(message_Pane: "Please add a photo or video.")
            shakeView_Pane(view: mediaZoneView_Pane)
            return
        }

        // ── 5. 调用 ViewModel 发布 ──
        // 从主题胶囊文字中去除 emoji 前缀获取纯主题词
        let themePure_pane = selectedTheme_Pane
            .components(separatedBy: " ")
            .dropFirst()
            .joined(separator: " ")

        // 按钮禁用防止重复点击
        publishButton_Pane.isUserInteractionEnabled = false
        TitleViewModel_Pane.shared_Pane.releasePost_Pane(
            title_pane: title_pane,
            content_pane: content_pane,
            media_pane: mediaPath_pane,
            theme_pane: themePure_pane
        )

        // ── 6. 清空表单 + 关闭页面 ──
        clearForm_Pane()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            Navigation_Pane.dismiss_Pane(from: self)
        }
    }

    /// 发布成功后清空页面所有输入状态
    private func clearForm_Pane() {
        titleField_Pane.text          = ""
        contentTextView_Pane.text     = contentPlaceholder_Pane
        contentTextView_Pane.textColor = ColorConfig_Pane.textPlaceholder_Pane
        titleCountLabel_Pane.text     = "0/\(titleMaxLength_Pane)"
        selectedTheme_Pane            = ""
        themeChipButtons_Pane.forEach { resetChip_Pane($0) }
        removeMedia_Pane()
        publishButton_Pane.isUserInteractionEnabled = true
    }

    // MARK: - 辅助动画

    /// 对目标视图执行水平震动动画（校验失败时的错误反馈）
    /// - Parameter view: 需要震动的视图
    private func shakeView_Pane(view: UIView) {
        let animation_pane = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation_pane.timingFunction = CAMediaTimingFunction(name: .linear)
        animation_pane.duration  = 0.4
        animation_pane.values    = [-10, 10, -8, 8, -5, 5, 0]
        view.layer.add(animation_pane, forKey: "shake_pane")
    }
}

// MARK: - UITextFieldDelegate

extension Release_Pane: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard textField == titleField_Pane else { return true }
        let current_pane = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        return current_pane.count <= titleMaxLength_Pane
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Pane.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension Release_Pane: UITextViewDelegate {

    /// 开始编辑时清除占位符
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == contentPlaceholder_Pane {
            textView.text      = ""
            textView.textColor = ColorConfig_Pane.textPrimary_Pane
        }
    }

    /// 结束编辑时若为空则恢复占位符
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text      = contentPlaceholder_Pane
            textView.textColor = ColorConfig_Pane.textPlaceholder_Pane
        }
    }

    /// 内容变化时更新 scrollView 布局（适配多行高度）
    func textViewDidChange(_ textView: UITextView) {
        let size_pane = textView.sizeThatFits(
            CGSize(width: textView.frame.width, height: .greatestFiniteMagnitude)
        )
        if textView.frame.height != size_pane.height {
            UIView.animate(withDuration: 0.18) { self.view.layoutIfNeeded() }
        }
    }
}
