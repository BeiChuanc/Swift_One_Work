import Foundation
import UIKit
import SnapKit
import AVFoundation

// MARK: 发布页

/// 发布页面
/// 核心作用：允许登录用户发布帖子，包含标题、内容和媒体的输入与发布
/// 设计思路：现代化渐变卡片布局，虚线媒体卡片，平滑表单交互
/// 关键属性/方法：
///   - selectedMediaPath_Tidy：已选媒体本地路径
///   - publishTapped_Tidy()：触发发布逻辑
///   - clearForm_Tidy()：发布成功后清空表单
class Release_Tidy: UIViewController {

    // MARK: - 私有数据属性

    /// 已选择的图片（图片类型媒体）
    private var selectedImage_Tidy: UIImage?

    /// 已选择的视频URL（视频类型媒体）
    private var selectedVideoURL_Tidy: URL?

    /// 当前选择媒体的本地路径，传递给ViewModel
    private var selectedMediaPath_Tidy: String?

    /// 内容文本视图占位文本常量
    private let contentPlaceholder_Tidy = "What's on your mind?"

    /// 当前选中的分类ID（对应 HomeCategory_Tidy.id_Tidy）
    private var selectedCategoryId_Tidy: String?

    /// 所有分类 Chip 引用（统一更新选中态）
    private var categoryChips_Tidy: [CategoryChip_Tidy] = []

    // MARK: - UI组件 - 主滚动容器

    /// 主滚动视图
    private let scrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        /// 禁止系统自动追加安全区 inset，避免顶部出现多余空白
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    /// 内容容器（SnapKit宽度锚定用）
    private let contentContainer_Tidy = UIView()

    // MARK: - UI组件 - 顶部渐变头部

    /// 顶部渐变头部卡片（圆角底部）
    private let headerCard_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 36
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// 头部渐变图层（延迟创建，layoutSubviews时设置）
    private var headerGradient_Tidy: CAGradientLayer?

