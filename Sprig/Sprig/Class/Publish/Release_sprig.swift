import Foundation
import UIKit
import SnapKit
import PhotosUI

// MARK: 发布页面

/// 发布页面
/// 功能：用户填写标题、内容并选取单一媒体（图片或视频），点击发布后校验并调用 TitleViewModel 完成发布
/// 设计：现代化渐变顶栏 + 卡片式表单 + 媒体预览区域
/// 关键逻辑：发布时先校验登录状态 → 再校验字段非空 → 调用 ViewModel 发布 → 成功后清空表单
class Release_Sprig: UIViewController {

    // MARK: - 私有属性

    /// 已选取的图片（图片媒体时使用）
    private var selectedImage_Sprig: UIImage?

    /// 已选取的视频 URL（视频媒体时使用）
    private var selectedVideoURL_Sprig: URL?

    /// 已选取的媒体路径字符串（传给 ViewModel）
    private var selectedMediaPath_Sprig: String?

    /// 媒体类型标记（true = 图片，false = 视频）
    private var isImageMedia_Sprig: Bool = true

    /// 所有可选标签数据
    private var allTags_Sprig: [FlowerTagModel_Sprig] = []

    /// 已选中的标签下标集合（支持多选）
    private var selectedTagIndices_Sprig: Set<Int> = []

    // MARK: - UI组件 - 顶部

