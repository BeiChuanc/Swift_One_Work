import Foundation
import UIKit
import SnapKit

// MARK: 帖子详情页
// 设计思路：
//   全屏媒体区顶部铺满（300pt），底部渐变蒙版过渡到信息卡片；
//   信息卡片（圆角 28）以 -30pt 偏移叠压在媒体底部，形成层叠感；
//   卡片内依次展示：作者行（头像环 + 名字 + Chat 按钮）、帖子标题、内容、
//   统计行（点赞 + 评论数）、渐变点赞按钮、评论区；
//   底部固定评论输入栏（输入框 + 渐变发送按钮）。
//   整体色调与全局统一（深紫-靛蓝主色系）。
// 关键属性：
//   titleModel_Echd — 帖子数据模型（由上一页传入）

/// 帖子详情页视图控制器
class Detail_Echd: UIViewController {

    // MARK: - 属性

    /// 帖子数据模型（由外部传入）
    var titleModel_Echd: TitleModel_Echd?

    // MARK: - UI组件 / 悬浮导航

    /// 返回按钮（白色毛玻璃，浮于媒体区）
    private let backButton_Echd = BackButton_Echd()

    /// 举报/删除按钮（懒加载）
    private var reportButton_Echd: UIButton?

    // MARK: - UI组件 / 媒体区

