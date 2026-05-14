
import Foundation
import UIKit
import SnapKit

// MARK: 发布页面

/// 发布页面
/// 核心作用：承载帖子标题、内容与媒体选择并完成发布
/// 设计思路：艺术化引导卡 + 三步走分组编号 + 动态进度反馈，让发布有强烈仪式感
class Release_Epoch: UIViewController {

    // MARK: - 背景 & 滚动

    /// 背景装饰
    private let backgroundDecorationView_Epoch = PageDecorationView_Epoch()

    /// 滚动视图
    private let scrollView_Epoch: UIScrollView = {
        let v = UIScrollView()
        v.showsVerticalScrollIndicator = false
        v.alwaysBounceVertical = true
        return v
    }()

    /// 内容容器
    private let contentView_Epoch = UIView()

    // MARK: - 顶部引导卡

    /// 顶部引导卡片
    private let heroCardView_Epoch = SurfaceCardView_Epoch()

    /// 右上装饰光斑（暖粉）
    private let heroGlowTopView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.secondaryGradientStart_Epoch.withAlphaComponent(0.22)
        v.layer.cornerRadius = 60
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 左下装饰光斑（冷紫）
    private let heroGlowBottomView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.18)
        v.layer.cornerRadius = 52
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 顶部图标背景
    private let heroIconBgView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch.withAlphaComponent(0.14)
        v.layer.cornerRadius = 22
        return v
    }()

    /// 顶部图标
    private let heroIconImageView_Epoch: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "pencil.and.sparkles"))
        iv.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 顶部角标
    private let heroBadgeLabel_Epoch: PaddingLabel_Epoch = {
        let l = PaddingLabel_Epoch()
        l.text = "CREATE POST"
        l.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        l.textColor = ColorConfig_Epoch.textOnDark_Epoch
        l.backgroundColor = ColorConfig_Epoch.accentPurple_Epoch
        l.layer.cornerRadius = 12
        l.clipsToBounds = true
        l.horizontalInset_Epoch = 10
        l.verticalInset_Epoch = 6
        return l
    }()

    /// 顶部主标题
    private let heroTitleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text = "Create your ritual post"
        l.font = UIFont.systemFont(ofSize: 27, weight: .bold)
        l.textColor = ColorConfig_Epoch.textPrimary_Epoch
        l.numberOfLines = 0
        return l
    }()

    /// 顶部副标题
    private let heroSubtitleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text = "Shape a polished post with a clear title, a warm story and one visual attachment."
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = ColorConfig_Epoch.textSecondary_Epoch
        l.numberOfLines = 0
        return l
    }()

    /// 顶部步骤标签容器
    private let heroTagStackView_Epoch: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 10
        s.distribution = .fillEqually
        return s
    }()

    /// 顶部步骤标签一
    private let storyTagView_Epoch = ReleaseFeatureTagView_Epoch()
    /// 顶部步骤标签二
    private let mediaTagView_Epoch = ReleaseFeatureTagView_Epoch()
    /// 顶部步骤标签三
    private let publishTagView_Epoch = ReleaseFeatureTagView_Epoch()

    // MARK: - 标题分组

    /// 标题分组头部
    private let titleSectionHeaderView_Epoch = ReleaseSectionHeaderView_Epoch()

    /// 标题卡片
    private let titleCardView_Epoch = SurfaceCardView_Epoch()

    /// 标题输入框
    private let titleTextField_Epoch = Release_Epoch.makeTextField_Epoch(placeholder_Epoch: "Post title")

    /// 标题底部分隔线
    private let titleDividerView_Epoch: UIView = {
        let v = UIView()
        return v
    }()

    /// 标题字数统计
    private let titleCharCountLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text = "0 / 80"
        l.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        l.textAlignment = .right
        return l
    }()

    // MARK: - 内容分组

    /// 内容分组头部
    private let contentSectionHeaderView_Epoch = ReleaseSectionHeaderView_Epoch()

    /// 内容卡片
    private let contentCardView_Epoch = SurfaceCardView_Epoch()

    /// 内容输入框
    private let contentTextView_Epoch: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tv.textColor = ColorConfig_Epoch.textPrimary_Epoch
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 40, right: 12)
        return tv
    }()

    /// 内容占位标签
    private let contentPlaceholderLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text = "Post content"
        l.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        l.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        return l
    }()

    /// 内容字数统计（固定在卡片右下角）
    private let contentCharCountLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text = "0 / 500"
        l.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        l.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        l.textAlignment = .right
        return l
    }()

    // MARK: - 媒体分组

    /// 媒体分组头部
    private let mediaSectionHeaderView_Epoch = ReleaseSectionHeaderView_Epoch()

    /// 媒体预览卡片
    private let previewCardView_Epoch = SurfaceCardView_Epoch()

    /// 媒体预览
    private let mediaPreview_Epoch = MediaDisplayView_Epoch()

    /// 媒体空状态视图（无媒体时展示）
    private let mediaEmptyStateView_Epoch = ReleaseMediaEmptyView_Epoch()

    /// 媒体状态角标
    private let mediaStatusBadgeLabel_Epoch: PaddingLabel_Epoch = {
        let l = PaddingLabel_Epoch()
        l.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        l.textColor = ColorConfig_Epoch.accentPurple_Epoch
        l.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.14)
        l.layer.cornerRadius = 12
        l.clipsToBounds = true
        l.horizontalInset_Epoch = 10
        l.verticalInset_Epoch = 6
        return l
    }()

    /// 媒体快捷操作容器
    private let mediaActionStackView_Epoch: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 14
        s.distribution = .fillEqually
        return s
    }()

    /// 图片选择按钮
    private let imageButton_Epoch = ReleaseSecondaryActionButton_Epoch(
        title_Epoch: "Pick Image",
        symbolName_Epoch: "photo.on.rectangle.angled",
        style_Epoch: .filled
    )

    /// 视频选择按钮
    private let videoButton_Epoch = ReleaseSecondaryActionButton_Epoch(
        title_Epoch: "Pick Video",
        symbolName_Epoch: "play.rectangle.fill",
        style_Epoch: .outline
    )

    // MARK: - 进度摘要卡片

    /// 状态摘要卡片
    private let summaryCardView_Epoch = SurfaceCardView_Epoch()

    /// 进度条容器（三段式）
    private let progressBarStack_Epoch: UIStackView = {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 6
        s.distribution = .fillEqually
        return s
    }()

    /// 进度段 - 标题
    private let progressSegTitle_Epoch = ReleaseProgressSegView_Epoch()
    /// 进度段 - 内容
    private let progressSegContent_Epoch = ReleaseProgressSegView_Epoch()
    /// 进度段 - 媒体
    private let progressSegMedia_Epoch = ReleaseProgressSegView_Epoch()

    /// 摘要图标背景
    private let summaryIconBackgroundView_Epoch = UIView()

    /// 摘要图标
    private let summaryIconImageView_Epoch: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "wand.and.stars"))
        iv.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 摘要标题
    private let summaryTitleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text = "Complete the post"
        l.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        l.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return l
    }()

    /// 摘要说明
    private let summarySubtitleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = ColorConfig_Epoch.textSecondary_Epoch
        l.numberOfLines = 0
        return l
    }()

    // MARK: - 发布区

    /// 发布区容器卡片（包裹按钮与 EULA）
    private let publishWrapCardView_Epoch = SurfaceCardView_Epoch()

    /// 确认发布按钮
    private let publishButton_Epoch = PrimaryActionButton_Epoch(title_Epoch: "Publish")

    /// EULA 按钮
    private let eulaButton_Epoch: UIButton = {
        let btn = UIButton(type: .system)
        let title = NSAttributedString(string: "EULA", attributes: [
            .foregroundColor: ColorConfig_Epoch.primaryGradientStart_Epoch,
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        btn.setAttributedTitle(title, for: .normal)
        return btn
    }()

    // MARK: - 数据状态

    /// 当前图片
    private var selectedImage_Epoch: UIImage?

    /// 当前视频路径
    private var selectedVideoURL_Epoch: URL?

    // MARK: - 生命周期

    /// 页面即将出现时隐藏导航栏
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    /// 页面加载完成后初始化界面
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Epoch()
        setupActions_Epoch()
        refreshFormState_Epoch()
    }

    // MARK: - 界面搭建

    /// 构建整体界面
    private func setupUI_Epoch() {
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        view.addSubview(backgroundDecorationView_Epoch)
        view.addSubview(scrollView_Epoch)
        scrollView_Epoch.addSubview(contentView_Epoch)

        backgroundDecorationView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView_Epoch.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Epoch.contentLayoutGuide)
            make.width.equalTo(scrollView_Epoch.frameLayoutGuide)
        }

        setupHeroCard_Epoch()
        setupTitleSection_Epoch()
        setupContentSection_Epoch()
        setupMediaSection_Epoch()
        setupSummaryCard_Epoch()
        setupPublishArea_Epoch()

        contentTextView_Epoch.delegate = self
        titleTextField_Epoch.addTarget(self, action: #selector(textChanged_Epoch), for: .editingChanged)
    }

    /// 搭建顶部引导卡
    private func setupHeroCard_Epoch() {
        contentView_Epoch.addSubview(heroCardView_Epoch)

        // 卡片裁剪以配合光斑效果
        heroCardView_Epoch.clipsToBounds = true
        heroCardView_Epoch.addSubview(heroGlowTopView_Epoch)
        heroCardView_Epoch.addSubview(heroGlowBottomView_Epoch)
        heroCardView_Epoch.addSubview(heroIconBgView_Epoch)
        heroIconBgView_Epoch.addSubview(heroIconImageView_Epoch)

        storyTagView_Epoch.configure_Epoch(symbolName_Epoch: "text.alignleft", title_Epoch: "Story")
        mediaTagView_Epoch.configure_Epoch(symbolName_Epoch: "sparkles.tv", title_Epoch: "Visual")
        publishTagView_Epoch.configure_Epoch(symbolName_Epoch: "paperplane.fill", title_Epoch: "Publish")
        heroTagStackView_Epoch.addArrangedSubview(storyTagView_Epoch)
        heroTagStackView_Epoch.addArrangedSubview(mediaTagView_Epoch)
        heroTagStackView_Epoch.addArrangedSubview(publishTagView_Epoch)

        let heroStack_epoch = UIStackView(arrangedSubviews: [
            heroBadgeLabel_Epoch,
            heroTitleLabel_Epoch,
            heroSubtitleLabel_Epoch,
            heroTagStackView_Epoch
        ])
        heroStack_epoch.axis = .vertical
        heroStack_epoch.spacing = 12
        heroStack_epoch.alignment = .leading
        heroCardView_Epoch.addSubview(heroStack_epoch)

        heroCardView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.right.equalToSuperview().inset(20)
        }

        heroGlowTopView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-28)
            make.right.equalToSuperview().offset(28)
            make.width.height.equalTo(120)
        }

        heroGlowBottomView_Epoch.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(28)
            make.left.equalToSuperview().offset(-28)
            make.width.height.equalTo(104)
        }

        heroIconBgView_Epoch.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(20)
            make.width.height.equalTo(44)
        }

        heroIconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        heroStack_epoch.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(22)
            make.right.lessThanOrEqualTo(heroIconBgView_Epoch.snp.left).offset(-10)
            make.bottom.equalToSuperview().offset(-22)
        }
    }

    /// 搭建标题分组
    private func setupTitleSection_Epoch() {
        contentView_Epoch.addSubview(titleSectionHeaderView_Epoch)
        contentView_Epoch.addSubview(titleCardView_Epoch)

        titleSectionHeaderView_Epoch.configure_Epoch(
            step_Epoch: 1,
            iconName_Epoch: "textformat.size",
            title_Epoch: "Title",
            subtitle_Epoch: "Name the feeling or moment you want people to notice first."
        )

        titleCardView_Epoch.addSubview(titleTextField_Epoch)
        titleCardView_Epoch.addSubview(titleDividerView_Epoch)
        titleCardView_Epoch.addSubview(titleCharCountLabel_Epoch)

        // 分隔线渐变
        let divGrad_epoch = UIColor.createPrimaryGradientLayer_Epoch(frame_Epoch: .zero)
        titleDividerView_Epoch.layer.addSublayer(divGrad_epoch)

        titleSectionHeaderView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(heroCardView_Epoch.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
        }

        titleCardView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleSectionHeaderView_Epoch.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(78)
        }

        titleTextField_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(UIEdgeInsets(top: 18, left: 16, bottom: 0, right: 16))
        }

        titleDividerView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleTextField_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(2)
        }

        titleCharCountLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleDividerView_Epoch.snp.bottom).offset(4)
            make.right.equalToSuperview().offset(-16)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }

        // 同步分隔线渐变尺寸在下次 layout 后
        titleCardView_Epoch.layoutIfNeeded()
    }

    /// 搭建内容分组
    private func setupContentSection_Epoch() {
        contentView_Epoch.addSubview(contentSectionHeaderView_Epoch)
        contentView_Epoch.addSubview(contentCardView_Epoch)

        contentSectionHeaderView_Epoch.configure_Epoch(
            step_Epoch: 2,
            iconName_Epoch: "quote.bubble",
            title_Epoch: "Story",
            subtitle_Epoch: "Describe the atmosphere, details and emotion behind this ritual."
        )

        contentCardView_Epoch.addSubview(contentTextView_Epoch)
        contentCardView_Epoch.addSubview(contentPlaceholderLabel_Epoch)
        contentCardView_Epoch.addSubview(contentCharCountLabel_Epoch)

        contentSectionHeaderView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleCardView_Epoch.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(20)
        }

        contentCardView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(contentSectionHeaderView_Epoch.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }

        contentTextView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        contentPlaceholderLabel_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(18)
        }

        contentCharCountLabel_Epoch.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(12)
        }
    }

    /// 搭建媒体分组
    private func setupMediaSection_Epoch() {
        contentView_Epoch.addSubview(mediaSectionHeaderView_Epoch)
        contentView_Epoch.addSubview(previewCardView_Epoch)
        contentView_Epoch.addSubview(mediaActionStackView_Epoch)

        mediaSectionHeaderView_Epoch.configure_Epoch(
            step_Epoch: 3,
            iconName_Epoch: "photo.stack",
            title_Epoch: "Visual",
            subtitle_Epoch: "Attach one image or one video to anchor your post with a strong mood."
        )

        previewCardView_Epoch.addSubview(mediaEmptyStateView_Epoch)
        previewCardView_Epoch.addSubview(mediaPreview_Epoch)
        previewCardView_Epoch.addSubview(mediaStatusBadgeLabel_Epoch)

        mediaActionStackView_Epoch.addArrangedSubview(imageButton_Epoch)
        mediaActionStackView_Epoch.addArrangedSubview(videoButton_Epoch)

        mediaSectionHeaderView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(contentCardView_Epoch.snp.bottom).offset(22)
            make.left.right.equalToSuperview().inset(20)
        }

        previewCardView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(mediaSectionHeaderView_Epoch.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(220)
        }

        mediaEmptyStateView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mediaPreview_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        mediaStatusBadgeLabel_Epoch.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(14)
        }

        mediaActionStackView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(previewCardView_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }
    }

    /// 搭建摘要卡片
    private func setupSummaryCard_Epoch() {
        contentView_Epoch.addSubview(summaryCardView_Epoch)

        // 进度条三段
        progressSegTitle_Epoch.configure_Epoch(label_Epoch: "Title")
        progressSegContent_Epoch.configure_Epoch(label_Epoch: "Story")
        progressSegMedia_Epoch.configure_Epoch(label_Epoch: "Visual")
        progressBarStack_Epoch.addArrangedSubview(progressSegTitle_Epoch)
        progressBarStack_Epoch.addArrangedSubview(progressSegContent_Epoch)
        progressBarStack_Epoch.addArrangedSubview(progressSegMedia_Epoch)
        summaryCardView_Epoch.addSubview(progressBarStack_Epoch)

        summaryIconBackgroundView_Epoch.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.14)
        summaryIconBackgroundView_Epoch.layer.cornerRadius = 22
        summaryCardView_Epoch.addSubview(summaryIconBackgroundView_Epoch)
        summaryIconBackgroundView_Epoch.addSubview(summaryIconImageView_Epoch)
        summaryCardView_Epoch.addSubview(summaryTitleLabel_Epoch)
        summaryCardView_Epoch.addSubview(summarySubtitleLabel_Epoch)

        progressBarStack_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(18)
            make.height.equalTo(32)
        }

        summaryIconBackgroundView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(progressBarStack_Epoch.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(18)
            make.width.height.equalTo(44)
        }

        summaryIconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(20)
        }

        summaryTitleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(summaryIconBackgroundView_Epoch)
            make.left.equalTo(summaryIconBackgroundView_Epoch.snp.right).offset(14)
            make.right.equalToSuperview().offset(-18)
        }

        summarySubtitleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(summaryTitleLabel_Epoch.snp.bottom).offset(6)
            make.left.equalTo(summaryTitleLabel_Epoch)
            make.right.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(-18)
        }

        summaryCardView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(mediaActionStackView_Epoch.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(20)
        }
    }

    /// 搭建发布按钮区域
    private func setupPublishArea_Epoch() {
        contentView_Epoch.addSubview(publishWrapCardView_Epoch)
        publishWrapCardView_Epoch.addSubview(publishButton_Epoch)
        publishWrapCardView_Epoch.addSubview(eulaButton_Epoch)

        publishWrapCardView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(summaryCardView_Epoch.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-100)
        }

        publishButton_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(18)
            make.height.equalTo(56)
        }

        eulaButton_Epoch.snp.makeConstraints { make in
            make.top.equalTo(publishButton_Epoch.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-18)
        }
    }

    // MARK: - 事件绑定

    /// 绑定按钮事件
    private func setupActions_Epoch() {
        imageButton_Epoch.addTarget(self, action: #selector(imageTapped_Epoch), for: .touchUpInside)
        videoButton_Epoch.addTarget(self, action: #selector(videoTapped_Epoch), for: .touchUpInside)
        publishButton_Epoch.addTarget(self, action: #selector(publishTapped_Epoch), for: .touchUpInside)
        eulaButton_Epoch.addTarget(self, action: #selector(eulaTapped_Epoch), for: .touchUpInside)
    }

    // MARK: - 工具方法

    /// 创建文本输入框
    /// - Parameter placeholder_Epoch: 占位文案
    /// - Returns: 配置好的 UITextField
    private static func makeTextField_Epoch(placeholder_Epoch: String) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder_Epoch
        tf.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        tf.textColor = ColorConfig_Epoch.textPrimary_Epoch
        tf.backgroundColor = .clear
        tf.clearButtonMode = .whileEditing
        return tf
    }

    // MARK: - 状态刷新

    /// 刷新发布按钮可用状态
    private func updatePublishButtonState_Epoch() {
        let titleReady_epoch = !(titleTextField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let contentReady_epoch = !contentTextView_Epoch.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let mediaReady_epoch = selectedImage_Epoch != nil || selectedVideoURL_Epoch != nil
        publishButton_Epoch.isEnabled = titleReady_epoch && contentReady_epoch && mediaReady_epoch
    }

    /// 统一刷新整个表单状态（按钮、进度、媒体提示、摘要文案）
    private func refreshFormState_Epoch() {
        let titleReady_epoch = !(titleTextField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let contentReady_epoch = !contentTextView_Epoch.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let mediaReady_epoch = selectedImage_Epoch != nil || selectedVideoURL_Epoch != nil

        updatePublishButtonState_Epoch()

        // 进度段刷新
        progressSegTitle_Epoch.setReady_Epoch(titleReady_epoch)
        progressSegContent_Epoch.setReady_Epoch(contentReady_epoch)
        progressSegMedia_Epoch.setReady_Epoch(mediaReady_epoch)

        // 媒体状态刷新
        if selectedImage_Epoch != nil {
            mediaStatusBadgeLabel_Epoch.text = "IMAGE READY"
            mediaEmptyStateView_Epoch.isHidden = true
            mediaPreview_Epoch.isHidden = false
        } else if selectedVideoURL_Epoch != nil {
            mediaStatusBadgeLabel_Epoch.text = "VIDEO READY"
            mediaEmptyStateView_Epoch.isHidden = true
            mediaPreview_Epoch.isHidden = false
        } else {
            mediaStatusBadgeLabel_Epoch.text = "NO MEDIA YET"
            mediaEmptyStateView_Epoch.isHidden = false
            mediaPreview_Epoch.isHidden = true
        }

        // 摘要卡片刷新
        if titleReady_epoch && contentReady_epoch && mediaReady_epoch {
            summaryTitleLabel_Epoch.text = "Ready to publish"
            summarySubtitleLabel_Epoch.text = "Your title, story and visual are all prepared. Publish whenever you feel the mood is right."
            summaryIconImageView_Epoch.image = UIImage(systemName: "checkmark.seal.fill")
            summaryIconImageView_Epoch.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        } else {
            summaryTitleLabel_Epoch.text = "Complete the post"
            summarySubtitleLabel_Epoch.text = composeSummaryText_Epoch(
                titleReady_epoch: titleReady_epoch,
                contentReady_epoch: contentReady_epoch,
                mediaReady_epoch: mediaReady_epoch
            )
            summaryIconImageView_Epoch.image = UIImage(systemName: "wand.and.stars")
            summaryIconImageView_Epoch.tintColor = ColorConfig_Epoch.accentGold_Epoch
        }
    }

    /// 刷新字数统计
    private func refreshCharCount_Epoch() {
        let titleLen_epoch = titleTextField_Epoch.text?.count ?? 0
        let contentLen_epoch = contentTextView_Epoch.text.count
        titleCharCountLabel_Epoch.text = "\(titleLen_epoch) / 80"
        contentCharCountLabel_Epoch.text = "\(contentLen_epoch) / 500"

        // 超出限制时红色警示
        titleCharCountLabel_Epoch.textColor = titleLen_epoch > 80
            ? ColorConfig_Epoch.accentPink_Epoch
            : ColorConfig_Epoch.textPlaceholder_Epoch
        contentCharCountLabel_Epoch.textColor = contentLen_epoch > 500
            ? ColorConfig_Epoch.accentPink_Epoch
            : ColorConfig_Epoch.textPlaceholder_Epoch
    }

    /// 生成摘要说明文案
    /// - Parameters:
    ///   - titleReady_epoch: 标题是否完成
    ///   - contentReady_epoch: 内容是否完成
    ///   - mediaReady_epoch: 媒体是否完成
    /// - Returns: 当前表单状态说明
    private func composeSummaryText_Epoch(
        titleReady_epoch: Bool,
        contentReady_epoch: Bool,
        mediaReady_epoch: Bool
    ) -> String {
        var items: [String] = []
        if !titleReady_epoch { items.append("add a title") }
        if !contentReady_epoch { items.append("write the story") }
        if !mediaReady_epoch { items.append("attach one visual") }
        guard !items.isEmpty else { return "Everything is prepared for publishing." }
        return "Before publishing, \(items.joined(separator: ", ")) to complete the post."
    }

    // MARK: - 媒体选择

    /// 从相册选取图片
    private func pickImage_Epoch() {
        MediaPickerHelper_Epoch.pickImage_Epoch(from: self) { [weak self] image_epoch in
            guard let self = self, let image_epoch = image_epoch else { return }
            self.selectedImage_Epoch = image_epoch
            self.selectedVideoURL_Epoch = nil
            self.mediaPreview_Epoch.configureWithImage_Epoch(image_Epoch: image_epoch)
            self.refreshFormState_Epoch()
        }
    }

    /// 从相册选取视频
    private func pickVideo_Epoch() {
        MediaPickerHelper_Epoch.pickVideo_Epoch(from: self) { [weak self] url_epoch in
            guard let self = self, let url_epoch = url_epoch else { return }
            self.selectedVideoURL_Epoch = url_epoch
            self.selectedImage_Epoch = nil
            self.mediaPreview_Epoch.configure_Epoch(mediaPath_Epoch: url_epoch.path, isVideo_Epoch: true)
            self.refreshFormState_Epoch()
        }
    }

    /// 保存图片到文档目录
    /// - Parameter image_Epoch: 图片对象
    /// - Returns: 本地存储路径（失败返回 nil）
    private func storeImage_Epoch(image_Epoch: UIImage) -> String? {
        let fileName_epoch = "release_\(Int(Date().timeIntervalSince1970)).jpg"
        let fileURL_epoch = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName_epoch)
        guard let data_epoch = image_Epoch.jpegData(compressionQuality: 0.85) else { return nil }
        do {
            try data_epoch.write(to: fileURL_epoch)
            return fileURL_epoch.path
        } catch {
            Utils_Epoch.showError_Epoch(message_Epoch: "Failed to save image.")
            return nil
        }
    }

    /// 重置表单到初始状态
    private func resetForm_Epoch() {
        titleTextField_Epoch.text = nil
        contentTextView_Epoch.text = nil
        contentPlaceholderLabel_Epoch.isHidden = false
        selectedImage_Epoch = nil
        selectedVideoURL_Epoch = nil
        mediaPreview_Epoch.configure_Epoch(mediaPath_Epoch: "photo.on.rectangle.angled")
        refreshCharCount_Epoch()
        refreshFormState_Epoch()
    }

    // MARK: - @objc 动作

    /// 标题文字变化
    @objc private func textChanged_Epoch() {
        refreshCharCount_Epoch()
        refreshFormState_Epoch()
    }

    /// 选择图片
    @objc private func imageTapped_Epoch() {
        pickImage_Epoch()
    }

    /// 选择视频
    @objc private func videoTapped_Epoch() {
        pickVideo_Epoch()
    }

    /// 发布帖子
    @objc private func publishTapped_Epoch() {
        guard UserViewModel_Epoch.shared_Epoch.isLoggedIn_Epoch else {
            Utils_Epoch.showWarning_Epoch(message_Epoch: "Please log in first.")
            Navigation_Epoch.toLogin_Epoch(style_epoch: .present_epoch)
            return
        }

        let title_epoch = titleTextField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let content_epoch = contentTextView_Epoch.text.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !title_epoch.isEmpty else {
            Utils_Epoch.showWarning_Epoch(message_Epoch: "Title cannot be empty.")
            return
        }
        guard !content_epoch.isEmpty else {
            Utils_Epoch.showWarning_Epoch(message_Epoch: "Content cannot be empty.")
            return
        }

        let mediaPath_epoch: String?
        if let image_epoch = selectedImage_Epoch {
            mediaPath_epoch = storeImage_Epoch(image_Epoch: image_epoch)
        } else {
            mediaPath_epoch = selectedVideoURL_Epoch?.path
        }

        guard let mediaPath_epoch = mediaPath_epoch, !mediaPath_epoch.isEmpty else {
            Utils_Epoch.showWarning_Epoch(message_Epoch: "Media cannot be empty.")
            return
        }

        TitleViewModel_Epoch.shared_Epoch.releasePost_Epoch(
            title_epoch: title_epoch,
            content_epoch: content_epoch,
            media_epoch: mediaPath_epoch
        )
        resetForm_Epoch()
    }

    /// 展示 EULA
    @objc private func eulaTapped_Epoch() {
        ProtocolHelper_Epoch.showProtocol_Epoch(
            type_Epoch: .eula_Epoch,
            content_Epoch: "eula.png",
            from: self
        )
    }
}

// MARK: - UITextViewDelegate

extension Release_Epoch: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholderLabel_Epoch.isHidden = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        refreshCharCount_Epoch()
        refreshFormState_Epoch()
    }
}

// MARK: - 发布页分组头部

/// 发布页分组头部
/// 核心作用：展示步骤编号、图标和分组标题，引导用户按步骤填写表单
/// 设计思路：左侧渐变圆圈步骤编号 + 图标背景 + 双层文字，兼顾信息密度与美感
class ReleaseSectionHeaderView_Epoch: UIView {

    /// 步骤编号容器
    private let stepBadgeView_Epoch: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 18
        v.clipsToBounds = true
        return v
    }()

    /// 步骤编号渐变图层
    private var stepGradientLayer_Epoch: CAGradientLayer?

    /// 步骤编号标签
    private let stepLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        l.textColor = ColorConfig_Epoch.textOnDark_Epoch
        l.textAlignment = .center
        return l
    }()

    /// 图标背景
    private let iconBackgroundView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.14)
        v.layer.cornerRadius = 16
        return v
    }()

    /// 图标
    private let iconImageView_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        return iv
    }()

    /// 标题
    private let titleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return l
    }()

    /// 副标题
    private let subtitleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = ColorConfig_Epoch.textSecondary_Epoch
        l.numberOfLines = 0
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 同步渐变圆圈尺寸
        stepGradientLayer_Epoch?.frame = stepBadgeView_Epoch.bounds
    }

    /// 配置分组头部
    /// - Parameters:
    ///   - step_Epoch: 步骤编号（1, 2, 3）
    ///   - iconName_Epoch: 图标名称
    ///   - title_Epoch: 标题文案
    ///   - subtitle_Epoch: 副标题文案
    func configure_Epoch(step_Epoch: Int, iconName_Epoch: String, title_Epoch: String, subtitle_Epoch: String) {
        stepLabel_Epoch.text = String(format: "%02d", step_Epoch)
        iconImageView_Epoch.image = UIImage(systemName: iconName_Epoch)
        titleLabel_Epoch.text = title_Epoch
        subtitleLabel_Epoch.text = subtitle_Epoch
    }

    private func setupUI_Epoch() {
        // 步骤圆圈渐变
        let grad_epoch = UIColor.createPrimaryGradientLayer_Epoch(frame_Epoch: .zero)
        stepBadgeView_Epoch.layer.insertSublayer(grad_epoch, at: 0)
        stepGradientLayer_Epoch = grad_epoch

        addSubview(stepBadgeView_Epoch)
        stepBadgeView_Epoch.addSubview(stepLabel_Epoch)
        addSubview(iconBackgroundView_Epoch)
        iconBackgroundView_Epoch.addSubview(iconImageView_Epoch)

        let textStack_epoch = UIStackView(arrangedSubviews: [titleLabel_Epoch, subtitleLabel_Epoch])
        textStack_epoch.axis = .vertical
        textStack_epoch.spacing = 3
        addSubview(textStack_epoch)

        stepBadgeView_Epoch.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(36)
        }

        stepLabel_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        iconBackgroundView_Epoch.snp.makeConstraints { make in
            make.left.equalTo(stepBadgeView_Epoch.snp.right).offset(8)
            make.centerY.equalTo(stepBadgeView_Epoch)
            make.width.height.equalTo(32)
        }

        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(16)
        }

        textStack_epoch.snp.makeConstraints { make in
            make.left.equalTo(iconBackgroundView_Epoch.snp.right).offset(10)
            make.top.right.bottom.equalToSuperview()
        }
    }
}

