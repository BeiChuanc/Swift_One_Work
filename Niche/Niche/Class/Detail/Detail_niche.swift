import Foundation
import UIKit
import SnapKit

// MARK: 帖子详情页

/// 帖子详情视图控制器
/// 功能：展示帖子完整内容、媒体、点赞、评论列表，支持发表评论
/// 设计：沉浸式全屏媒体 + 圆角内容卡片上浮 + 渐变作者区域 + 玻璃统计栏 + 气泡评论
/// 响应：监听 TitleViewModel 通知自动刷新页面数据
class Detail_Niche: UIViewController {

    // MARK: - 传入数据

    var titleModel_Niche: TitleModel_Niche?

    // MARK: - 私有属性

    private var _currentPost_niche: TitleModel_Niche? {
        guard let id_niche = titleModel_Niche?.titleId_Niche else { return nil }
        return TitleViewModel_Niche.shared_Niche.getPosts_Niche().first { $0.titleId_Niche == id_niche }
    }

    /// 当前帖子的发布者用户 ID（用于作者卡片点击导航）
    private var _authorUserId_niche: Int = 0
    /// 当前媒体路径（用于媒体点击打开播放器）
    private var _currentMediaPath_niche: String?

    // MARK: - UI 组件 / 顶部导航

    private let _backBtn_niche = BackButton_Niche()
    private var _reportBtn_niche: UIButton?

    // MARK: - UI 组件 / 媒体

    private let _scrollView_niche: UIScrollView = {
        let sv_niche = UIScrollView()
        sv_niche.showsVerticalScrollIndicator = false
        sv_niche.contentInsetAdjustmentBehavior = .never
        return sv_niche
    }()
    private let _contentView_niche = UIView()

    private let _mediaView_niche = MediaDisplayView_Niche()

    /// 媒体底部渐变遮罩（融合过渡效果）
    private let _mediaBottomFade_niche: UIView = {
        let v_niche = UIView()
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    // MARK: - UI 组件 / 内容卡

    private let _contentCard_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")
        v_niche.layer.cornerRadius = 28
        v_niche.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return v_niche
    }()

    /// 作者信息区（渐变背景圆角卡片）
    private let _authorCard_niche: UIView = {
        let v_niche = UIView()
        v_niche.layer.cornerRadius = 18
        v_niche.layer.shadowColor = UIColor(hexstring_Niche: "#B794F6").withValues(alpha: 0.15).cgColor
        v_niche.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_niche.layer.shadowRadius = 12
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()
    private var _authorCardGrad_niche: CAGradientLayer?

    private let _authorAvatar_niche = UserAvatarView_Niche()

    private let _authorNameLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        l_niche.textColor = .white
        return l_niche
    }()