    /// 主滚动视图
    private let scrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsVerticalScrollIndicator = false
        sv_Echd.alwaysBounceVertical = true
        sv_Echd.keyboardDismissMode = .onDrag
        return sv_Echd
    }()

    /// 内容容器
    private let contentView_Echd = UIView()

    /// 媒体展示视图（顶部全幅）
    private let mediaDisplayView_Echd = MediaDisplayView_Echd()

    /// 媒体底部渐变蒙版（过渡到白色信息卡片）
    private let mediaGradientMask_Echd: DetailGradientMask_Echd = {
        return DetailGradientMask_Echd()
    }()

    // MARK: - UI组件 / 信息卡片

    /// 帖子信息卡片（叠压在媒体底部）
    private let postCard_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
        view_Echd.layer.cornerRadius = 28
        view_Echd.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view_Echd.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: -4)
        view_Echd.layer.shadowRadius = 16
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    // MARK: - UI组件 / 作者行

    /// 作者头像环（accent 颜色边框）
    private let authorRingView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.layer.cornerRadius = 24
        view_Echd.layer.borderWidth = 2.5
        view_Echd.layer.borderColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.5).cgColor
        return view_Echd
    }()

    /// 作者头像
    private let authorAvatarView_Echd = UserAvatarView_Echd()

    /// 作者名字
    private let authorNameLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        return label_Echd
    }()

    /// 发布时间标签
    private let postTimeLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 11)
        label_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        return label_Echd
    }()

    /// Chat 快捷按钮（跳转聊天）
    private let chatButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .system)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn_Echd.setImage(UIImage(systemName: "message.fill", withConfiguration: cfg_Echd), for: .normal)
        btn_Echd.setTitle("  Chat", for: .normal)
        btn_Echd.tintColor = UIColor(hexstring_Echd: "#7C3AED")
        btn_Echd.setTitleColor(UIColor(hexstring_Echd: "#7C3AED"), for: .normal)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        btn_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.1)
        btn_Echd.layer.cornerRadius = 14
        btn_Echd.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return btn_Echd
    }()

    // MARK: - UI组件 / 帖子内容

    /// 帖子标题
    private let postTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 22, weight: .black)
        label_Echd.textColor = UIColor(hexstring_Echd: "#111827")
        label_Echd.numberOfLines = 0
        return label_Echd
    }()

    /// 帖子内容
    private let postContentLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 15)
        label_Echd.textColor = UIColor(hexstring_Echd: "#374151")
        label_Echd.numberOfLines = 0
        label_Echd.lineBreakMode = .byWordWrapping
        return label_Echd
    }()

    // MARK: - UI组件 / 统计行

    /// 统计行容器
    private let statsRow_Echd = UIView()

    /// 点赞数展示标签
    private let likesCountLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label_Echd.textColor = UIColor(hexstring_Echd: "#6B7280")
        return label_Echd
    }()

    /// 评论数展示标签
    private let commentsCountLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label_Echd.textColor = UIColor(hexstring_Echd: "#6B7280")
        return label_Echd
    }()

    /// 点赞按钮（渐变胶囊）
    private let likeButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        btn_Echd.layer.cornerRadius = 22
        btn_Echd.layer.masksToBounds = true
        btn_Echd.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return btn_Echd
    }()

    /// 点赞按钮渐变图层
    private var likeGradient_Echd: CAGradientLayer?

    // MARK: - UI组件 / 评论区

    /// 分隔线
    private let divider_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#E5E7EB")
        return view_Echd
    }()

    /// 评论标题行
    private let commentsTitleRow_Echd = UIView()

    /// 评论标题标签
    private let commentsTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Comments"
        label_Echd.font = UIFont.systemFont(ofSize: 17, weight: .black)
        label_Echd.textColor = UIColor(hexstring_Echd: "#111827")
        return label_Echd
    }()

    /// 评论列表 StackView
    private let commentsStackView_Echd: UIStackView = {
        let sv_Echd = UIStackView()
        sv_Echd.axis = .vertical
        sv_Echd.spacing = 10
        return sv_Echd
    }()

    // MARK: - UI组件 / 底部输入栏

    /// 评论输入条容器
    /// 固定高度 64pt，不依赖 safeArea 动态计算，避免发送按钮尺寸不一致变成椭圆
    private let commentBar_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.shadowColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.06).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: -2)
        view_Echd.layer.shadowRadius = 8
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    /// 评论输入框容器（极浅紫背景，更柔和）
    private let commentInputWrap_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#EDE9FE")  // 极浅紫
        view_Echd.layer.cornerRadius = 20
        return view_Echd
    }()

    /// 评论输入框
    private let commentTextField_Echd: UITextField = {
        let tf_Echd = UITextField()
        tf_Echd.attributedPlaceholder = NSAttributedString(
            string: "Add a comment...",
            attributes: [.foregroundColor: UIColor(hexstring_Echd: "#A78BFA")]  // 中紫色占位符
        )
        tf_Echd.font = UIFont.systemFont(ofSize: 14)
        tf_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        tf_Echd.backgroundColor = .clear
        tf_Echd.borderStyle = .none
        tf_Echd.autocorrectionType = .no
        return tf_Echd
    }()

    /// 发送按钮（42×42 严格正方形，cornerRadius=21 才能得到真圆）
    private let sendCommentButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        btn_Echd.setImage(UIImage(systemName: "paperplane.fill", withConfiguration: cfg_Echd), for: .normal)
        btn_Echd.tintColor = .white
        btn_Echd.layer.cornerRadius = 21   // 42/2 = 21，配合固定 42×42 尺寸
        btn_Echd.layer.masksToBounds = true
        return btn_Echd
    }()

    // sendGradient 已移除，发送按钮改用 backgroundColor

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
        setupUI_Echd()
        setupConstraints_Echd()
        loadPostData_Echd()
        observeNotifications_Echd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        likeGradient_Echd?.frame = likeButton_Echd.bounds
        // 发送按钮使用 backgroundColor，无需在此更新渐变 frame
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI设置

    private func setupUI_Echd() {
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(contentView_Echd)

        // 媒体区
        contentView_Echd.addSubview(mediaDisplayView_Echd)
        contentView_Echd.addSubview(mediaGradientMask_Echd)

        // 信息卡片
        contentView_Echd.addSubview(postCard_Echd)

        // 作者行
        postCard_Echd.addSubview(authorRingView_Echd)
        authorRingView_Echd.addSubview(authorAvatarView_Echd)
        postCard_Echd.addSubview(authorNameLabel_Echd)
        postCard_Echd.addSubview(postTimeLabel_Echd)
        postCard_Echd.addSubview(chatButton_Echd)

        // 帖子内容
        postCard_Echd.addSubview(postTitleLabel_Echd)
        postCard_Echd.addSubview(postContentLabel_Echd)

        // 统计行
        postCard_Echd.addSubview(statsRow_Echd)
        statsRow_Echd.addSubview(likesCountLabel_Echd)
        statsRow_Echd.addSubview(commentsCountLabel_Echd)

        // 点赞按钮渐变
        postCard_Echd.addSubview(likeButton_Echd)
        let lg_Echd = CAGradientLayer()
        lg_Echd.colors = [UIColor(hexstring_Echd: "#7C3AED").cgColor, UIColor(hexstring_Echd: "#4F46E5").cgColor]
        lg_Echd.startPoint = CGPoint(x: 0, y: 0.5)
        lg_Echd.endPoint = CGPoint(x: 1, y: 0.5)
        likeButton_Echd.layer.insertSublayer(lg_Echd, at: 0)
        likeGradient_Echd = lg_Echd
        likeButton_Echd.addTarget(self, action: #selector(likeTapped_Echd), for: .touchUpInside)

        // 评论区
        postCard_Echd.addSubview(divider_Echd)
        postCard_Echd.addSubview(commentsTitleRow_Echd)
        commentsTitleRow_Echd.addSubview(commentsTitleLabel_Echd)
        postCard_Echd.addSubview(commentsStackView_Echd)

        // 悬浮导航
        view.addSubview(backButton_Echd)
        backButton_Echd.onTapped_Echd = { Navigation_Echd.pop_Echd() }

        // 作者点击
        let authorTap_Echd = UITapGestureRecognizer(target: self, action: #selector(authorTapped_Echd))
        authorRingView_Echd.addGestureRecognizer(authorTap_Echd)
        authorRingView_Echd.isUserInteractionEnabled = true
        let nameTap_Echd = UITapGestureRecognizer(target: self, action: #selector(authorTapped_Echd))
        authorNameLabel_Echd.isUserInteractionEnabled = true
        authorNameLabel_Echd.addGestureRecognizer(nameTap_Echd)
        chatButton_Echd.addTarget(self, action: #selector(chatTapped_Echd), for: .touchUpInside)

        // 底部评论输入栏
        view.addSubview(commentBar_Echd)
        commentBar_Echd.addSubview(commentInputWrap_Echd)
        commentInputWrap_Echd.addSubview(commentTextField_Echd)
        commentBar_Echd.addSubview(sendCommentButton_Echd)

        // 直接使用 backgroundColor，避免 CAGradientLayer 初始 frame=zero 时遮住 imageView
        sendCommentButton_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED")
        sendCommentButton_Echd.addTarget(self, action: #selector(sendCommentTapped_Echd), for: .touchUpInside)
    }

    // MARK: - 约束布局

    private func setupConstraints_Echd() {
        let sw_Echd = UIScreen.main.bounds.width

        backButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }

        scrollView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(commentBar_Echd.snp.top)
        }
        contentView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sw_Echd)
        }

        // 媒体区（顶部全幅，280pt）
        mediaDisplayView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(280)
        }
        mediaGradientMask_Echd.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(mediaDisplayView_Echd)
            make.height.equalTo(100)
        }

        // 信息卡片（叠压媒体，-30pt 偏移）
        postCard_Echd.snp.makeConstraints { make in
            make.top.equalTo(mediaDisplayView_Echd.snp.bottom).offset(-30)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 作者行
        authorRingView_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(48)
        }
        authorAvatarView_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(42)
        }
        authorNameLabel_Echd.snp.makeConstraints { make in
            make.leading.equalTo(authorRingView_Echd.snp.trailing).offset(12)
            make.top.equalTo(authorRingView_Echd.snp.top).offset(4)
        }
        postTimeLabel_Echd.snp.makeConstraints { make in
            make.leading.equalTo(authorRingView_Echd.snp.trailing).offset(12)
            make.top.equalTo(authorNameLabel_Echd.snp.bottom).offset(3)
        }
        chatButton_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(authorRingView_Echd)
            make.height.equalTo(32)
        }

        // 帖子标题
        postTitleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(authorRingView_Echd.snp.bottom).offset(18)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        // 帖子内容
        postContentLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel_Echd.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        // 统计行
        statsRow_Echd.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel_Echd.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(20)
        }
        likesCountLabel_Echd.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }
        commentsCountLabel_Echd.snp.makeConstraints { make in
            make.leading.equalTo(likesCountLabel_Echd.snp.trailing).offset(20)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
        }

        // 点赞按钮
        likeButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(statsRow_Echd.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(44)
            make.width.greaterThanOrEqualTo(140)
        }

        // 分隔线
        divider_Echd.snp.makeConstraints { make in
            make.top.equalTo(likeButton_Echd.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }

        // 评论标题
        commentsTitleRow_Echd.snp.makeConstraints { make in
            make.top.equalTo(divider_Echd.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(24)
        }
        commentsTitleLabel_Echd.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        // 评论列表
        commentsStackView_Echd.snp.makeConstraints { make in
            make.top.equalTo(commentsTitleRow_Echd.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-24)
        }

        // 底部评论输入栏
        // 固定高度 64pt + safeArea 背景延伸：输入条高度确定，发送按钮尺寸稳定
        commentBar_Echd.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(64 + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0))
        }
        // 发送按钮：严格 42×42，在输入条内垂直居中（距右 16pt）
        sendCommentButton_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview().offset(-(UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) / 2)
            make.width.height.equalTo(42)  // 严格正方形 → cornerRadius=21 = 真圆
        }
        // 输入框：从左侧 14pt 到发送按钮左侧 10pt，高度 44，垂直居中
        commentInputWrap_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalTo(sendCommentButton_Echd.snp.leading).offset(-10)
            make.centerY.equalTo(sendCommentButton_Echd)
            make.height.equalTo(44)
        }
        commentTextField_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.centerY.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    /// 加载帖子数据填充 UI
    private func loadPostData_Echd() {
        guard let post_Echd = titleModel_Echd else { return }

        mediaDisplayView_Echd.configure_Echd(mediaPath_Echd: post_Echd.titleMeidas_Echd.first)
        authorAvatarView_Echd.configure_Echd(userId_Echd: post_Echd.titleUserId_Echd)
        authorNameLabel_Echd.text = post_Echd.titleUserName_Echd
        postTimeLabel_Echd.text = "spark ✦"
        postTitleLabel_Echd.text = post_Echd.title_Echd
        postContentLabel_Echd.text = post_Echd.titleContent_Echd

        updateStatsRow_Echd(post_Echd: post_Echd)
        updateLikeButton_Echd(post_Echd: post_Echd)
        setupReportButton_Echd(post_Echd: post_Echd)
        refreshComments_Echd(post_Echd: post_Echd)

        // 如果是自己的帖子，隐藏 Chat 按钮
        if UserViewModel_Echd.shared_Echd.isCurrentUser_Echd(userId_echd: post_Echd.titleUserId_Echd) {
            chatButton_Echd.isHidden = true
        }
    }

    /// 更新统计行数字
    private func updateStatsRow_Echd(post_Echd: TitleModel_Echd) {
        likesCountLabel_Echd.attributedText = makeStatAttr_Echd(
            icon: "flame.fill",
            count: post_Echd.likes_Echd,
            color: UIColor(hexstring_Echd: "#F43F5E")
        )
        commentsCountLabel_Echd.attributedText = makeStatAttr_Echd(
            icon: "bubble.left.fill",
            count: post_Echd.reviews_Echd.count,
            color: UIColor(hexstring_Echd: "#7C3AED")
        )
    }

    /// 构建统计标签 AttributedString
    private func makeStatAttr_Echd(icon: String, count: Int, color: UIColor) -> NSAttributedString {
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let attach_Echd = NSTextAttachment()
        attach_Echd.image = UIImage(systemName: icon, withConfiguration: cfg_Echd)?.withTintColor(color)
        let str_Echd = NSMutableAttributedString(attachment: attach_Echd)
        str_Echd.append(NSAttributedString(
            string: "  \(count)",
            attributes: [.foregroundColor: UIColor(hexstring_Echd: "#6B7280"),
                         .font: UIFont.systemFont(ofSize: 13, weight: .semibold)]
        ))
        return str_Echd
    }

    /// 配置举报/删除按钮
    private func setupReportButton_Echd(post_Echd: TitleModel_Echd) {
        reportButton_Echd?.removeFromSuperview()
        let btn_Echd = ReportDeleteHelper_Echd.createPostReportButton_Echd(
            post_Echd: post_Echd,
            size_Echd: 14,
            color_Echd: UIColor(hexstring_Echd: "#6B7280"),
            from: self,
            completion_Echd: { Navigation_Echd.pop_Echd() }
        )
        btn_Echd.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        btn_Echd.layer.cornerRadius = 18
        view.addSubview(btn_Echd)
        btn_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(backButton_Echd)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(36)
        }
        reportButton_Echd = btn_Echd
    }

    /// 更新点赞按钮状态（渐变 or 描边）
    private func updateLikeButton_Echd(post_Echd: TitleModel_Echd) {
        let isLiked_Echd = TitleViewModel_Echd.shared_Echd.isLikedPost_Echd(post_echd: post_Echd)
        let iconName_Echd = isLiked_Echd ? "flame.fill" : "flame"
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)

        if isLiked_Echd {
            likeGradient_Echd?.isHidden = false
            likeButton_Echd.setTitleColor(.white, for: .normal)
            likeButton_Echd.tintColor = .white
            likeButton_Echd.layer.borderWidth = 0
        } else {
            likeGradient_Echd?.isHidden = true
            likeButton_Echd.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
            likeButton_Echd.setTitleColor(UIColor(hexstring_Echd: "#6B7280"), for: .normal)
            likeButton_Echd.tintColor = UIColor(hexstring_Echd: "#6B7280")
            likeButton_Echd.layer.borderWidth = 1.5
            likeButton_Echd.layer.borderColor = UIColor(hexstring_Echd: "#E5E7EB").cgColor
        }

        likeButton_Echd.setImage(UIImage(systemName: iconName_Echd, withConfiguration: cfg_Echd), for: .normal)
        likeButton_Echd.setTitle("  \(post_Echd.likes_Echd) Likes", for: .normal)
        likeButton_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
    }

    /// 刷新评论列表
    private func refreshComments_Echd(post_Echd: TitleModel_Echd) {
        commentsStackView_Echd.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if post_Echd.reviews_Echd.isEmpty {
            let emptyView_Echd = buildCommentsEmpty_Echd()
            commentsStackView_Echd.addArrangedSubview(emptyView_Echd)
            return
        }

        for comment_Echd in post_Echd.reviews_Echd {
            commentsStackView_Echd.addArrangedSubview(
                buildCommentCard_Echd(comment: comment_Echd, post: post_Echd)
            )
        }
    }

    /// 构建评论空状态
    private func buildCommentsEmpty_Echd() -> UIView {
        let wrap_Echd = UIView()
        let label_Echd = UILabel()
        label_Echd.text = "No comments yet.\nBe the first to spark! ✦"
        label_Echd.font = UIFont.systemFont(ofSize: 13)
        label_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        label_Echd.textAlignment = .center
        label_Echd.numberOfLines = 0
        wrap_Echd.addSubview(label_Echd)
        label_Echd.snp.makeConstraints { make in make.edges.equalToSuperview().inset(16) }
        return wrap_Echd
    }

    /// 构建单条评论卡片
    private func buildCommentCard_Echd(comment: Comment_Echd, post: TitleModel_Echd) -> UIView {
        let card_Echd = UIView()
        card_Echd.backgroundColor = .white
        card_Echd.layer.cornerRadius = 14
        card_Echd.layer.shadowColor = UIColor.black.withAlphaComponent(0.04).cgColor
        card_Echd.layer.shadowOffset = CGSize(width: 0, height: 2)
        card_Echd.layer.shadowRadius = 6
        card_Echd.layer.shadowOpacity = 1

        // 左侧 accent 竖条
        let bar_Echd = UIView()
        bar_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED").withAlphaComponent(0.4)
        bar_Echd.layer.cornerRadius = 2
        card_Echd.addSubview(bar_Echd)

        // 评论者头像
        let avatar_Echd = UserAvatarView_Echd()
        avatar_Echd.configure_Echd(userId_Echd: comment.commentUserId_Echd)
        card_Echd.addSubview(avatar_Echd)

        // 评论者名字
        let nameLabel_Echd = UILabel()
        nameLabel_Echd.text = comment.commentUserName_Echd
        nameLabel_Echd.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        nameLabel_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        card_Echd.addSubview(nameLabel_Echd)

        // 举报按钮
        let reportBtn_Echd = ReportDeleteHelper_Echd.createCommentReportButton_Echd(
            comment_Echd: comment,
            post_Echd: post,
            size_Echd: 12,
            color_Echd: UIColor(hexstring_Echd: "#9CA3AF"),
            from: self,
            completion_Echd: { [weak self] in
                if let updated_Echd = TitleViewModel_Echd.shared_Echd.getPosts_Echd()
                    .first(where: { $0.titleId_Echd == post.titleId_Echd }) {
                    self?.titleModel_Echd = updated_Echd
                    self?.refreshComments_Echd(post_Echd: updated_Echd)
                }
            }
        )
        card_Echd.addSubview(reportBtn_Echd)

        // 评论内容
        let contentLabel_Echd = UILabel()
        contentLabel_Echd.text = comment.commentContent_Echd
        contentLabel_Echd.font = UIFont.systemFont(ofSize: 14)
        contentLabel_Echd.textColor = UIColor(hexstring_Echd: "#374151")
        contentLabel_Echd.numberOfLines = 0
        card_Echd.addSubview(contentLabel_Echd)

        // 约束
        bar_Echd.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(10)
            make.width.equalTo(4)
        }
        avatar_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.width.height.equalTo(28)
        }
        nameLabel_Echd.snp.makeConstraints { make in
            make.leading.equalTo(avatar_Echd.snp.trailing).offset(8)
            make.centerY.equalTo(avatar_Echd)
        }
        reportBtn_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(avatar_Echd)
            make.width.height.equalTo(26)
        }
        contentLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(avatar_Echd.snp.bottom).offset(8)
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }

        return card_Echd
    }

    // MARK: - 事件处理

    @objc private func likeTapped_Echd() {
        guard let post_Echd = titleModel_Echd else { return }
        likeButton_Echd.animatePulse_Echd()
        Task { @MainActor in
            TitleViewModel_Echd.shared_Echd.likePost_Echd(post_echd: post_Echd)
        }
    }

    @objc private func sendCommentTapped_Echd() {
        guard let post_Echd = titleModel_Echd,
              let content_Echd = commentTextField_Echd.text,
              !content_Echd.trimmingCharacters(in: .whitespaces).isEmpty else {
            commentTextField_Echd.animateShake_Echd()
            return
        }
        sendCommentButton_Echd.animatePulse_Echd()
        commentTextField_Echd.text = nil
        commentTextField_Echd.resignFirstResponder()
        Task { @MainActor in
            TitleViewModel_Echd.shared_Echd.releaseComment_Echd(post_echd: post_Echd, content_echd: content_Echd)
        }
    }

    @objc private func authorTapped_Echd() {
        guard let post_Echd = titleModel_Echd else { return }
        let userInfo_Echd = UserViewModel_Echd.shared_Echd.getUserById_Echd(userId_echd: post_Echd.titleUserId_Echd)
        if UserViewModel_Echd.shared_Echd.isCurrentUser_Echd(userId_echd: post_Echd.titleUserId_Echd) {
            Navigation_Echd.toMe_Echd(style_echd: .push_echd)
        } else {
            Navigation_Echd.toUserInfo_Echd(with: userInfo_Echd, style_echd: .push_echd)
        }
    }

    @objc private func chatTapped_Echd() {
        guard let post_Echd = titleModel_Echd else { return }
        let user_Echd = UserViewModel_Echd.shared_Echd.getUserById_Echd(userId_echd: post_Echd.titleUserId_Echd)
        Navigation_Echd.toMessageUser_Echd(with: user_Echd, style_echd: .push_echd)
    }

    // MARK: - 通知监听

    private func observeNotifications_Echd() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStateChange_Echd),
            name: TitleViewModel_Echd.titleStateDidChangeNotification_Echd,
            object: nil
        )
    }

    @objc private func handleStateChange_Echd() {
        guard let post_Echd = titleModel_Echd,
              let updated_Echd = TitleViewModel_Echd.shared_Echd.getPosts_Echd()
                .first(where: { $0.titleId_Echd == post_Echd.titleId_Echd }) else { return }
        titleModel_Echd = updated_Echd
        updateStatsRow_Echd(post_Echd: updated_Echd)
        updateLikeButton_Echd(post_Echd: updated_Echd)
        refreshComments_Echd(post_Echd: updated_Echd)
    }
}

// MARK: - 媒体底部渐变蒙版（详情页专用）

/// 详情页媒体区底部渐变蒙版，白色底色过渡（与信息卡片颜色一致）
private class DetailGradientMask_Echd: UIView {
    private let grad_Echd = CAGradientLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        grad_Echd.colors = [UIColor.clear.cgColor, UIColor(hexstring_Echd: "#F8F7FF").cgColor]
        grad_Echd.startPoint = CGPoint(x: 0.5, y: 0)
        grad_Echd.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(grad_Echd, at: 0)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        grad_Echd.frame = bounds
    }
}
