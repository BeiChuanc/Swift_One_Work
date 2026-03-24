import Foundation
import UIKit
import SnapKit
import AVFoundation

// MARK: 发布页

/// 发布页面
/// 核心作用：允许登录用户发布帖子，包含标题、内容和媒体的输入与发布
/// 设计思路：现代化渐变卡片布局，虚线媒体卡片，平滑表单交互
/// 关键属性/方法：
///   - selectedMediaPath_Base_one：已选媒体本地路径
///   - publishTapped_Base_one()：触发发布逻辑
///   - clearForm_Base_one()：发布成功后清空表单
class Release_Base_one: UIViewController {

    // MARK: - 私有数据属性

    /// 已选择的图片（图片类型媒体）
    private var selectedImage_Base_one: UIImage?

    /// 已选择的视频URL（视频类型媒体）
    private var selectedVideoURL_Base_one: URL?

    /// 当前选择媒体的本地路径，传递给ViewModel
    private var selectedMediaPath_Base_one: String?

    /// 内容文本视图占位文本常量
    private let contentPlaceholder_Base_one = "What's on your mind?"

    /// 当前选中的分类ID（对应 HomeCategory_Base_one.id_Base_one）
    private var selectedCategoryId_Base_one: String?

    /// 所有分类 Chip 引用（统一更新选中态）
    private var categoryChips_Base_one: [CategoryChip_Base_one] = []

    // MARK: - UI组件 - 主滚动容器

    /// 主滚动视图
    private let scrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        /// 禁止系统自动追加安全区 inset，避免顶部出现多余空白
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    /// 内容容器（SnapKit宽度锚定用）
    private let contentContainer_Base_one = UIView()

    // MARK: - UI组件 - 顶部渐变头部

    /// 顶部渐变头部卡片（圆角底部）
    private let headerCard_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 36
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// 头部渐变图层（延迟创建，layoutSubviews时设置）
    private var headerGradient_Base_one: CAGradientLayer?

