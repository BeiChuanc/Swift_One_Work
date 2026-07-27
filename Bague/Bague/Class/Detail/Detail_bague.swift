import Foundation
import UIKit
import SnapKit

// MARK: 帖子详情页

/// 帖子详情视图控制器
/// 功能：展示帖子媒体/标题/内容/评论列表，支持点赞、发表评论、举报/删除帖子和评论
/// 设计：大图头部、胶囊半透明悬浮按钮、白色圆角内容卡片、浅紫评论卡片、玫瑰渐变发送按钮
class Detail_Bague: UIViewController {

    // MARK: - 属性

    var titleModel_Bague: TitleModel_Bague?

    // MARK: - UI 组件

    private let scrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView_Bague = UIView()

    /// 返回按钮（半透明胶囊，与全局风格统一）
    private let backBtn_Bague: UIButton = {
        let btn = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        btn.layer.cornerRadius = 18
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
        return btn
    }()

    /// 举报/删除按钮（右上角）
    private var postActionBtn_Bague: UIButton?

    /// 媒体展示视图
    private let mediaDisplayView_Bague = MediaDisplayView_Bague()

    /// 内容卡片（上圆角白色卡片浮于媒体顶部）
    private let contentCard_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -4)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 20
        return v
    }()

    // MARK: - 作者行

    private let authorRow_Bague = UIView()

    /// 作者行左侧彩色口音条
    private let authorAccentBar_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#9B72F5")
        v.layer.cornerRadius = 2
        return v
    }()

    private let authorAvatar_Bague = UserAvatarView_Bague()

    private let authorNameLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = ColorConfig_Bague.textPrimary_Bague
        return label
    }()

    private let authorBioLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        return label
    }()

    /// 点赞按钮（已点赞=辅助渐变，未点赞=浅色胶囊）
    private let likesBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 16
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        return btn
    }()

    // MARK: - 内容区

    private let titleLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = ColorConfig_Bague.textPrimary_Bague
        label.numberOfLines = 0
        return label
    }()

    private let bodyLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.textColor = ColorConfig_Bague.textSecondary_Bague
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    // MARK: - 评论区

    /// 评论区分割线（带渐变色）
    private let dividerView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Bague.divider_Bague
        return v
    }()

    /// 评论区标题行（图标 + 文字）
    private let commentHeaderRow_Bague: UIView = UIView()

    private let commentIconView_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        iv.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: cfg)
        iv.tintColor = UIColor(hexstring_Bague: "#9B72F5")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let commentTitleLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Comments"
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textColor = ColorConfig_Bague.textPrimary_Bague
        return label
    }()

    private let commentsStack_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        return sv
    }()

    /// 无评论时的空状态
    private let noCommentsView_Bague: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    private let noCommentsIcon_Bague: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 28, weight: .light)
        iv.image = UIImage(systemName: "bubble.left", withConfiguration: cfg)
        iv.tintColor = UIColor(hexstring_Bague: "#9B72F5").withAlphaComponent(0.35)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let noCommentsLabel_Bague: UILabel = {
        let label = UILabel()
        label.text = "Be the first to comment!"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = ColorConfig_Bague.textPlaceholder_Bague
        label.textAlignment = .center
        return label
    }()

    // MARK: - 底部输入栏

    private let inputContainer_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.shadowColor = UIColor(hexstring_Bague: "#8B9CC8").cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: -2)
        v.layer.shadowOpacity = 0.1
        v.layer.shadowRadius = 12
        return v
    }()

    private let inputBg_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#F5F0FF")
        v.layer.cornerRadius = 22
        v.layer.borderWidth = 1.2
        v.layer.borderColor = UIColor(hexstring_Bague: "#D4C4FF").cgColor
        return v
    }()

    private let commentField_Bague: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Add a comment..."
        tf.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        tf.textColor = ColorConfig_Bague.textPrimary_Bague
        tf.returnKeyType = .send
        tf.placeHolderTextColor_Bague(ColorConfig_Bague.textPlaceholder_Bague)
        return tf
    }()

    private let sendCommentBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        btn.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 18
        return btn
    }()

    /// 送礼按钮（gift_btn 图标，与发送按钮尺寸一致）
    private let giftBtn_Bague: UIButton = {
        let btn = UIButton(type: .custom)
        let img = UIImage(named: "gift_btn")?.withRenderingMode(.alwaysOriginal)
        btn.setImage(img, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.layer.cornerRadius = 18
        btn.clipsToBounds = true
        return btn
    }()

    private var sendBtnGradient_Bague: CAGradientLayer?
    private var likesBtnGradient_Bague: CAGradientLayer?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Bague()
        setupConstraints_Bague()
        setupBindings_Bague()
        loadData_Bague()
        setupKeyboardObservers_Bague()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradients_Bague()
    }

    // MARK: - UI 设置

    private func setupUI_Bague() {
        view.backgroundColor = ColorConfig_Bague.backgroundPrimary_Bague

        view.addSubview(scrollView_Bague)
        scrollView_Bague.addSubview(contentView_Bague)

        // 媒体区域
        contentView_Bague.addSubview(mediaDisplayView_Bague)
        contentView_Bague.addSubview(backBtn_Bague)
        backBtn_Bague.addTarget(self, action: #selector(backTapped_Bague), for: .touchUpInside)

        // 内容卡片
        contentView_Bague.addSubview(contentCard_Bague)
        contentCard_Bague.addSubview(authorRow_Bague)
        authorRow_Bague.addSubview(authorAccentBar_Bague)
        authorRow_Bague.addSubview(authorAvatar_Bague)
        authorRow_Bague.addSubview(authorNameLabel_Bague)
        authorRow_Bague.addSubview(authorBioLabel_Bague)
        authorRow_Bague.addSubview(likesBtn_Bague)

        contentCard_Bague.addSubview(titleLabel_Bague)
        contentCard_Bague.addSubview(bodyLabel_Bague)
        contentCard_Bague.addSubview(dividerView_Bague)

        // 评论标题行
        contentCard_Bague.addSubview(commentHeaderRow_Bague)
        commentHeaderRow_Bague.addSubview(commentIconView_Bague)
        commentHeaderRow_Bague.addSubview(commentTitleLabel_Bague)

        contentCard_Bague.addSubview(commentsStack_Bague)

        // 无评论空状态
        contentCard_Bague.addSubview(noCommentsView_Bague)
        noCommentsView_Bague.addSubview(noCommentsIcon_Bague)
        noCommentsView_Bague.addSubview(noCommentsLabel_Bague)

        // 底部输入栏
        view.addSubview(inputContainer_Bague)
        inputContainer_Bague.addSubview(inputBg_Bague)
        inputBg_Bague.addSubview(commentField_Bague)
        inputBg_Bague.addSubview(giftBtn_Bague)
        inputBg_Bague.addSubview(sendCommentBtn_Bague)
        commentField_Bague.delegate = self
        sendCommentBtn_Bague.addTarget(self, action: #selector(sendComment_Bague), for: .touchUpInside)
        giftBtn_Bague.addTarget(self, action: #selector(giftBtnTapped_Bague), for: .touchUpInside)

        let bgTap_bague = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Bague))
        bgTap_bague.cancelsTouchesInView = false
        scrollView_Bague.addGestureRecognizer(bgTap_bague)

        // 点击作者行
        let authorTap_bague = UITapGestureRecognizer(target: self, action: #selector(authorTapped_Bague))
        authorRow_Bague.addGestureRecognizer(authorTap_bague)
        authorRow_Bague.isUserInteractionEnabled = true

        likesBtn_Bague.addTarget(self, action: #selector(likesTapped_Bague), for: .touchUpInside)
        likesBtn_Bague.addTarget(self, action: #selector(likesBtnDown_Bague), for: .touchDown)
        likesBtn_Bague.addTarget(self, action: #selector(likesBtnUp_Bague), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func setupConstraints_Bague() {
        scrollView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(inputContainer_Bague.snp.top)
        }
        contentView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        mediaDisplayView_Bague.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(320)
        }
        backBtn_Bague.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        contentCard_Bague.snp.makeConstraints { make in
            make.top.equalTo(mediaDisplayView_Bague.snp.bottom).offset(-24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        authorRow_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
        }
        authorAccentBar_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(4)
            make.height.equalTo(32)
        }
        authorAccentBar_Bague.layer.cornerRadius = 2
        authorAvatar_Bague.snp.makeConstraints { make in
            make.leading.equalTo(authorAccentBar_Bague.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(42)
        }
        authorNameLabel_Bague.snp.makeConstraints { make in
            make.leading.equalTo(authorAvatar_Bague.snp.trailing).offset(10)
            make.top.equalTo(authorAvatar_Bague).offset(5)
        }
        authorBioLabel_Bague.snp.makeConstraints { make in
            make.leading.equalTo(authorNameLabel_Bague)
            make.top.equalTo(authorNameLabel_Bague.snp.bottom).offset(3)
        }
        likesBtn_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }
        titleLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(authorRow_Bague.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        bodyLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Bague.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        dividerView_Bague.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel_Bague.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        // 评论标题行
        commentHeaderRow_Bague.snp.makeConstraints { make in
            make.top.equalTo(dividerView_Bague.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }
        commentIconView_Bague.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        commentTitleLabel_Bague.snp.makeConstraints { make in
            make.leading.equalTo(commentIconView_Bague.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        commentsStack_Bague.snp.makeConstraints { make in
            make.top.equalTo(commentHeaderRow_Bague.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-30)
        }
        noCommentsView_Bague.snp.makeConstraints { make in
            make.top.equalTo(commentHeaderRow_Bague.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
        }
        noCommentsIcon_Bague.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(36)
        }
        noCommentsLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(noCommentsIcon_Bague.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        inputContainer_Bague.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-4)
            make.height.equalTo(68)
        }
        inputBg_Bague.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
        }
        sendCommentBtn_Bague.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-6)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        giftBtn_Bague.snp.makeConstraints { make in
            make.trailing.equalTo(sendCommentBtn_Bague.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        commentField_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(giftBtn_Bague.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 渐变

    /// 发送按钮：玫瑰粉 → 珊瑚橙（辅助色，与发布/聊天页统一）
    private func updateGradients_Bague() {
        sendBtnGradient_Bague?.removeFromSuperlayer()
        let grad_bague = CAGradientLayer()
        grad_bague.frame = sendCommentBtn_Bague.bounds
        grad_bague.colors = [
            UIColor(hexstring_Bague: "#F07DAD").cgColor,
            UIColor(hexstring_Bague: "#FFA07A").cgColor
        ]
        grad_bague.startPoint = CGPoint(x: 0, y: 0)
        grad_bague.endPoint = CGPoint(x: 1, y: 1)
        grad_bague.cornerRadius = 18
        sendCommentBtn_Bague.layer.insertSublayer(grad_bague, at: 0)
        sendBtnGradient_Bague = grad_bague
    }

    // MARK: - 数据绑定

    private func setupBindings_Bague() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dataChanged_Bague),
            name: TitleViewModel_Bague.titleStateDidChangeNotification_Bague,
            object: nil
        )
    }

    @objc private func dataChanged_Bague() {
        if let post_bague = titleModel_Bague {
            let posts_bague = TitleViewModel_Bague.shared_Bague.getPosts_Bague()
            titleModel_Bague = posts_bague.first { $0.titleId_Bague == post_bague.titleId_Bague } ?? post_bague
        }
        loadData_Bague()
    }

    // MARK: - 数据加载

    private func loadData_Bague() {
        guard let post_bague = titleModel_Bague else { return }

        let mediaPath_bague = post_bague.titleMeidas_Bague.first ?? ""
        mediaDisplayView_Bague.configure_Bague(mediaPath_Bague: mediaPath_bague)

        let author_bague = UserViewModel_Bague.shared_Bague.getUserById_Bague(userId_bague: post_bague.titleUserId_Bague)
        authorAvatar_Bague.configure_Bague(userId_Bague: post_bague.titleUserId_Bague)
        authorNameLabel_Bague.text = post_bague.titleUserName_Bague
        authorBioLabel_Bague.text = author_bague.userIntroduce_Bague ?? "Bag enthusiast"

        updateLikesButton_Bague(post_bague: post_bague)

        titleLabel_Bague.text = post_bague.title_Bague
        bodyLabel_Bague.text = post_bague.titleContent_Bague

        // 举报/删除按钮（仅创建一次）
        if postActionBtn_Bague == nil {
            let btn_bague = ReportDeleteHelper_Bague.createPostReportButton_Bague(
                post_Bague: post_bague,
                size_Bague: 16,
                color_Bague: .white,
                from: self,
                completion_Bague: { [weak self] in
                    Navigation_Bague.pop_Bague(from: self)
                }
            )
            btn_bague.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            btn_bague.layer.cornerRadius = 18
            btn_bague.layer.borderWidth = 1
            btn_bague.layer.borderColor = UIColor.white.withAlphaComponent(0.25).cgColor
            contentView_Bague.addSubview(btn_bague)
            btn_bague.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(14)
                make.trailing.equalToSuperview().offset(-16)
                make.width.height.equalTo(36)
            }
            postActionBtn_Bague = btn_bague
        }

        refreshComments_Bague(post_bague: post_bague)
    }

    private func updateLikesButton_Bague(post_bague: TitleModel_Bague) {
        let isLiked_bague = TitleViewModel_Bague.shared_Bague.isLikedPost_Bague(post_bague: post_bague)

        likesBtnGradient_Bague?.removeFromSuperlayer()

        if isLiked_bague {
            // 已点赞：玫瑰粉→珊瑚橙渐变
            let grad_bague = CAGradientLayer()
            grad_bague.frame = likesBtn_Bague.bounds.isEmpty
                ? CGRect(x: 0, y: 0, width: 80, height: 36) : likesBtn_Bague.bounds
            grad_bague.colors = [
                UIColor(hexstring_Bague: "#F07DAD").cgColor,
                UIColor(hexstring_Bague: "#FFA07A").cgColor
            ]
            grad_bague.startPoint = CGPoint(x: 0, y: 0)
            grad_bague.endPoint = CGPoint(x: 1, y: 0)
            grad_bague.cornerRadius = 16
            likesBtn_Bague.layer.insertSublayer(grad_bague, at: 0)
            likesBtnGradient_Bague = grad_bague
            likesBtn_Bague.setTitle("♥ \(post_bague.likes_Bague)", for: .normal)
            likesBtn_Bague.setTitleColor(.white, for: .normal)
            likesBtn_Bague.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
            likesBtn_Bague.backgroundColor = .clear
        } else {
            likesBtn_Bague.backgroundColor = UIColor(hexstring_Bague: "#F5F0FF")
            likesBtn_Bague.setTitle("♡ \(post_bague.likes_Bague)", for: .normal)
            likesBtn_Bague.setTitleColor(UIColor(hexstring_Bague: "#9B72F5"), for: .normal)
            likesBtn_Bague.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
    }

    private func refreshComments_Bague(post_bague: TitleModel_Bague) {
        commentsStack_Bague.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let userList_bague = LocalData_Bague.shared_Bague.userList_Bague
        let currentUserId_bague = UserViewModel_Bague.shared_Bague.getCurrentUser_Bague().userId_Bague ?? 0

        // userList 为空说明数据未初始化，直接显示全部评论；
        // 非空时才过滤：仅保留仍在用户列表中的评论 + 当前登录用户自己的评论
        let visibleComments_bague: [Comment_Bague]
        if userList_bague.isEmpty {
            visibleComments_bague = post_bague.reviews_Bague
        } else {
            let validIds_bague = Set(userList_bague.compactMap { $0.userId_Bague })
            visibleComments_bague = post_bague.reviews_Bague.filter { comment in
                validIds_bague.contains(comment.commentUserId_Bague)
                || comment.commentUserId_Bague == currentUserId_bague
            }
        }

        if visibleComments_bague.isEmpty {
            noCommentsView_Bague.isHidden = false
        } else {
            noCommentsView_Bague.isHidden = true
            visibleComments_bague.enumerated().forEach { idx, comment in
                let cell_bague = CommentCellView_Bague(
                    comment_bague: comment,
                    post_bague: post_bague,
                    viewController_bague: self
                )
                commentsStack_Bague.addArrangedSubview(cell_bague)
                cell_bague.alpha = 0
                UIView.animate(withDuration: 0.25, delay: Double(idx) * 0.03) {
                    cell_bague.alpha = 1
                }
            }
        }
    }

    // MARK: - 键盘管理

    private func setupKeyboardObservers_Bague() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Bague(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Bague(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow_Bague(_ notification: Notification) {
        guard let frame_bague = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_bague = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration_bague) {
            self.inputContainer_Bague.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
                    .offset(-(frame_bague.height - self.view.safeAreaInsets.bottom + 4))
            }
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide_Bague(_ notification: Notification) {
        guard let duration_bague = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        UIView.animate(withDuration: duration_bague) {
            self.inputContainer_Bague.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-4)
            }
            self.view.layoutIfNeeded()
        }
    }

    @objc private func dismissKeyboard_Bague() { view.endEditing(true) }

    // MARK: - 事件处理

    @objc private func backTapped_Bague() { Navigation_Bague.pop_Bague() }

    @objc private func authorTapped_Bague() {
        guard let post_bague = titleModel_Bague else { return }
        let user_bague = UserViewModel_Bague.shared_Bague.getUserById_Bague(userId_bague: post_bague.titleUserId_Bague)
        Navigation_Bague.toUserInfo_Bague(with: user_bague)
    }

    @objc private func likesBtnDown_Bague() { likesBtn_Bague.animatePressDown_Bague() }
    @objc private func likesBtnUp_Bague() { likesBtn_Bague.animatePressUp_Bague() }

    @objc private func likesTapped_Bague() {
        guard let post_bague = titleModel_Bague else { return }
        Task { @MainActor in
            TitleViewModel_Bague.shared_Bague.likePost_Bague(post_bague: post_bague)
        }
    }

    @objc private func sendComment_Bague() {
        guard let post_bague = titleModel_Bague,
              let text_bague = commentField_Bague.text, !text_bague.isEmpty else {
            commentField_Bague.animateShake_Bague()
            return
        }
        commentField_Bague.text = ""
        view.endEditing(true)
        sendCommentBtn_Bague.animatePulse_Bague()
        Task { @MainActor in
            TitleViewModel_Bague.shared_Bague.releaseComment_Bague(
                post_bague: post_bague,
                content_bague: text_bague
            )
        }
    }

    /// 点击送礼按钮，以全屏透明模态方式展示 GiftPage_Bague
    @objc private func giftBtnTapped_Bague() {
        let giftPage_bague = GiftPage_Bague()
        giftPage_bague.modalPresentationStyle = .overFullScreen
        giftPage_bague.modalTransitionStyle = .crossDissolve
        present(giftPage_bague, animated: true)
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UITextFieldDelegate

extension Detail_Bague: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment_Bague()
        return true
    }
}

// MARK: - 评论单元格视图

/// 单条评论视图
/// 设计：浅紫色背景卡片 `#EDE8FF`，头像 + 姓名 + 内容，带举报按钮
class CommentCellView_Bague: UIView {

    private let comment_Bague: Comment_Bague
    private let post_Bague: TitleModel_Bague
    private weak var vc_Bague: UIViewController?

    private let cardView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hexstring_Bague: "#EDE8FF")
        v.layer.cornerRadius = 16
        return v
    }()

    private let avatarView_Bague = UserAvatarView_Bague()

    private let nameLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(hexstring_Bague: "#4A3080")
        return label
    }()

    private let commentLabel_Bague: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(hexstring_Bague: "#5A4090")
        label.numberOfLines = 0
        return label
    }()

    private var reportBtn_Bague: UIButton?

    init(comment_bague: Comment_Bague, post_bague: TitleModel_Bague, viewController_bague: UIViewController) {
        self.comment_Bague = comment_bague
        self.post_Bague = post_bague
        self.vc_Bague = viewController_bague
        super.init(frame: .zero)
        setupUI_Bague()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI_Bague() {
        addSubview(cardView_Bague)
        cardView_Bague.addSubview(avatarView_Bague)
        cardView_Bague.addSubview(nameLabel_Bague)
        cardView_Bague.addSubview(commentLabel_Bague)

        avatarView_Bague.configure_Bague(userId_Bague: comment_Bague.commentUserId_Bague)
        nameLabel_Bague.text = comment_Bague.commentUserName_Bague
        commentLabel_Bague.text = comment_Bague.commentContent_Bague

        if let vc_bague = vc_Bague {
            let btn_bague = ReportDeleteHelper_Bague.createCommentReportButton_Bague(
                comment_Bague: comment_Bague,
                post_Bague: post_Bague,
                size_Bague: 13,
                color_Bague: UIColor(hexstring_Bague: "#9B72F5").withAlphaComponent(0.5),
                from: vc_bague
            )
            cardView_Bague.addSubview(btn_bague)
            btn_bague.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.width.height.equalTo(24)
            }
            reportBtn_Bague = btn_bague
        }

        cardView_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
        avatarView_Bague.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(34)
        }
        nameLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Bague)
            make.leading.equalTo(avatarView_Bague.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-40)
        }
        commentLabel_Bague.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Bague.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel_Bague)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}