// MARK: - 发布页功能标签

/// 发布页功能标签
/// 核心作用：展示发布步骤关键词
/// 设计思路：轻卡片承载图标与短文案，增强头部信息密度
class ReleaseFeatureTagView_Epoch: UIView {

    /// 面板容器
    private let containerView_Epoch = SurfaceCardView_Epoch()

    /// 图标
    private let iconImageView_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        return iv
    }()

    /// 文案
    private let titleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        l.textColor = ColorConfig_Epoch.textPrimary_Epoch
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置标签内容
    /// - Parameters:
    ///   - symbolName_Epoch: SF Symbol 名称
    ///   - title_Epoch: 文案
    func configure_Epoch(symbolName_Epoch: String, title_Epoch: String) {
        iconImageView_Epoch.image = UIImage(systemName: symbolName_Epoch)
        titleLabel_Epoch.text = title_Epoch
    }

    private func setupUI_Epoch() {
        addSubview(containerView_Epoch)
        containerView_Epoch.addSubview(iconImageView_Epoch)
        containerView_Epoch.addSubview(titleLabel_Epoch)

        containerView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(68)
        }

        iconImageView_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(20)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(iconImageView_Epoch.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(6)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }
    }
}

// MARK: - 发布页次级按钮

/// 发布页次级按钮样式枚举
enum ReleaseButtonStyle_Epoch {
    /// 填充样式（主色渐变背景）
    case filled
    /// 描边样式（透明背景 + 边框）
    case outline
}