    /// 头部装饰气泡1（右上角大圆）
    private let headerDecoBubble1_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 55
        return v
    }()

    /// 头部装饰气泡2（左下角）
    private let headerDecoBubble2_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 38
        return v
    }()

    /// 头部图标圆形背景容器
    private let headerIconCircle_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 30
        return v
    }()

    /// 头部图标
    private let headerIconView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "square.and.pencil")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 头部主标题
    private let headerTitleLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "Create a Post"
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        return l
    }()

    /// 头部副标题
    private let headerSubtitleLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "Share your home inspiration with the world"
        l.textColor = UIColor.white.withAlphaComponent(0.78)
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.numberOfLines = 1
        return l
    }()

    // MARK: - UI组件 - 标题输入卡片

    /// 标题输入卡片
    private let titleCard_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 14
        v.layer.shadowOpacity = 1
        return v
    }()

    /// 标题卡片左侧渐变装饰条
    private let titleAccentBar_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 3
        v.clipsToBounds = true
        return v
    }()

    /// 渐变装饰条图层（延迟创建）
    private var accentBarGradient_Tidy: CAGradientLayer?

    /// 标题区块标签
    private let titleSectionLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "TITLE"
        l.textColor = ColorConfig_Tidy.textSecondary_Tidy
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        return l
    }()

    /// 标题输入框
    private let titleTextField_Tidy: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Give your story a title...",
            attributes: [.foregroundColor: ColorConfig_Tidy.textPlaceholder_Tidy]
        )
        tf.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        tf.textColor = ColorConfig_Tidy.textPrimary_Tidy
        tf.borderStyle = .none
        tf.returnKeyType = .next
        return tf
    }()

    // MARK: - UI组件 - 内容输入卡片

    /// 内容输入卡片
    private let contentCard_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 14
        v.layer.shadowOpacity = 1
        return v
    }()

    /// 内容区块标签
    private let contentSectionLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "CONTENT"
        l.textColor = ColorConfig_Tidy.textSecondary_Tidy
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        return l
    }()

    /// 内容输入文本视图
    private let contentTextView_Tidy: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()

    // MARK: - UI组件 - 媒体选择卡片

    /// 媒体选择卡片
    private let mediaCard_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 14
        v.layer.shadowOpacity = 1
        return v
    }()

    /// 媒体区块标签
    private let mediaSectionLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "MEDIA"
        l.textColor = ColorConfig_Tidy.textSecondary_Tidy
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        return l
    }()

    /// 媒体点击容器（虚线边框装饰）
    private let mediaTapArea_Tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 虚线边框图层
    private let mediaDashBorder_Tidy = CAShapeLayer()

    /// 媒体预览图片视图
    private let mediaPreview_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()

    /// 媒体为空时的占位内容容器
    private let mediaEmptyView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        return v
    }()

    /// 媒体添加图标
    private let mediaAddIcon_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo.badge.plus.fill")
        iv.tintColor = ColorConfig_Tidy.primaryGradientStart_Tidy
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 媒体提示文字
    private let mediaHintLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "Tap to add photo or video"
        l.textColor = ColorConfig_Tidy.textSecondary_Tidy
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textAlignment = .center
        return l
    }()

    /// 媒体次要提示文字
    private let mediaSubhintLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "PNG · JPG · MP4 · MOV"
        l.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        l.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        l.textAlignment = .center
        return l
    }()

    /// 视频类型角标（视频时显示）
    private let videoBadgeView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        v.layer.cornerRadius = 11
        v.isHidden = true
        return v
    }()

    /// 视频角标图标
    private let videoBadgeIcon_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "video.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 视频角标文字
    private let videoBadgeLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "VIDEO"
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        return l
    }()

    /// 更换媒体按钮（有媒体时显示）
    private let changeMediaBtn_Tidy: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.9)
        btn.layer.cornerRadius = 17
        btn.isHidden = true
        return btn
    }()

    // MARK: - UI组件 - 分类选择卡片

    /// 分类选择卡片
    private let categoryCard_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 18
        v.layer.shadowColor = UIColor.black.withAlphaComponent(0.07).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 14
        v.layer.shadowOpacity = 1
        return v
    }()

    /// 分类区块标签
    private let categorySectionLabel_Tidy: UILabel = {
        let l = UILabel()
        l.text = "CATEGORY"
        l.textColor = ColorConfig_Tidy.textSecondary_Tidy
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        return l
    }()

    /// 分类横向滚动容器
    private let categoryScrollView_Tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.clipsToBounds = false
        return sv
    }()

    /// 分类横向 StackView，间距 10
    private let categoryHStack_Tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.alignment = .center
        return sv
    }()

    // MARK: - UI组件 - 发布按钮

    /// 发布按钮（渐变背景）
    private let publishBtn_Tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 28
        btn.clipsToBounds = true
        btn.setTitle("Publish Post  ✦", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return btn
    }()

    /// 发布按钮渐变图层（延迟创建）
    private var publishGradient_Tidy: CAGradientLayer?

    /// EULA协议标签（ProtocolHelper创建）
    private var eulaLabel_Tidy: UILabel?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 返回此页面时确保导航栏隐藏
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Tidy()
        buildCategoryChips_Tidy()
        setupConstraints_Tidy()
        setupGestures_Tidy()
        setupKeyboard_Tidy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /// 布局完成后设置渐变与虚线边框
        updateLayerFrames_Tidy()
    }

    // MARK: - UI搭建

    /// 搭建所有UI组件
    private func setupUI_Tidy() {
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy

        view.addSubview(scrollView_Tidy)
        scrollView_Tidy.addSubview(contentContainer_Tidy)

        /// 头部卡片
        contentContainer_Tidy.addSubview(headerCard_Tidy)
        headerCard_Tidy.addSubview(headerDecoBubble1_Tidy)
        headerCard_Tidy.addSubview(headerDecoBubble2_Tidy)
        headerCard_Tidy.addSubview(headerIconCircle_Tidy)
        headerIconCircle_Tidy.addSubview(headerIconView_Tidy)
        headerCard_Tidy.addSubview(headerTitleLabel_Tidy)
        headerCard_Tidy.addSubview(headerSubtitleLabel_Tidy)

        /// 标题卡片
        contentContainer_Tidy.addSubview(titleCard_Tidy)
        titleCard_Tidy.addSubview(titleAccentBar_Tidy)
        titleCard_Tidy.addSubview(titleSectionLabel_Tidy)
        titleCard_Tidy.addSubview(titleTextField_Tidy)
        titleTextField_Tidy.delegate = self

        /// 内容卡片
        contentContainer_Tidy.addSubview(contentCard_Tidy)
        contentCard_Tidy.addSubview(contentSectionLabel_Tidy)
        contentCard_Tidy.addSubview(contentTextView_Tidy)
        contentTextView_Tidy.delegate = self
        contentTextView_Tidy.text = contentPlaceholder_Tidy

        /// 媒体卡片
        contentContainer_Tidy.addSubview(mediaCard_Tidy)
        mediaCard_Tidy.addSubview(mediaSectionLabel_Tidy)
        mediaCard_Tidy.addSubview(mediaTapArea_Tidy)
        mediaTapArea_Tidy.addSubview(mediaEmptyView_Tidy)
        mediaEmptyView_Tidy.addSubview(mediaAddIcon_Tidy)
        mediaEmptyView_Tidy.addSubview(mediaHintLabel_Tidy)
        mediaEmptyView_Tidy.addSubview(mediaSubhintLabel_Tidy)
        mediaTapArea_Tidy.addSubview(mediaPreview_Tidy)
        mediaTapArea_Tidy.addSubview(videoBadgeView_Tidy)
        videoBadgeView_Tidy.addSubview(videoBadgeIcon_Tidy)
        videoBadgeView_Tidy.addSubview(videoBadgeLabel_Tidy)
        mediaTapArea_Tidy.addSubview(changeMediaBtn_Tidy)

        /// 虚线边框图层
        mediaDashBorder_Tidy.strokeColor = ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.4).cgColor
        mediaDashBorder_Tidy.lineDashPattern = [6, 4]
        mediaDashBorder_Tidy.lineWidth = 1.5
        mediaDashBorder_Tidy.fillColor = UIColor.clear.cgColor
        mediaTapArea_Tidy.layer.addSublayer(mediaDashBorder_Tidy)

        /// 分类卡片
        contentContainer_Tidy.addSubview(categoryCard_Tidy)
        categoryCard_Tidy.addSubview(categorySectionLabel_Tidy)
        categoryCard_Tidy.addSubview(categoryScrollView_Tidy)
        categoryScrollView_Tidy.addSubview(categoryHStack_Tidy)

        /// 发布按钮
        contentContainer_Tidy.addSubview(publishBtn_Tidy)
        publishBtn_Tidy.addTarget(self, action: #selector(publishTapped_Tidy), for: .touchUpInside)

        /// EULA标签：纯文本 "EULA" + 下划线，点击展示协议详情
        let eulaLbl = UILabel()
        eulaLbl.textAlignment = .center
        eulaLbl.isUserInteractionEnabled = true
        let eulaAttrs_Tidy: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: ColorConfig_Tidy.textSecondary_Tidy,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: ColorConfig_Tidy.textSecondary_Tidy
        ]
        eulaLbl.attributedText = NSAttributedString(string: "EULA", attributes: eulaAttrs_Tidy)
        let eulaTap_Tidy = UITapGestureRecognizer(target: self, action: #selector(eulaTapped_Tidy))
        eulaLbl.addGestureRecognizer(eulaTap_Tidy)
        eulaLabel_Tidy = eulaLbl
        contentContainer_Tidy.addSubview(eulaLbl)
    }

    // MARK: - 构建分类 Chip

    /// 从 ViewModel 读取分类列表（排除 "all"），生成 CategoryChip 并填入横向 StackView
    private func buildCategoryChips_Tidy() {
        categoryChips_Tidy.removeAll()
        // 左侧首项内边距
        let leading_Tidy = UIView()
        categoryHStack_Tidy.addArrangedSubview(leading_Tidy)
        leading_Tidy.snp.makeConstraints { $0.width.equalTo(4) }

        let allCategories_Tidy = TitleViewModel_Tidy.shared_Tidy.getCategories_Tidy()
        allCategories_Tidy.filter { $0.id_Tidy != "all" }.forEach { category_Tidy in
            let chip_Tidy = CategoryChip_Tidy()
            chip_Tidy.configure_Tidy(category: category_Tidy)
            chip_Tidy.onTap_Tidy = { [weak self] categoryId_Tidy in
                self?.updateCategorySelection_Tidy(categoryId: categoryId_Tidy)
            }
            categoryHStack_Tidy.addArrangedSubview(chip_Tidy)
            chip_Tidy.snp.makeConstraints { $0.height.equalTo(36) }
            categoryChips_Tidy.append(chip_Tidy)
        }

        // 右侧末项内边距
        let trailing_Tidy = UIView()
        categoryHStack_Tidy.addArrangedSubview(trailing_Tidy)
        trailing_Tidy.snp.makeConstraints { $0.width.equalTo(4) }
    }

    // MARK: - 分类选中更新

    /// 更新所有 Chip 的选中态，并记录当前选中分类ID
    /// - Parameter categoryId: 被选中的分类 ID
    private func updateCategorySelection_Tidy(categoryId: String) {
        selectedCategoryId_Tidy = categoryId
        categoryChips_Tidy.forEach { chip_Tidy in
            chip_Tidy.setSelected_Tidy(chip_Tidy.categoryId_Tidy == categoryId)
        }
    }

    // MARK: - 约束布局

    /// 设置SnapKit约束
    private func setupConstraints_Tidy() {
        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        scrollView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentContainer_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Tidy)
        }

        /// 头部卡片
        headerCard_Tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop + 110)
        }

        /// 装饰气泡1（右上角超出边界，制造层次感）
        headerDecoBubble1_Tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(-28)
            make.width.height.equalTo(150)
        }

        /// 装饰气泡2（左下角）
        headerDecoBubble2_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(28)
            make.width.height.equalTo(110)
        }

        /// 图标圆圈（左侧居中对齐文字）
        headerIconCircle_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().offset(-18)
            make.width.height.equalTo(60)
        }

        headerIconView_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        /// 主标题（图标右侧）
        headerTitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(headerIconCircle_Tidy.snp.trailing).offset(14)
            make.bottom.equalTo(headerSubtitleLabel_Tidy.snp.top).offset(-5)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        /// 副标题（与主标题左对齐）
        headerSubtitleLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(headerIconCircle_Tidy.snp.trailing).offset(14)
            make.bottom.equalTo(headerIconCircle_Tidy.snp.bottom)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        /// 标题卡片
        titleCard_Tidy.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Tidy.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        titleAccentBar_Tidy.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(14)
            make.width.equalTo(4)
        }

        titleSectionLabel_Tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(titleAccentBar_Tidy.snp.trailing).offset(12)
        }

        titleTextField_Tidy.snp.makeConstraints { make in
            make.top.equalTo(titleSectionLabel_Tidy.snp.bottom).offset(7)
            make.leading.equalTo(titleAccentBar_Tidy.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(36)
        }

        /// 内容卡片
        contentCard_Tidy.snp.makeConstraints { make in
            make.top.equalTo(titleCard_Tidy.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        contentSectionLabel_Tidy.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }

        contentTextView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(contentSectionLabel_Tidy.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-14)
            make.height.greaterThanOrEqualTo(96)
        }

        /// 媒体卡片
        mediaCard_Tidy.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Tidy.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        mediaSectionLabel_Tidy.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }

        mediaTapArea_Tidy.snp.makeConstraints { make in
            make.top.equalTo(mediaSectionLabel_Tidy.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(190)
        }

        mediaEmptyView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mediaPreview_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mediaAddIcon_Tidy.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-18)
            make.width.height.equalTo(46)
        }

        mediaHintLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(mediaAddIcon_Tidy.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        mediaSubhintLabel_Tidy.snp.makeConstraints { make in
            make.top.equalTo(mediaHintLabel_Tidy.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        videoBadgeView_Tidy.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(10)
            make.height.equalTo(26)
            make.width.equalTo(82)
        }

        videoBadgeIcon_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        videoBadgeLabel_Tidy.snp.makeConstraints { make in
            make.leading.equalTo(videoBadgeIcon_Tidy.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
        }

        changeMediaBtn_Tidy.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(10)
            make.width.height.equalTo(34)
        }

        /// 分类卡片（在 mediaCard 下方 14pt）
        categoryCard_Tidy.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Tidy.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        categorySectionLabel_Tidy.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }

        categoryScrollView_Tidy.snp.makeConstraints { make in
            make.top.equalTo(categorySectionLabel_Tidy.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(36)
        }

        categoryHStack_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        /// 发布按钮（在 categoryCard 下方 20pt）
        publishBtn_Tidy.snp.makeConstraints { make in
            make.top.equalTo(categoryCard_Tidy.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }

        /// EULA标签（距发布按钮底部 10pt）
        eulaLabel_Tidy?.snp.makeConstraints { make in
            make.top.equalTo(publishBtn_Tidy.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-120)
        }
    }

    // MARK: - 手势设置

    /// 绑定媒体选择和发布手势
    private func setupGestures_Tidy() {
        /// 媒体区域点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectMediaTapped_Tidy))
        mediaTapArea_Tidy.addGestureRecognizer(tap)

        /// 更换媒体按钮
        changeMediaBtn_Tidy.addTarget(self, action: #selector(selectMediaTapped_Tidy), for: .touchUpInside)

        /// 点击空白收起键盘
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Tidy))
        bgTap.cancelsTouchesInView = false
        view.addGestureRecognizer(bgTap)
    }

    // MARK: - 键盘处理

    /// 注册键盘通知
    private func setupKeyboard_Tidy() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Tidy(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Tidy(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func keyboardWillShow_Tidy(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView_Tidy.contentInset.bottom = frame.height + 20
        scrollView_Tidy.scrollIndicatorInsets.bottom = frame.height
    }

    @objc private func keyboardWillHide_Tidy(_ notification: Notification) {
        scrollView_Tidy.contentInset.bottom = 0
        scrollView_Tidy.scrollIndicatorInsets.bottom = 0
    }

    @objc private func dismissKeyboard_Tidy() {
        view.endEditing(true)
    }

    // MARK: - 图层帧更新

    /// 布局完成后更新渐变和虚线边框的frame
    private func updateLayerFrames_Tidy() {
        /// 头部渐变
        if headerGradient_Tidy == nil && headerCard_Tidy.bounds.width > 0 {
            let grad = UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: headerCard_Tidy.bounds)
            grad.cornerRadius = 36
            grad.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            headerCard_Tidy.layer.insertSublayer(grad, at: 0)
            headerGradient_Tidy = grad
        } else {
            headerGradient_Tidy?.frame = headerCard_Tidy.bounds
        }

        /// 标题装饰条渐变
        if accentBarGradient_Tidy == nil && titleAccentBar_Tidy.bounds.height > 0 {
            let grad = UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: titleAccentBar_Tidy.bounds)
            titleAccentBar_Tidy.layer.insertSublayer(grad, at: 0)
            accentBarGradient_Tidy = grad
        } else {
            accentBarGradient_Tidy?.frame = titleAccentBar_Tidy.bounds
        }

        /// 发布按钮渐变
        if publishGradient_Tidy == nil && publishBtn_Tidy.bounds.width > 0 {
            let grad = UIColor.createPrimaryGradientLayer_Tidy(frame_Tidy: publishBtn_Tidy.bounds)
            publishBtn_Tidy.layer.insertSublayer(grad, at: 0)
            publishGradient_Tidy = grad
        } else {
            publishGradient_Tidy?.frame = publishBtn_Tidy.bounds
        }

        /// 更新虚线边框路径
        if mediaTapArea_Tidy.bounds.width > 0 {
            let path = UIBezierPath(roundedRect: mediaTapArea_Tidy.bounds, cornerRadius: 14)
            mediaDashBorder_Tidy.path = path.cgPath
            mediaDashBorder_Tidy.frame = mediaTapArea_Tidy.bounds
        }
    }

    // MARK: - 事件处理

    /// 点击媒体区域，弹出相册选择器
    @objc private func selectMediaTapped_Tidy() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        mediaTapArea_Tidy.animatePressDown_Tidy {
            self.mediaTapArea_Tidy.animatePressUp_Tidy()
        }

        /// 调用媒体选择工具（图片或视频均可选）
        MediaPickerHelper_Tidy.pickMedia_Tidy(from: self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .photo_Tidy(let image):
                self.selectedImage_Tidy = image
                self.selectedVideoURL_Tidy = nil
                self.selectedMediaPath_Tidy = self.saveImageToDocuments_Tidy(image: image)
                self.refreshMediaPreview_Tidy(previewImage: image, isVideo: false)

            case .video_Tidy(let url):
                self.selectedVideoURL_Tidy = url
                self.selectedImage_Tidy = nil
                self.selectedMediaPath_Tidy = url.path
                let thumbnail = self.generateVideoThumbnail_Tidy(url: url)
                self.refreshMediaPreview_Tidy(previewImage: thumbnail, isVideo: true)

            case .cancelled_Tidy:
                break
            }
        }
    }

    /// 点击 EULA 标签，展示 EULA 协议详情（与设置页调用方式一致）
    @objc private func eulaTapped_Tidy() {
        ProtocolHelper_Tidy.showProtocol_Tidy(
            type_Tidy: .eula_Tidy,
            content_Tidy: "eula.png",
            from: self
        )
    }

    /// 点击发布按钮
    @objc private func publishTapped_Tidy() {
        publishBtn_Tidy.animatePressDown_Tidy {
            self.publishBtn_Tidy.animatePressUp_Tidy()
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        /// 第一步：检查是否登录，未登录跳转登录页
        guard UserViewModel_Tidy.shared_Tidy.isLoggedIn_Tidy else {
            Navigation_Tidy.toLogin_Tidy(style_tidy: .present_tidy)
            return
        }

        /// 获取并修剪输入内容
        let title = titleTextField_Tidy.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isPlaceholder = contentTextView_Tidy.textColor == ColorConfig_Tidy.textPlaceholder_Tidy
        let content = isPlaceholder ? "" : (contentTextView_Tidy.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")

        /// 第二步：校验标题不为空
        guard !title.isEmpty else {
            Utils_Tidy.showWarning_Tidy(message_Tidy: "Please enter a title.")
            titleTextField_Tidy.animateShake_Tidy()
            return
        }

        /// 第三步：校验内容不为空
        guard !content.isEmpty else {
            Utils_Tidy.showWarning_Tidy(message_Tidy: "Please enter some content.")
            contentTextView_Tidy.animateShake_Tidy()
            return
        }

        /// 第四步：校验媒体已选择
        guard let mediaPath = selectedMediaPath_Tidy, !mediaPath.isEmpty else {
            Utils_Tidy.showWarning_Tidy(message_Tidy: "Please add a photo or video.")
            mediaCard_Tidy.animateShake_Tidy()
            return
        }

        /// 第五步：校验已选择分类
        guard let categoryId = selectedCategoryId_Tidy else {
            Utils_Tidy.showWarning_Tidy(message_Tidy: "Please select a category.")
            categoryCard_Tidy.animateShake_Tidy()
            return
        }

        /// 调用ViewModel发布帖子（携带分类ID）
        Task { @MainActor in
            TitleViewModel_Tidy.shared_Tidy.releasePost_Tidy(
                title_tidy: title,
                content_tidy: content,
                media_tidy: mediaPath,
                category_tidy: categoryId
            )
            /// 发布完成后清空表单数据
            self.clearForm_Tidy()
        }
    }

    // MARK: - 表单更新

    /// 刷新媒体预览区域
    /// - Parameters:
    ///   - previewImage: 预览图（视频为缩略图）
    ///   - isVideo: 是否为视频
    private func refreshMediaPreview_Tidy(previewImage: UIImage?, isVideo: Bool) {
        DispatchQueue.main.async {
            if let img = previewImage {
                self.mediaPreview_Tidy.image = img
                self.mediaPreview_Tidy.isHidden = false
                self.mediaEmptyView_Tidy.isHidden = true
                self.videoBadgeView_Tidy.isHidden = !isVideo
                self.changeMediaBtn_Tidy.isHidden = false
                self.mediaPreview_Tidy.animateSpringScaleIn_Tidy()
                /// 有媒体时隐藏虚线边框
                self.mediaDashBorder_Tidy.strokeColor = UIColor.clear.cgColor
            } else {
                self.mediaPreview_Tidy.isHidden = true
                self.mediaEmptyView_Tidy.isHidden = false
                self.videoBadgeView_Tidy.isHidden = true
                self.changeMediaBtn_Tidy.isHidden = true
                self.mediaDashBorder_Tidy.strokeColor = ColorConfig_Tidy.primaryGradientStart_Tidy.withAlphaComponent(0.4).cgColor
            }
        }
    }

    /// 清空表单所有输入、媒体及分类数据
    private func clearForm_Tidy() {
        titleTextField_Tidy.text = ""
        contentTextView_Tidy.text = contentPlaceholder_Tidy
        contentTextView_Tidy.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        selectedImage_Tidy = nil
        selectedVideoURL_Tidy = nil
        selectedMediaPath_Tidy = nil
        // 重置分类选中状态
        selectedCategoryId_Tidy = nil
        categoryChips_Tidy.forEach { $0.setSelected_Tidy(false) }
        refreshMediaPreview_Tidy(previewImage: nil, isVideo: false)
    }

    // MARK: - 私有工具方法

    /// 将图片保存到文档目录，返回文件路径
    /// - Parameter image: 要保存的UIImage
    /// - Returns: 文件路径字符串，失败返回nil
    private func saveImageToDocuments_Tidy(image: UIImage) -> String? {
        let fileName = "user_post_\(UUID().uuidString).jpg"
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docURL.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("❌ 保存图片失败: \(error)")
            return nil
        }
    }

    /// 从视频URL生成缩略图
    /// - Parameter url: 视频文件URL
    /// - Returns: 第1秒帧的UIImage，失败返回系统占位图
    private func generateVideoThumbnail_Tidy(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 60)
        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("⚠️ 视频缩略图生成失败: \(error)")
            return UIImage(systemName: "video.fill")
        }
    }

    // MARK: - 析构

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextViewDelegate

