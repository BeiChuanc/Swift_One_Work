import Foundation
import UIKit
import SnapKit

// MARK: - 发布页面视图控制器

/// 发布页面视图控制器
/// 功能：输入标题、内容、选取单一媒体（图片/视频），确认发布；底部带 EULA 协议链接
/// 设计：顶部渐变导航 + 虚线媒体选取区 + 独立输入卡片 + 渐变发布按钮 + 进场动画
/// 逻辑：发布前验证登录状态 → 标题/内容/媒体非空检测 → 调用 TitleViewModel 发布 → 清除数据
class Release_Maki: UIViewController {

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary = UIColor(hexstring_Maki: "#FF8C00")
        static let accent  = UIColor(hexstring_Maki: "#E8650A")
        static let bg      = UIColor(hexstring_Maki: "#FFFBF4")
        static let card    = UIColor.white
        static let tp      = UIColor(hexstring_Maki: "#1A0A00")
        static let ts      = UIColor(hexstring_Maki: "#8B7355")
        static let border  = UIColor(hexstring_Maki: "#F0EDE6")
    }

    /// 当前选中的分类标签索引（0 = Craft）
    private var selectedCategoryIdx_Maki: Int = 0

    // MARK: - 媒体相关状态

    private var selectedImage_Maki: UIImage?
    private var selectedVideoURL_Maki: URL?
    /// 存储媒体路径，用于发布数据
    private var mediaPath_Maki: String?

    // MARK: - UI 属性 / 主容器

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.alwaysBounceVertical = true
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.contentInsetAdjustmentBehavior = .never
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    // MARK: - UI 属性 / 顶部导航区

    private let navArea_Maki = UIView()
    private let navGrad_Maki = CAGradientLayer()
    private let navBubble1_Maki = UIView()
    private let navBubble2_Maki = UIView()

    // MARK: - UI 属性 / 媒体选取区

    /// 媒体选取外层容器（承载虚线边框层）
    private let mediaPickerView_Maki = UIView()
    /// 媒体预览组件（选取后显示）
    private let mediaDisplayView_Maki = MediaDisplayView_Maki()
    /// 未选取时的占位内容视图
    private let mediaPlaceholder_Maki = UIView()
    /// 占位图标
    private let mediaIcon_Maki: UIImageView = {
        let iv_maki = UIImageView(image: UIImage(systemName: "plus.rectangle.on.folder.fill"))
        iv_maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
        iv_maki.contentMode = .scaleAspectFit
        return iv_maki
    }()
    /// 占位主提示文字
    private let mediaHintLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text = "Add Photo or Video"
        lb_maki.font = .systemFont(ofSize: 15, weight: .semibold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#FF8C00")
        lb_maki.textAlignment = .center
        return lb_maki
    }()
    /// 占位副提示文字（支持格式）
    private let mediaSubHintLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text = "JPG · PNG · MP4"
        lb_maki.font = .systemFont(ofSize: 12)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        lb_maki.textAlignment = .center
        return lb_maki
    }()
    /// 已选取媒体后的更换按钮（右上角）
    private let mediaChangeBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("Change", for: .normal)
        btn_maki.setTitleColor(.white, for: .normal)
        btn_maki.titleLabel?.font = .systemFont(ofSize: 12, weight: .semibold)
        btn_maki.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        btn_maki.layer.cornerRadius = 12
        btn_maki.isHidden = true
        return btn_maki
    }()

    // MARK: - UI 属性 / 表单区

    /// 标题输入卡片
    private let postTitleField_Maki = ReleaseField_Maki(
        iconName_maki: "pencil.and.scribble",
        label: "Title",
        placeholder: "Give your creation a title..."
    )
    /// 内容输入卡片
    private let postContentView_Maki = ReleaseTextView_Maki(
        iconName_maki: "text.alignleft",
        label: "Story",
        placeholder: "Share the story behind this creation..."
    )

    // MARK: - UI 属性 / 发布按钮

    private let publishBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("  Publish Creation", for: .normal)
        btn_maki.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        btn_maki.setTitleColor(.white, for: .normal)
        btn_maki.tintColor = .white
        btn_maki.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn_maki.layer.cornerRadius = 16
        btn_maki.layer.shadowColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.4).cgColor
        btn_maki.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn_maki.layer.shadowRadius = 14
        btn_maki.layer.shadowOpacity = 1
        return btn_maki
    }()

    /// 发布按钮渐变层引用（用于 layoutSubviews 更新 frame）
    private let publishGrad_Maki = CAGradientLayer()

    /// EULA 协议链接标签
    private var eulaLabel_Maki: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        buildUI_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntranceAnimation_Maki()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navGrad_Maki.frame = navArea_Maki.bounds
        refreshMediaDashBorder_Maki()
    }
}

