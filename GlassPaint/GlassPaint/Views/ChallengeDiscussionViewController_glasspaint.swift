import UIKit
import SnapKit

/// 挑战评论讨论区页面
/// 功能：展示挑战的评论和讨论
/// 设计：渐变边框、阴影效果、丰富的图标元素
class ChallengeDiscussionViewController_Glasspaint: UIViewController {
    
    private let challenge_Glasspaint: ChallengeModel_Glasspaint
    private var comments_Glasspaint: [ChallengeComment_Glasspaint] = []
    
    // UI元素
    private let scrollView_Glasspaint = UIScrollView()
    private let contentView_Glasspaint = UIView()
    
    // 挑战信息区
    private let challengeInfoContainer_Glasspaint = UIView()
    private let challengeGradientLayer_Glasspaint = CAGradientLayer()
    private let challengeIconView_Glasspaint = UIImageView()
    private let challengeTitleLabel_Glasspaint = UILabel()
    private let challengeDescLabel_Glasspaint = UILabel()
    private let participantIconView_Glasspaint = UIImageView()
    private let participantCountLabel_Glasspaint = UILabel()
    private let dividerLine_Glasspaint = UIView()
    
    // 评论区
    private let commentsHeader_Glasspaint = UIView()
    private let commentsIconView_Glasspaint = UIImageView()
    private let commentsTitle_Glasspaint = UILabel()
    private let commentsCountBadge_Glasspaint = UILabel()
    private let commentsTableView_Glasspaint = UITableView()
    
    // 输入区
    private let inputContainer_Glasspaint = UIView()
    private let inputGradientLayer_Glasspaint = CAGradientLayer()
    private let inputTextView_Glasspaint = UITextView()
    private let inputPlaceholderLabel_Glasspaint = UILabel()
    private let sendButton_Glasspaint = UIButton(type: .system)
    
