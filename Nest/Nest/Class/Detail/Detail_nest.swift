import Foundation
import UIKit
import SnapKit

// MARK: - 帖子展示详情页面
/// 核心作用：完整展示帖子内容（媒体、标题、内容、作者、点赞）及评论互动
/// 设计思路：
///   - 媒体区全宽紧贴屏幕顶部（contentInsetAdjustmentBehavior = .never）
///   - 浮动半透明导航条（返回 + 举报按钮）覆盖在媒体上方
///   - 内容圆角卡片从媒体区滑出，包含作者行、正文、点赞、评论区
///   - 作者行含渐变环头像 + 姓名 + 时间；点赞 / 评论统计图标彩色化
///   - 评论卡片：渐变环头像 + 昵称 + 内容 + 举报按钮
///   - 底部固定输入栏：当前用户头像 + 文本框 + 渐变发送按钮
/// 关键逻辑：
///   - 登录用户右上角可见举报/删除按钮
///   - 每条评论右上角有举报按钮，举报后自动从列表删除
///   - 监听 titleStateDidChangeNotification_Nest 实时刷新
class Detail_Nest: UIViewController {

    // MARK: - 外部注入
    var titleModel_Nest: TitleModel_Nest?

    // MARK: - 私有状态
    private var post_Nest: TitleModel_Nest?

