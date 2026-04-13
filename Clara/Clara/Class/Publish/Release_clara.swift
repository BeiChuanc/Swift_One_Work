import Foundation
import UIKit
import SnapKit

// MARK: - 发布页

/// 发布页面
/// 核心功能：允许已登录用户发布带标题、内容和单一媒体（图片或视频）的帖子
/// 设计思路：顶部渐变 Banner（含媒体类型图标组 + 引导文案）→ 标题卡片 → 内容卡片（含字数统计）
///           → 媒体选择区（虚线边框 + 渐变背景提示）→ 发布按钮 + EULA 链接；
///           发布前校验登录状态与各字段非空，发布成功后清空表单并关闭页面
/// 关键属性：
///   - selectedImage_Clara: 选取的图片（与 selectedVideoURL_Clara 互斥）
///   - selectedVideoURL_Clara: 选取的视频 URL
///   - mediaPath_Clara: 最终传给 ViewModel 的媒体路径字符串
/// 关键方法：
///   - pickMedia_Clara: 打开媒体选择器（图片/视频）
///   - publishTapped_Clara: 校验登录 → 校验非空 → 调用 TitleViewModel 发布 → 清空
class Release_Clara: UIViewController {

    // MARK: - 数据属性

    private var selectedImage_Clara: UIImage?
    private var selectedVideoURL_Clara: URL?

    /// 媒体路径（发布时传入 ViewModel）
    private var mediaPath_Clara: String = ""

    // MARK: - UI 组件

