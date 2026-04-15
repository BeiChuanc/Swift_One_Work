
import Foundation
import UIKit
import SnapKit

// MARK: 帖子展示详情页面

/// 帖子详情页
/// 核心作用：展示帖子完整内容、媒体和评论互动
/// 设计思路：使用表格分区承载帖子主体和评论列表，并在底部提供即时评论输入
class Detail_Epoch: UIViewController {

    var titleModel_Epoch: TitleModel_Epoch?

    /// 背景装饰
    private let backgroundDecorationView_Epoch = PageDecorationView_Epoch()

    /// 帖子表格
    private let tableView_Epoch: UITableView = {
        let tableView_Epoch = UITableView(frame: .zero, style: .insetGrouped)
        tableView_Epoch.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        tableView_Epoch.separatorStyle = .none
        tableView_Epoch.showsVerticalScrollIndicator = false
        tableView_Epoch.rowHeight = UITableView.automaticDimension
        tableView_Epoch.estimatedRowHeight = 120
        return tableView_Epoch
    }()

    /// 评论输入容器
    private let inputContainerView_Epoch: UIView = {
        let view_Epoch = UIView()
        view_Epoch.backgroundColor = ColorConfig_Epoch.backgroundSecondary_Epoch
        view_Epoch.layer.cornerRadius = 22
        view_Epoch.layer.borderWidth = 1
        view_Epoch.layer.borderColor = ColorConfig_Epoch.divider_Epoch.cgColor
        return view_Epoch
    }()

    /// 评论输入框
    private let commentTextField_Epoch: UITextField = {
        let textField_Epoch = UITextField()
        textField_Epoch.placeholder = "Write a comment"
        textField_Epoch.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        textField_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        textField_Epoch.returnKeyType = .send
        return textField_Epoch
    }()

    /// 发送按钮
    private let sendButton_Epoch = PrimaryActionButton_Epoch(title_Epoch: "Send")

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        reloadData_Epoch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Epoch()
        setupNavigation_Epoch()
        setupNotifications_Epoch()
        reloadData_Epoch()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 构建界面
    private func setupUI_Epoch() {
        view.backgroundColor = ColorConfig_Epoch.backgroundPrimary_Epoch
        title = "Post details"

        view.addSubview(backgroundDecorationView_Epoch)
        view.addSubview(tableView_Epoch)
        view.addSubview(inputContainerView_Epoch)
        inputContainerView_Epoch.addSubview(commentTextField_Epoch)
        inputContainerView_Epoch.addSubview(sendButton_Epoch)

        backgroundDecorationView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView_Epoch.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(inputContainerView_Epoch.snp.top).offset(-12)
        }

        inputContainerView_Epoch.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            make.height.equalTo(60)
        }

        commentTextField_Epoch.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.right.equalTo(sendButton_Epoch.snp.left).offset(-12)
        }

        sendButton_Epoch.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview().inset(6)
            make.width.equalTo(94)
        }

        sendButton_Epoch.addTarget(self, action: #selector(sendTapped_Epoch), for: .touchUpInside)
        commentTextField_Epoch.delegate = self

        tableView_Epoch.register(DetailContentCell_Epoch.self, forCellReuseIdentifier: "DetailContentCell_Epoch")
        tableView_Epoch.register(CommentCell_Epoch.self, forCellReuseIdentifier: "CommentCell_Epoch")
        tableView_Epoch.dataSource = self
        tableView_Epoch.delegate = self
        tableView_Epoch.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 0)
    }

    /// 配置导航按钮
    private func setupNavigation_Epoch() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Epoch)
        )
        navigationItem.leftBarButtonItem?.tintColor = ColorConfig_Epoch.textPrimary_Epoch
        navigationItem.rightBarButtonItem = makeRightActionItem_Epoch()
    }

    /// 注册通知
    private func setupNotifications_Epoch() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Epoch),
            name: TitleViewModel_Epoch.titleStateDidChangeNotification_Epoch,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Epoch),
            name: UserViewModel_Epoch.userStateDidChangeNotification_Epoch,
            object: nil
        )
    }

    /// 刷新详情数据
    private func reloadData_Epoch() {
        guard let titleId_epoch = titleModel_Epoch?.titleId_Epoch else { return }
        guard let refreshedPost_epoch = TitleViewModel_Epoch.shared_Epoch.getPost_Epoch(titleId_epoch: titleId_epoch) else {
            Navigation_Epoch.pop_Epoch()
            return
        }
        titleModel_Epoch = refreshedPost_epoch
        navigationItem.rightBarButtonItem = makeRightActionItem_Epoch()
        tableView_Epoch.reloadData()
    }

    /// 生成右上角按钮
    /// - Returns: 导航按钮
    private func makeRightActionItem_Epoch() -> UIBarButtonItem? {
        guard let titleModel_Epoch = titleModel_Epoch else { return nil }
        let button_epoch = ReportDeleteHelper_Epoch.createPostReportButton_Epoch(
            post_Epoch: titleModel_Epoch,
            size_Epoch: 18,
            color_Epoch: ColorConfig_Epoch.textPrimary_Epoch,
            from: self
        )
        return UIBarButtonItem(customView: button_epoch)
    }

    /// 发送评论
    private func submitComment_Epoch() {
        guard let titleModel_Epoch = titleModel_Epoch else { return }
        let commentText_epoch = commentTextField_Epoch.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !commentText_epoch.isEmpty else {
            Utils_Epoch.showWarning_Epoch(message_Epoch: "Comment cannot be empty.")
            return
        }
        TitleViewModel_Epoch.shared_Epoch.releaseComment_Epoch(post_epoch: titleModel_Epoch, content_epoch: commentText_epoch)
        commentTextField_Epoch.text = nil
        view.endEditing(true)
        reloadData_Epoch()
    }

    /// 处理状态更新
    @objc private func handleStateChange_Epoch() {
        reloadData_Epoch()
    }

    /// 返回上一页
    @objc private func backTapped_Epoch() {
        Navigation_Epoch.pop_Epoch()
    }

    /// 发送按钮点击
    @objc private func sendTapped_Epoch() {
        submitComment_Epoch()
    }
}

