import Foundation
import UIKit
import SnapKit

// MARK: - 用户中心页面视图控制器

/// 用户中心页面视图控制器
/// 功能：展示他人用户信息（头像/昵称/简介/统计）、关注按钮、消息按钮；帖子列表带举报/删除
/// 设计：全屏渐变头部（内容驱动高度）+ 玻璃态统计栏 + 精美按钮 + 帖子双列网格
/// 逻辑：消息按钮需确认关注后才可进入聊天；举报用户后安全导航
class UserInfo_Maki: UIViewController {

    // MARK: - 对外属性
    var userModel_Maki: PrewUserModel_Maki?

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary = UIColor(hexstring_Maki: "#FF8C00")
        static let bg      = UIColor(hexstring_Maki: "#FFFBF4")
        static let card    = UIColor.white
        static let tp      = UIColor(hexstring_Maki: "#1A0A00")
        static let ts      = UIColor(hexstring_Maki: "#8B7355")
        static let cellId  = "UserInfoPostCell_Maki"
    }

    // MARK: - 数据

    private var userPosts_Maki: [TitleModel_Maki] {
        guard let user_maki = userModel_Maki else { return [] }
        return TitleViewModel_Maki.shared_Maki.getUserPosts_Maki(user_maki: user_maki)
    }
    private var isFollowing_Maki: Bool {
        guard let user_maki = userModel_Maki else { return false }
        return UserViewModel_Maki.shared_Maki.isFollowing_Maki(user_maki: user_maki)
    }

    // MARK: - UI 属性 / 主容器

    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.alwaysBounceVertical = true
        sv_maki.contentInsetAdjustmentBehavior = .never
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    // MARK: - UI 属性 / 头部区域

    private let headerView_Maki = UIView()
    private let headerGrad_Maki = CAGradientLayer()
    private let headerBubble1_Maki = UIView()
    private let headerBubble2_Maki = UIView()

    /// 头像光晕外圈
    private let avatarRing_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_maki.layer.cornerRadius = 50
        return v_maki
    }()
    private let avatarView_Maki = UserAvatarView_Maki()
    private let nameLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = UIFont(name: "Georgia-Bold", size: 22)
            ?? .systemFont(ofSize: 22, weight: .bold)
        lb_maki.textColor = .white
        lb_maki.textAlignment = .center
        return lb_maki
    }()
    private let bioLabel_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = UIFont(name: "Georgia-Italic", size: 13)
            ?? .italicSystemFont(ofSize: 13)
        lb_maki.textColor = UIColor.white.withAlphaComponent(0.85)
        lb_maki.textAlignment = .center
        lb_maki.numberOfLines = 2
        return lb_maki
    }()
    /// 玻璃态统计数据行
    private let statsRow_Maki = UIView()

    // MARK: - UI 属性 / 操作按钮

    private let followBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("Follow", for: .normal)
        btn_maki.setTitleColor(.white, for: .normal)
        btn_maki.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
        btn_maki.layer.cornerRadius = 18
        btn_maki.layer.borderWidth  = 2
        btn_maki.layer.borderColor  = UIColor.white.withAlphaComponent(0.7).cgColor
        btn_maki.backgroundColor    = UIColor.white.withAlphaComponent(0.2)
        return btn_maki
    }()
    private let messageBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setImage(UIImage(systemName: "message.fill"), for: .normal)
        btn_maki.tintColor = .white
        btn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_maki.layer.cornerRadius = 18
        btn_maki.layer.borderWidth  = 2
        btn_maki.layer.borderColor  = UIColor.white.withAlphaComponent(0.7).cgColor
        return btn_maki
    }()

    // MARK: - UI 属性 / 帖子网格

    private let postsSection_Maki = UIView()
    private lazy var postsCV_Maki: UICollectionView = {
        let itemW_maki = (APPSCREEN_Maki.WIDTH_Maki - 50) / 2
        let layout_maki = UICollectionViewFlowLayout()
        layout_maki.itemSize = CGSize(width: itemW_maki, height: itemW_maki * 1.3)
        layout_maki.minimumInteritemSpacing = 10
        layout_maki.minimumLineSpacing = 12
        layout_maki.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 100, right: 20)
        let cv_maki = UICollectionView(frame: .zero, collectionViewLayout: layout_maki)
        cv_maki.backgroundColor = .clear
        cv_maki.isScrollEnabled = false
        cv_maki.dataSource = self
        cv_maki.delegate   = self
        cv_maki.register(MePostCell_Maki.self, forCellWithReuseIdentifier: K_Maki.cellId)
        return cv_maki
    }()
    private var postsCVHeight_Maki: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        setupNav_Maki()
        buildUI_Maki()
        bindNotifications_Maki()
        reloadAll_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadAll_Maki()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGrad_Maki.frame = headerView_Maki.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 导航栏（透明 + 举报按钮）

    private func setupNav_Maki() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(onReportUser_Maki)
        )
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
}