    init(challenge_glasspaint: ChallengeModel_Glasspaint) {
        self.challenge_Glasspaint = challenge_glasspaint
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar_Glasspaint()
        setupUI_Glasspaint()
        loadComments_Glasspaint()
        
        // 监听键盘通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow_Glasspaint), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide_Glasspaint), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 更新渐变层
        challengeGradientLayer_Glasspaint.frame = challengeInfoContainer_Glasspaint.bounds
        inputGradientLayer_Glasspaint.frame = inputContainer_Glasspaint.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        // 确保导航栏显示
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // 设置标题
        title = "Challenge Discussion"
        
        // 设置导航栏颜色
        navigationController?.navigationBar.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        
        // 自定义返回按钮
        let backConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        let backButton_glasspaint = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left", withConfiguration: backConfig_glasspaint),
            style: .plain,
            target: self,
            action: #selector(handleBack_Glasspaint)
        )
        navigationItem.leftBarButtonItem = backButton_glasspaint
    }
    
    /// 返回
    @objc private func handleBack_Glasspaint() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.keyboardDismissMode = .interactive
        
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 挑战信息容器
        contentView_Glasspaint.addSubview(challengeInfoContainer_Glasspaint)
        challengeInfoContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        challengeInfoContainer_Glasspaint.layer.cornerRadius = 20
        challengeInfoContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        challengeInfoContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 4)
        challengeInfoContainer_Glasspaint.layer.shadowRadius = 12
        challengeInfoContainer_Glasspaint.layer.shadowOpacity = 0.15
        
        // 渐变背景层
        challengeGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.05).cgColor,
            ColorConfig_Glasspaint.cardBackground_Glasspaint.cgColor
        ]
        challengeGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        challengeGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        challengeGradientLayer_Glasspaint.cornerRadius = 20
        challengeInfoContainer_Glasspaint.layer.insertSublayer(challengeGradientLayer_Glasspaint, at: 0)
        
        // 挑战图标
        challengeInfoContainer_Glasspaint.addSubview(challengeIconView_Glasspaint)
        let challengeIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
        challengeIconView_Glasspaint.image = UIImage(systemName: "trophy.fill", withConfiguration: challengeIconConfig_glasspaint)
        challengeIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        challengeIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        challengeInfoContainer_Glasspaint.addSubview(challengeTitleLabel_Glasspaint)
        challengeTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        challengeTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        challengeTitleLabel_Glasspaint.numberOfLines = 0
        challengeTitleLabel_Glasspaint.text = challenge_Glasspaint.challengeTitle_Glasspaint
        
        // 分割线
        challengeInfoContainer_Glasspaint.addSubview(dividerLine_Glasspaint)
        dividerLine_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.15)
        
        // 描述
        challengeInfoContainer_Glasspaint.addSubview(challengeDescLabel_Glasspaint)
        challengeDescLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        challengeDescLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        challengeDescLabel_Glasspaint.numberOfLines = 0
        challengeDescLabel_Glasspaint.text = challenge_Glasspaint.challengeDescription_Glasspaint
        
        // 参与人数图标
        challengeInfoContainer_Glasspaint.addSubview(participantIconView_Glasspaint)
        let participantIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        participantIconView_Glasspaint.image = UIImage(systemName: "person.3.fill", withConfiguration: participantIconConfig_glasspaint)
        participantIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        participantIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 参与人数
        challengeInfoContainer_Glasspaint.addSubview(participantCountLabel_Glasspaint)
        participantCountLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        participantCountLabel_Glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        participantCountLabel_Glasspaint.text = "\(challenge_Glasspaint.participantCount_Glasspaint) participants joined"
        
        // 评论头部
        contentView_Glasspaint.addSubview(commentsHeader_Glasspaint)
        
        // 评论图标
        commentsHeader_Glasspaint.addSubview(commentsIconView_Glasspaint)
        let commentsIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        commentsIconView_Glasspaint.image = UIImage(systemName: "bubble.left.and.bubble.right.fill", withConfiguration: commentsIconConfig_glasspaint)
        commentsIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        commentsIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 评论标题
        commentsHeader_Glasspaint.addSubview(commentsTitle_Glasspaint)
        commentsTitle_Glasspaint.text = "Discussions"
        commentsTitle_Glasspaint.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        commentsTitle_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 评论数量徽章
        commentsHeader_Glasspaint.addSubview(commentsCountBadge_Glasspaint)
        commentsCountBadge_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        commentsCountBadge_Glasspaint.textColor = .white
        commentsCountBadge_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        commentsCountBadge_Glasspaint.textAlignment = .center
        commentsCountBadge_Glasspaint.layer.cornerRadius = 10
        commentsCountBadge_Glasspaint.layer.masksToBounds = true
        updateCommentsCountBadge_Glasspaint()
        
        // 评论列表
        contentView_Glasspaint.addSubview(commentsTableView_Glasspaint)
        commentsTableView_Glasspaint.delegate = self
        commentsTableView_Glasspaint.dataSource = self
        commentsTableView_Glasspaint.backgroundColor = .clear
        commentsTableView_Glasspaint.separatorStyle = .none
        commentsTableView_Glasspaint.register(CommentCell_Glasspaint.self, forCellReuseIdentifier: "CommentCell")
        commentsTableView_Glasspaint.isScrollEnabled = false
        commentsTableView_Glasspaint.estimatedRowHeight = 130
        commentsTableView_Glasspaint.rowHeight = UITableView.automaticDimension
        
        // 输入容器
        view.addSubview(inputContainer_Glasspaint)
        inputContainer_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        inputContainer_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        inputContainer_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: -3)
        inputContainer_Glasspaint.layer.shadowRadius = 10
        inputContainer_Glasspaint.layer.shadowOpacity = 0.1
        
        // 输入区渐变层
        inputGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.03).cgColor,
            ColorConfig_Glasspaint.cardBackground_Glasspaint.cgColor
        ]
        inputGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        inputGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 0)
        inputContainer_Glasspaint.layer.insertSublayer(inputGradientLayer_Glasspaint, at: 0)
        
        // 输入框容器
        inputContainer_Glasspaint.addSubview(inputTextView_Glasspaint)
        inputTextView_Glasspaint.delegate = self
        inputTextView_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        inputTextView_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        inputTextView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundSecondary_Glasspaint
        inputTextView_Glasspaint.layer.cornerRadius = 22
        inputTextView_Glasspaint.layer.borderWidth = 1.5
        inputTextView_Glasspaint.layer.borderColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.2).cgColor
        inputTextView_Glasspaint.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        // 占位符
        inputTextView_Glasspaint.addSubview(inputPlaceholderLabel_Glasspaint)
        inputPlaceholderLabel_Glasspaint.text = "Share your thoughts..."
        inputPlaceholderLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        inputPlaceholderLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.6)
        
        // 发送按钮
        inputContainer_Glasspaint.addSubview(sendButton_Glasspaint)
        let sendConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let sendImage_glasspaint = UIImage(systemName: "paperplane.fill", withConfiguration: sendConfig_glasspaint)
        sendButton_Glasspaint.setImage(sendImage_glasspaint, for: .normal)
        sendButton_Glasspaint.tintColor = .white
        sendButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        sendButton_Glasspaint.layer.cornerRadius = 22
        sendButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        sendButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        sendButton_Glasspaint.layer.shadowRadius = 6
        sendButton_Glasspaint.layer.shadowOpacity = 0.3
        sendButton_Glasspaint.addTarget(self, action: #selector(handleSend_Glasspaint), for: .touchUpInside)
        
        setupConstraints_Glasspaint()
    }
    
    /// 设置约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalTo(inputContainer_Glasspaint.snp.top)
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView_Glasspaint)
        }
        
        challengeInfoContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
        }
        
        challengeIconView_Glasspaint.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(20)
            make.width.height.equalTo(36)
        }
        
        challengeTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(challengeIconView_Glasspaint.snp.right).offset(12)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(challengeIconView_Glasspaint)
        }
        
        dividerLine_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(challengeIconView_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(1)
        }
        
        challengeDescLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(dividerLine_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
        }
        
        participantIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(challengeDescLabel_Glasspaint.snp.bottom).offset(16)
            make.bottom.equalToSuperview().offset(-20)
            make.width.height.equalTo(18)
        }
        
        participantCountLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(participantIconView_Glasspaint.snp.right).offset(8)
            make.centerY.equalTo(participantIconView_Glasspaint)
        }
        
        commentsHeader_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(challengeInfoContainer_Glasspaint.snp.bottom).offset(28)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(32)
        }
        
        commentsIconView_Glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        commentsTitle_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(commentsIconView_Glasspaint.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        commentsCountBadge_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(commentsTitle_Glasspaint.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.width.greaterThanOrEqualTo(32)
            make.height.equalTo(20)
        }
        
        commentsTableView_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(commentsHeader_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        inputContainer_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(72)
        }
        
        inputTextView_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.height.equalTo(44)
        }
        
        inputPlaceholderLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(12)
        }
        
        sendButton_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(inputTextView_Glasspaint.snp.right).offset(12)
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
    }
    
    /// 更新评论数量徽章
    private func updateCommentsCountBadge_Glasspaint() {
        commentsCountBadge_Glasspaint.text = "\(comments_Glasspaint.count)"
    }
    
    /// 加载评论
    private func loadComments_Glasspaint() {
        // 为每个挑战生成2条相关评论
        comments_Glasspaint = generateComments_Glasspaint(for: challenge_Glasspaint)
        updateCommentsCountBadge_Glasspaint()
        commentsTableView_Glasspaint.reloadData()
        
        // 延迟更新表格高度，确保单元格已完成布局
        DispatchQueue.main.async {
            self.updateTableViewHeight_Glasspaint()
        }
    }
    
    /// 更新表格视图高度
    private func updateTableViewHeight_Glasspaint() {
        // 强制布局以计算实际内容高度
        commentsTableView_Glasspaint.layoutIfNeeded()
        
        // 使用表格实际内容高度
        let totalHeight_glasspaint = commentsTableView_Glasspaint.contentSize.height
        
        commentsTableView_Glasspaint.snp.updateConstraints { make in
            make.height.equalTo(max(totalHeight_glasspaint, 100))
        }
        
        // 通知父视图布局更新
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// 生成评论
    /// 参数：
    /// - challenge_glasspaint: 挑战数据
    /// 返回：生成的评论数组
    private func generateComments_Glasspaint(for challenge_glasspaint: ChallengeModel_Glasspaint) -> [ChallengeComment_Glasspaint] {
        let users_glasspaint = LocalData_Glasspaint.shared_Glasspaint.userList_Glasspaint
        guard users_glasspaint.count >= 2 else { return [] }
        
        // 根据挑战类型生成相关评论
        let commentsData_glasspaint = getCommentsForChallenge_Glasspaint(challenge_glasspaint)
        
        var comments_glasspaint: [ChallengeComment_Glasspaint] = []
        for (index_glasspaint, commentText_glasspaint) in commentsData_glasspaint.enumerated() {
            let user_glasspaint = users_glasspaint[index_glasspaint]
            guard let userId_glasspaint = user_glasspaint.userId_Glasspaint,
                  let userName_glasspaint = user_glasspaint.userName_Glasspaint else { continue }
            
            let comment_glasspaint = ChallengeComment_Glasspaint(
                commentId_glasspaint: "comment_\(index_glasspaint)",
                userId_glasspaint: userId_glasspaint,
                userName_glasspaint: userName_glasspaint,
                content_glasspaint: commentText_glasspaint,
                createdDate_glasspaint: Date().addingTimeInterval(-Double(index_glasspaint + 1) * 3600)
            )
            comments_glasspaint.append(comment_glasspaint)
        }
        
        return comments_glasspaint
    }
    
    /// 根据挑战获取评论内容
    /// 参数：
    /// - challenge_glasspaint: 挑战数据
    /// 返回：评论内容数组
    private func getCommentsForChallenge_Glasspaint(_ challenge_glasspaint: ChallengeModel_Glasspaint) -> [String] {
        let title_glasspaint = challenge_glasspaint.challengeTitle_Glasspaint.lowercased()
        
        if title_glasspaint.contains("glass") || title_glasspaint.contains("cup") {
            return [
                "This glass painting challenge is amazing! The transparency effects are so delicate and beautiful.",
                "I love painting on glass surfaces! The way light plays through the paint creates such magical results."
            ]
        } else if title_glasspaint.contains("vase") || title_glasspaint.contains("bottle") {
            return [
                "Curved surfaces are tricky but so rewarding! Can't wait to try this challenge.",
                "The bottle design possibilities are endless. Looking forward to seeing everyone's creative interpretations!"
            ]
        } else if title_glasspaint.contains("window") || title_glasspaint.contains("panel") {
            return [
                "Window painting is such a classic art form. Excited to explore traditional techniques!",
                "I've always admired stained glass art. This challenge will help me learn the fundamentals."
            ]
        } else {
            return [
                "This challenge looks really interesting! Can't wait to see what everyone creates.",
                "Love the creativity in this community. Ready to join this challenge!"
            ]
        }
    }
    
    /// 处理举报评论
    /// 参数：
    /// - comment_glasspaint: 被举报的评论
    private func handleReportComment_Glasspaint(_ comment_glasspaint: ChallengeComment_Glasspaint) {
        // 显示举报确认对话框
        UIAlertController.report_Glasspaint(with: false) { [weak self] in
            guard let self = self else { return }
            
            // 从列表中移除该评论
            if let index_glasspaint = self.comments_Glasspaint.firstIndex(where: { $0.commentId_glasspaint == comment_glasspaint.commentId_glasspaint }) {
                self.comments_Glasspaint.remove(at: index_glasspaint)
                
                // 更新UI
                self.commentsTableView_Glasspaint.deleteRows(at: [IndexPath(row: index_glasspaint, section: 0)], with: .fade)
                self.updateCommentsCountBadge_Glasspaint()
                self.updateTableViewHeight_Glasspaint()
                
                // 显示成功提示
                Utils_Glasspaint.showSuccess_Glasspaint(message_Glasspaint: "This comment will no longer appear.", delay_Glasspaint: 1.5)
                
                print("已举报评论: \(comment_glasspaint.content_glasspaint)")
            }
        }
    }
    
    /// 发送评论
    @objc private func handleSend_Glasspaint() {
        guard let text_glasspaint = inputTextView_Glasspaint.text, !text_glasspaint.isEmpty else {
            return
        }
        
        // 检查是否登录
        guard UserViewModel_Glasspaint.shared_Glasspaint.isLoggedIn_Glasspaint else {
            // 延迟跳转到登录页面
            Task {
                try? await Task.sleep(nanoseconds: 500_000_000) // 1.5秒
                Navigation_Glasspaint.toLogin_Glasspaint(style_glasspaint: .present_glasspaint)
            }
            return }
        
        // 获取当前用户
        let currentUser_glasspaint = UserViewModel_Glasspaint.shared_Glasspaint.getCurrentUser_Glasspaint()
        guard let userId_glasspaint = currentUser_glasspaint.userId_Glasspaint,
              let userName_glasspaint = currentUser_glasspaint.userName_Glasspaint else {
            return
        }
        
        // 创建新评论
        let comment_glasspaint = ChallengeComment_Glasspaint(
            commentId_glasspaint: "comment_\(Date().timeIntervalSince1970)",
            userId_glasspaint: userId_glasspaint,
            userName_glasspaint: userName_glasspaint,
            content_glasspaint: text_glasspaint,
            createdDate_glasspaint: Date()
        )
        
        comments_Glasspaint.append(comment_glasspaint)
        updateCommentsCountBadge_Glasspaint()
        commentsTableView_Glasspaint.reloadData()
        
        // 延迟更新表格高度，确保单元格已完成布局
        DispatchQueue.main.async {
            self.updateTableViewHeight_Glasspaint()
        }
        
        // 清空输入框
        inputTextView_Glasspaint.text = ""
        inputPlaceholderLabel_Glasspaint.isHidden = false
        
        // 发送按钮动画
        UIView.animate(withDuration: 0.2, animations: {
            self.sendButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.sendButton_Glasspaint.transform = .identity
            }
        }
    }
    
    /// 键盘将要显示
    @objc private func keyboardWillShow_Glasspaint(_ notification: Notification) {
        guard let keyboardFrame_glasspaint = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight_glasspaint = keyboardFrame_glasspaint.height
        inputContainer_Glasspaint.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-keyboardHeight_glasspaint)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    /// 键盘将要隐藏
    @objc private func keyboardWillHide_Glasspaint(_ notification: Notification) {
        inputContainer_Glasspaint.snp.updateConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDelegate & DataSource

extension ChallengeDiscussionViewController_Glasspaint: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments_Glasspaint.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell_glasspaint = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell_Glasspaint
        cell_glasspaint.configure_Glasspaint(with: comments_Glasspaint[indexPath.row])
        cell_glasspaint.onReport_Glasspaint = { [weak self] comment_glasspaint in
            self?.handleReportComment_Glasspaint(comment_glasspaint)
        }
        return cell_glasspaint
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

// MARK: - UITextViewDelegate

extension ChallengeDiscussionViewController_Glasspaint: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        inputPlaceholderLabel_Glasspaint.isHidden = !textView.text.isEmpty
    }
}