/// 发布页次级按钮
/// 核心作用：媒体选择等次级操作的统一样式
/// 设计思路：区分 filled（图片）和 outline（视频）两种视觉层级
class ReleaseSecondaryActionButton_Epoch: UIButton {

    /// 渐变图层（仅 filled 样式使用）
    private var gradientLayer_Epoch: CAGradientLayer?

    /// 按钮样式
    private let style_Epoch: ReleaseButtonStyle_Epoch

    /// 初始化
    /// - Parameters:
    ///   - title_Epoch: 按钮文案
    ///   - symbolName_Epoch: SF Symbol 名称
    ///   - style_Epoch: 按钮样式
    init(title_Epoch: String, symbolName_Epoch: String, style_Epoch: ReleaseButtonStyle_Epoch) {
        self.style_Epoch = style_Epoch
        super.init(frame: .zero)
        setTitle(title_Epoch, for: .normal)
        setImage(UIImage(systemName: symbolName_Epoch), for: .normal)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Epoch?.frame = bounds
        layer.cornerRadius = bounds.height / 2
        gradientLayer_Epoch?.cornerRadius = bounds.height / 2
    }

    private func setupUI_Epoch() {
        titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        imageView?.contentMode = .scaleAspectFit
        semanticContentAttribute = .forceLeftToRight
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        layer.cornerRadius = 22

        switch style_Epoch {
        case .filled:
            // 渐变填充背景
            let grad_epoch = UIColor.createPrimaryGradientLayer_Epoch(frame_Epoch: .zero)
            layer.insertSublayer(grad_epoch, at: 0)
            gradientLayer_Epoch = grad_epoch
            setTitleColor(ColorConfig_Epoch.textOnDark_Epoch, for: .normal)
            tintColor = .white
            layer.shadowColor = ColorConfig_Epoch.primaryGradientStart_Epoch.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 4)
            layer.shadowOpacity = 0.28
            layer.shadowRadius = 8
        case .outline:
            // 透明底 + 描边
            backgroundColor = .white.withAlphaComponent(0.72)
            layer.borderWidth = 1.5
            layer.borderColor = ColorConfig_Epoch.accentBorder_Epoch.cgColor
            setTitleColor(ColorConfig_Epoch.textPrimary_Epoch, for: .normal)
            tintColor = ColorConfig_Epoch.accentPurple_Epoch
        }
    }
}

