import Foundation
import UIKit
import SnapKit

// MARK: - 帖子详情页

/// 帖子详情页
/// 核心作用：完整展示帖子媒体、标题、正文、评论，支持点赞、关注作者、发表评论、举报/删除
/// 设计思路：
///   - 导航栏不透明，hero 区从 safeArea 下方开始，避免被遮盖
///   - 评论输入框为 ScrollView 末尾的普通卡片，随页面滚动，不悬浮遮盖内容
///   - 数据响应：订阅 TitleViewModel / UserViewModel 通知，自动刷新
class Detail_Tidy: UIViewController {

    // MARK: - 数据

    /// 由导航器传入的帖子初始数据
    var titleModel_Tidy: TitleModel_Tidy?

    /// 导航栏右侧送礼按钮（保存引用以便与举报/删除按钮组合排列）
    private var giftBarItem_tidy: UIBarButtonItem?

    /// 始终从 ViewModel 取最新帖子数据（帖子被删除则返回 nil）
    private var latestPost_tidy: TitleModel_Tidy? {
        guard let id = titleModel_Tidy?.titleId_Tidy else { return titleModel_Tidy }
        return TitleViewModel_Tidy.shared_Tidy.getPosts_Tidy()
            .first { $0.titleId_Tidy == id } ?? titleModel_Tidy
    }

    // MARK: - 主滚动容器

