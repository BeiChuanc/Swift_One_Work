import Foundation
import UIKit
import SnapKit

// MARK: 帖子详情页面

/// 帖子详情页面
/// 功能：展示帖子媒体/内容、点赞、评论列表与输入；右上角举报/删除
/// 设计亮点：
///   • 沉浸式媒体区（380pt）+ 三段渐变遮罩
///   • 作者信息磨砂胶囊（黑色半透明背景，一体化 avatar+name+tag）
///   • 内容卡片向上 -36pt 叠入媒体，顶部圆角 26pt
///   • 渐变左装饰条 + 渐变分隔线
///   • 统计行：点赞胶囊 + 评论数胶囊并排
///   • 评论区头部带数量徽章；Cell 左侧 3pt 渐变色条
///   • 输入栏：当前用户头像 + 暖白输入框 + 渐变发送按钮
class Detail_Vestir: UIViewController {

    // MARK: - 属性

    var titleModel_Vestir: TitleModel_Vestir?

    private var currentPost_Vestir: TitleModel_Vestir? {
        guard let id_vestir = titleModel_Vestir?.titleId_Vestir else { return titleModel_Vestir }
        return TitleViewModel_Vestir.shared_Vestir.getPosts_Vestir()
            .first(where: { $0.titleId_Vestir == id_vestir }) ?? titleModel_Vestir
    }

    // MARK: - 滚动容器

    private let scrollView_Vestir: UIScrollView = {
        let sv_Vestir = UIScrollView()
        sv_Vestir.showsVerticalScrollIndicator = false
        sv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        sv_Vestir.contentInsetAdjustmentBehavior = .never
        return sv_Vestir
    }()

    private let contentView_Vestir = UIView()

    // MARK: - 媒体区域

    private let mediaView_Vestir: MediaDisplayView_Vestir = {
        let mv_Vestir = MediaDisplayView_Vestir()
        mv_Vestir.layer.cornerRadius = 0
        mv_Vestir.clipsToBounds = true
        return mv_Vestir
    }()

    private let mediaOverlay_Vestir: UIView = UIView()
    private let overlayGradient_Vestir = CAGradientLayer()

    // MARK: - 导航悬浮按钮

