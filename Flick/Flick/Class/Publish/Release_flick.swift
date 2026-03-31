import Foundation
import UIKit
import SnapKit
import AVFoundation

// MARK: - 发布页面

/// 发布帖子页面
/// 核心功能：渐变装饰顶部 Banner + 步骤指示器 + 卡片表单（标题/内容/媒体）+ 渐变发布按钮 + EULA 链接
/// 设计思路：
///   顶部 - 与 Discover/MessageList 风格统一的紫蓝渐变 Banner + 步骤 Pill 指示当前进度
///   表单 - 三张圆角卡片，各带彩色图标、字符计数、交互焦点高亮
///   媒体 - 虚线渐变边框选区，选中后显示预览 + 媒体类型徽章
///   发布 - 渐变按钮 + 光晕阴影 + 点击弹性动画 + EULA 下划线链接
/// 关键属性：
///   - selectedImage_Flick: 选中的图片（UI 暂存）
///   - selectedVideoURL_Flick: 选中的视频 URL（UI 暂存）
///   - selectedMediaPath_Flick: 传给 ViewModel 的路径字符串
class Release_Flick: UIViewController {

    // MARK: - UI 暂存状态

    private var selectedImage_Flick: UIImage?
    private var selectedVideoURL_Flick: URL?
    private var selectedMediaPath_Flick: String = ""

    // MARK: - 顶部渐变 Banner

    private let topBannerView_Flick: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var bannerGradientLayer_Flick: CAGradientLayer?

