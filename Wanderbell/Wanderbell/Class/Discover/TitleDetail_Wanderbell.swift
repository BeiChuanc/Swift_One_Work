import Foundation
import UIKit
import SnapKit

// MARK: - 帖子详情页面

/// 帖子详情页面
/// 功能：展示完整的帖子内容、评论列表、互动操作
/// 设计：现代化卡片式、沉浸式媒体展示、流畅交互
class TitleDetail_Wanderbell: UIViewController {
    
    // MARK: - 属性
    
    /// 帖子模型
    private var titleModel_Wanderbell: TitleModel_Wanderbell
    
    // MARK: - UI组件
    
    /// 滚动容器
    private let scrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = false
        scrollView_wanderbell.backgroundColor = .clear
        return scrollView_wanderbell
    }()
    
    private let contentView_Wanderbell = UIView()
    
    /// 媒体展示区域（图片/视频）
    private lazy var mediaView_Wanderbell: MediaDisplayView_Wanderbell = {
        let view_wanderbell = MediaDisplayView_Wanderbell()
        return view_wanderbell
    }()
    
    /// 作者信息卡片
    private let authorCard_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 20
        view_wanderbell.layer.shadowColor = UIColor.black.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_wanderbell.layer.shadowRadius = 12
        view_wanderbell.layer.shadowOpacity = 0.08
        return view_wanderbell
    }()
    
    /// 作者头像
    private let authorAvatar_Wanderbell = UserAvatarView_Wanderbell()
    
    /// 作者名称
    private let authorNameLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.title3_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    /// 发布时间
    private let timeLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.caption_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.text = "Just now"
        return label_wanderbell
    }()
    
    /// 内容卡片
    private let contentCard_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.cornerRadius = 20
        view_wanderbell.layer.shadowColor = UIColor.black.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_wanderbell.layer.shadowRadius = 12
        view_wanderbell.layer.shadowOpacity = 0.08
        return view_wanderbell
    }()
    
    /// 帖子标题
    private let titleLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.title1_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        label_wanderbell.numberOfLines = 0
        return label_wanderbell
    }()
    
    /// 帖子内容
    private let contentLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        label_wanderbell.numberOfLines = 0
        return label_wanderbell
    }()
    
    /// 互动栏（点赞、评论统计）
    private let interactionBar_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundSecondary_Wanderbell
        view_wanderbell.layer.cornerRadius = 16
        return view_wanderbell
    }()
    
    /// 点赞按钮
    private let likeButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)
        button_wanderbell.setImage(UIImage(systemName: "heart"), for: .normal)
        button_wanderbell.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        return button_wanderbell
    }()
    
    /// 点赞数标签
    private let likeCountLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    /// 评论数标签
    private let commentCountLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        return label_wanderbell
    }()
    
    /// 评论列表容器
    private let commentsContainer_Wanderbell: UIStackView = {
        let stack_wanderbell = UIStackView()
        stack_wanderbell.axis = .vertical
        stack_wanderbell.spacing = 12
        stack_wanderbell.alignment = .fill
        stack_wanderbell.distribution = .fill
        return stack_wanderbell
    }()
    
    /// 评论区标题
    private let commentsHeaderLabel_Wanderbell: UILabel = {
        let label_wanderbell = UILabel()
        label_wanderbell.text = "Comments"
        label_wanderbell.font = FontConfig_Wanderbell.title2_Wanderbell()
        label_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        return label_wanderbell
    }()
    
    /// 底部输入栏
    private let inputBar_Wanderbell: UIView = {
        let view_wanderbell = UIView()
        view_wanderbell.backgroundColor = .white
        view_wanderbell.layer.shadowColor = UIColor.black.cgColor
        view_wanderbell.layer.shadowOffset = CGSize(width: 0, height: -2)
        view_wanderbell.layer.shadowRadius = 12
        view_wanderbell.layer.shadowOpacity = 0.1
        view_wanderbell.layer.cornerRadius = 20
        view_wanderbell.layer.masksToBounds = true
        return view_wanderbell
    }()
    
    /// 评论输入框
    private let commentTextField_Wanderbell: UITextField = {
        let textField_wanderbell = UITextField()
        textField_wanderbell.placeholder = "Write a comment..."
        textField_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        textField_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundSecondary_Wanderbell
        textField_wanderbell.layer.cornerRadius = 20
        textField_wanderbell.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField_wanderbell.leftViewMode = .always
        textField_wanderbell.rightViewMode = .always
        return textField_wanderbell
    }()
    
    /// 发送按钮
    private let sendButton_Wanderbell: UIButton = {
        let button_wanderbell = UIButton(type: .custom)
        let config_wanderbell = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        button_wanderbell.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: config_wanderbell), for: .normal)
        button_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        return button_wanderbell
    }()
    
    // MARK: - 初始化
    
    init(titleModel_wanderbell: TitleModel_Wanderbell) {
        self.titleModel_Wanderbell = titleModel_wanderbell
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
        setupNavigationBar_Wanderbell()
        setupActions_Wanderbell()
        loadData_Wanderbell()
        observeTitleState_Wanderbell()
    }
    
    // MARK: - UI设置
    
    private func setupUI_Wanderbell() {
        view.addDiscoverBackgroundGradient_Wanderbell()
        
        view.addSubview(scrollView_Wanderbell)
        scrollView_Wanderbell.addSubview(contentView_Wanderbell)
        
        // 媒体区域
        if !titleModel_Wanderbell.titleMeidas_Wanderbell.isEmpty {
            contentView_Wanderbell.addSubview(mediaView_Wanderbell)
        }
        
        // 作者信息卡片
        contentView_Wanderbell.addSubview(authorCard_Wanderbell)
        authorCard_Wanderbell.addSubview(authorAvatar_Wanderbell)
        authorCard_Wanderbell.addSubview(authorNameLabel_Wanderbell)
        authorCard_Wanderbell.addSubview(timeLabel_Wanderbell)
        
        // 内容卡片
        contentView_Wanderbell.addSubview(contentCard_Wanderbell)
        contentCard_Wanderbell.addSubview(titleLabel_Wanderbell)
        contentCard_Wanderbell.addSubview(contentLabel_Wanderbell)
        
        // 互动栏
        contentCard_Wanderbell.addSubview(interactionBar_Wanderbell)
        interactionBar_Wanderbell.addSubview(likeButton_Wanderbell)
        interactionBar_Wanderbell.addSubview(likeCountLabel_Wanderbell)
        interactionBar_Wanderbell.addSubview(commentCountLabel_Wanderbell)
        
        // 评论区
        contentView_Wanderbell.addSubview(commentsHeaderLabel_Wanderbell)
        contentView_Wanderbell.addSubview(commentsContainer_Wanderbell)
        
        // 底部输入栏
        view.addSubview(inputBar_Wanderbell)
        inputBar_Wanderbell.addSubview(commentTextField_Wanderbell)
        
        // 设置发送按钮为输入框的 rightView
        let sendContainer_wanderbell = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 44))
        sendContainer_wanderbell.addSubview(sendButton_Wanderbell)
        sendButton_Wanderbell.frame = CGRect(x: 6, y: 4, width: 40, height: 40)
        commentTextField_Wanderbell.rightView = sendContainer_wanderbell
        
        // 键盘通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Wanderbell(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Wanderbell(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // 点击空白处收起键盘
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Wanderbell))
        tapGesture_wanderbell.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture_wanderbell)
    }
    
    private func setupConstraints_Wanderbell() {
        scrollView_Wanderbell.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(inputBar_Wanderbell.snp.top)
        }
        
        contentView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
        
        var previousView_wanderbell: UIView? = nil
        
        // 媒体区域约束
        if !titleModel_Wanderbell.titleMeidas_Wanderbell.isEmpty {
            mediaView_Wanderbell.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview().inset(20)
                make.height.equalTo(UIScreen.main.bounds.width)
            }
            previousView_wanderbell = mediaView_Wanderbell
        }
        
        // 作者信息卡片
        authorCard_Wanderbell.snp.makeConstraints { make in
            if let previous_wanderbell = previousView_wanderbell {
                make.top.equalTo(previous_wanderbell.snp.bottom).offset(16)
            } else {
                make.top.equalToSuperview().offset(16)
            }
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(70)
        }
        
        authorAvatar_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        authorNameLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(authorAvatar_Wanderbell.snp.right).offset(12)
            make.top.equalTo(authorAvatar_Wanderbell).offset(2)
            make.right.equalToSuperview().offset(-16)
        }
        
        timeLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(authorNameLabel_Wanderbell)
            make.bottom.equalTo(authorAvatar_Wanderbell).offset(-2)
        }
        
        // 内容卡片
        contentCard_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(authorCard_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        titleLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        contentLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Wanderbell.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 互动栏
        interactionBar_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        likeButton_Wanderbell.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        likeCountLabel_Wanderbell.snp.makeConstraints { make in
            make.left.equalTo(likeButton_Wanderbell.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
        
        commentCountLabel_Wanderbell.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
        
        // 评论区标题
        commentsHeaderLabel_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(contentCard_Wanderbell.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(20)
        }
        
        // 评论列表
        commentsContainer_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(commentsHeaderLabel_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        // 底部输入栏
        inputBar_Wanderbell.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(70)
        }
        
        commentTextField_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Wanderbell() {
        // 设置标题
        title = "Post Details"
        
        // 自定义返回按钮
        let backButton_wanderbell = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_Wanderbell)
        )
        backButton_wanderbell.tintColor = ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        navigationItem.leftBarButtonItem = backButton_wanderbell
        
        // 右上角举报按钮
        let reportButton_wanderbell = ReportDeleteHelper_Wanderbell.createPostReportButton_Wanderbell(
            post_wanderbell: titleModel_Wanderbell,
            size_wanderbell: 28,
            color_wanderbell: ColorConfig_Wanderbell.primaryGradientStart_Wanderbell,
            from: self
        ) { [weak self] in
            // 举报/删除完成后返回上一页
            self?.navigationController?.popViewController(animated: true)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButton_wanderbell)
    }
    
    private func setupActions_Wanderbell() {
        likeButton_Wanderbell.addTarget(self, action: #selector(likeButtonTapped_Wanderbell), for: .touchUpInside)
        sendButton_Wanderbell.addTarget(self, action: #selector(sendCommentTapped_Wanderbell), for: .touchUpInside)
        
        // 点击作者卡片跳转到作者主页
        let tapGesture_wanderbell = UITapGestureRecognizer(target: self, action: #selector(authorCardTapped_Wanderbell))
        authorCard_Wanderbell.addGestureRecognizer(tapGesture_wanderbell)
    }
    
    // MARK: - 数据加载
    
    private func loadData_Wanderbell() {
        // 配置媒体
        if let firstMedia_wanderbell = titleModel_Wanderbell.titleMeidas_Wanderbell.first {
            mediaView_Wanderbell.configure_Wanderbell(
                mediaPath_wanderbell: firstMedia_wanderbell,
                isVideo_wanderbell: firstMedia_wanderbell.hasSuffix(".mp4") || firstMedia_wanderbell.hasSuffix(".mov")
            )
        }
        
        // 配置作者信息
        authorAvatar_Wanderbell.configure_Wanderbell(userId_wanderbell: titleModel_Wanderbell.titleUserId_Wanderbell)
        authorNameLabel_Wanderbell.text = titleModel_Wanderbell.titleUserName_Wanderbell
        
        // 配置内容
        titleLabel_Wanderbell.text = titleModel_Wanderbell.title_Wanderbell
        contentLabel_Wanderbell.text = titleModel_Wanderbell.titleContent_Wanderbell
        
        // 配置互动数据
        updateLikeStatus_Wanderbell()
        likeCountLabel_Wanderbell.text = "\(titleModel_Wanderbell.likes_Wanderbell) likes"
        commentCountLabel_Wanderbell.text = "\(titleModel_Wanderbell.reviews_Wanderbell.count) comments"
        
        // 加载评论
        loadComments_Wanderbell()
    }
    
    /// 加载评论列表
    private func loadComments_Wanderbell() {
        // 清空现有评论
        commentsContainer_Wanderbell.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if titleModel_Wanderbell.reviews_Wanderbell.isEmpty {
            // 显示空状态
            let emptyLabel_wanderbell = UILabel()
            emptyLabel_wanderbell.text = "No comments yet. Be the first to comment!"
            emptyLabel_wanderbell.font = FontConfig_Wanderbell.subheadline_Wanderbell()
            emptyLabel_wanderbell.textColor = ColorConfig_Wanderbell.textPlaceholder_Wanderbell
            emptyLabel_wanderbell.textAlignment = .center
            emptyLabel_wanderbell.numberOfLines = 0
            
            commentsContainer_Wanderbell.addArrangedSubview(emptyLabel_wanderbell)
            emptyLabel_wanderbell.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(80)
            }
        } else {
            // 显示评论列表
            for comment_wanderbell in titleModel_Wanderbell.reviews_Wanderbell {
                let commentView_wanderbell = createCommentView_Wanderbell(comment: comment_wanderbell)
                commentsContainer_Wanderbell.addArrangedSubview(commentView_wanderbell)
            }
        }
    }
    
    /// 创建单个评论视图
    /// 参数：
    /// - comment: 评论模型
    /// 返回值：评论视图
    private func createCommentView_Wanderbell(comment: Comment_Wanderbell) -> UIView {
        let containerView_wanderbell = UIView()
        containerView_wanderbell.backgroundColor = .white
        containerView_wanderbell.layer.cornerRadius = 16
        containerView_wanderbell.layer.shadowColor = UIColor.black.cgColor
        containerView_wanderbell.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView_wanderbell.layer.shadowRadius = 8
        containerView_wanderbell.layer.shadowOpacity = 0.06
        
        // 评论者头像
        let avatar_wanderbell = UserAvatarView_Wanderbell()
        avatar_wanderbell.configure_Wanderbell(userId_wanderbell: comment.commentUserId_Wanderbell)
        containerView_wanderbell.addSubview(avatar_wanderbell)
        
        // 评论者名称
        let nameLabel_wanderbell = UILabel()
        nameLabel_wanderbell.text = comment.commentUserName_Wanderbell
        nameLabel_wanderbell.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        nameLabel_wanderbell.textColor = ColorConfig_Wanderbell.textPrimary_Wanderbell
        containerView_wanderbell.addSubview(nameLabel_wanderbell)
        
        // 评论内容
        let contentLabel_wanderbell = UILabel()
        contentLabel_wanderbell.text = comment.commentContent_Wanderbell
        contentLabel_wanderbell.font = FontConfig_Wanderbell.body_Wanderbell()
        contentLabel_wanderbell.textColor = ColorConfig_Wanderbell.textSecondary_Wanderbell
        contentLabel_wanderbell.numberOfLines = 0
        containerView_wanderbell.addSubview(contentLabel_wanderbell)
        
        // 举报/删除按钮
        let reportButton_wanderbell = ReportDeleteHelper_Wanderbell.createCommentReportButton_Wanderbell(
            comment_wanderbell: comment,
            post_wanderbell: titleModel_Wanderbell,
            size_wanderbell: 24,
            color_wanderbell: ColorConfig_Wanderbell.textPlaceholder_Wanderbell,
            from: self,
            completion_wanderbell: { [weak self] in
                // 删除/举报完成后重新加载评论
                self?.loadComments_Wanderbell()
            }
        )
        containerView_wanderbell.addSubview(reportButton_wanderbell)
        
        // 布局
        avatar_wanderbell.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(12)
            make.width.height.equalTo(36)
        }
        
        nameLabel_wanderbell.snp.makeConstraints { make in
            make.left.equalTo(avatar_wanderbell.snp.right).offset(10)
            make.top.equalTo(avatar_wanderbell).inset(10)
            make.right.equalTo(reportButton_wanderbell.snp.left).offset(-8)
        }
        
        contentLabel_wanderbell.snp.makeConstraints { make in
            make.left.equalTo(nameLabel_wanderbell)
            make.top.equalTo(nameLabel_wanderbell.snp.bottom).offset(6)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
        
        reportButton_wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(32)
        }
        
        containerView_wanderbell.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(60)
        }
        
        return containerView_wanderbell
    }
    
    // MARK: - 事件处理
    
    /// 返回按钮点击
    @objc private func backTapped_Wanderbell() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 点赞按钮点击
    @objc private func likeButtonTapped_Wanderbell() {
        // 按钮动画
        likeButton_Wanderbell.animatePulse_Wanderbell()
        
        // 切换点赞状态
        TitleViewModel_Wanderbell.shared_Wanderbell.likePost_Wanderbell(post_wanderbell: titleModel_Wanderbell)
        
        // 触觉反馈
        let generator_wanderbell = UIImpactFeedbackGenerator(style: .medium)
        generator_wanderbell.impactOccurred()
    }
    
    /// 发送评论
    @objc private func sendCommentTapped_Wanderbell() {
        guard let commentText_wanderbell = commentTextField_Wanderbell.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !commentText_wanderbell.isEmpty else {
            return
        }
        
        // 创建新评论
        let currentUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getCurrentUser_Wanderbell()
        let newComment_wanderbell = Comment_Wanderbell(
            commentId_Wanderbell: Int.random(in: 10000...99999),
            commentUserId_Wanderbell: currentUser_wanderbell.userId_Wanderbell ?? 0,
            commentUserName_Wanderbell: currentUser_wanderbell.userName_Wanderbell ?? "User",
            commentContent_Wanderbell: commentText_wanderbell
        )
        
        // 添加评论
        TitleViewModel_Wanderbell.shared_Wanderbell.addComment_Wanderbell(
            to: titleModel_Wanderbell,
            comment: newComment_wanderbell
        )
        
        // 清空输入框
        commentTextField_Wanderbell.text = ""
        
        // 收起键盘
        commentTextField_Wanderbell.resignFirstResponder()
        
        // 显示成功提示
        Utils_Wanderbell.showSuccess_Wanderbell(
            message_wanderbell: "Comment posted successfully",
            delay_wanderbell: 1.5
        )
        
        // 触觉反馈
        let generator_wanderbell = UINotificationFeedbackGenerator()
        generator_wanderbell.notificationOccurred(.success)
        
        // 滚动到最新评论（延迟执行，等待UI更新）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.scrollToBottomComment_Wanderbell()
        }
    }
    
    /// 滚动到最新评论
    /// 功能：将滚动视图滚动到评论区域底部，显示最新添加的评论
    private func scrollToBottomComment_Wanderbell() {
        // 计算评论区域底部的位置
        let bottomOffset_wanderbell = CGPoint(
            x: 0,
            y: max(0, scrollView_Wanderbell.contentSize.height - scrollView_Wanderbell.bounds.height + scrollView_Wanderbell.contentInset.bottom)
        )
        
        // 平滑滚动到底部
        scrollView_Wanderbell.setContentOffset(bottomOffset_wanderbell, animated: true)
    }
    
    /// 作者卡片点击
    @objc private func authorCardTapped_Wanderbell() {
        // 获取作者信息
        let authorUser_wanderbell = UserViewModel_Wanderbell.shared_Wanderbell.getUserById_Wanderbell(
            userId_wanderbell: titleModel_Wanderbell.titleUserId_Wanderbell
        )
        
        // 跳转到用户详情页
        Navigation_Wanderbell.toUserInfo_Wanderbell(
            with: authorUser_wanderbell,
            style_wanderbell: .replace_wanderbell
        )
    }
    
    /// 收起键盘
    @objc private func dismissKeyboard_Wanderbell() {
        view.endEditing(true)
    }
    
    /// 键盘显示
    @objc private func keyboardWillShow_Wanderbell(_ notification: Notification) {
        guard let keyboardFrame_wanderbell = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_wanderbell = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight_wanderbell = keyboardFrame_wanderbell.height - view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration_wanderbell) {
            self.inputBar_Wanderbell.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-keyboardHeight_wanderbell)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    /// 键盘隐藏
    @objc private func keyboardWillHide_Wanderbell(_ notification: Notification) {
        guard let duration_wanderbell = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration_wanderbell) {
            self.inputBar_Wanderbell.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - 辅助方法
    
    /// 更新点赞状态
    private func updateLikeStatus_Wanderbell() {
        let isLiked_wanderbell = TitleViewModel_Wanderbell.shared_Wanderbell.isLikedPost_Wanderbell(
            post_wanderbell: titleModel_Wanderbell
        )
        likeButton_Wanderbell.isSelected = isLiked_wanderbell
        likeButton_Wanderbell.tintColor = isLiked_wanderbell
            ? UIColor(hexstring_Wanderbell: "#FC8181")
            : ColorConfig_Wanderbell.textSecondary_Wanderbell
    }
    
    /// 监听帖子状态变化
    private func observeTitleState_Wanderbell() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Wanderbell),
            name: TitleViewModel_Wanderbell.titleStateDidChangeNotification_Wanderbell,
            object: nil
        )
    }
    
    /// 处理帖子状态变化
    @objc private func handleTitleStateChange_Wanderbell() {
        // 重新获取最新的帖子数据
        if let updatedPost_wanderbell = TitleViewModel_Wanderbell.shared_Wanderbell.getPostById_Wanderbell(
            postId_wanderbell: titleModel_Wanderbell.titleId_Wanderbell
        ) {
            titleModel_Wanderbell = updatedPost_wanderbell
            
            // 更新UI
            updateLikeStatus_Wanderbell()
            likeCountLabel_Wanderbell.text = "\(titleModel_Wanderbell.likes_Wanderbell) likes"
            commentCountLabel_Wanderbell.text = "\(titleModel_Wanderbell.reviews_Wanderbell.count) comments"
            loadComments_Wanderbell()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
