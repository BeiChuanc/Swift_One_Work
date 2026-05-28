import UIKit
import SnapKit

// MARK: 四季专题详情页

/// 四季专题详情页
/// 功能：展示官方四季专题的标题、描述、用户讨论评论列表，支持发布评论和举报/删除评论
/// 设计：季节色渐变 Header + 可滚动评论区 + 底部评论输入框
class TopicDetail_Ornit: UIViewController {

    // MARK: - 公共属性

    /// 目标专题数据（由导航传入）
    var topic_Ornit: SeasonalTopic_Ornit?

    // MARK: - 私有属性

    /// 当前专题在 LocalData 中的索引（用于实时刷新）
    private var topicIndex_Ornit: Int {
        guard let id_ornit = topic_Ornit?.topicId_Ornit else { return -1 }
        return LocalData_Ornit.shared_Ornit.seasonalTopics_Ornit.firstIndex {
            $0.topicId_Ornit == id_ornit
        } ?? -1
    }

    /// 当前专题最新数据
    private var currentTopic_Ornit: SeasonalTopic_Ornit? {
        guard topicIndex_Ornit >= 0 else { return topic_Ornit }
        return LocalData_Ornit.shared_Ornit.seasonalTopics_Ornit[topicIndex_Ornit]
    }

    // MARK: - UI 组件

    private let scrollView_Ornit = UIScrollView()
    private let contentView_Ornit = UIView()

    /// Header 渐变视图
    private let headerView_Ornit = UIView()
    private var headerGradient_Ornit: CAGradientLayer?

    /// 评论列表容器
    private let commentsStack_Ornit: UIStackView = {
        let sv_ornit = UIStackView()
        sv_ornit.axis = .vertical
        sv_ornit.spacing = 12
        return sv_ornit
    }()

    /// 无评论空状态标签
    private let noCommentLabel_Ornit: UILabel = {
        let label_ornit = UILabel()
        label_ornit.text = "Be the first to join the discussion!"
        label_ornit.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label_ornit.textColor = ColorConfig_Ornit.textPlaceholder_Ornit
        label_ornit.textAlignment = .center
        label_ornit.isHidden = true
        return label_ornit
    }()

    /// 底部评论输入容器
    private let inputContainer_Ornit = UIView()