    /// 作者行引用（供 buildPostBody 约束使用）
    private let authorRowRef_Nest = UIView()
    /// 统计行引用（供 buildDivider 约束使用）
    private let statsRowRef_Nest  = UIView()
    /// 分割线引用（供 buildCommentsSection 约束使用）
    private let dividerLineRef_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.divider_Nest
        return v_Nest
    }()

    // MARK: - UI 组件

    private let scrollView_Nest: UIScrollView = {
        let sv_Nest = UIScrollView()
        sv_Nest.showsVerticalScrollIndicator = false
        sv_Nest.alwaysBounceVertical = true
        sv_Nest.contentInsetAdjustmentBehavior = .never
        return sv_Nest
    }()

    private let contentView_Nest = UIView()

    /// 媒体展示区（全宽，紧贴屏幕顶部）
    private let mediaView_Nest = MediaDisplayView_Nest()

    /// 媒体顶部渐变蒙版（使导航按钮更清晰）
    private let mediaTopGradient_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.isUserInteractionEnabled = false
        return v_Nest
    }()

    private var mediaGradientLayer_Nest: CAGradientLayer?

    /// 浮动导航覆盖层
    private let navOverlay_Nest = UIView()

    private let backBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        v_Nest.layer.cornerRadius = 20
        return v_Nest
    }()

    private let backIcon_Nest: UIImageView = {
        let iv_Nest = UIImageView(image: UIImage(systemName: "chevron.left"))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let reportMenuBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        v_Nest.layer.cornerRadius = 20
        return v_Nest
    }()

    private let reportMenuIcon_Nest: UIImageView = {
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let iv_Nest  = UIImageView(image: UIImage(systemName: "ellipsis", withConfiguration: cfg_Nest))
        iv_Nest.tintColor = .white
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    /// 内容卡片（圆角顶部，从媒体下方滑出）
    private let infoCard_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        v_Nest.layer.cornerRadius = 28
        v_Nest.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_Nest
    }()

    // MARK: - 作者行

    private let authorAvatar_Nest = UserAvatarView_Nest()

    /// 头像渐变外环
    private let authorAvatarRing_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 26
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private var authorRingGradient_Nest: CAGradientLayer?

    private let authorName_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        return lbl_Nest
    }()

    private let postTimeLbl_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 11)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        return lbl_Nest
    }()

    /// "View Profile" 胶囊按钮
    private let viewProfileBtn_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 12
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private var viewProfileGradient_Nest: CAGradientLayer?

    private let viewProfileLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "View Profile"
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Nest.textColor = .white
        return lbl_Nest
    }()

    // MARK: - 正文区

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        lbl_Nest.numberOfLines = 0
        return lbl_Nest
    }()

    private let contentLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 15)
        lbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        lbl_Nest.numberOfLines = 0
        lbl_Nest.lineBreakMode = .byWordWrapping
        return lbl_Nest
    }()

    // MARK: - 点赞 / 评论统计行

    private let likeBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn_Nest.setImage(UIImage(systemName: "heart", withConfiguration: cfg_Nest), for: .normal)
        btn_Nest.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg_Nest), for: .selected)
        btn_Nest.tintColor = UIColor(hexstring_Nest: "#FC8181")
        return btn_Nest
    }()

    private let likeCountLbl_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl_Nest.textColor = UIColor(hexstring_Nest: "#FC8181")
        return lbl_Nest
    }()

    private let commentIconLbl_Nest: UIImageView = {
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let iv_Nest  = UIImageView(image: UIImage(systemName: "bubble.left.fill", withConfiguration: cfg_Nest))
        iv_Nest.tintColor = ColorConfig_Nest.primaryGradientStart_Nest
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let commentCountLbl_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        lbl_Nest.textColor = ColorConfig_Nest.primaryGradientStart_Nest
        return lbl_Nest
    }()

    // MARK: - 评论区

    private let commentsSectionView_Nest = DetailCommentsSectionHeader_Nest()
    private let commentsStack_Nest: UIStackView = {
        let sv_Nest = UIStackView()
        sv_Nest.axis = .vertical
        sv_Nest.spacing = 10
        return sv_Nest
    }()

    private let noCommentView_Nest = DetailNoCommentView_Nest()

    // MARK: - 底部输入栏

    private let inputBar_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        // 仅上方两角圆角
        v_Nest.layer.cornerRadius = 20
        v_Nest.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v_Nest.layer.shadowColor = ColorConfig_Nest.shadowColor_Nest.cgColor
        v_Nest.layer.shadowOffset = CGSize(width: 0, height: -3)
        v_Nest.layer.shadowRadius = 10
        v_Nest.layer.shadowOpacity = 1
        return v_Nest
    }()

    /// 当前用户头像（输入栏左侧）
    private let inputAvatarView_Nest = CurrentUserAvatarView_Nest()

    private let commentField_Nest: UITextField = {
        let tf_Nest = UITextField()
        tf_Nest.placeholder = "Add a comment..."
        tf_Nest.font = UIFont.systemFont(ofSize: 14)
        tf_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        tf_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        tf_Nest.layer.cornerRadius = 20
        tf_Nest.layer.borderWidth = 1.2
        tf_Nest.layer.borderColor = ColorConfig_Nest.border_Nest.cgColor
        let pad_Nest = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf_Nest.leftView = pad_Nest
        tf_Nest.leftViewMode = .always
        tf_Nest.returnKeyType = .send
        return tf_Nest
    }()

    /// 渐变发送按钮
    private let sendBtn_Nest: UIButton = {
        let btn_Nest = UIButton(type: .custom)
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn_Nest.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_Nest), for: .normal)
        btn_Nest.tintColor = .white
        btn_Nest.layer.cornerRadius = 20
        return btn_Nest
    }()

    private var sendBtnGradient_Nest: CAGradientLayer?
    /// 发送按钮渐变包装容器（避免 CAGradientLayer 遮挡 UIButton 图标）
    private let sendGradientContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 20
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        buildMedia_Nest()
        buildNavOverlay_Nest()
        buildScrollContent_Nest()
        buildInputBar_Nest()
        setupNotifications_Nest()
        loadData_Nest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mediaGradientLayer_Nest?.frame = mediaTopGradient_Nest.bounds
        sendBtnGradient_Nest?.frame = sendGradientContainer_Nest.bounds
        authorRingGradient_Nest?.frame = authorAvatarRing_Nest.bounds
        viewProfileGradient_Nest?.frame = viewProfileBtn_Nest.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 媒体区

    private func buildMedia_Nest() {
        view.addSubview(scrollView_Nest)
        scrollView_Nest.addSubview(contentView_Nest)
        // inputBar 尚未加入视图层级，bottom 先约束到 view 底部，
        // 待 buildInputBar_Nest 添加 inputBar 后再更新
        scrollView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.bottom.equalToSuperview()
        }
        contentView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.edges.equalToSuperview()
            make_Nest.width.equalTo(view)
        }

        contentView_Nest.addSubview(mediaView_Nest)
        mediaView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(300)
        }

        // 点击媒体区进入全屏浏览
        let mediaTap_Nest = UITapGestureRecognizer(target: self, action: #selector(onMediaTapped_Nest))
        mediaView_Nest.isUserInteractionEnabled = true
        mediaView_Nest.addGestureRecognizer(mediaTap_Nest)

        // 顶部渐变蒙版（黑→透明）
        let gl_Nest = CAGradientLayer()
        gl_Nest.colors = [UIColor.black.withAlphaComponent(0.5).cgColor, UIColor.clear.cgColor]
        gl_Nest.startPoint = CGPoint(x: 0.5, y: 0)
        gl_Nest.endPoint   = CGPoint(x: 0.5, y: 1)
        mediaTopGradient_Nest.layer.insertSublayer(gl_Nest, at: 0)
        mediaGradientLayer_Nest = gl_Nest
        mediaView_Nest.addSubview(mediaTopGradient_Nest)
        mediaTopGradient_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(120)
        }
    }

    // MARK: - 浮动导航

    private func buildNavOverlay_Nest() {
        backBtn_Nest.addSubview(backIcon_Nest)
        reportMenuBtn_Nest.addSubview(reportMenuIcon_Nest)
        navOverlay_Nest.addSubview(backBtn_Nest)
        navOverlay_Nest.addSubview(reportMenuBtn_Nest)
        view.addSubview(navOverlay_Nest)

        navOverlay_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.height.equalTo(110)
        }
        backBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.top.equalToSuperview().offset(54)
            make_Nest.width.height.equalTo(40)
        }
        backIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(16)
        }
        reportMenuBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.centerY.equalTo(backBtn_Nest)
            make_Nest.width.height.equalTo(40)
        }
        reportMenuIcon_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.equalTo(22)
            make_Nest.height.equalTo(18)
        }

        backBtn_Nest.isUserInteractionEnabled = true
        backBtn_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBackTapped_Nest)))
        reportMenuBtn_Nest.isUserInteractionEnabled = true
        reportMenuBtn_Nest.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onReportTapped_Nest)))
    }

    // MARK: - 滚动内容区

    private func buildScrollContent_Nest() {
        // 内容卡片
        contentView_Nest.addSubview(infoCard_Nest)
        infoCard_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(mediaView_Nest.snp.bottom).offset(-28)
            make_Nest.leading.trailing.bottom.equalToSuperview()
        }

        buildAuthorRow_Nest()
        buildPostBody_Nest()
        buildStatsRow_Nest()
        buildDivider_Nest()
        buildCommentsSection_Nest()
    }

    /// 构建作者行（渐变环头像 + 名称 + 时间 + View Profile 胶囊）
    private func buildAuthorRow_Nest() {
        // 渐变外环
        let gl_Nest = CAGradientLayer()
        gl_Nest.colors = [
            ColorConfig_Nest.primaryGradientStart_Nest.cgColor,
            ColorConfig_Nest.primaryGradientEnd_Nest.cgColor
        ]
        gl_Nest.startPoint = CGPoint(x: 0, y: 0)
        gl_Nest.endPoint   = CGPoint(x: 1, y: 1)
        authorAvatarRing_Nest.layer.insertSublayer(gl_Nest, at: 0)
        authorRingGradient_Nest = gl_Nest

        let whiteInner_Nest = UIView()
        whiteInner_Nest.backgroundColor = ColorConfig_Nest.cardBackground_Nest
        whiteInner_Nest.layer.cornerRadius = 23
        whiteInner_Nest.clipsToBounds = true
        authorAvatarRing_Nest.addSubview(whiteInner_Nest)
        whiteInner_Nest.addSubview(authorAvatar_Nest)

        // View Profile 胶囊渐变
        let pgGl_Nest = CAGradientLayer()
        pgGl_Nest.colors = [
            ColorConfig_Nest.primaryGradientStart_Nest.cgColor,
            ColorConfig_Nest.primaryGradientEnd_Nest.cgColor
        ]
        pgGl_Nest.startPoint = CGPoint(x: 0, y: 0)
        pgGl_Nest.endPoint   = CGPoint(x: 1, y: 1)
        viewProfileBtn_Nest.layer.insertSublayer(pgGl_Nest, at: 0)
        viewProfileGradient_Nest = pgGl_Nest
        viewProfileBtn_Nest.addSubview(viewProfileLabel_Nest)
        viewProfileBtn_Nest.isUserInteractionEnabled = true
        viewProfileBtn_Nest.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onAuthorTapped_Nest))
        )

        authorRowRef_Nest.addSubview(authorAvatarRing_Nest)
        authorRowRef_Nest.addSubview(authorName_Nest)
        authorRowRef_Nest.addSubview(postTimeLbl_Nest)
        authorRowRef_Nest.addSubview(viewProfileBtn_Nest)
        authorRowRef_Nest.isUserInteractionEnabled = true
        authorRowRef_Nest.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onAuthorTapped_Nest))
        )

        infoCard_Nest.addSubview(authorRowRef_Nest)

        authorRowRef_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalToSuperview().offset(22)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(52)
        }
        authorAvatarRing_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(52)
        }
        whiteInner_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(46)
        }
        authorAvatar_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(40)
        }
        authorName_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(authorAvatarRing_Nest.snp.trailing).offset(12)
            make_Nest.top.equalTo(authorAvatarRing_Nest).offset(7)
        }
        postTimeLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(authorName_Nest)
            make_Nest.top.equalTo(authorName_Nest.snp.bottom).offset(3)
        }
        viewProfileBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalToSuperview()
            make_Nest.centerY.equalToSuperview()
            make_Nest.height.equalTo(26)
        }
        viewProfileLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(10)
            make_Nest.trailing.equalToSuperview().offset(-10)
            make_Nest.centerY.equalToSuperview()
        }
    }

    /// 构建帖子标题 + 正文
    private func buildPostBody_Nest() {
        infoCard_Nest.addSubview(titleLabel_Nest)
        infoCard_Nest.addSubview(contentLabel_Nest)

        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(authorRowRef_Nest.snp.bottom).offset(16)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
        }
        contentLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLabel_Nest.snp.bottom).offset(10)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
        }
    }

    /// 构建点赞 / 评论统计行
    private func buildStatsRow_Nest() {
        statsRowRef_Nest.addSubview(likeBtn_Nest)
        statsRowRef_Nest.addSubview(likeCountLbl_Nest)
        statsRowRef_Nest.addSubview(commentIconLbl_Nest)
        statsRowRef_Nest.addSubview(commentCountLbl_Nest)

        infoCard_Nest.addSubview(statsRowRef_Nest)
        statsRowRef_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(contentLabel_Nest.snp.bottom).offset(16)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(36)
        }

        likeBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(32)
        }
        likeCountLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(likeBtn_Nest.snp.trailing).offset(4)
            make_Nest.centerY.equalToSuperview()
        }
        commentIconLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(likeCountLbl_Nest.snp.trailing).offset(20)
            make_Nest.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(20)
        }
        commentCountLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(commentIconLbl_Nest.snp.trailing).offset(4)
            make_Nest.centerY.equalToSuperview()
        }

        likeBtn_Nest.addTarget(self, action: #selector(onLikeTapped_Nest), for: .touchUpInside)
    }

    /// 构建分割线
    private func buildDivider_Nest() {
        infoCard_Nest.addSubview(dividerLineRef_Nest)
        dividerLineRef_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(statsRowRef_Nest.snp.bottom).offset(16)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(0.5)
        }
    }

    /// 构建评论区（标题行 + 列表 + 空态）
    private func buildCommentsSection_Nest() {
        infoCard_Nest.addSubview(commentsSectionView_Nest)
        infoCard_Nest.addSubview(commentsStack_Nest)
        infoCard_Nest.addSubview(noCommentView_Nest)

        commentsSectionView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(dividerLineRef_Nest.snp.bottom).offset(18)
            make_Nest.leading.equalToSuperview().offset(20)
            make_Nest.trailing.equalToSuperview().offset(-20)
            make_Nest.height.equalTo(28)
        }
        commentsStack_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(commentsSectionView_Nest.snp.bottom).offset(12)
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.bottom.equalToSuperview().offset(-30)
        }
        noCommentView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(commentsSectionView_Nest.snp.bottom).offset(24)
            make_Nest.centerX.equalToSuperview()
            make_Nest.bottom.equalToSuperview().offset(-30)
        }
        noCommentView_Nest.isHidden = true
    }

    // MARK: - 输入栏

    private func buildInputBar_Nest() {
        // 渐变包装容器（渐变 layer 在容器内，button 作为子视图覆盖在渐变上方，解决图层遮挡问题）
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        sendGradientContainer_Nest.layer.insertSublayer(gl_Nest, at: 0)
        sendBtnGradient_Nest = gl_Nest

        sendBtn_Nest.backgroundColor = .clear
        sendBtn_Nest.addTarget(self, action: #selector(onSendComment_Nest), for: .touchUpInside)
        sendGradientContainer_Nest.addSubview(sendBtn_Nest)
        sendBtn_Nest.snp.makeConstraints { make_Nest in make_Nest.edges.equalToSuperview() }

        inputBar_Nest.addSubview(commentField_Nest)
        inputBar_Nest.addSubview(sendGradientContainer_Nest)
        view.addSubview(inputBar_Nest)

        // inputBar 已加入视图层级，重建 scrollView 约束使底部贴合 inputBar 顶部
        scrollView_Nest.snp.remakeConstraints { make_Nest in
            make_Nest.top.leading.trailing.equalToSuperview()
            make_Nest.bottom.equalTo(inputBar_Nest.snp.top)
        }

        inputBar_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.trailing.bottom.equalToSuperview()
            // 高度 = 内容区 66 + safeArea 底部间距，保证内容不被 Home 键遮挡
            make_Nest.height.equalTo(66).priority(.low)
            make_Nest.height.greaterThanOrEqualTo(66)
        }
        commentField_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(16)
            make_Nest.trailing.equalTo(sendGradientContainer_Nest.snp.leading).offset(-10)
            make_Nest.top.equalToSuperview().offset(13)
            make_Nest.height.equalTo(40)
        }
        sendGradientContainer_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalToSuperview().offset(-16)
            make_Nest.centerY.equalTo(commentField_Nest)
            make_Nest.width.height.equalTo(40)
        }

        commentField_Nest.delegate = self

        let tapDismiss_Nest = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Nest))
        tapDismiss_Nest.cancelsTouchesInView = false
        view.addGestureRecognizer(tapDismiss_Nest)

        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardShow_Nest(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onKeyboardHide_Nest(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    // MARK: - 通知

    private func setupNotifications_Nest() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onPostStateChanged_Nest),
            name: TitleViewModel_Nest.titleStateDidChangeNotification_Nest, object: nil
        )
    }

    // MARK: - 数据加载

    private func loadData_Nest() {
        if let mid_Nest = titleModel_Nest?.titleId_Nest {
            post_Nest = TitleViewModel_Nest.shared_Nest.getPosts_Nest()
                .first(where: { $0.titleId_Nest == mid_Nest }) ?? titleModel_Nest
        } else {
            post_Nest = titleModel_Nest
        }
        guard let post_Nest else { return }

        // 媒体
        mediaView_Nest.configure_Nest(mediaPath_Nest: post_Nest.titleMeidas_Nest.first, isVideo_Nest: false)

        // 正文
        titleLabel_Nest.text   = post_Nest.title_Nest
        contentLabel_Nest.text = post_Nest.titleContent_Nest

        // 作者
        authorAvatar_Nest.configure_Nest(userId_Nest: post_Nest.titleUserId_Nest)
        let author_Nest = LocalData_Nest.shared_Nest.userList_Nest
            .first(where: { $0.userId_Nest == post_Nest.titleUserId_Nest })
        authorName_Nest.text = author_Nest?.userName_Nest ?? "User"
        postTimeLbl_Nest.text = "Posted recently"

        // 点赞
        likeCountLbl_Nest.text = "\(post_Nest.likes_Nest)"
        commentCountLbl_Nest.text = "\(post_Nest.reviews_Nest.count)"
        likeBtn_Nest.isSelected = TitleViewModel_Nest.shared_Nest.isLikedPost_Nest(post_nest: post_Nest)

        // 举报按钮始终可见，点击时在事件中判断登录状态
        reportMenuBtn_Nest.isHidden = false

        // 输入栏始终可见，发送时在事件中判断登录状态
        inputBar_Nest.isHidden = false

        // 评论
        commentsSectionView_Nest.updateCount_Nest(post_Nest.reviews_Nest.count)
        buildComments_Nest()
    }

    private func buildComments_Nest() {
        commentsStack_Nest.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let post_Nest else { return }

        if post_Nest.reviews_Nest.isEmpty {
            noCommentView_Nest.isHidden = false
            commentsStack_Nest.snp.remakeConstraints { make_Nest in
                make_Nest.top.equalTo(commentsSectionView_Nest.snp.bottom).offset(12)
                make_Nest.leading.equalToSuperview().offset(16)
                make_Nest.trailing.equalToSuperview().offset(-16)
            }
        } else {
            noCommentView_Nest.isHidden = true
            commentsStack_Nest.snp.remakeConstraints { make_Nest in
                make_Nest.top.equalTo(commentsSectionView_Nest.snp.bottom).offset(12)
                make_Nest.leading.equalToSuperview().offset(16)
                make_Nest.trailing.equalToSuperview().offset(-16)
                make_Nest.bottom.equalToSuperview().offset(-30)
            }
            for (i_Nest, comment_Nest) in post_Nest.reviews_Nest.enumerated() {
                let card_Nest = makeCommentCard_Nest(comment: comment_Nest, post: post_Nest)
                commentsStack_Nest.addArrangedSubview(card_Nest)
                card_Nest.animateSlideInFromBottom_Nest(
                    offset_Nest: 20,
                    delay_Nest: TimeInterval(i_Nest) * AnimationConfig_Nest.delayShort_Nest
                )
            }
        }
    }

    /// 构建评论卡片（渐变环头像 + 昵称 + 内容 + 举报）
    private func makeCommentCard_Nest(comment: Comment_Nest, post: TitleModel_Nest) -> UIView {
        let card_Nest = UIView()
        card_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        card_Nest.layer.cornerRadius = 16

        // 头像外环
        let ring_Nest = UIView()
        ring_Nest.layer.cornerRadius = 20
        ring_Nest.clipsToBounds = true
        let ringGl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: CGRect(x: 0, y: 0, width: 40, height: 40))
        ring_Nest.layer.insertSublayer(ringGl_Nest, at: 0)

        let whiteInner_Nest = UIView()
        whiteInner_Nest.backgroundColor = ColorConfig_Nest.backgroundPrimary_Nest
        whiteInner_Nest.layer.cornerRadius = 17
        whiteInner_Nest.clipsToBounds = true
        ring_Nest.addSubview(whiteInner_Nest)

        let avatarView_Nest = UserAvatarView_Nest()
        avatarView_Nest.configure_Nest(userId_Nest: comment.commentUserId_Nest)
        whiteInner_Nest.addSubview(avatarView_Nest)

        let nameLbl_Nest = UILabel()
        let user_Nest = LocalData_Nest.shared_Nest.userList_Nest
            .first(where: { $0.userId_Nest == comment.commentUserId_Nest })
        nameLbl_Nest.text = user_Nest?.userName_Nest ?? "User"
        nameLbl_Nest.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        nameLbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest

        let contentLbl_Nest = UILabel()
        contentLbl_Nest.text = comment.commentContent_Nest
        contentLbl_Nest.font = UIFont.systemFont(ofSize: 13)
        contentLbl_Nest.textColor = ColorConfig_Nest.textSecondary_Nest
        contentLbl_Nest.numberOfLines = 0

        let reportBtn_Nest = UIButton(type: .custom)
        let flagCfg_Nest = UIImage.SymbolConfiguration(pointSize: 15, weight: .medium)
        reportBtn_Nest.setImage(UIImage(systemName: "ellipsis.circle.fill", withConfiguration: flagCfg_Nest), for: .normal)
        reportBtn_Nest.tintColor = ColorConfig_Nest.textPlaceholder_Nest
        reportBtn_Nest.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            ReportDeleteHelper_Nest.report_Nest(comment_Nest: comment, post_Nest: post, from: self)
        }, for: .touchUpInside)

        card_Nest.addSubview(ring_Nest)
        card_Nest.addSubview(nameLbl_Nest)
        card_Nest.addSubview(contentLbl_Nest)
        card_Nest.addSubview(reportBtn_Nest)

        ring_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalToSuperview().offset(12)
            make_Nest.top.equalToSuperview().offset(12)
            make_Nest.width.height.equalTo(40)
        }
        whiteInner_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(34)
        }
        avatarView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(28)
        }
        reportBtn_Nest.snp.makeConstraints { make_Nest in
            make_Nest.trailing.equalToSuperview().offset(-12)
            make_Nest.top.equalToSuperview().offset(12)
            make_Nest.width.height.equalTo(26)
        }
        nameLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(ring_Nest.snp.trailing).offset(10)
            make_Nest.top.equalToSuperview().offset(14)
            make_Nest.trailing.equalTo(reportBtn_Nest.snp.leading).offset(-4)
        }
        contentLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(nameLbl_Nest.snp.bottom).offset(4)
            make_Nest.leading.equalTo(nameLbl_Nest)
            make_Nest.trailing.equalToSuperview().offset(-12)
            make_Nest.bottom.equalToSuperview().offset(-12)
        }

        return card_Nest
    }

    // MARK: - 事件处理

    /// 点击媒体区 → 全屏浏览
    @objc private func onMediaTapped_Nest() {
        let player_Nest = MediaPlayerPage_Nest()
        player_Nest.mediaPath_Nest = post_Nest?.titleMeidas_Nest.first
        player_Nest.isVideo_Nest   = false
        player_Nest.modalPresentationStyle = .overFullScreen
        player_Nest.modalTransitionStyle   = .crossDissolve
        present(player_Nest, animated: true)
    }

    @objc private func onBackTapped_Nest() {
        backBtn_Nest.animatePressDown_Nest { self.backBtn_Nest.animatePressUp_Nest() }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Nest.pop_Nest(from: self)
    }

    @objc private func onReportTapped_Nest() {
        guard let post_Nest else { return }
        let alert_Nest = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert_Nest.addAction(UIAlertAction(title: "Report", style: .destructive) { [weak self] _ in
            guard let self else { return }
            ReportDeleteHelper_Nest.report_Nest(post_Nest: post_Nest, from: self)
        })
        alert_Nest.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self else { return }
            ReportDeleteHelper_Nest.delete_Nest(post_Nest: post_Nest, from: self) { [weak self] in
                Navigation_Nest.pop_Nest(from: self)
            }
        })
        alert_Nest.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Nest, animated: true)
    }

    @objc private func onAuthorTapped_Nest() {
        guard let post_Nest,
              let author_Nest = LocalData_Nest.shared_Nest.userList_Nest
                .first(where: { $0.userId_Nest == post_Nest.titleUserId_Nest })
        else { return }
        Navigation_Nest.toUserInfo_Nest(with: author_Nest)
    }

    @objc private func onLikeTapped_Nest() {
        guard let post_Nest else { return }
        guard UserViewModel_Nest.shared_Nest.isLoggedIn_Nest else {
            Navigation_Nest.toLogin_Nest(style_nest: .present_nest)
            return
        }
        TitleViewModel_Nest.shared_Nest.likePost_Nest(post_nest: post_Nest)
        likeBtn_Nest.animatePulse_Nest()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @objc private func onSendComment_Nest() {
        let text_Nest = (commentField_Nest.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text_Nest.isEmpty, let post_Nest else { return }
        guard UserViewModel_Nest.shared_Nest.isLoggedIn_Nest else {
            Navigation_Nest.toLogin_Nest(style_nest: .present_nest)
            return
        }
        sendBtn_Nest.animatePulse_Nest()
        TitleViewModel_Nest.shared_Nest.releaseComment_Nest(post_nest: post_Nest, content_nest: text_Nest)
        commentField_Nest.text = nil
        view.endEditing(true)
    }

    @objc private func onPostStateChanged_Nest() {
        loadData_Nest()
    }

    @objc private func dismissKeyboard_Nest() {
        view.endEditing(true)
    }

    @objc private func onKeyboardShow_Nest(_ notification: Notification) {
        guard let kbFrame_Nest = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_Nest = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        let height_Nest = kbFrame_Nest.height
        UIView.animate(withDuration: duration_Nest) {
            self.inputBar_Nest.snp.updateConstraints { make_Nest in
                make_Nest.bottom.equalToSuperview().offset(-height_Nest)
            }
            self.view.layoutIfNeeded()
        }
    }

    @objc private func onKeyboardHide_Nest(_ notification: Notification) {
        guard let duration_Nest = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        UIView.animate(withDuration: duration_Nest) {
            self.inputBar_Nest.snp.updateConstraints { make_Nest in
                make_Nest.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Nest: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        onSendComment_Nest()
        return true
    }
}

// MARK: - DetailCommentsSectionHeader_Nest
/// 评论区标题行：渐变圆点 + "Comments" + 数量胶囊
private class DetailCommentsSectionHeader_Nest: UIView {

    private var dotGradient_Nest: CAGradientLayer?

    private let dotView_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.layer.cornerRadius = 4
        v_Nest.clipsToBounds = true
        return v_Nest
    }()

    private let titleLabel_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Comments"
        lbl_Nest.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        return lbl_Nest
    }()

    private let countBadge_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Nest.textColor = ColorConfig_Nest.primaryGradientStart_Nest
        lbl_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.1)
        lbl_Nest.textAlignment = .center
        lbl_Nest.layer.cornerRadius = 10
        lbl_Nest.clipsToBounds = true
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        let gl_Nest = UIColor.createPrimaryGradientLayer_Nest(frame_Nest: .zero)
        dotView_Nest.layer.insertSublayer(gl_Nest, at: 0)
        dotGradient_Nest = gl_Nest

        addSubview(dotView_Nest)
        addSubview(titleLabel_Nest)
        addSubview(countBadge_Nest)

        dotView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.centerY.equalToSuperview()
            make_Nest.width.height.equalTo(8)
        }
        titleLabel_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(dotView_Nest.snp.trailing).offset(8)
            make_Nest.centerY.equalToSuperview()
        }
        countBadge_Nest.snp.makeConstraints { make_Nest in
            make_Nest.leading.equalTo(titleLabel_Nest.snp.trailing).offset(8)
            make_Nest.centerY.equalToSuperview()
            make_Nest.height.equalTo(20)
            make_Nest.width.greaterThanOrEqualTo(28)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        dotGradient_Nest?.frame = dotView_Nest.bounds
    }

    func updateCount_Nest(_ count: Int) {
        countBadge_Nest.text = "  \(count)  "
    }
}

