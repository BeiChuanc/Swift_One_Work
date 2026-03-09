import Foundation
import UIKit
import SnapKit
import PhotosUI
import AVFoundation

// MARK: 发布页

/// 情绪便签发布页
/// 功能：输入标题、内容，从相册选取媒体，完成后发布帖子
/// 设计：渐变顶部头部 + 步骤卡片（媒体 + 输入）+ 底部固定发布按钮
/// 逻辑：登录校验 → 字段校验（抖动提示）→ 调用 ViewModel 发布 → 清空页面
class Release_Moode: UIViewController {

    // MARK: - 常量

    private let bottomBtnHeight_Moode: CGFloat = 56

    // MARK: - 渐变头部

    /// 顶部渐变装饰区
    private let headerBg_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.clipsToBounds = true
        v_Moode.layer.cornerRadius = 28
        v_Moode.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        return v_Moode
    }()

    private var headerGradient_Moode: CAGradientLayer?

    private let headerTitleLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Share a Post"
        l_Moode.font = .systemFont(ofSize: 26, weight: .heavy)
        l_Moode.textColor = .white
        return l_Moode
    }()

    private let headerSubLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Capture your moment with a photo or video"
        l_Moode.font = .systemFont(ofSize: 13)
        l_Moode.textColor = UIColor.white.withAlphaComponent(0.75)
        l_Moode.numberOfLines = 2
        return l_Moode
    }()

    /// 右侧大装饰 emoji
    private let headerDecorEmoji_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "✍️"
        l_Moode.font = .systemFont(ofSize: 52)
        l_Moode.alpha = 0.25
        return l_Moode
    }()

    /// 右上角小装饰 emoji
    private let headerDecorSmall_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "📸"
        l_Moode.font = .systemFont(ofSize: 24)
        l_Moode.alpha = 0.3
        return l_Moode
    }()

    // MARK: - 主内容滚动区域

    private let scrollView_Moode: UIScrollView = {
        let sv_Moode = UIScrollView()
        sv_Moode.showsVerticalScrollIndicator = false
        sv_Moode.backgroundColor = .clear
        return sv_Moode
    }()

    private let contentView_Moode = UIView()

    // MARK: - 媒体卡片（步骤 01）

    private let mediaCard_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 20
        v_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#8B5CF6").cgColor
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Moode.layer.shadowRadius = 14
        v_Moode.layer.shadowOpacity = 0.10
        return v_Moode
    }()

    /// 步骤编号角标 "01"
    private let mediaStepBadge_Moode = makeStepBadge_Moode(text_Moode: "01")

    /// 卡片标题
    private let mediaSectionTitle_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Add Media"
        l_Moode.font = .systemFont(ofSize: 15, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        return l_Moode
    }()

    private let mediaRequiredDot_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "•  Required"
        l_Moode.font = .systemFont(ofSize: 11, weight: .medium)
        l_Moode.textColor = UIColor(hexstring_Moode: "#A78BFA")
        return l_Moode
    }()

    /// 虚线边框（无媒体时显示）
    private let mediaDashBorder_Moode = CAShapeLayer()

    /// 空状态容器
    private let mediaEmptyView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#F5F3FF")
        v_Moode.layer.cornerRadius = 14
        return v_Moode
    }()

    private let mediaEmptyIcon_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
        iv_Moode.image = UIImage(systemName: "photo.on.rectangle.angled", withConfiguration: cfg_Moode)
        iv_Moode.tintColor = UIColor(hexstring_Moode: "#A78BFA")
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    private let mediaEmptyTitle_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Add Photo or Video"
        l_Moode.font = .systemFont(ofSize: 14, weight: .semibold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#6D6D9A")
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    private let mediaEmptySub_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Tap to pick from library"
        l_Moode.font = .systemFont(ofSize: 11)
        l_Moode.textColor = UIColor(hexstring_Moode: "#AAAACC")
        l_Moode.textAlignment = .center
        return l_Moode
    }()

    /// 已选媒体预览图
    private let mediaPreviewImageView_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        iv_Moode.contentMode = .scaleAspectFill
        iv_Moode.clipsToBounds = true
        iv_Moode.layer.cornerRadius = 14
        iv_Moode.isHidden = true
        return iv_Moode
    }()

    /// 视频角标
    private let videoTagView_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#1A1A2E").withAlphaComponent(0.65)
        v_Moode.layer.cornerRadius = 10
        v_Moode.isHidden = true
        return v_Moode
    }()

    private let videoTagLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "▶  Video"
        l_Moode.font = .systemFont(ofSize: 11, weight: .semibold)
        l_Moode.textColor = .white
        return l_Moode
    }()

    /// 删除媒体按钮（右上角 X）
    private let removeMediaBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .custom)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 10, weight: .bold)
        btn_Moode.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.tintColor = .white
        btn_Moode.backgroundColor = UIColor(hexstring_Moode: "#1A1A2E").withAlphaComponent(0.55)
        btn_Moode.layer.cornerRadius = 14
        btn_Moode.isHidden = true
        return btn_Moode
    }()

    // MARK: - 输入卡片（步骤 02）

    private let inputCard_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 20
        v_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#8B5CF6").cgColor
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Moode.layer.shadowRadius = 14
        v_Moode.layer.shadowOpacity = 0.10
        return v_Moode
    }()

    private let inputStepBadge_Moode = makeStepBadge_Moode(text_Moode: "02")

    private let inputSectionTitle_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Write Your Post"
        l_Moode.font = .systemFont(ofSize: 15, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        return l_Moode
    }()

    /// 标题输入行图标
    private let titleIconView_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        iv_Moode.image = UIImage(systemName: "pencil.line", withConfiguration: cfg_Moode)
        iv_Moode.tintColor = UIColor(hexstring_Moode: "#A78BFA")
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    private let titleField_Moode: UITextField = {
        let tf_Moode = UITextField()
        tf_Moode.placeholder = "Give your post a title..."
        tf_Moode.font = .systemFont(ofSize: 16, weight: .semibold)
        tf_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        tf_Moode.borderStyle = .none
        tf_Moode.returnKeyType = .next
        return tf_Moode
    }()

    private let titleDivider_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        return v_Moode
    }()

    /// 正文输入行图标
    private let contentIconView_Moode: UIImageView = {
        let iv_Moode = UIImageView()
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
        iv_Moode.image = UIImage(systemName: "text.alignleft", withConfiguration: cfg_Moode)
        iv_Moode.tintColor = UIColor(hexstring_Moode: "#A78BFA")
        iv_Moode.contentMode = .scaleAspectFit
        return iv_Moode
    }()

    private let contentTextView_Moode: UITextView = {
        let tv_Moode = UITextView()
        tv_Moode.font = .systemFont(ofSize: 14)
        tv_Moode.textColor = UIColor(hexstring_Moode: "#444466")
        tv_Moode.backgroundColor = .clear
        tv_Moode.showsVerticalScrollIndicator = false
        tv_Moode.textContainerInset = .zero
        tv_Moode.textContainer.lineFragmentPadding = 0
        return tv_Moode
    }()

    private let contentPlaceholder_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "What's on your mind right now?"
        l_Moode.font = .systemFont(ofSize: 14)
        l_Moode.textColor = UIColor(hexstring_Moode: "#BBBBDD")
        l_Moode.numberOfLines = 0
        return l_Moode
    }()

    /// 底部计数 + 表情工具行
    private let inputBottomRow_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#F8F6FF")
        v_Moode.layer.cornerRadius = 12
        return v_Moode
    }()

    private let charCountLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "0 / 300"
        l_Moode.font = .systemFont(ofSize: 11, weight: .medium)
        l_Moode.textColor = UIColor(hexstring_Moode: "#A78BFA")
        l_Moode.textAlignment = .right
        return l_Moode
    }()

    private let charProgressBar_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        v_Moode.layer.cornerRadius = 2
        return v_Moode
    }()

    private let charProgressFill_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = UIColor(hexstring_Moode: "#A78BFA")
        v_Moode.layer.cornerRadius = 2
        return v_Moode
    }()

    private var charProgressFillWidth_Moode: Constraint?

    // MARK: - 底部发布按钮

    private let bottomPostBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .custom)
        let cfg_Moode = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn_Moode.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_Moode), for: .normal)
        btn_Moode.setTitle("  Post Now", for: .normal)
        btn_Moode.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn_Moode.setTitleColor(.white, for: .normal)
        btn_Moode.tintColor = .white
        btn_Moode.clipsToBounds = false
        btn_Moode.layer.cornerRadius = 28
        return btn_Moode
    }()

    private var bottomBtnGradient_Moode: CAGradientLayer?

    /// EULA 协议文本按钮（带下划线，位于发布按钮正下方）
    private let eulaBtn_Moode: UIButton = {
        let btn_Moode = UIButton(type: .system)
        // 构建带下划线的富文本标题
        let attrs_Moode: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor(hexstring_Moode: "#9B8FCC"),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor(hexstring_Moode: "#9B8FCC")
        ]
        let title_Moode = NSAttributedString(
            string: "EULA",
            attributes: attrs_Moode
        )
        btn_Moode.setAttributedTitle(title_Moode, for: .normal)
        btn_Moode.backgroundColor = .clear
        return btn_Moode
    }()

    // MARK: - 情绪模式配置

    /// 是否为情绪帖子发布模式，由外部（快速记录入口）设置
    var isMoodPost_Moode: Bool = false

    // MARK: - 数据

    private var selectedMediaPath_Moode: String? = nil
    private var selectedIsVideo_Moode: Bool = false
    /// 当前选中的情绪类型，仅情绪模式下使用
    private var selectedMoodType_Moode: MoodType_Moode? = nil
    /// 情绪选择芯片视图集合，用于更新选中态样式
    private var moodChipViews_Moode: [(view: UIView, label: UILabel, mood: MoodType_Moode)] = []

    // MARK: - 情绪选择卡片（仅情绪模式显示）

    /// 情绪选择卡片容器
    private let moodCard_Moode: UIView = {
        let v_Moode = UIView()
        v_Moode.backgroundColor = .white
        v_Moode.layer.cornerRadius = 20
        v_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#8B5CF6").cgColor
        v_Moode.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_Moode.layer.shadowRadius = 14
        v_Moode.layer.shadowOpacity = 0.10
        return v_Moode
    }()

    /// 情绪卡片高度约束（隐藏时收缩为 0）
    private var moodCardHeightConstraint_Moode: Constraint?

    private let moodSectionTitle_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "How are you feeling?"
        l_Moode.font = .systemFont(ofSize: 15, weight: .bold)
        l_Moode.textColor = UIColor(hexstring_Moode: "#1A1A2E")
        return l_Moode
    }()

    private let moodRequiredDot_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "•  Required"
        l_Moode.font = .systemFont(ofSize: 11, weight: .medium)
        l_Moode.textColor = UIColor(hexstring_Moode: "#A78BFA")
        return l_Moode
    }()

    private let moodHintLabel_Moode: UILabel = {
        let l_Moode = UILabel()
        l_Moode.text = "Select the mood that best describes how you feel"
        l_Moode.font = .systemFont(ofSize: 12)
        l_Moode.textColor = UIColor(hexstring_Moode: "#AAAACC")
        l_Moode.numberOfLines = 0
        return l_Moode
    }()

    private let moodChipScrollView_Moode: UIScrollView = {
        let sv_Moode = UIScrollView()
        sv_Moode.showsHorizontalScrollIndicator = false
        sv_Moode.showsVerticalScrollIndicator = false
        sv_Moode.backgroundColor = .clear
        return sv_Moode
    }()

    private let moodChipStackView_Moode: UIStackView = {
        let sv_Moode = UIStackView()
        sv_Moode.axis = .horizontal
        sv_Moode.spacing = 10
        sv_Moode.alignment = .center
        return sv_Moode
    }()

    // MARK: - 工厂方法

    /// 创建步骤编号角标视图
    private static func makeStepBadge_Moode(text_Moode: String) -> UIView {
        let container_moode = UIView()
        container_moode.backgroundColor = UIColor(hexstring_Moode: "#EDE9FF")
        container_moode.layer.cornerRadius = 10
        let label_moode = UILabel()
        label_moode.text = text_Moode
        label_moode.font = .systemFont(ofSize: 10, weight: .heavy)
        label_moode.textColor = UIColor(hexstring_Moode: "#7C6FF7")
        container_moode.addSubview(label_moode)
        label_moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(7)
        }
        container_moode.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        return container_moode
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Moode: "#F4F2FF")
        setupHeaderBg_Moode()
        setupScrollContent_Moode()
        setupKeyboardObserver_Moode()
        startHeaderAnimation_Moode()
        applyMoodPostMode_Moode()
    }

    /// 根据 isMoodPost_Moode 标志更新页头文案及情绪卡片可见性
    private func applyMoodPostMode_Moode() {
        if isMoodPost_Moode {
            // 更新页头描述，强调情绪记录主题
            headerTitleLabel_Moode.text = "Capture Your Mood"
            headerSubLabel_Moode.text = "Record how you feel with a photo or video"
            headerDecorEmoji_Moode.text = "🌈"
            headerDecorSmall_Moode.text = "💫"
            // 展开情绪选择卡片
            moodCard_Moode.isHidden = false
            moodCardHeightConstraint_Moode?.deactivate()
        } else {
            // 普通模式：隐藏并折叠情绪卡片，不占布局空间
            moodCard_Moode.isHidden = true
            moodCardHeightConstraint_Moode?.activate()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBtnGradients_Moode()
        updateHeaderGradient_Moode()
        updateMediaDashBorder_Moode()
    }

    // MARK: - UI 搭建：顶部头部

    private func setupHeaderBg_Moode() {
        view.addSubview(headerBg_Moode)
        headerBg_Moode.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(164)
        }

        headerBg_Moode.addSubview(headerDecorEmoji_Moode)
        headerDecorEmoji_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-10)
        }

        headerBg_Moode.addSubview(headerDecorSmall_Moode)
        headerDecorSmall_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-28)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
        }

        headerBg_Moode.addSubview(headerTitleLabel_Moode)
        headerTitleLabel_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(22)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }

        headerBg_Moode.addSubview(headerSubLabel_Moode)
        headerSubLabel_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(22)
            make.top.equalTo(headerTitleLabel_Moode.snp.bottom).offset(6)
            make.right.equalTo(headerDecorEmoji_Moode.snp.left).offset(-8)
        }
    }

    // MARK: - UI 搭建：滚动内容

    private func setupScrollContent_Moode() {
        view.addSubview(bottomPostBtn_Moode)
        bottomPostBtn_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-120)
            make.height.equalTo(bottomBtnHeight_Moode)
        }
        bottomPostBtn_Moode.addTarget(self, action: #selector(handlePublish_Moode), for: .touchUpInside)

        // EULA 协议按钮，位于发布按钮正下方 10pt
        view.addSubview(eulaBtn_Moode)
        eulaBtn_Moode.snp.makeConstraints { make in
            make.top.equalTo(bottomPostBtn_Moode.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }
        eulaBtn_Moode.addTarget(self, action: #selector(handleEulaTapped_Moode), for: .touchUpInside)

        view.addSubview(scrollView_Moode)
        scrollView_Moode.snp.makeConstraints { make in
            make.top.equalTo(headerBg_Moode.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomPostBtn_Moode.snp.top).offset(-12)
        }

        scrollView_Moode.addSubview(contentView_Moode)
        contentView_Moode.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Moode.contentLayoutGuide)
            make.width.equalTo(scrollView_Moode.frameLayoutGuide)
        }

        setupMediaCard_Moode()
        setupMoodCard_Moode()
        setupInputCard_Moode()
    }

    private func setupMediaCard_Moode() {
        contentView_Moode.addSubview(mediaCard_Moode)
        mediaCard_Moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(4)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        // 卡片头部行
        let mediaHeader_moode = UIView()
        mediaCard_Moode.addSubview(mediaHeader_moode)
        mediaHeader_moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(24)
        }

        mediaHeader_moode.addSubview(mediaStepBadge_Moode)
        mediaStepBadge_Moode.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }

        mediaHeader_moode.addSubview(mediaSectionTitle_Moode)
        mediaSectionTitle_Moode.snp.makeConstraints { make in
            make.left.equalTo(mediaStepBadge_Moode.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        mediaHeader_moode.addSubview(mediaRequiredDot_Moode)
        mediaRequiredDot_Moode.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
        }

        // 空状态区域
        mediaCard_Moode.addSubview(mediaEmptyView_Moode)
        mediaEmptyView_Moode.snp.makeConstraints { make in
            make.top.equalTo(mediaHeader_moode.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(130)
            make.bottom.equalToSuperview().offset(-12)
        }

        mediaEmptyView_Moode.addSubview(mediaEmptyIcon_Moode)
        mediaEmptyIcon_Moode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-18)
            make.width.height.equalTo(38)
        }

        mediaEmptyView_Moode.addSubview(mediaEmptyTitle_Moode)
        mediaEmptyTitle_Moode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(mediaEmptyIcon_Moode.snp.bottom).offset(10)
        }

        mediaEmptyView_Moode.addSubview(mediaEmptySub_Moode)
        mediaEmptySub_Moode.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(mediaEmptyTitle_Moode.snp.bottom).offset(4)
        }

        // 已选媒体预览（覆盖空状态区域相同位置）
        mediaCard_Moode.addSubview(mediaPreviewImageView_Moode)
        mediaPreviewImageView_Moode.snp.makeConstraints { make in
            make.top.equalTo(mediaHeader_moode.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(130)
        }

        mediaCard_Moode.addSubview(videoTagView_Moode)
        videoTagView_Moode.addSubview(videoTagLabel_Moode)
        videoTagView_Moode.snp.makeConstraints { make in
            make.left.equalTo(mediaPreviewImageView_Moode).offset(10)
            make.bottom.equalTo(mediaPreviewImageView_Moode).offset(-10)
            make.height.equalTo(22)
        }
        videoTagLabel_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(8)
        }

        mediaCard_Moode.addSubview(removeMediaBtn_Moode)
        removeMediaBtn_Moode.snp.makeConstraints { make in
            make.right.equalTo(mediaPreviewImageView_Moode).offset(-10)
            make.top.equalTo(mediaPreviewImageView_Moode).offset(10)
            make.width.height.equalTo(28)
        }
        removeMediaBtn_Moode.addTarget(self, action: #selector(handleRemoveMedia_Moode), for: .touchUpInside)

        let tap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleMediaCardTapped_Moode))
        mediaCard_Moode.addGestureRecognizer(tap_Moode)
        mediaCard_Moode.isUserInteractionEnabled = true
    }

    /// 搭建情绪选择卡片（步骤 02，仅情绪帖子模式可见）
    /// 功能：横向滚动展示所有情绪类型，点击选中后高亮对应芯片
    private func setupMoodCard_Moode() {
        contentView_Moode.addSubview(moodCard_Moode)
        moodCard_Moode.snp.makeConstraints { make in
            make.top.equalTo(mediaCard_Moode.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            // 保存高度约束，普通模式下激活为 0 折叠卡片
            moodCardHeightConstraint_Moode = make.height.equalTo(0).constraint
        }

        // 卡片头部行
        let moodHeader_moode = UIView()
        moodCard_Moode.addSubview(moodHeader_moode)
        moodHeader_moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(24)
        }

        let moodStepBadge_moode = Release_Moode.makeStepBadge_Moode(text_Moode: "02")
        moodHeader_moode.addSubview(moodStepBadge_moode)
        moodStepBadge_moode.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }

        moodHeader_moode.addSubview(moodSectionTitle_Moode)
        moodSectionTitle_Moode.snp.makeConstraints { make in
            make.left.equalTo(moodStepBadge_moode.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        moodHeader_moode.addSubview(moodRequiredDot_Moode)
        moodRequiredDot_Moode.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
        }

        // 提示文本
        moodCard_Moode.addSubview(moodHintLabel_Moode)
        moodHintLabel_Moode.snp.makeConstraints { make in
            make.top.equalTo(moodHeader_moode.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        // 情绪芯片横向滚动区
        moodCard_Moode.addSubview(moodChipScrollView_Moode)
        moodChipScrollView_Moode.snp.makeConstraints { make in
            make.top.equalTo(moodHintLabel_Moode.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().offset(-14)
        }

        moodChipScrollView_Moode.addSubview(moodChipStackView_Moode)
        moodChipStackView_Moode.snp.makeConstraints { make in
            make.edges.equalTo(moodChipScrollView_Moode.contentLayoutGuide)
            make.height.equalTo(moodChipScrollView_Moode.frameLayoutGuide)
        }

        // 构建每个情绪芯片
        for mood_moode in MoodType_Moode.allCases {
            let chip_moode = buildMoodChip_Moode(mood_moode: mood_moode)
            moodChipStackView_Moode.addArrangedSubview(chip_moode.view)
        }
    }

    /// 构建单个情绪选择芯片
    /// - Parameter mood_moode: 对应的情绪类型
    /// - Returns: 包含芯片视图和文本标签的元组
    private func buildMoodChip_Moode(mood_moode: MoodType_Moode) -> (view: UIView, label: UILabel, mood: MoodType_Moode) {
        let container_moode = UIView()
        container_moode.backgroundColor = UIColor(hexstring_Moode: "#F5F3FF")
        container_moode.layer.cornerRadius = 20
        container_moode.layer.borderWidth = 1.5
        container_moode.layer.borderColor = UIColor(hexstring_Moode: "#EDE9FF").cgColor
        container_moode.clipsToBounds = true

        let label_moode = UILabel()
        label_moode.text = "\(mood_moode.emoji_Moode)  \(mood_moode.displayName_Moode)"
        label_moode.font = .systemFont(ofSize: 13, weight: .semibold)
        label_moode.textColor = UIColor(hexstring_Moode: "#6D6D9A")
        label_moode.isUserInteractionEnabled = false

        container_moode.addSubview(label_moode)
        label_moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(14)
        }
        container_moode.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        let tap_moode = UITapGestureRecognizer(target: self, action: #selector(handleMoodChipTapped_Moode(_:)))
        container_moode.addGestureRecognizer(tap_moode)
        container_moode.isUserInteractionEnabled = true
        container_moode.tag = MoodType_Moode.allCases.firstIndex(of: mood_moode) ?? 0

        let chipInfo_moode = (view: container_moode, label: label_moode, mood: mood_moode)
        moodChipViews_Moode.append(chipInfo_moode)
        return chipInfo_moode
    }

    /// 情绪芯片点击处理：更新选中态样式
    /// - Parameter gesture_moode: 识别到的点击手势
    @objc private func handleMoodChipTapped_Moode(_ gesture_moode: UITapGestureRecognizer) {
        guard let tappedView_moode = gesture_moode.view else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let index_moode = tappedView_moode.tag
        let mood_moode = MoodType_Moode.allCases[index_moode]
        selectedMoodType_Moode = mood_moode
        updateMoodChipSelection_Moode()
    }

    /// 根据当前选中情绪刷新所有芯片的视觉状态
    private func updateMoodChipSelection_Moode() {
        for chipInfo_moode in moodChipViews_Moode {
            let isSelected_moode = chipInfo_moode.mood == selectedMoodType_Moode
            UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseInOut) {
                if isSelected_moode {
                    // 选中：使用情绪渐变起始色作为背景，白色文字
                    chipInfo_moode.view.backgroundColor = chipInfo_moode.mood.gradientStart_Moode
                    chipInfo_moode.view.layer.borderColor = UIColor.clear.cgColor
                    chipInfo_moode.label.textColor = .white
                } else {
                    chipInfo_moode.view.backgroundColor = UIColor(hexstring_Moode: "#F5F3FF")
                    chipInfo_moode.view.layer.borderColor = UIColor(hexstring_Moode: "#EDE9FF").cgColor
                    chipInfo_moode.label.textColor = UIColor(hexstring_Moode: "#6D6D9A")
                }
            }
        }
    }

    private func setupInputCard_Moode() {
        contentView_Moode.addSubview(inputCard_Moode)
        inputCard_Moode.snp.makeConstraints { make in
            make.top.equalTo(moodCard_Moode.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }

        // 卡片头部行
        let inputHeader_moode = UIView()
        inputCard_Moode.addSubview(inputHeader_moode)
        inputHeader_moode.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(24)
        }

        inputHeader_moode.addSubview(inputStepBadge_Moode)
        inputStepBadge_Moode.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
        }

        inputHeader_moode.addSubview(inputSectionTitle_Moode)
        inputSectionTitle_Moode.snp.makeConstraints { make in
            make.left.equalTo(inputStepBadge_Moode.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }

        // 标题输入行
        let titleRow_moode = UIView()
        inputCard_Moode.addSubview(titleRow_moode)
        titleRow_moode.snp.makeConstraints { make in
            make.top.equalTo(inputHeader_moode.snp.bottom).offset(14)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(36)
        }

        titleRow_moode.addSubview(titleIconView_Moode)
        titleIconView_Moode.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }

        titleRow_moode.addSubview(titleField_Moode)
        titleField_Moode.snp.makeConstraints { make in
            make.left.equalTo(titleIconView_Moode.snp.right).offset(8)
            make.right.top.bottom.equalToSuperview()
        }
        titleField_Moode.delegate = self
        titleField_Moode.addTarget(self, action: #selector(handleTitleChanged_Moode), for: .editingChanged)

        inputCard_Moode.addSubview(titleDivider_Moode)
        titleDivider_Moode.snp.makeConstraints { make in
            make.top.equalTo(titleRow_moode.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(1)
        }

        // 正文输入行
        let contentRow_moode = UIView()
        inputCard_Moode.addSubview(contentRow_moode)
        contentRow_moode.snp.makeConstraints { make in
            make.top.equalTo(titleDivider_Moode.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        contentRow_moode.addSubview(contentIconView_Moode)
        contentIconView_Moode.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(18)
        }

        contentRow_moode.addSubview(contentTextView_Moode)
        contentTextView_Moode.snp.makeConstraints { make in
            make.left.equalTo(contentIconView_Moode.snp.right).offset(8)
            make.right.top.equalToSuperview()
            make.height.equalTo(150)
            make.bottom.equalToSuperview()
        }
        contentTextView_Moode.delegate = self

        contentRow_moode.addSubview(contentPlaceholder_Moode)
        contentPlaceholder_Moode.snp.makeConstraints { make in
            make.top.right.equalTo(contentTextView_Moode)
            make.left.equalTo(contentTextView_Moode)
        }

        // 底部计数行
        inputCard_Moode.addSubview(inputBottomRow_Moode)
        inputBottomRow_Moode.snp.makeConstraints { make in
            make.top.equalTo(contentRow_moode.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(32)
            make.bottom.equalToSuperview().offset(-14)
        }

        inputBottomRow_Moode.addSubview(charCountLabel_Moode)
        charCountLabel_Moode.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }

        inputBottomRow_Moode.addSubview(charProgressBar_Moode)
        charProgressBar_Moode.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.right.equalTo(charCountLabel_Moode.snp.left).offset(-10)
            make.height.equalTo(4)
        }

        charProgressBar_Moode.addSubview(charProgressFill_Moode)
        charProgressFill_Moode.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            charProgressFillWidth_Moode = make.width.equalTo(0).constraint
        }
    }

    // MARK: - 渐变层更新

    private func updateHeaderGradient_Moode() {
        if headerGradient_Moode == nil {
            let grad_Moode = CAGradientLayer()
            grad_Moode.colors = [
                UIColor(hexstring_Moode: "#9B72F5").cgColor,
                UIColor(hexstring_Moode: "#6C5CE7").cgColor,
                UIColor(hexstring_Moode: "#5B4BD9").cgColor
            ]
            grad_Moode.locations = [0.0, 0.6, 1.0]
            grad_Moode.startPoint = CGPoint(x: 0, y: 0)
            grad_Moode.endPoint = CGPoint(x: 1, y: 1)
            headerBg_Moode.layer.insertSublayer(grad_Moode, at: 0)
            headerGradient_Moode = grad_Moode
        }
        headerGradient_Moode?.frame = headerBg_Moode.bounds
    }

    private func updateBtnGradients_Moode() {
        if bottomBtnGradient_Moode == nil {
            let grad_Moode = CAGradientLayer()
            grad_Moode.colors = [
                UIColor(hexstring_Moode: "#A78BFA").cgColor,
                UIColor(hexstring_Moode: "#7C6FF7").cgColor,
                UIColor(hexstring_Moode: "#6C5CE7").cgColor
            ]
            grad_Moode.locations = [0.0, 0.5, 1.0]
            grad_Moode.startPoint = CGPoint(x: 0, y: 0)
            grad_Moode.endPoint = CGPoint(x: 1, y: 1)
            grad_Moode.cornerRadius = bottomPostBtn_Moode.layer.cornerRadius
            bottomPostBtn_Moode.layer.insertSublayer(grad_Moode, at: 0)
            bottomBtnGradient_Moode = grad_Moode
            bottomPostBtn_Moode.layer.shadowColor = UIColor(hexstring_Moode: "#6C5CE7").cgColor
            bottomPostBtn_Moode.layer.shadowOffset = CGSize(width: 0, height: 8)
            bottomPostBtn_Moode.layer.shadowRadius = 18
            bottomPostBtn_Moode.layer.shadowOpacity = 0.40
        }
        bottomBtnGradient_Moode?.frame = bottomPostBtn_Moode.bounds
    }

    // MARK: - 虚线边框

    private func updateMediaDashBorder_Moode() {
        guard mediaPreviewImageView_Moode.isHidden else {
            mediaDashBorder_Moode.removeFromSuperlayer()
            return
        }
        mediaDashBorder_Moode.removeFromSuperlayer()
        let rect_moode = mediaEmptyView_Moode.frame.insetBy(dx: -2, dy: -2)
            .offsetBy(dx: mediaEmptyView_Moode.frame.minX < 0 ? 0 : 0, dy: 0)
        let path_Moode = UIBezierPath(roundedRect: mediaEmptyView_Moode.convert(mediaEmptyView_Moode.bounds, to: mediaCard_Moode).insetBy(dx: -1, dy: -1), cornerRadius: 14)
        mediaDashBorder_Moode.path = path_Moode.cgPath
        mediaDashBorder_Moode.strokeColor = UIColor(hexstring_Moode: "#C5BAFF").cgColor
        mediaDashBorder_Moode.fillColor = UIColor.clear.cgColor
        mediaDashBorder_Moode.lineWidth = 1.5
        mediaDashBorder_Moode.lineDashPattern = [5, 4]
        mediaCard_Moode.layer.addSublayer(mediaDashBorder_Moode)
        _ = rect_moode
    }

    // MARK: - 媒体预览刷新

    private func updateMediaPreview_Moode(image_moode: UIImage?, isVideo_moode: Bool) {
        let hasMedia_moode = image_moode != nil
        mediaEmptyView_Moode.isHidden = hasMedia_moode
        mediaPreviewImageView_Moode.isHidden = !hasMedia_moode
        removeMediaBtn_Moode.isHidden = !hasMedia_moode
        videoTagView_Moode.isHidden = !(hasMedia_moode && isVideo_moode)
        mediaPreviewImageView_Moode.image = image_moode
        selectedIsVideo_Moode = isVideo_moode
        mediaDashBorder_Moode.removeFromSuperlayer()
        // 选中媒体后，卡片添加彩色边框
        mediaCard_Moode.layer.borderWidth = hasMedia_moode ? 1.5 : 0
        mediaCard_Moode.layer.borderColor = hasMedia_moode
            ? UIColor(hexstring_Moode: "#A78BFA").cgColor : UIColor.clear.cgColor
    }

    // MARK: - 抖动反馈（字段验证失败时）

    /// 对指定视图播放水平抖动动画以提示用户
    private func shakeView_Moode(_ view_moode: UIView) {
        let anim_moode = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim_moode.timingFunction = CAMediaTimingFunction(name: .linear)
        anim_moode.duration = 0.42
        anim_moode.values = [-10, 10, -8, 8, -5, 5, -3, 3, 0]
        view_moode.layer.add(anim_moode, forKey: "shake")
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        // 短暂高亮红色边框
        UIView.animate(withDuration: 0.15) {
            view_moode.layer.borderWidth = 1.5
            view_moode.layer.borderColor = UIColor(hexstring_Moode: "#FF6B8A").cgColor
        } completion: { _ in
            UIView.animate(withDuration: 0.4, delay: 0.6) {
                view_moode.layer.borderWidth = 0
                view_moode.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }

    // MARK: - 清空页面数据

    private func clearAll_Moode() {
        titleField_Moode.text = ""
        contentTextView_Moode.text = ""
        contentPlaceholder_Moode.isHidden = false
        charCountLabel_Moode.text = "0 / 300"
        charProgressFillWidth_Moode?.update(offset: 0)
        selectedMediaPath_Moode = nil
        updateMediaPreview_Moode(image_moode: nil, isVideo_moode: false)
        // 重置情绪选择
        selectedMoodType_Moode = nil
        updateMoodChipSelection_Moode()
    }

    // MARK: - 头部动画

    private func startHeaderAnimation_Moode() {
        UIView.animate(withDuration: 2.8, delay: 0,
                       options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.headerDecorEmoji_Moode.transform = CGAffineTransform(translationX: 0, y: -8)
        }
        UIView.animate(withDuration: 2.2, delay: 0.5,
                       options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.headerDecorSmall_Moode.transform = CGAffineTransform(translationX: 0, y: 6)
        }
    }

    // MARK: - 键盘监听

    private func setupKeyboardObserver_Moode() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardWillShow_Moode(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleKeyboardWillHide_Moode(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
        let tap_Moode = UITapGestureRecognizer(target: self, action: #selector(handleBgTapped_Moode))
        tap_Moode.cancelsTouchesInView = false
        view.addGestureRecognizer(tap_Moode)
    }

    // MARK: - 事件处理

    @objc private func handleBgTapped_Moode() {
        view.endEditing(true)
    }

    /// EULA 按钮点击：通过 ProtocolHelper 展示最终用户许可协议
    @objc private func handleEulaTapped_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        ProtocolHelper_Moode.showProtocol_Moode(
            type_Moode: .eula_Moode,
            content_Moode: "eula.png",
            from: self
        )
    }

    @objc private func handleTitleChanged_Moode() { }

    @objc private func handleMediaCardTapped_Moode() {
        guard selectedMediaPath_Moode == nil else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        var config_Moode = PHPickerConfiguration()
        config_Moode.selectionLimit = 1
        config_Moode.filter = .any(of: [.images, .videos])
        let picker_Moode = PHPickerViewController(configuration: config_Moode)
        picker_Moode.delegate = self
        present(picker_Moode, animated: true)
    }

    @objc private func handleRemoveMedia_Moode() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedMediaPath_Moode = nil
        UIView.animate(withDuration: 0.22) {
            self.updateMediaPreview_Moode(image_moode: nil, isVideo_moode: false)
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    /// 发布按钮点击：登录校验 → 字段校验（抖动） → 发布 → 清空
    @objc private func handlePublish_Moode() {
        view.endEditing(true)

        // 1. 登录校验
        guard UserViewModel_Moode.shared_Moode.isLoggedIn_Moode else {
            Navigation_Moode.toLogin_Moode()
            return
        }

        // 2. 媒体校验
        guard selectedMediaPath_Moode != nil else {
            shakeView_Moode(mediaCard_Moode)
            Utils_Moode.showError_Moode(
                message_Moode: "Please add a photo or video",
                image_Moode: UIImage(systemName: "photo.badge.exclamationmark")
            )
            return
        }

        // 3. 标题校验
        let title_moode = titleField_Moode.text?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !title_moode.isEmpty else {
            shakeView_Moode(inputCard_Moode)
            Utils_Moode.showError_Moode(
                message_Moode: "Please enter a title",
                image_Moode: UIImage(systemName: "exclamationmark.circle")
            )
            return
        }

        // 4. 正文校验
        let content_moode = contentTextView_Moode.text.trimmingCharacters(in: .whitespaces)
        guard !content_moode.isEmpty else {
            shakeView_Moode(inputCard_Moode)
            Utils_Moode.showError_Moode(
                message_Moode: "Please write some content",
                image_Moode: UIImage(systemName: "exclamationmark.circle")
            )
            return
        }

        // 5. 情绪模式：校验情绪是否已选择
        if isMoodPost_Moode {
            guard selectedMoodType_Moode != nil else {
                shakeView_Moode(moodCard_Moode)
                Utils_Moode.showError_Moode(
                    message_Moode: "Please select your mood",
                    image_Moode: UIImage(systemName: "face.smiling.inverse")
                )
                return
            }
        }

        // 6. 发布
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        bottomPostBtn_Moode.animatePressDown_Moode { self.bottomPostBtn_Moode.animatePressUp_Moode() }

        TitleViewModel_Moode.shared_Moode.addPost_Moode(
            title_moode: title_moode,
            content_moode: content_moode,
            postType_moode: isMoodPost_Moode ? .mood_moode : .normal_moode,
            moodType_moode: selectedMoodType_Moode ?? .calm_moode,
            mediaPaths_moode: [selectedMediaPath_Moode!]
        )

        clearAll_Moode()
    }

    @objc private func handleKeyboardWillShow_Moode(_ notification_moode: Notification) {
        guard let kbFrame_moode = notification_moode.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_moode = notification_moode.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration_moode) {
            self.view.transform = CGAffineTransform(translationX: 0, y: -kbFrame_moode.height * 0.25)
        }
    }

    @objc private func handleKeyboardWillHide_Moode(_ notification_moode: Notification) {
        guard let duration_moode = notification_moode.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        UIView.animate(withDuration: duration_moode) {
            self.view.transform = .identity
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension Release_Moode: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result_moode = results.first else { return }

        let isVideo_moode = result_moode.itemProvider.hasItemConformingToTypeIdentifier("public.movie")

        if isVideo_moode {
            result_moode.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { [weak self] url_moode, _ in
                guard let self_moode = self, let url_moode = url_moode else { return }
                let localPath_moode = self_moode.saveToTemp_Moode(from: url_moode)
                DispatchQueue.main.async {
                    self_moode.selectedMediaPath_Moode = localPath_moode
                    let thumbnail_moode = self_moode.videoThumbnail_Moode(from: url_moode)
                    self_moode.updateMediaPreview_Moode(image_moode: thumbnail_moode, isVideo_moode: true)
                }
            }
        } else {
            result_moode.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image_moode, _ in
                guard let self_moode = self, let image_moode = image_moode as? UIImage else { return }
                let localPath_moode = self_moode.saveImageToTemp_Moode(image_moode: image_moode)
                DispatchQueue.main.async {
                    self_moode.selectedMediaPath_Moode = localPath_moode
                    self_moode.updateMediaPreview_Moode(image_moode: image_moode, isVideo_moode: false)
                }
            }
        }
    }

    private func saveImageToTemp_Moode(image_moode: UIImage) -> String {
        let fileName_moode = "mood_media_\(Int(Date().timeIntervalSince1970)).jpg"
        let path_Moode = NSTemporaryDirectory() + fileName_moode
        if let data_moode = image_moode.jpegData(compressionQuality: 0.85) {
            try? data_moode.write(to: URL(fileURLWithPath: path_Moode))
        }
        return path_Moode
    }

    private func saveToTemp_Moode(from url_moode: URL) -> String {
        let ext_moode = url_moode.pathExtension
        let fileName_moode = "mood_video_\(Int(Date().timeIntervalSince1970)).\(ext_moode)"
        let dest_moode = URL(fileURLWithPath: NSTemporaryDirectory() + fileName_moode)
        try? FileManager.default.copyItem(at: url_moode, to: dest_moode)
        return dest_moode.path
    }

    private func videoThumbnail_Moode(from url_moode: URL) -> UIImage? {
        let asset_moode = AVURLAsset(url: url_moode)
        let gen_moode = AVAssetImageGenerator(asset: asset_moode)
        gen_moode.appliesPreferredTrackTransform = true
        let time_moode = CMTime(seconds: 0.1, preferredTimescale: 600)
        if let cgImage_moode = try? gen_moode.copyCGImage(at: time_moode, actualTime: nil) {
            return UIImage(cgImage: cgImage_moode)
        }
        return nil
    }
}

// MARK: - UITextFieldDelegate

extension Release_Moode: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        contentTextView_Moode.becomeFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate

extension Release_Moode: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder_Moode.isHidden = !textView.text.isEmpty
        let count_moode = min(textView.text.count, 300)
        charCountLabel_Moode.text = "\(count_moode) / 300"
        if textView.text.count > 300 {
            textView.text = String(textView.text.prefix(300))
        }
        // 更新字数进度条宽度
        let ratio_moode = CGFloat(count_moode) / 300.0
        let barWidth_moode = charProgressBar_Moode.bounds.width * ratio_moode
        charProgressFillWidth_Moode?.update(offset: max(barWidth_moode, 0))
        // 接近上限时进度条变红
        charProgressFill_Moode.backgroundColor = count_moode > 270
            ? UIColor(hexstring_Moode: "#FF6B8A")
            : UIColor(hexstring_Moode: "#A78BFA")
        UIView.animate(withDuration: 0.2) {
            self.charProgressBar_Moode.layoutIfNeeded()
        }
    }
}