    private let _authorTagLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "✦ Post Author"
        l_niche.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.75)
        return l_niche
    }()

    /// 帖子标题
    private let _postTitleLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        l_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        l_niche.numberOfLines = 0
        return l_niche
    }()

    /// 帖子内容
    private let _postContentLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 15)
        l_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        l_niche.numberOfLines = 0
        l_niche.lineBreakMode = .byWordWrapping
        return l_niche
    }()

    // MARK: - UI 组件 / 统计行（点赞 + 评论数）

    /// 玻璃拟态统计行容器
    private let _statsBar_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = .white
        v_niche.layer.cornerRadius = 16
        v_niche.layer.shadowColor = UIColor.black.withValues(alpha: 0.06).cgColor
        v_niche.layer.shadowOffset = CGSize(width: 0, height: 3)
        v_niche.layer.shadowRadius = 8
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()

    private let _likeButton_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        btn_niche.setImage(UIImage(systemName: "heart", withConfiguration: cfg_niche), for: .normal)
        btn_niche.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg_niche), for: .selected)
        btn_niche.tintColor = UIColor(hexstring_Niche: "#FF6B9D")
        return btn_niche
    }()

    private let _likeCountLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        l_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        return l_niche
    }()

    private let _commentCountIcon_niche: UIImageView = {
        let iv_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iv_niche.image = UIImage(systemName: "bubble.right.fill", withConfiguration: cfg_niche)
        iv_niche.tintColor = ColorConfig_Niche.primaryGradientEnd_Niche
        iv_niche.contentMode = .scaleAspectFit
        return iv_niche
    }()

    private let _commentCountLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        l_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        return l_niche
    }()

    // MARK: - UI 组件 / 评论区

    private let _commentSectionHeader_niche: UIView = UIView()

    private let _commentsContainer_niche = UIStackView()

    // MARK: - UI 组件 / 输入栏

    private let _inputBar_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = .white
        v_niche.layer.shadowColor = UIColor.black.withValues(alpha: 0.08).cgColor
        v_niche.layer.shadowOffset = CGSize(width: 0, height: -2)
        v_niche.layer.shadowRadius = 10
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()

    private let _commentField_niche: UITextField = {
        let tf_niche = UITextField()
        tf_niche.placeholder = "Share your thoughts..."
        tf_niche.font = UIFont.systemFont(ofSize: 14)
        tf_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        tf_niche.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")
        tf_niche.layer.cornerRadius = 20
        return tf_niche
    }()

    private let _sendButton_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.layer.cornerRadius = 20
        btn_niche.clipsToBounds = true
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn_niche.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_niche), for: .normal)
        btn_niche.tintColor = .white
        return btn_niche
    }()
    private var _sendBtnGrad_niche: CAGradientLayer?

    /// 送礼按钮（gift_btn 图标，与发送按钮同尺寸）
    /// 送礼按钮，高度与发送按钮一致，宽度由 gift_btn 图片比例自适应
    private let _giftButton_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.layer.cornerRadius = 20
        btn_niche.clipsToBounds = true
        btn_niche.setImage(
            UIImage(named: "gift_btn")?.withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        btn_niche.imageView?.contentMode = .scaleAspectFit
        btn_niche.contentHorizontalAlignment = .fill
        btn_niche.contentVerticalAlignment = .fill
        return btn_niche
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
        setupActions_Niche()
        setupObservers_Niche()
        loadPostData_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshAuthorCardGrad_Niche()
        refreshSendBtnGrad_Niche()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")

        // ── 输入栏（固定底部）──
        view.addSubview(_inputBar_niche)
        _inputBar_niche.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(66)
        }

        _commentField_niche.addLeftPadding_Niche(16)
        _commentField_niche.placeHolderTextColor_Niche(ColorConfig_Niche.textPlaceholder_Niche)
        _inputBar_niche.addSubview(_commentField_niche)
        _inputBar_niche.addSubview(_sendButton_niche)

        /// 发送按钮固定右侧
        _sendButton_niche.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        /// 输入框右侧紧贴发送按钮
        _commentField_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.trailing.equalTo(_sendButton_niche.snp.leading).offset(-10)
        }

        // ── 主滚动视图 ──
        view.addSubview(_scrollView_niche)
        _scrollView_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(_inputBar_niche.snp.top)
        }

        _scrollView_niche.addSubview(_contentView_niche)
        _contentView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        // ── 媒体（顶部全宽 360pt）──
        _contentView_niche.addSubview(_mediaView_niche)
        _mediaView_niche.layer.cornerRadius = 0
        _mediaView_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(360)
        }

        // 媒体底部渐变遮罩（融合过渡）
        _contentView_niche.addSubview(_mediaBottomFade_niche)
        _mediaBottomFade_niche.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(_mediaView_niche.snp.bottom)
            make.height.equalTo(120)
        }
        let fadeLyr_niche = CAGradientLayer()
        fadeLyr_niche.colors = [UIColor.clear.cgColor, UIColor(hexstring_Niche: "#F4F0FF").cgColor]
        fadeLyr_niche.startPoint = CGPoint(x: 0.5, y: 0)
        fadeLyr_niche.endPoint = CGPoint(x: 0.5, y: 1)
        DispatchQueue.main.async {
            fadeLyr_niche.frame = self._mediaBottomFade_niche.bounds
            self._mediaBottomFade_niche.layer.insertSublayer(fadeLyr_niche, at: 0)
        }

        // ── 内容卡（叠在媒体下方，圆角上浮）──
        _contentView_niche.addSubview(_contentCard_niche)
        _contentCard_niche.snp.makeConstraints { make in
            make.top.equalTo(_mediaView_niche.snp.bottom).offset(-30)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        buildContentArea_Niche()

        // ── 导航按钮（浮层）──
        view.addSubview(_backBtn_niche)
        _backBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        _backBtn_niche.onTapped_Niche = { Navigation_Niche.pop_Niche() }
    }

    private func buildContentArea_Niche() {
        // 作者卡片
        _contentCard_niche.addSubview(_authorCard_niche)
        _authorCard_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(62)
        }

        _authorCard_niche.addSubview(_authorAvatar_niche)
        _authorCard_niche.addSubview(_authorNameLabel_niche)
        _authorCard_niche.addSubview(_authorTagLabel_niche)

        _authorAvatar_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(38)
        }
        _authorNameLabel_niche.snp.makeConstraints { make in
            make.leading.equalTo(_authorAvatar_niche.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        _authorTagLabel_niche.snp.makeConstraints { make in
            make.leading.equalTo(_authorAvatar_niche.snp.trailing).offset(10)
            make.top.equalTo(_authorNameLabel_niche.snp.bottom).offset(2)
        }

        // 帖子标题
        _contentCard_niche.addSubview(_postTitleLabel_niche)
        _postTitleLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_authorCard_niche.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        // 帖子内容
        _contentCard_niche.addSubview(_postContentLabel_niche)
        _postContentLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_postTitleLabel_niche.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        // 统计行（全部 addSubview 再设约束）
        _contentCard_niche.addSubview(_statsBar_niche)
        _statsBar_niche.snp.makeConstraints { make in
            make.top.equalTo(_postContentLabel_niche.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(48)
        }

        _statsBar_niche.addSubview(_likeButton_niche)
        _statsBar_niche.addSubview(_likeCountLabel_niche)
        _statsBar_niche.addSubview(_commentCountIcon_niche)
        _statsBar_niche.addSubview(_commentCountLabel_niche)

        _likeButton_niche.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(32)
        }
        _likeCountLabel_niche.snp.makeConstraints { make in
            make.leading.equalTo(_likeButton_niche.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
        _commentCountIcon_niche.snp.makeConstraints { make in
            make.leading.equalTo(_likeCountLabel_niche.snp.trailing).offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }
        _commentCountLabel_niche.snp.makeConstraints { make in
            make.leading.equalTo(_commentCountIcon_niche.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }

        // 评论区标题
        buildCommentSectionHeader_Niche()

        // 评论容器
        _commentsContainer_niche.axis = .vertical
        _commentsContainer_niche.spacing = 0
        _contentCard_niche.addSubview(_commentsContainer_niche)
        _commentsContainer_niche.snp.makeConstraints { make in
            make.top.equalTo(_commentSectionHeader_niche.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }
    }

    private func buildCommentSectionHeader_Niche() {
        _contentCard_niche.addSubview(_commentSectionHeader_niche)
        _commentSectionHeader_niche.snp.makeConstraints { make in
            make.top.equalTo(_statsBar_niche.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(24)
        }

        let dot_niche = UIView()
        dot_niche.backgroundColor = ColorConfig_Niche.primaryGradientStart_Niche
        dot_niche.layer.cornerRadius = 4
        _commentSectionHeader_niche.addSubview(dot_niche)
        dot_niche.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }

        let titleLbl_niche = UILabel()
        titleLbl_niche.text = "COMMENTS"
        titleLbl_niche.font = UIFont.systemFont(ofSize: 11, weight: .heavy)
        titleLbl_niche.textColor = ColorConfig_Niche.primaryGradientStart_Niche
        _commentSectionHeader_niche.addSubview(titleLbl_niche)
        titleLbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(dot_niche.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 渐变刷新

    private func refreshAuthorCardGrad_Niche() {
        guard !_authorCard_niche.bounds.isEmpty else { return }
        if _authorCardGrad_niche == nil {
            let grad_niche = CAGradientLayer()
            grad_niche.cornerRadius = 18
            grad_niche.colors = [
                UIColor(hexstring_Niche: "#9333EA").cgColor,
                UIColor(hexstring_Niche: "#B794F6").cgColor,
                UIColor(hexstring_Niche: "#90CDF4").cgColor
            ]
            grad_niche.locations = [0, 0.6, 1.0]
            grad_niche.startPoint = CGPoint(x: 0, y: 0)
            grad_niche.endPoint = CGPoint(x: 1, y: 1)
            _authorCard_niche.layer.insertSublayer(grad_niche, at: 0)
            _authorCardGrad_niche = grad_niche
        }
        _authorCardGrad_niche?.frame = _authorCard_niche.bounds
    }

    private func refreshSendBtnGrad_Niche() {
        guard !_sendButton_niche.bounds.isEmpty else { return }
        if _sendBtnGrad_niche == nil {
            let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: _sendButton_niche.bounds)
            grad_niche.cornerRadius = 20
            _sendButton_niche.layer.insertSublayer(grad_niche, at: 0)
            _sendBtnGrad_niche = grad_niche
        }
        _sendBtnGrad_niche?.frame = _sendButton_niche.bounds
    }

    // MARK: - 数据加载

    private func setupActions_Niche() {
        _likeButton_niche.addTarget(self, action: #selector(handleLike_Niche), for: .touchUpInside)
        _sendButton_niche.addTarget(self, action: #selector(handleSendComment_Niche), for: .touchUpInside)
        _giftButton_niche.addTarget(self, action: #selector(handleGift_Niche), for: .touchUpInside)

        // 作者卡片点击 → 进入用户中心
        _authorCard_niche.isUserInteractionEnabled = true
        let authorTap_niche = UITapGestureRecognizer(target: self, action: #selector(handleAuthorTap_Niche))
        _authorCard_niche.addGestureRecognizer(authorTap_niche)

        // 媒体区域点击 → 打开全屏媒体播放器
        _mediaView_niche.isUserInteractionEnabled = true
        let mediaTap_niche = UITapGestureRecognizer(target: self, action: #selector(handleMediaTap_Niche))
        _mediaView_niche.addGestureRecognizer(mediaTap_niche)
    }

    private func setupObservers_Niche() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleDataChange_Niche),
            name: TitleViewModel_Niche.titleStateDidChangeNotification_Niche, object: nil
        )
    }

    @objc private func handleDataChange_Niche() { loadPostData_Niche() }

    private func loadPostData_Niche() {
        guard let post_niche = _currentPost_niche ?? titleModel_Niche else { return }

        // 记录作者 ID 和媒体路径，供点击回调使用
        _authorUserId_niche  = post_niche.titleUserId_Niche
        _currentMediaPath_niche = post_niche.titleMeidas_Niche.first

        _mediaView_niche.configure_Niche(mediaPath_Niche: post_niche.titleMeidas_Niche.first, isVideo_Niche: false)

        _authorAvatar_niche.configure_Niche(userId_Niche: post_niche.titleUserId_Niche)
        _authorNameLabel_niche.text = post_niche.titleUserName_Niche
        _postTitleLabel_niche.text = post_niche.title_Niche
        _postContentLabel_niche.text = post_niche.titleContent_Niche

        let isLiked_niche = TitleViewModel_Niche.shared_Niche.isLikedPost_Niche(post_niche: post_niche)
        _likeButton_niche.isSelected = isLiked_niche
        _likeCountLabel_niche.text = "\(post_niche.likes_Niche)"
        _commentCountLabel_niche.text = "\(post_niche.reviews_Niche.count)"

        refreshReportButton_Niche(post: post_niche)
        refreshComments_Niche(post: post_niche)
    }

    private func refreshReportButton_Niche(post: TitleModel_Niche) {
        _reportBtn_niche?.removeFromSuperview()
        let btn_niche = ReportDeleteHelper_Niche.createPostReportButton_Niche(
            post_Niche: post, size_Niche: 15, color_Niche: .white, from: self
        ) { [weak self] in
            Navigation_Niche.pop_Niche()
            _ = self
        }
        btn_niche.backgroundColor = UIColor.black.withValues(alpha: 0.35)
        btn_niche.layer.cornerRadius = 18
        view.addSubview(btn_niche)
        btn_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        _reportBtn_niche = btn_niche

        /// 礼物按钮移至举报按钮左侧10pt，垂直居中对齐
        view.addSubview(_giftButton_niche)
        _giftButton_niche.snp.remakeConstraints { make in
            make.trailing.equalTo(btn_niche.snp.leading).offset(-10)
            make.centerY.equalTo(btn_niche)
            make.height.equalTo(btn_niche.snp.height)
        }
    }

    private func refreshComments_Niche(post: TitleModel_Niche) {
        _commentsContainer_niche.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let currentUserId_niche = UserViewModel_Niche.shared_Niche.getCurrentUser_Niche().userId_Niche ?? 0

        // 过滤被举报用户的评论：被举报用户会从 userList 中移除，以此判断是否隐藏
        let visibleComments_niche = post.reviews_Niche.filter { comment_niche in
            if comment_niche.commentUserId_Niche == currentUserId_niche { return true } // 自己的评论始终显示
            return LocalData_Niche.shared_Niche.userList_Niche.contains {
                $0.userId_Niche == comment_niche.commentUserId_Niche
            }
        }

        if visibleComments_niche.isEmpty {
            let emptyV_niche = buildEmptyComments_Niche()
            _commentsContainer_niche.addArrangedSubview(emptyV_niche)
            return
        }

        for comment_niche in visibleComments_niche {
            let row_niche = buildCommentView_Niche(comment: comment_niche, post: post)
            _commentsContainer_niche.addArrangedSubview(row_niche)
        }
    }

    private func buildEmptyComments_Niche() -> UIView {
        let v_niche = UIView()
        let iconIV_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        iconIV_niche.image = UIImage(systemName: "bubble.left", withConfiguration: cfg_niche)
        iconIV_niche.tintColor = ColorConfig_Niche.textPlaceholder_Niche
        iconIV_niche.contentMode = .scaleAspectFit
        v_niche.addSubview(iconIV_niche)
        iconIV_niche.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(40)
        }
        let lbl_niche = UILabel()
        lbl_niche.text = "No comments yet\nBe the first to comment!"
        lbl_niche.font = UIFont.systemFont(ofSize: 13)
        lbl_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche
        lbl_niche.textAlignment = .center
        lbl_niche.numberOfLines = 2
        v_niche.addSubview(lbl_niche)
        lbl_niche.snp.makeConstraints { make in
            make.top.equalTo(iconIV_niche.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }
        v_niche.snp.makeConstraints { make in make.height.equalTo(100) }
        return v_niche
    }

    private func buildCommentView_Niche(comment: Comment_Niche, post: TitleModel_Niche) -> UIView {
        let row_niche = UIView()
        row_niche.backgroundColor = .white
        row_niche.layer.cornerRadius = 16

        let avatar_niche = UserAvatarView_Niche()
        avatar_niche.configure_Niche(userId_Niche: comment.commentUserId_Niche)

        let nameLbl_niche = UILabel()
        nameLbl_niche.text = comment.commentUserName_Niche
        nameLbl_niche.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        nameLbl_niche.textColor = ColorConfig_Niche.primaryGradientStart_Niche

        let contentBubble_niche = UIView()
        contentBubble_niche.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")
        contentBubble_niche.layer.cornerRadius = 12

        let contentLbl_niche = UILabel()
        contentLbl_niche.text = comment.commentContent_Niche
        contentLbl_niche.font = UIFont.systemFont(ofSize: 13)
        contentLbl_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        contentLbl_niche.numberOfLines = 0

        let reportBtn_niche = ReportDeleteHelper_Niche.createCommentReportButton_Niche(
            comment_Niche: comment, post_Niche: post, size_Niche: 12,
            color_Niche: ColorConfig_Niche.textSecondary_Niche, from: self
        ) { [weak self] in self?.loadPostData_Niche() }

        // 先全部 addSubview
        row_niche.addSubview(avatar_niche)
        row_niche.addSubview(nameLbl_niche)
        row_niche.addSubview(reportBtn_niche)
        row_niche.addSubview(contentBubble_niche)
        contentBubble_niche.addSubview(contentLbl_niche)

        avatar_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(28)
        }
        nameLbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(avatar_niche.snp.trailing).offset(8)
            make.centerY.equalTo(avatar_niche)
        }
        reportBtn_niche.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalTo(avatar_niche)
            make.width.height.equalTo(24)
        }
        contentBubble_niche.snp.makeConstraints { make in
            make.top.equalTo(avatar_niche.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
        contentLbl_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }

        // 评论卡片间距（上方留白）
        let wrapperV_niche = UIView()
        wrapperV_niche.addSubview(row_niche)
        row_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview()
        }
        return wrapperV_niche
    }

    // MARK: - 事件处理

    /// 作者卡片点击 → 导航到发布者用户中心
    @objc private func handleAuthorTap_Niche() {
        guard _authorUserId_niche != 0 else { return }
        let user_niche = UserViewModel_Niche.shared_Niche.getUserById_Niche(userId_niche: _authorUserId_niche)
        Navigation_Niche.toUserInfo_Niche(with: user_niche)
    }

    /// 媒体区域点击 → 打开全屏媒体播放器
    @objc private func handleMediaTap_Niche() {
        guard let path_niche = _currentMediaPath_niche, !path_niche.isEmpty else { return }
        let player_niche = MediaPlayerPage_Niche()
        player_niche.mediaPath_Niche = path_niche
        player_niche.isVideo_Niche = false
        player_niche.modalPresentationStyle = .fullScreen
        present(player_niche, animated: true)
    }

    @objc private func handleLike_Niche() {
        guard let post_niche = _currentPost_niche ?? titleModel_Niche else { return }
        _likeButton_niche.animatePulse_Niche()
        Task { @MainActor in TitleViewModel_Niche.shared_Niche.likePost_Niche(post_niche: post_niche) }
    }

    @objc private func handleSendComment_Niche() {
        let text_niche = _commentField_niche.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text_niche.isEmpty, let post_niche = _currentPost_niche ?? titleModel_Niche else { return }
        _commentField_niche.text = nil
        view.endEditing(true)
        Task { @MainActor in
            TitleViewModel_Niche.shared_Niche.releaseComment_Niche(post_niche: post_niche, content_niche: text_niche)
        }
    }

    /// 点击送礼按钮，弹出礼物选择界面
    @objc private func handleGift_Niche() {
        let giftPage_Niche = GiftPage_Niche()
        giftPage_Niche.modalPresentationStyle = .overFullScreen
        giftPage_Niche.modalTransitionStyle = .crossDissolve
        present(giftPage_Niche, animated: true)
    }
}