// MARK: - UI 构建

extension UserInfo_Maki {

    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }
        buildHeader_Maki()
        buildPostsSection_Maki()
    }

    /// 构建头部渐变区（内容驱动高度，与 Me 页设计一致）
    private func buildHeader_Maki() {
        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        headerGrad_Maki.colors = [
            UIColor(hexstring_Maki: "#E8650A").cgColor,
            UIColor(hexstring_Maki: "#FF9F1C").cgColor
        ]
        headerGrad_Maki.startPoint = CGPoint(x: 0, y: 0)
        headerGrad_Maki.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Maki.layer.insertSublayer(headerGrad_Maki, at: 0)
        contentView_Maki.addSubview(headerView_Maki)
        headerView_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            // 高度由内容（decoBar）驱动
        }

        // 装饰气泡
        headerBubble1_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        headerBubble1_Maki.layer.cornerRadius = 70
        headerView_Maki.addSubview(headerBubble1_Maki)
        headerBubble1_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.trailing.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(-30)
        }
        headerBubble2_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        headerBubble2_Maki.layer.cornerRadius = 40
        headerView_Maki.addSubview(headerBubble2_Maki)
        headerBubble2_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.leading.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview().offset(-20)
        }

        // 自定义返回按钮
        let backBtn_maki = UIButton(type: .system)
        backBtn_maki.setImage(UIImage(systemName: "arrow.left"), for: .normal)
        backBtn_maki.tintColor = .white
        backBtn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        backBtn_maki.layer.cornerRadius = 18
        backBtn_maki.layer.borderWidth = 1.5
        backBtn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        backBtn_maki.addTarget(self, action: #selector(onBack_Maki), for: .touchUpInside)
        headerView_Maki.addSubview(backBtn_maki)
        backBtn_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(statusH_maki + 10)
            make.width.height.equalTo(36)
        }

        // 举报按钮（右上角）
        let reportBtn_maki = UIButton(type: .system)
        reportBtn_maki.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        reportBtn_maki.tintColor = .white
        reportBtn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        reportBtn_maki.layer.cornerRadius = 18
        reportBtn_maki.layer.borderWidth = 1.5
        reportBtn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        reportBtn_maki.addTarget(self, action: #selector(onReportUser_Maki), for: .touchUpInside)
        headerView_Maki.addSubview(reportBtn_maki)
        reportBtn_maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.centerY.equalTo(backBtn_maki)
            make.width.height.equalTo(36)
        }

        // 头像光晕外圈
        headerView_Maki.addSubview(avatarRing_Maki)
        avatarRing_Maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(statusH_maki + 58)
            make.width.height.equalTo(100)
        }

        // 头像
        avatarView_Maki.layer.cornerRadius = 38
        avatarView_Maki.clipsToBounds = true
        avatarView_Maki.layer.borderWidth = 3.5
        avatarView_Maki.layer.borderColor = UIColor.white.cgColor
        headerView_Maki.addSubview(avatarView_Maki)
        avatarView_Maki.snp.makeConstraints { make in
            make.center.equalTo(avatarRing_Maki)
            make.width.height.equalTo(76)
        }

        // 用户名
        headerView_Maki.addSubview(nameLabel_Maki)
        nameLabel_Maki.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_Maki.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }

        // 简介
        headerView_Maki.addSubview(bioLabel_Maki)
        bioLabel_Maki.snp.makeConstraints { make in
            make.top.equalTo(nameLabel_Maki.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(36)
        }

        // 统计玻璃卡
        let glassBg_maki = UIView()
        glassBg_maki.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        glassBg_maki.layer.cornerRadius = 16
        glassBg_maki.layer.borderWidth  = 1
        glassBg_maki.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        headerView_Maki.addSubview(glassBg_maki)
        glassBg_maki.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(bioLabel_Maki.snp.bottom).offset(14)
            make.height.equalTo(54)
        }
        glassBg_maki.addSubview(statsRow_Maki)
        statsRow_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 关注 / 消息 按钮行
        followBtn_Maki.addTarget(self, action: #selector(onFollow_Maki), for: .touchUpInside)
        messageBtn_Maki.addTarget(self, action: #selector(onMessage_Maki), for: .touchUpInside)
        let btnStack_maki = UIStackView(arrangedSubviews: [followBtn_Maki, messageBtn_Maki])
        btnStack_maki.axis = .horizontal
        btnStack_maki.spacing = 12
        headerView_Maki.addSubview(btnStack_maki)
        btnStack_maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(glassBg_maki.snp.bottom).offset(14)
        }
        followBtn_Maki.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(36)
        }
        messageBtn_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        // 底部圆角过渡条（驱动 headerView 高度）
        let decoBar_maki = UIView()
        decoBar_maki.backgroundColor = K_Maki.bg
        decoBar_maki.layer.cornerRadius = 22
        decoBar_maki.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerView_Maki.addSubview(decoBar_maki)
        decoBar_maki.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(btnStack_maki.snp.bottom).offset(14)
            make.height.equalTo(28)
            make.bottom.equalToSuperview()
        }
    }

    /// 构建帖子网格区（区块标题 + CollectionView）
    private func buildPostsSection_Maki() {
        contentView_Maki.addSubview(postsSection_Maki)
        postsSection_Maki.snp.makeConstraints { make in
            make.top.equalTo(headerView_Maki.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        // 区块标题行
        let titleRow_maki = UIView()
        let iconIV_maki = UIImageView(image: UIImage(systemName: "square.grid.2x2.fill"))
        iconIV_maki.tintColor = K_Maki.primary
        iconIV_maki.contentMode = .scaleAspectFit
        let titleLb_maki = UILabel()
        titleLb_maki.text = "Creations"
        titleLb_maki.font = .systemFont(ofSize: 17, weight: .bold)
        titleLb_maki.textColor = K_Maki.tp
        titleRow_maki.addSubview(iconIV_maki)
        titleRow_maki.addSubview(titleLb_maki)
        iconIV_maki.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(18)
        }
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_maki.snp.trailing).offset(7)
            make.centerY.trailing.equalToSuperview()
        }
        postsSection_Maki.addSubview(titleRow_maki)
        titleRow_maki.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }

        postsSection_Maki.addSubview(postsCV_Maki)
        postsCV_Maki.snp.makeConstraints { make in
            make.top.equalTo(titleRow_maki.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
            postsCVHeight_Maki = make.height.equalTo(200).constraint
        }
    }
}

