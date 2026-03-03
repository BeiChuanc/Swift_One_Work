import Foundation
import UIKit
import SnapKit

// MARK: - 帖子详情页

/// 帖子详情页面控制器
/// 功能：展示帖子详细内容，包括媒体、标题、内容、评论列表
/// 特性：支持举报/删除帖子和评论、实时数据更新、现代化UI设计
class Detail_Glasspaint: UIViewController {
    
    // MARK: - 数据属性
    
    /// 帖子模型数据
    var titleModel_Glasspaint: TitleModel_Glasspaint?
    
    // MARK: - UI组件 - 背景装饰
    
    /// 背景渐变层
    private let backgroundGradientLayer_Glasspaint = CAGradientLayer()
    
    /// 装饰圆圈1
    private let decorCircle1_Glasspaint = UIView()
    
    /// 装饰圆圈2
    private let decorCircle2_Glasspaint = UIView()
    
    // MARK: - UI组件 - 内容区域
    
    /// 滚动视图
    private let scrollView_Glasspaint: UIScrollView = {
        let scrollView_Glasspaint = UIScrollView()
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.contentInsetAdjustmentBehavior = .never
        return scrollView_Glasspaint
    }()
    
    /// 内容容器
    private let contentView_Glasspaint = UIView()
    
    /// 媒体展示区域
    private let mediaContainerView_Glasspaint = UIView()
    
    /// 媒体展示视图
    private let mediaDisplayView_Glasspaint = MediaDisplayView_Glasspaint()
    