// MARK: - UI 构建

extension Release_Maki {

    /// 构建全部 UI 层级
    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }
        buildNavArea_Maki()
        buildMediaPicker_Maki()
        buildFormSection_Maki()
        buildPublishArea_Maki()
    }

    /// 构建顶部渐变导航区（渐变背景 + 装饰气泡 + 标题 + 关闭按钮）
    private func buildNavArea_Maki() {
        // 渐变背景（与首页/发现页保持统一）
        navGrad_Maki.colors = [
            UIColor(hexstring_Maki: "#E8650A").cgColor,
            UIColor(hexstring_Maki: "#FF9F1C").cgColor
        ]
        navGrad_Maki.startPoint = CGPoint(x: 0, y: 0)
        navGrad_Maki.endPoint   = CGPoint(x: 1, y: 1)
        navArea_Maki.layer.insertSublayer(navGrad_Maki, at: 0)
        contentView_Maki.addSubview(navArea_Maki)

        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        navArea_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(statusH_maki + 118)
        }

        // 装饰气泡（右上大泡）
        navBubble1_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        navBubble1_Maki.layer.cornerRadius = 55
        navArea_Maki.addSubview(navBubble1_Maki)
        navBubble1_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.trailing.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(-22)
        }

        // 装饰气泡（左下小泡）
        navBubble2_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        navBubble2_Maki.layer.cornerRadius = 32
        navArea_Maki.addSubview(navBubble2_Maki)
        navBubble2_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(64)
            make.leading.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(16)
        }

        // 页面主标题（居中）
        let titleLb_maki = UILabel()
        titleLb_maki.text = "Share Your Creation"
        titleLb_maki.font = UIFont(name: "Georgia-Bold", size: 22)
            ?? .systemFont(ofSize: 22, weight: .bold)
        titleLb_maki.textColor = .white
        navArea_Maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(statusH_maki + 20)
        }

        // 副标题
        let subLb_maki = UILabel()
        subLb_maki.text = "✨  Let the community see your craft"
        subLb_maki.font = .systemFont(ofSize: 12, weight: .light)
        subLb_maki.textColor = UIColor.white.withAlphaComponent(0.8)
        navArea_Maki.addSubview(subLb_maki)
        subLb_maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLb_maki.snp.bottom).offset(5)
        }

        // 三颗装饰星点（底部点缀）
        let dotsStack_maki = makeNavDotsView_Maki()
        navArea_Maki.addSubview(dotsStack_maki)
        dotsStack_maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-36)
        }

        // 底部圆角过渡条
        let decoBar_maki = UIView()
        decoBar_maki.backgroundColor = K_Maki.bg
        decoBar_maki.layer.cornerRadius = 22
        decoBar_maki.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navArea_Maki.addSubview(decoBar_maki)
        decoBar_maki.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(28)
        }
    }

    /// 创建导航区底部三颗装饰小圆点（步骤指示装饰）
    private func makeNavDotsView_Maki() -> UIView {
        let stack_maki = UIStackView()
        stack_maki.axis = .horizontal
        stack_maki.spacing = 6
        stack_maki.alignment = .center
        // 1号点（选中态，大）
        let dotConfigs_maki: [(CGFloat, CGFloat)] = [(8, 1.0), (5, 0.5), (5, 0.5)]
        for (size_maki, alpha_maki) in dotConfigs_maki {
            let dot_maki = UIView()
            dot_maki.backgroundColor = UIColor.white.withAlphaComponent(alpha_maki)
            dot_maki.layer.cornerRadius = size_maki / 2
            stack_maki.addArrangedSubview(dot_maki)
            dot_maki.snp.makeConstraints { $0.width.height.equalTo(size_maki) }
        }
        return stack_maki
    }

    /// 构建媒体选取区（虚线圆角边框 + 占位图标 + 预览组件 + 更换按钮）
    private func buildMediaPicker_Maki() {
        mediaPickerView_Maki.backgroundColor = UIColor(hexstring_Maki: "#FFF9F0")
        mediaPickerView_Maki.layer.cornerRadius = 20
        mediaPickerView_Maki.clipsToBounds = true

        contentView_Maki.addSubview(mediaPickerView_Maki)
        mediaPickerView_Maki.snp.makeConstraints { make in
            make.top.equalTo(navArea_Maki.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(210)
        }

        // 预览组件
        mediaPickerView_Maki.addSubview(mediaDisplayView_Maki)
        mediaDisplayView_Maki.isHidden = true
        mediaDisplayView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 占位内容
        mediaPickerView_Maki.addSubview(mediaPlaceholder_Maki)
        mediaPlaceholder_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 占位图标（圆形橙色背景）
        let iconWrap_maki = UIView()
        iconWrap_maki.backgroundColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.12)
        iconWrap_maki.layer.cornerRadius = 32
        mediaPlaceholder_Maki.addSubview(iconWrap_maki)
        iconWrap_maki.addSubview(mediaIcon_Maki)
        iconWrap_maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-22)
            make.width.height.equalTo(64)
        }
        mediaIcon_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }

        // 主提示文字
        mediaPlaceholder_Maki.addSubview(mediaHintLabel_Maki)
        mediaHintLabel_Maki.snp.makeConstraints { make in
            make.top.equalTo(iconWrap_maki.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        // 副提示文字
        mediaPlaceholder_Maki.addSubview(mediaSubHintLb_Maki)
        mediaSubHintLb_Maki.snp.makeConstraints { make in
            make.top.equalTo(mediaHintLabel_Maki.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        // 更换按钮（选取后显示在右上角）
        mediaPickerView_Maki.addSubview(mediaChangeBtn_Maki)
        mediaChangeBtn_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(28)
            make.width.equalTo(70)
        }
        mediaChangeBtn_Maki.addTarget(self, action: #selector(onPickMedia_Maki), for: .touchUpInside)

        // 点击整个区域选取媒体
        let tap_maki = UITapGestureRecognizer(target: self, action: #selector(onPickMedia_Maki))
        mediaPickerView_Maki.isUserInteractionEnabled = true
        mediaPickerView_Maki.addGestureRecognizer(tap_maki)
    }

    /// 使用 CAShapeLayer 绘制媒体区虚线边框（在 viewDidLayoutSubviews 调用刷新）
    private func refreshMediaDashBorder_Maki() {
        // 移除旧的虚线层，防止重复
        mediaPickerView_Maki.layer.sublayers?
            .filter { $0.name == "dashBorder_maki" }
            .forEach { $0.removeFromSuperlayer() }

        guard !mediaPickerView_Maki.bounds.isEmpty else { return }

        let dash_maki = CAShapeLayer()
        dash_maki.name = "dashBorder_maki"
        dash_maki.strokeColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.35).cgColor
        dash_maki.fillColor   = UIColor.clear.cgColor
        dash_maki.lineWidth   = 2
        dash_maki.lineDashPattern = [8, 5]
        dash_maki.path = UIBezierPath(roundedRect: mediaPickerView_Maki.bounds.insetBy(dx: 1, dy: 1),
                                      cornerRadius: 20).cgPath
        mediaPickerView_Maki.layer.addSublayer(dash_maki)
    }

    /// 构建表单区（区块标题 + 标题输入卡片 + 内容输入卡片）
    private func buildFormSection_Maki() {
        // 区块标题行
        let sectionHeader_maki = buildSectionHeader_Maki(icon_maki: "doc.text.fill", title_maki: "Post Details")
        contentView_Maki.addSubview(sectionHeader_maki)
        sectionHeader_maki.snp.makeConstraints { make in
            make.top.equalTo(mediaPickerView_Maki.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(20)
        }

        // 标题输入卡片
        contentView_Maki.addSubview(postTitleField_Maki)
        postTitleField_Maki.snp.makeConstraints { make in
            make.top.equalTo(sectionHeader_maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(68)
        }

        // 内容输入卡片
        contentView_Maki.addSubview(postContentView_Maki)
        postContentView_Maki.snp.makeConstraints { make in
            make.top.equalTo(postTitleField_Maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }

        // 分类标签区块标题
        let tagHeader_maki = buildSectionHeader_Maki(icon_maki: "tag.fill", title_maki: "Category")
        contentView_Maki.addSubview(tagHeader_maki)
        tagHeader_maki.snp.makeConstraints { make in
            make.top.equalTo(postContentView_Maki.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(20)
        }

        // 横向分类标签选择行
        let tagScrollView_maki = UIScrollView()
        tagScrollView_maki.showsHorizontalScrollIndicator = false
        tagScrollView_maki.alwaysBounceHorizontal = true
        let tagStack_maki = UIStackView()
        tagStack_maki.axis = .horizontal
        tagStack_maki.spacing = 8
        tagStack_maki.alignment = .center
        tagScrollView_maki.addSubview(tagStack_maki)
        contentView_Maki.addSubview(tagScrollView_maki)

        tagScrollView_maki.snp.makeConstraints { make in
            make.top.equalTo(tagHeader_maki.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(36)
        }
        tagStack_maki.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalToSuperview()
        }

        // 与发现页一致的分类和配色
        let categoryNames_maki  = ["Craft", "Art", "Food", "Travel", "Life"]
        let categoryColors_maki: [UIColor] = [
            UIColor(hexstring_Maki: "#9B59B6"),
            UIColor(hexstring_Maki: "#E74C3C"),
            UIColor(hexstring_Maki: "#27AE60"),
            UIColor(hexstring_Maki: "#2980B9"),
            UIColor(hexstring_Maki: "#E67E22")
        ]
        for (idx_maki, name_maki) in categoryNames_maki.enumerated() {
            let btn_maki = UIButton(type: .custom)
            btn_maki.setTitle(name_maki, for: .normal)
            btn_maki.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
            btn_maki.tag = idx_maki
            btn_maki.layer.cornerRadius = 12
            btn_maki.contentEdgeInsets = UIEdgeInsets(top: 5, left: 14, bottom: 5, right: 14)
            btn_maki.addTarget(self, action: #selector(onCategoryTap_Maki(_:)), for: .touchUpInside)
            // 初始：第 0 项选中
            applyTagStyle_Maki(btn_maki, color_maki: categoryColors_maki[idx_maki],
                               selected_maki: idx_maki == selectedCategoryIdx_Maki)
            tagStack_maki.addArrangedSubview(btn_maki)
        }
    }

    /// 构建区块标题行（图标 + 文字 + 右侧横线装饰）
    /// - Parameters:
    ///   - icon_maki: SF Symbol 图标名
    ///   - title_maki: 标题文字
    /// - Returns: 配置好的 UIView
    private func buildSectionHeader_Maki(icon_maki: String, title_maki: String) -> UIView {
        let wrap_maki = UIView()
        let iconIV_maki = UIImageView(image: UIImage(systemName: icon_maki))
        iconIV_maki.tintColor = K_Maki.primary
        iconIV_maki.contentMode = .scaleAspectFit
        let lb_maki = UILabel()
        lb_maki.text = title_maki
        lb_maki.font = .systemFont(ofSize: 13, weight: .bold)
        lb_maki.textColor = K_Maki.tp
        wrap_maki.addSubview(iconIV_maki)
        wrap_maki.addSubview(lb_maki)
        iconIV_maki.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        lb_maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_maki.snp.trailing).offset(6)
            make.centerY.trailing.equalToSuperview()
        }
        return wrap_maki
    }

    /// 构建发布按钮区（渐变发布按钮 + EULA 协议）
    private func buildPublishArea_Maki() {
        // 渐变层
        publishGrad_Maki.colors = [
            UIColor(hexstring_Maki: "#FF8C00").cgColor,
            UIColor(hexstring_Maki: "#E8650A").cgColor
        ]
        publishGrad_Maki.startPoint = CGPoint(x: 0, y: 0.5)
        publishGrad_Maki.endPoint   = CGPoint(x: 1, y: 0.5)
        publishGrad_Maki.cornerRadius = 16
        publishGrad_Maki.frame = CGRect(x: 0, y: 0, width: APPSCREEN_Maki.WIDTH_Maki - 40, height: 56)
        publishBtn_Maki.layer.insertSublayer(publishGrad_Maki, at: 0)

        contentView_Maki.addSubview(publishBtn_Maki)
        publishBtn_Maki.snp.makeConstraints { make in
            make.top.equalTo(postContentView_Maki.snp.bottom).offset(104)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }
        publishBtn_Maki.addTarget(self, action: #selector(onPublish_Maki), for: .touchUpInside)

        // EULA 协议链接
        let eulaLb_maki = ProtocolHelper_Maki.createProtocolTextLabel_Maki(
            firstProtocol_Maki: .eula_Maki,
            firstContent_Maki: "terms",
            secondProtocol_Maki: .privacy_Maki,
            secondContent_Maki: "privacy",
            config_Maki: .light_Maki(),
            from: self
        )
        eulaLabel_Maki = eulaLb_maki
        contentView_Maki.addSubview(eulaLb_maki)
        eulaLb_maki.snp.makeConstraints { make in
            make.top.equalTo(publishBtn_Maki.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
}

// MARK: - 进场动画

extension Release_Maki {

    /// 进场动画：媒体区 + 表单 + 发布按钮依次从下方弹入
    private func playEntranceAnimation_Maki() {
        let targets_maki: [UIView] = [mediaPickerView_Maki, postTitleField_Maki, postContentView_Maki, publishBtn_Maki]
        for (i_maki, v_maki) in targets_maki.enumerated() {
            v_maki.alpha = 0
            v_maki.transform = CGAffineTransform(translationX: 0, y: 28)
            UIView.animate(
                withDuration: 0.44,
                delay: Double(i_maki) * 0.08,
                usingSpringWithDamping: 0.78,
                initialSpringVelocity: 0.3,
                options: [],
                animations: {
                    v_maki.alpha = 1
                    v_maki.transform = .identity
                }
            )
        }
    }
}

// MARK: - 事件响应

extension Release_Maki {

    /// 分类标签点击：切换选中态 + 弹性动画
    @objc private func onCategoryTap_Maki(_ sender: UIButton) {
        guard sender.tag != selectedCategoryIdx_Maki else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let categoryColors_maki: [UIColor] = [
            UIColor(hexstring_Maki: "#9B59B6"),
            UIColor(hexstring_Maki: "#E74C3C"),
            UIColor(hexstring_Maki: "#27AE60"),
            UIColor(hexstring_Maki: "#2980B9"),
            UIColor(hexstring_Maki: "#E67E22")
        ]
        // 找同级所有标签按钮，刷新样式
        if let stack_maki = sender.superview as? UIStackView {
            stack_maki.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { btn_maki in
                let color_maki = categoryColors_maki[btn_maki.tag % categoryColors_maki.count]
                applyTagStyle_Maki(btn_maki, color_maki: color_maki, selected_maki: btn_maki.tag == sender.tag)
            }
        }
        selectedCategoryIdx_Maki = sender.tag
        // 弹性缩放反馈
        UIView.animate(withDuration: 0.12, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2, delay: 0,
                           usingSpringWithDamping: 0.55, initialSpringVelocity: 0.4,
                           options: [], animations: { sender.transform = .identity })
        })
    }

    /// 应用标签按钮选中/未选中样式
    private func applyTagStyle_Maki(_ btn_maki: UIButton, color_maki: UIColor, selected_maki: Bool) {
        if selected_maki {
            btn_maki.backgroundColor = color_maki
            btn_maki.setTitleColor(.white, for: .normal)
            btn_maki.layer.shadowColor  = color_maki.withAlphaComponent(0.45).cgColor
            btn_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
            btn_maki.layer.shadowRadius = 6
            btn_maki.layer.shadowOpacity = 1
        } else {
            btn_maki.backgroundColor = .white
            btn_maki.setTitleColor(UIColor(hexstring_Maki: "#8B7355"), for: .normal)
            btn_maki.layer.shadowColor  = UIColor.black.withAlphaComponent(0.06).cgColor
            btn_maki.layer.shadowOffset = CGSize(width: 0, height: 2)
            btn_maki.layer.shadowRadius = 4
            btn_maki.layer.shadowOpacity = 1
        }
    }

    /// 打开相册选取图片或视频
    @objc private func onPickMedia_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        MediaPickerHelper_Maki.pickMedia_Maki(from: self) { [weak self] result_maki in
            guard let self else { return }
            switch result_maki {
            case .photo_Maki(let image_maki):
                self.selectedImage_Maki    = image_maki
                self.selectedVideoURL_Maki = nil
                self.mediaDisplayView_Maki.configureWithImage_Maki(image_Maki: image_maki)
                self.showMediaPreview_Maki()
                self.mediaPath_Maki = self.saveImageToDocuments_Maki(image_maki)
            case .video_Maki(let url_maki):
                self.selectedVideoURL_Maki = url_maki
                self.selectedImage_Maki    = nil
                self.mediaDisplayView_Maki.configure_Maki(mediaPath_Maki: url_maki.path, isVideo_Maki: true)
                self.showMediaPreview_Maki()
                self.mediaPath_Maki = url_maki.lastPathComponent
            case .cancelled_Maki:
                break
            }
        }
    }

    /// 切换媒体区到预览状态（隐藏占位，显示预览和更换按钮）
    private func showMediaPreview_Maki() {
        mediaDisplayView_Maki.isHidden = false
        mediaPlaceholder_Maki.isHidden = true
        mediaChangeBtn_Maki.isHidden   = false
        // 选取成功轻微缩放反馈
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.65,
            initialSpringVelocity: 0.4,
            options: [],
            animations: {
                self.mediaPickerView_Maki.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            }, completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.mediaPickerView_Maki.transform = .identity
                }
            }
        )
    }

    /// 确认发布帖子
    @objc private func onPublish_Maki() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // 发布按钮按压动画
        UIView.animate(withDuration: 0.1, animations: {
            self.publishBtn_Maki.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.15) {
                self.publishBtn_Maki.transform = .identity
            }
        })

        // 1. 验证登录状态
        guard UserViewModel_Maki.shared_Maki.isLoggedIn_Maki else {
            Load_Maki.showWarning_Maki(message_Maki: "Please log in first")
            Navigation_Maki.toLogin_Maki(style_maki: .present_maki)
            return
        }
        // 2. 验证字段非空
        let title_maki   = postTitleField_Maki.currentValue_Maki.trimmingCharacters(in: .whitespaces)
        let content_maki = postContentView_Maki.currentValue_Maki.trimmingCharacters(in: .whitespaces)
        guard !title_maki.isEmpty else {
            Load_Maki.showWarning_Maki(message_Maki: "Please enter a title")
            return
        }
        guard !content_maki.isEmpty else {
            Load_Maki.showWarning_Maki(message_Maki: "Please enter some content")
            return
        }
        guard let path_maki = mediaPath_Maki else {
            Load_Maki.showWarning_Maki(message_Maki: "Please add a photo or video")
            return
        }
        // 3. 调用 ViewModel 发布
        TitleViewModel_Maki.shared_Maki.releasePost_Maki(
            title_maki: title_maki,
            content_maki: content_maki,
            media_maki: path_maki
        )
        // 4. 清除表单并关闭页面
        clearForm_Maki()
        Load_Maki.showSuccess_Maki(message_Maki: "Published successfully!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            Navigation_Maki.dismiss_Maki()
        }
    }

    /// 清空所有表单数据，恢复媒体区占位状态
    private func clearForm_Maki() {
        postTitleField_Maki.clearValue_Maki()
        postContentView_Maki.clearValue_Maki()
        mediaPath_Maki         = nil
        selectedImage_Maki     = nil
        selectedVideoURL_Maki  = nil
        mediaDisplayView_Maki.isHidden = true
        mediaPlaceholder_Maki.isHidden = false
        mediaChangeBtn_Maki.isHidden   = true
    }

    /// 将图片保存到 Documents 目录，返回文件名
    /// - Parameter image_maki: 待保存的图片
    /// - Returns: 保存的文件名（用于帖子媒体路径）
    private func saveImageToDocuments_Maki(_ image_maki: UIImage) -> String {
        let filename_maki = "post_\(Int(Date().timeIntervalSince1970)).jpg"
        let url_maki = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename_maki)
        if let data_maki = image_maki.jpegData(compressionQuality: 0.85) {
            try? data_maki.write(to: url_maki)
        }
        return filename_maki
    }
}