    private let scrollView_Clara: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        return sv
    }()

    private let contentView_Clara = UIView()

    /// 顶部渐变 Banner
    private let topBanner_Clara = UIView()

    /// Banner 渐变图层
    private var topBannerGl_Clara: CAGradientLayer?

    // 标题卡片引用（用于媒体区相对布局）
    private let titleCard_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        v.layer.cornerRadius = 16
        v.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 8
        return v
    }()

    // 内容卡片引用
    private let contentCard_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Clara.cardBackground_Clara
        v.layer.cornerRadius = 16
        v.layer.shadowColor = ColorConfig_Clara.shadowColor_Clara.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 8
        return v
    }()

    /// 标题输入框
    private let titleField_Clara: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Give your post a title..."
        tf.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf.textColor = ColorConfig_Clara.textPrimary_Clara
        tf.clearButtonMode = .whileEditing
        tf.returnKeyType = .next
        return tf
    }()

    /// 内容输入框
    private let contentTextView_Clara: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15)
        tv.textColor = ColorConfig_Clara.textPrimary_Clara
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()

    /// 内容占位符
    private let contentPlaceholder_Clara: UILabel = {
        let l = UILabel()
        l.text = "Share your story..."
        l.font = UIFont.systemFont(ofSize: 15)
        l.textColor = ColorConfig_Clara.textPlaceholder_Clara
        return l
    }()

    /// 内容字数统计
    private let contentCountLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "0 / 300"
        l.font = UIFont.systemFont(ofSize: 11)
        l.textColor = ColorConfig_Clara.textPlaceholder_Clara
        l.textAlignment = .right
        return l
    }()

    /// 媒体选择容器
    private let mediaContainer_Clara: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 媒体容器渐变背景图层
    private var mediaContainerGl_Clara: CAGradientLayer?

    /// 媒体展示视图
    private let mediaDisplayView_Clara = MediaDisplayView_Clara()

    /// 添加媒体图标
    private let mediaPlusIcon_Clara: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 34, weight: .light)
        iv.image = UIImage(systemName: "photo.badge.plus", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Clara.primaryGradientStart_Clara
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 添加媒体主提示文字
    private let mediaHintLabel_Clara: UILabel = {
        let l = UILabel()
        l.text = "Tap to add photo or video"
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = ColorConfig_Clara.primaryGradientStart_Clara
        l.textAlignment = .center
        return l
    }()

    /// 添加媒体副提示文字
    private let mediaSubHint_Clara: UILabel = {
        let l = UILabel()
        l.text = "JPG · PNG · MP4 · MOV"
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = ColorConfig_Clara.textPlaceholder_Clara
        l.textAlignment = .center
        return l
    }()

    /// 删除媒体按钮（已选媒体时显示）
    private let removeMediaButton_Clara: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        btn.layer.cornerRadius = 16
        btn.isHidden = true
        return btn
    }()

    /// 发布按钮
    private let publishButton_Clara: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.setTitle("  Publish", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 26
        return btn
    }()

    /// EULA 按钮：普通文字 + "EULA" 局部下划线
    private let eulaButton_Clara: UIButton = {
        let btn = UIButton(type: .system)
        let fullText = "EULA"
        let attr = NSMutableAttributedString(
            string: fullText,
            attributes: [
                .foregroundColor: ColorConfig_Clara.textPlaceholder_Clara,
                .font: UIFont.systemFont(ofSize: 14, weight: .regular)
            ]
        )
        // 仅对 "EULA" 添加下划线与主题色，突出可点击性
        if let eulaRange = fullText.range(of: "EULA") {
            let nsRange = NSRange(eulaRange, in: fullText)
            attr.addAttributes([
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: ColorConfig_Clara.primaryGradientStart_Clara
            ], range: nsRange)
        }
        btn.setAttributedTitle(attr, for: .normal)
        return btn
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 完全隐藏导航栏，与 Home/Me 保持一致，使用自定义返回按钮
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyThemeBackground_Clara()
        title = "New Post"
        setupNavigationBar_Clara()
        setupScrollView_Clara()
        setupTopBanner_Clara()
        setupFormCards_Clara()
        setupMediaArea_Clara()
        setupBottomButtons_Clara()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Banner 渐变
        if let gl = topBannerGl_Clara {
            gl.frame = topBanner_Clara.bounds
        } else if topBanner_Clara.bounds.width > 0 {
            let gl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: topBanner_Clara.bounds)
            gl.cornerRadius = 24
            topBanner_Clara.layer.insertSublayer(gl, at: 0)
            topBannerGl_Clara = gl
        }
        // 发布按钮渐变
        publishButton_Clara.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        if publishButton_Clara.bounds.width > 0 {
            let btnGl = UIColor.createPrimaryGradientLayer_Clara(frame_Clara: publishButton_Clara.bounds)
            btnGl.cornerRadius = 26
            publishButton_Clara.layer.insertSublayer(btnGl, at: 0)
        }
        // 媒体容器渐变背景（无媒体时）
        if mediaContainerGl_Clara == nil && mediaContainer_Clara.bounds.width > 0 && mediaPath_Clara.isEmpty {
            setupMediaContainerGl_Clara()
        }
        view.updateThemeBackgroundFrame_Clara()
    }

    // MARK: - 自定义返回按钮

    /// 添加悬浮于渐变 Banner 之上的自定义返回按钮（半透明白色，与渐变融合）
    private func setupNavigationBar_Clara() {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.40).cgColor
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        btn.addTarget(self, action: #selector(backTapped_Clara), for: .touchUpInside)
    }

    // MARK: - UI 搭建

    private func setupScrollView_Clara() {
        view.addSubview(scrollView_Clara)
        scrollView_Clara.addSubview(contentView_Clara)
        // 透明背景，使 view 层的多拼色渐变透出
        scrollView_Clara.backgroundColor = .clear
        contentView_Clara.backgroundColor = .clear
        // 贴满整个 view（含状态栏区域），使 Banner 延伸到屏幕顶部
        scrollView_Clara.contentInsetAdjustmentBehavior = .never
        scrollView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    /// 顶部渐变 Banner（全宽 + 延伸至屏幕顶部，丰富三层内容：主副标题 + 步骤 Chip 行）
    private func setupTopBanner_Clara() {
        contentView_Clara.addSubview(topBanner_Clara)
        // 仅底部两个圆角，与状态栏区域无缝衔接
        topBanner_Clara.layer.cornerRadius = 28
        topBanner_Clara.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        topBanner_Clara.clipsToBounds = true
        topBanner_Clara.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            // 高度：状态栏 + 130pt 内容区（三行内容）
            make.bottom.equalTo(contentView_Clara.safeAreaLayoutGuide.snp.top).offset(130)
        }

        // 大装饰圆（右上，溢出营造层次）
        let bigCircle = UIView()
        bigCircle.backgroundColor = UIColor.white.withAlphaComponent(0.10)
        bigCircle.layer.cornerRadius = 60
        topBanner_Clara.addSubview(bigCircle)
        bigCircle.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.right.equalToSuperview().inset(-28)
            make.top.equalToSuperview().inset(-26)
        }

        // 中等装饰圆（左下）
        let midCircle = UIView()
        midCircle.backgroundColor = UIColor.white.withAlphaComponent(0.06)
        midCircle.layer.cornerRadius = 38
        topBanner_Clara.addSubview(midCircle)
        midCircle.snp.makeConstraints { make in
            make.width.height.equalTo(76)
            make.left.equalToSuperview().inset(-18)
            make.bottom.equalToSuperview().inset(-20)
        }

        // 小装饰点（右下区域）
        let dotCircle = UIView()
        dotCircle.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        dotCircle.layer.cornerRadius = 18
        topBanner_Clara.addSubview(dotCircle)
        dotCircle.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.right.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset(16)
        }

        // 右侧媒体图标组（右上区域，与标题同高）
        let iconStack = UIStackView()
        iconStack.axis = .horizontal
        iconStack.spacing = 14
        iconStack.alignment = .center
        topBanner_Clara.addSubview(iconStack)

        for iconName in ["photo.fill", "video.fill"] {
            let iv = UIImageView()
            let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
            iv.image = UIImage(systemName: iconName, withConfiguration: cfg)
            iv.tintColor = UIColor.white.withAlphaComponent(0.70)
            iv.contentMode = .scaleAspectFit
            iconStack.addArrangedSubview(iv)
            iv.snp.makeConstraints { make in make.width.height.equalTo(22) }
        }

        // ── 主标题
        let mainLabel = UILabel()
        mainLabel.text = "Share a Moment ✨"
        mainLabel.font = UIFont.systemFont(ofSize: 21, weight: .heavy)
        mainLabel.textColor = .white
        topBanner_Clara.addSubview(mainLabel)
        mainLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(72)
            make.centerY.equalTo(topBanner_Clara.safeAreaLayoutGuide.snp.top).offset(24)
        }
        iconStack.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(24)
            make.centerY.equalTo(mainLabel.snp.centerY)
        }

        // ── 副标题描述
        let subLabel = UILabel()
        subLabel.text = "Tell your story · Inspire someone today"
        subLabel.font = UIFont.systemFont(ofSize: 12.5, weight: .regular)
        subLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        topBanner_Clara.addSubview(subLabel)
        subLabel.snp.makeConstraints { make in
            make.left.equalTo(mainLabel.snp.left)
            make.top.equalTo(mainLabel.snp.bottom).offset(6)
        }

        // ── 步骤标签行（① Title  ② Story  ③ Media）
        let stepData: [(String, String)] = [
            ("textformat.alt",         "① Title"),
            ("doc.text.fill",          "② Story"),
            ("photo.badge.plus.fill",  "③ Media")
        ]
        var prevChip: UIView? = nil
        for (icon, text) in stepData {
            let chip = makeReleaseBannerChip_Clara(icon: icon, text: text)
            topBanner_Clara.addSubview(chip)
            chip.snp.makeConstraints { make in
                make.centerY.equalTo(topBanner_Clara.safeAreaLayoutGuide.snp.top).offset(96)
                make.height.equalTo(26)
                if let prev = prevChip {
                    make.left.equalTo(prev.snp.right).offset(8)
                } else {
                    make.left.equalTo(mainLabel.snp.left)
                }
            }
            prevChip = chip
        }
    }

    /// 创建发布页 Banner 步骤标签（Chip）
    /// - Parameters:
    ///   - icon: SF Symbol 图标名
    ///   - text: 标签文字
    /// - Returns: 配置好的半透明 Chip 视图
    private func makeReleaseBannerChip_Clara(icon: String, text: String) -> UIView {
        let chip = UIView()
        chip.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        chip.layer.cornerRadius = 13
        chip.layer.borderWidth = 0.5
        chip.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor

        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 9, weight: .semibold)
        iv.image = UIImage(systemName: icon, withConfiguration: cfg)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit

        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl.textColor = .white

        chip.addSubview(iv)
        chip.addSubview(lbl)
        iv.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12)
        }
        lbl.snp.makeConstraints { make in
            make.left.equalTo(iv.snp.right).offset(5)
            make.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        return chip
    }

    /// 搭建标题和内容表单卡片
    private func setupFormCards_Clara() {
        // 标题卡片
        contentView_Clara.addSubview(titleCard_Clara)
        titleCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(topBanner_Clara.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(58)
        }

        // 左侧强调色竖条
        let titleBar = UIView()
        titleBar.backgroundColor = ColorConfig_Clara.primaryGradientStart_Clara
        titleBar.layer.cornerRadius = 2
        titleCard_Clara.addSubview(titleBar)
        titleBar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(28)
        }

        let titleIcon = UIImageView()
        let titleCfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        titleIcon.image = UIImage(systemName: "textformat.alt", withConfiguration: titleCfg)
        titleIcon.tintColor = ColorConfig_Clara.primaryGradientStart_Clara
        titleIcon.contentMode = .scaleAspectFit
        titleCard_Clara.addSubview(titleIcon)
        titleIcon.snp.makeConstraints { make in
            make.left.equalTo(titleBar.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        titleCard_Clara.addSubview(titleField_Clara)
        titleField_Clara.snp.makeConstraints { make in
            make.left.equalTo(titleIcon.snp.right).offset(8)
            make.right.equalToSuperview().inset(14)
            make.top.bottom.equalToSuperview()
        }
        titleField_Clara.delegate = self

        // 内容卡片
        contentView_Clara.addSubview(contentCard_Clara)
        contentCard_Clara.snp.makeConstraints { make in
            make.top.equalTo(titleCard_Clara.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(136)
        }

        let contentBar = UIView()
        contentBar.backgroundColor = ColorConfig_Clara.primaryGradientEnd_Clara
        contentBar.layer.cornerRadius = 2
        contentCard_Clara.addSubview(contentBar)
        contentBar.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(16)
            make.width.equalTo(4)
            make.height.equalTo(28)
        }

        let contentIcon = UIImageView()
        let contentIconCfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        contentIcon.image = UIImage(systemName: "doc.text", withConfiguration: contentIconCfg)
        contentIcon.tintColor = ColorConfig_Clara.primaryGradientEnd_Clara
        contentIcon.contentMode = .scaleAspectFit
        contentCard_Clara.addSubview(contentIcon)
        contentIcon.snp.makeConstraints { make in
            make.left.equalTo(contentBar.snp.right).offset(10)
            make.top.equalToSuperview().offset(18)
            make.width.height.equalTo(18)
        }

        contentCard_Clara.addSubview(contentTextView_Clara)
        contentTextView_Clara.snp.makeConstraints { make in
            make.left.equalTo(contentIcon.snp.right).offset(8)
            make.right.equalToSuperview().inset(14)
            make.top.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().inset(26)
        }
        contentCard_Clara.addSubview(contentPlaceholder_Clara)
        contentPlaceholder_Clara.snp.makeConstraints { make in
            make.left.equalTo(contentTextView_Clara.snp.left)
            make.top.equalTo(contentTextView_Clara.snp.top).offset(1)
        }

        // 字数统计
        contentCard_Clara.addSubview(contentCountLabel_Clara)
        contentCountLabel_Clara.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(8)
        }

        contentTextView_Clara.delegate = self
    }

    /// 搭建媒体选择区（渐变底 + 虚线边框提示）
    private func setupMediaArea_Clara() {
        contentView_Clara.addSubview(mediaContainer_Clara)
        mediaContainer_Clara.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Clara.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }

        // 虚线边框层
        let dashLayer = CAShapeLayer()
        dashLayer.strokeColor = ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.5).cgColor
        dashLayer.lineDashPattern = [8, 5]
        dashLayer.lineWidth = 1.5
        dashLayer.fillColor = UIColor.clear.cgColor
        dashLayer.cornerRadius = 18
        mediaContainer_Clara.layer.addSublayer(dashLayer)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let path = UIBezierPath(roundedRect: self.mediaContainer_Clara.bounds, cornerRadius: 18)
            dashLayer.path = path.cgPath
            dashLayer.frame = self.mediaContainer_Clara.bounds
        }

        mediaContainer_Clara.addSubview(mediaDisplayView_Clara)
        mediaDisplayView_Clara.layer.cornerRadius = 18
        mediaDisplayView_Clara.clipsToBounds = true
        // 初始隐藏，避免空状态下覆盖提示图标和渐变背景
        mediaDisplayView_Clara.isHidden = true
        mediaDisplayView_Clara.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 加号图标与提示（无媒体时显示）
        mediaContainer_Clara.addSubview(mediaPlusIcon_Clara)
        mediaPlusIcon_Clara.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-22)
            make.width.height.equalTo(44)
        }

        mediaContainer_Clara.addSubview(mediaHintLabel_Clara)
        mediaHintLabel_Clara.snp.makeConstraints { make in
            make.top.equalTo(mediaPlusIcon_Clara.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        mediaContainer_Clara.addSubview(mediaSubHint_Clara)
        mediaSubHint_Clara.snp.makeConstraints { make in
            make.top.equalTo(mediaHintLabel_Clara.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        // 删除媒体按钮
        mediaContainer_Clara.addSubview(removeMediaButton_Clara)
        removeMediaButton_Clara.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().inset(10)
            make.width.height.equalTo(32)
        }
        removeMediaButton_Clara.addTarget(self, action: #selector(removeMedia_Clara), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(pickMedia_Clara))
        mediaContainer_Clara.addGestureRecognizer(tap)
    }

    /// 为媒体容器设置淡渐变背景（提示区背景）
    private func setupMediaContainerGl_Clara() {
        let gl = CAGradientLayer()
        gl.frame = mediaContainer_Clara.bounds
        gl.colors = [
            ColorConfig_Clara.primaryGradientStart_Clara.withAlphaComponent(0.05).cgColor,
            ColorConfig_Clara.primaryGradientEnd_Clara.withAlphaComponent(0.08).cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 1, y: 1)
        gl.cornerRadius = 18
        mediaContainer_Clara.layer.insertSublayer(gl, at: 0)
        mediaContainerGl_Clara = gl
    }

    private func setupBottomButtons_Clara() {
        contentView_Clara.addSubview(publishButton_Clara)
        publishButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(mediaContainer_Clara.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(54)
        }
        publishButton_Clara.addTarget(self, action: #selector(publishTapped_Clara), for: .touchUpInside)

        contentView_Clara.addSubview(eulaButton_Clara)
        eulaButton_Clara.snp.makeConstraints { make in
            make.top.equalTo(publishButton_Clara.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
        }
        eulaButton_Clara.addTarget(self, action: #selector(eulaTapped_Clara), for: .touchUpInside)
    }

    // MARK: - 媒体选择

    /// 打开媒体选择器（图片/视频）
    @objc private func pickMedia_Clara() {
        MediaPickerHelper_Clara.pickMedia_Clara(from: self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .photo_Clara(let image):
                self.selectedImage_Clara = image
                self.selectedVideoURL_Clara = nil
                let path = self.saveTempImage_Clara(image: image)
                self.mediaPath_Clara = path
                self.mediaDisplayView_Clara.configureWithImage_Clara(image_Clara: image)
                self.updateMediaUI_Clara(hasMedia: true)
            case .video_Clara(let url):
                self.selectedVideoURL_Clara = url
                self.selectedImage_Clara = nil
                self.mediaPath_Clara = url.path
                self.mediaDisplayView_Clara.configure_Clara(mediaPath_Clara: url.path, isVideo_Clara: true)
                self.updateMediaUI_Clara(hasMedia: true)
            case .cancelled_Clara:
                break
            }
        }
    }

    /// 更新媒体区域 UI 状态
    /// - Parameter hasMedia: 是否已有选取的媒体
    private func updateMediaUI_Clara(hasMedia: Bool) {
        // 有媒体时展示 mediaDisplayView，无媒体时展示提示图标和文案
        mediaDisplayView_Clara.isHidden = !hasMedia
        mediaPlusIcon_Clara.isHidden = hasMedia
        mediaHintLabel_Clara.isHidden = hasMedia
        mediaSubHint_Clara.isHidden = hasMedia
        removeMediaButton_Clara.isHidden = !hasMedia
        // 有媒体时隐藏渐变底
        mediaContainerGl_Clara?.isHidden = hasMedia
    }

    @objc private func removeMedia_Clara() {
        selectedImage_Clara = nil
        selectedVideoURL_Clara = nil
        mediaPath_Clara = ""
        mediaDisplayView_Clara.configure_Clara(mediaPath_Clara: nil)
        updateMediaUI_Clara(hasMedia: false)
    }

    /// 将图片存储到临时目录并返回路径
    /// - Parameter image: 要存储的图片
    /// - Returns: 临时文件路径字符串
    private func saveTempImage_Clara(image: UIImage) -> String {
        let name = "post_img_\(Int(Date().timeIntervalSince1970)).jpg"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        if let data = image.jpegData(compressionQuality: 0.85) {
            try? data.write(to: url)
        }
        return url.path
    }

    // MARK: - 事件响应

    @objc private func backTapped_Clara() {
        navigationController?.popViewController(animated: true)
    }

    /// 发布帖子（校验登录 → 非空校验 → 调用 ViewModel → 清空表单）
    @objc private func publishTapped_Clara() {
        view.endEditing(true)

        guard UserViewModel_Clara.shared_Clara.isLoggedIn_Clara else {
            Navigation_Clara.toLogin_Clara(style_clara: .present_clara)
            return
        }

        let title = titleField_Clara.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let content = contentTextView_Clara.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !title.isEmpty else {
            Utils_Clara.showWarning_Clara(message_Clara: "Please enter a title")
            return
        }
        guard !content.isEmpty else {
            Utils_Clara.showWarning_Clara(message_Clara: "Please write some content")
            return
        }
        guard !mediaPath_Clara.isEmpty else {
            Utils_Clara.showWarning_Clara(message_Clara: "Please add a photo or video")
            return
        }

        TitleViewModel_Clara.shared_Clara.releasePost_Clara(
            title_clara: title,
            content_clara: content,
            media_clara: mediaPath_Clara
        )

        clearForm_Clara()
        navigationController?.popViewController(animated: true)
    }

    /// EULA 按钮点击
    @objc private func eulaTapped_Clara() {
        ProtocolHelper_Clara.showProtocol_Clara(
            type_Clara: .eula_Clara,
            content_Clara: "eula.png",
            from: self
        )
    }

    /// 清空表单数据
    private func clearForm_Clara() {
        titleField_Clara.text = ""
        contentTextView_Clara.text = ""
        contentPlaceholder_Clara.isHidden = false
        contentCountLabel_Clara.text = "0 / 300"
        removeMedia_Clara()
    }
}

// MARK: - UITextFieldDelegate

extension Release_Clara: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Clara.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension Release_Clara: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder_Clara.isHidden = !textView.text.isEmpty
        let count = textView.text.count
        contentCountLabel_Clara.text = "\(count) / 300"
        contentCountLabel_Clara.textColor = count > 300
            ? .systemRed
            : ColorConfig_Clara.textPlaceholder_Clara
    }
}