// MARK: - 评论Cell

/// 评论单元格
/// 功能：展示评论内容并支持举报操作
/// 设计：渐变边框、头像容器、时间图标、举报按钮
class CommentCell_Glasspaint: UITableViewCell {
    
    private let containerView_Glasspaint = UIView()
    private let gradientBorderLayer_Glasspaint = CAGradientLayer()
    private let avatarContainer_Glasspaint = UIView()
    private let avatarGradientLayer_Glasspaint = CAGradientLayer()
    private let avatarView_Glasspaint = UserAvatarView_Glasspaint()
    private let nameLabel_Glasspaint = UILabel()
    private let timeIconView_Glasspaint = UIImageView()
    private let timeLabel_Glasspaint = UILabel()
    private let contentLabel_Glasspaint = UILabel()
    private let reportButton_Glasspaint = UIButton(type: .system)
    
    private var currentComment_Glasspaint: ChallengeComment_Glasspaint?
    
    /// 举报回调
    var onReport_Glasspaint: ((ChallengeComment_Glasspaint) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI_Glasspaint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 更新渐变边框
        gradientBorderLayer_Glasspaint.frame = containerView_Glasspaint.bounds
        if let maskLayer_glasspaint = gradientBorderLayer_Glasspaint.mask as? CAShapeLayer {
            maskLayer_glasspaint.path = UIBezierPath(
                roundedRect: containerView_Glasspaint.bounds,
                cornerRadius: 16
            ).cgPath
        }
        
        // 更新头像渐变
        avatarGradientLayer_Glasspaint.frame = avatarContainer_Glasspaint.bounds
    }
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // 容器
        contentView.addSubview(containerView_Glasspaint)
        containerView_Glasspaint.backgroundColor = ColorConfig_Glasspaint.cardBackground_Glasspaint
        containerView_Glasspaint.layer.cornerRadius = 16
        containerView_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        containerView_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView_Glasspaint.layer.shadowRadius = 6
        containerView_Glasspaint.layer.shadowOpacity = 0.08
        