// MARK: - ReleaseField_Maki（发布页带图标输入框卡片）

/// 发布页带图标标签的单行文本输入卡片
/// 功能：左侧 SF Symbol 图标 + 上方小标签 + 输入框 + 聚焦时橙色边框高亮
final class ReleaseField_Maki: UIView {

    // MARK: UI 子视图

    /// SF Symbol 图标
    private let iconIV_Maki: UIImageView = {
        let iv_maki = UIImageView()
        iv_maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
        iv_maki.contentMode = .scaleAspectFit
        return iv_maki
    }()
    /// 字段标签（大写）
    private let labelLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 10, weight: .bold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        return lb_maki
    }()
    /// 文本输入框
    private let tf_Maki: UITextField = {
        let tf_maki = UITextField()
        tf_maki.font = .systemFont(ofSize: 15, weight: .medium)
        tf_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        tf_maki.autocorrectionType = .no
        return tf_maki
    }()

    /// 当前输入内容
    var currentValue_Maki: String { tf_Maki.text ?? "" }

    // MARK: 初始化

    init(iconName_maki: String, label: String, placeholder: String) {
        super.init(frame: .zero)
        iconIV_Maki.image = UIImage(systemName: iconName_maki)
        labelLb_Maki.text = label.uppercased()
        tf_Maki.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(hexstring_Maki: "#C0A880")]
        )
        setupAppearance_Maki()
        setupLayout_Maki()
        tf_Maki.delegate = self
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: 外观设置

    /// 配置卡片外观（白色背景、圆角、阴影）
    private func setupAppearance_Maki() {
        backgroundColor = .white
        layer.cornerRadius = 14
        layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 8
        layer.shadowOpacity = 1
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(hexstring_Maki: "#F0EDE6").cgColor
    }

    /// 建立内部约束
    private func setupLayout_Maki() {
        addSubview(iconIV_Maki)
        addSubview(labelLb_Maki)
        addSubview(tf_Maki)

        iconIV_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        labelLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_Maki.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(12)
        }
        tf_Maki.snp.makeConstraints { make in
            make.top.equalTo(labelLb_Maki.snp.bottom).offset(3)
            make.leading.equalTo(labelLb_Maki)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-10)
        }
    }

    // MARK: 公共方法

    func clearValue_Maki() { tf_Maki.text = nil }
}