    private let scrollView_tidy: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .onDrag
        return sv
    }()

    private let contentView_tidy = UIView()

    // MARK: - Hero 头图区（分类渐变背景）

    private let heroView_tidy: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var heroGradient_tidy: CAGradientLayer?

    private let heroDeco1_tidy = Detail_Tidy.buildDecorCircle_tidy(size: 170, alpha: 0.13)
    private let heroDeco2_tidy = Detail_Tidy.buildDecorCircle_tidy(size: 100, alpha: 0.10)
    private let heroDeco3_tidy = Detail_Tidy.buildDecorCircle_tidy(size: 56, alpha: 0.18)
    private let heroDecoRing_tidy: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 46
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 分类徽章
    private let categoryBadge_tidy: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 11
        v.clipsToBounds = true
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.40).cgColor
        v.layer.borderWidth = 1
        return v
    }()
    private let categoryLabel_tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()

    /// 帖子大标题
    private let postTitleLabel_tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        lb.textColor = .white
        lb.numberOfLines = 0
        lb.lineBreakMode = .byWordWrapping
        return lb
    }()

    /// 作者头像
    private let authorAvatarView_tidy = UserAvatarView_Tidy()

    /// 作者名
    private let authorNameLabel_tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lb.textColor = UIColor.white.withAlphaComponent(0.9)
        return lb
    }()

    /// 关注/已关注按钮（非本人帖子时显示）
    private let followButton_tidy: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1.5
        btn.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        btn.isHidden = true
        return btn
    }()

    /// 点赞按钮
    private let likeButton_tidy: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "heart", withConfiguration: cfg), for: .normal)
        btn.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg), for: .selected)
        btn.tintColor = UIColor(hexstring_Tidy: "#FF6B6B")
        btn.setTitle("  Like", for: .normal)
        btn.setTitle("  Liked", for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.85), for: .normal)
        btn.setTitleColor(UIColor(hexstring_Tidy: "#FF6B6B"), for: .selected)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        btn.layer.cornerRadius = 16
        return btn
    }()

    private let likeCountLabel_tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lb.textColor = UIColor.white.withAlphaComponent(0.85)
        return lb
    }()

    // MARK: - 媒体横向滑览区

    private let mediaSectionBg_tidy: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        return v
    }()

    private let mediaCollectionView_tidy: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.alwaysBounceHorizontal = true
        return cv
    }()

    private let kMediaCell_tidy = "DetailMediaCell"

    // MARK: - 内容卡片

    private let contentCard_tidy = Detail_Tidy.buildCard_tidy()
    private let contentBodyLabel_tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        lb.numberOfLines = 0
        lb.lineBreakMode = .byWordWrapping
        return lb
    }()

    // MARK: - 评论区卡片

    private let commentsCard_tidy = Detail_Tidy.buildCard_tidy()
    private let commentsTitleLabel_tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }()
    private let emptyCommentLabel_tidy: UILabel = {
        let lb = UILabel()
        lb.text = "No comments yet. Be the first!"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = ColorConfig_Tidy.textPlaceholder_Tidy
        lb.textAlignment = .center
        return lb
    }()
    private let commentsStack_tidy: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.distribution = .fill
        return sv
    }()

    // MARK: - 评论输入卡片（ScrollView 末尾，非悬浮）

    private let commentInputCard_tidy = Detail_Tidy.buildCard_tidy()
    private let commentTextField_tidy: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Leave a comment..."
        tf.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        tf.layer.cornerRadius = 20
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.rightViewMode = .always
        tf.returnKeyType = .send
        return tf
    }()
    private let sendButton_tidy: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        btn.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Tidy.tidyMint_Tidy
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Tidy.backgroundPrimary_Tidy
        setupNavBar_tidy()
        setupScrollView_tidy()
        setupHero_tidy()
        setupMediaSection_tidy()
        setupContentCard_tidy()
        setupCommentsCard_tidy()
        setupCommentInputCard_tidy()
        bindData_tidy()
        observeNotifications_tidy()
        observeKeyboard_tidy()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        print("触发1")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        view.endEditing(true)
        print("触发2")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradient_tidy?.frame = heroView_tidy.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 导航栏配置（不透明，不与 Hero 内容重叠）

    private func setupNavBar_tidy() {
        // 使用不透明外观，避免内容被导航栏遮盖
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hexstring_Tidy: "#38B2AC")
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white

        let backBtn = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped_tidy)
        )
        navigationItem.leftBarButtonItem = backBtn

        /// 送礼按钮：40×40 原图，使用 customView 精确控制尺寸
        let giftBtn_tidy = UIButton(type: .custom)
        giftBtn_tidy.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let giftImg_tidy = UIImage(named: "gift_btn")?.withRenderingMode(.alwaysOriginal)
        giftBtn_tidy.setImage(giftImg_tidy, for: .normal)
        giftBtn_tidy.contentMode = .scaleAspectFit
        giftBtn_tidy.addTarget(self, action: #selector(giftTapped_tidy), for: .touchUpInside)
        giftBarItem_tidy = UIBarButtonItem(customView: giftBtn_tidy)

        refreshMoreButton_tidy()
    }

    /// 刷新右上角按钮组（举报/删除 + 送礼，从右到左排列）
    /// 数组顺序：index 0 = 最右侧（举报/删除），index 1 = 次右侧（送礼）
    private func refreshMoreButton_tidy() {
        guard let post = latestPost_tidy else { return }
        let isMyPost = UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(
            userId_tidy: post.titleUserId_Tidy
        )
        let iconName = isMyPost ? "trash" : "ellipsis"
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let moreItem_tidy = UIBarButtonItem(
            image: UIImage(systemName: iconName, withConfiguration: cfg),
            style: .plain,
            target: self,
            action: #selector(moreTapped_tidy)
        )
        /// 送礼按钮在举报/删除按钮左侧 10pt
        /// UIBarButtonItem 数组：rightBarButtonItems[0] 最右，[1] 紧靠其左
        if let gift_tidy = giftBarItem_tidy {
            let spacer_tidy = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            spacer_tidy.width = 10
            navigationItem.rightBarButtonItems = [moreItem_tidy, spacer_tidy, gift_tidy]
        } else {
            navigationItem.rightBarButtonItems = [moreItem_tidy]
        }
    }

    // MARK: - 主滚动视图（从 safeAreaLayoutGuide.top 开始，不延伸至导航栏后方）

    private func setupScrollView_tidy() {
        view.addSubview(scrollView_tidy)
        scrollView_tidy.addSubview(contentView_tidy)

        scrollView_tidy.snp.makeConstraints { make in
            // 从安全区域顶部开始，hero 内容不会被导航栏遮盖
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    // MARK: - Hero 头图区

    private func setupHero_tidy() {
        contentView_tidy.addSubview(heroView_tidy)
        heroView_tidy.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            // 高度由内容自适应（分类徽章 + 标题 + 作者行）
            make.height.greaterThanOrEqualTo(0)
        }

        [heroDeco1_tidy, heroDeco2_tidy, heroDeco3_tidy, heroDecoRing_tidy].forEach {
            heroView_tidy.addSubview($0)
        }
        heroDeco1_tidy.snp.makeConstraints { make in
            make.width.height.equalTo(170)
            make.top.equalToSuperview().offset(-55)
            make.trailing.equalToSuperview().offset(45)
        }
        heroDeco2_tidy.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.bottom.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(-25)
        }
        heroDeco3_tidy.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.top.equalToSuperview().offset(55)
            make.leading.equalToSuperview().offset(40)
        }
        heroDecoRing_tidy.snp.makeConstraints { make in
            make.width.height.equalTo(92)
            make.top.equalToSuperview().offset(-18)
            make.trailing.equalToSuperview().offset(-55)
        }

        // 分类徽章（顶部左侧，从 heroView.top 计算，不用 safeArea）
        categoryBadge_tidy.addSubview(categoryLabel_tidy)
        heroView_tidy.addSubview(categoryBadge_tidy)
        categoryLabel_tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12))
        }
        categoryBadge_tidy.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        // 帖子标题（紧跟分类徽章下方，消除空白间距）
        heroView_tidy.addSubview(postTitleLabel_tidy)
        postTitleLabel_tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(categoryBadge_tidy.snp.bottom).offset(12)
        }

        // 作者行：头像 | 名称 | [Follow] | [Like Count] [Like btn]
        heroView_tidy.addSubview(authorAvatarView_tidy)
        heroView_tidy.addSubview(authorNameLabel_tidy)
        heroView_tidy.addSubview(followButton_tidy)
        heroView_tidy.addSubview(likeCountLabel_tidy)
        heroView_tidy.addSubview(likeButton_tidy)

        // 作者行紧跟标题，Hero 高度由此行撑出底部
        authorAvatarView_tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(postTitleLabel_tidy.snp.bottom).offset(16)
            make.width.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-20)
        }
        authorNameLabel_tidy.snp.makeConstraints { make in
            make.leading.equalTo(authorAvatarView_tidy.snp.trailing).offset(8)
            make.centerY.equalTo(authorAvatarView_tidy)
        }
        followButton_tidy.snp.makeConstraints { make in
            make.leading.equalTo(authorNameLabel_tidy.snp.trailing).offset(10)
            make.centerY.equalTo(authorAvatarView_tidy)
            make.height.equalTo(28)
        }
        likeCountLabel_tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(authorAvatarView_tidy)
        }
        likeButton_tidy.snp.makeConstraints { make in
            make.trailing.equalTo(likeCountLabel_tidy.snp.leading).offset(-8)
            make.centerY.equalTo(likeCountLabel_tidy)
            make.height.equalTo(32)
            make.width.equalTo(80)
        }

        likeButton_tidy.addTarget(self, action: #selector(likeTapped_tidy), for: .touchUpInside)
        followButton_tidy.addTarget(self, action: #selector(followTapped_tidy), for: .touchUpInside)
    }

    // MARK: - 媒体横向滑览区

    private func setupMediaSection_tidy() {
        contentView_tidy.addSubview(mediaSectionBg_tidy)
        mediaSectionBg_tidy.snp.makeConstraints { make in
            make.top.equalTo(heroView_tidy.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(220)
        }
        mediaSectionBg_tidy.addSubview(mediaCollectionView_tidy)
        mediaCollectionView_tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(190)
        }
        mediaCollectionView_tidy.register(
            DetailMediaCell_tidy.self,
            forCellWithReuseIdentifier: kMediaCell_tidy
        )
        mediaCollectionView_tidy.dataSource = self
        mediaCollectionView_tidy.delegate = self
    }

    // MARK: - 内容卡片

    private func setupContentCard_tidy() {
        contentView_tidy.addSubview(contentCard_tidy)
        contentCard_tidy.snp.makeConstraints { make in
            make.top.equalTo(mediaSectionBg_tidy.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        let dot = makeSectionDot_tidy()
        let title = makeSectionTitle_tidy(text: "Details")
        contentCard_tidy.addSubview(dot)
        contentCard_tidy.addSubview(title)
        dot.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(22)
            make.width.equalTo(4)
            make.height.equalTo(20)
        }
        title.snp.makeConstraints { make in
            make.leading.equalTo(dot.snp.trailing).offset(8)
            make.centerY.equalTo(dot)
        }
        contentCard_tidy.addSubview(contentBodyLabel_tidy)
        contentBodyLabel_tidy.snp.makeConstraints { make in
            make.top.equalTo(dot.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - 评论区卡片

    private func setupCommentsCard_tidy() {
        contentView_tidy.addSubview(commentsCard_tidy)
        commentsCard_tidy.snp.makeConstraints { make in
            make.top.equalTo(contentCard_tidy.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        let dot2 = makeSectionDot_tidy()
        commentsCard_tidy.addSubview(dot2)
        commentsCard_tidy.addSubview(commentsTitleLabel_tidy)
        dot2.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(22)
            make.width.equalTo(4)
            make.height.equalTo(20)
        }
        commentsTitleLabel_tidy.snp.makeConstraints { make in
            make.leading.equalTo(dot2.snp.trailing).offset(8)
            make.centerY.equalTo(dot2)
        }
        commentsCard_tidy.addSubview(emptyCommentLabel_tidy)
        emptyCommentLabel_tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(dot2.snp.bottom).offset(24)
            make.height.equalTo(44)
        }
        commentsCard_tidy.addSubview(commentsStack_tidy)
        commentsStack_tidy.snp.makeConstraints { make in
            make.top.equalTo(dot2.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    // MARK: - 评论输入卡片（ScrollView 末尾普通卡片，非悬浮）

    private func setupCommentInputCard_tidy() {
        contentView_tidy.addSubview(commentInputCard_tidy)
        commentInputCard_tidy.snp.makeConstraints { make in
            make.top.equalTo(commentsCard_tidy.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
        }
        let dot3 = makeSectionDot_tidy()
        let inputTitle = makeSectionTitle_tidy(text: "Add Comment")
        commentInputCard_tidy.addSubview(dot3)
        commentInputCard_tidy.addSubview(inputTitle)
        dot3.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(22)
            make.width.equalTo(4)
            make.height.equalTo(20)
        }
        inputTitle.snp.makeConstraints { make in
            make.leading.equalTo(dot3.snp.trailing).offset(8)
            make.centerY.equalTo(dot3)
        }
        commentInputCard_tidy.addSubview(commentTextField_tidy)
        commentInputCard_tidy.addSubview(sendButton_tidy)
        sendButton_tidy.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(dot3.snp.bottom).offset(14)
            make.width.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-18)
        }
        commentTextField_tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(sendButton_tidy.snp.leading).offset(-10)
            make.centerY.equalTo(sendButton_tidy)
            make.height.equalTo(40)
        }
        commentTextField_tidy.delegate = self
        sendButton_tidy.addTarget(self, action: #selector(sendComment_tidy), for: .touchUpInside)
    }

    // MARK: - 数据绑定（首次渲染）

    private func bindData_tidy() {
        guard let post = latestPost_tidy else { return }
        applyHeroGradient_tidy(category: post.titleCategory_Tidy)
        categoryLabel_tidy.text = categoryDisplayName_tidy(post.titleCategory_Tidy)
        postTitleLabel_tidy.text = post.title_Tidy
        contentBodyLabel_tidy.text = post.titleContent_Tidy.isEmpty
            ? "No content provided." : post.titleContent_Tidy
        authorNameLabel_tidy.text = post.titleUserName_Tidy
        authorAvatarView_tidy.configure_Tidy(userId_Tidy: post.titleUserId_Tidy)
        likeCountLabel_tidy.text = "\(post.likes_Tidy)"
        likeButton_tidy.isSelected = TitleViewModel_Tidy.shared_Tidy
            .isLikedPost_Tidy(post_tidy: post)

        let hasMedia = !post.titleMeidas_Tidy.isEmpty
        mediaSectionBg_tidy.isHidden = !hasMedia
        if !hasMedia {
            mediaSectionBg_tidy.snp.updateConstraints { make in make.height.equalTo(0) }
        }
        mediaCollectionView_tidy.reloadData()
        refreshComments_tidy(post: post)
        refreshFollowButton_tidy(post: post)
        refreshMoreButton_tidy()
    }

    /// 增量刷新（点赞、评论、关注状态）
    private func refreshUI_tidy() {
        guard let post = latestPost_tidy else {
            navigationController?.popViewController(animated: true)
            return
        }
        likeCountLabel_tidy.text = "\(post.likes_Tidy)"
        likeButton_tidy.isSelected = TitleViewModel_Tidy.shared_Tidy
            .isLikedPost_Tidy(post_tidy: post)
        refreshComments_tidy(post: post)
        refreshFollowButton_tidy(post: post)
        refreshMoreButton_tidy()
    }

    // MARK: - 关注按钮刷新

    /// 根据关注状态刷新 Follow 按钮（本人帖子隐藏）
    private func refreshFollowButton_tidy(post: TitleModel_Tidy) {
        let isMyPost = UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(
            userId_tidy: post.titleUserId_Tidy
        )
        followButton_tidy.isHidden = isMyPost
        guard !isMyPost else { return }

        let author = UserViewModel_Tidy.shared_Tidy.getUserById_Tidy(
            userId_tidy: post.titleUserId_Tidy
        )
        let isFollowing = UserViewModel_Tidy.shared_Tidy.isFollowing_Tidy(
            user_tidy: author
        )
        if isFollowing {
            followButton_tidy.setTitle("Followed", for: .normal)
            followButton_tidy.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
            followButton_tidy.backgroundColor = UIColor.white.withAlphaComponent(0.10)
            followButton_tidy.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor
        } else {
            followButton_tidy.setTitle("Follow", for: .normal)
            followButton_tidy.setTitleColor(.white, for: .normal)
            followButton_tidy.backgroundColor = UIColor.white.withAlphaComponent(0.22)
            followButton_tidy.layer.borderColor = UIColor.white.withAlphaComponent(0.70).cgColor
        }
    }

    // MARK: - 评论列表刷新

    private func refreshComments_tidy(post: TitleModel_Tidy) {
        commentsStack_tidy.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // 过滤掉已被举报/拉黑用户发布的评论
        let comments = post.reviews_Tidy.filter { comment in
            !UserViewModel_Tidy.shared_Tidy.isReportedUser_Tidy(
                userId_tidy: comment.commentUserId_Tidy
            )
        }
        commentsTitleLabel_tidy.text = "Comments (\(comments.count))"
        emptyCommentLabel_tidy.isHidden = !comments.isEmpty
        comments.enumerated().forEach { idx, comment in
            let row = buildCommentRow_tidy(
                comment: comment, post: post, isLast: idx == comments.count - 1
            )
            commentsStack_tidy.addArrangedSubview(row)
        }
    }

    /// 构建单条评论行视图
    private func buildCommentRow_tidy(
        comment: Comment_Tidy,
        post: TitleModel_Tidy,
        isLast: Bool
    ) -> UIView {
        let container = UIView()
        container.backgroundColor = .white

        if !isLast {
            let divider = UIView()
            divider.backgroundColor = ColorConfig_Tidy.divider_Tidy
            container.addSubview(divider)
            divider.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.leading.equalToSuperview().offset(64)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(0.5)
            }
        }

        let avatarView = UserAvatarView_Tidy()
        avatarView.configure_Tidy(userId_Tidy: comment.commentUserId_Tidy)
        container.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(34)
        }

        let isMyComment = UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(
            userId_tidy: comment.commentUserId_Tidy
        )
        let reportBtn = UIButton(type: .system)
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        reportBtn.setImage(UIImage(systemName: isMyComment ? "trash" : "ellipsis",
                                  withConfiguration: iconCfg), for: .normal)
        reportBtn.tintColor = ColorConfig_Tidy.textPlaceholder_Tidy
        container.addSubview(reportBtn)
        reportBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(28)
        }

        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLabel.textColor = ColorConfig_Tidy.textPrimary_Tidy
        nameLabel.text = comment.commentUserName_Tidy
        container.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.top.equalTo(avatarView)
            make.trailing.equalTo(reportBtn.snp.leading).offset(-4)
        }

        let contentLabel = UILabel()
        contentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel.textColor = ColorConfig_Tidy.textSecondary_Tidy
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.text = comment.commentContent_Tidy
        container.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-14)
        }

        reportBtn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.10) {
                reportBtn.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
            } completion: { _ in
                UIView.animate(withDuration: 0.10) { reportBtn.transform = .identity }
            }
            if isMyComment {
                ReportDeleteHelper_Tidy.delete_Tidy(
                    comment_Tidy: comment, post_Tidy: post, from: self
                )
            } else {
                ReportDeleteHelper_Tidy.report_Tidy(
                    comment_Tidy: comment, post_Tidy: post, from: self
                )
            }
        }, for: .touchUpInside)
        return container
    }

    // MARK: - Hero 渐变

    private func applyHeroGradient_tidy(category: String) {
        heroGradient_tidy?.removeFromSuperlayer()
        let frame = heroView_tidy.bounds.isEmpty
            ? CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 260)
            : heroView_tidy.bounds
        let layer = UIColor.createCategoryGradientLayer_Tidy(
            categoryId_Tidy: category, frame_Tidy: frame
        )
        heroView_tidy.layer.insertSublayer(layer, at: 0)
        heroGradient_tidy = layer
    }

    // MARK: - 通知订阅

    private func observeNotifications_tidy() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTitleDataChanged_tidy),
            name: TitleViewModel_Tidy.titleStateDidChangeNotification_Tidy,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onUserDataChanged_tidy),
            name: UserViewModel_Tidy.userStateDidChangeNotification_Tidy,
            object: nil
        )
    }

    // MARK: - 键盘监听（滚动内容上移，让输入框可见）

    private func observeKeyboard_tidy() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_tidy(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_tidy(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - 工具方法

    private func makeSectionDot_tidy() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Tidy.tidyMint_Tidy
        v.layer.cornerRadius = 2
        return v
    }

    private func makeSectionTitle_tidy(text: String) -> UILabel {
        let lb = UILabel()
        lb.text = text
        lb.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lb.textColor = ColorConfig_Tidy.textPrimary_Tidy
        return lb
    }

    private func categoryDisplayName_tidy(_ id: String) -> String {
        switch id {
        case "living_room": return "Living Room"
        case "bedroom":     return "Bedroom"
        case "kitchen":     return "Kitchen"
        case "bathroom":    return "Bathroom"
        case "study":       return "Study"
        case "storage":     return "Storage"
        case "garden":      return "Garden"
        default:            return "Home"
        }
    }

    /// 创建白色阴影卡片（static 供存储属性初始化）
    private static func buildCard_tidy() -> UIView {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 20
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 12
        v.layer.shadowOpacity = 0.06
        v.layer.masksToBounds = false
        return v
    }

    private static func buildDecorCircle_tidy(size: CGFloat, alpha: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v.layer.cornerRadius = size / 2
        v.isUserInteractionEnabled = false
        return v
    }

    // MARK: - 事件响应

    @objc private func backTapped_tidy() {
        navigationController?.popViewController(animated: true)
    }

    /// 点击送礼按钮：弹起送礼界面
    @objc private func giftTapped_tidy() {
        guard let giftView = giftBarItem_tidy?.customView else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        /// 按钮弹簧动画反馈
        UIView.animate(withDuration: 0.10, animations: {
            giftView.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }, completion: { _ in
            UIView.animate(withDuration: 0.12,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.8) {
                giftView.transform = .identity
            }
        })
        /// 模态弹起送礼界面（透明背景 + 淡入淡出）
        let giftPage_tidy = GiftPage_Tidy()
        giftPage_tidy.modalPresentationStyle = .overFullScreen
        giftPage_tidy.modalTransitionStyle   = .crossDissolve
        present(giftPage_tidy, animated: true)
    }

    @objc private func moreTapped_tidy() {
        guard let post = latestPost_tidy else { return }
        let isMyPost = UserViewModel_Tidy.shared_Tidy.isCurrentUser_Tidy(
            userId_tidy: post.titleUserId_Tidy
        )
        if isMyPost {
            ReportDeleteHelper_Tidy.delete_Tidy(post_Tidy: post, from: self) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            ReportDeleteHelper_Tidy.report_Tidy(post_Tidy: post, from: self)
        }
    }

    @objc private func likeTapped_tidy() {
        guard let post = latestPost_tidy else { return }
        likeButton_tidy.animatePulse_Tidy()
        Task { @MainActor in
            TitleViewModel_Tidy.shared_Tidy.likePost_Tidy(post_tidy: post)
        }
    }

    /// 关注/取消关注作者
    @objc private func followTapped_tidy() {
        guard let post = latestPost_tidy else { return }
        let author = UserViewModel_Tidy.shared_Tidy.getUserById_Tidy(
            userId_tidy: post.titleUserId_Tidy
        )
        UIView.animate(withDuration: 0.12) {
            self.followButton_tidy.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        } completion: { _ in
            UIView.animate(withDuration: 0.12) {
                self.followButton_tidy.transform = .identity
            }
        }
        UserViewModel_Tidy.shared_Tidy.followUser_Tidy(user_tidy: author)
    }

    @objc private func sendComment_tidy() {
        guard let post = latestPost_tidy,
              let text = commentTextField_tidy.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        commentTextField_tidy.text = ""
        view.endEditing(true)
        Task { @MainActor in
            TitleViewModel_Tidy.shared_Tidy.releaseComment_Tidy(
                post_tidy: post, content_tidy: text
            )
        }
    }

    @objc private func onTitleDataChanged_tidy() { refreshUI_tidy() }
    @objc private func onUserDataChanged_tidy() {
        if let post = latestPost_tidy { refreshFollowButton_tidy(post: post) }
    }

    @objc private func keyboardWillShow_tidy(_ notification: Notification) {
        guard let kbFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        let inset = kbFrame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
            self.scrollView_tidy.contentInset.bottom = inset
            self.scrollView_tidy.verticalScrollIndicatorInsets.bottom = inset
            // 滚动到输入框可见
            let target = self.commentInputCard_tidy.frame.maxY + 8
            self.scrollView_tidy.setContentOffset(
                CGPoint(x: 0, y: max(0, target - self.scrollView_tidy.bounds.height + inset)),
                animated: false
            )
        }
    }

    @objc private func keyboardWillHide_tidy(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        UIView.animate(withDuration: duration) {
            self.scrollView_tidy.contentInset.bottom = 0
            self.scrollView_tidy.verticalScrollIndicatorInsets.bottom = 0
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension Detail_Tidy: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        latestPost_tidy?.titleMeidas_Tidy.count ?? 0
    }

    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: kMediaCell_tidy, for: indexPath
        ) as! DetailMediaCell_tidy
        let path = latestPost_tidy?.titleMeidas_Tidy[indexPath.item] ?? ""
        cell.configure_tidy(mediaPath: path, index: indexPath.item)
        return cell
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let path = latestPost_tidy?.titleMeidas_Tidy[indexPath.item] else { return }
        let playerVC = MediaPlayerPage_Tidy()
        playerVC.mediaPath_Tidy = path
        playerVC.modalPresentationStyle = .fullScreen
        present(playerVC, animated: true)
    }

    func collectionView(_ cv: UICollectionView,
                        layout layout_: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 230, height: 170)
    }
}

