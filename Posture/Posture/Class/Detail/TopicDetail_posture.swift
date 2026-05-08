import Foundation
import UIKit
import SnapKit

// MARK: 话题详情页

/// 话题详情控制器
/// 核心作用：展示单个话题的标题、描述、参与人数，并提供评论列表与发评输入框。
/// 设计思路：使用自定义顶部导航栏，完全脱离系统 Navigation Bar 状态机干扰。
///          UI 只负责布局与事件转发，数据读写均通过 TitleViewModel_Posture 完成。
/// 关键属性：topic_Posture 由外部注入，commentsStack_Posture 动态渲染评论列表。
/// 关键方法：reloadComments_Posture() 刷新评论，sendComment_Posture() 发布新评论。
@MainActor
class TopicDetail_Posture: UIViewController {

    // MARK: - 外部注入

    /// 当前话题（由 Navigation_Posture.toTopicDetail_Posture 传入）
    var topic_Posture: Topic_Posture?

    // MARK: - UI 组件

    /// 自定义顶部导航栏
    private let customNavBar_Posture = UIView()

    /// 导航栏标题
    private let navTitleLabel_Posture = UILabel()

    /// 滚动容器
    private let scrollView_Posture = UIScrollView()

    /// 内容容器
    private let contentView_Posture = UIView()

    /// 话题头部卡片
    private let headerCard_Posture = UIView()

    /// 话题图标
    private let iconView_Posture = UIImageView()

    /// 话题标题
    private let titleLabel_Posture = UILabel()

    /// 话题描述
    private let descLabel_Posture = UILabel()

    /// 评论区分割标题
    private let commentSectionLabel_Posture = UILabel()

    /// 评论列表容器
    private let commentsStack_Posture = UIStackView()

    /// 底部评论输入栏背景
    private let inputBar_Posture = UIView()

    /// 评论输入框
    private let inputField_Posture = UITextField()

    /// 发送按钮
    private let sendButton_Posture = UIButton(type: .system)

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavBar_Posture()
        setupUI_Posture()
        setupInputBar_Posture()
        observeTopicState_Posture()
        reloadComments_Posture()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 自定义导航栏

    /// 搭建自定义顶部导航栏（背景 + 返回按钮 + 标题）
    private func setupCustomNavBar_Posture() {
        // 与页面背景色保持一致，去除阴影避免割裂感
        customNavBar_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        view.addSubview(customNavBar_Posture)

        customNavBar_Posture.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }

        // 返回按钮
        let backBtn_Posture = UIButton(type: .system)
        let backConfig_Posture = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        backBtn_Posture.setImage(UIImage(systemName: "chevron.left", withConfiguration: backConfig_Posture), for: .normal)
        backBtn_Posture.tintColor = ColorConfig_Posture.textPrimary_Posture
        backBtn_Posture.addAction(UIAction { _ in Navigation_Posture.pop_Posture() }, for: .touchUpInside)
        customNavBar_Posture.addSubview(backBtn_Posture)