// MARK: - UITableViewDataSource

extension Detail_Epoch: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let titleModel_Epoch = titleModel_Epoch else { return 0 }
        return section == 0 ? 1 : titleModel_Epoch.reviews_Epoch.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let titleModel_Epoch = titleModel_Epoch else { return UITableViewCell() }
        if indexPath.section == 0 {
            guard let cell_epoch = tableView.dequeueReusableCell(withIdentifier: "DetailContentCell_Epoch", for: indexPath) as? DetailContentCell_Epoch else {
                return UITableViewCell()
            }
            cell_epoch.configure_Epoch(post_epoch: titleModel_Epoch)
            cell_epoch.onUserTapped_Epoch = {
                let user_epoch = UserViewModel_Epoch.shared_Epoch.getUserById_Epoch(userId_epoch: titleModel_Epoch.titleUserId_Epoch)
                Navigation_Epoch.toUserInfo_Epoch(with: user_epoch)
            }
            return cell_epoch
        }

        guard let cell_epoch = tableView.dequeueReusableCell(withIdentifier: "CommentCell_Epoch", for: indexPath) as? CommentCell_Epoch else {
            return UITableViewCell()
        }
        let comment_epoch = titleModel_Epoch.reviews_Epoch[indexPath.row]
        cell_epoch.configure_Epoch(comment_epoch: comment_epoch, post_epoch: titleModel_Epoch, hostViewController_Epoch: self)
        return cell_epoch
    }
}

// MARK: - UITableViewDelegate

extension Detail_Epoch: UITableViewDelegate {

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 1 else { return nil }
        let count_epoch = titleModel_Epoch?.reviews_Epoch.count ?? 0
        return "Comments (\(count_epoch))"
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Epoch: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        submitComment_Epoch()
        return true
    }
}

// MARK: - 详情内容单元格

/// 详情内容单元格
private final class DetailContentCell_Epoch: UITableViewCell {

    /// 作者头像
    private let avatarView_Epoch = UserAvatarView_Epoch()

    /// 作者按钮
    private let authorButton_Epoch = UIButton(type: .custom)