extension Release_Tidy: UITextViewDelegate {

    /// 开始编辑时清除占位文本
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == ColorConfig_Tidy.textPlaceholder_Tidy {
            textView.text = ""
            textView.textColor = ColorConfig_Tidy.textPrimary_Tidy
        }
    }

    /// 结束编辑时恢复占位文本
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = contentPlaceholder_Tidy
            textView.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        }
    }
}

// MARK: - UITextFieldDelegate

extension Release_Tidy: UITextFieldDelegate {

    /// 标题输入框回车跳转到内容文本框
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Tidy.becomeFirstResponder()
        return true
    }
}

// MARK: - CategoryChip_Tidy

/// 分类选择 Chip 视图
/// 核心作用：展示单个家居分类标签（图标 + 名称），支持选中/未选中态切换与点击回调
/// 设计思路：圆角胶囊形卡片，未选中浅灰底+次要文字色，选中分类主题色底+白色文字
/// 关键方法：
/// - configure_Tidy: 注入分类数据（图标、名称、颜色）
/// - setSelected_Tidy: 切换选中态
private class CategoryChip_Tidy: UIView {

    // MARK: - 属性

    /// 当前分类ID（外部只读）
    private(set) var categoryId_Tidy: String = ""

    /// 点击回调，回传分类 ID
    var onTap_Tidy: ((String) -> Void)?