        // 渐变边框层
        gradientBorderLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.3).cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.withAlphaComponent(0.1).cgColor
        ]
        gradientBorderLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        gradientBorderLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        gradientBorderLayer_Glasspaint.cornerRadius = 16
        
        let borderMask_glasspaint = CAShapeLayer()
        borderMask_glasspaint.fillColor = UIColor.clear.cgColor
        borderMask_glasspaint.strokeColor = UIColor.white.cgColor
        borderMask_glasspaint.lineWidth = 2
        gradientBorderLayer_Glasspaint.mask = borderMask_glasspaint
        containerView_Glasspaint.layer.addSublayer(gradientBorderLayer_Glasspaint)
        
        // 头像容器
        containerView_Glasspaint.addSubview(avatarContainer_Glasspaint)
        avatarContainer_Glasspaint.layer.cornerRadius = 26
        avatarContainer_Glasspaint.layer.masksToBounds = true
        
        // 头像容器渐变
        avatarGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.15).cgColor,
            ColorConfig_Glasspaint.primaryGradientEnd_Glasspaint.withAlphaComponent(0.05).cgColor
        ]
        avatarGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        avatarGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        avatarContainer_Glasspaint.layer.addSublayer(avatarGradientLayer_Glasspaint)
        
        // 头像
        avatarContainer_Glasspaint.addSubview(avatarView_Glasspaint)
        
        // 用户名
        containerView_Glasspaint.addSubview(nameLabel_Glasspaint)
        nameLabel_Glasspaint.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        nameLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 时间图标
        containerView_Glasspaint.addSubview(timeIconView_Glasspaint)
        let timeIconConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 11, weight: .medium)
        timeIconView_Glasspaint.image = UIImage(systemName: "clock.fill", withConfiguration: timeIconConfig_glasspaint)
        timeIconView_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.7)
        timeIconView_Glasspaint.contentMode = .scaleAspectFit
        
        // 时间
        containerView_Glasspaint.addSubview(timeLabel_Glasspaint)
        timeLabel_Glasspaint.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        timeLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textSecondary_Glasspaint
        
        // 内容
        containerView_Glasspaint.addSubview(contentLabel_Glasspaint)
        contentLabel_Glasspaint.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        contentLabel_Glasspaint.numberOfLines = 0
        
        // 举报按钮
        containerView_Glasspaint.addSubview(reportButton_Glasspaint)
        let reportConfig_glasspaint = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        let reportImage_glasspaint = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: reportConfig_glasspaint)
        reportButton_Glasspaint.setImage(reportImage_glasspaint, for: .normal)
        reportButton_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.6)
        reportButton_Glasspaint.backgroundColor = ColorConfig_Glasspaint.backgroundSecondary_Glasspaint
        reportButton_Glasspaint.layer.cornerRadius = 18
        reportButton_Glasspaint.layer.shadowColor = ColorConfig_Glasspaint.shadowColor_Glasspaint.cgColor
        reportButton_Glasspaint.layer.shadowOffset = CGSize(width: 0, height: 1)
        reportButton_Glasspaint.layer.shadowRadius = 3
        reportButton_Glasspaint.layer.shadowOpacity = 0.1
        reportButton_Glasspaint.addTarget(self, action: #selector(handleReportTap_Glasspaint), for: .touchUpInside)
        
        // 布局
        containerView_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-6)
        }
        
        avatarContainer_Glasspaint.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(16)
            make.width.height.equalTo(52)
        }
        
        avatarView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(32)
        }
        
        nameLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(avatarContainer_Glasspaint.snp.right).offset(14)
            make.top.equalTo(avatarContainer_Glasspaint).offset(4)
            make.right.equalTo(reportButton_Glasspaint.snp.left).offset(-12)
        }
        
        timeIconView_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(nameLabel_Glasspaint)
            make.top.equalTo(nameLabel_Glasspaint.snp.bottom).offset(6)
            make.width.height.equalTo(13)
        }
        
        timeLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(timeIconView_Glasspaint.snp.right).offset(6)
            make.centerY.equalTo(timeIconView_Glasspaint)
        }
        
        reportButton_Glasspaint.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(16)
            make.width.height.equalTo(36)
        }
        
        contentLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(timeIconView_Glasspaint.snp.bottom).offset(12)
            make.left.equalTo(nameLabel_Glasspaint)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-16)
        }
    }
    
    /// 配置评论
    /// 参数：
    /// - comment_glasspaint: 评论数据
    func configure_Glasspaint(with comment_glasspaint: ChallengeComment_Glasspaint) {
        currentComment_Glasspaint = comment_glasspaint
        nameLabel_Glasspaint.text = comment_glasspaint.userName_glasspaint
        contentLabel_Glasspaint.text = comment_glasspaint.content_glasspaint
        
        // 配置头像
        avatarView_Glasspaint.configure_Glasspaint(userId_Glasspaint: comment_glasspaint.userId_glasspaint)
        
        // 格式化时间
        let formatter_glasspaint = DateFormatter()
        formatter_glasspaint.dateFormat = "HH:mm"
        timeLabel_Glasspaint.text = formatter_glasspaint.string(from: comment_glasspaint.createdDate_glasspaint)
    }
    
    /// 处理举报点击
    @objc private func handleReportTap_Glasspaint() {
        guard let comment_glasspaint = currentComment_Glasspaint else { return }
        
        // 按钮动画效果
        UIView.animate(withDuration: 0.15, animations: {
            self.reportButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            self.reportButton_Glasspaint.tintColor = UIColor.systemRed
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.reportButton_Glasspaint.transform = .identity
                self.reportButton_Glasspaint.tintColor = ColorConfig_Glasspaint.textSecondary_Glasspaint.withAlphaComponent(0.6)
            }
        }
        
        onReport_Glasspaint?(comment_glasspaint)
    }
}

// MARK: - 评论模型

/// 挑战评论模型
/// 功能：存储评论的基本信息
class ChallengeComment_Glasspaint: NSObject {
    var commentId_glasspaint: String
    var userId_glasspaint: Int
    var userName_glasspaint: String
    var content_glasspaint: String
    var createdDate_glasspaint: Date
    
    /// 初始化方法
    /// 参数：
    /// - commentId_glasspaint: 评论ID
    /// - userId_glasspaint: 用户ID
    /// - userName_glasspaint: 用户名
    /// - content_glasspaint: 评论内容
    /// - createdDate_glasspaint: 创建时间
    init(commentId_glasspaint: String, userId_glasspaint: Int, userName_glasspaint: String, content_glasspaint: String, createdDate_glasspaint: Date) {
        self.commentId_glasspaint = commentId_glasspaint
        self.userId_glasspaint = userId_glasspaint
        self.userName_glasspaint = userName_glasspaint
        self.content_glasspaint = content_glasspaint
        self.createdDate_glasspaint = createdDate_glasspaint
    }
}