    /// 作者名称
    private let nameLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return label_Epoch
    }()

    /// 点赞评论信息
    private let metaLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        return label_Epoch
    }()

    /// 媒体视图
    private let mediaView_Epoch = MediaDisplayView_Epoch()

    /// 标题标签
    private let titleLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    /// 内容标签
    private let contentLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    /// 点击用户回调
    var onUserTapped_Epoch: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let cardView_epoch = UIView()
        cardView_epoch.backgroundColor = ColorConfig_Epoch.backgroundSecondary_Epoch
        cardView_epoch.layer.cornerRadius = 24
        contentView.addSubview(cardView_epoch)
        cardView_epoch.addSubview(avatarView_Epoch)
        cardView_epoch.addSubview(nameLabel_Epoch)
        cardView_epoch.addSubview(metaLabel_Epoch)
        cardView_epoch.addSubview(authorButton_Epoch)
        cardView_epoch.addSubview(mediaView_Epoch)
        cardView_epoch.addSubview(titleLabel_Epoch)
        cardView_epoch.addSubview(contentLabel_Epoch)

        cardView_epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
        }

        avatarView_Epoch.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(18)
            make.width.height.equalTo(44)
        }

        nameLabel_Epoch.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.left.equalTo(avatarView_Epoch.snp.right).offset(12)
            make.right.equalToSuperview().offset(-18)
        }

        metaLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Epoch.snp.bottom).offset(4)
            make.left.equalTo(nameLabel_Epoch)
            make.right.equalToSuperview().offset(-18)
        }

        authorButton_Epoch.snp.makeConstraints { make in
            make.left.top.equalToSuperview().inset(12)
            make.right.equalTo(nameLabel_Epoch.snp.right)
            make.bottom.equalTo(metaLabel_Epoch.snp.bottom).offset(4)
        }

        mediaView_Epoch.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Epoch.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(18)
            make.height.equalTo(250)
        }

        titleLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Epoch.snp.bottom).offset(18)
            make.left.right.equalToSuperview().inset(18)
        }

        contentLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Epoch.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview().inset(18)
        }

        authorButton_Epoch.addTarget(self, action: #selector(userTapped_Epoch), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 绑定帖子内容
    /// - Parameter post_epoch: 帖子模型
    func configure_Epoch(post_epoch: TitleModel_Epoch) {
        nameLabel_Epoch.text = post_epoch.titleUserName_Epoch
        metaLabel_Epoch.text = "\(post_epoch.likes_Epoch) likes • \(post_epoch.reviews_Epoch.count) comments"
        titleLabel_Epoch.text = post_epoch.title_Epoch
        contentLabel_Epoch.text = post_epoch.titleContent_Epoch
        avatarView_Epoch.configure_Epoch(userId_Epoch: post_epoch.titleUserId_Epoch)
        mediaView_Epoch.configure_Epoch(
            mediaPath_Epoch: post_epoch.titleMeidas_Epoch.first,
            isVideo_Epoch: DetailContentCell_Epoch.isVideoMedia_Epoch(post_epoch.titleMeidas_Epoch.first)
        )
    }

    /// 判断媒体类型
    /// - Parameter mediaPath_Epoch: 媒体路径
    /// - Returns: 是否为视频
    private static func isVideoMedia_Epoch(_ mediaPath_Epoch: String?) -> Bool {
        guard let mediaPath_Epoch = mediaPath_Epoch?.lowercased() else { return false }
        return mediaPath_Epoch.hasSuffix(".mov") || mediaPath_Epoch.hasSuffix(".mp4") || mediaPath_Epoch.hasSuffix(".m4v")
    }

    /// 处理作者点击
    @objc private func userTapped_Epoch() {
        onUserTapped_Epoch?()
    }
}

// MARK: - 评论单元格

/// 评论单元格
private final class CommentCell_Epoch: UITableViewCell {

    /// 评论者头像
    private let avatarView_Epoch = UserAvatarView_Epoch()

    /// 评论作者名称
    private let nameLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label_Epoch.textColor = ColorConfig_Epoch.textPrimary_Epoch
        return label_Epoch
    }()

    /// 评论内容
    private let contentLabel_Epoch: UILabel = {
        let label_Epoch = UILabel()
        label_Epoch.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label_Epoch.textColor = ColorConfig_Epoch.textSecondary_Epoch
        label_Epoch.numberOfLines = 0
        return label_Epoch
    }()

    /// 举报容器
    private let reportContainerView_Epoch = UIView()

    /// 按钮缓存
    private var reportButton_Epoch: UIButton?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        let cardView_epoch = UIView()
        cardView_epoch.backgroundColor = ColorConfig_Epoch.backgroundSecondary_Epoch
        cardView_epoch.layer.cornerRadius = 18
        contentView.addSubview(cardView_epoch)
        cardView_epoch.addSubview(avatarView_Epoch)
        cardView_epoch.addSubview(nameLabel_Epoch)
        cardView_epoch.addSubview(contentLabel_Epoch)
        cardView_epoch.addSubview(reportContainerView_Epoch)

        cardView_epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
        }

        // 头像：左上角，36×36
        avatarView_Epoch.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(14)
            make.width.height.equalTo(36)
        }

        // 举报按钮：右上角
        reportContainerView_Epoch.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(14)
            make.width.height.equalTo(24)
        }

        // 作者名：头像右侧，与头像顶部对齐
        nameLabel_Epoch.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView_Epoch)
            make.left.equalTo(avatarView_Epoch.snp.right).offset(10)
            make.right.lessThanOrEqualTo(reportContainerView_Epoch.snp.left).offset(-8)
        }

        // 评论内容：头像下方，占满宽度
        contentLabel_Epoch.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Epoch.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().offset(-14)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 配置评论内容
    /// - Parameters:
    ///   - comment_epoch: 评论模型
    ///   - post_epoch: 帖子模型
    ///   - hostViewController_Epoch: 宿主控制器
    func configure_Epoch(
        comment_epoch: Comment_Epoch,
        post_epoch: TitleModel_Epoch,
        hostViewController_Epoch: UIViewController
    ) {
        avatarView_Epoch.configure_Epoch(userId_Epoch: comment_epoch.commentUserId_Epoch)
        nameLabel_Epoch.text = comment_epoch.commentUserName_Epoch
        contentLabel_Epoch.text = comment_epoch.commentContent_Epoch

        reportButton_Epoch?.removeFromSuperview()
        let button_epoch = ReportDeleteHelper_Epoch.createCommentReportButton_Epoch(
            comment_Epoch: comment_epoch,
            post_Epoch: post_epoch,
            size_Epoch: 18,
            color_Epoch: ColorConfig_Epoch.textSecondary_Epoch,
            from: hostViewController_Epoch
        )
        reportContainerView_Epoch.addSubview(button_epoch)
        button_epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        reportButton_Epoch = button_epoch
    }
}
