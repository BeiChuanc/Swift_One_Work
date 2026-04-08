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
class Detail_Base_one: UIViewController {

    // MARK: - 数据

    /// 由导航器传入的帖子初始数据
    var titleModel_Base_one: TitleModel_Base_one?

    /// 导航栏右侧送礼按钮（保存引用以便与举报/删除按钮组合排列）
    private var giftBarItem_base_one: UIBarButtonItem?

    /// 始终从 ViewModel 取最新帖子数据（帖子被删除则返回 nil）
    private var latestPost_base_one: TitleModel_Base_one? {
        guard let id = titleModel_Base_one?.titleId_Base_one else { return titleModel_Base_one }
        return TitleViewModel_Base_one.shared_Base_one.getPosts_Base_one()
            .first { $0.titleId_Base_one == id } ?? titleModel_Base_one
    }

    // MARK: - 主滚动容器

    private let scrollView_base_one: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.keyboardDismissMode = .onDrag
        return sv
    }()

    private let contentView_base_one = UIView()

    // MARK: - Hero 头图区（分类渐变背景）

    private let heroView_base_one: UIView = {
        let v = UIView()
        v.clipsToBounds = true
        return v
    }()

    private var heroGradient_base_one: CAGradientLayer?

    private let heroDeco1_base_one = Detail_Base_one.buildDecorCircle_base_one(size: 170, alpha: 0.13)
    private let heroDeco2_base_one = Detail_Base_one.buildDecorCircle_base_one(size: 100, alpha: 0.10)
    private let heroDeco3_base_one = Detail_Base_one.buildDecorCircle_base_one(size: 56, alpha: 0.18)
    private let heroDecoRing_base_one: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        v.layer.borderWidth = 2
        v.layer.cornerRadius = 46
        v.isUserInteractionEnabled = false
        return v
    }()

    /// 分类徽章
    private let categoryBadge_base_one: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 11
        v.clipsToBounds = true
        v.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.40).cgColor
        v.layer.borderWidth = 1
        return v
    }()
    private let categoryLabel_base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()

    /// 帖子大标题
    private let postTitleLabel_base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        lb.textColor = .white
        lb.numberOfLines = 0
        lb.lineBreakMode = .byWordWrapping
        return lb
    }()

    /// 作者头像
    private let authorAvatarView_base_one = UserAvatarView_Base_one()

    /// 作者名
    private let authorNameLabel_base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lb.textColor = UIColor.white.withAlphaComponent(0.9)
        return lb
    }()

    /// 关注/已关注按钮（非本人帖子时显示）
    private let followButton_base_one: UIButton = {
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
    private let likeButton_base_one: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "heart", withConfiguration: cfg), for: .normal)
        btn.setImage(UIImage(systemName: "heart.fill", withConfiguration: cfg), for: .selected)
        btn.tintColor = UIColor(hexstring_Base_one: "#FF6B6B")
        btn.setTitle("  Like", for: .normal)
        btn.setTitle("  Liked", for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.85), for: .normal)
        btn.setTitleColor(UIColor(hexstring_Base_one: "#FF6B6B"), for: .selected)
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.20)
        btn.layer.cornerRadius = 16
        return btn
    }()

    private let likeCountLabel_base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lb.textColor = UIColor.white.withAlphaComponent(0.85)
        return lb
    }()

    // MARK: - 媒体横向滑览区

    private let mediaSectionBg_base_one: UIView = {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        return v
    }()

    private let mediaCollectionView_base_one: UICollectionView = {
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

    private let kMediaCell_base_one = "DetailMediaCell"

    // MARK: - 内容卡片

    private let contentCard_base_one = Detail_Base_one.buildCard_base_one()
    private let contentBodyLabel_base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        lb.textColor = ColorConfig_Base_one.textPrimary_Base_one
        lb.numberOfLines = 0
        lb.lineBreakMode = .byWordWrapping
        return lb
    }()

    // MARK: - 评论区卡片

    private let commentsCard_base_one = Detail_Base_one.buildCard_base_one()
    private let commentsTitleLabel_base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lb.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return lb
    }()
    private let emptyCommentLabel_base_one: UILabel = {
        let lb = UILabel()
        lb.text = "No comments yet. Be the first!"
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = ColorConfig_Base_one.textPlaceholder_Base_one
        lb.textAlignment = .center
        return lb
    }()
    private let commentsStack_base_one: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 0
        sv.distribution = .fill
        return sv
    }()

    // MARK: - 评论输入卡片（ScrollView 末尾，非悬浮）

    private let commentInputCard_base_one = Detail_Base_one.buildCard_base_one()
    private let commentTextField_base_one: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Leave a comment..."
        tf.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        tf.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        tf.layer.cornerRadius = 20
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        tf.rightViewMode = .always
        tf.returnKeyType = .send
        return tf
    }()
    private let sendButton_base_one: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        btn.setImage(UIImage(systemName: "arrow.up.circle.fill", withConfiguration: cfg), for: .normal)
        btn.tintColor = ColorConfig_Base_one.tidyMint_Base_one
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorConfig_Base_one.backgroundPrimary_Base_one
        setupNavBar_base_one()
        setupScrollView_base_one()
        setupHero_base_one()
        setupMediaSection_base_one()
        setupContentCard_base_one()
        setupCommentsCard_base_one()
        setupCommentInputCard_base_one()
        bindData_base_one()
        observeNotifications_base_one()
        observeKeyboard_base_one()
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
        heroGradient_base_one?.frame = heroView_base_one.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 导航栏配置（不透明，不与 Hero 内容重叠）

    private func setupNavBar_base_one() {
        // 使用不透明外观，避免内容被导航栏遮盖
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(hexstring_Base_one: "#38B2AC")
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
            action: #selector(backTapped_base_one)
        )
        navigationItem.leftBarButtonItem = backBtn

        /// 送礼按钮：40×40 原图，使用 customView 精确控制尺寸
        let giftBtn_base_one = UIButton(type: .custom)
        giftBtn_base_one.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        let giftImg_base_one = UIImage(named: "gift_btn")?.withRenderingMode(.alwaysOriginal)
        giftBtn_base_one.setImage(giftImg_base_one, for: .normal)
        giftBtn_base_one.contentMode = .scaleAspectFit
        giftBtn_base_one.addTarget(self, action: #selector(giftTapped_base_one), for: .touchUpInside)
        giftBarItem_base_one = UIBarButtonItem(customView: giftBtn_base_one)

        refreshMoreButton_base_one()
    }

    /// 刷新右上角按钮组（举报/删除 + 送礼，从右到左排列）
    /// 数组顺序：index 0 = 最右侧（举报/删除），index 1 = 次右侧（送礼）
    private func refreshMoreButton_base_one() {
        guard let post = latestPost_base_one else { return }
        let isMyPost = UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(
            userId_base_one: post.titleUserId_Base_one
        )
        let iconName = isMyPost ? "trash" : "ellipsis"
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let moreItem_base_one = UIBarButtonItem(
            image: UIImage(systemName: iconName, withConfiguration: cfg),
            style: .plain,
            target: self,
            action: #selector(moreTapped_base_one)
        )
        /// 送礼按钮在举报/删除按钮左侧 10pt
        /// UIBarButtonItem 数组：rightBarButtonItems[0] 最右，[1] 紧靠其左
        if let gift_base_one = giftBarItem_base_one {
            let spacer_base_one = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            spacer_base_one.width = 10
            navigationItem.rightBarButtonItems = [moreItem_base_one, spacer_base_one, gift_base_one]
        } else {
            navigationItem.rightBarButtonItems = [moreItem_base_one]
        }
    }

    // MARK: - 主滚动视图（从 safeAreaLayoutGuide.top 开始，不延伸至导航栏后方）

    private func setupScrollView_base_one() {
        view.addSubview(scrollView_base_one)
        scrollView_base_one.addSubview(contentView_base_one)

        scrollView_base_one.snp.makeConstraints { make in
            // 从安全区域顶部开始，hero 内容不会被导航栏遮盖
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    // MARK: - Hero 头图区

    private func setupHero_base_one() {
        contentView_base_one.addSubview(heroView_base_one)
        heroView_base_one.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            // 高度由内容自适应（分类徽章 + 标题 + 作者行）
            make.height.greaterThanOrEqualTo(0)
        }

        [heroDeco1_base_one, heroDeco2_base_one, heroDeco3_base_one, heroDecoRing_base_one].forEach {
            heroView_base_one.addSubview($0)
        }
        heroDeco1_base_one.snp.makeConstraints { make in
            make.width.height.equalTo(170)
            make.top.equalToSuperview().offset(-55)
            make.trailing.equalToSuperview().offset(45)
        }
        heroDeco2_base_one.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.bottom.equalToSuperview().offset(25)
            make.leading.equalToSuperview().offset(-25)
        }
        heroDeco3_base_one.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.top.equalToSuperview().offset(55)
            make.leading.equalToSuperview().offset(40)
        }
        heroDecoRing_base_one.snp.makeConstraints { make in
            make.width.height.equalTo(92)
            make.top.equalToSuperview().offset(-18)
            make.trailing.equalToSuperview().offset(-55)
        }

        // 分类徽章（顶部左侧，从 heroView.top 计算，不用 safeArea）
        categoryBadge_base_one.addSubview(categoryLabel_base_one)
        heroView_base_one.addSubview(categoryBadge_base_one)
        categoryLabel_base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12))
        }
        categoryBadge_base_one.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
        }

        // 帖子标题（紧跟分类徽章下方，消除空白间距）
        heroView_base_one.addSubview(postTitleLabel_base_one)
        postTitleLabel_base_one.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(categoryBadge_base_one.snp.bottom).offset(12)
        }

        // 作者行：头像 | 名称 | [Follow] | [Like Count] [Like btn]
        heroView_base_one.addSubview(authorAvatarView_base_one)
        heroView_base_one.addSubview(authorNameLabel_base_one)
        heroView_base_one.addSubview(followButton_base_one)
        heroView_base_one.addSubview(likeCountLabel_base_one)
        heroView_base_one.addSubview(likeButton_base_one)

        // 作者行紧跟标题，Hero 高度由此行撑出底部
        authorAvatarView_base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(postTitleLabel_base_one.snp.bottom).offset(16)
            make.width.height.equalTo(28)
            make.bottom.equalToSuperview().offset(-20)
        }
        authorNameLabel_base_one.snp.makeConstraints { make in
            make.leading.equalTo(authorAvatarView_base_one.snp.trailing).offset(8)
            make.centerY.equalTo(authorAvatarView_base_one)
        }
        followButton_base_one.snp.makeConstraints { make in
            make.leading.equalTo(authorNameLabel_base_one.snp.trailing).offset(10)
            make.centerY.equalTo(authorAvatarView_base_one)
            make.height.equalTo(28)
        }
        likeCountLabel_base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(authorAvatarView_base_one)
        }
        likeButton_base_one.snp.makeConstraints { make in
            make.trailing.equalTo(likeCountLabel_base_one.snp.leading).offset(-8)
            make.centerY.equalTo(likeCountLabel_base_one)
            make.height.equalTo(32)
            make.width.equalTo(80)
        }

        likeButton_base_one.addTarget(self, action: #selector(likeTapped_base_one), for: .touchUpInside)
        followButton_base_one.addTarget(self, action: #selector(followTapped_base_one), for: .touchUpInside)
    }

    // MARK: - 媒体横向滑览区

    private func setupMediaSection_base_one() {
        contentView_base_one.addSubview(mediaSectionBg_base_one)
        mediaSectionBg_base_one.snp.makeConstraints { make in
            make.top.equalTo(heroView_base_one.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(220)
        }
        mediaSectionBg_base_one.addSubview(mediaCollectionView_base_one)
        mediaCollectionView_base_one.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(190)
        }
        mediaCollectionView_base_one.register(
            DetailMediaCell_base_one.self,
            forCellWithReuseIdentifier: kMediaCell_base_one
        )
        mediaCollectionView_base_one.dataSource = self
        mediaCollectionView_base_one.delegate = self
    }

    // MARK: - 内容卡片

    private func setupContentCard_base_one() {
        contentView_base_one.addSubview(contentCard_base_one)
        contentCard_base_one.snp.makeConstraints { make in
            make.top.equalTo(mediaSectionBg_base_one.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        let dot = makeSectionDot_base_one()
        let title = makeSectionTitle_base_one(text: "Details")
        contentCard_base_one.addSubview(dot)
        contentCard_base_one.addSubview(title)
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
        contentCard_base_one.addSubview(contentBodyLabel_base_one)
        contentBodyLabel_base_one.snp.makeConstraints { make in
            make.top.equalTo(dot.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    // MARK: - 评论区卡片

    private func setupCommentsCard_base_one() {
        contentView_base_one.addSubview(commentsCard_base_one)
        commentsCard_base_one.snp.makeConstraints { make in
            make.top.equalTo(contentCard_base_one.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        let dot2 = makeSectionDot_base_one()
        commentsCard_base_one.addSubview(dot2)
        commentsCard_base_one.addSubview(commentsTitleLabel_base_one)
        dot2.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(22)
            make.width.equalTo(4)
            make.height.equalTo(20)
        }
        commentsTitleLabel_base_one.snp.makeConstraints { make in
            make.leading.equalTo(dot2.snp.trailing).offset(8)
            make.centerY.equalTo(dot2)
        }
        commentsCard_base_one.addSubview(emptyCommentLabel_base_one)
        emptyCommentLabel_base_one.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(dot2.snp.bottom).offset(24)
            make.height.equalTo(44)
        }
        commentsCard_base_one.addSubview(commentsStack_base_one)
        commentsStack_base_one.snp.makeConstraints { make in
            make.top.equalTo(dot2.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    // MARK: - 评论输入卡片（ScrollView 末尾普通卡片，非悬浮）

    private func setupCommentInputCard_base_one() {
        contentView_base_one.addSubview(commentInputCard_base_one)
        commentInputCard_base_one.snp.makeConstraints { make in
            make.top.equalTo(commentsCard_base_one.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-24)
        }
        let dot3 = makeSectionDot_base_one()
        let inputTitle = makeSectionTitle_base_one(text: "Add Comment")
        commentInputCard_base_one.addSubview(dot3)
        commentInputCard_base_one.addSubview(inputTitle)
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
        commentInputCard_base_one.addSubview(commentTextField_base_one)
        commentInputCard_base_one.addSubview(sendButton_base_one)
        sendButton_base_one.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(dot3.snp.bottom).offset(14)
            make.width.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-18)
        }
        commentTextField_base_one.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalTo(sendButton_base_one.snp.leading).offset(-10)
            make.centerY.equalTo(sendButton_base_one)
            make.height.equalTo(40)
        }
        commentTextField_base_one.delegate = self
        sendButton_base_one.addTarget(self, action: #selector(sendComment_base_one), for: .touchUpInside)
    }

    // MARK: - 数据绑定（首次渲染）

    private func bindData_base_one() {
        guard let post = latestPost_base_one else { return }
        applyHeroGradient_base_one(category: post.titleCategory_Base_one)
        categoryLabel_base_one.text = categoryDisplayName_base_one(post.titleCategory_Base_one)
        postTitleLabel_base_one.text = post.title_Base_one
        contentBodyLabel_base_one.text = post.titleContent_Base_one.isEmpty
            ? "No content provided." : post.titleContent_Base_one
        authorNameLabel_base_one.text = post.titleUserName_Base_one
        authorAvatarView_base_one.configure_Base_one(userId_Base_one: post.titleUserId_Base_one)
        likeCountLabel_base_one.text = "\(post.likes_Base_one)"
        likeButton_base_one.isSelected = TitleViewModel_Base_one.shared_Base_one
            .isLikedPost_Base_one(post_base_one: post)

        let hasMedia = !post.titleMeidas_Base_one.isEmpty
        mediaSectionBg_base_one.isHidden = !hasMedia
        if !hasMedia {
            mediaSectionBg_base_one.snp.updateConstraints { make in make.height.equalTo(0) }
        }
        mediaCollectionView_base_one.reloadData()
        refreshComments_base_one(post: post)
        refreshFollowButton_base_one(post: post)
        refreshMoreButton_base_one()
    }

    /// 增量刷新（点赞、评论、关注状态）
    private func refreshUI_base_one() {
        guard let post = latestPost_base_one else {
            navigationController?.popViewController(animated: true)
            return
        }
        likeCountLabel_base_one.text = "\(post.likes_Base_one)"
        likeButton_base_one.isSelected = TitleViewModel_Base_one.shared_Base_one
            .isLikedPost_Base_one(post_base_one: post)
        refreshComments_base_one(post: post)
        refreshFollowButton_base_one(post: post)
        refreshMoreButton_base_one()
    }

    // MARK: - 关注按钮刷新

    /// 根据关注状态刷新 Follow 按钮（本人帖子隐藏）
    private func refreshFollowButton_base_one(post: TitleModel_Base_one) {
        let isMyPost = UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(
            userId_base_one: post.titleUserId_Base_one
        )
        followButton_base_one.isHidden = isMyPost
        guard !isMyPost else { return }

        let author = UserViewModel_Base_one.shared_Base_one.getUserById_Base_one(
            userId_base_one: post.titleUserId_Base_one
        )
        let isFollowing = UserViewModel_Base_one.shared_Base_one.isFollowing_Base_one(
            user_base_one: author
        )
        if isFollowing {
            followButton_base_one.setTitle("Followed", for: .normal)
            followButton_base_one.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
            followButton_base_one.backgroundColor = UIColor.white.withAlphaComponent(0.10)
            followButton_base_one.layer.borderColor = UIColor.white.withAlphaComponent(0.30).cgColor
        } else {
            followButton_base_one.setTitle("Follow", for: .normal)
            followButton_base_one.setTitleColor(.white, for: .normal)
            followButton_base_one.backgroundColor = UIColor.white.withAlphaComponent(0.22)
            followButton_base_one.layer.borderColor = UIColor.white.withAlphaComponent(0.70).cgColor
        }
    }

    // MARK: - 评论列表刷新

    private func refreshComments_base_one(post: TitleModel_Base_one) {
        commentsStack_base_one.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // 过滤掉已被举报/拉黑用户发布的评论
        let comments = post.reviews_Base_one.filter { comment in
            !UserViewModel_Base_one.shared_Base_one.isReportedUser_Base_one(
                userId_base_one: comment.commentUserId_Base_one
            )
        }
        commentsTitleLabel_base_one.text = "Comments (\(comments.count))"
        emptyCommentLabel_base_one.isHidden = !comments.isEmpty
        comments.enumerated().forEach { idx, comment in
            let row = buildCommentRow_base_one(
                comment: comment, post: post, isLast: idx == comments.count - 1
            )
            commentsStack_base_one.addArrangedSubview(row)
        }
    }

    /// 构建单条评论行视图
    private func buildCommentRow_base_one(
        comment: Comment_Base_one,
        post: TitleModel_Base_one,
        isLast: Bool
    ) -> UIView {
        let container = UIView()
        container.backgroundColor = .white

        if !isLast {
            let divider = UIView()
            divider.backgroundColor = ColorConfig_Base_one.divider_Base_one
            container.addSubview(divider)
            divider.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.leading.equalToSuperview().offset(64)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(0.5)
            }
        }

        let avatarView = UserAvatarView_Base_one()
        avatarView.configure_Base_one(userId_Base_one: comment.commentUserId_Base_one)
        container.addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(34)
        }

        let isMyComment = UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(
            userId_base_one: comment.commentUserId_Base_one
        )
        let reportBtn = UIButton(type: .system)
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        reportBtn.setImage(UIImage(systemName: isMyComment ? "trash" : "ellipsis",
                                  withConfiguration: iconCfg), for: .normal)
        reportBtn.tintColor = ColorConfig_Base_one.textPlaceholder_Base_one
        container.addSubview(reportBtn)
        reportBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(14)
            make.width.height.equalTo(28)
        }

        let nameLabel = UILabel()
        nameLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        nameLabel.textColor = ColorConfig_Base_one.textPrimary_Base_one
        nameLabel.text = comment.commentUserName_Base_one
        container.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarView.snp.trailing).offset(10)
            make.top.equalTo(avatarView)
            make.trailing.equalTo(reportBtn.snp.leading).offset(-4)
        }

        let contentLabel = UILabel()
        contentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel.textColor = ColorConfig_Base_one.textSecondary_Base_one
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        contentLabel.text = comment.commentContent_Base_one
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
                ReportDeleteHelper_Base_one.delete_Base_one(
                    comment_Base_one: comment, post_Base_one: post, from: self
                )
            } else {
                ReportDeleteHelper_Base_one.report_Base_one(
                    comment_Base_one: comment, post_Base_one: post, from: self
                )
            }
        }, for: .touchUpInside)
        return container
    }

    // MARK: - Hero 渐变

    private func applyHeroGradient_base_one(category: String) {
        heroGradient_base_one?.removeFromSuperlayer()
        let frame = heroView_base_one.bounds.isEmpty
            ? CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 260)
            : heroView_base_one.bounds
        let layer = UIColor.createCategoryGradientLayer_Base_one(
            categoryId_Base_one: category, frame_Base_one: frame
        )
        heroView_base_one.layer.insertSublayer(layer, at: 0)
        heroGradient_base_one = layer
    }

    // MARK: - 通知订阅

    private func observeNotifications_base_one() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onTitleDataChanged_base_one),
            name: TitleViewModel_Base_one.titleStateDidChangeNotification_Base_one,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onUserDataChanged_base_one),
            name: UserViewModel_Base_one.userStateDidChangeNotification_Base_one,
            object: nil
        )
    }

    // MARK: - 键盘监听（滚动内容上移，让输入框可见）

    private func observeKeyboard_base_one() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow_base_one(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide_base_one(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - 工具方法

    private func makeSectionDot_base_one() -> UIView {
        let v = UIView()
        v.backgroundColor = ColorConfig_Base_one.tidyMint_Base_one
        v.layer.cornerRadius = 2
        return v
    }

    private func makeSectionTitle_base_one(text: String) -> UILabel {
        let lb = UILabel()
        lb.text = text
        lb.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        lb.textColor = ColorConfig_Base_one.textPrimary_Base_one
        return lb
    }

    private func categoryDisplayName_base_one(_ id: String) -> String {
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
    private static func buildCard_base_one() -> UIView {
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

    private static func buildDecorCircle_base_one(size: CGFloat, alpha: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        v.layer.cornerRadius = size / 2
        v.isUserInteractionEnabled = false
        return v
    }

    // MARK: - 事件响应

    @objc private func backTapped_base_one() {
        navigationController?.popViewController(animated: true)
    }

    /// 点击送礼按钮：弹起送礼界面
    @objc private func giftTapped_base_one() {
        guard let giftView = giftBarItem_base_one?.customView else { return }
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
        let giftPage_base_one = GiftPage_Base_one()
        giftPage_base_one.modalPresentationStyle = .overFullScreen
        giftPage_base_one.modalTransitionStyle   = .crossDissolve
        present(giftPage_base_one, animated: true)
    }

    @objc private func moreTapped_base_one() {
        guard let post = latestPost_base_one else { return }
        let isMyPost = UserViewModel_Base_one.shared_Base_one.isCurrentUser_Base_one(
            userId_base_one: post.titleUserId_Base_one
        )
        if isMyPost {
            ReportDeleteHelper_Base_one.delete_Base_one(post_Base_one: post, from: self) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        } else {
            ReportDeleteHelper_Base_one.report_Base_one(post_Base_one: post, from: self)
        }
    }

    @objc private func likeTapped_base_one() {
        guard let post = latestPost_base_one else { return }
        likeButton_base_one.animatePulse_Base_one()
        Task { @MainActor in
            TitleViewModel_Base_one.shared_Base_one.likePost_Base_one(post_base_one: post)
        }
    }

    /// 关注/取消关注作者
    @objc private func followTapped_base_one() {
        guard let post = latestPost_base_one else { return }
        let author = UserViewModel_Base_one.shared_Base_one.getUserById_Base_one(
            userId_base_one: post.titleUserId_Base_one
        )
        UIView.animate(withDuration: 0.12) {
            self.followButton_base_one.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        } completion: { _ in
            UIView.animate(withDuration: 0.12) {
                self.followButton_base_one.transform = .identity
            }
        }
        UserViewModel_Base_one.shared_Base_one.followUser_Base_one(user_base_one: author)
    }

    @objc private func sendComment_base_one() {
        guard let post = latestPost_base_one,
              let text = commentTextField_base_one.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        commentTextField_base_one.text = ""
        view.endEditing(true)
        Task { @MainActor in
            TitleViewModel_Base_one.shared_Base_one.releaseComment_Base_one(
                post_base_one: post, content_base_one: text
            )
        }
    }

    @objc private func onTitleDataChanged_base_one() { refreshUI_base_one() }
    @objc private func onUserDataChanged_base_one() {
        if let post = latestPost_base_one { refreshFollowButton_base_one(post: post) }
    }

    @objc private func keyboardWillShow_base_one(_ notification: Notification) {
        guard let kbFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        let inset = kbFrame.height - view.safeAreaInsets.bottom
        UIView.animate(withDuration: duration) {
            self.scrollView_base_one.contentInset.bottom = inset
            self.scrollView_base_one.verticalScrollIndicatorInsets.bottom = inset
            // 滚动到输入框可见
            let target = self.commentInputCard_base_one.frame.maxY + 8
            self.scrollView_base_one.setContentOffset(
                CGPoint(x: 0, y: max(0, target - self.scrollView_base_one.bounds.height + inset)),
                animated: false
            )
        }
    }

    @objc private func keyboardWillHide_base_one(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }
        UIView.animate(withDuration: duration) {
            self.scrollView_base_one.contentInset.bottom = 0
            self.scrollView_base_one.verticalScrollIndicatorInsets.bottom = 0
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension Detail_Base_one: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        latestPost_base_one?.titleMeidas_Base_one.count ?? 0
    }

    func collectionView(_ cv: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(
            withReuseIdentifier: kMediaCell_base_one, for: indexPath
        ) as! DetailMediaCell_base_one
        let path = latestPost_base_one?.titleMeidas_Base_one[indexPath.item] ?? ""
        cell.configure_base_one(mediaPath: path, index: indexPath.item)
        return cell
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let path = latestPost_base_one?.titleMeidas_Base_one[indexPath.item] else { return }
        let playerVC = MediaPlayerPage_Base_one()
        playerVC.mediaPath_Base_one = path
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

extension Detail_Base_one: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendComment_base_one()
        return true
    }
}

// MARK: - 媒体单元格

/// 详情页媒体单元格
/// 功能：使用 MediaDisplayView_Base_one 展示单个媒体缩略图
/// 点击后由 VC 的 collectionView(_:didSelectItemAt:) 打开 MediaPlayerPage_Base_one
private class DetailMediaCell_base_one: UICollectionViewCell {

    private let mediaView_base_one: MediaDisplayView_Base_one = {
        let v = MediaDisplayView_Base_one()
        v.layer.cornerRadius = 16
        v.clipsToBounds = true
        return v
    }()

    private let indexBadge_base_one: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        v.layer.cornerRadius = 10
        v.isHidden = true
        return v
    }()
    private let indexLabel_base_one: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lb.textColor = .white
        lb.textAlignment = .center
        return lb
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell_base_one()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell_base_one()
    }

    private func setupCell_base_one() {
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 10
        contentView.layer.shadowOpacity = 0.14
        contentView.layer.masksToBounds = false

        contentView.addSubview(mediaView_base_one)
        mediaView_base_one.snp.makeConstraints { $0.edges.equalToSuperview() }

        indexBadge_base_one.addSubview(indexLabel_base_one)
        contentView.addSubview(indexBadge_base_one)
        indexLabel_base_one.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 3, left: 7, bottom: 3, right: 7))
        }
        indexBadge_base_one.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(10)
        }
    }

    /// 配置媒体路径及序号
    func configure_base_one(mediaPath: String, index: Int = -1) {
        mediaView_base_one.configure_Base_one(mediaPath_Base_one: mediaPath, isVideo_Base_one: false)
        if index >= 0 {
            indexLabel_base_one.text = "\(index + 1)"
            indexBadge_base_one.isHidden = false
        } else {
            indexBadge_base_one.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        mediaView_base_one.configure_Base_one(mediaPath_Base_one: nil, isVideo_Base_one: false)
        indexBadge_base_one.isHidden = true
    }
}