    /// 分类主题色（选中时用作背景）
    private var themeColor_Tidy: UIColor = ColorConfig_Tidy.primaryGradientStart_Tidy

    // MARK: - UI

    /// 分类图标
    private let iconView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Tidy.textSecondary_Tidy
        return iv
    }()

    /// 分类名称
    private let nameLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = ColorConfig_Tidy.textSecondary_Tidy
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Tidy()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Tidy() {
        backgroundColor    = UIColor(white: 0.95, alpha: 1)
        layer.cornerRadius = 18

        let stack_Tidy = UIStackView(arrangedSubviews: [iconView_Tidy, nameLabel_Tidy])
        stack_Tidy.axis      = .horizontal
        stack_Tidy.spacing   = 5
        stack_Tidy.alignment = .center
        addSubview(stack_Tidy)

        iconView_Tidy.snp.makeConstraints { $0.width.height.equalTo(14) }
        stack_Tidy.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.bottom.equalToSuperview().inset(8)
        }

        let tap_Tidy = UITapGestureRecognizer(target: self, action: #selector(handleTap_Tidy))
        addGestureRecognizer(tap_Tidy)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入分类数据
    /// - Parameter category: HomeCategory_Tidy 分类模型
    func configure_Tidy(category: HomeCategory_Tidy) {
        categoryId_Tidy        = category.id_Tidy
        nameLabel_Tidy.text    = category.name_Tidy
        iconView_Tidy.image    = UIImage(systemName: category.iconName_Tidy)?
            .withRenderingMode(.alwaysTemplate)
        themeColor_Tidy        = UIColor(hexstring_Tidy: category.colorHex_Tidy)
    }

    // MARK: - 选中态切换

    /// 切换选中状态
    /// - Parameter selected: true 为选中（分类主题色背景 + 白色内容），false 为未选中（浅灰背景 + 次要色内容）
    func setSelected_Tidy(_ selected: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor        = selected ? self.themeColor_Tidy : UIColor(white: 0.95, alpha: 1)
            self.iconView_Tidy.tintColor = selected ? .white : ColorConfig_Tidy.textSecondary_Tidy
            self.nameLabel_Tidy.textColor = selected ? .white : ColorConfig_Tidy.textSecondary_Tidy
        }
    }

    // MARK: - 点击处理

    @objc private func handleTap_Tidy() {
        onTap_Tidy?(categoryId_Tidy)
    }
}