    /// 头部装饰气泡1（右上角大圆）
    private let headerDecoBubble1_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        v.layer.cornerRadius = 55
        return v
    }()

    /// 头部装饰气泡2（左下角）
    private let headerDecoBubble2_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.layer.cornerRadius = 38
        return v
    }()

    /// 头部图标圆形背景容器
    private let headerIconCircle_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.cornerRadius = 30
        return v
    }()

    /// 头部图标
    private let headerIconView_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "square.and.pencil")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 头部主标题
    private let headerTitleLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "Create a Post"
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        return l
    }()

    /// 头部副标题
    private let headerSubtitleLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "Share your home inspiration with the world"
        l.textColor = UIColor.white.withAlphaComponent(0.78)
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.numberOfLines = 1
        return l
    }()

    // MARK: - UI组件 - 标题输入卡片

    /// 标题输入卡片
    private let titleCard_Base_one: UIView = {
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
    private let titleAccentBar_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 3
        v.clipsToBounds = true
        return v
    }()

    /// 渐变装饰条图层（延迟创建）
    private var accentBarGradient_Base_one: CAGradientLayer?

    /// 标题区块标签
    private let titleSectionLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "TITLE"
        l.textColor = ColorConfig_Base_one.textSecondary_Base_one
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        return l
    }()

    /// 标题输入框
    private let titleTextField_Base_one: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "Give your story a title...",
            attributes: [.foregroundColor: ColorConfig_Base_one.textPlaceholder_Base_one]
        )
        tf.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        tf.textColor = ColorConfig_Base_one.textPrimary_Base_one
        tf.borderStyle = .none
        tf.returnKeyType = .next
        return tf
    }()

    // MARK: - UI组件 - 内容输入卡片

    /// 内容输入卡片
    private let contentCard_Base_one: UIView = {
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
    private let contentSectionLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "CONTENT"
        l.textColor = ColorConfig_Base_one.textSecondary_Base_one
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        return l
    }()

    /// 内容输入文本视图
    private let contentTextView_Base_one: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tv.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()

    // MARK: - UI组件 - 媒体选择卡片

    /// 媒体选择卡片
    private let mediaCard_Base_one: UIView = {
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
    private let mediaSectionLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "MEDIA"
        l.textColor = ColorConfig_Base_one.textSecondary_Base_one
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        return l
    }()

    /// 媒体点击容器（虚线边框装饰）
    private let mediaTapArea_Base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 14
        v.clipsToBounds = true
        v.isUserInteractionEnabled = true
        return v
    }()

    /// 虚线边框图层
    private let mediaDashBorder_Base_one = CAShapeLayer()

    /// 媒体预览图片视图
    private let mediaPreview_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        return iv
    }()

    /// 媒体为空时的占位内容容器
    private let mediaEmptyView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        return v
    }()

    /// 媒体添加图标
    private let mediaAddIcon_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo.badge.plus.fill")
        iv.tintColor = ColorConfig_Base_one.primaryGradientStart_Base_one
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 媒体提示文字
    private let mediaHintLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "Tap to add photo or video"
        l.textColor = ColorConfig_Base_one.textSecondary_Base_one
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textAlignment = .center
        return l
    }()

    /// 媒体次要提示文字
    private let mediaSubhintLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "PNG · JPG · MP4 · MOV"
        l.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        l.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        l.textAlignment = .center
        return l
    }()

    /// 视频类型角标（视频时显示）
    private let videoBadgeView_Base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        v.layer.cornerRadius = 11
        v.isHidden = true
        return v
    }()

    /// 视频角标图标
    private let videoBadgeIcon_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "video.fill")
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 视频角标文字
    private let videoBadgeLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "VIDEO"
        l.textColor = .white
        l.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        return l
    }()

    /// 更换媒体按钮（有媒体时显示）
    private let changeMediaBtn_Base_one: UIButton = {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "arrow.triangle.2.circlepath", withConfiguration: config), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = ColorConfig_Base_one.primaryGradientStart_Base_one.withAlphaComponent(0.9)
        btn.layer.cornerRadius = 17
        btn.isHidden = true
        return btn
    }()

    // MARK: - UI组件 - 分类选择卡片

    /// 分类选择卡片
    private let categoryCard_Base_one: UIView = {
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
    private let categorySectionLabel_Base_one: UILabel = {
        let l = UILabel()
        l.text = "CATEGORY"
        l.textColor = ColorConfig_Base_one.textSecondary_Base_one
        l.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        return l
    }()

    /// 分类横向滚动容器
    private let categoryScrollView_Base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.clipsToBounds = false
        return sv
    }()

    /// 分类横向 StackView，间距 10
    private let categoryHStack_Base_one: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.alignment = .center
        return sv
    }()

    // MARK: - UI组件 - 发布按钮

    /// 发布按钮（渐变背景）
    private let publishBtn_Base_one: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 28
        btn.clipsToBounds = true
        btn.setTitle("Publish Post  ✦", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return btn
    }()

    /// 发布按钮渐变图层（延迟创建）
    private var publishGradient_Base_one: CAGradientLayer?

    /// EULA协议标签（ProtocolHelper创建）
    private var eulaLabel_Base_one: UILabel?

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// 返回此页面时确保导航栏隐藏
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Base_one()
        buildCategoryChips_Base_one()
        setupConstraints_Base_one()
        setupGestures_Base_one()
        setupKeyboard_Base_one()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /// 布局完成后设置渐变与虚线边框
        updateLayerFrames_Base_one()
    }

    // MARK: - UI搭建

    /// 搭建所有UI组件
    private func setupUI_Base_one() {
        view.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one

        view.addSubview(scrollView_Base_one)
        scrollView_Base_one.addSubview(contentContainer_Base_one)

        /// 头部卡片
        contentContainer_Base_one.addSubview(headerCard_Base_one)
        headerCard_Base_one.addSubview(headerDecoBubble1_Base_one)
        headerCard_Base_one.addSubview(headerDecoBubble2_Base_one)
        headerCard_Base_one.addSubview(headerIconCircle_Base_one)
        headerIconCircle_Base_one.addSubview(headerIconView_Base_one)
        headerCard_Base_one.addSubview(headerTitleLabel_Base_one)
        headerCard_Base_one.addSubview(headerSubtitleLabel_Base_one)

        /// 标题卡片
        contentContainer_Base_one.addSubview(titleCard_Base_one)
        titleCard_Base_one.addSubview(titleAccentBar_Base_one)
        titleCard_Base_one.addSubview(titleSectionLabel_Base_one)
        titleCard_Base_one.addSubview(titleTextField_Base_one)
        titleTextField_Base_one.delegate = self

        /// 内容卡片
        contentContainer_Base_one.addSubview(contentCard_Base_one)
        contentCard_Base_one.addSubview(contentSectionLabel_Base_one)
        contentCard_Base_one.addSubview(contentTextView_Base_one)
        contentTextView_Base_one.delegate = self
        contentTextView_Base_one.text = contentPlaceholder_Base_one

        /// 媒体卡片
        contentContainer_Base_one.addSubview(mediaCard_Base_one)
        mediaCard_Base_one.addSubview(mediaSectionLabel_Base_one)
        mediaCard_Base_one.addSubview(mediaTapArea_Base_one)
        mediaTapArea_Base_one.addSubview(mediaEmptyView_Base_one)
        mediaEmptyView_Base_one.addSubview(mediaAddIcon_Base_one)
        mediaEmptyView_Base_one.addSubview(mediaHintLabel_Base_one)
        mediaEmptyView_Base_one.addSubview(mediaSubhintLabel_Base_one)
        mediaTapArea_Base_one.addSubview(mediaPreview_Base_one)
        mediaTapArea_Base_one.addSubview(videoBadgeView_Base_one)
        videoBadgeView_Base_one.addSubview(videoBadgeIcon_Base_one)
        videoBadgeView_Base_one.addSubview(videoBadgeLabel_Base_one)
        mediaTapArea_Base_one.addSubview(changeMediaBtn_Base_one)

        /// 虚线边框图层
        mediaDashBorder_Base_one.strokeColor = ColorConfig_Base_one.primaryGradientStart_Base_one.withAlphaComponent(0.4).cgColor
        mediaDashBorder_Base_one.lineDashPattern = [6, 4]
        mediaDashBorder_Base_one.lineWidth = 1.5
        mediaDashBorder_Base_one.fillColor = UIColor.clear.cgColor
        mediaTapArea_Base_one.layer.addSublayer(mediaDashBorder_Base_one)

        /// 分类卡片
        contentContainer_Base_one.addSubview(categoryCard_Base_one)
        categoryCard_Base_one.addSubview(categorySectionLabel_Base_one)
        categoryCard_Base_one.addSubview(categoryScrollView_Base_one)
        categoryScrollView_Base_one.addSubview(categoryHStack_Base_one)

        /// 发布按钮
        contentContainer_Base_one.addSubview(publishBtn_Base_one)
        publishBtn_Base_one.addTarget(self, action: #selector(publishTapped_Base_one), for: .touchUpInside)

        /// EULA标签：纯文本 "EULA" + 下划线，点击展示协议详情
        let eulaLbl = UILabel()
        eulaLbl.textAlignment = .center
        eulaLbl.isUserInteractionEnabled = true
        let eulaAttrs_Base_one: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: ColorConfig_Base_one.textSecondary_Base_one,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: ColorConfig_Base_one.textSecondary_Base_one
        ]
        eulaLbl.attributedText = NSAttributedString(string: "EULA", attributes: eulaAttrs_Base_one)
        let eulaTap_Base_one = UITapGestureRecognizer(target: self, action: #selector(eulaTapped_Base_one))
        eulaLbl.addGestureRecognizer(eulaTap_Base_one)
        eulaLabel_Base_one = eulaLbl
        contentContainer_Base_one.addSubview(eulaLbl)
    }

    // MARK: - 构建分类 Chip

    /// 从 ViewModel 读取分类列表（排除 "all"），生成 CategoryChip 并填入横向 StackView
    private func buildCategoryChips_Base_one() {
        categoryChips_Base_one.removeAll()
        // 左侧首项内边距
        let leading_Base_one = UIView()
        categoryHStack_Base_one.addArrangedSubview(leading_Base_one)
        leading_Base_one.snp.makeConstraints { $0.width.equalTo(4) }

        let allCategories_Base_one = TitleViewModel_Base_one.shared_Base_one.getCategories_Base_one()
        allCategories_Base_one.filter { $0.id_Base_one != "all" }.forEach { category_Base_one in
            let chip_Base_one = CategoryChip_Base_one()
            chip_Base_one.configure_Base_one(category: category_Base_one)
            chip_Base_one.onTap_Base_one = { [weak self] categoryId_Base_one in
                self?.updateCategorySelection_Base_one(categoryId: categoryId_Base_one)
            }
            categoryHStack_Base_one.addArrangedSubview(chip_Base_one)
            chip_Base_one.snp.makeConstraints { $0.height.equalTo(36) }
            categoryChips_Base_one.append(chip_Base_one)
        }

        // 右侧末项内边距
        let trailing_Base_one = UIView()
        categoryHStack_Base_one.addArrangedSubview(trailing_Base_one)
        trailing_Base_one.snp.makeConstraints { $0.width.equalTo(4) }
    }

    // MARK: - 分类选中更新

    /// 更新所有 Chip 的选中态，并记录当前选中分类ID
    /// - Parameter categoryId: 被选中的分类 ID
    private func updateCategorySelection_Base_one(categoryId: String) {
        selectedCategoryId_Base_one = categoryId
        categoryChips_Base_one.forEach { chip_Base_one in
            chip_Base_one.setSelected_Base_one(chip_Base_one.categoryId_Base_one == categoryId)
        }
    }

    // MARK: - 约束布局

    /// 设置SnapKit约束
    private func setupConstraints_Base_one() {
        let safeTop = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        scrollView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentContainer_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Base_one)
        }

        /// 头部卡片
        headerCard_Base_one.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(safeTop + 110)
        }

        /// 装饰气泡1（右上角超出边界，制造层次感）
        headerDecoBubble1_Base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(-28)
            make.width.height.equalTo(150)
        }

        /// 装饰气泡2（左下角）
        headerDecoBubble2_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-24)
            make.bottom.equalToSuperview().offset(28)
            make.width.height.equalTo(110)
        }

        /// 图标圆圈（左侧居中对齐文字）
        headerIconCircle_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.bottom.equalToSuperview().offset(-18)
            make.width.height.equalTo(60)
        }

        headerIconView_Base_one.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        /// 主标题（图标右侧）
        headerTitleLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(headerIconCircle_Base_one.snp.trailing).offset(14)
            make.bottom.equalTo(headerSubtitleLabel_Base_one.snp.top).offset(-5)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        /// 副标题（与主标题左对齐）
        headerSubtitleLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(headerIconCircle_Base_one.snp.trailing).offset(14)
            make.bottom.equalTo(headerIconCircle_Base_one.snp.bottom)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }

        /// 标题卡片
        titleCard_Base_one.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Base_one.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        titleAccentBar_Base_one.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(14)
            make.width.equalTo(4)
        }

        titleSectionLabel_Base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalTo(titleAccentBar_Base_one.snp.trailing).offset(12)
        }

        titleTextField_Base_one.snp.makeConstraints { make in
            make.top.equalTo(titleSectionLabel_Base_one.snp.bottom).offset(7)
            make.leading.equalTo(titleAccentBar_Base_one.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(36)
        }

        /// 内容卡片
        contentCard_Base_one.snp.makeConstraints { make in
            make.top.equalTo(titleCard_Base_one.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        contentSectionLabel_Base_one.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }

        contentTextView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(contentSectionLabel_Base_one.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-14)
            make.height.greaterThanOrEqualTo(96)
        }

        /// 媒体卡片
        mediaCard_Base_one.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Base_one.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        mediaSectionLabel_Base_one.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }

        mediaTapArea_Base_one.snp.makeConstraints { make in
            make.top.equalTo(mediaSectionLabel_Base_one.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.height.equalTo(190)
        }

        mediaEmptyView_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mediaPreview_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mediaAddIcon_Base_one.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-18)
            make.width.height.equalTo(46)
        }

        mediaHintLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(mediaAddIcon_Base_one.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        mediaSubhintLabel_Base_one.snp.makeConstraints { make in
            make.top.equalTo(mediaHintLabel_Base_one.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }

        videoBadgeView_Base_one.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview().inset(10)
            make.height.equalTo(26)
            make.width.equalTo(82)
        }

        videoBadgeIcon_Base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        videoBadgeLabel_Base_one.snp.makeConstraints { make in
            make.leading.equalTo(videoBadgeIcon_Base_one.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
        }

        changeMediaBtn_Base_one.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(10)
            make.width.height.equalTo(34)
        }

        /// 分类卡片（在 mediaCard 下方 14pt）
        categoryCard_Base_one.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Base_one.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        categorySectionLabel_Base_one.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }

        categoryScrollView_Base_one.snp.makeConstraints { make in
            make.top.equalTo(categorySectionLabel_Base_one.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(36)
        }

        categoryHStack_Base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }

        /// 发布按钮（在 categoryCard 下方 20pt）
        publishBtn_Base_one.snp.makeConstraints { make in
            make.top.equalTo(categoryCard_Base_one.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(56)
        }

        /// EULA标签（距发布按钮底部 10pt）
        eulaLabel_Base_one?.snp.makeConstraints { make in
            make.top.equalTo(publishBtn_Base_one.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-120)
        }
    }

    // MARK: - 手势设置

    /// 绑定媒体选择和发布手势
    private func setupGestures_Base_one() {
        /// 媒体区域点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectMediaTapped_Base_one))
        mediaTapArea_Base_one.addGestureRecognizer(tap)

        /// 更换媒体按钮
        changeMediaBtn_Base_one.addTarget(self, action: #selector(selectMediaTapped_Base_one), for: .touchUpInside)

        /// 点击空白收起键盘
        let bgTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Base_one))
        bgTap.cancelsTouchesInView = false
        view.addGestureRecognizer(bgTap)
    }

    // MARK: - 键盘处理

    /// 注册键盘通知
    private func setupKeyboard_Base_one() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow_Base_one(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide_Base_one(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    @objc private func keyboardWillShow_Base_one(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView_Base_one.contentInset.bottom = frame.height + 20
        scrollView_Base_one.scrollIndicatorInsets.bottom = frame.height
    }

    @objc private func keyboardWillHide_Base_one(_ notification: Notification) {
        scrollView_Base_one.contentInset.bottom = 0
        scrollView_Base_one.scrollIndicatorInsets.bottom = 0
    }

    @objc private func dismissKeyboard_Base_one() {
        view.endEditing(true)
    }

    // MARK: - 图层帧更新

    /// 布局完成后更新渐变和虚线边框的frame
    private func updateLayerFrames_Base_one() {
        /// 头部渐变
        if headerGradient_Base_one == nil && headerCard_Base_one.bounds.width > 0 {
            let grad = UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: headerCard_Base_one.bounds)
            grad.cornerRadius = 36
            grad.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            headerCard_Base_one.layer.insertSublayer(grad, at: 0)
            headerGradient_Base_one = grad
        } else {
            headerGradient_Base_one?.frame = headerCard_Base_one.bounds
        }

        /// 标题装饰条渐变
        if accentBarGradient_Base_one == nil && titleAccentBar_Base_one.bounds.height > 0 {
            let grad = UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: titleAccentBar_Base_one.bounds)
            titleAccentBar_Base_one.layer.insertSublayer(grad, at: 0)
            accentBarGradient_Base_one = grad
        } else {
            accentBarGradient_Base_one?.frame = titleAccentBar_Base_one.bounds
        }

        /// 发布按钮渐变
        if publishGradient_Base_one == nil && publishBtn_Base_one.bounds.width > 0 {
            let grad = UIColor.createPrimaryGradientLayer_Base_one(frame_Base_one: publishBtn_Base_one.bounds)
            publishBtn_Base_one.layer.insertSublayer(grad, at: 0)
            publishGradient_Base_one = grad
        } else {
            publishGradient_Base_one?.frame = publishBtn_Base_one.bounds
        }

        /// 更新虚线边框路径
        if mediaTapArea_Base_one.bounds.width > 0 {
            let path = UIBezierPath(roundedRect: mediaTapArea_Base_one.bounds, cornerRadius: 14)
            mediaDashBorder_Base_one.path = path.cgPath
            mediaDashBorder_Base_one.frame = mediaTapArea_Base_one.bounds
        }
    }

    // MARK: - 事件处理

    /// 点击媒体区域，弹出相册选择器
    @objc private func selectMediaTapped_Base_one() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        mediaTapArea_Base_one.animatePressDown_Base_one {
            self.mediaTapArea_Base_one.animatePressUp_Base_one()
        }

        /// 调用媒体选择工具（图片或视频均可选）
        MediaPickerHelper_Base_one.pickMedia_Base_one(from: self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .photo_Base_one(let image):
                self.selectedImage_Base_one = image
                self.selectedVideoURL_Base_one = nil
                self.selectedMediaPath_Base_one = self.saveImageToDocuments_Base_one(image: image)
                self.refreshMediaPreview_Base_one(previewImage: image, isVideo: false)

            case .video_Base_one(let url):
                self.selectedVideoURL_Base_one = url
                self.selectedImage_Base_one = nil
                self.selectedMediaPath_Base_one = url.path
                let thumbnail = self.generateVideoThumbnail_Base_one(url: url)
                self.refreshMediaPreview_Base_one(previewImage: thumbnail, isVideo: true)

            case .cancelled_Base_one:
                break
            }
        }
    }

    /// 点击 EULA 标签，展示 EULA 协议详情（与设置页调用方式一致）
    @objc private func eulaTapped_Base_one() {
        ProtocolHelper_Base_one.showProtocol_Base_one(
            type_Base_one: .eula_Base_one,
            content_Base_one: "eula.png",
            from: self
        )
    }

    /// 点击发布按钮
    @objc private func publishTapped_Base_one() {
        publishBtn_Base_one.animatePressDown_Base_one {
            self.publishBtn_Base_one.animatePressUp_Base_one()
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        /// 第一步：检查是否登录，未登录跳转登录页
        guard UserViewModel_Base_one.shared_Base_one.isLoggedIn_Base_one else {
            Navigation_Base_one.toLogin_Base_one(style_base_one: .present_base_one)
            return
        }

        /// 获取并修剪输入内容
        let title = titleTextField_Base_one.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let isPlaceholder = contentTextView_Base_one.textColor == ColorConfig_Base_one.textPlaceholder_Base_one
        let content = isPlaceholder ? "" : (contentTextView_Base_one.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")

        /// 第二步：校验标题不为空
        guard !title.isEmpty else {
            Utils_Base_one.showWarning_Base_one(message_Base_one: "Please enter a title.")
            titleTextField_Base_one.animateShake_Base_one()
            return
        }

        /// 第三步：校验内容不为空
        guard !content.isEmpty else {
            Utils_Base_one.showWarning_Base_one(message_Base_one: "Please enter some content.")
            contentTextView_Base_one.animateShake_Base_one()
            return
        }

        /// 第四步：校验媒体已选择
        guard let mediaPath = selectedMediaPath_Base_one, !mediaPath.isEmpty else {
            Utils_Base_one.showWarning_Base_one(message_Base_one: "Please add a photo or video.")
            mediaCard_Base_one.animateShake_Base_one()
            return
        }

        /// 第五步：校验已选择分类
        guard let categoryId = selectedCategoryId_Base_one else {
            Utils_Base_one.showWarning_Base_one(message_Base_one: "Please select a category.")
            categoryCard_Base_one.animateShake_Base_one()
            return
        }

        /// 调用ViewModel发布帖子（携带分类ID）
        Task { @MainActor in
            TitleViewModel_Base_one.shared_Base_one.releasePost_Base_one(
                title_base_one: title,
                content_base_one: content,
                media_base_one: mediaPath,
                category_base_one: categoryId
            )
            /// 发布完成后清空表单数据
            self.clearForm_Base_one()
        }
    }

    // MARK: - 表单更新

    /// 刷新媒体预览区域
    /// - Parameters:
    ///   - previewImage: 预览图（视频为缩略图）
    ///   - isVideo: 是否为视频
    private func refreshMediaPreview_Base_one(previewImage: UIImage?, isVideo: Bool) {
        DispatchQueue.main.async {
            if let img = previewImage {
                self.mediaPreview_Base_one.image = img
                self.mediaPreview_Base_one.isHidden = false
                self.mediaEmptyView_Base_one.isHidden = true
                self.videoBadgeView_Base_one.isHidden = !isVideo
                self.changeMediaBtn_Base_one.isHidden = false
                self.mediaPreview_Base_one.animateSpringScaleIn_Base_one()
                /// 有媒体时隐藏虚线边框
                self.mediaDashBorder_Base_one.strokeColor = UIColor.clear.cgColor
            } else {
                self.mediaPreview_Base_one.isHidden = true
                self.mediaEmptyView_Base_one.isHidden = false
                self.videoBadgeView_Base_one.isHidden = true
                self.changeMediaBtn_Base_one.isHidden = true
                self.mediaDashBorder_Base_one.strokeColor = ColorConfig_Base_one.primaryGradientStart_Base_one.withAlphaComponent(0.4).cgColor
            }
        }
    }

    /// 清空表单所有输入、媒体及分类数据
    private func clearForm_Base_one() {
        titleTextField_Base_one.text = ""
        contentTextView_Base_one.text = contentPlaceholder_Base_one
        contentTextView_Base_one.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        selectedImage_Base_one = nil
        selectedVideoURL_Base_one = nil
        selectedMediaPath_Base_one = nil
        // 重置分类选中状态
        selectedCategoryId_Base_one = nil
        categoryChips_Base_one.forEach { $0.setSelected_Base_one(false) }
        refreshMediaPreview_Base_one(previewImage: nil, isVideo: false)
    }

    // MARK: - 私有工具方法

    /// 将图片保存到文档目录，返回文件路径
    /// - Parameter image: 要保存的UIImage
    /// - Returns: 文件路径字符串，失败返回nil
    private func saveImageToDocuments_Base_one(image: UIImage) -> String? {
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
    private func generateVideoThumbnail_Base_one(url: URL) -> UIImage? {
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

extension Release_Base_one: UITextViewDelegate {

    /// 开始编辑时清除占位文本
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == ColorConfig_Base_one.textPlaceholder_Base_one {
            textView.text = ""
            textView.textColor = ColorConfig_Base_one.textPrimary_Base_one
        }
    }

    /// 结束编辑时恢复占位文本
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = contentPlaceholder_Base_one
            textView.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        }
    }
}

// MARK: - UITextFieldDelegate

extension Release_Base_one: UITextFieldDelegate {

    /// 标题输入框回车跳转到内容文本框
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Base_one.becomeFirstResponder()
        return true
    }
}