extension ReleaseField_Maki: UITextFieldDelegate {

    /// 聚焦时加强橙色边框高亮
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.55).cgColor
            self.layer.shadowColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.12).cgColor
        }
    }

    /// 失焦时恢复默认边框
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = UIColor(hexstring_Maki: "#F0EDE6").cgColor
            self.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        }
    }
}

// MARK: - ReleaseTextView_Maki（发布页带图标多行文本输入卡片）

/// 发布页带图标标签的多行文本输入卡片
/// 功能：左上角 SF Symbol 图标 + 标签 + 多行 UITextView + 右下角字数统计 + 聚焦高亮
final class ReleaseTextView_Maki: UIView {

    // MARK: UI 子视图

    private let iconIV_Maki: UIImageView = {
        let iv_maki = UIImageView()
        iv_maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
        iv_maki.contentMode = .scaleAspectFit
        return iv_maki
    }()
    private let labelLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 10, weight: .bold)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        return lb_maki
    }()
    private let tv_Maki: UITextView = {
        let tv_maki = UITextView()
        tv_maki.font = .systemFont(ofSize: 15)
        tv_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        tv_maki.backgroundColor = .clear
        tv_maki.textContainerInset = .zero
        tv_maki.textContainer.lineFragmentPadding = 0
        return tv_maki
    }()
    private let placeholder_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 15)
        lb_maki.textColor = UIColor(hexstring_Maki: "#C0A880")
        lb_maki.numberOfLines = 0
        return lb_maki
    }()
    /// 右下角字数统计标签
    private let countLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.text = "0"
        lb_maki.font = .systemFont(ofSize: 10, weight: .medium)
        lb_maki.textColor = UIColor(hexstring_Maki: "#8B7355").withAlphaComponent(0.5)
        lb_maki.textAlignment = .right
        return lb_maki
    }()

    var currentValue_Maki: String { tv_Maki.text ?? "" }

    // MARK: 初始化

    init(iconName_maki: String, label: String, placeholder: String) {
        super.init(frame: .zero)
        iconIV_Maki.image = UIImage(systemName: iconName_maki)
        labelLb_Maki.text = label.uppercased()
        placeholder_Maki.text = placeholder
        tv_Maki.delegate = self
        setupAppearance_Maki()
        setupLayout_Maki()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: 外观与布局

    private func setupAppearance_Maki() {
        backgroundColor = .white
        layer.cornerRadius = 14
        layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = 8
        layer.shadowOpacity = 1
        layer.borderWidth = 1.5
        layer.borderColor = UIColor(hexstring_Maki: "#F0EDE6").cgColor
    }

    private func setupLayout_Maki() {
        addSubview(iconIV_Maki)
        addSubview(labelLb_Maki)
        addSubview(tv_Maki)
        addSubview(placeholder_Maki)
        addSubview(countLb_Maki)

        iconIV_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(13)
            make.width.height.equalTo(20)
        }
        labelLb_Maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_Maki.snp.trailing).offset(10)
            make.centerY.equalTo(iconIV_Maki)
        }
        tv_Maki.snp.makeConstraints { make in
            make.top.equalTo(labelLb_Maki.snp.bottom).offset(6)
            make.leading.equalTo(labelLb_Maki)
            make.trailing.equalToSuperview().offset(-14)
            make.bottom.equalToSuperview().offset(-26)
        }
        placeholder_Maki.snp.makeConstraints { $0.edges.equalTo(tv_Maki) }
        countLb_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-8)
        }
    }

    // MARK: 公共方法

    func clearValue_Maki() {
        tv_Maki.text = nil
        placeholder_Maki.isHidden = false
        countLb_Maki.text = "0"
    }
}

extension ReleaseTextView_Maki: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.55).cgColor
            self.layer.shadowColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.12).cgColor
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            self.layer.borderColor = UIColor(hexstring_Maki: "#F0EDE6").cgColor
            self.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholder_Maki.isHidden = !textView.text.isEmpty
        countLb_Maki.text = "\(textView.text.count)"
        // 字数较多时字数标签变橙色提示
        countLb_Maki.textColor = textView.text.count > 200
            ? UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.8)
            : UIColor(hexstring_Maki: "#8B7355").withAlphaComponent(0.5)
    }
}