// MARK: - 数据刷新

extension UserInfo_Maki {

    private func reloadAll_Maki() {
        guard let user_maki = userModel_Maki else { return }
        avatarView_Maki.configure_Maki(userId_Maki: user_maki.userId_Maki ?? 0)
        nameLabel_Maki.text = user_maki.userName_Maki
        bioLabel_Maki.text  = user_maki.userIntroduce_Maki?.isEmpty == false
            ? user_maki.userIntroduce_Maki
            : "Craft · Create · Share"

        // 重建统计行
        statsRow_Maki.subviews.forEach { $0.removeFromSuperview() }
        let stackStats_maki = UIStackView()
        stackStats_maki.axis = .horizontal
        stackStats_maki.distribution = .fillEqually
        stackStats_maki.alignment = .center
        statsRow_Maki.addSubview(stackStats_maki)
        stackStats_maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        let statItems_maki: [(String, String)] = [
            ("\(user_maki.userFollow_Maki ?? 0)", "Following"),
            ("\(user_maki.userFans_Maki ?? 0)",   "Followers"),
            ("\(userPosts_Maki.count)",            "Posts")
        ]
        for (i_maki, (num_maki, title_maki)) in statItems_maki.enumerated() {
            let col_maki = UIView()
            let numLb_maki = UILabel()
            numLb_maki.text = num_maki
            numLb_maki.font = .systemFont(ofSize: 18, weight: .bold)
            numLb_maki.textColor = .white
            numLb_maki.textAlignment = .center
            let titleLb_maki = UILabel()
            titleLb_maki.text = title_maki
            titleLb_maki.font = .systemFont(ofSize: 10, weight: .medium)
            titleLb_maki.textColor = UIColor.white.withAlphaComponent(0.8)
            titleLb_maki.textAlignment = .center
            col_maki.addSubview(numLb_maki)
            col_maki.addSubview(titleLb_maki)
            numLb_maki.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(8)
                make.centerX.equalToSuperview()
            }
            titleLb_maki.snp.makeConstraints { make in
                make.top.equalTo(numLb_maki.snp.bottom).offset(1)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-8)
            }
            if i_maki < statItems_maki.count - 1 {
                let div_maki = UIView()
                div_maki.backgroundColor = UIColor.white.withAlphaComponent(0.25)
                col_maki.addSubview(div_maki)
                div_maki.snp.makeConstraints { make in
                    make.trailing.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.width.equalTo(1)
                    make.height.equalTo(22)
                }
            }
            stackStats_maki.addArrangedSubview(col_maki)
        }

        updateFollowBtn_Maki()
        postsCV_Maki.reloadData()
        let itemW_maki = (APPSCREEN_Maki.WIDTH_Maki - 50) / 2
        let rows_maki  = ceil(CGFloat(userPosts_Maki.count) / 2)
        postsCVHeight_Maki?.update(offset: max(rows_maki * itemW_maki * 1.3 + max(0, rows_maki - 1) * 12 + 20 + 100, 200))
    }

    private func updateFollowBtn_Maki() {
        let following_maki = isFollowing_Maki
        followBtn_Maki.setTitle(following_maki ? "Following ✓" : "Follow", for: .normal)
        followBtn_Maki.backgroundColor = following_maki
            ? UIColor.white.withAlphaComponent(0.35)
            : UIColor.white.withAlphaComponent(0.2)
    }
}