// MARK: - UITextFieldDelegate

extension Detail_Tidy: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment_tidy()
        return true
    }
}

// MARK: - 媒体单元格

/// 详情页媒体单元格
/// 功能：使用 MediaDisplayView_Tidy 展示单个媒体缩略图
/// 点击后由 VC 的 collectionView(_:didSelectItemAt:) 打开 MediaPlayerPage_Tidy
private class DetailMediaCell_tidy: UICollectionViewCell {

    private let mediaView_tidy: MediaDisplayView_Tidy = {
        let v = MediaDisplayView_Tidy()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let indexBadge_tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v.layer.cornerRadius = 10
        v.isHidden = true
        return v
    }()
    private let indexLabel_tidy: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell_tidy()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell_tidy()
    }

    private func setupCell_tidy() {
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOpacity = 0.14
        contentView.layer.masksToBounds = false

        contentView.addSubview(mediaView_tidy)
        mediaView_tidy.snp.makeConstraints { $0.edges.equalToSuperview() }

        indexBadge_tidy.addSubview(indexLabel_tidy)
        contentView.addSubview(indexBadge_tidy)
        indexLabel_tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7))
        }
        indexBadge_tidy.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(10)
        }
    }

    /// 配置媒体路径及序号
    func configure_tidy(mediaPath: String, index: Int = -1) {
        mediaView_tidy.configure_Tidy(mediaPath_Tidy: mediaPath, isVideo_Tidy: false)
        if index >= 0 {
            indexLabel_tidy.text = "\(index + 1)"
            indexBadge_tidy.isHidden = false
        } else {
            indexBadge_tidy.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        mediaView_tidy.configure_Tidy(mediaPath_Tidy: nil, isVideo_Tidy: false)
        indexBadge_tidy.isHidden = true
    }
}