// MARK: - 媒体空状态视图

/// 媒体空状态视图
/// 核心作用：在未选择媒体时展示引导图标和提示文字
/// 设计思路：居中大图标 + 标题 + 副标题，配合卡片背景形成内容引导感
class ReleaseMediaEmptyView_Epoch: UIView {

    /// 图标背景
    private let iconBgView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.primaryGradientStart_Epoch.withAlphaComponent(0.12)
        v.layer.cornerRadius = 32
        return v
    }()

    /// 图标
    private let iconImageView_Epoch: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "photo.badge.plus"))
        iv.tintColor = ColorConfig_Epoch.accentPurple_Epoch
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 主提示
    private let titleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text = "Add a visual mood"
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.textColor = ColorConfig_Epoch.textPrimary_Epoch
        l.textAlignment = .center
        return l
    }()

    /// 副提示
    private let subtitleLabel_Epoch: UILabel = {
        let l = UILabel()
        l.text = "Tap Pick Image or Pick Video below"
        l.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        l.textColor = ColorConfig_Epoch.textSecondary_Epoch
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI_Epoch() {
        addSubview(iconBgView_Epoch)
        iconBgView_Epoch.addSubview(iconImageView_Epoch)

        let textStack_epoch = UIStackView(arrangedSubviews: [titleLabel_Epoch, subtitleLabel_Epoch])
        textStack_epoch.axis = .vertical
        textStack_epoch.spacing = 6
        addSubview(textStack_epoch)

        iconBgView_Epoch.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.height.equalTo(64)
        }

        iconImageView_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        textStack_epoch.snp.makeConstraints { make in
            make.top.equalTo(iconBgView_Epoch.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(20)
        }
    }
}