// MARK: - 通知

extension UserInfo_Maki {

    private func bindNotifications_Maki() {
        NotificationCenter.default.addObserver(self, selector: #selector(onDataChange_Maki),
            name: UserViewModel_Maki.userStateDidChangeNotification_Maki, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDataChange_Maki),
            name: TitleViewModel_Maki.titleStateDidChangeNotification_Maki, object: nil)
    }
    @objc private func onDataChange_Maki() { reloadAll_Maki() }
}

// MARK: - 事件响应

extension UserInfo_Maki {

    @objc private func onBack_Maki() { Navigation_Maki.pop_Maki() }

    @objc private func onFollow_Maki() {
        guard let user_maki = userModel_Maki else { return }
        guard UserViewModel_Maki.shared_Maki.isLoggedIn_Maki else {
            Navigation_Maki.toLogin_Maki(style_maki: .present_maki); return
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UserViewModel_Maki.shared_Maki.followUser_Maki(user_maki: user_maki)
        updateFollowBtn_Maki()
    }

    @objc private func onMessage_Maki() {
        guard UserViewModel_Maki.shared_Maki.isLoggedIn_Maki else {
            Navigation_Maki.toLogin_Maki(style_maki: .present_maki); return
        }
        guard isFollowing_Maki else {
            Load_Maki.showWarning_Maki(message_Maki: "Follow this user first to send a message"); return
        }
        showChatConfirmSheet_Maki()
    }

    private func showChatConfirmSheet_Maki() {
        guard let user_maki = userModel_Maki else { return }
        let alert_maki = UIAlertController(
            title: "Start a conversation with \(user_maki.userName_Maki ?? "this user")?",
            message: user_maki.userIntroduce_Maki ?? "",
            preferredStyle: .actionSheet
        )
        alert_maki.addAction(UIAlertAction(title: "Start Chat", style: .default) { [weak self] _ in
            Navigation_Maki.toMessageUser_Maki(with: user_maki)
        })
        alert_maki.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_maki, animated: true)
    }

    @objc private func onReportUser_Maki() {
        guard let user_maki = userModel_Maki else { return }
        UIAlertController.report_Maki(with: true) { [weak self] in
            guard let self else { return }
            UserViewModel_Maki.shared_Maki.reportUser_Maki(user_maki: user_maki)
            Navigation_Maki.popToSafeStateAfterBlock_Maki(from: self)
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension UserInfo_Maki: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        userPosts_Maki.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_maki = collectionView.dequeueReusableCell(
            withReuseIdentifier: K_Maki.cellId, for: indexPath
        ) as! MePostCell_Maki
        let post_maki = userPosts_Maki[indexPath.item]
        cell_maki.configure_Maki(post_maki: post_maki, showDelete: false, vc_maki: self) { [weak self] in
            self?.postsCV_Maki.reloadData()
        }
        return cell_maki
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < userPosts_Maki.count else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Maki.toTitleDetail_Maki(titleModel_maki: userPosts_Maki[indexPath.item])
    }
}