    private let backBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_Vestir.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Vestir),
            for: .normal
        )
        btn_Vestir.tintColor = .white
        btn_Vestir.backgroundColor = UIColor(white: 0, alpha: 0.35)
        btn_Vestir.layer.cornerRadius = 18
        btn_Vestir.clipsToBounds = true
        return btn_Vestir
    }()

    private var reportBtnHolder_Vestir: UIView?

    // MARK: - 作者信息磨砂胶囊（整体一体化）

    /// 磨砂胶囊容器（黑色 38% alpha，圆角 28pt，包裹头像+名字+tag）
    private let authorInfoPill_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 0, alpha: 0.38)
        v_Vestir.layer.cornerRadius = 28
        v_Vestir.clipsToBounds = true
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    private let authorAvatarView_Vestir: UserAvatarView_Vestir = {
        let av_Vestir = UserAvatarView_Vestir()
        av_Vestir.layer.cornerRadius = 19
        av_Vestir.clipsToBounds = true
        av_Vestir.layer.borderWidth = 1.5
        av_Vestir.layer.borderColor = UIColor(white: 1.0, alpha: 0.75).cgColor
        return av_Vestir
    }()

    private let authorNameLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl_Vestir.textColor = .white
        return lbl_Vestir
    }()

    private let authorTagLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "View Profile ›"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.65)
        return lbl_Vestir
    }()

    // MARK: - 内容卡片

    private let contentCardShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
        v_Vestir.layer.shadowOpacity = 0.18
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: -6)
        v_Vestir.layer.shadowRadius = 18
        return v_Vestir
    }()

    private let contentCard_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        v_Vestir.layer.cornerRadius = 26
        v_Vestir.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    /// 标题渐变左装饰条
    private let titleAccentBar_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 2
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    private let postTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        lbl_Vestir.numberOfLines = 3
        return lbl_Vestir
    }()

    private let postContentLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        lbl_Vestir.numberOfLines = 0
        return lbl_Vestir
    }()

    // MARK: - 统计行（点赞胶囊 + 评论数胶囊并排）

    /// 统计行容器
    private let statsRow_Vestir: UIView = UIView()

    /// 点赞胶囊
    private let likePill_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#FFF1F2")
        v_Vestir.layer.cornerRadius = 20
        v_Vestir.layer.borderWidth = 1
        v_Vestir.layer.borderColor = UIColor(hexstring_Vestir: "#FECDD3").cgColor
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    private let likeBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_Vestir.setImage(UIImage(systemName: "heart", withConfiguration: cfg_Vestir), for: .normal)
        btn_Vestir.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg_Vestir), for: .selected)
        btn_Vestir.tintColor = ColorConfig_Vestir.heartColor_Vestir
        return btn_Vestir
    }()

    private let likeCountLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lbl_Vestir.textColor = ColorConfig_Vestir.heartColor_Vestir
        return lbl_Vestir
    }()

    /// 评论数胶囊（主渐变色系）
    private let commentStatPill_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.tagPill_Vestir
        v_Vestir.layer.cornerRadius = 20
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    private let commentStatIcon_Vestir: UIImageView = {
        let iv_Vestir = UIImageView()
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        iv_Vestir.image = UIImage(systemName: "bubble.left.fill", withConfiguration: cfg_Vestir)
        iv_Vestir.tintColor = ColorConfig_Vestir.primaryGradientStart_Vestir
        iv_Vestir.contentMode = .scaleAspectFit
        return iv_Vestir
    }()

    private let commentStatLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lbl_Vestir.textColor = ColorConfig_Vestir.tagPillText_Vestir
        return lbl_Vestir
    }()

    // MARK: - 渐变分隔线

    private let cardDivider_Vestir: UIView = UIView()

    // MARK: - 评论分区（带数量徽章）

    private let commentSectionRow_Vestir: UIView = UIView()

    private let commentDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.primaryGradientStart_Vestir
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()

    private let commentSectionTitle_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Comments"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    /// 评论数量徽章（薰衣草背景 + 深紫文字）
    private let commentCountBadge_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.tagPillText_Vestir
        lbl_Vestir.backgroundColor = ColorConfig_Vestir.tagPill_Vestir
        lbl_Vestir.layer.cornerRadius = 9
        lbl_Vestir.clipsToBounds = true
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    private let commentsStackView_Vestir: UIStackView = {
        let sv_Vestir = UIStackView()
        sv_Vestir.axis = .vertical
        sv_Vestir.spacing = 10
        return sv_Vestir
    }()

    // MARK: - 底部评论输入栏

    private let commentBar_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        v_Vestir.layer.cornerRadius = 26
        v_Vestir.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Vestir.layer.shadowColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
        v_Vestir.layer.shadowOpacity = 0.10
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: -4)
        v_Vestir.layer.shadowRadius = 14
        return v_Vestir
    }()

    private let commentInputField_Vestir: UITextField = {
        let tf_Vestir = UITextField()
        tf_Vestir.placeholder = "Add a comment..."
        tf_Vestir.font = UIFont.systemFont(ofSize: 14)
        tf_Vestir.borderStyle = .none
        tf_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        tf_Vestir.layer.cornerRadius = 20
        tf_Vestir.setLeftPadding_Vestir(
            icon: "bubble.left.fill",
            tintColor: ColorConfig_Vestir.primaryGradientStart_Vestir
        )
        tf_Vestir.returnKeyType = .send
        return tf_Vestir
    }()

    private let sendBtnView_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 19
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    private let sendGradLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#6B21A8").cgColor,
            UIColor(hexstring_Vestir: "#4338CA").cgColor,
            UIColor(hexstring_Vestir: "#0369A1").cgColor
        ]
        g_Vestir.locations = [0, 0.52, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        g_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        return g_Vestir
    }()

    private lazy var sendCommentBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        let cfg_Vestir = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn_Vestir.setImage(UIImage(systemName: "arrow.up", withConfiguration: cfg_Vestir), for: .normal)
        btn_Vestir.tintColor = .white
        btn_Vestir.addTarget(self, action: #selector(sendComment_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        bindNotifications_Vestir()
        loadData_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        loadData_Vestir()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayGradient_Vestir.frame = mediaOverlay_Vestir.bounds
        sendGradLayer_Vestir.frame = sendBtnView_Vestir.bounds
        refreshTitleAccentBar_Vestir()
        refreshCardDivider_Vestir()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        commentBar_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.bottom + 76)
        }
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 渐变刷新

    private func refreshTitleAccentBar_Vestir() {
        titleAccentBar_Vestir.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
        guard titleAccentBar_Vestir.bounds.width > 0 else { return }
        let g_Vestir = CAGradientLayer()
        g_Vestir.frame = titleAccentBar_Vestir.bounds
        g_Vestir.colors = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor
        ]
        g_Vestir.startPoint = CGPoint(x: 0.5, y: 0)
        g_Vestir.endPoint = CGPoint(x: 0.5, y: 1)
        g_Vestir.cornerRadius = 2
        titleAccentBar_Vestir.layer.insertSublayer(g_Vestir, at: 0)
    }

    private func refreshCardDivider_Vestir() {
        cardDivider_Vestir.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }
        guard cardDivider_Vestir.bounds.width > 0 else { return }
        let g_Vestir = CAGradientLayer()
        g_Vestir.frame = cardDivider_Vestir.bounds
        g_Vestir.colors = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor,
            UIColor.clear.cgColor
        ]
        g_Vestir.locations = [0, 0.5, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        g_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        cardDivider_Vestir.layer.addSublayer(g_Vestir)
    }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        overlayGradient_Vestir.colors = [
            UIColor.clear.cgColor,
            UIColor(white: 0, alpha: 0.18).cgColor,
            UIColor(white: 0, alpha: 0.65).cgColor
        ]
        overlayGradient_Vestir.locations = [0, 0.55, 1.0]
        overlayGradient_Vestir.startPoint = CGPoint(x: 0.5, y: 0)
        overlayGradient_Vestir.endPoint = CGPoint(x: 0.5, y: 1)
        mediaOverlay_Vestir.layer.addSublayer(overlayGradient_Vestir)

        view.addSubview(scrollView_Vestir)
        scrollView_Vestir.addSubview(contentView_Vestir)

        // 媒体底层
        contentView_Vestir.addSubview(mediaView_Vestir)
        contentView_Vestir.addSubview(mediaOverlay_Vestir)

        // 内容卡片（先加，z 轴低于作者信息）
        contentView_Vestir.addSubview(contentCardShadow_Vestir)
        contentCardShadow_Vestir.addSubview(contentCard_Vestir)
        contentCard_Vestir.addSubview(titleAccentBar_Vestir)
        contentCard_Vestir.addSubview(postTitleLabel_Vestir)
        contentCard_Vestir.addSubview(postContentLabel_Vestir)
        // 统计行
        contentCard_Vestir.addSubview(statsRow_Vestir)
        statsRow_Vestir.addSubview(likePill_Vestir)
        likePill_Vestir.addSubview(likeBtn_Vestir)
        likePill_Vestir.addSubview(likeCountLabel_Vestir)
        statsRow_Vestir.addSubview(commentStatPill_Vestir)
        commentStatPill_Vestir.addSubview(commentStatIcon_Vestir)
        commentStatPill_Vestir.addSubview(commentStatLabel_Vestir)
        // 分隔线
        contentCard_Vestir.addSubview(cardDivider_Vestir)
        // 评论区
        contentCard_Vestir.addSubview(commentSectionRow_Vestir)
        commentSectionRow_Vestir.addSubview(commentDot_Vestir)
        commentSectionRow_Vestir.addSubview(commentSectionTitle_Vestir)
        commentSectionRow_Vestir.addSubview(commentCountBadge_Vestir)
        contentCard_Vestir.addSubview(commentsStackView_Vestir)

        // 作者磨砂胶囊（后加，z 轴高于内容卡片）
        contentView_Vestir.addSubview(authorInfoPill_Vestir)
        authorInfoPill_Vestir.addSubview(authorAvatarView_Vestir)
        authorInfoPill_Vestir.addSubview(authorNameLabel_Vestir)
        authorInfoPill_Vestir.addSubview(authorTagLabel_Vestir)

        // 导航按钮（z 轴最高）
        contentView_Vestir.addSubview(backBtn_Vestir)

        // 评论输入栏
        view.addSubview(commentBar_Vestir)
        commentBar_Vestir.addSubview(commentInputField_Vestir)
        commentBar_Vestir.addSubview(sendBtnView_Vestir)
        sendBtnView_Vestir.layer.insertSublayer(sendGradLayer_Vestir, at: 0)
        sendBtnView_Vestir.addSubview(sendCommentBtn_Vestir)

        backBtn_Vestir.addTarget(self, action: #selector(backTapped_Vestir), for: .touchUpInside)
        likeBtn_Vestir.addTarget(self, action: #selector(likeTapped_Vestir), for: .touchUpInside)
        commentInputField_Vestir.delegate = self
    }

    private func setupConstraints_Vestir() {
        scrollView_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(commentBar_Vestir.snp.top)
        }
        contentView_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }

        // 媒体区 380pt
        mediaView_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(380)
        }
        mediaOverlay_Vestir.snp.makeConstraints { make in
            make.edges.equalTo(mediaView_Vestir)
        }

        // 返回按钮
        backBtn_Vestir.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }

        // 作者信息磨砂胶囊（媒体底部 20pt）
        authorInfoPill_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(mediaView_Vestir.snp.bottom).offset(-16)
            make.height.equalTo(52)
        }
        authorAvatarView_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(38)
        }
        authorNameLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(authorAvatarView_Vestir.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-14)
        }
        authorTagLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(authorNameLabel_Vestir)
            make.top.equalTo(authorNameLabel_Vestir.snp.bottom).offset(3)
            make.trailing.equalToSuperview().offset(-14)
        }

        // 内容卡片（向上 36pt 叠入媒体）
        contentCardShadow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Vestir.snp.bottom).offset(-36)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        contentCard_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 标题区
        titleAccentBar_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(24)
            make.width.equalTo(4)
            make.height.equalTo(26)
        }
        postTitleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(titleAccentBar_Vestir.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalTo(titleAccentBar_Vestir)
        }
        postContentLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel_Vestir.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }

        // 统计行
        statsRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel_Vestir.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(38)
        }
        // 点赞胶囊
        likePill_Vestir.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        likeBtn_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        likeCountLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(likeBtn_Vestir.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        // 评论数胶囊
        commentStatPill_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(likePill_Vestir.snp.trailing).offset(10)
            make.top.bottom.trailing.equalToSuperview()
        }
        commentStatIcon_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(11)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        commentStatLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(commentStatIcon_Vestir.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }

        // 渐变分隔线
        cardDivider_Vestir.snp.makeConstraints { make in
            make.top.equalTo(statsRow_Vestir.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview()
            make.height.equalTo(1.5)
        }

        // 评论区标题行
        commentSectionRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(cardDivider_Vestir.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(24)
        }
        commentDot_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        commentSectionTitle_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(commentDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }
        commentCountBadge_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(commentSectionTitle_Vestir.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.height.equalTo(20)
            make.width.greaterThanOrEqualTo(24)
        }

        // 评论列表
        commentsStackView_Vestir.snp.makeConstraints { make in
            make.top.equalTo(commentSectionRow_Vestir.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }

        // 输入栏
        commentBar_Vestir.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.bottom + 76)
        }
        commentInputField_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(sendBtnView_Vestir.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(44)
        }
        sendBtnView_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalTo(commentInputField_Vestir)
            make.width.height.equalTo(38)
        }
        sendCommentBtn_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    private func loadData_Vestir() {
        guard let post_vestir = currentPost_Vestir else { return }

        mediaView_Vestir.configure_Vestir(mediaPath_Vestir: post_vestir.titleMeidas_Vestir.first)
        authorAvatarView_Vestir.configure_Vestir(userId_Vestir: post_vestir.titleUserId_Vestir)
        authorNameLabel_Vestir.text = post_vestir.titleUserName_Vestir
        postTitleLabel_Vestir.text = post_vestir.title_Vestir
        postContentLabel_Vestir.text = post_vestir.titleContent_Vestir

        // 统计数据
        likeCountLabel_Vestir.text = "\(post_vestir.likes_Vestir)"
        likeBtn_Vestir.isSelected = UserViewModel_Vestir.shared_Vestir.isLikedByCurrentUser_Vestir(
            post_vestir: post_vestir
        )
        let commentCount_vestir = post_vestir.reviews_Vestir.count
        commentStatLabel_Vestir.text = "\(commentCount_vestir)"
        commentCountBadge_Vestir.text = "  \(commentCount_vestir)  "

        // 举报/删除按钮
        reportBtnHolder_Vestir?.removeFromSuperview()
        let reportBtn_vestir = ReportDeleteHelper_Vestir.createPostReportButton_Vestir(
            post_Vestir: post_vestir,
            size_Vestir: 17,
            color_Vestir: .white,
            from: self
        ) { [weak self] in Navigation_Vestir.pop_Vestir() }
        reportBtn_vestir.backgroundColor = UIColor(white: 0, alpha: 0.35)
        reportBtn_vestir.layer.cornerRadius = 18
        contentView_Vestir.addSubview(reportBtn_vestir)
        reportBtnHolder_Vestir = reportBtn_vestir
        reportBtn_vestir.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }

        rebuildComments_Vestir(post_vestir: post_vestir)
    }

    private func rebuildComments_Vestir(post_vestir: TitleModel_Vestir) {
        commentsStackView_Vestir.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 过滤掉被举报/屏蔽用户（reportUser_Vestir 会从 LocalData.userList 中移除该用户）的评论
        // 当前登录用户自己的评论始终显示
        let visibleComments_Vestir = post_vestir.reviews_Vestir.filter { comment_Vestir in
            !isCommentAuthorBlocked_Vestir(userId_vestir: comment_Vestir.commentUserId_Vestir)
        }

        if visibleComments_Vestir.isEmpty {
            let emptyLabel_vestir = UILabel()
            emptyLabel_vestir.text = "Be the first to comment ✨"
            emptyLabel_vestir.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            emptyLabel_vestir.textColor = ColorConfig_Vestir.textPlaceholder_Vestir
            emptyLabel_vestir.textAlignment = .center
            emptyLabel_vestir.numberOfLines = 2
            commentsStackView_Vestir.addArrangedSubview(emptyLabel_vestir)
            return
        }

        for (idx_vestir, comment_vestir) in visibleComments_Vestir.enumerated() {
            let cell_vestir = buildCommentCell_Vestir(comment_vestir: comment_vestir, post_vestir: post_vestir)
            cell_vestir.alpha = 0
            commentsStackView_Vestir.addArrangedSubview(cell_vestir)
            cell_vestir.animateFadeIn_Vestir(delay_Vestir: Double(idx_vestir) * 0.05)
        }
    }

    /// 判断评论作者是否已被举报/屏蔽
    /// 逻辑：reportUser_Vestir 会将用户从 LocalData.userList 中移除
    ///       若某 userId 不在 userList 中（且非当前登录用户），视为已屏蔽
    /// 参数：
    /// - userId_vestir: 评论作者的 userId
    /// 返回值：true = 已屏蔽，应隐藏该评论
    private func isCommentAuthorBlocked_Vestir(userId_vestir: Int) -> Bool {
        // 当前登录用户的评论始终可见
        if UserViewModel_Vestir.shared_Vestir.isCurrentUser_Vestir(userId_vestir: userId_vestir) {
            return false
        }
        // 被举报的用户会从 LocalData.userList 中移除，若找不到则视为已屏蔽
        return !LocalData_Vestir.shared_Vestir.userList_Vestir.contains {
            $0.userId_Vestir == userId_vestir
        }
    }

    /// 评论 Cell：暖白卡片 + 左侧渐变色条 + 渐变头像边框
    private func buildCommentCell_Vestir(
        comment_vestir: Comment_Vestir,
        post_vestir: TitleModel_Vestir
    ) -> UIView {
        let cell_vestir = UIView()
        cell_vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        cell_vestir.layer.cornerRadius = 16
        cell_vestir.layer.borderWidth = 1
        cell_vestir.layer.borderColor = ColorConfig_Vestir.divider_Vestir.cgColor
        cell_vestir.clipsToBounds = true

        // 左侧渐变色条（3pt 宽，全高）
        let accentBar_vestir = UIView()
        accentBar_vestir.clipsToBounds = true
        // 用 CAGradientLayer 渲染渐变色条
        let barGrad_vestir = CAGradientLayer()
        barGrad_vestir.colors = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor
        ]
        barGrad_vestir.startPoint = CGPoint(x: 0.5, y: 0)
        barGrad_vestir.endPoint = CGPoint(x: 0.5, y: 1)
        accentBar_vestir.layer.addSublayer(barGrad_vestir)

        // 头像（渐变背景外环）
        let avatarRing_vestir = UIView()
        avatarRing_vestir.backgroundColor = ColorConfig_Vestir.primaryGradientStart_Vestir.withAlphaComponent(0.12)
        avatarRing_vestir.layer.cornerRadius = 16
        avatarRing_vestir.clipsToBounds = true

        let avatarView_vestir = UserAvatarView_Vestir()
        avatarView_vestir.layer.cornerRadius = 13
        avatarView_vestir.clipsToBounds = true
        avatarView_vestir.configure_Vestir(userId_Vestir: comment_vestir.commentUserId_Vestir)

        let nameLabel_vestir = UILabel()
        nameLabel_vestir.text = comment_vestir.commentUserName_Vestir
        nameLabel_vestir.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLabel_vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir

        let contentLabel_vestir = UILabel()
        contentLabel_vestir.text = comment_vestir.commentContent_Vestir
        contentLabel_vestir.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        contentLabel_vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        contentLabel_vestir.numberOfLines = 0

        let reportBtn_vestir = ReportDeleteHelper_Vestir.createCommentReportButton_Vestir(
            comment_Vestir: comment_vestir,
            post_Vestir: post_vestir,
            size_Vestir: 13,
            color_Vestir: ColorConfig_Vestir.textPlaceholder_Vestir,
            from: self
        ) { [weak self] in self?.loadData_Vestir() }

        cell_vestir.addSubview(accentBar_vestir)
        cell_vestir.addSubview(avatarRing_vestir)
        avatarRing_vestir.addSubview(avatarView_vestir)
        cell_vestir.addSubview(nameLabel_vestir)
        cell_vestir.addSubview(contentLabel_vestir)
        cell_vestir.addSubview(reportBtn_vestir)

        accentBar_vestir.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(3)
        }
        avatarRing_vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(accentBar_vestir.snp.trailing).offset(10)
            make.width.height.equalTo(32)
        }
        avatarView_vestir.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }
        nameLabel_vestir.snp.makeConstraints { make in
            make.centerY.equalTo(avatarRing_vestir)
            make.leading.equalTo(avatarRing_vestir.snp.trailing).offset(8)
        }
        reportBtn_vestir.snp.makeConstraints { make in
            make.centerY.equalTo(avatarRing_vestir)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(26)
        }
        contentLabel_vestir.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_vestir.snp.bottom).offset(6)
            make.leading.equalTo(accentBar_vestir.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-10)
        }

        // 在 layoutSubviews 后异步更新渐变条 frame
        DispatchQueue.main.async {
            barGrad_vestir.frame = accentBar_vestir.bounds
        }

        return cell_vestir
    }

    // MARK: - 通知绑定

    private func bindNotifications_Vestir() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChanged_Vestir),
            name: TitleViewModel_Vestir.titleStateDidChangeNotification_Vestir, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChanged_Vestir),
            name: UserViewModel_Vestir.userStateDidChangeNotification_Vestir, object: nil
        )
    }

    @objc private func onDataChanged_Vestir() { loadData_Vestir() }

    // MARK: - 事件处理

    @objc private func backTapped_Vestir() { Navigation_Vestir.pop_Vestir() }

    @objc private func likeTapped_Vestir() {
        guard let post_vestir = currentPost_Vestir else { return }
        likeBtn_Vestir.animatePulse_Vestir()
        Task { @MainActor in
            TitleViewModel_Vestir.shared_Vestir.likePost_Vestir(post_vestir: post_vestir)
        }
    }

    @objc private func sendComment_Vestir() {
        guard
            let post_vestir = currentPost_Vestir,
            let text_vestir = commentInputField_Vestir.text,
            !text_vestir.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            commentInputField_Vestir.animateShake_Vestir()
            return
        }
        Task { @MainActor in
            TitleViewModel_Vestir.shared_Vestir.releaseComment_Vestir(
                post_vestir: post_vestir,
                content_vestir: text_vestir
            )
        }
        commentInputField_Vestir.text = ""
        commentInputField_Vestir.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Vestir: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment_Vestir()
        return true
    }
}