// MARK: - DetailNoCommentView_Nest
/// 评论区空态：浮动图标 + 双行提示
private class DetailNoCommentView_Nest: UIView {

    private let iconContainer_Nest: UIView = {
        let v_Nest = UIView()
        v_Nest.backgroundColor = ColorConfig_Nest.primaryGradientStart_Nest.withAlphaComponent(0.08)
        v_Nest.layer.cornerRadius = 26
        return v_Nest
    }()

    private let iconView_Nest: UIImageView = {
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let iv_Nest  = UIImageView(image: UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: cfg_Nest))
        iv_Nest.tintColor = ColorConfig_Nest.primaryGradientStart_Nest
        iv_Nest.contentMode = .scaleAspectFit
        return iv_Nest
    }()

    private let titleLbl_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "No Comments Yet"
        lbl_Nest.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lbl_Nest.textColor = ColorConfig_Nest.textPrimary_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    private let subtitleLbl_Nest: UILabel = {
        let lbl_Nest = UILabel()
        lbl_Nest.text = "Be the first to share your thoughts!"
        lbl_Nest.font = UIFont.systemFont(ofSize: 13)
        lbl_Nest.textColor = ColorConfig_Nest.textPlaceholder_Nest
        lbl_Nest.textAlignment = .center
        return lbl_Nest
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        iconContainer_Nest.addSubview(iconView_Nest)
        addSubview(iconContainer_Nest)
        addSubview(titleLbl_Nest)
        addSubview(subtitleLbl_Nest)

        iconContainer_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.centerX.equalToSuperview()
            make_Nest.width.height.equalTo(52)
        }
        iconView_Nest.snp.makeConstraints { make_Nest in
            make_Nest.center.equalToSuperview()
            make_Nest.width.height.equalTo(26)
        }
        titleLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(iconContainer_Nest.snp.bottom).offset(12)
            make_Nest.centerX.equalToSuperview()
        }
        subtitleLbl_Nest.snp.makeConstraints { make_Nest in
            make_Nest.top.equalTo(titleLbl_Nest.snp.bottom).offset(4)
            make_Nest.centerX.equalToSuperview()
            make_Nest.bottom.equalToSuperview()
        }

        UIView.animate(
            withDuration: 2.0, delay: 0,
            options: [.autoreverse, .repeat, .curveEaseInOut]
        ) { self.iconContainer_Nest.transform = CGAffineTransform(translationX: 0, y: -5) }
    }

    required init?(coder: NSCoder) { fatalError() }
}
