import Foundation
import UIKit
import SnapKit

// MARK: 发布页面
// 设计思路：
//   作为底部 Tabbar 的标准子页面嵌入，无关闭按钮。
//   顶部渐变横幅与 Discover 统一色系（深紫-靛蓝），内容区采用卡片式模块布局：
//     - 媒体选择卡片：虚线框 + 渐变图标 CTA
//     - 标题输入卡片：左侧 accent 色条 + 带图标的输入行
//     - 故事输入卡片：支持多行 + 字符计数器
//   发布按钮采用全宽渐变设计，发布成功后切换回首页 Tab。
//   viewWillAppear 时自动重置表单，保持干净初始状态。
// 关键属性：
//   selectedMediaPath_Echd — 已选媒体的本地路径
//   publishGradient_Echd   — 发布按钮渐变图层
//   maxStoryLength_Echd    — 故事最大字符数

/// 发布页视图控制器
class Release_Echd: UIViewController {

    // MARK: - 常量

    /// 故事内容最大字符数
    private let maxStoryLength_Echd = 300

    // MARK: - UI组件 / 顶部 Banner

    /// 顶部渐变 Banner 容器
    private let bannerView_Echd = UIView()

    /// Banner 渐变图层
    private var bannerGradient_Echd: CAGradientLayer?