// MARK: - 进度段视图

/// 进度段视图
/// 核心作用：表示表单中某一项（标题/内容/媒体）的完成状态
/// 设计思路：未完成时为淡灰色圆角胶囊，完成时切换为渐变填充，并附带字段名称标签
class ReleaseProgressSegView_Epoch: UIView {

    /// 渐变填充图层
    private var fillGradientLayer_Epoch: CAGradientLayer?

    /// 底部标签
    private let labelView_Epoch: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        l.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        l.textAlignment = .center
        return l
    }()

    /// 胶囊条
    private let capsuleView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Epoch.divider_Epoch
        v.layer.cornerRadius = 5
        v.clipsToBounds = true
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Epoch()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        fillGradientLayer_Epoch?.frame = capsuleView_Epoch.bounds
    }

    /// 配置字段名称
    /// - Parameter label_Epoch: 字段名称
    func configure_Epoch(label_Epoch: String) {
        labelView_Epoch.text = label_Epoch
    }

    /// 更新完成状态
    /// - Parameter ready_Epoch: 是否已完成
    func setReady_Epoch(_ ready_Epoch: Bool) {
        if ready_Epoch {
            if fillGradientLayer_Epoch == nil {
                let grad_epoch = UIColor.createPrimaryGradientLayer_Epoch(frame_Epoch: capsuleView_Epoch.bounds)
                capsuleView_Epoch.layer.insertSublayer(grad_epoch, at: 0)
                fillGradientLayer_Epoch = grad_epoch
            }
            fillGradientLayer_Epoch?.opacity = 1
            capsuleView_Epoch.backgroundColor = .clear
            labelView_Epoch.textColor = ColorConfig_Epoch.accentPurple_Epoch
        } else {
            fillGradientLayer_Epoch?.opacity = 0
            capsuleView_Epoch.backgroundColor = ColorConfig_Epoch.divider_Epoch
            labelView_Epoch.textColor = ColorConfig_Epoch.textPlaceholder_Epoch
        }
    }

    private func setupUI_Epoch() {
        addSubview(capsuleView_Epoch)
        addSubview(labelView_Epoch)

        capsuleView_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(10)
        }

        labelView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(capsuleView_Epoch.snp.bottom).offset(5)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