    /// 顶部渐变导航栏容器
    private let headerView_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.layer.cornerRadius = 32
        view_Sprig.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view_Sprig.clipsToBounds = true
        return view_Sprig
    }()

    /// 渐变图层
    private var headerGradient_Sprig: CAGradientLayer?

    /// 页面标题
    private let headerTitleLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Share Your Spark ✦"
        label_Sprig.font = UIFont.systemFont(ofSize: 26, weight: .black)
        label_Sprig.textColor = .white
        return label_Sprig
    }()

    /// 副标题
    private let headerSubtitleLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Let the world see your moment"
        label_Sprig.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Sprig.textColor = UIColor.white.withAlphaComponent(0.85)
        return label_Sprig
    }()

    // 发布页通过 dismiss/pop 关闭，顶部不显示返回按钮

    // MARK: - UI组件 - 主滚动区域

    /// 主滚动视图
    private let mainScrollView_Sprig: UIScrollView = {
        let sv_Sprig = UIScrollView()
        sv_Sprig.showsVerticalScrollIndicator = false
        sv_Sprig.alwaysBounceVertical = true
        sv_Sprig.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        return sv_Sprig
    }()

    /// 滚动内容容器
    private let scrollContentView_Sprig = UIView()

    // MARK: - UI组件 - 表单卡片

    /// 表单卡片容器
    private let formCard_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = ColorConfig_Sprig.cardBackground_Sprig
        view_Sprig.layer.cornerRadius = 24
        view_Sprig.layer.shadowColor = UIColor.black.cgColor
        view_Sprig.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_Sprig.layer.shadowRadius = 16
        view_Sprig.layer.shadowOpacity = 0.08
        return view_Sprig
    }()

    /// 标题输入框标签
    private let titleFieldLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Title"
        label_Sprig.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        return label_Sprig
    }()

    /// 标题输入框
    private let titleTextField_Sprig: UITextField = {
        let tf_Sprig = UITextField()
        tf_Sprig.placeholder = "Give your post a title..."
        tf_Sprig.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        tf_Sprig.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        tf_Sprig.layer.cornerRadius = 14
        tf_Sprig.returnKeyType = .next
        return tf_Sprig
    }()

    /// 分割线（标题/内容之间）
    private let formDivider1_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = ColorConfig_Sprig.divider_Sprig
        return view_Sprig
    }()

    /// 内容输入框标签
    private let contentFieldLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Content"
        label_Sprig.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        return label_Sprig
    }()

    /// 内容输入框（多行）
    private let contentTextView_Sprig: UITextView = {
        let tv_Sprig = UITextView()
        tv_Sprig.font = UIFont.systemFont(ofSize: 15)
        tv_Sprig.textColor = ColorConfig_Sprig.textPrimary_Sprig
        tv_Sprig.backgroundColor = .clear
        tv_Sprig.isScrollEnabled = false
        tv_Sprig.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tv_Sprig.textContainer.lineFragmentPadding = 0
        return tv_Sprig
    }()

    /// 内容占位文字标签
    private let contentPlaceholder_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Share your story, thoughts, or moments..."
        label_Sprig.font = UIFont.systemFont(ofSize: 15)
        label_Sprig.textColor = ColorConfig_Sprig.textPlaceholder_Sprig
        label_Sprig.numberOfLines = 0
        return label_Sprig
    }()

    // MARK: - UI组件 - 媒体区域

    /// 媒体选取区域卡片
    private let mediaCard_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = ColorConfig_Sprig.cardBackground_Sprig
        view_Sprig.layer.cornerRadius = 24
        view_Sprig.layer.shadowColor = UIColor.black.cgColor
        view_Sprig.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_Sprig.layer.shadowRadius = 16
        view_Sprig.layer.shadowOpacity = 0.08
        view_Sprig.layer.borderWidth = 1.5
        view_Sprig.layer.borderColor = ColorConfig_Sprig.divider_Sprig.cgColor
        return view_Sprig
    }()

    /// 媒体占位图标
    private let mediaPickIcon_Sprig: UIImageView = {
        let iv_Sprig = UIImageView()
        iv_Sprig.image = UIImage(systemName: "photo.on.rectangle.angled")
        iv_Sprig.tintColor = ColorConfig_Sprig.primaryGradientStart_Sprig
        iv_Sprig.contentMode = .scaleAspectFit
        return iv_Sprig
    }()

    /// 媒体占位文字
    private let mediaPickLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Tap to add a photo or video"
        label_Sprig.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        label_Sprig.textAlignment = .center
        return label_Sprig
    }()

    /// 媒体占位子文字
    private let mediaPickSubLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Photo or Video · Max 1 file"
        label_Sprig.font = UIFont.systemFont(ofSize: 11)
        label_Sprig.textColor = ColorConfig_Sprig.textPlaceholder_Sprig
        label_Sprig.textAlignment = .center
        return label_Sprig
    }()

    /// 已选媒体预览（图片展示）
    private let mediaPreviewImageView_Sprig: UIImageView = {
        let iv_Sprig = UIImageView()
        iv_Sprig.contentMode = .scaleAspectFill
        iv_Sprig.clipsToBounds = true
        iv_Sprig.layer.cornerRadius = 18
        iv_Sprig.isHidden = true
        return iv_Sprig
    }()

    /// 视频媒体标识角标
    private let videoTagView_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view_Sprig.layer.cornerRadius = 8
        view_Sprig.isHidden = true
        return view_Sprig
    }()

    /// 视频标识图标
    private let videoTagIcon_Sprig: UIImageView = {
        let iv_Sprig = UIImageView()
        iv_Sprig.image = UIImage(systemName: "play.fill")
        iv_Sprig.tintColor = .white
        iv_Sprig.contentMode = .scaleAspectFit
        return iv_Sprig
    }()

    /// 视频标识文字
    private let videoTagLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Video"
        label_Sprig.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        label_Sprig.textColor = .white
        return label_Sprig
    }()

    /// 删除媒体按钮
    private let removeMediaButton_Sprig: UIButton = {
        let btn_Sprig = UIButton(type: .system)
        let config_Sprig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn_Sprig.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config_Sprig), for: .normal)
        btn_Sprig.tintColor = .white
        btn_Sprig.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        btn_Sprig.layer.cornerRadius = 14
        btn_Sprig.isHidden = true
        return btn_Sprig
    }()

    // MARK: - UI组件 - 底部按钮区

    /// 发布确认按钮（渐变背景）
    private let publishButton_Sprig: UIButton = {
        let btn_Sprig = UIButton(type: .system)
        btn_Sprig.setTitle("Publish Now", for: .normal)
        btn_Sprig.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        btn_Sprig.setTitleColor(.white, for: .normal)
        btn_Sprig.layer.cornerRadius = 26
        btn_Sprig.clipsToBounds = true
        return btn_Sprig
    }()

    /// 发布按钮渐变图层
    private let publishGradient_Sprig = CAGradientLayer()

    // MARK: - UI组件 - 标签选取区

    /// 标签选取卡片容器
    private let tagCard_Sprig: UIView = {
        let view_Sprig = UIView()
        view_Sprig.backgroundColor = ColorConfig_Sprig.cardBackground_Sprig
        view_Sprig.layer.cornerRadius = 18
        view_Sprig.layer.shadowColor = UIColor.black.cgColor
        view_Sprig.layer.shadowOffset = CGSize(width: 0, height: 3)
        view_Sprig.layer.shadowRadius = 10
        view_Sprig.layer.shadowOpacity = 0.06
        return view_Sprig
    }()

    /// 标签区域标题标签
    private let tagHeaderLabel_Sprig: UILabel = {
        let label_Sprig = UILabel()
        label_Sprig.text = "Tags (Optional)"
        label_Sprig.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label_Sprig.textColor = ColorConfig_Sprig.textSecondary_Sprig
        return label_Sprig
    }()

    /// 标签横向滚动容器
    private lazy var tagScrollView_Sprig: UIScrollView = {
        let sv_Sprig = UIScrollView()
        sv_Sprig.showsHorizontalScrollIndicator = false
        sv_Sprig.alwaysBounceHorizontal = true
        sv_Sprig.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        return sv_Sprig
    }()

    /// 标签 chip 水平堆栈
    private let tagStackView_Sprig: UIStackView = {
        let sv_Sprig = UIStackView()
        sv_Sprig.axis = .horizontal
        sv_Sprig.spacing = 8
        sv_Sprig.alignment = .center
        return sv_Sprig
    }()

    // MARK: - UI组件 - 底部按钮区

    /// EULA 用户协议按钮（带下划线，点击展示协议内容）
    private let eulaButton_Sprig: UIButton = {
        let btn_Sprig = UIButton(type: .system)
        let attrTitle_Sprig = NSAttributedString(
            string: "EULA",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: ColorConfig_Sprig.textSecondary_Sprig
            ]
        )
        btn_Sprig.setAttributedTitle(attrTitle_Sprig, for: .normal)
        btn_Sprig.titleLabel?.numberOfLines = 2
        btn_Sprig.titleLabel?.textAlignment = .center
        return btn_Sprig
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Sprig()
        setupActions_Sprig()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Sprig?.frame = headerView_Sprig.bounds
        publishGradient_Sprig.frame = publishButton_Sprig.bounds
    }

    // MARK: - UI构建

    /// 搭建整体 UI
    private func setupUI_Sprig() {
        view.backgroundColor = ColorConfig_Sprig.backgroundPrimary_Sprig
        setupHeaderView_Sprig()
        setupScrollContent_Sprig()
        setupKeyboardDismiss_Sprig()
    }

    /// 搭建顶部渐变导航栏
    private func setupHeaderView_Sprig() {
        view.addSubview(headerView_Sprig)

        let gradient_Sprig = CAGradientLayer()
        gradient_Sprig.colors = [
            ColorConfig_Sprig.secondaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor
        ]
        gradient_Sprig.startPoint = CGPoint(x: 0, y: 0)
        gradient_Sprig.endPoint = CGPoint(x: 1, y: 1)
        headerGradient_Sprig = gradient_Sprig
        headerView_Sprig.layer.insertSublayer(gradient_Sprig, at: 0)

        headerView_Sprig.addSubview(headerTitleLabel_Sprig)
        headerView_Sprig.addSubview(headerSubtitleLabel_Sprig)

        headerView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.left.right.equalToSuperview()
            make_Sprig.height.equalTo(148)
        }

        // 标题从左侧固定偏移起始，无需参考返回按钮
        headerTitleLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalToSuperview().offset(24)
            make_Sprig.bottom.equalToSuperview().offset(-30)
        }

        headerSubtitleLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalTo(headerTitleLabel_Sprig)
            make_Sprig.top.equalTo(headerTitleLabel_Sprig.snp.bottom).offset(4)
        }
    }

    /// 搭建滚动内容区域（表单卡片 + 媒体卡片 + 按钮）
    private func setupScrollContent_Sprig() {
        view.addSubview(mainScrollView_Sprig)
        mainScrollView_Sprig.addSubview(scrollContentView_Sprig)

        mainScrollView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(headerView_Sprig.snp.bottom)
            make_Sprig.left.right.bottom.equalToSuperview()
        }

        scrollContentView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.edges.equalToSuperview()
            make_Sprig.width.equalTo(mainScrollView_Sprig)
        }

        setupFormCard_Sprig()
        setupTagCard_Sprig()
        setupMediaCard_Sprig()
        setupBottomButtons_Sprig()
    }

    /// 搭建表单卡片（标题 + 内容输入）
    private func setupFormCard_Sprig() {
        scrollContentView_Sprig.addSubview(formCard_Sprig)

        formCard_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalToSuperview().offset(20)
            make_Sprig.left.equalToSuperview().offset(20)
            make_Sprig.right.equalToSuperview().offset(-20)
        }

        formCard_Sprig.addSubview(titleFieldLabel_Sprig)
        formCard_Sprig.addSubview(titleTextField_Sprig)
        formCard_Sprig.addSubview(formDivider1_Sprig)
        formCard_Sprig.addSubview(contentFieldLabel_Sprig)
        formCard_Sprig.addSubview(contentTextView_Sprig)
        contentTextView_Sprig.addSubview(contentPlaceholder_Sprig)

        titleFieldLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalToSuperview().offset(18)
            make_Sprig.left.equalToSuperview().offset(20)
        }

        titleTextField_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(titleFieldLabel_Sprig.snp.bottom).offset(8)
            make_Sprig.left.equalToSuperview().offset(20)
            make_Sprig.right.equalToSuperview().offset(-20)
            make_Sprig.height.equalTo(44)
        }
        titleTextField_Sprig.addLeftPadding_Sprig(12)

        formDivider1_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(titleTextField_Sprig.snp.bottom).offset(14)
            make_Sprig.left.equalToSuperview().offset(20)
            make_Sprig.right.equalToSuperview().offset(-20)
            make_Sprig.height.equalTo(0.8)
        }

        contentFieldLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(formDivider1_Sprig.snp.bottom).offset(14)
            make_Sprig.left.equalToSuperview().offset(20)
        }

        contentTextView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(contentFieldLabel_Sprig.snp.bottom).offset(8)
            make_Sprig.left.equalToSuperview().offset(20)
            make_Sprig.right.equalToSuperview().offset(-20)
            make_Sprig.height.greaterThanOrEqualTo(100)
            make_Sprig.bottom.equalToSuperview().offset(-18)
        }

        contentPlaceholder_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.left.equalToSuperview()
            make_Sprig.right.equalToSuperview()
        }
        contentTextView_Sprig.delegate = self
    }

    /// 搭建标签选取卡片（表单卡片与媒体卡片之间）
    /// 功能：展示横向可滚动标签 chip，支持多选，选中后高亮对应标签色
    private func setupTagCard_Sprig() {
        scrollContentView_Sprig.addSubview(tagCard_Sprig)

        tagCard_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(formCard_Sprig.snp.bottom).offset(16)
            make_Sprig.left.equalToSuperview().offset(20)
            make_Sprig.right.equalToSuperview().offset(-20)
        }

        tagCard_Sprig.addSubview(tagHeaderLabel_Sprig)
        tagHeaderLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalToSuperview().offset(16)
            make_Sprig.left.equalToSuperview().offset(20)
        }

        tagCard_Sprig.addSubview(tagScrollView_Sprig)
        tagScrollView_Sprig.addSubview(tagStackView_Sprig)

        tagScrollView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(tagHeaderLabel_Sprig.snp.bottom).offset(10)
            make_Sprig.left.right.equalToSuperview().inset(16)
            make_Sprig.height.equalTo(36)
            make_Sprig.bottom.equalToSuperview().offset(-16)
        }

        tagStackView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.edges.equalToSuperview()
            make_Sprig.height.equalToSuperview()
        }

        // 加载标签数据并构建 chip
        allTags_Sprig = DiscoverViewModel_Sprig.shared_Sprig.getAllTags_Sprig()
        buildTagChips_Sprig()
    }

    /// 重建标签 chip 列表（每次选中状态变化后调用）
    private func buildTagChips_Sprig() {
        tagStackView_Sprig.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (idx_sprig, tag_sprig) in allTags_Sprig.enumerated() {
            let chip_sprig = buildSingleTagChip_Sprig(
                tag_sprig: tag_sprig,
                index_sprig: idx_sprig,
                isSelected_sprig: selectedTagIndices_Sprig.contains(idx_sprig)
            )
            tagStackView_Sprig.addArrangedSubview(chip_sprig)
        }
    }

    /// 构建单个标签 chip
    /// - Parameters:
    ///   - tag_sprig: 标签模型
    ///   - index_sprig: 标签下标（用于 view.tag 传递）
    ///   - isSelected_sprig: 是否选中
    /// - Returns: 标签 chip 视图
    private func buildSingleTagChip_Sprig(tag_sprig: FlowerTagModel_Sprig,
                                          index_sprig: Int,
                                          isSelected_sprig: Bool) -> UIView {
        let tagColor_sprig = UIColor(hexstring_Sprig: tag_sprig.tagHexColor_Sprig)
        let chip_sprig = UIView()
        chip_sprig.backgroundColor = isSelected_sprig
            ? tagColor_sprig
            : ColorConfig_Sprig.tagBackground_Sprig
        chip_sprig.layer.cornerRadius = 16
        if isSelected_sprig {
            chip_sprig.layer.shadowColor = tagColor_sprig.cgColor
            chip_sprig.layer.shadowOpacity = 0.3
            chip_sprig.layer.shadowRadius  = 6
            chip_sprig.layer.shadowOffset  = CGSize(width: 0, height: 3)
        }
        chip_sprig.tag = index_sprig
        chip_sprig.isUserInteractionEnabled = true

        let icon_sprig = UIImageView(image: UIImage(systemName: tag_sprig.tagIcon_Sprig))
        icon_sprig.tintColor = isSelected_sprig ? .white : tagColor_sprig
        icon_sprig.contentMode = .scaleAspectFit
        chip_sprig.addSubview(icon_sprig)
        icon_sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalToSuperview().offset(10)
            make_Sprig.centerY.equalToSuperview()
            make_Sprig.width.height.equalTo(13)
        }

        let label_sprig = UILabel()
        label_sprig.text = tag_sprig.tagName_Sprig
        label_sprig.font = .systemFont(ofSize: 13, weight: .semibold)
        label_sprig.textColor = isSelected_sprig ? .white : ColorConfig_Sprig.textSecondary_Sprig
        chip_sprig.addSubview(label_sprig)
        label_sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalTo(icon_sprig.snp.right).offset(5)
            make_Sprig.right.equalToSuperview().offset(-10)
            make_Sprig.centerY.equalToSuperview()
            make_Sprig.top.equalToSuperview().offset(8)
            make_Sprig.bottom.equalToSuperview().offset(-8)
        }

        let tap_sprig = UITapGestureRecognizer(target: self, action: #selector(handleTagChipTap_Sprig(_:)))
        chip_sprig.addGestureRecognizer(tap_sprig)
        return chip_sprig
    }

    /// 处理标签 chip 点击，切换选中状态并重建 chip 列表
    /// - Parameter gesture: 点击手势
    @objc private func handleTagChipTap_Sprig(_ gesture: UITapGestureRecognizer) {
        guard let chipView_sprig = gesture.view else { return }
        chipView_sprig.animatePressDown_Sprig { chipView_sprig.animatePressUp_Sprig() }
        let index_sprig = chipView_sprig.tag
        if selectedTagIndices_Sprig.contains(index_sprig) {
            selectedTagIndices_Sprig.remove(index_sprig)
        } else {
            selectedTagIndices_Sprig.insert(index_sprig)
        }
        buildTagChips_Sprig()
    }

    /// 搭建媒体选取卡片
    private func setupMediaCard_Sprig() {
        scrollContentView_Sprig.addSubview(mediaCard_Sprig)

        mediaCard_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(tagCard_Sprig.snp.bottom).offset(16)
            make_Sprig.left.equalToSuperview().offset(20)
            make_Sprig.right.equalToSuperview().offset(-20)
            make_Sprig.height.equalTo(200)
        }

        // 占位提示内容
        mediaCard_Sprig.addSubview(mediaPickIcon_Sprig)
        mediaCard_Sprig.addSubview(mediaPickLabel_Sprig)
        mediaCard_Sprig.addSubview(mediaPickSubLabel_Sprig)

        mediaPickIcon_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.centerX.equalToSuperview()
            make_Sprig.top.equalToSuperview().offset(44)
            make_Sprig.width.height.equalTo(44)
        }

        mediaPickLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(mediaPickIcon_Sprig.snp.bottom).offset(12)
            make_Sprig.centerX.equalToSuperview()
        }

        mediaPickSubLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(mediaPickLabel_Sprig.snp.bottom).offset(6)
            make_Sprig.centerX.equalToSuperview()
        }

        // 媒体预览层
        mediaCard_Sprig.addSubview(mediaPreviewImageView_Sprig)
        mediaPreviewImageView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.edges.equalToSuperview().inset(8)
        }

        // 视频角标
        mediaCard_Sprig.addSubview(videoTagView_Sprig)
        videoTagView_Sprig.addSubview(videoTagIcon_Sprig)
        videoTagView_Sprig.addSubview(videoTagLabel_Sprig)

        videoTagView_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalToSuperview().offset(18)
            make_Sprig.bottom.equalToSuperview().offset(-18)
            make_Sprig.height.equalTo(26)
        }

        videoTagIcon_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalToSuperview().offset(8)
            make_Sprig.centerY.equalToSuperview()
            make_Sprig.width.height.equalTo(12)
        }

        videoTagLabel_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.left.equalTo(videoTagIcon_Sprig.snp.right).offset(4)
            make_Sprig.centerY.equalToSuperview()
            make_Sprig.right.equalToSuperview().offset(-8)
        }

        // 删除媒体按钮
        mediaCard_Sprig.addSubview(removeMediaButton_Sprig)
        removeMediaButton_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalToSuperview().offset(12)
            make_Sprig.right.equalToSuperview().offset(-12)
            make_Sprig.width.height.equalTo(28)
        }

        // 点击媒体区域唤起选择器
        let mediaTap_Sprig = UITapGestureRecognizer(target: self, action: #selector(handleMediaPickTap_Sprig))
        mediaCard_Sprig.addGestureRecognizer(mediaTap_Sprig)
        mediaCard_Sprig.isUserInteractionEnabled = true
    }

    /// 搭建底部发布按钮和 EULA 链接
    private func setupBottomButtons_Sprig() {
        scrollContentView_Sprig.addSubview(publishButton_Sprig)
        scrollContentView_Sprig.addSubview(eulaButton_Sprig)

        // 发布按钮渐变背景
        publishGradient_Sprig.colors = [
            ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor,
            ColorConfig_Sprig.primaryGradientEnd_Sprig.cgColor
        ]
        publishGradient_Sprig.startPoint = CGPoint(x: 0, y: 0.5)
        publishGradient_Sprig.endPoint = CGPoint(x: 1, y: 0.5)
        publishGradient_Sprig.cornerRadius = 26
        publishButton_Sprig.layer.insertSublayer(publishGradient_Sprig, at: 0)

        // 发布按钮阴影
        publishButton_Sprig.layer.shadowColor = ColorConfig_Sprig.primaryGradientStart_Sprig.cgColor
        publishButton_Sprig.layer.shadowOffset = CGSize(width: 0, height: 6)
        publishButton_Sprig.layer.shadowRadius = 12
        publishButton_Sprig.layer.shadowOpacity = 0.35

        publishButton_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(mediaCard_Sprig.snp.bottom).offset(28)
            make_Sprig.left.equalToSuperview().offset(24)
            make_Sprig.right.equalToSuperview().offset(-24)
            make_Sprig.height.equalTo(56)
        }

        // EULA 在发布按钮下方 10pt
        eulaButton_Sprig.snp.makeConstraints { make_Sprig in
            make_Sprig.top.equalTo(publishButton_Sprig.snp.bottom).offset(10)
            make_Sprig.centerX.equalToSuperview()
            make_Sprig.left.greaterThanOrEqualToSuperview().offset(24)
            make_Sprig.right.lessThanOrEqualToSuperview().offset(-24)
            make_Sprig.bottom.equalToSuperview().offset(-100)
        }
    }

    /// 注册按钮事件和键盘消除手势
    private func setupActions_Sprig() {
        publishButton_Sprig.addAction(UIAction { [weak self] _ in
            self?.handlePublish_Sprig()
        }, for: .touchUpInside)

        eulaButton_Sprig.addAction(UIAction { [weak self] _ in
            self?.handleEulaTap_Sprig()
        }, for: .touchUpInside)

        removeMediaButton_Sprig.addAction(UIAction { [weak self] _ in
            self?.clearMediaSelection_Sprig()
        }, for: .touchUpInside)
    }

    /// 注册点击背景收起键盘手势
    private func setupKeyboardDismiss_Sprig() {
        let tap_Sprig = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Sprig))
        tap_Sprig.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Sprig)
    }

    // MARK: - 媒体选取

    /// 点击媒体区域 - 唤起媒体选择器
    @objc private func handleMediaPickTap_Sprig() {
        // 媒体区域有内容时点击更换
        mediaCard_Sprig.animatePressDown_Sprig {
            self.mediaCard_Sprig.animatePressUp_Sprig()
        }

        MediaPickerHelper_Sprig.pickMedia_Sprig(from: self) { [weak self] result_Sprig in
            guard let self = self else { return }
            switch result_Sprig {
            case .photo_Sprig(let image_Sprig):
                self.applyImageMedia_Sprig(image: image_Sprig)

            case .video_Sprig(let url_Sprig):
                self.applyVideoMedia_Sprig(url: url_Sprig)

            case .cancelled_Sprig:
                print("用户取消了媒体选取")
            }
        }
    }

    /// 应用已选图片
    /// - Parameter image: 选取的图片
    private func applyImageMedia_Sprig(image: UIImage) {
        selectedImage_Sprig = image
        selectedVideoURL_Sprig = nil
        isImageMedia_Sprig = true

        // 保存图片到临时路径作为媒体路径字符串
        if let data_Sprig = image.jpegData(compressionQuality: 0.8) {
            let path_Sprig = FileManager.default.temporaryDirectory
                .appendingPathComponent("release_image_\(Date().timeIntervalSince1970).jpg")
            try? data_Sprig.write(to: path_Sprig)
            selectedMediaPath_Sprig = path_Sprig.path
        }

        // 更新预览 UI
        mediaPreviewImageView_Sprig.image = image
        showMediaPreview_Sprig(isVideo: false)
    }

    /// 应用已选视频
    /// - Parameter url: 视频文件 URL
    private func applyVideoMedia_Sprig(url: URL) {
        selectedVideoURL_Sprig = url
        selectedImage_Sprig = nil
        isImageMedia_Sprig = false
        selectedMediaPath_Sprig = url.path

        // 生成视频封面帧
        generateVideoThumbnail_Sprig(url: url) { [weak self] thumbnail_Sprig in
            self?.mediaPreviewImageView_Sprig.image = thumbnail_Sprig
        }

        showMediaPreview_Sprig(isVideo: true)
    }

    /// 生成视频封面
    /// - Parameters:
    ///   - url: 视频 URL
    ///   - completion: 封面回调
    private func generateVideoThumbnail_Sprig(url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset_Sprig = AVURLAsset(url: url)
            let generator_Sprig = AVAssetImageGenerator(asset: asset_Sprig)
            generator_Sprig.appliesPreferredTrackTransform = true
            let time_Sprig = CMTime(seconds: 0, preferredTimescale: 1)
            if let cgImage_Sprig = try? generator_Sprig.copyCGImage(at: time_Sprig, actualTime: nil) {
                let thumbnail_Sprig = UIImage(cgImage: cgImage_Sprig)
                DispatchQueue.main.async { completion(thumbnail_Sprig) }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }

    /// 显示媒体预览（隐藏占位提示，显示预览）
    /// - Parameter isVideo: 是否为视频媒体
    private func showMediaPreview_Sprig(isVideo: Bool) {
        mediaPickIcon_Sprig.isHidden = true
        mediaPickLabel_Sprig.isHidden = true
        mediaPickSubLabel_Sprig.isHidden = true
        mediaPreviewImageView_Sprig.isHidden = false
        removeMediaButton_Sprig.isHidden = false
        videoTagView_Sprig.isHidden = !isVideo

        // 更新边框颜色为主题色
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.mediaCard_Sprig.layer.borderColor = ColorConfig_Sprig.primaryGradientStart_Sprig.withAlphaComponent(0.5).cgColor
        }
    }

    /// 清除媒体选取，恢复占位状态
    private func clearMediaSelection_Sprig() {
        selectedImage_Sprig = nil
        selectedVideoURL_Sprig = nil
        selectedMediaPath_Sprig = nil

        mediaPreviewImageView_Sprig.image = nil
        mediaPreviewImageView_Sprig.isHidden = true
        removeMediaButton_Sprig.isHidden = true
        videoTagView_Sprig.isHidden = true
        mediaPickIcon_Sprig.isHidden = false
        mediaPickLabel_Sprig.isHidden = false
        mediaPickSubLabel_Sprig.isHidden = false

        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.mediaCard_Sprig.layer.borderColor = ColorConfig_Sprig.divider_Sprig.cgColor
        }
    }

    // MARK: - 发布逻辑

    /// 处理发布操作
    /// 逻辑顺序：检查登录 → 校验字段 → 调用 ViewModel 发布 → 成功后清空
    private func handlePublish_Sprig() {
        // 按钮动画
        publishButton_Sprig.animatePressDown_Sprig {
            self.publishButton_Sprig.animatePressUp_Sprig()
        }

        // 1. 检查是否登录
        guard UserViewModel_Sprig.shared_Sprig.isLoggedIn_Sprig else {
            Utils_Sprig.showWarning_Sprig(message_Sprig: "Please log in first to publish")
            Task {
                try? await Task.sleep(nanoseconds: 800_000_000)
                Navigation_Sprig.toLogin_Sprig(style_sprig: .present_sprig)
            }
            return
        }

        // 2. 获取输入内容并校验
        let title_Sprig = titleTextField_Sprig.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let content_Sprig = contentTextView_Sprig.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !title_Sprig.isEmpty else {
            Utils_Sprig.showWarning_Sprig(message_Sprig: "Please enter a title for your post")
            titleTextField_Sprig.becomeFirstResponder()
            return
        }

        guard !content_Sprig.isEmpty else {
            Utils_Sprig.showWarning_Sprig(message_Sprig: "Please write some content for your post")
            contentTextView_Sprig.becomeFirstResponder()
            return
        }

        guard let mediaPath_Sprig = selectedMediaPath_Sprig, !mediaPath_Sprig.isEmpty else {
            Utils_Sprig.showWarning_Sprig(message_Sprig: "Please add a photo or video to your post")
            return
        }

        // 3. 收集已选标签名称
        let selectedTagNames_sprig = selectedTagIndices_Sprig.sorted()
            .map { allTags_Sprig[$0].tagName_Sprig }

        // 4. 调用 ViewModel 发布
        TitleViewModel_Sprig.shared_Sprig.releasePost_Sprig(
            title_sprig: title_Sprig,
            content_sprig: content_Sprig,
            media_sprig: mediaPath_Sprig,
            tags_sprig: selectedTagNames_sprig
        )

        // 5. 发布成功后清空页面数据并关闭
        clearForm_Sprig()
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            dismissPage_Sprig()
        }
    }

    /// 点击 EULA 链接，通过 ProtocolHelper 展示用户协议图片
    private func handleEulaTap_Sprig() {
        eulaButton_Sprig.animatePulse_Sprig()
        ProtocolHelper_Sprig.showProtocol_Sprig(
            type_Sprig: .eula_Sprig,
            content_Sprig: "eula.png",
            from: self
        )
    }

    /// 清空表单数据（包含标签选取状态重置）
    private func clearForm_Sprig() {
        titleTextField_Sprig.text = ""
        contentTextView_Sprig.text = ""
        contentPlaceholder_Sprig.isHidden = false
        clearMediaSelection_Sprig()
        // 清除标签选中状态
        selectedTagIndices_Sprig.removeAll()
        buildTagChips_Sprig()
        view.endEditing(true)
    }

    /// 关闭页面（兼容 push 和 present）
    private func dismissPage_Sprig() {
        if navigationController?.viewControllers.first == self {
            Navigation_Sprig.dismiss_Sprig()
        } else {
            Navigation_Sprig.pop_Sprig()
        }
    }

    // MARK: - 辅助事件

    /// 收起键盘
    @objc private func dismissKeyboard_Sprig() {
        view.endEditing(true)
    }
}

// MARK: - UITextViewDelegate

extension Release_Sprig: UITextViewDelegate {

    /// 内容变化时隐藏/显示占位文字
    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder_Sprig.isHidden = !textView.text.isEmpty
    }

    /// 内容输入框获取焦点
    func textViewDidBeginEditing(_ textView: UITextView) {
        contentPlaceholder_Sprig.isHidden = !textView.text.isEmpty
    }

    /// 内容输入框失去焦点
    func textViewDidEndEditing(_ textView: UITextView) {
        contentPlaceholder_Sprig.isHidden = !textView.text.isEmpty
    }
}

// MARK: - 导入 AVFoundation（视频封面生成）
import AVFoundation