    /// 装饰大圆（左上）
    private let decorCircle1_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.07)
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰中圆（右侧）
    private let decorCircle2_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withValues(alpha: 0.05)
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 装饰星形
    private let decorStar_Flick: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = UIColor.white.withValues(alpha: 0.15)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// 装饰闪光
    private let decorSparkle_Flick: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "sparkles"))
        iv.tintColor = UIColor.white.withValues(alpha: 0.2)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    /// 页面主标题
    private let bannerTitleLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "New Post"
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        label.textColor = .white
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOpacity = 0.15
        label.layer.shadowRadius = 4
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        return label
    }()

    /// 副标题
    private let bannerSubtitleLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "✦  Share your story with the world"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = UIColor.white.withValues(alpha: 0.8)
        return label
    }()

    // MARK: - 步骤指示器（3 步 Pill）

    /// 步骤指示容器
    private let stepsContainer_Flick: UIView = UIView()

    private let stepLabels_Flick: [String] = ["Title", "Content", "Media"]
    private var stepPills_Flick: [UIView] = []
    private var stepGradients_Flick: [CAGradientLayer] = []
    private var stepTextLabels_Flick: [UILabel] = []

    // MARK: - 滚动表单

    private let scrollView_Flick: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentStack_Flick: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        return stack
    }()

    // MARK: - 标题卡片

    private let titleCard_Flick = ReleaseFormCard_Flick.make()

    private let titleIconView_Flick: UIView = makeIconBadge_Flick(
        systemName: "pencil.line",
        bgColor: ColorConfig_Flick.primaryGradientStart_Flick
    )

    private let titleField_Flick: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Post title..."
        tf.font = .systemFont(ofSize: 16, weight: .medium)
        tf.textColor = ColorConfig_Flick.textPrimary_Flick
        tf.clearButtonMode = .whileEditing
        return tf
    }()

    private let titleCountLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "0/50"
        label.font = .systemFont(ofSize: 11)
        label.textColor = ColorConfig_Flick.textPlaceholder_Flick
        return label
    }()

    private let titleSeparator_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.divider_Flick
        return v
    }()

    // MARK: - 内容卡片

    private let contentCard_Flick = ReleaseFormCard_Flick.make()

    private let contentIconView_Flick: UIView = makeIconBadge_Flick(
        systemName: "text.alignleft",
        bgColor: ColorConfig_Flick.secondaryGradientStart_Flick
    )

    private let contentTextView_Flick: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 15)
        tv.textColor = ColorConfig_Flick.textPrimary_Flick
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.isScrollEnabled = false
        return tv
    }()

    private let contentPlaceholderLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "What's on your mind?"
        label.font = .systemFont(ofSize: 15)
        label.textColor = ColorConfig_Flick.textPlaceholder_Flick
        label.numberOfLines = 0
        return label
    }()

    private let contentCountLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "0/300"
        label.font = .systemFont(ofSize: 11)
        label.textColor = ColorConfig_Flick.textPlaceholder_Flick
        label.textAlignment = .right
        return label
    }()

    // MARK: - 媒体选择卡片

    private let mediaCard_Flick = ReleaseFormCard_Flick.make()

    private let mediaIconView_Flick: UIView = makeIconBadge_Flick(
        systemName: "photo.on.rectangle.angled",
        bgColor: UIColor(hexstring_Flick: "#F6AD55")
    )

    private let mediaTitleLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "Media"
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = ColorConfig_Flick.textPrimary_Flick
        return label
    }()

    private let mediaSubtitleLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "Photo or Video"
        label.font = .systemFont(ofSize: 12)
        label.textColor = ColorConfig_Flick.textSecondary_Flick
        return label
    }()

    /// 虚线渐变选择区域
    private let mediaPickerArea_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let mediaPickerDashedBorder_Flick = CAShapeLayer()

    private let mediaPickerIcon_Flick: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        iv.image = UIImage(systemName: "plus.circle.dashed", withConfiguration: config)
        iv.tintColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.5)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let mediaPickerHintLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "Tap to add photo or video"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.7)
        label.textAlignment = .center
        return label
    }()

    private let mediaPickerSubHintLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "JPG, PNG, MOV, MP4 supported"
        label.font = .systemFont(ofSize: 11)
        label.textColor = ColorConfig_Flick.textPlaceholder_Flick
        label.textAlignment = .center
        return label
    }()

    /// 媒体预览容器（选中后显示）
    private let mediaPreviewContainer_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        v.isHidden = true
        return v
    }()

    private let previewImageView_Flick: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()

    private let previewVideoThumbView_Flick: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()

    private let videoPlayIconView_Flick: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 52, weight: .bold)
        iv.image = UIImage(systemName: "play.circle.fill", withConfiguration: config)
        iv.tintColor = .white
        iv.isHidden = true
        return iv
    }()

    /// 媒体类型徽章（"Photo" / "Video"）
    private let mediaBadge_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withValues(alpha: 0.5)
        v.layer.cornerRadius = 10
        v.isHidden = true
        return v
    }()

    private let mediaBadgeLabel_Flick: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .bold)
        label.textColor = .white
        return label
    }()

    /// 移除媒体按钮
    private let removeMediaButton_Flick: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withValues(alpha: 0.3)
        btn.layer.cornerRadius = 16
        btn.isHidden = true
        return btn
    }()

    // MARK: - 发布按钮区域

    private let publishButton_Flick: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Publish Post", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn.layer.cornerRadius = 26
        btn.layer.cornerCurve = .continuous
        btn.layer.masksToBounds = false
        return btn
    }()

    private let publishGradientLayer_Flick = CAGradientLayer()

    /// 发布按钮下方的小闪光装饰
    private let publishDecorLabel_Flick: UILabel = {
        let label = UILabel()
        label.text = "✨  Your post will be visible to everyone"
        label.font = .systemFont(ofSize: 12)
        label.textColor = ColorConfig_Flick.textPlaceholder_Flick
        label.textAlignment = .center
        return label
    }()

    /// EULA 带下划线按钮
    private let eulaButton_Flick: UIButton = {
        let btn = UIButton(type: .system)
        let attrs: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: ColorConfig_Flick.textSecondary_Flick,
            .font: UIFont.systemFont(ofSize: 13)
        ]
        btn.setAttributedTitle(
            NSAttributedString(string: "EULA", attributes: attrs),
            for: .normal
        )
        return btn
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Flick()
        setupConstraints_Flick()
        setupActions_Flick()
        setupKeyboardDismiss_Flick()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBannerGradient_Flick()
        updateDecorLayout_Flick()
        updatePublishGradient_Flick()
        updateMediaPickerDashedBorder_Flick()
        updateStepGradients_Flick()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBannerEntrance_Flick()
    }

    // MARK: - UI 搭建

    private func setupUI_Flick() {
        view.backgroundColor = ColorConfig_Flick.backgroundPrimary_Flick

        // 渐变顶部 Banner
        view.addSubview(topBannerView_Flick)
        topBannerView_Flick.addSubview(decorCircle1_Flick)
        topBannerView_Flick.addSubview(decorCircle2_Flick)
        topBannerView_Flick.addSubview(decorStar_Flick)
        topBannerView_Flick.addSubview(decorSparkle_Flick)
        topBannerView_Flick.addSubview(bannerTitleLabel_Flick)
        topBannerView_Flick.addSubview(bannerSubtitleLabel_Flick)
        topBannerView_Flick.addSubview(stepsContainer_Flick)

        // 步骤 Pill
        buildStepIndicator_Flick()

        // 滚动表单
        view.addSubview(scrollView_Flick)
        scrollView_Flick.addSubview(contentStack_Flick)

        // 标题卡片
        buildTitleCard_Flick()
        contentStack_Flick.addArrangedSubview(titleCard_Flick)

        // 内容卡片
        buildContentCard_Flick()
        contentStack_Flick.addArrangedSubview(contentCard_Flick)

        // 媒体卡片
        buildMediaCard_Flick()
        contentStack_Flick.addArrangedSubview(mediaCard_Flick)

        // 发布区域
        buildPublishSection_Flick()
    }

    /// 构建步骤指示器
    private func buildStepIndicator_Flick() {
        var lastView: UIView? = nil
        for (i, label_Flick) in stepLabels_Flick.enumerated() {
            let pill = UIView()
            pill.layer.cornerRadius = 12
            pill.clipsToBounds = true

            let gradient = CAGradientLayer()
            gradient.cornerRadius = 12
            gradient.colors = i == 0
                ? [ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
                   ColorConfig_Flick.primaryGradientEnd_Flick.cgColor]
                : [UIColor.white.withValues(alpha: 0.25).cgColor,
                   UIColor.white.withValues(alpha: 0.15).cgColor]
            gradient.startPoint = CGPoint(x: 0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 0.5)
            pill.layer.insertSublayer(gradient, at: 0)

            let text = UILabel()
            text.text = "\(i + 1). \(label_Flick)"
            text.font = .systemFont(ofSize: 11, weight: .semibold)
            text.textColor = .white
            pill.addSubview(text)
            text.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(5)
                make.left.right.equalToSuperview().inset(10)
            }

            stepsContainer_Flick.addSubview(pill)
            pill.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.height.equalTo(24)
                if let last = lastView {
                    make.left.equalTo(last.snp.right).offset(8)
                } else {
                    make.left.equalToSuperview()
                }
                if i == stepLabels_Flick.count - 1 {
                    make.right.equalToSuperview()
                }
            }

            stepPills_Flick.append(pill)
            stepGradients_Flick.append(gradient)
            stepTextLabels_Flick.append(text)
            lastView = pill
        }
    }

    /// 构建标题输入卡片
    private func buildTitleCard_Flick() {
        titleCard_Flick.addSubview(titleIconView_Flick)
        titleCard_Flick.addSubview(titleField_Flick)
        titleCard_Flick.addSubview(titleCountLabel_Flick)
        titleCard_Flick.addSubview(titleSeparator_Flick)

        titleIconView_Flick.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
        }

        titleField_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(titleIconView_Flick)
            make.left.equalTo(titleIconView_Flick.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(32)
        }

        titleSeparator_Flick.snp.makeConstraints { make in
            make.top.equalTo(titleIconView_Flick.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }

        titleCountLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(titleSeparator_Flick.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }

        titleField_Flick.addTarget(self, action: #selector(titleFieldChanged_Flick), for: .editingChanged)
        titleField_Flick.addTarget(self, action: #selector(titleFieldBegin_Flick), for: .editingDidBegin)
        titleField_Flick.addTarget(self, action: #selector(titleFieldEnd_Flick), for: .editingDidEnd)
    }

    /// 构建内容输入卡片
    private func buildContentCard_Flick() {
        contentCard_Flick.addSubview(contentIconView_Flick)
        contentCard_Flick.addSubview(contentTextView_Flick)
        contentCard_Flick.addSubview(contentPlaceholderLabel_Flick)
        contentCard_Flick.addSubview(contentCountLabel_Flick)

        contentIconView_Flick.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
        }

        contentTextView_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(contentIconView_Flick.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.height.greaterThanOrEqualTo(100)
        }

        contentPlaceholderLabel_Flick.snp.makeConstraints { make in
            make.top.left.equalTo(contentTextView_Flick)
        }

        contentCountLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(contentTextView_Flick.snp.bottom).offset(6)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-10)
        }

        contentTextView_Flick.delegate = self
    }

    /// 构建媒体选择卡片
    private func buildMediaCard_Flick() {
        mediaCard_Flick.addSubview(mediaIconView_Flick)
        mediaCard_Flick.addSubview(mediaTitleLabel_Flick)
        mediaCard_Flick.addSubview(mediaSubtitleLabel_Flick)
        mediaCard_Flick.addSubview(mediaPickerArea_Flick)
        mediaCard_Flick.addSubview(mediaPreviewContainer_Flick)

        mediaPickerArea_Flick.addSubview(mediaPickerIcon_Flick)
        mediaPickerArea_Flick.addSubview(mediaPickerHintLabel_Flick)
        mediaPickerArea_Flick.addSubview(mediaPickerSubHintLabel_Flick)

        mediaPreviewContainer_Flick.addSubview(previewImageView_Flick)
        mediaPreviewContainer_Flick.addSubview(previewVideoThumbView_Flick)
        mediaPreviewContainer_Flick.addSubview(videoPlayIconView_Flick)
        mediaPreviewContainer_Flick.addSubview(mediaBadge_Flick)
        mediaBadge_Flick.addSubview(mediaBadgeLabel_Flick)
        mediaPreviewContainer_Flick.addSubview(removeMediaButton_Flick)

        mediaIconView_Flick.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
        }

        mediaTitleLabel_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(mediaIconView_Flick)
            make.left.equalTo(mediaIconView_Flick.snp.right).offset(10)
        }

        mediaSubtitleLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(mediaTitleLabel_Flick.snp.bottom).offset(1)
            make.left.equalTo(mediaTitleLabel_Flick)
        }

        // 选择区域（虚线边框）
        mediaPickerArea_Flick.snp.makeConstraints { make in
            make.top.equalTo(mediaIconView_Flick.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(130)
            make.bottom.equalToSuperview().offset(-16)
        }

        mediaPickerIcon_Flick.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-14)
            make.width.height.equalTo(40)
        }

        mediaPickerHintLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(mediaPickerIcon_Flick.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        mediaPickerSubHintLabel_Flick.snp.makeConstraints { make in
            make.top.equalTo(mediaPickerHintLabel_Flick.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        // 预览容器
        mediaPreviewContainer_Flick.snp.makeConstraints { make in
            make.top.equalTo(mediaIconView_Flick.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(200)
            make.bottom.equalToSuperview().offset(-16)
        }

        previewImageView_Flick.snp.makeConstraints { $0.edges.equalToSuperview() }
        previewVideoThumbView_Flick.snp.makeConstraints { $0.edges.equalToSuperview() }

        videoPlayIconView_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(64)
        }

        mediaBadge_Flick.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(10)
        }

        mediaBadgeLabel_Flick.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.left.right.equalToSuperview().inset(8)
        }

        removeMediaButton_Flick.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(10)
            make.width.height.equalTo(32)
        }

        // 点击手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePickMedia_Flick))
        mediaPickerArea_Flick.addGestureRecognizer(tap)
    }

    /// 构建发布区域（按钮 + 装饰 + EULA）
    private func buildPublishSection_Flick() {
        // 发布按钮渐变
        publishGradientLayer_Flick.cornerRadius = 26
        publishGradientLayer_Flick.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        publishGradientLayer_Flick.startPoint = CGPoint(x: 0, y: 0.5)
        publishGradientLayer_Flick.endPoint = CGPoint(x: 1, y: 0.5)
        publishButton_Flick.layer.insertSublayer(publishGradientLayer_Flick, at: 0)
        publishButton_Flick.layer.shadowColor = ColorConfig_Flick.primaryGradientStart_Flick.cgColor
        publishButton_Flick.layer.shadowOffset = CGSize(width: 0, height: 8)
        publishButton_Flick.layer.shadowOpacity = 0.35
        publishButton_Flick.layer.shadowRadius = 16

        contentStack_Flick.addArrangedSubview(publishButton_Flick)
        contentStack_Flick.addArrangedSubview(publishDecorLabel_Flick)
        contentStack_Flick.addArrangedSubview(eulaButton_Flick)
        contentStack_Flick.setCustomSpacing(10, after: publishButton_Flick)
        contentStack_Flick.setCustomSpacing(2, after: publishDecorLabel_Flick)
    }

    // MARK: - 约束

    private func setupConstraints_Flick() {
        topBannerView_Flick.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(106)
        }

        bannerTitleLabel_Flick.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-32)
            make.left.equalToSuperview().offset(20)
        }

        bannerSubtitleLabel_Flick.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.left.equalToSuperview().offset(20)
        }

        stepsContainer_Flick.snp.makeConstraints { make in
            make.centerY.equalTo(bannerTitleLabel_Flick)
            make.right.equalToSuperview().offset(-20)
        }

        scrollView_Flick.snp.makeConstraints { make in
            make.top.equalTo(topBannerView_Flick.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        contentStack_Flick.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-30)
            make.width.equalTo(scrollView_Flick).offset(-32)
        }

        publishButton_Flick.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
    }

    // MARK: - 渐变 & 装饰更新

    private func updateBannerGradient_Flick() {
        bannerGradientLayer_Flick?.removeFromSuperlayer()
        let gradient = CAGradientLayer()
        gradient.frame = topBannerView_Flick.bounds
        gradient.colors = [
            ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
            ColorConfig_Flick.primaryGradientEnd_Flick.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        topBannerView_Flick.layer.insertSublayer(gradient, at: 0)
        bannerGradientLayer_Flick = gradient
    }

    private func updateDecorLayout_Flick() {
        let w = topBannerView_Flick.bounds.width
        let h = topBannerView_Flick.bounds.height
        decorCircle1_Flick.frame = CGRect(x: -40, y: -40, width: 150, height: 150)
        decorCircle1_Flick.layer.cornerRadius = 75
        decorCircle2_Flick.frame = CGRect(x: w - 60, y: h - 20, width: 110, height: 110)
        decorCircle2_Flick.layer.cornerRadius = 55
        decorStar_Flick.frame = CGRect(x: w - 48, y: 44, width: 22, height: 22)
        decorSparkle_Flick.frame = CGRect(x: w - 80, y: 50, width: 26, height: 26)
    }

    private func updatePublishGradient_Flick() {
        publishGradientLayer_Flick.frame = publishButton_Flick.bounds
    }

    /// 虚线渐变边框（用 CAShapeLayer 模拟）
    private func updateMediaPickerDashedBorder_Flick() {
        mediaPickerDashedBorder_Flick.removeFromSuperlayer()
        mediaPickerDashedBorder_Flick.frame = mediaPickerArea_Flick.bounds
        mediaPickerDashedBorder_Flick.strokeColor = ColorConfig_Flick.primaryGradientStart_Flick
            .withValues(alpha: 0.4).cgColor
        mediaPickerDashedBorder_Flick.fillColor = UIColor.clear.cgColor
        mediaPickerDashedBorder_Flick.lineWidth = 1.5
        mediaPickerDashedBorder_Flick.lineDashPattern = [6, 4]
        mediaPickerDashedBorder_Flick.path = UIBezierPath(
            roundedRect: mediaPickerArea_Flick.bounds.insetBy(dx: 0.75, dy: 0.75),
            cornerRadius: 16
        ).cgPath
        mediaPickerArea_Flick.layer.addSublayer(mediaPickerDashedBorder_Flick)
    }

    private func updateStepGradients_Flick() {
        for (i, gradient) in stepGradients_Flick.enumerated() {
            gradient.frame = stepPills_Flick[i].bounds
        }
    }

    // MARK: - Banner 入场动画

    private func animateBannerEntrance_Flick() {
        bannerTitleLabel_Flick.alpha = 0
        bannerSubtitleLabel_Flick.alpha = 0
        stepsContainer_Flick.alpha = 0
        bannerTitleLabel_Flick.transform = CGAffineTransform(translationX: -20, y: 0)

        UIView.animate(
            withDuration: AnimationConfig_Flick.durationSpring_Flick,
            delay: 0.05,
            usingSpringWithDamping: AnimationConfig_Flick.springDampingNormal_Flick,
            initialSpringVelocity: 0.5
        ) {
            self.bannerTitleLabel_Flick.alpha = 1
            self.bannerTitleLabel_Flick.transform = .identity
        }

        UIView.animate(withDuration: 0.4, delay: 0.15) {
            self.bannerSubtitleLabel_Flick.alpha = 1
            self.stepsContainer_Flick.alpha = 1
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Flick() {
        removeMediaButton_Flick.addTarget(self, action: #selector(handleRemoveMedia_Flick), for: .touchUpInside)
        publishButton_Flick.addTarget(self, action: #selector(handlePublish_Flick), for: .touchUpInside)
        eulaButton_Flick.addTarget(self, action: #selector(handleEULA_Flick), for: .touchUpInside)
    }

    @objc private func titleFieldChanged_Flick() {
        let count = titleField_Flick.text?.count ?? 0
        titleCountLabel_Flick.text = "\(count)/50"
        titleCountLabel_Flick.textColor = count > 40
            ? UIColor(hexstring_Flick: "#FC8181")
            : ColorConfig_Flick.textPlaceholder_Flick
        updateStepHighlight_Flick()
    }

    @objc private func titleFieldBegin_Flick() {
        highlightCard_Flick(titleCard_Flick, highlight: true)
    }

    @objc private func titleFieldEnd_Flick() {
        highlightCard_Flick(titleCard_Flick, highlight: false)
    }

    /// 卡片焦点高亮（边框渐变动画）
    private func highlightCard_Flick(_ card: UIView, highlight: Bool) {
        UIView.animate(withDuration: 0.25) {
            card.layer.borderWidth = highlight ? 1.5 : 0
            card.layer.borderColor = highlight
                ? ColorConfig_Flick.primaryGradientStart_Flick.withValues(alpha: 0.4).cgColor
                : UIColor.clear.cgColor
        }
    }

    @objc private func handlePickMedia_Flick() {
        // 选择区域按压动画
        mediaPickerArea_Flick.animatePressDown_Flick { [weak self] in
            self?.mediaPickerArea_Flick.animatePressUp_Flick()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            MediaPickerHelper_Flick.pickMedia_Flick(from: self) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .photo_Flick(let image): self.applySelectedImage_Flick(image_Flick: image)
                case .video_Flick(let url): self.applySelectedVideo_Flick(url_Flick: url)
                case .cancelled_Flick: break
                }
            }
        }
    }

    private func applySelectedImage_Flick(image_Flick: UIImage) {
        selectedImage_Flick = image_Flick
        selectedVideoURL_Flick = nil

        if let data = image_Flick.jpegData(compressionQuality: 0.8) {
            let path = FileManager.default.temporaryDirectory
                .appendingPathComponent("release_img_\(Date().timeIntervalSince1970).jpg")
            try? data.write(to: path)
            selectedMediaPath_Flick = path.absoluteString
        }

        previewImageView_Flick.image = image_Flick
        previewImageView_Flick.isHidden = false
        previewVideoThumbView_Flick.isHidden = true
        videoPlayIconView_Flick.isHidden = true
        mediaBadgeLabel_Flick.text = "📷  Photo"
        mediaBadge_Flick.isHidden = false
        removeMediaButton_Flick.isHidden = false
        mediaPickerArea_Flick.isHidden = true
        mediaPreviewContainer_Flick.isHidden = false

        // 预览入场弹性动画
        mediaPreviewContainer_Flick.animateSpringScaleIn_Flick()
        updateStepHighlight_Flick()
    }

    private func applySelectedVideo_Flick(url_Flick: URL) {
        selectedVideoURL_Flick = url_Flick
        selectedImage_Flick = nil
        selectedMediaPath_Flick = url_Flick.absoluteString

        let asset = AVURLAsset(url: url_Flick)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0, preferredTimescale: 60)
        if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
            previewVideoThumbView_Flick.image = UIImage(cgImage: cgImage)
        }

        previewVideoThumbView_Flick.isHidden = false
        previewImageView_Flick.isHidden = true
        videoPlayIconView_Flick.isHidden = false
        mediaBadgeLabel_Flick.text = "🎬  Video"
        mediaBadge_Flick.isHidden = false
        removeMediaButton_Flick.isHidden = false
        mediaPickerArea_Flick.isHidden = true
        mediaPreviewContainer_Flick.isHidden = false

        mediaPreviewContainer_Flick.animateSpringScaleIn_Flick()
        updateStepHighlight_Flick()
    }

    @objc private func handleRemoveMedia_Flick() {
        selectedImage_Flick = nil
        selectedVideoURL_Flick = nil
        selectedMediaPath_Flick = ""

        previewImageView_Flick.image = nil
        previewVideoThumbView_Flick.image = nil
        previewImageView_Flick.isHidden = true
        previewVideoThumbView_Flick.isHidden = true
        videoPlayIconView_Flick.isHidden = true
        mediaBadge_Flick.isHidden = true
        removeMediaButton_Flick.isHidden = true
        mediaPickerArea_Flick.isHidden = false
        mediaPreviewContainer_Flick.isHidden = true
        updateStepHighlight_Flick()
    }

    /// 根据表单填写进度更新步骤 Pill 高亮
    private func updateStepHighlight_Flick() {
        let hasTitle = !(titleField_Flick.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let hasContent = !contentTextView_Flick.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasMedia = !selectedMediaPath_Flick.isEmpty
        let states = [hasTitle, hasContent, hasMedia]

        for (i, gradient) in stepGradients_Flick.enumerated() {
            let active = states[i]
            gradient.colors = active
                ? [ColorConfig_Flick.primaryGradientStart_Flick.cgColor,
                   ColorConfig_Flick.primaryGradientEnd_Flick.cgColor]
                : [UIColor.white.withValues(alpha: 0.25).cgColor,
                   UIColor.white.withValues(alpha: 0.15).cgColor]
        }
    }

    @objc private func handlePublish_Flick() {
        // 按钮弹性动画
        publishButton_Flick.animatePressDown_Flick { [weak self] in
            self?.publishButton_Flick.animatePressUp_Flick()
        }

        // 1. 检查登录
        guard UserViewModel_Flick.shared_Flick.isLoggedIn_Flick else {
            Navigation_Flick.toLogin_Flick(style_flick: .present_flick)
            return
        }

        // 2. 校验标题
        let title = titleField_Flick.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !title.isEmpty else {
            highlightCard_Flick(titleCard_Flick, highlight: true)
            Utils_Flick.showWarning_Flick(message_Flick: "Please enter a title.")
            return
        }

        // 3. 校验内容
        let content = contentTextView_Flick.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else {
            highlightCard_Flick(contentCard_Flick, highlight: true)
            Utils_Flick.showWarning_Flick(message_Flick: "Please enter some content.")
            return
        }

        // 4. 校验媒体
        guard !selectedMediaPath_Flick.isEmpty else {
            Utils_Flick.showWarning_Flick(message_Flick: "Please add a photo or video.")
            return
        }

        // 5. 调用 ViewModel 发布
        TitleViewModel_Flick.shared_Flick.releasePost_Flick(
            title_flick: title,
            content_flick: content,
            media_flick: selectedMediaPath_Flick
        )

        // 6. 清空页面
        clearPageData_Flick()
    }

    private func clearPageData_Flick() {
        titleField_Flick.text = ""
        contentTextView_Flick.text = ""
        contentPlaceholderLabel_Flick.isHidden = false
        titleCountLabel_Flick.text = "0/50"
        contentCountLabel_Flick.text = "0/300"
        handleRemoveMedia_Flick()
        view.endEditing(true)
    }

    /// 打开协议展示页，调用链与设置页 `Setting_Flick.openProtocol_Flick` 相同
    /// - Parameters:
    ///   - type_Flick: 协议类型枚举
    ///   - imageName_flick: 本地协议图片资源名（如 eula.png）
    private func openProtocol_Flick(type_Flick: ProtocolHelper_Flick.ProtocolType_Flick, imageName_flick: String) {
        ProtocolHelper_Flick.showProtocol_Flick(type_Flick: type_Flick, content_Flick: imageName_flick, from: self)
    }

    @objc private func handleEULA_Flick() {
        openProtocol_Flick(type_Flick: .eula_Flick, imageName_flick: "eula.png")
    }

    private func setupKeyboardDismiss_Flick() {
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

// MARK: - UITextViewDelegate

extension Release_Flick: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholderLabel_Flick.isHidden = !textView.text.isEmpty
        let count = textView.text.count
        contentCountLabel_Flick.text = "\(count)/300"
        contentCountLabel_Flick.textColor = count > 260
            ? UIColor(hexstring_Flick: "#FC8181")
            : ColorConfig_Flick.textPlaceholder_Flick
        updateStepHighlight_Flick()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        contentPlaceholderLabel_Flick.isHidden = !textView.text.isEmpty
        highlightCard_Flick(contentCard_Flick, highlight: true)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        contentPlaceholderLabel_Flick.isHidden = !textView.text.isEmpty
        highlightCard_Flick(contentCard_Flick, highlight: false)
    }
}

// MARK: - 辅助：圆角图标徽章

/// 创建圆角彩色图标小徽章（用于卡片左侧标识）
private func makeIconBadge_Flick(systemName: String, bgColor: UIColor) -> UIView {
    let container = UIView()
    container.backgroundColor = bgColor.withValues(alpha: 0.15)
    container.layer.cornerRadius = 10

    let iv = UIImageView()
    let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
    iv.image = UIImage(systemName: systemName, withConfiguration: config)
    iv.tintColor = bgColor
    iv.contentMode = .scaleAspectFit

    container.addSubview(iv)
    iv.snp.makeConstraints { make in
        make.center.equalToSuperview()
        make.width.height.equalTo(18)
    }

    return container
}

// MARK: - 卡片工厂

/// 表单卡片视图工厂
private enum ReleaseFormCard_Flick {

    /// 生成白色圆角卡片
    static func make() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.cornerCurve = .continuous
        v.layer.shadowColor = UIColor.black.withValues(alpha: 0.05).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 10
        return v
    }
}