    /// 评论输入框
    private let commentField_Ornit: UITextField = {
        let tf_ornit = UITextField()
        tf_ornit.placeholder = "Join the discussion..."
        tf_ornit.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        tf_ornit.backgroundColor = ColorConfig_Ornit.backgroundPrimary_Ornit
        tf_ornit.layer.cornerRadius = 20
        tf_ornit.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 0))
        tf_ornit.leftViewMode = .always
        tf_ornit.returnKeyType = .send
        return tf_ornit
    }()

    /// 发送按钮
    private let sendButton_Ornit: UIButton = {
        let btn_ornit = UIButton(type: .custom)
        let config_ornit = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        btn_ornit.setImage(
            UIImage(systemName: "arrow.up", withConfiguration: config_ornit),
            for: .normal
        )
        btn_ornit.tintColor = .white
        btn_ornit.layer.cornerRadius = 20
        return btn_ornit
    }()

    private var inputBottomConstraint_Ornit: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Ornit.backgroundPrimary_Ornit
        setupScrollView_Ornit()
        setupHeaderView_Ornit()
        setupCommentsSection_Ornit()
        setupInputBar_Ornit()
        setupNotifications_Ornit()
        refreshComments_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Ornit?.frame = headerView_Ornit.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 通知监听

    private func setupNotifications_Ornit() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Ornit(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Ornit(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow_Ornit(_ notification: Notification) {
        guard let frame_ornit = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let dur_ornit = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        UIView.animate(withDuration: dur_ornit) {
            self.inputBottomConstraint_Ornit?.update(offset: -frame_ornit.height + self.view.safeAreaInsets.bottom)
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide_Ornit(_ notification: Notification) {
        let dur_ornit = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        UIView.animate(withDuration: dur_ornit) {
            self.inputBottomConstraint_Ornit?.update(offset: 0)
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - 数据刷新

    /// 刷新评论列表
    private func refreshComments_Ornit() {
        commentsStack_Ornit.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let topic_ornit = currentTopic_Ornit else { return }

        // 过滤已被举报移除用户的评论
        let currentUid_ornit = UserViewModel_Ornit.shared_Ornit.getCurrentUser_Ornit().userId_Ornit ?? -1
        let activeIds_ornit = Set(LocalData_Ornit.shared_Ornit.userList_Ornit.compactMap { $0.userId_Ornit })
        let visible_ornit = topic_ornit.comments_Ornit.filter {
            $0.commentUserId_Ornit == currentUid_ornit || activeIds_ornit.contains($0.commentUserId_Ornit)
        }

        noCommentLabel_Ornit.isHidden = !visible_ornit.isEmpty

        for comment_ornit in visible_ornit {
            commentsStack_Ornit.addArrangedSubview(
                makeCommentCell_Ornit(comment_ornit: comment_ornit)
            )
        }
    }

    // MARK: - UI 搭建

    private func setupScrollView_Ornit() {
        scrollView_Ornit.showsVerticalScrollIndicator = false
        scrollView_Ornit.contentInsetAdjustmentBehavior = .never
        scrollView_Ornit.keyboardDismissMode = .interactive
        scrollView_Ornit.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
        view.addSubview(scrollView_Ornit)
        scrollView_Ornit.addSubview(contentView_Ornit)

        scrollView_Ornit.snp.makeConstraints { make_ornit in make_ornit.edges.equalToSuperview() }
        contentView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.edges.equalToSuperview()
            make_ornit.width.equalToSuperview()
        }
    }

    /// 构建专题渐变 Header（季节色 + 标题 + 描述 + 返回按钮）
    private func setupHeaderView_Ornit() {
        contentView_Ornit.addSubview(headerView_Ornit)

        // 季节渐变色
        let gradient_ornit = CAGradientLayer()
        if let topic_ornit = topic_Ornit {
            gradient_ornit.colors = [
                UIColor(hexstring_Ornit: topic_ornit.gradientStart_Ornit).cgColor,
                UIColor(hexstring_Ornit: topic_ornit.gradientEnd_Ornit).cgColor
            ]
        }
        gradient_ornit.startPoint = CGPoint(x: 0, y: 0)
        gradient_ornit.endPoint = CGPoint(x: 1, y: 1)
        headerView_Ornit.layer.insertSublayer(gradient_ornit, at: 0)
        headerGradient_Ornit = gradient_ornit
        headerView_Ornit.layer.cornerRadius = 24
        headerView_Ornit.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        headerView_Ornit.clipsToBounds = true

        // 装饰圆
        let deco_ornit = UIView()
        deco_ornit.backgroundColor = UIColor.white.withValues(alpha: 0.06)
        deco_ornit.layer.cornerRadius = 64
        headerView_Ornit.addSubview(deco_ornit)

        // 返回按钮
        let backView_ornit = BackButton_Ornit()
        backView_ornit.onTapped_Ornit = { [weak self] in Navigation_Ornit.pop_Ornit(from: self) }
        headerView_Ornit.addSubview(backView_ornit)

        // 季节标签
        let seasonLabel_ornit = UILabel()
        seasonLabel_ornit.text = topic_Ornit?.season_Ornit.uppercased()
        seasonLabel_ornit.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        seasonLabel_ornit.textColor = UIColor.white.withValues(alpha: 0.7)
        headerView_Ornit.addSubview(seasonLabel_ornit)

        // 标题
        let titleLabel_ornit = UILabel()
        titleLabel_ornit.text = topic_Ornit?.title_Ornit
        titleLabel_ornit.font = UIFont.systemFont(ofSize: 20, weight: .black)
        titleLabel_ornit.textColor = .white
        titleLabel_ornit.numberOfLines = 2
        headerView_Ornit.addSubview(titleLabel_ornit)

        // 描述
        let descLabel_ornit = UILabel()
        descLabel_ornit.text = topic_Ornit?.topicDescription_Ornit
        descLabel_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        descLabel_ornit.textColor = UIColor.white.withValues(alpha: 0.82)
        descLabel_ornit.numberOfLines = 3
        headerView_Ornit.addSubview(descLabel_ornit)

        // 装饰图标
        let iconConfig_ornit = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin)
        let iconView_ornit = UIImageView(
            image: UIImage(systemName: topic_Ornit?.iconName_Ornit ?? "leaf.fill", withConfiguration: iconConfig_ornit)
        )
        iconView_ornit.tintColor = UIColor.white.withValues(alpha: 0.18)
        headerView_Ornit.addSubview(iconView_ornit)

        headerView_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(240)
        }

        deco_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(40)
            make_ornit.top.equalToSuperview().offset(-20)
            make_ornit.width.height.equalTo(128)
        }

        backView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.top.equalToSuperview().offset(54)
            make_ornit.width.height.equalTo(38)
        }

        seasonLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(22)
            make_ornit.top.equalTo(backView_ornit.snp.bottom).offset(14)
        }

        titleLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(22)
            make_ornit.top.equalTo(seasonLabel_ornit.snp.bottom).offset(4)
            make_ornit.trailing.equalToSuperview().offset(-70)
        }

        descLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(22)
            make_ornit.trailing.equalToSuperview().offset(-22)
            make_ornit.top.equalTo(titleLabel_ornit.snp.bottom).offset(8)
        }

        iconView_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-18)
            make_ornit.centerY.equalTo(titleLabel_ornit)
            make_ornit.width.height.equalTo(52)
        }
    }

    /// 构建评论区（区段标题 + 评论列表 + 空状态）
    private func setupCommentsSection_Ornit() {
        let sectionLabel_ornit = UILabel()
        sectionLabel_ornit.text = "Discussion"
        sectionLabel_ornit.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        sectionLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        contentView_Ornit.addSubview(sectionLabel_ornit)

        contentView_Ornit.addSubview(commentsStack_Ornit)
        contentView_Ornit.addSubview(noCommentLabel_Ornit)

        sectionLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(headerView_Ornit.snp.bottom).offset(20)
            make_ornit.leading.equalToSuperview().offset(20)
        }

        commentsStack_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(sectionLabel_ornit.snp.bottom).offset(14)
            make_ornit.leading.equalToSuperview().offset(16)
            make_ornit.trailing.equalToSuperview().offset(-16)
            make_ornit.bottom.equalToSuperview().offset(-20)
        }

        noCommentLabel_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(sectionLabel_ornit.snp.bottom).offset(30)
            make_ornit.centerX.equalToSuperview()
        }

        // 点击空白收起键盘
        let tap_ornit = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Ornit))
        tap_ornit.cancelsTouchesInView = false
        scrollView_Ornit.addGestureRecognizer(tap_ornit)
    }

    /// 构建底部评论输入栏
    private func setupInputBar_Ornit() {
        inputContainer_Ornit.backgroundColor = .white
        inputContainer_Ornit.layer.shadowColor = UIColor.black.withValues(alpha: 0.05).cgColor
        inputContainer_Ornit.layer.shadowOffset = CGSize(width: 0, height: -2)
        inputContainer_Ornit.layer.shadowOpacity = 1
        inputContainer_Ornit.layer.shadowRadius = 6
        view.addSubview(inputContainer_Ornit)

        let topLine_ornit = UIView()
        topLine_ornit.backgroundColor = ColorConfig_Ornit.divider_Ornit
        inputContainer_Ornit.addSubview(topLine_ornit)

        // 发送按钮颜色：使用专题的渐变起始色
        if let start_ornit = topic_Ornit?.gradientStart_Ornit {
            sendButton_Ornit.backgroundColor = UIColor(hexstring_Ornit: start_ornit)
        } else {
            sendButton_Ornit.backgroundColor = ColorConfig_Ornit.naturePrimary_Ornit
        }

        inputContainer_Ornit.addSubview(commentField_Ornit)
        inputContainer_Ornit.addSubview(sendButton_Ornit)

        inputContainer_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(62)
            inputBottomConstraint_Ornit = make_ornit.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).constraint
        }

        topLine_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.leading.trailing.equalToSuperview()
            make_ornit.height.equalTo(0.5)
        }

        sendButton_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-14)
            make_ornit.centerY.equalToSuperview()
            make_ornit.width.height.equalTo(40)
        }

        commentField_Ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(14)
            make_ornit.trailing.equalTo(sendButton_Ornit.snp.leading).offset(-10)
            make_ornit.centerY.equalToSuperview()
            make_ornit.height.equalTo(40)
        }

        commentField_Ornit.delegate = self
        sendButton_Ornit.addTarget(self, action: #selector(sendCommentTapped_Ornit), for: .touchUpInside)
    }

    // MARK: - 辅助方法

    /// 创建单条评论卡片（头像 + 昵称 + 内容 + 举报/删除按钮）
    private func makeCommentCell_Ornit(comment_ornit: Comment_Ornit) -> UIView {
        let card_ornit = UIView()
        card_ornit.backgroundColor = .white
        card_ornit.layer.cornerRadius = 14
        card_ornit.layer.shadowColor = UIColor.black.withValues(alpha: 0.06).cgColor
        card_ornit.layer.shadowOffset = CGSize(width: 0, height: 2)
        card_ornit.layer.shadowOpacity = 1
        card_ornit.layer.shadowRadius = 5

        let avatar_ornit = UserAvatarView_Ornit()
        avatar_ornit.configure_Ornit(userId_Ornit: comment_ornit.commentUserId_Ornit)
        card_ornit.addSubview(avatar_ornit)

        let nameLabel_ornit = UILabel()
        nameLabel_ornit.text = comment_ornit.commentUserName_Ornit
        nameLabel_ornit.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        nameLabel_ornit.textColor = ColorConfig_Ornit.textPrimary_Ornit
        card_ornit.addSubview(nameLabel_ornit)

        let contentLabel_ornit = UILabel()
        contentLabel_ornit.text = comment_ornit.commentContent_Ornit
        contentLabel_ornit.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        contentLabel_ornit.textColor = ColorConfig_Ornit.textSecondary_Ornit
        contentLabel_ornit.numberOfLines = 0
        card_ornit.addSubview(contentLabel_ornit)

        // 举报/删除按钮
        let currentUid_ornit = UserViewModel_Ornit.shared_Ornit.getCurrentUser_Ornit().userId_Ornit ?? -1
        let isMyComment_ornit = comment_ornit.commentUserId_Ornit == currentUid_ornit

        let actionBtn_ornit = UIButton(type: .system)
        let iconSize_ornit: CGFloat = 13
        let btnConfig_ornit = UIImage.SymbolConfiguration(pointSize: iconSize_ornit, weight: .semibold)
        let iconName_ornit = isMyComment_ornit ? "trash" : "ellipsis"
        actionBtn_ornit.setImage(UIImage(systemName: iconName_ornit, withConfiguration: btnConfig_ornit), for: .normal)
        actionBtn_ornit.tintColor = ColorConfig_Ornit.textPlaceholder_Ornit
        card_ornit.addSubview(actionBtn_ornit)

        let commentId_ornit = comment_ornit.commentId_Ornit
        let topicId_ornit = topic_Ornit?.topicId_Ornit ?? -1

        actionBtn_ornit.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            if isMyComment_ornit {
                self.deleteTopicComment_Ornit(commentId_ornit: commentId_ornit, topicId_ornit: topicId_ornit)
            } else {
                self.reportTopicComment_Ornit(commentId_ornit: commentId_ornit, topicId_ornit: topicId_ornit)
            }
        }, for: .touchUpInside)

        avatar_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalToSuperview().offset(12)
            make_ornit.top.equalToSuperview().offset(12)
            make_ornit.width.height.equalTo(32)
        }
        nameLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.leading.equalTo(avatar_ornit.snp.trailing).offset(8)
            make_ornit.centerY.equalTo(avatar_ornit)
            make_ornit.trailing.equalTo(actionBtn_ornit.snp.leading).offset(-4)
        }
        actionBtn_ornit.snp.makeConstraints { make_ornit in
            make_ornit.trailing.equalToSuperview().offset(-10)
            make_ornit.top.equalToSuperview().offset(10)
            make_ornit.width.height.equalTo(24)
        }
        contentLabel_ornit.snp.makeConstraints { make_ornit in
            make_ornit.top.equalTo(avatar_ornit.snp.bottom).offset(8)
            make_ornit.leading.equalToSuperview().offset(12)
            make_ornit.trailing.equalToSuperview().offset(-12)
            make_ornit.bottom.equalToSuperview().offset(-12)
        }

        return card_ornit
    }

    /// 删除自己的评论（弹确认弹窗）
    private func deleteTopicComment_Ornit(commentId_ornit: Int, topicId_ornit: Int) {
        let alert_ornit = UIAlertController(
            title: "Delete Comment",
            message: "Are you sure you want to delete this comment? This action cannot be undone.",
            preferredStyle: .alert
        )
        alert_ornit.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            LocalData_Ornit.shared_Ornit.deleteTopicComment_Ornit(
                topicId_ornit: topicId_ornit,
                commentId_ornit: commentId_ornit
            )
            self?.refreshComments_Ornit()
        })
        alert_ornit.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_ornit, animated: true)
    }

    /// 举报他人评论（直接在当前 VC 弹 ActionSheet，不依赖 currentViewController 查找）
    private func reportTopicComment_Ornit(commentId_ornit: Int, topicId_ornit: Int) {
        let sheet_ornit = UIAlertController(
            title: "Report Comment",
            message: "Why are you reporting this comment?",
            preferredStyle: .actionSheet
        )
        let action_ornit: (UIAlertAction) -> Void = { [weak self] _ in
            LocalData_Ornit.shared_Ornit.deleteTopicComment_Ornit(
                topicId_ornit: topicId_ornit,
                commentId_ornit: commentId_ornit
            )
            self?.refreshComments_Ornit()
        }
        sheet_ornit.addAction(UIAlertAction(title: "Report Sexually Explicit Material", style: .default, handler: action_ornit))
        sheet_ornit.addAction(UIAlertAction(title: "Report Spam", style: .default, handler: action_ornit))
        sheet_ornit.addAction(UIAlertAction(title: "Report Something Else", style: .default, handler: action_ornit))
        sheet_ornit.addAction(UIAlertAction(title: "Report", style: .destructive, handler: action_ornit))
        sheet_ornit.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet_ornit, animated: true)
    }

    // MARK: - 事件处理

    @objc private func sendCommentTapped_Ornit() {
        guard let text_ornit = commentField_Ornit.text?.trimmingCharacters(in: .whitespaces),
              !text_ornit.isEmpty else { return }

        guard UserViewModel_Ornit.shared_Ornit.isLoggedIn_Ornit else {
            Navigation_Ornit.toLogin_Ornit()
            return
        }

        let user_ornit = UserViewModel_Ornit.shared_Ornit.getCurrentUser_Ornit()
        let allComments_ornit = currentTopic_Ornit?.comments_Ornit ?? []
        let newId_ornit = (allComments_ornit.map { $0.commentId_Ornit }.max() ?? 0) + 1

        let comment_ornit = Comment_Ornit(
            commentId_Ornit: newId_ornit,
            commentUserId_Ornit: user_ornit.userId_Ornit ?? 0,
            commentUserName_Ornit: user_ornit.userName_Ornit ?? "User",
            commentContent_Ornit: text_ornit
        )

        LocalData_Ornit.shared_Ornit.addTopicComment_Ornit(
            topicId_ornit: topic_Ornit?.topicId_Ornit ?? -1,
            comment_ornit: comment_ornit
        )

        commentField_Ornit.text = ""
        view.endEditing(true)
        refreshComments_Ornit()

        // 滚动到底部
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            let bottom_ornit = self.scrollView_Ornit.contentSize.height - self.scrollView_Ornit.bounds.height
            if bottom_ornit > 0 {
                self.scrollView_Ornit.setContentOffset(CGPoint(x: 0, y: bottom_ornit), animated: true)
            }
        }
    }

    @objc private func dismissKeyboard_Ornit() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate

extension TopicDetail_Ornit: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendCommentTapped_Ornit()
        return true
    }
}