// MARK: - CategoryChip_Base_one

/// 分类选择 Chip 视图
/// 核心作用：展示单个家居分类标签（图标 + 名称），支持选中/未选中态切换与点击回调
/// 设计思路：圆角胶囊形卡片，未选中浅灰底+次要文字色，选中分类主题色底+白色文字
/// 关键方法：
/// - configure_Base_one: 注入分类数据（图标、名称、颜色）
/// - setSelected_Base_one: 切换选中态
private class CategoryChip_Base_one: UIView {

    // MARK: - 属性

    /// 当前分类ID（外部只读）
    private(set) var categoryId_Base_one: String = ""

    /// 点击回调，回传分类 ID
    var onTap_Base_one: ((String) -> Void)?

    /// 分类主题色（选中时用作背景）
    private var themeColor_Base_one: UIColor = ColorConfig_Base_one.primaryGradientStart_Base_one

    // MARK: - UI

    /// 分类图标
    private let iconView_Base_one: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Base_one.textSecondary_Base_one
        return iv
    }()

    /// 分类名称
    private let nameLabel_Base_one: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = ColorConfig_Base_one.textSecondary_Base_one
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Base_one()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Base_one() {
        backgroundColor    = UIColor(white: 0.95, alpha: 1)
        layer.cornerRadius = 18

        let stack_Base_one = UIStackView(arrangedSubviews: [iconView_Base_one, nameLabel_Base_one])
        stack_Base_one.axis      = .horizontal
        stack_Base_one.spacing   = 5
        stack_Base_one.alignment = .center
        addSubview(stack_Base_one)

        iconView_Base_one.snp.makeConstraints { $0.width.height.equalTo(14) }
        stack_Base_one.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.bottom.equalToSuperview().inset(8)
        }

        let tap_Base_one = UITapGestureRecognizer(target: self, action: #selector(handleTap_Base_one))
        addGestureRecognizer(tap_Base_one)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入分类数据
    /// - Parameter category: HomeCategory_Base_one 分类模型
    func configure_Base_one(category: HomeCategory_Base_one) {
        categoryId_Base_one        = category.id_Base_one
        nameLabel_Base_one.text    = category.name_Base_one
        iconView_Base_one.image    = UIImage(systemName: category.iconName_Base_one)?
            .withRenderingMode(.alwaysTemplate)
        themeColor_Base_one        = UIColor(hexstring_Base_one: category.colorHex_Base_one)
    }

    // MARK: - 选中态切换

    /// 切换选中状态
    /// - Parameter selected: true 为选中（分类主题色背景 + 白色内容），false 为未选中（浅灰背景 + 次要色内容）
    func setSelected_Base_one(_ selected: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.backgroundColor        = selected ? self.themeColor_Base_one : UIColor(white: 0.95, alpha: 1)
            self.iconView_Base_one.tintColor = selected ? .white : ColorConfig_Base_one.textSecondary_Base_one
            self.nameLabel_Base_one.textColor = selected ? .white : ColorConfig_Base_one.textSecondary_Base_one
        }
    }

    // MARK: - 点击处理

    @objc private func handleTap_Base_one() {
        onTap_Base_one?(categoryId_Base_one)
    }
}
