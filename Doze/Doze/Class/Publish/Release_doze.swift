import UIKit
import SnapKit

// MARK: 发布页

/// 宠物睡眠日志发布页
/// 设计风格：浅色清新主题 + 渐变英雄区 + 卡片式表单 + 流光渐变 CTA
/// 布局层次：顶部导航栏 → 英雄横幅 → ScrollView（媒体上传 → 宠物类别 → 标题卡 → 正文卡 → 发布按钮 → EULA）
class Release_Doze: UIViewController {

    // MARK: - 常量

    /// 正文最大字数
    private let maxContentLength_Doze = 500

    // MARK: - 逻辑层

    private let logic_Doze = ReleaseLogic_Doze.shared_Doze

    // MARK: - 状态

    /// 已选媒体路径，nil 表示未选择
    private var selectedMediaPath_Doze: String?

    /// 已选宠物类别（默认猫咪）
    private var selectedCategory_Doze: PetCategory_Doze = .cat_doze

    /// 当前激活的分类按钮
    private var activeCategoryBtn_Doze: UIButton?

    // MARK: - 顶部导航栏

    private let navBar_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    /// 左侧主标题
    private let navTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Pet Memory"
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        return lbl
    }()

    /// 副标题描述
    private let navSubtitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Record your pet's beautiful moments"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        return lbl
    }()

    /// 右侧装饰图标（无功能）
    private let navDecoIconView_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iv.image = UIImage(systemName: "pawprint.circle.fill", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.35)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 英雄横幅

    /// 渐变英雄卡片：营造情绪感与视觉层次
    private let heroBanner_Doze: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()

    private let heroBannerGradient_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(hexstring_Doze: "#EDE7FB").cgColor,
            UIColor(hexstring_Doze: "#E3F2FD").cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 1, y: 1)
        return gl
    }()

    private let heroTitleLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Share Your Pet's\nSleep Story"
        lbl.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        lbl.numberOfLines = 2
        return lbl
    }()

    private let heroDescLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Capture precious nap moments\nand share them with the community"
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        lbl.numberOfLines = 2
        return lbl
    }()

    /// 英雄区右侧月亮装饰图
    private let heroIllustration_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 60, weight: .thin)
        iv.image = UIImage(systemName: "moon.zzz.fill", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.25)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 英雄区装饰圆点（左下）
    private let heroCircle1_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Doze.primaryGradientEnd_Doze.withAlphaComponent(0.2)
        v.layer.cornerRadius = 30
        return v
    }()

    /// 英雄区装饰圆点（右上）
    private let heroCircle2_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.15)
        v.layer.cornerRadius = 20
        return v
    }()

    // MARK: - 内容滚动区

    private let scrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.keyboardDismissMode = .onDrag
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let scrollContent_Doze = UIView()

    // MARK: - 媒体上传卡片

    private let mediaCard_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 1
        v.clipsToBounds = false
        return v
    }()

    /// 媒体卡内层（用于裁剪内容，不影响外层阴影）
    private let mediaCardInner_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Doze: "#F8F6FF")
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()

    private let mediaIconView_Doze: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "moon.zzz.fill")
        iv.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 上传按钮圆圈（中心"+"）
    private let mediaUploadCircle_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.12)
        v.layer.cornerRadius = 34
        return v
    }()

    private let mediaUploadPlus_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iv.image = UIImage(systemName: "plus", withConfiguration: cfg)
        iv.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let mediaHintLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Add Cover Photo"
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        lbl.textAlignment = .center
        return lbl
    }()

    private let mediaSubHintLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Capture your pet's sleep moment"
        lbl.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textPlaceholder_Doze
        lbl.textAlignment = .center
        return lbl
    }()

    /// 已选图片预览（叠加在媒体卡上）
    private let mediaPreviewImageView_Doze: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.isHidden = true
        return iv
    }()

    /// 预览状态下右上角更换按钮
    private let mediaChangeButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn.setImage(UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        btn.layer.cornerRadius = 18
        btn.isHidden = true
        return btn
    }()

    // MARK: - 宠物分类

    private let categorySectionLabel_Doze = Release_Doze.makeSectionLabel_Doze("hare.fill", "Pet Type")

    private let categoryScrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        return sv
    }()

    private let categoryStack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.alignment = .center
        return sv
    }()

    // MARK: - 标题输入

    private let titleSectionLabel_Doze = Release_Doze.makeSectionLabel_Doze("pencil", "Title")

    /// 标题输入外层卡片容器
    private let titleCard_Doze: UIView = Release_Doze.makeFormCard_Doze()

    private let titleTextField_Doze: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "e.g. Luna's Deep Sleep Tonight",
            attributes: [.foregroundColor: ColorConfig_Doze.textPlaceholder_Doze]
        )
        tf.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf.textColor = ColorConfig_Doze.textPrimary_Doze
        tf.backgroundColor = .clear
        tf.returnKeyType = .next
        return tf
    }()

    /// 标题字数角标
    private let titleCountBadge_Doze = Release_Doze.makeCountBadge_Doze("0 / 60")

    // MARK: - 正文输入

    private let contentSectionLabel_Doze = Release_Doze.makeSectionLabel_Doze("note.text", "Notes")

    /// 正文输入外层卡片容器
    private let contentCard_Doze: UIView = Release_Doze.makeFormCard_Doze()

    private let contentTextView_Doze: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv.textColor = ColorConfig_Doze.textPrimary_Doze
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tv.textContainer.lineFragmentPadding = 0
        tv.isScrollEnabled = false
        return tv
    }()

    private let contentPlaceholderLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.text = "Describe what you observed during this sleep session..."
        lbl.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textPlaceholder_Doze
        lbl.numberOfLines = 0
        lbl.isUserInteractionEnabled = false
        return lbl
    }()

    /// 正文字数角标
    private let contentCountBadge_Doze = Release_Doze.makeCountBadge_Doze("0 / 500")

    // MARK: - 底部发布大按钮

    private let publishBigButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Publish Sleep Log", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 28
        btn.clipsToBounds = true
        return btn
    }()

    private let publishBigBtnGradient_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        gl.startPoint = CGPoint(x: 0, y: 0.5)
        gl.endPoint = CGPoint(x: 1, y: 0.5)
        return gl
    }()

    /// 发布按钮左侧爪子图标
    private let publishBtnPawIcon_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        iv.image = UIImage(systemName: "pawprint.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.75)
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        return iv
    }()

    // MARK: - EULA 文本按钮

    /// 用户许可协议跳转按钮
    private let eulaButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: ColorConfig_Doze.primaryGradientStart_Doze,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: ColorConfig_Doze.primaryGradientStart_Doze
        ]
        btn.setAttributedTitle(NSAttributedString(string: "EULA", attributes: attrs), for: .normal)
        return btn
    }()

    // MARK: - 静态工厂

    /// 创建带图标前缀的 section 标题行（icon + label + 渐变色点缀）
    private static func makeSectionLabel_Doze(_ icon: String, _ text: String) -> UIView {
        let container = UIView()

        // 左侧渐变色竖条
        let bar = UIView()
        bar.layer.cornerRadius = 2
        let barGl = CAGradientLayer()
        barGl.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        barGl.startPoint = CGPoint(x: 0, y: 0)
        barGl.endPoint = CGPoint(x: 0, y: 1)
        barGl.cornerRadius = 2
        bar.layer.insertSublayer(barGl, at: 0)
        container.addSubview(bar)
        bar.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(18)
        }

        // 图标
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        iv.image = UIImage(systemName: icon, withConfiguration: cfg)
        iv.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        iv.contentMode = .scaleAspectFit
        container.addSubview(iv)
        iv.snp.makeConstraints { make in
            make.left.equalTo(bar.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        // 标题文字
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        container.addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.left.equalTo(iv.snp.right).offset(6)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }

        container.snp.makeConstraints { make in
            make.height.equalTo(24)
        }

        // 延迟设置渐变 bar 的 frame（在布局时执行）
        DispatchQueue.main.async {
            barGl.frame = bar.bounds
        }

        return container
    }

    /// 创建表单输入外层白色卡片
    private static func makeFormCard_Doze() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 3)
        v.layer.shadowRadius = 10
        v.layer.shadowOpacity = 1
        return v
    }

    /// 创建字数角标 Badge（胶囊形）
    private static func makeCountBadge_Doze(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        lbl.textColor = ColorConfig_Doze.textPlaceholder_Doze
        lbl.backgroundColor = ColorConfig_Doze.backgroundPrimary_Doze
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 9
        lbl.clipsToBounds = true
        return lbl
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Doze.backgroundPrimary_Doze
        setupNavBar_Doze()
        setupHeroBanner_Doze()
        setupScrollView_Doze()
        setupMediaCard_Doze()
        setupCategorySection_Doze()
        setupTitleSection_Doze()
        setupContentSection_Doze()
        setupPublishButton_Doze()
        setupKeyboardHandling_Doze()
        animateEntrance_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        publishBigBtnGradient_Doze.frame = publishBigButton_Doze.bounds
        heroBannerGradient_Doze.frame = heroBanner_Doze.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 顶部导航栏搭建

    private func setupNavBar_Doze() {
        view.addSubview(navBar_Doze)
        navBar_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }

        // 左侧标题纵向组合
        let titleStack_Doze = UIStackView(arrangedSubviews: [navTitleLabel_Doze, navSubtitleLabel_Doze])
        titleStack_Doze.axis = .vertical
        titleStack_Doze.alignment = .leading
        titleStack_Doze.spacing = 1
        navBar_Doze.addSubview(titleStack_Doze)
        titleStack_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        // 右侧装饰图标（视觉平衡）
        navBar_Doze.addSubview(navDecoIconView_Doze)
        navDecoIconView_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
        }

        // 底部细分割线
        let separator = UIView()
        separator.backgroundColor = ColorConfig_Doze.divider_Doze
        navBar_Doze.addSubview(separator)
        separator.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    // MARK: - 英雄横幅搭建

    private func setupHeroBanner_Doze() {
        heroBanner_Doze.layer.insertSublayer(heroBannerGradient_Doze, at: 0)

        view.addSubview(heroBanner_Doze)
        heroBanner_Doze.snp.makeConstraints { make in
            make.top.equalTo(navBar_Doze.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(110)
        }

        // 左下装饰圆
        heroBanner_Doze.addSubview(heroCircle1_Doze)
        heroCircle1_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(15)
            make.width.height.equalTo(60)
        }

        // 右上装饰圆
        heroBanner_Doze.addSubview(heroCircle2_Doze)
        heroCircle2_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-50)
            make.top.equalToSuperview().offset(-10)
            make.width.height.equalTo(40)
        }

        // 右侧月亮插图
        heroBanner_Doze.addSubview(heroIllustration_Doze)
        heroIllustration_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(80)
        }

        // 主标题
        heroBanner_Doze.addSubview(heroTitleLabel_Doze)
        heroTitleLabel_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(18)
            make.right.equalTo(heroIllustration_Doze.snp.left).offset(-8)
        }

        // 副描述
        heroBanner_Doze.addSubview(heroDescLabel_Doze)
        heroDescLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(heroTitleLabel_Doze.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(18)
            make.right.equalTo(heroIllustration_Doze.snp.left).offset(-8)
        }

        // 英雄横幅浮入动画
        heroBanner_Doze.alpha = 0
        heroBanner_Doze.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
    }

    // MARK: - 滚动容器搭建

    private func setupScrollView_Doze() {
        view.addSubview(scrollView_Doze)
        scrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(heroBanner_Doze.snp.bottom).offset(14)
            make.left.right.bottom.equalToSuperview()
        }
        scrollView_Doze.addSubview(scrollContent_Doze)
        scrollContent_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    // MARK: - 媒体上传卡片搭建

    private func setupMediaCard_Doze() {
        scrollContent_Doze.addSubview(mediaCard_Doze)
        mediaCard_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(190)
        }

        // 内层裁剪视图（保留圆角同时允许外层有阴影）
        mediaCard_Doze.addSubview(mediaCardInner_Doze)
        mediaCardInner_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 上传圆圈背景
        mediaCardInner_Doze.addSubview(mediaUploadCircle_Doze)
        mediaUploadCircle_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-22)
            make.width.height.equalTo(68)
        }

        // "+" 图标
        mediaUploadCircle_Doze.addSubview(mediaUploadPlus_Doze)
        mediaUploadPlus_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }

        // 宠物类别图标（叠加在圆圈右下角）
        mediaCardInner_Doze.addSubview(mediaIconView_Doze)
        mediaIconView_Doze.snp.makeConstraints { make in
            make.centerX.equalTo(mediaUploadCircle_Doze.snp.right).offset(-6)
            make.centerY.equalTo(mediaUploadCircle_Doze.snp.bottom).offset(-6)
            make.width.height.equalTo(20)
        }

        // 主提示文字
        mediaCardInner_Doze.addSubview(mediaHintLabel_Doze)
        mediaHintLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(mediaUploadCircle_Doze.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }

        // 副提示文字
        mediaCardInner_Doze.addSubview(mediaSubHintLabel_Doze)
        mediaSubHintLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(mediaHintLabel_Doze.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        addMediaIconPulseAnim_Doze()

        // 图片预览层
        scrollContent_Doze.addSubview(mediaPreviewImageView_Doze)
        mediaPreviewImageView_Doze.snp.makeConstraints { make in
            make.edges.equalTo(mediaCard_Doze)
        }

        // 右上角更换按钮
        scrollContent_Doze.addSubview(mediaChangeButton_Doze)
        mediaChangeButton_Doze.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Doze).offset(12)
            make.right.equalTo(mediaCard_Doze).offset(-12)
            make.width.height.equalTo(36)
        }
        mediaChangeButton_Doze.addTarget(self, action: #selector(handleMediaTap_Doze), for: .touchUpInside)

        // 卡片整体点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleMediaTap_Doze))
        mediaCard_Doze.addGestureRecognizer(tap)
    }

    /// 媒体图标呼吸脉冲动画
    private func addMediaIconPulseAnim_Doze() {
        let anim = CABasicAnimation(keyPath: "transform.scale")
        anim.fromValue = 1.0
        anim.toValue = 1.10
        anim.duration = 2.0
        anim.autoreverses = true
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        mediaUploadCircle_Doze.layer.add(anim, forKey: "pulse_doze")
    }

    // MARK: - 宠物分类区搭建

    private func setupCategorySection_Doze() {
        scrollContent_Doze.addSubview(categorySectionLabel_Doze)
        categorySectionLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Doze.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        scrollContent_Doze.addSubview(categoryScrollView_Doze)
        categoryScrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(categorySectionLabel_Doze.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.height.equalTo(42)
        }

        categoryScrollView_Doze.addSubview(categoryStack_Doze)
        categoryStack_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        let leadSpacer = UIView()
        leadSpacer.snp.makeConstraints { make in make.width.equalTo(20) }
        categoryStack_Doze.addArrangedSubview(leadSpacer)

        for (i, cat) in PetCategory_Doze.allCases.enumerated() {
            guard cat != .all_doze else { continue }
            let btn = makeCategoryChip_Doze(category_doze: cat)
            btn.tag = i
            btn.addTarget(self, action: #selector(categoryChipTapped_Doze(_:)), for: .touchUpInside)
            categoryStack_Doze.addArrangedSubview(btn)
            if cat == .cat_doze {
                setActiveCategoryChip_Doze(btn)
            }
        }

        let trailSpacer = UIView()
        trailSpacer.snp.makeConstraints { make in make.width.equalTo(20) }
        categoryStack_Doze.addArrangedSubview(trailSpacer)
    }

    /// 创建分类 Chip 按钮（胶囊型 + 图标）
    private func makeCategoryChip_Doze(category_doze: PetCategory_Doze) -> UIButton {
        let btn = UIButton(type: .custom)
        let icon = UIImage(systemName: category_doze.iconName_Doze)?
            .withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.setTitle("  \(category_doze.rawValue)", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        btn.setTitleColor(ColorConfig_Doze.textSecondary_Doze, for: .normal)
        btn.tintColor = ColorConfig_Doze.textSecondary_Doze
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 16
        btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 6
        btn.layer.shadowOpacity = 1
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        btn.snp.makeConstraints { make in make.height.equalTo(36) }
        return btn
    }

    /// 更新激活分类按钮样式
    private func setActiveCategoryChip_Doze(_ button_doze: UIButton) {
        activeCategoryBtn_Doze?.backgroundColor = .white
        activeCategoryBtn_Doze?.setTitleColor(ColorConfig_Doze.textSecondary_Doze, for: .normal)
        activeCategoryBtn_Doze?.tintColor = ColorConfig_Doze.textSecondary_Doze
        activeCategoryBtn_Doze?.layer.shadowOpacity = 1

        button_doze.backgroundColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.12)
        button_doze.setTitleColor(ColorConfig_Doze.primaryGradientStart_Doze, for: .normal)
        button_doze.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        button_doze.layer.shadowColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.3).cgColor
        button_doze.layer.shadowOpacity = 1
        button_doze.animatePulse_Doze()
        activeCategoryBtn_Doze = button_doze
    }

    // MARK: - 标题输入区搭建

    private func setupTitleSection_Doze() {
        scrollContent_Doze.addSubview(titleSectionLabel_Doze)
        titleSectionLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(categoryScrollView_Doze.snp.bottom).offset(28)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        scrollContent_Doze.addSubview(titleCard_Doze)
        titleCard_Doze.snp.makeConstraints { make in
            make.top.equalTo(titleSectionLabel_Doze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }

        // 输入框
        titleCard_Doze.addSubview(titleTextField_Doze)
        titleTextField_Doze.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(24)
        }

        // 字数角标（右下角）
        scrollContent_Doze.addSubview(titleCountBadge_Doze)
        titleCountBadge_Doze.snp.makeConstraints { make in
            make.top.equalTo(titleCard_Doze.snp.bottom).offset(6)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(50)
        }
        titleCountBadge_Doze.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        titleTextField_Doze.addTarget(self, action: #selector(titleEditChanged_Doze), for: .editingChanged)
        titleTextField_Doze.delegate = self
    }

    // MARK: - 正文输入区搭建

    private func setupContentSection_Doze() {
        scrollContent_Doze.addSubview(contentSectionLabel_Doze)
        contentSectionLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(titleCountBadge_Doze.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        scrollContent_Doze.addSubview(contentCard_Doze)
        contentCard_Doze.snp.makeConstraints { make in
            make.top.equalTo(contentSectionLabel_Doze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(20)
        }

        contentCard_Doze.addSubview(contentTextView_Doze)
        contentTextView_Doze.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(14)
            make.left.right.equalToSuperview().inset(16)
            make.height.greaterThanOrEqualTo(120)
        }

        // 占位符（跟随 textView 位置）
        contentCard_Doze.addSubview(contentPlaceholderLabel_Doze)
        contentPlaceholderLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(contentTextView_Doze)
            make.left.right.equalTo(contentTextView_Doze)
        }

        scrollContent_Doze.addSubview(contentCountBadge_Doze)
        contentCountBadge_Doze.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Doze.snp.bottom).offset(6)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(18)
            make.width.greaterThanOrEqualTo(56)
        }

        contentTextView_Doze.delegate = self
    }

    // MARK: - 底部发布大按钮搭建

    private func setupPublishButton_Doze() {
        publishBigButton_Doze.layer.insertSublayer(publishBigBtnGradient_Doze, at: 0)
        scrollContent_Doze.addSubview(publishBigButton_Doze)
        publishBigButton_Doze.snp.makeConstraints { make in
            make.top.equalTo(contentCountBadge_Doze.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }

        // 左侧爪子图标
        publishBigButton_Doze.addSubview(publishBtnPawIcon_Doze)
        publishBtnPawIcon_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        publishBigButton_Doze.addTarget(self, action: #selector(handlePost_Doze), for: .touchUpInside)
        addPublishButtonShimmer_Doze()

        // EULA 文本按钮（发布按钮下方 10）
        scrollContent_Doze.addSubview(eulaButton_Doze)
        eulaButton_Doze.snp.makeConstraints { make in
            make.top.equalTo(publishBigButton_Doze.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-120)
        }
        eulaButton_Doze.addTarget(self, action: #selector(handleEULA_Doze), for: .touchUpInside)
    }

    /// 添加发布按钮流光动画
    private func addPublishButtonShimmer_Doze() {
        let shimmer = CAGradientLayer()
        shimmer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0.18).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        shimmer.startPoint = CGPoint(x: 0, y: 0.5)
        shimmer.endPoint = CGPoint(x: 1, y: 0.5)
        shimmer.locations = [0, 0.5, 1.0]
        publishBigButton_Doze.layer.addSublayer(shimmer)

        let anim = CABasicAnimation(keyPath: "locations")
        anim.fromValue = [-0.5, -0.25, 0]
        anim.toValue = [1.0, 1.25, 1.5]
        anim.duration = 2.6
        anim.repeatCount = .infinity
        anim.beginTime = CACurrentMediaTime() + 1.0
        shimmer.add(anim, forKey: "shimmer_doze")
    }

    // MARK: - 键盘避让

    private func setupKeyboardHandling_Doze() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Doze(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Doze(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - 入场动画

    private func animateEntrance_Doze() {
        // 英雄横幅弹入
        UIView.animate(
            withDuration: 0.6,
            delay: 0.05,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3,
            options: [.curveEaseOut]
        ) {
            self.heroBanner_Doze.alpha = 1
            self.heroBanner_Doze.transform = .identity
        }

        // 滚动区元素依次浮入
        let targets: [UIView] = [
            mediaCard_Doze,
            categorySectionLabel_Doze, categoryScrollView_Doze,
            titleSectionLabel_Doze, titleCard_Doze,
            contentSectionLabel_Doze, contentCard_Doze,
            publishBigButton_Doze, eulaButton_Doze
        ]
        targets.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: 20)
        }
        for (i, v) in targets.enumerated() {
            UIView.animate(
                withDuration: 0.48,
                delay: 0.1 + Double(i) * 0.04,
                usingSpringWithDamping: 0.84,
                initialSpringVelocity: 0.3,
                options: [.curveEaseOut]
            ) {
                v.alpha = 1
                v.transform = .identity
            }
        }
    }

    // MARK: - 事件处理

    /// 发布
    @objc private func handlePost_Doze() {
        view.endEditing(true)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // 优先校验登录状态，未登录跳转登录页
        guard logic_Doze.isLoggedIn_Doze() else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                Navigation_Doze.toLogin_Doze(style_doze: .present_doze)
            }
            return
        }

        let title = titleTextField_Doze.text ?? ""
        let content = contentTextView_Doze.text ?? ""
        let (valid, msg) = logic_Doze.validateInputs_Doze(title_doze: title, content_doze: content)

        guard valid else {
            Utils_Doze.showWarning_Doze(message_Doze: msg)
            publishBigButton_Doze.animateShake_Doze()
            return
        }

        publishBigButton_Doze.animatePressDown_Doze {
            self.publishBigButton_Doze.animatePressUp_Doze()
        }

        logic_Doze.publishPost_Doze(
            title_doze: title,
            content_doze: content,
            mediaPath_doze: selectedMediaPath_Doze,
            category_doze: selectedCategory_Doze
        )

        Utils_Doze.showSuccess_Doze(message_Doze: "Sleep log published!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.clearFormAfterPublish_Doze()
        }
    }

    /// 发布成功后重置表单至初始状态
    private func clearFormAfterPublish_Doze() {
        // 清空文本输入
        titleTextField_Doze.text = ""
        contentTextView_Doze.text = ""
        contentPlaceholderLabel_Doze.isHidden = false

        // 重置媒体
        selectedMediaPath_Doze = nil
        mediaPreviewImageView_Doze.image = nil
        mediaPreviewImageView_Doze.isHidden = true
        mediaChangeButton_Doze.isHidden = true
        UIView.animate(withDuration: 0.2) {
            self.mediaUploadCircle_Doze.alpha = 1
            self.mediaIconView_Doze.alpha = 1
            self.mediaHintLabel_Doze.alpha = 1
            self.mediaSubHintLabel_Doze.alpha = 1
        }

        // 重置分类：激活第一个（cat）Chip
        selectedCategory_Doze = .cat_doze
        if let firstChip = categoryStack_Doze.arrangedSubviews
            .compactMap({ $0 as? UIButton }).first {
            setActiveCategoryChip_Doze(firstChip)
        }

        // 滚回顶部
        scrollView_Doze.setContentOffset(.zero, animated: true)
    }

    /// 点击媒体区域选图
    @objc private func handleMediaTap_Doze() {
        view.endEditing(true)
        mediaCard_Doze.animatePressDown_Doze {
            self.mediaCard_Doze.animatePressUp_Doze {
                MediaPickerHelper_Doze.pickImage_Doze(from: self) { [weak self] image in
                    guard let self, let img = image else { return }
                    self.handleImageSelected_Doze(img)
                }
            }
        }
    }

    /// 处理图片选取结果
    private func handleImageSelected_Doze(_ image: UIImage) {
        if let path = logic_Doze.saveImageToDocuments_Doze(image_doze: image) {
            selectedMediaPath_Doze = path
        }

        mediaPreviewImageView_Doze.image = image
        mediaPreviewImageView_Doze.isHidden = false
        mediaChangeButton_Doze.isHidden = false

        // 淡出原始提示
        UIView.animate(withDuration: 0.22) {
            self.mediaUploadCircle_Doze.alpha = 0
            self.mediaIconView_Doze.alpha = 0
            self.mediaHintLabel_Doze.alpha = 0
            self.mediaSubHintLabel_Doze.alpha = 0
        }

        // 预览图弹入
        mediaPreviewImageView_Doze.alpha = 0
        mediaPreviewImageView_Doze.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        UIView.animate(
            withDuration: 0.38,
            delay: 0,
            usingSpringWithDamping: 0.78,
            initialSpringVelocity: 0.5,
            options: [.curveEaseOut]
        ) {
            self.mediaPreviewImageView_Doze.alpha = 1
            self.mediaPreviewImageView_Doze.transform = .identity
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// 分类 Chip 点击
    @objc private func categoryChipTapped_Doze(_ sender: UIButton) {
        let filteredCats = PetCategory_Doze.allCases.filter { $0 != .all_doze }
        let idx = sender.tag - 1
        guard idx >= 0, idx < filteredCats.count else { return }
        selectedCategory_Doze = filteredCats[idx]
        setActiveCategoryChip_Doze(sender)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // 没选图时同步更新媒体图标
        if selectedMediaPath_Doze == nil {
            UIView.transition(with: mediaIconView_Doze, duration: 0.2, options: .transitionCrossDissolve) {
                self.mediaIconView_Doze.image = UIImage(systemName: self.selectedCategory_Doze.iconName_Doze)
            }
        }
    }

    /// 标题输入变化
    @objc private func titleEditChanged_Doze() {
        let count = titleTextField_Doze.text?.count ?? 0
        if count > 60 {
            titleTextField_Doze.text = String(titleTextField_Doze.text!.prefix(60))
        }
        let actualCount = titleTextField_Doze.text?.count ?? 0
        titleCountBadge_Doze.text = "  \(actualCount) / 60  "
        titleCountBadge_Doze.textColor = logic_Doze.counterColor_Doze(current_doze: actualCount, max_doze: 60)
    }

    /// 更新正文字数计数
    private func updateContentCount_Doze() {
        let count = contentTextView_Doze.text?.count ?? 0
        contentCountBadge_Doze.text = "  \(count) / \(maxContentLength_Doze)  "
        contentCountBadge_Doze.textColor = logic_Doze.counterColor_Doze(
            current_doze: count, max_doze: maxContentLength_Doze)
    }

    /// 点击 EULA 跳转协议页面
    @objc private func handleEULA_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        ProtocolHelper_Doze.showProtocol_Doze(
            type_Doze: .eula_Doze,
            content_Doze: "eula.png",
            from: self
        )
    }

    // MARK: - 键盘通知

    @objc private func keyboardWillShow_Doze(_ notification: Notification) {
        guard let kbFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView_Doze.contentInset.bottom = kbFrame.height + 16
        scrollView_Doze.scrollIndicatorInsets.bottom = kbFrame.height
    }

    @objc private func keyboardWillHide_Doze(_ notification: Notification) {
        scrollView_Doze.contentInset.bottom = 0
        scrollView_Doze.scrollIndicatorInsets.bottom = 0
    }
}

// MARK: - UITextFieldDelegate

extension Release_Doze: UITextFieldDelegate {

    /// 点击 return 键跳转到正文
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Doze.becomeFirstResponder()
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.titleCard_Doze.layer.shadowColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.2).cgColor
            self.titleCard_Doze.layer.shadowRadius = 14
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.titleCard_Doze.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
            self.titleCard_Doze.layer.shadowRadius = 10
        }
    }
}

// MARK: - UITextViewDelegate

extension Release_Doze: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholderLabel_Doze.isHidden = !textView.text.isEmpty
        if textView.text.count > maxContentLength_Doze {
            textView.text = String(textView.text.prefix(maxContentLength_Doze))
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        }
        updateContentCount_Doze()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            self.contentCard_Doze.layer.shadowColor = ColorConfig_Doze.primaryGradientStart_Doze.withAlphaComponent(0.2).cgColor
            self.contentCard_Doze.layer.shadowRadius = 14
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        UIView.animate(withDuration: 0.2) {
            self.contentCard_Doze.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
            self.contentCard_Doze.layer.shadowRadius = 10
        }
    }
}