        backBtn_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }

        // 标题
        navTitleLabel_Posture.text = topic_Posture?.topicTitle_Posture ?? "Topic"
        navTitleLabel_Posture.font = .systemFont(ofSize: 17, weight: .bold)
        navTitleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        navTitleLabel_Posture.textAlignment = .center
        customNavBar_Posture.addSubview(navTitleLabel_Posture)

        navTitleLabel_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualTo(backBtn_Posture.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualToSuperview().inset(60)
        }
    }

    // MARK: - UI 搭建

    /// 搭建主体 UI（ScrollView + 头部卡片 + 评论列表）
    private func setupUI_Posture() {
        view.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture

        scrollView_Posture.showsVerticalScrollIndicator = false
        view.addSubview(scrollView_Posture)
        scrollView_Posture.addSubview(contentView_Posture)

        scrollView_Posture.snp.makeConstraints { make in
            make.top.equalTo(customNavBar_Posture.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(70)
        }

        contentView_Posture.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Posture.contentLayoutGuide)
            make.width.equalTo(scrollView_Posture.frameLayoutGuide)
        }

        // 话题头部卡片
        buildHeaderCard_Posture()
        contentView_Posture.addSubview(headerCard_Posture)

        headerCard_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
        }

        // 评论区标题
        commentSectionLabel_Posture.text = "Community Voices"
        commentSectionLabel_Posture.font = .systemFont(ofSize: 17, weight: .bold)
        commentSectionLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        contentView_Posture.addSubview(commentSectionLabel_Posture)

        commentSectionLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Posture.snp.bottom).offset(22)
            make.leading.equalToSuperview().offset(20)
        }

        // 评论列表栈
        commentsStack_Posture.axis = .vertical
        commentsStack_Posture.spacing = 12
        contentView_Posture.addSubview(commentsStack_Posture)

        commentsStack_Posture.snp.makeConstraints { make in
            make.top.equalTo(commentSectionLabel_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    /// 构建话题头部卡片
    private func buildHeaderCard_Posture() {
        guard let topic_posture = topic_Posture else { return }

        headerCard_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        headerCard_Posture.layer.cornerRadius = 24
        headerCard_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        headerCard_Posture.layer.shadowOpacity = 1
        headerCard_Posture.layer.shadowRadius = 14
        headerCard_Posture.layer.shadowOffset = CGSize(width: 0, height: 6)

        // 图标背景
        let iconBg_Posture = UIView()
        iconBg_Posture.backgroundColor = ColorConfig_Posture.primaryLight_Posture
        iconBg_Posture.layer.cornerRadius = 24
        iconView_Posture.image = UIImage(systemName: topic_posture.topicIcon_Posture)
        iconView_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        iconView_Posture.contentMode = .scaleAspectFit
        iconBg_Posture.addSubview(iconView_Posture)
        iconView_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(26)
        }

        titleLabel_Posture.text = topic_posture.topicTitle_Posture
        titleLabel_Posture.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        titleLabel_Posture.numberOfLines = 2

        descLabel_Posture.text = topic_posture.topicDesc_Posture
        descLabel_Posture.font = .systemFont(ofSize: 14, weight: .regular)
        descLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        descLabel_Posture.numberOfLines = 3

        // 参与人数徽章
        let memberBadge_Posture = makeMemberBadge_Posture(count_posture: topic_posture.memberCount_Posture)

        headerCard_Posture.addSubview(iconBg_Posture)
        headerCard_Posture.addSubview(titleLabel_Posture)
        headerCard_Posture.addSubview(descLabel_Posture)
        headerCard_Posture.addSubview(memberBadge_Posture)

        iconBg_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(48)
        }

        titleLabel_Posture.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalTo(iconBg_Posture.snp.trailing).offset(14)
            make.trailing.equalToSuperview().inset(20)
        }

        descLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(iconBg_Posture.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        memberBadge_Posture.snp.makeConstraints { make in
            make.top.equalTo(descLabel_Posture.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(28)
        }
    }

    /// 创建参与人数徽章视图
    /// - Parameter count_posture: 参与人数
    /// - Returns: UIView
    private func makeMemberBadge_Posture(count_posture: Int) -> UIView {
        let badge_Posture = UIView()
        badge_Posture.backgroundColor = ColorConfig_Posture.accentIndigoLight_Posture
        badge_Posture.layer.cornerRadius = 14

        let iconIV_Posture = UIImageView(image: UIImage(systemName: "person.2.fill"))
        iconIV_Posture.tintColor = ColorConfig_Posture.accentIndigo_Posture
        iconIV_Posture.contentMode = .scaleAspectFit

        let label_Posture = UILabel()
        let formatted_posture = count_posture >= 1000
            ? String(format: "%.1fk members", Double(count_posture) / 1000)
            : "\(count_posture) members"
        label_Posture.text = formatted_posture
        label_Posture.font = .systemFont(ofSize: 12, weight: .semibold)
        label_Posture.textColor = ColorConfig_Posture.accentIndigo_Posture

        badge_Posture.addSubview(iconIV_Posture)
        badge_Posture.addSubview(label_Posture)

        iconIV_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        label_Posture.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_Posture.snp.trailing).offset(6)
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
        }

        return badge_Posture
    }

    /// 搭建底部评论输入栏
    private func setupInputBar_Posture() {
        // 与页面背景色保持一致，去除上方阴影避免割裂感
        inputBar_Posture.backgroundColor = ColorConfig_Posture.backgroundPrimary_Posture
        view.addSubview(inputBar_Posture)

        inputBar_Posture.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(70)
        }

        // 输入框容器
        let inputContainer_Posture = UIView()
        inputContainer_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        inputContainer_Posture.layer.cornerRadius = 20
        inputContainer_Posture.layer.borderWidth = 1
        inputContainer_Posture.layer.borderColor = ColorConfig_Posture.divider_Posture.cgColor
        inputBar_Posture.addSubview(inputContainer_Posture)

        inputField_Posture.placeholder = "Share your experience..."
        inputField_Posture.font = .systemFont(ofSize: 14)
        inputField_Posture.textColor = ColorConfig_Posture.textPrimary_Posture
        inputContainer_Posture.addSubview(inputField_Posture)

        // 发送按钮
        let sendConfig_Posture = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        sendButton_Posture.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: sendConfig_Posture), for: .normal)
        sendButton_Posture.tintColor = ColorConfig_Posture.primaryGradientStart_Posture
        sendButton_Posture.addAction(UIAction { [weak self] _ in self?.sendComment_Posture() }, for: .touchUpInside)
        inputBar_Posture.addSubview(sendButton_Posture)

        inputContainer_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().inset(12)
            make.trailing.equalTo(sendButton_Posture.snp.leading).offset(-10)
        }

        inputField_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().inset(14)
            make.centerY.equalToSuperview()
        }

        sendButton_Posture.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
    }

    // MARK: - 数据刷新

    /// 监听话题状态变化通知
    private func observeTopicState_Posture() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTopicStateChange_Posture),
            name: TitleViewModel_Posture.topicStateDidChangeNotification_Posture,
            object: nil
        )
    }

    /// 响应话题状态通知，同步最新数据后刷新评论列表
    @objc private func handleTopicStateChange_Posture() {
        if let topicId_posture = topic_Posture?.topicId_Posture {
            topic_Posture = TitleViewModel_Posture.shared_Posture.getTopics_Posture()
                .first(where: { $0.topicId_Posture == topicId_posture })
        }
        reloadComments_Posture()
    }

    /// 清空并重新渲染所有评论卡片
    private func reloadComments_Posture() {
        commentsStack_Posture.arrangedSubviews.forEach {
            commentsStack_Posture.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        guard let comments_posture = topic_Posture?.comments_Posture, !comments_posture.isEmpty else {
            commentsStack_Posture.addArrangedSubview(makeEmptyCommentsView_Posture())
            return
        }

        for (idx_posture, comment_posture) in comments_posture.enumerated() {
            let card_posture = makeCommentCard_Posture(comment_posture: comment_posture)
            commentsStack_Posture.addArrangedSubview(card_posture)
            card_posture.animateSlideInFromBottom_Posture(delay_Posture: Double(idx_posture) * 0.04)
        }
    }

    // MARK: - 评论卡片构建

    /// 构建单条评论卡片（头像 + 昵称 + 内容 + 举报/删除按钮）
    /// - Parameter comment_posture: 评论模型
    /// - Returns: UIView
    private func makeCommentCard_Posture(comment_posture: Comment_Posture) -> UIView {
        guard let topicId_posture = topic_Posture?.topicId_Posture else { return UIView() }

        let card_Posture = UIView()
        card_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        card_Posture.layer.cornerRadius = 18
        card_Posture.layer.shadowColor = ColorConfig_Posture.shadowColor_Posture.cgColor
        card_Posture.layer.shadowOpacity = 1
        card_Posture.layer.shadowRadius = 10
        card_Posture.layer.shadowOffset = CGSize(width: 0, height: 4)

        // 头像
        let avatarView_Posture = UserAvatarView_Posture()
        avatarView_Posture.configure_Posture(userId_Posture: comment_posture.commentUserId_Posture)

        // 昵称
        let nameLabel_Posture = UILabel()
        nameLabel_Posture.text = comment_posture.commentUserName_Posture
        nameLabel_Posture.font = .systemFont(ofSize: 13, weight: .bold)
        nameLabel_Posture.textColor = ColorConfig_Posture.textPrimary_Posture

        // 评论内容
        let contentLabel_Posture = UILabel()
        contentLabel_Posture.text = comment_posture.commentContent_Posture
        contentLabel_Posture.font = .systemFont(ofSize: 14, weight: .regular)
        contentLabel_Posture.textColor = ColorConfig_Posture.textSecondary_Posture
        contentLabel_Posture.numberOfLines = 0

        // 举报/删除按钮（右上角）
        let reportBtn_Posture = ReportDeleteHelper_Posture.createTopicCommentReportButton_Posture(
            comment_Posture: comment_posture,
            topicId_Posture: topicId_posture,
            size_Posture: 16,
            color_Posture: ColorConfig_Posture.textSecondary_Posture,
            from: self
        )

        card_Posture.addSubview(avatarView_Posture)
        card_Posture.addSubview(nameLabel_Posture)
        card_Posture.addSubview(contentLabel_Posture)
        card_Posture.addSubview(reportBtn_Posture)

        avatarView_Posture.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(34)
        }

        nameLabel_Posture.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView_Posture)
            make.leading.equalTo(avatarView_Posture.snp.trailing).offset(10)
            make.trailing.equalTo(reportBtn_Posture.snp.leading).offset(-8)
        }

        reportBtn_Posture.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(14)
            make.width.height.equalTo(28)
        }

        contentLabel_Posture.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Posture.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }

        return card_Posture
    }

    /// 创建空评论占位视图
    private func makeEmptyCommentsView_Posture() -> UIView {
        let empty_Posture = UIView()
        empty_Posture.backgroundColor = ColorConfig_Posture.cardBackground_Posture
        empty_Posture.layer.cornerRadius = 18

        let label_Posture = UILabel()
        label_Posture.text = "No comments yet. Be the first to share!"
        label_Posture.font = .systemFont(ofSize: 14, weight: .medium)
        label_Posture.textColor = ColorConfig_Posture.textPlaceholder_Posture
        label_Posture.textAlignment = .center
        label_Posture.numberOfLines = 2
        empty_Posture.addSubview(label_Posture)

        empty_Posture.snp.makeConstraints { make in make.height.equalTo(80) }
        label_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        return empty_Posture
    }

    // MARK: - 事件处理

    /// 发布评论
    private func sendComment_Posture() {
        let text_posture = inputField_Posture.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text_posture.isEmpty else { return }
        guard let topicId_posture = topic_Posture?.topicId_Posture else { return }

        inputField_Posture.text = nil
        inputField_Posture.resignFirstResponder()
        sendButton_Posture.animatePulse_Posture()

        TitleViewModel_Posture.shared_Posture.addTopicComment_Posture(
            topicId_posture: topicId_posture,
            content_posture: text_posture
        )
    }
}