    /// 帖子信息卡片
    private let postInfoCard_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = .white
        view_Glasspaint.layer.cornerRadius = 24
        view_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        view_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        view_Glasspaint.layer.shadowRadius = 12
        view_Glasspaint.layer.shadowOpacity = 0.08
        return view_Glasspaint
    }()
    
    /// 帖子标题标签
    private let titleLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.font = .systemFont(ofSize: 24, weight: .bold)
        label_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        label_Glasspaint.numberOfLines = 0
        return label_Glasspaint
    }()
    
    /// 用户信息容器
    private let userInfoContainer_Glasspaint = UIView()
    
    /// 用户头像
    private let userAvatarView_Glasspaint: UserAvatarView_Glasspaint = {
        let avatarView_Glasspaint = UserAvatarView_Glasspaint()
        avatarView_Glasspaint.layer.borderWidth = 2
        avatarView_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        return avatarView_Glasspaint
    }()
    
    /// 用户名标签
    private let userNameLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.font = .systemFont(ofSize: 16, weight: .semibold)
        label_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        return label_Glasspaint
    }()
    
    /// 发布时间标签
    private let dateLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.font = .systemFont(ofSize: 13, weight: .regular)
        label_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        return label_Glasspaint
    }()
    
    /// 帖子内容标签
    private let contentLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.font = .systemFont(ofSize: 16, weight: .regular)
        label_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        label_Glasspaint.numberOfLines = 0
        return label_Glasspaint
    }()
    
    /// 点赞数容器
    private let likesContainer_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1)
        view_Glasspaint.layer.cornerRadius = 20
        return view_Glasspaint
    }()
    
    /// 点赞图标
    private let likesIconView_Glasspaint: UIImageView = {
        let imageView_Glasspaint = UIImageView()
        let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        imageView_Glasspaint.image = UIImage(systemName: "heart.fill", withConfiguration: config_glasspaint)
        imageView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        imageView_Glasspaint.contentMode = .scaleAspectFit
        return imageView_Glasspaint
    }()
    
    /// 点赞数标签
    private let likesLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.font = .systemFont(ofSize: 15, weight: .semibold)
        label_Glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        return label_Glasspaint
    }()
    
    // MARK: - UI组件 - 评论区域
    
    /// 评论区标题容器
    private let commentsTitleContainer_Glasspaint = UIView()
    
    /// 评论区标题标签
    private let commentsTitleLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.text = "Comments"
        label_Glasspaint.font = .systemFont(ofSize: 20, weight: .bold)
        label_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        return label_Glasspaint
    }()
    
    /// 评论计数标签
    private let commentsCountLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.font = .systemFont(ofSize: 15, weight: .medium)
        label_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        return label_Glasspaint
    }()
    
    /// 评论列表容器
    private let commentsListContainer_Glasspaint = UIView()
    
    /// 空状态视图
    private let emptyCommentsView_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.isHidden = true
        return view_Glasspaint
    }()
    
    /// 空状态图标
    private let emptyIconView_Glasspaint: UIImageView = {
        let imageView_Glasspaint = UIImageView()
        let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        imageView_Glasspaint.image = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: config_glasspaint)
        imageView_Glasspaint.tintColor = ColorConfig_Glasspaint.textPlaceholder_Glasspaint
        imageView_Glasspaint.contentMode = .scaleAspectFit
        return imageView_Glasspaint
    }()
    
    /// 空状态提示标签
    private let emptyLabel_Glasspaint: UILabel = {
        let label_Glasspaint = UILabel()
        label_Glasspaint.text = "No comments yet\nBe the first to comment!"
        label_Glasspaint.font = .systemFont(ofSize: 15, weight: .medium)
        label_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        label_Glasspaint.textAlignment = .center
        label_Glasspaint.numberOfLines = 2
        return label_Glasspaint
    }()
    
    // MARK: - UI组件 - 评论输入区域
    
    /// 评论输入容器
    private let commentInputContainer_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = .white
        view_Glasspaint.layer.cornerRadius = 24
        view_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        view_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: -2)
        view_Glasspaint.layer.shadowRadius = 8
        view_Glasspaint.layer.shadowOpacity = 0.1
        return view_Glasspaint
    }()
    
    /// 评论输入框背景
    private let commentInputBackground_Glasspaint: UIView = {
        let view_Glasspaint = UIView()
        view_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        view_Glasspaint.layer.cornerRadius = 24
        return view_Glasspaint
    }()
    
    /// 评论输入框
    private let commentTextField_Glasspaint: UITextField = {
        let textField_Glasspaint = UITextField()
        textField_Glasspaint.placeholder = "Add a comment..."
        textField_Glasspaint.font = .systemFont(ofSize: 15, weight: .regular)
        textField_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        textField_Glasspaint.returnKeyType = .send
        return textField_Glasspaint
    }()
    
    /// 礼物按钮
    private let giftButton_Glasspaint: UIButton = {
        let button_Glasspaint = UIButton(type: .custom)
        button_Glasspaint.setImage(UIImage(named: "gift_btn"), for: .normal)
        button_Glasspaint.contentMode = .scaleAspectFit
        return button_Glasspaint
    }()
    
    /// 发送按钮
    private let sendButton_Glasspaint: UIButton = {
        let button_Glasspaint = UIButton(type: .system)
        let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        button_Glasspaint.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: config_glasspaint), for: .normal)
        button_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        button_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1)
        button_Glasspaint.layer.cornerRadius = 20
        return button_Glasspaint
    }()
    
    // MARK: - 生命周期方法
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI_Glasspaint()
        setupNavigationBar_Glasspaint()
        setupConstraints_Glasspaint()
        setupNotifications_Glasspaint()
        setupKeyboardObservers_Glasspaint()
        loadData_Glasspaint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradientLayer_Glasspaint.frame = view.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI设置方法
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 背景渐变
        setupBackgroundGradient_Glasspaint()
        
        // 装饰元素
        setupDecorationElements_Glasspaint()
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 媒体展示区域
        contentView_Glasspaint.addSubview(mediaContainerView_Glasspaint)
        mediaContainerView_Glasspaint.addSubview(mediaDisplayView_Glasspaint)
        
        // 帖子信息卡片
        contentView_Glasspaint.addSubview(postInfoCard_Glasspaint)
        setupPostInfoCard_Glasspaint()
        
        // 评论区域
        contentView_Glasspaint.addSubview(commentsTitleContainer_Glasspaint)
        setupCommentsTitleSection_Glasspaint()
        
        contentView_Glasspaint.addSubview(commentsListContainer_Glasspaint)
        
        // 空状态视图
        contentView_Glasspaint.addSubview(emptyCommentsView_Glasspaint)
        setupEmptyCommentsView_Glasspaint()
        
        // 评论输入区域
        view.addSubview(commentInputContainer_Glasspaint)
        setupCommentInputSection_Glasspaint()
    }
    
    /// 设置背景渐变
    private func setupBackgroundGradient_Glasspaint() {
        backgroundGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.cgColor,
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.05).cgColor,
            ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.cgColor
        ]
        backgroundGradientLayer_Glasspaint.locations = [0.0, 0.5, 1.0]
        backgroundGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer_Glasspaint, at: 0)
    }
    
    /// 设置装饰元素
    private func setupDecorationElements_Glasspaint() {
        // 装饰圆圈1
        view.addSubview(decorCircle1_Glasspaint)
        decorCircle1_Glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.1)
        decorCircle1_Glasspaint.layer.cornerRadius = 100
        
        decorCircle1_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-50)
            make.right.equalToSuperview().offset(30)
            make.width.height.equalTo(200)
        }
        
        // 装饰圆圈2
        view.addSubview(decorCircle2_Glasspaint)
        decorCircle2_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.withAlphaComponent(0.08)
        decorCircle2_Glasspaint.layer.cornerRadius = 80
        
        decorCircle2_Glasspaint.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(-40)
            make.width.height.equalTo(160)
        }
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        navigationController?.navigationBar.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        
        // 自定义返回按钮
        let backButton_glasspaint = UIButton(type: .system)
        let config_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        backButton_glasspaint.setImage(UIImage(systemName: "chevron.left", withConfiguration: config_glasspaint), for: .normal)
        backButton_glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        backButton_glasspaint.addTarget(self, action: #selector(handleBackTap_Glasspaint), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton_glasspaint)
        
        // 居中标题
        let titleLabel_glasspaint = UILabel()
        titleLabel_glasspaint.text = "Detail"
        titleLabel_glasspaint.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel_glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        navigationItem.titleView = titleLabel_glasspaint
        
        // 举报/删除按钮
        if let post_glasspaint = titleModel_Glasspaint {
            let reportButton_glasspaint = ReportDeleteHelper_Glasspaint.createPostReportButton_Glasspaint(
                post_Glasspaint: post_glasspaint,
                size_Glasspaint: 22,
                color_Glasspaint: ColorConfig_Glasspaint.primaryGradientStart_Glasspaint,
                from: self
            ) { [weak self] in
                // 删除成功后返回上一页
                self?.navigationController?.popViewController(animated: true)
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButton_glasspaint)
        }
    }
    
    /// 设置帖子信息卡片
    private func setupPostInfoCard_Glasspaint() {
        // 标题
        postInfoCard_Glasspaint.addSubview(titleLabel_Glasspaint)
        
        // 用户信息容器
        postInfoCard_Glasspaint.addSubview(userInfoContainer_Glasspaint)
        
        // 用户头像
        userInfoContainer_Glasspaint.addSubview(userAvatarView_Glasspaint)
        
        // 用户名和时间容器
        let textStackView_glasspaint = UIStackView(arrangedSubviews: [userNameLabel_Glasspaint, dateLabel_Glasspaint])
        textStackView_glasspaint.axis = .vertical
        textStackView_glasspaint.spacing = 2
        userInfoContainer_Glasspaint.addSubview(textStackView_glasspaint)
        
        textStackView_glasspaint.snp.makeConstraints { make in
            make.left.equalTo(userAvatarView_Glasspaint.snp.right).offset(12)
            make.centerY.equalTo(userAvatarView_Glasspaint)
            make.right.lessThanOrEqualToSuperview()
        }
        
        // 内容标签
        postInfoCard_Glasspaint.addSubview(contentLabel_Glasspaint)
        
        // 点赞容器
        postInfoCard_Glasspaint.addSubview(likesContainer_Glasspaint)
        likesContainer_Glasspaint.addSubview(likesIconView_Glasspaint)
        likesContainer_Glasspaint.addSubview(likesLabel_Glasspaint)
        
        likesIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        likesLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(likesIconView_Glasspaint.snp.right).offset(6)
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
    
    /// 设置评论区标题区域
    private func setupCommentsTitleSection_Glasspaint() {
        commentsTitleContainer_Glasspaint.addSubview(commentsTitleLabel_Glasspaint)
        commentsTitleContainer_Glasspaint.addSubview(commentsCountLabel_Glasspaint)
        
        commentsTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.centerY.equalToSuperview()
        }
        
        commentsCountLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(commentsTitleLabel_Glasspaint.snp.right).offset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    /// 设置空评论视图
    private func setupEmptyCommentsView_Glasspaint() {
        emptyCommentsView_Glasspaint.addSubview(emptyIconView_Glasspaint)
        emptyCommentsView_Glasspaint.addSubview(emptyLabel_Glasspaint)
        
        emptyIconView_Glasspaint.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
            make.width.height.equalTo(60)
        }
        
        emptyLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(emptyIconView_Glasspaint.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
    }
    
    /// 设置评论输入区域
    private func setupCommentInputSection_Glasspaint() {
        // 输入背景
        commentInputContainer_Glasspaint.addSubview(commentInputBackground_Glasspaint)
        
        // 输入框
        commentInputBackground_Glasspaint.addSubview(commentTextField_Glasspaint)
        commentTextField_Glasspaint.delegate = self
        commentTextField_Glasspaint.addTarget(self, action: #selector(commentTextChanged_Glasspaint), for: .editingChanged)
        
        // 礼物按钮
        commentInputBackground_Glasspaint.addSubview(giftButton_Glasspaint)
        giftButton_Glasspaint.addTarget(self, action: #selector(handleGiftTap_Glasspaint), for: .touchUpInside)
        
        // 发送按钮
        commentInputBackground_Glasspaint.addSubview(sendButton_Glasspaint)
        sendButton_Glasspaint.addTarget(self, action: #selector(handleSendComment_Glasspaint), for: .touchUpInside)
        sendButton_Glasspaint.isEnabled = false
        sendButton_Glasspaint.alpha = 0.5
        
        commentInputBackground_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(48)
        }
        
        commentTextField_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.right.equalTo(giftButton_Glasspaint.snp.left).offset(-8)
        }
        
        giftButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalTo(sendButton_Glasspaint.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(34)
        }
        
        sendButton_Glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(commentInputContainer_Glasspaint.snp.top)
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Glasspaint)
        }
        
        // 媒体展示区域
        mediaContainerView_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(380)
        }
        
        mediaDisplayView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 帖子信息卡片
        postInfoCard_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(mediaContainerView_Glasspaint.snp.bottom).offset(-40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        userInfoContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Glasspaint.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        
        userAvatarView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        contentLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(userInfoContainer_Glasspaint.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        likesContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(contentLabel_Glasspaint.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        // 评论区标题
        commentsTitleContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(postInfoCard_Glasspaint.snp.bottom).offset(32)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        // 评论列表容器 - 不设置底部约束，让其根据内容自适应高度
        commentsListContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(commentsTitleContainer_Glasspaint.snp.bottom).offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.lessThanOrEqualToSuperview().offset(-120)
        }
        
        // 空状态视图
        emptyCommentsView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(commentsTitleContainer_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(200)
            make.bottom.lessThanOrEqualToSuperview().offset(-120)
        }
        
        // 评论输入容器
        commentInputContainer_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(72)
        }
    }
    
    // MARK: - 通知设置
    
    /// 设置通知监听
    private func setupNotifications_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataChange_Glasspaint),
            name: TitleViewModel_Glasspaint.titleStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
    
    /// 设置键盘监听
    private func setupKeyboardObservers_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_Glasspaint(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_Glasspaint(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // 添加点击手势关闭键盘
        let tapGesture_glasspaint = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard_Glasspaint))
        tapGesture_glasspaint.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture_glasspaint)
    }
    
    // MARK: - 数据加载
    
    /// 加载数据
    private func loadData_Glasspaint() {
        guard let post_glasspaint = titleModel_Glasspaint else { return }
        
        // 加载媒体
        if let firstMedia_glasspaint = post_glasspaint.titleMeidas_Glasspaint.first {
            mediaDisplayView_Glasspaint.configure_Glasspaint(mediaPath_Glasspaint: firstMedia_glasspaint, isVideo_Glasspaint: false)
        }
        
        // 加载标题
        titleLabel_Glasspaint.text = post_glasspaint.title_Glasspaint
        
        // 加载用户信息
        userNameLabel_Glasspaint.text = post_glasspaint.titleUserName_Glasspaint
        
        // 加载用户头像
        userAvatarView_Glasspaint.configure_Glasspaint(userId_Glasspaint: post_glasspaint.titleUserId_Glasspaint)
        
        // 加载时间
        let dateFormatter_glasspaint = DateFormatter()
        dateFormatter_glasspaint.dateFormat = "MMM dd, yyyy"
        dateLabel_Glasspaint.text = dateFormatter_glasspaint.string(from: post_glasspaint.createdDate_Glasspaint)
        
        // 加载内容
        contentLabel_Glasspaint.text = post_glasspaint.titleContent_Glasspaint
        
        // 加载点赞数
        likesLabel_Glasspaint.text = "\(post_glasspaint.likes_Glasspaint)"
        
        // 加载评论列表
        loadComments_Glasspaint()
    }
    
    /// 加载评论列表
    private func loadComments_Glasspaint() {
        guard let post_glasspaint = titleModel_Glasspaint else { return }
        
        // 清空旧的评论视图和约束
        commentsListContainer_Glasspaint.subviews.forEach { $0.removeFromSuperview() }
        commentsListContainer_Glasspaint.snp.removeConstraints()
        
        let comments_glasspaint = post_glasspaint.reviews_Glasspaint
        
        // 更新评论数量
        commentsCountLabel_Glasspaint.text = "(\(comments_glasspaint.count))"
        
        if comments_glasspaint.isEmpty {
            // 显示空状态
            emptyCommentsView_Glasspaint.isHidden = false
            commentsListContainer_Glasspaint.isHidden = true
            
            // 重新设置评论列表容器约束（空状态时设置固定高度）
            commentsListContainer_Glasspaint.snp.remakeConstraints { make in
                make.top.equalTo(commentsTitleContainer_Glasspaint.snp.bottom).offset(16)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
                make.height.equalTo(0)
            }
        } else {
            // 隐藏空状态
            emptyCommentsView_Glasspaint.isHidden = true
            commentsListContainer_Glasspaint.isHidden = false
            
            // 重新设置评论列表容器约束
            commentsListContainer_Glasspaint.snp.remakeConstraints { make in
                make.top.equalTo(commentsTitleContainer_Glasspaint.snp.bottom).offset(16)
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
            }
            
            // 创建评论视图
            var lastCommentView_glasspaint: UIView?
            
            for (index_glasspaint, comment_glasspaint) in comments_glasspaint.enumerated() {
                let commentView_glasspaint = createCommentView_Glasspaint(
                    comment_Glasspaint: comment_glasspaint,
                    post_Glasspaint: post_glasspaint
                )
                commentsListContainer_Glasspaint.addSubview(commentView_glasspaint)
                
                commentView_glasspaint.snp.makeConstraints { make in
                    if let lastView_glasspaint = lastCommentView_glasspaint {
                        make.top.equalTo(lastView_glasspaint.snp.bottom).offset(12)
                    } else {
                        make.top.equalToSuperview()
                    }
                    make.left.right.equalToSuperview()
                    
                    if index_glasspaint == comments_glasspaint.count - 1 {
                        make.bottom.equalToSuperview().offset(-32)
                    }
                }
                
                lastCommentView_glasspaint = commentView_glasspaint
            }
        }
        
        // 强制更新布局
        view.layoutIfNeeded()
    }
    
    /// 创建单个评论视图
    private func createCommentView_Glasspaint(
        comment_Glasspaint: Comment_Glasspaint,
        post_Glasspaint: TitleModel_Glasspaint
    ) -> UIView {
        let containerView_glasspaint = UIView()
        containerView_glasspaint.backgroundColor = .white
        containerView_glasspaint.layer.cornerRadius = 16
        containerView_glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        containerView_glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView_glasspaint.layer.shadowRadius = 8
        containerView_glasspaint.layer.shadowOpacity = 0.06
        
        // 用户头像
        let avatarView_glasspaint = UserAvatarView_Glasspaint()
        avatarView_glasspaint.configure_Glasspaint(userId_Glasspaint: comment_Glasspaint.commentUserId_Glasspaint)
        containerView_glasspaint.addSubview(avatarView_glasspaint)
        
        // 用户名标签
        let userNameLabel_glasspaint = UILabel()
        userNameLabel_glasspaint.text = comment_Glasspaint.commentUserName_Glasspaint
        userNameLabel_glasspaint.font = .systemFont(ofSize: 15, weight: .semibold)
        userNameLabel_glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        containerView_glasspaint.addSubview(userNameLabel_glasspaint)
        
        // 评论内容标签
        let contentLabel_glasspaint = UILabel()
        contentLabel_glasspaint.text = comment_Glasspaint.commentContent_Glasspaint
        contentLabel_glasspaint.font = .systemFont(ofSize: 14, weight: .regular)
        contentLabel_glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        contentLabel_glasspaint.numberOfLines = 0
        containerView_glasspaint.addSubview(contentLabel_glasspaint)
        
        // 举报/删除按钮
        let reportButton_glasspaint = ReportDeleteHelper_Glasspaint.createCommentReportButton_Glasspaint(
            comment_Glasspaint: comment_Glasspaint,
            post_Glasspaint: post_Glasspaint,
            size_Glasspaint: 20,
            color_Glasspaint: ColorConfig_Glasspaint.textSecondary_Glasspaint,
            from: self
        ) { [weak self] in
            // 评论删除成功后重新加载评论列表
            self?.loadComments_Glasspaint()
        }
        containerView_glasspaint.addSubview(reportButton_glasspaint)
        
        // 约束
        avatarView_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(36)
        }
        
        userNameLabel_glasspaint.snp.makeConstraints { make in
            make.left.equalTo(avatarView_glasspaint.snp.right).offset(12)
            make.top.equalToSuperview().offset(16)
            make.right.lessThanOrEqualTo(reportButton_glasspaint.snp.left).offset(-8)
        }
        
        reportButton_glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
        }
        
        contentLabel_glasspaint.snp.makeConstraints { make in
            make.left.equalTo(avatarView_glasspaint.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(userNameLabel_glasspaint.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        return containerView_glasspaint
    }
    
    // MARK: - 事件处理
    
    /// 处理返回按钮点击
    @objc private func handleBackTap_Glasspaint() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 处理数据变化通知
    @objc private func handleDataChange_Glasspaint() {
        // 数据变化时重新加载
        guard let post_glasspaint = titleModel_Glasspaint else { return }
        
        // 从所有帖子中查找当前帖子
        let allPosts_glasspaint = TitleViewModel_Glasspaint.shared_Glasspaint.getPosts_Glasspaint()
        let updatedPost_glasspaint = allPosts_glasspaint.first { 
            $0.titleId_Glasspaint == post_glasspaint.titleId_Glasspaint 
        }
        
        if let updatedPost_glasspaint = updatedPost_glasspaint {
            // 更新数据
            titleModel_Glasspaint = updatedPost_glasspaint
            
            // 重新加载UI
            loadData_Glasspaint()
        } else {
            // 如果帖子已被删除，返回上一页
            navigationController?.popViewController(animated: true)
        }
    }
    
    /// 评论文本改变
    @objc private func commentTextChanged_Glasspaint() {
        let hasText_glasspaint = !(commentTextField_Glasspaint.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        sendButton_Glasspaint.isEnabled = hasText_glasspaint
        
        UIView.animate(withDuration: 0.2) {
            self.sendButton_Glasspaint.alpha = hasText_glasspaint ? 1.0 : 0.5
        }
    }
    
    /// 处理礼物按钮点击
    @objc private func handleGiftTap_Glasspaint() {
        // 添加点击动画
        UIView.animate(withDuration: 0.1, animations: {
            self.giftButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.giftButton_Glasspaint.transform = .identity
            }
        }
        
        // 打开礼物界面
        let giftVC_glasspaint = GiftViewController_Glasspaint { selectedGift_glasspaint in
            print("✅ 选中礼物：\(selectedGift_glasspaint.goodsName_Glasspaint ?? "")")
            
            // 执行购买
            Store_Glasspaint.shared_Glasspaint.PurchaseStoreGift_Glasspaint(
                gid_Glasspaint: selectedGift_glasspaint.goodsId_Glasspaint ?? "",
                completion_Glasspaint: {
                    print("✅ 购买成功")
                }
            )
        }
        present(giftVC_glasspaint, animated: true)
    }
    
    /// 处理发送评论
    @objc private func handleSendComment_Glasspaint() {
        guard let post_glasspaint = titleModel_Glasspaint,
              let commentText_glasspaint = commentTextField_Glasspaint.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !commentText_glasspaint.isEmpty else {
            return
        }
        
        // 发布评论
        TitleViewModel_Glasspaint.shared_Glasspaint.releaseComment_Glasspaint(
            post_glasspaint: post_glasspaint,
            content_glasspaint: commentText_glasspaint
        )
        
        // 清空输入框
        commentTextField_Glasspaint.text = ""
        commentTextChanged_Glasspaint()
        
        // 关闭键盘
        commentTextField_Glasspaint.resignFirstResponder()
    }
    
    /// 关闭键盘
    @objc private func dismissKeyboard_Glasspaint() {
        view.endEditing(true)
    }
    
    // MARK: - 键盘处理
    
    /// 键盘将显示
    @objc private func keyboardWillShow_Glasspaint(_ notification: Notification) {
        guard let keyboardFrame_glasspaint = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration_glasspaint = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        let keyboardHeight_glasspaint = keyboardFrame_glasspaint.height - view.safeAreaInsets.bottom
        
        UIView.animate(withDuration: duration_glasspaint) {
            self.commentInputContainer_Glasspaint.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-keyboardHeight_glasspaint - 8)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    /// 键盘将隐藏
    @objc private func keyboardWillHide_Glasspaint(_ notification: Notification) {
        guard let duration_glasspaint = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        
        UIView.animate(withDuration: duration_glasspaint) {
            self.commentInputContainer_Glasspaint.snp.updateConstraints { make in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-16)
            }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Glasspaint: UITextFieldDelegate {
    
    /// 处理回车键
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == commentTextField_Glasspaint {
            handleSendComment_Glasspaint()
        }
        return true
    }
}