    /// 页面主标题
    private let pageTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Share a Spark"
        label_Echd.font = UIFont.systemFont(ofSize: 26, weight: .black)
        label_Echd.textColor = .white
        return label_Echd
    }()

    /// Banner 副标题
    private let pageSubtitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Capture your moment ✦"
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.75)
        return label_Echd
    }()

    /// Banner 右侧装饰图标
    private let bannerIconView_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 38, weight: .thin)
        iv_Echd.image = UIImage(systemName: "camera.aperture", withConfiguration: cfg_Echd)
        iv_Echd.tintColor = UIColor.white.withAlphaComponent(0.15)
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()

    // MARK: - UI组件 / 滚动区

    /// 主滚动视图
    private let scrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsVerticalScrollIndicator = false
        sv_Echd.alwaysBounceVertical = true
        sv_Echd.keyboardDismissMode = .onDrag
        return sv_Echd
    }()

    /// 滚动内容容器
    private let contentView_Echd = UIView()

    // MARK: - UI组件 / 媒体选择卡片

    /// 媒体卡片容器
    private let mediaCardView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#EDE9FE")  // 极浅紫
        view_Echd.layer.cornerRadius = 20
        view_Echd.layer.borderWidth = 1.8
        view_Echd.layer.borderColor = UIColor(hexstring_Echd: "#8B5CF6").withAlphaComponent(0.3).cgColor
        return view_Echd
    }()

    /// 媒体预览视图（选择媒体后显示，默认隐藏）
    private let mediaDisplayView_Echd: MediaDisplayView_Echd = {
        let v_Echd = MediaDisplayView_Echd()
        v_Echd.isHidden = true
        return v_Echd
    }()

    /// 媒体上传提示容器（未选时可见）
    private let mediaPromptView_Echd = UIView()

    /// 上传图标背景圆（clipsToBounds 保证渐变图层随圆角裁剪）
    private let uploadIconBg_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.layer.cornerRadius = 30
        view_Echd.clipsToBounds = true
        return view_Echd
    }()

    /// 渐变图层（上传图标背景）
    private var uploadIconGradient_Echd: CAGradientLayer?

    /// 上传图标
    private let uploadIcon_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        iv_Echd.image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: cfg_Echd)
        iv_Echd.tintColor = .white
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()

    /// 上传主提示文本
    private let uploadHintLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Choose Photo or Video"
        label_Echd.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label_Echd.textColor = UIColor(hexstring_Echd: "#7C3AED")
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// 上传次提示文本
    private let uploadSubHintLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Supports JPG, PNG, MP4 · Max 50MB"
        label_Echd.font = UIFont.systemFont(ofSize: 11)
        label_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// 重选按钮（已选媒体时显示）
    private let reSelectButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .system)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        btn_Echd.setImage(UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: cfg_Echd), for: .normal)
        btn_Echd.setTitle("  Reselect", for: .normal)
        btn_Echd.tintColor = .white
        btn_Echd.setTitleColor(.white, for: .normal)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn_Echd.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        btn_Echd.layer.cornerRadius = 14
        btn_Echd.isHidden = true
        return btn_Echd
    }()

    // MARK: - UI组件 / 标题卡片

    /// 标题输入卡片
    private let titleCardView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.cornerRadius = 16
        view_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.1).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Echd.layer.shadowRadius = 10
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    /// 标题卡片左侧 accent 色条
    private let titleAccentBar_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED")
        view_Echd.layer.cornerRadius = 2
        return view_Echd
    }()

    /// 标题卡片 section 标签
    private let titleSectionLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Title"
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Echd.textColor = UIColor(hexstring_Echd: "#7C3AED")
        label_Echd.textAlignment = .center
        return label_Echd
    }()

    /// 标题输入框
    private let titleTextField_Echd: UITextField = {
        let tf_Echd = UITextField()
        tf_Echd.placeholder = "Give your spark a title..."
        tf_Echd.font = UIFont.systemFont(ofSize: 16)
        tf_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        tf_Echd.autocorrectionType = .no
        tf_Echd.borderStyle = .none
        return tf_Echd
    }()

    /// 分隔线
    private let titleDivider_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#F3F4F6")
        return view_Echd
    }()

    // MARK: - UI组件 / 故事卡片

    /// 故事输入卡片
    private let storyCardView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.cornerRadius = 16
        view_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#EC4899").withAlphaComponent(0.1).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Echd.layer.shadowRadius = 10
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    /// 故事卡片左侧 accent 色条（玫瑰粉）
    private let storyAccentBar_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#EC4899")
        view_Echd.layer.cornerRadius = 2
        return view_Echd
    }()

    /// 故事卡片 section 标签
    private let storySectionLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Story"
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        label_Echd.textColor = UIColor(hexstring_Echd: "#EC4899")
        return label_Echd
    }()

    /// 字符计数器标签（右上角）
    private let charCountLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "0/300"
        label_Echd.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        return label_Echd
    }()

    /// 故事多行输入框
    private let contentTextView_Echd: UITextView = {
        let tv_Echd = UITextView()
        tv_Echd.font = UIFont.systemFont(ofSize: 15)
        tv_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        tv_Echd.backgroundColor = .clear
        tv_Echd.isScrollEnabled = false
        tv_Echd.textContainerInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: -4)
        return tv_Echd
    }()

    /// 故事输入框占位符
    private let contentPlaceholder_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Share your moment..."
        label_Echd.font = UIFont.systemFont(ofSize: 15)
        label_Echd.textColor = UIColor(hexstring_Echd: "#D1D5DB")
        label_Echd.isUserInteractionEnabled = false
        return label_Echd
    }()

    // MARK: - UI组件 / 发布按钮区

    /// 发布按钮
    private let publishButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        btn_Echd.setTitle("✦  Publish Spark", for: .normal)
        btn_Echd.setTitleColor(.white, for: .normal)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Echd.layer.cornerRadius = 18
        btn_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.45).cgColor
        btn_Echd.layer.shadowOffset = CGSize(width: 0, height: 8)
        btn_Echd.layer.shadowRadius = 16
        btn_Echd.layer.shadowOpacity = 1
        return btn_Echd
    }()

    /// 发布按钮渐变图层
    private var publishGradient_Echd: CAGradientLayer?

    // MARK: - 私有属性

    /// 已选媒体的本地文件名
    private var selectedMediaPath_Echd: String?

    /// 已选媒体图片（仅图片时有值）
    private var selectedImage_Echd: UIImage?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        // 每次进入此 Tab 时重置表单
        clearPageData_Echd()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
        setupUI_Echd()
        setupConstraints_Echd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 同步渐变图层尺寸
        bannerGradient_Echd?.frame = bannerView_Echd.bounds
        publishGradient_Echd?.frame = publishButton_Echd.bounds
        publishButton_Echd.layer.masksToBounds = true
        uploadIconGradient_Echd?.frame = uploadIconBg_Echd.bounds
    }

    // MARK: - UI设置

    private func setupUI_Echd() {
        setupBanner_Echd()
        setupScrollContent_Echd()

        // 收起键盘手势
        let tap_Echd = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Echd))
        tap_Echd.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Echd)
    }

    /// 配置顶部渐变 Banner
    private func setupBanner_Echd() {
        view.addSubview(bannerView_Echd)
        bannerView_Echd.clipsToBounds = true

        let grad_Echd = CAGradientLayer()
        grad_Echd.colors = [
            UIColor(hexstring_Echd: "#7C3AED").cgColor,
            UIColor(hexstring_Echd: "#4F46E5").cgColor
        ]
        grad_Echd.startPoint = CGPoint(x: 0, y: 0)
        grad_Echd.endPoint = CGPoint(x: 1, y: 1)
        bannerView_Echd.layer.insertSublayer(grad_Echd, at: 0)
        bannerGradient_Echd = grad_Echd

        bannerView_Echd.addSubview(bannerIconView_Echd)
        bannerView_Echd.addSubview(pageTitleLabel_Echd)
        bannerView_Echd.addSubview(pageSubtitleLabel_Echd)
    }

    /// 配置滚动区内容
    private func setupScrollContent_Echd() {
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(contentView_Echd)

        // --- 媒体卡片 ---
        contentView_Echd.addSubview(mediaCardView_Echd)
        mediaCardView_Echd.addSubview(mediaDisplayView_Echd)
        mediaCardView_Echd.addSubview(mediaPromptView_Echd)
        mediaCardView_Echd.addSubview(reSelectButton_Echd)

        // 上传提示内部组件
        mediaPromptView_Echd.addSubview(uploadIconBg_Echd)
        mediaPromptView_Echd.addSubview(uploadIcon_Echd)
        mediaPromptView_Echd.addSubview(uploadHintLabel_Echd)
        mediaPromptView_Echd.addSubview(uploadSubHintLabel_Echd)

        // 上传图标渐变背景
        let iconGrad_Echd = CAGradientLayer()
        iconGrad_Echd.colors = [
            UIColor(hexstring_Echd: "#8B5CF6").cgColor,
            UIColor(hexstring_Echd: "#EC4899").cgColor
        ]
        iconGrad_Echd.startPoint = CGPoint(x: 0, y: 0)
        iconGrad_Echd.endPoint = CGPoint(x: 1, y: 1)
        uploadIconBg_Echd.layer.insertSublayer(iconGrad_Echd, at: 0)
        uploadIconGradient_Echd = iconGrad_Echd

        // 媒体区点击
        let mediaTap_Echd = UITapGestureRecognizer(target: self, action: #selector(mediaTapped_Echd))
        mediaCardView_Echd.addGestureRecognizer(mediaTap_Echd)
        reSelectButton_Echd.addTarget(self, action: #selector(mediaTapped_Echd), for: .touchUpInside)

        // --- 标题卡片 ---
        contentView_Echd.addSubview(titleCardView_Echd)
        titleCardView_Echd.addSubview(titleAccentBar_Echd)
        titleCardView_Echd.addSubview(titleSectionLabel_Echd)
        titleCardView_Echd.addSubview(titleTextField_Echd)
        titleCardView_Echd.addSubview(titleDivider_Echd)

        // --- 故事卡片 ---
        contentView_Echd.addSubview(storyCardView_Echd)
        storyCardView_Echd.addSubview(storyAccentBar_Echd)
        storyCardView_Echd.addSubview(storySectionLabel_Echd)
        storyCardView_Echd.addSubview(charCountLabel_Echd)
        storyCardView_Echd.addSubview(contentTextView_Echd)
        storyCardView_Echd.addSubview(contentPlaceholder_Echd)
        contentTextView_Echd.delegate = self

        // --- 发布按钮 ---
        contentView_Echd.addSubview(publishButton_Echd)
        let pubGrad_Echd = CAGradientLayer()
        pubGrad_Echd.colors = [
            UIColor(hexstring_Echd: "#7C3AED").cgColor,
            UIColor(hexstring_Echd: "#4F46E5").cgColor
        ]
        pubGrad_Echd.startPoint = CGPoint(x: 0, y: 0)
        pubGrad_Echd.endPoint = CGPoint(x: 1, y: 0)
        publishButton_Echd.layer.insertSublayer(pubGrad_Echd, at: 0)
        publishGradient_Echd = pubGrad_Echd
        publishButton_Echd.addTarget(self, action: #selector(publishTapped_Echd), for: .touchUpInside)

        // EULA
        let eulaLabel_Echd = buildEulaLabel_Echd()
        contentView_Echd.addSubview(eulaLabel_Echd)
        eulaLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(publishButton_Echd.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-34)
        }
    }

    // MARK: - 约束布局

    private func setupConstraints_Echd() {
        let sw_Echd = UIScreen.main.bounds.width

        // Banner
        bannerView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(130)
        }
        bannerIconView_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(10)
            make.width.height.equalTo(120)
        }
        pageTitleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(18)
            make.leading.equalToSuperview().offset(22)
            make.trailing.lessThanOrEqualTo(bannerIconView_Echd.snp.leading).offset(-10)
        }
        pageSubtitleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(pageTitleLabel_Echd.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(22)
        }

        // 滚动区
        scrollView_Echd.snp.makeConstraints { make in
            make.top.equalTo(bannerView_Echd.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sw_Echd)
        }

        // 媒体卡片
        mediaCardView_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(200)
        }
        mediaDisplayView_Echd.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaPromptView_Echd.snp.makeConstraints { make in make.edges.equalToSuperview() }
        uploadIconBg_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        uploadIcon_Echd.snp.makeConstraints { make in
            make.center.equalTo(uploadIconBg_Echd)
            make.width.height.equalTo(26)
        }
        uploadHintLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(uploadIconBg_Echd.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        uploadSubHintLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(uploadHintLabel_Echd.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        reSelectButton_Echd.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(12)
            make.height.equalTo(28)
            make.width.greaterThanOrEqualTo(90)
        }

        // 标题卡片
        titleCardView_Echd.snp.makeConstraints { make in
            make.top.equalTo(mediaCardView_Echd.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        titleAccentBar_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.width.equalTo(4)
            make.height.equalTo(16)
        }
        titleSectionLabel_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(titleAccentBar_Echd)
            make.leading.equalTo(titleAccentBar_Echd.snp.trailing).offset(8)
        }
        titleDivider_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleAccentBar_Echd.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(1)
        }
        titleTextField_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleDivider_Echd.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-14)
        }

        // 故事卡片
        storyCardView_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleCardView_Echd.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        storyAccentBar_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.width.equalTo(4)
            make.height.equalTo(16)
        }
        storySectionLabel_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(storyAccentBar_Echd)
            make.leading.equalTo(storyAccentBar_Echd.snp.trailing).offset(8)
        }
        charCountLabel_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(storyAccentBar_Echd)
            make.trailing.equalToSuperview().offset(-14)
        }
        contentTextView_Echd.snp.makeConstraints { make in
            make.top.equalTo(storyAccentBar_Echd.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.greaterThanOrEqualTo(110)
            make.bottom.equalToSuperview().offset(-14)
        }
        contentPlaceholder_Echd.snp.makeConstraints { make in
            make.top.equalTo(contentTextView_Echd).offset(0)
            make.leading.equalTo(contentTextView_Echd).offset(0)
        }

        // 发布按钮
        publishButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(storyCardView_Echd.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(60)
        }
    }

    // MARK: - EULA 标签构建

    /// 构建带下划线的 EULA 标签
    private func buildEulaLabel_Echd() -> UILabel {
        let label_Echd = UILabel()
        let attrs_Echd: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(hexstring_Echd: "#7C3AED"),
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor(hexstring_Echd: "#7C3AED")
        ]
        label_Echd.attributedText = NSAttributedString(string: "EULA", attributes: attrs_Echd)
        label_Echd.isUserInteractionEnabled = true
        label_Echd.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eulaTapped_Echd)))
        return label_Echd
    }

    // MARK: - 事件处理

    /// 选择媒体
    @objc private func mediaTapped_Echd() {
        mediaCardView_Echd.animatePressDown_Echd { self.mediaCardView_Echd.animatePressUp_Echd() }

        MediaPickerHelper_Echd.pickMedia_Echd(from: self) { [weak self] result_Echd in
            guard let self = self else { return }
            switch result_Echd {
            case .photo_Echd(let image_Echd): self.handleImageSelected_Echd(image_Echd: image_Echd)
            case .video_Echd(let url_Echd):   self.handleVideoSelected_Echd(url_Echd: url_Echd)
            case .cancelled_Echd: break
            }
        }
    }

    /// 处理选择的图片
    private func handleImageSelected_Echd(image_Echd: UIImage) {
        selectedImage_Echd = image_Echd
        let fileName_Echd = "post_img_\(Date().timeIntervalSince1970).jpg"
        let dir_Echd = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url_Echd = dir_Echd.appendingPathComponent(fileName_Echd)
        if let data_Echd = image_Echd.jpegData(compressionQuality: 0.8) {
            try? data_Echd.write(to: url_Echd)
            selectedMediaPath_Echd = fileName_Echd
        }
        mediaDisplayView_Echd.configureWithImage_Echd(image_Echd: image_Echd)
        mediaDisplayView_Echd.isHidden = false
        mediaPromptView_Echd.isHidden = true
        reSelectButton_Echd.isHidden = false
    }

    /// 处理选择的视频
    private func handleVideoSelected_Echd(url_Echd: URL) {
        let fileName_Echd = "post_vid_\(Date().timeIntervalSince1970).mp4"
        let dir_Echd = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dest_Echd = dir_Echd.appendingPathComponent(fileName_Echd)
        try? FileManager.default.copyItem(at: url_Echd, to: dest_Echd)
        selectedMediaPath_Echd = fileName_Echd
        mediaDisplayView_Echd.configure_Echd(mediaPath_Echd: fileName_Echd, isVideo_Echd: true)
        mediaDisplayView_Echd.isHidden = false
        mediaPromptView_Echd.isHidden = true
        reSelectButton_Echd.isHidden = false
    }

    /// 发布按钮点击
    @objc private func publishTapped_Echd() {
        publishButton_Echd.animatePressDown_Echd { self.publishButton_Echd.animatePressUp_Echd() }

        // 校验登录
        guard UserViewModel_Echd.shared_Echd.isLoggedIn_Echd else {
            Navigation_Echd.toLogin_Echd(style_echd: .present_echd)
            return
        }

        // 校验标题
        guard let title_Echd = titleTextField_Echd.text,
              !title_Echd.trimmingCharacters(in: .whitespaces).isEmpty else {
            titleCardView_Echd.animateShake_Echd()
            Utils_Echd.showWarning_Echd(message_Echd: "Title cannot be empty")
            return
        }

        // 校验内容
        let content_Echd = contentTextView_Echd.text ?? ""
        guard !content_Echd.trimmingCharacters(in: .whitespaces).isEmpty else {
            storyCardView_Echd.animateShake_Echd()
            Utils_Echd.showWarning_Echd(message_Echd: "Story cannot be empty")
            return
        }

        // 校验媒体
        guard let mediaPath_Echd = selectedMediaPath_Echd else {
            mediaCardView_Echd.animateShake_Echd()
            Utils_Echd.showWarning_Echd(message_Echd: "Please choose a photo or video")
            return
        }

        // 调用 ViewModel 发布
        Task { @MainActor in
            TitleViewModel_Echd.shared_Echd.releasePost_Echd(
                title_echd: title_Echd,
                content_echd: content_Echd,
                media_echd: mediaPath_Echd
            )
        }

        clearPageData_Echd()

        // 发布成功，切换回首页 Tab
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let tabBar_Echd = self?.tabBarController as? TabBar_Echd else { return }
            tabBar_Echd.switchToTab_Echd(index_Echd: 0)
        }
    }

    /// EULA 点击
    @objc private func eulaTapped_Echd() {
        ProtocolHelper_Echd.showProtocol_Echd(
            type_Echd: .eula_Echd,
            content_Echd: "eula",
            from: self
        )
    }

    /// 收起键盘
    @objc private func dismissKeyboard_Echd() {
        view.endEditing(true)
    }

    // MARK: - 表单重置

    /// 清除所有表单数据，恢复初始状态
    private func clearPageData_Echd() {
        titleTextField_Echd.text = nil
        contentTextView_Echd.text = nil
        contentPlaceholder_Echd.isHidden = false
        charCountLabel_Echd.text = "0/\(maxStoryLength_Echd)"
        charCountLabel_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        selectedMediaPath_Echd = nil
        selectedImage_Echd = nil
        mediaDisplayView_Echd.configure_Echd(mediaPath_Echd: nil)
        mediaDisplayView_Echd.isHidden = true
        mediaPromptView_Echd.isHidden = false
        reSelectButton_Echd.isHidden = true
    }
}

// MARK: - UITextViewDelegate

extension Release_Echd: UITextViewDelegate {

    /// 文本变化：更新占位符显示状态与字符计数器
    func textViewDidChange(_ textView: UITextView) {
        let count_Echd = textView.text.count
        contentPlaceholder_Echd.isHidden = count_Echd > 0

        // 超出限制时截断
        if count_Echd > maxStoryLength_Echd {
            textView.text = String(textView.text.prefix(maxStoryLength_Echd))
        }

        let current_Echd = min(count_Echd, maxStoryLength_Echd)
        charCountLabel_Echd.text = "\(current_Echd)/\(maxStoryLength_Echd)"
        // 接近上限时变色提示
        charCountLabel_Echd.textColor = current_Echd >= maxStoryLength_Echd - 20
            ? UIColor(hexstring_Echd: "#F43F5E")
            : UIColor(hexstring_Echd: "#9CA3AF")
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        contentPlaceholder_Echd.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        contentPlaceholder_Echd.isHidden = textView.text.isEmpty
    }
}
