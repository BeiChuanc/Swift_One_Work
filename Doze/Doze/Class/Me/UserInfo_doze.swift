import Foundation
import UIKit
import SnapKit

// MARK: - 用户中心页（预制用户）

/// 用户中心页面
/// 核心作用：展示他人用户信息（头像、名称、Bio、数据统计）及其发布的帖子列表
/// 设计风格：沉浸式三色渐变顶部横幅 + 悬浮头像卡片 + 帖子双列瀑布流
/// 关键属性：
///   - userModel_Doze: 外部传入的预制用户模型
/// 关键方法：
///   - loadData_Doze: 加载用户信息与帖子
///   - refreshGrid_Doze: 重建帖子双列网格
class UserInfo_Doze: UIViewController {

    // MARK: - 外部数据

    /// 外部传入用户模型
    var userModel_Doze: PrewUserModel_Doze?

    // MARK: - 顶部横幅

    private let heroBg_Doze: UIView = {
        let v = UIView()
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.layer.cornerRadius = 32
        v.clipsToBounds = true
        return v
    }()

    private let heroGradient_Doze: CAGradientLayer = {
        let gl = CAGradientLayer()
        gl.colors = [
            UIColor(hexstring_Doze: "#4A1D96").cgColor,
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        gl.locations = [0, 0.5, 1]
        gl.startPoint = CGPoint(x: 0, y: 0)
        gl.endPoint = CGPoint(x: 1, y: 1)
        return gl
    }()

    /// 装饰圆 - 右上
    private let deco1_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 52
        return v
    }()

    /// 装饰圆 - 左下
    private let deco2_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        v.layer.cornerRadius = 36
        return v
    }()

    /// 爪印装饰图标
    private let pawIcon_Doze: UIImageView = {
        let iv = UIImageView()
        let cfg = UIImage.SymbolConfiguration(pointSize: 24, weight: .thin)
        iv.image = UIImage(systemName: "pawprint.fill", withConfiguration: cfg)
        iv.tintColor = UIColor.white.withAlphaComponent(0.10)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - 顶栏按钮

    /// 返回按钮
    private let backBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        btn.setImage(UIImage(systemName: "chevron.left", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()

    /// 举报按钮
    private let reportBtn_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        btn.layer.cornerRadius = 18
        return btn
    }()

    // MARK: - 头像卡片（悬浮在横幅底部）

    private let avatarCard_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 28
        v.layer.shadowColor = UIColor(hexstring_Doze: "#7C3AED").withAlphaComponent(0.15).cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        v.layer.shadowRadius = 20
        v.layer.shadowOpacity = 1
        return v
    }()

    private let avatarView_Doze = UserAvatarView_Doze()

    private let userNameLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl.textColor = ColorConfig_Doze.textPrimary_Doze
        lbl.textAlignment = .center
        return lbl
    }()

    private let bioLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = ColorConfig_Doze.textSecondary_Doze
        lbl.textAlignment = .center
        lbl.numberOfLines = 2
        return lbl
    }()

    // MARK: - 关注 & 聊天按钮行

    /// 关注 / 已关注切换按钮
    private let followButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Follow", for: .normal)
        btn.setTitle("Followed", for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitleColor(ColorConfig_Doze.primaryGradientStart_Doze, for: .selected)
        btn.layer.cornerRadius = 18
        btn.layer.masksToBounds = true
        return btn
    }()

    private let followGradient_Doze = CAGradientLayer()

    /// 进入聊天按钮
    private let chatButton_Doze: UIButton = {
        let btn = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        btn.setImage(UIImage(systemName: "bubble.fill", withConfiguration: cfg), for: .normal)
        btn.setTitle("  Chat", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        btn.setTitleColor(ColorConfig_Doze.primaryGradientStart_Doze, for: .normal)
        btn.tintColor = ColorConfig_Doze.primaryGradientStart_Doze
        btn.backgroundColor = UIColor(hexstring_Doze: "#F0ECF9")
        btn.layer.cornerRadius = 18
        btn.layer.masksToBounds = true
        return btn
    }()

    /// 关注与聊天并排的按钮行容器
    private let actionButtonRow_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fillEqually
        sv.alignment = .fill
        return sv
    }()

    // MARK: - 统计行

    private let statsRow_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()

    // MARK: - 内容 ScrollView

    private let scrollView_Doze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let gridContainer_Doze = UIView()

    private let emptyView_Doze: UIView = {
        let v = UIView()
        v.isHidden = true
        return v
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Doze: "#F2F0F8")
        setupHero_Doze()
        setupAvatarCard_Doze()
        setupScrollView_Doze()
        setupEmptyView_Doze()
        setupNotifications_Doze()
        loadData_Doze()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heroGradient_Doze.frame = heroBg_Doze.bounds
        followGradient_Doze.frame = followButton_Doze.bounds
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 通知

    private func setupNotifications_Doze() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Doze),
            name: TitleViewModel_Doze.titleStateDidChangeNotification_Doze,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Doze),
            name: UserViewModel_Doze.userStateDidChangeNotification_Doze,
            object: nil
        )
    }

    @objc private func onDataChanged_Doze() {
        loadData_Doze()
    }

    // MARK: - 顶部横幅搭建

    private func setupHero_Doze() {
        view.addSubview(heroBg_Doze)
        heroBg_Doze.layer.addSublayer(heroGradient_Doze)
        heroBg_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }

        // 装饰元素
        heroBg_Doze.addSubview(deco1_Doze)
        deco1_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(-20)
            make.width.height.equalTo(104)
        }

        heroBg_Doze.addSubview(deco2_Doze)
        deco2_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(-18)
            make.bottom.equalToSuperview().offset(18)
            make.width.height.equalTo(72)
        }

        heroBg_Doze.addSubview(pawIcon_Doze)
        pawIcon_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(56)
            make.width.height.equalTo(36)
        }

        // 返回按钮
        heroBg_Doze.addSubview(backBtn_Doze)
        backBtn_Doze.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.width.height.equalTo(36)
        }
        backBtn_Doze.addTarget(self, action: #selector(backTapped_Doze), for: .touchUpInside)

        // 举报按钮
        heroBg_Doze.addSubview(reportBtn_Doze)
        reportBtn_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(backBtn_Doze)
            make.width.height.equalTo(36)
        }
        reportBtn_Doze.addTarget(self, action: #selector(reportTapped_Doze), for: .touchUpInside)
    }

    // MARK: - 头像卡片搭建

    private func setupAvatarCard_Doze() {
        view.addSubview(avatarCard_Doze)
        avatarCard_Doze.snp.makeConstraints { make in
            make.top.equalTo(heroBg_Doze.snp.bottom).offset(-30)
            make.left.right.equalToSuperview().inset(20)
        }

        // 头像
        avatarCard_Doze.addSubview(avatarView_Doze)
        avatarView_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-24)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        // 头像白色圆形边框
        avatarView_Doze.layer.cornerRadius = 40
        avatarView_Doze.layer.borderWidth = 3
        avatarView_Doze.layer.borderColor = UIColor.white.cgColor
        avatarView_Doze.clipsToBounds = true

        // 用户名
        avatarCard_Doze.addSubview(userNameLabel_Doze)
        userNameLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(avatarView_Doze.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }

        // Bio
        avatarCard_Doze.addSubview(bioLabel_Doze)
        bioLabel_Doze.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel_Doze.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(20)
        }

        // 分隔线
        let sep_Doze = UIView()
        sep_Doze.backgroundColor = ColorConfig_Doze.divider_Doze
        avatarCard_Doze.addSubview(sep_Doze)
        sep_Doze.snp.makeConstraints { make in
            make.top.equalTo(bioLabel_Doze.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }

        // 统计行
        avatarCard_Doze.addSubview(statsRow_Doze)
        statsRow_Doze.snp.makeConstraints { make in
            make.top.equalTo(sep_Doze.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(48)
        }

        // 关注 + 聊天按钮行
        setupFollowButton_Doze()
        actionButtonRow_Doze.addArrangedSubview(followButton_Doze)
        actionButtonRow_Doze.addArrangedSubview(chatButton_Doze)
        avatarCard_Doze.addSubview(actionButtonRow_Doze)
        actionButtonRow_Doze.snp.makeConstraints { make in
            make.top.equalTo(statsRow_Doze.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(38)
            make.bottom.equalToSuperview().offset(-20)
        }
        chatButton_Doze.addTarget(self, action: #selector(chatTapped_Doze), for: .touchUpInside)
    }

    /// 配置关注按钮渐变背景
    private func setupFollowButton_Doze() {
        followGradient_Doze.colors = [
            ColorConfig_Doze.primaryGradientStart_Doze.cgColor,
            ColorConfig_Doze.primaryGradientEnd_Doze.cgColor
        ]
        followGradient_Doze.startPoint = CGPoint(x: 0, y: 0)
        followGradient_Doze.endPoint = CGPoint(x: 1, y: 0)
        followButton_Doze.layer.insertSublayer(followGradient_Doze, at: 0)
        followButton_Doze.addTarget(self, action: #selector(followTapped_Doze), for: .touchUpInside)
    }

    // MARK: - ScrollView 搭建

    private func setupScrollView_Doze() {
        // "Posts" 分区标题
        let sectionLabel_Doze = UILabel()
        sectionLabel_Doze.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        sectionLabel_Doze.textColor = ColorConfig_Doze.textPrimary_Doze
        sectionLabel_Doze.text = "Posts"
        view.addSubview(sectionLabel_Doze)
        sectionLabel_Doze.snp.makeConstraints { make in
            // 约束将在 avatarCard_Doze 布局完成后才能正确设置，用延迟或先做相对约束
            make.left.equalToSuperview().offset(20)
        }

        view.addSubview(scrollView_Doze)
        scrollView_Doze.snp.makeConstraints { make in
            make.top.equalTo(avatarCard_Doze.snp.bottom).offset(36)
            make.left.right.bottom.equalToSuperview()
        }

        // 更新分区标签约束（在 scrollView 上方）
        sectionLabel_Doze.snp.remakeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(scrollView_Doze.snp.top).offset(-10)
        }

        scrollView_Doze.addSubview(gridContainer_Doze)
        gridContainer_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }

    // MARK: - 空状态

    private func setupEmptyView_Doze() {
        scrollView_Doze.addSubview(emptyView_Doze)
        emptyView_Doze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(60)
        }

        let iconIv_Doze = UIImageView()
        let cfg_Doze = UIImage.SymbolConfiguration(pointSize: 40, weight: .thin)
        iconIv_Doze.image = UIImage(systemName: "moon.zzz", withConfiguration: cfg_Doze)
        iconIv_Doze.tintColor = ColorConfig_Doze.textPlaceholder_Doze
        emptyView_Doze.addSubview(iconIv_Doze)
        iconIv_Doze.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.width.height.equalTo(52)
        }

        let lbl_Doze = UILabel()
        lbl_Doze.text = "No posts yet"
        lbl_Doze.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        lbl_Doze.textColor = ColorConfig_Doze.textSecondary_Doze
        lbl_Doze.textAlignment = .center
        emptyView_Doze.addSubview(lbl_Doze)
        lbl_Doze.snp.makeConstraints { make in
            make.top.equalTo(iconIv_Doze.snp.bottom).offset(10)
            make.centerX.bottom.equalToSuperview()
        }
    }

    // MARK: - 数据加载

    /// 加载用户信息和帖子数据
    private func loadData_Doze() {
        guard let user_Doze = userModel_Doze else { return }

        // 头像
        avatarView_Doze.configure_Doze(userId_Doze: user_Doze.userId_Doze ?? 0)

        // 名称 / Bio
        userNameLabel_Doze.text = user_Doze.userName_Doze ?? "User"
        bioLabel_Doze.text = user_Doze.userIntroduce_Doze?.isEmpty == false
            ? user_Doze.userIntroduce_Doze
            : "No bio yet ·  Keeping it mysterious 🐾"

        // 关注状态
        let isFollowing_Doze = UserViewModel_Doze.shared_Doze.isFollowing_Doze(user_doze: user_Doze)
        followButton_Doze.isSelected = isFollowing_Doze
        followButton_Doze.backgroundColor = isFollowing_Doze
            ? UIColor(hexstring_Doze: "#F0ECF9")
            : .clear

        // 统计行
        refreshStats_Doze(user_Doze: user_Doze)

        // 帖子网格
        let posts_Doze = TitleViewModel_Doze.shared_Doze.getUserPosts_Doze(user_doze: user_Doze)
        refreshGrid_Doze(posts_Doze: posts_Doze)
    }

    /// 重建统计数据行
    private func refreshStats_Doze(user_Doze: PrewUserModel_Doze) {
        statsRow_Doze.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let postsCount_Doze = TitleViewModel_Doze.shared_Doze
            .getUserPosts_Doze(user_doze: user_Doze).count
        let followCount_Doze = user_Doze.userFollow_Doze ?? 0
        let fansCount_Doze   = user_Doze.userFans_Doze ?? 0

        let item1_Doze = makeStatItem_Doze(value: "\(postsCount_Doze)", label: "Posts")
        let item2_Doze = makeStatItem_Doze(value: "\(followCount_Doze)", label: "Following")
        let item3_Doze = makeStatItem_Doze(value: "\(fansCount_Doze)", label: "Fans")

        statsRow_Doze.addArrangedSubview(item1_Doze)
        statsRow_Doze.addArrangedSubview(makeDivider_Doze())
        statsRow_Doze.addArrangedSubview(item2_Doze)
        statsRow_Doze.addArrangedSubview(makeDivider_Doze())
        statsRow_Doze.addArrangedSubview(item3_Doze)

        item1_Doze.snp.makeConstraints { make in make.width.equalTo(item2_Doze) }
        item3_Doze.snp.makeConstraints { make in make.width.equalTo(item2_Doze) }
    }

    /// 构建统计数值项
    private func makeStatItem_Doze(value: String, label: String) -> UIView {
        let v_Doze = UIView()

        let valLbl_Doze = UILabel()
        valLbl_Doze.text = value
        valLbl_Doze.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        valLbl_Doze.textColor = ColorConfig_Doze.textPrimary_Doze
        valLbl_Doze.textAlignment = .center

        let nameLbl_Doze = UILabel()
        nameLbl_Doze.text = label
        nameLbl_Doze.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        nameLbl_Doze.textColor = ColorConfig_Doze.textSecondary_Doze
        nameLbl_Doze.textAlignment = .center

        v_Doze.addSubview(valLbl_Doze)
        v_Doze.addSubview(nameLbl_Doze)

        valLbl_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        nameLbl_Doze.snp.makeConstraints { make in
            make.top.equalTo(valLbl_Doze.snp.bottom).offset(3)
            make.left.right.bottom.equalToSuperview()
        }
        return v_Doze
    }

    /// 构建统计行分隔线
    private func makeDivider_Doze() -> UIView {
        let v_Doze = UIView()
        v_Doze.backgroundColor = ColorConfig_Doze.divider_Doze
        v_Doze.snp.makeConstraints { make in
            make.width.equalTo(0.5)
            make.height.equalTo(28)
        }
        return v_Doze
    }

    /// 重建帖子双列网格
    private func refreshGrid_Doze(posts_Doze: [TitleModel_Doze]) {
        gridContainer_Doze.subviews.forEach { $0.removeFromSuperview() }

        if posts_Doze.isEmpty {
            emptyView_Doze.isHidden = false
            emptyView_Doze.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(60)
                make.width.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            return
        }

        emptyView_Doze.isHidden = true

        let screenW_Doze = UIScreen.main.bounds.width
        let cardW_Doze = (screenW_Doze - 36) / 2

        let colLeft_Doze  = UIStackView(); colLeft_Doze.axis = .vertical;  colLeft_Doze.spacing = 10
        let colRight_Doze = UIStackView(); colRight_Doze.axis = .vertical; colRight_Doze.spacing = 10

        for (idx_Doze, post_Doze) in posts_Doze.enumerated() {
            let card_Doze = makePostCard_Doze(post_Doze: post_Doze, width_Doze: cardW_Doze)
            if idx_Doze % 2 == 0 {
                colLeft_Doze.addArrangedSubview(card_Doze)
            } else {
                colRight_Doze.addArrangedSubview(card_Doze)
            }
        }

        gridContainer_Doze.addSubview(colLeft_Doze)
        gridContainer_Doze.addSubview(colRight_Doze)

        colLeft_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.equalToSuperview().offset(12)
            make.width.equalTo(cardW_Doze)
        }
        colRight_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(cardW_Doze)
        }

        let anchor_Doze = UIView()
        gridContainer_Doze.addSubview(anchor_Doze)
        anchor_Doze.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(colLeft_Doze.snp.bottom)
            make.top.greaterThanOrEqualTo(colRight_Doze.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
            make.height.equalTo(1)
        }
    }

    /// 构建单张帖子卡片
    private func makePostCard_Doze(post_Doze: TitleModel_Doze, width_Doze: CGFloat) -> UIView {
        let card_Doze = UIView()
        card_Doze.backgroundColor = .white
        card_Doze.layer.cornerRadius = 16
        card_Doze.layer.shadowColor = UIColor(hexstring_Doze: "#7C3AED").withAlphaComponent(0.10).cgColor
        card_Doze.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Doze.layer.shadowRadius = 10
        card_Doze.layer.shadowOpacity = 1
        card_Doze.snp.makeConstraints { make in make.width.equalTo(width_Doze) }

        // 媒体图片
        let mediaView_Doze = MediaDisplayView_Doze()
        mediaView_Doze.layer.cornerRadius = 14
        mediaView_Doze.configure_Doze(mediaPath_Doze: post_Doze.titleMeidas_Doze.first)
        card_Doze.addSubview(mediaView_Doze)
        mediaView_Doze.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(width_Doze * 0.88)
        }

        // 底部渐变遮罩
        let overlay_Doze = UIView()
        mediaView_Doze.addSubview(overlay_Doze)
        overlay_Doze.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(width_Doze * 0.35)
        }
        let overlayGl_Doze = CAGradientLayer()
        overlayGl_Doze.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.30).cgColor]
        overlayGl_Doze.startPoint = CGPoint(x: 0.5, y: 0)
        overlayGl_Doze.endPoint   = CGPoint(x: 0.5, y: 1)
        overlay_Doze.layer.addSublayer(overlayGl_Doze)
        DispatchQueue.main.async { overlayGl_Doze.frame = overlay_Doze.bounds }

        // 宠物类别 Badge（左上角）
        let badge_Doze = UIView()
        badge_Doze.backgroundColor = UIColor.black.withAlphaComponent(0.28)
        badge_Doze.layer.cornerRadius = 8
        let badgeLbl_Doze = UILabel()
        badgeLbl_Doze.text = post_Doze.petCategory_Doze.rawValue
        badgeLbl_Doze.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        badgeLbl_Doze.textColor = .white
        badge_Doze.addSubview(badgeLbl_Doze)
        badgeLbl_Doze.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(3)
            make.left.right.equalToSuperview().inset(6)
        }
        mediaView_Doze.addSubview(badge_Doze)
        badge_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
        }

        // 举报/删除按钮（右上角，逻辑由 ReportDeleteHelper 决定）
        let reportBtn_Doze = ReportDeleteHelper_Doze.createPostReportButton_Doze(
            post_Doze: post_Doze,
            size_Doze: 12,
            color_Doze: .white,
            from: self
        ) { [weak self] in
            self?.loadData_Doze()
        }
        reportBtn_Doze.backgroundColor = UIColor.black.withAlphaComponent(0.30)
        reportBtn_Doze.layer.cornerRadius = 13
        mediaView_Doze.addSubview(reportBtn_Doze)
        reportBtn_Doze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
            make.width.height.equalTo(26)
        }

        // 标题
        let titleLbl_Doze = UILabel()
        titleLbl_Doze.text = post_Doze.title_Doze
        titleLbl_Doze.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLbl_Doze.textColor = ColorConfig_Doze.textPrimary_Doze
        titleLbl_Doze.numberOfLines = 2
        card_Doze.addSubview(titleLbl_Doze)
        titleLbl_Doze.snp.makeConstraints { make in
            make.top.equalTo(mediaView_Doze.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(10)
        }

        // 底部点赞行（与发现页一致：数量右锚定，图标在左，可点击）
        let likeBottomRow_Doze = UIView()
        card_Doze.addSubview(likeBottomRow_Doze)
        likeBottomRow_Doze.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Doze.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-10)
        }

        // 点赞数（右侧锚定，保证完整显示）
        let likesLbl_Doze = UILabel()
        likesLbl_Doze.text = "\(post_Doze.likes_Doze)"
        likesLbl_Doze.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        likesLbl_Doze.textColor = ColorConfig_Doze.secondaryGradientStart_Doze
        likesLbl_Doze.setContentHuggingPriority(.required, for: .horizontal)
        likesLbl_Doze.setContentCompressionResistancePriority(.required, for: .horizontal)
        likeBottomRow_Doze.addSubview(likesLbl_Doze)
        likesLbl_Doze.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-2)
            make.centerY.equalToSuperview()
        }

        // 点赞图标（在数字左侧，尺寸放大与发现页一致）
        let heartIv_Doze = UIImageView()
        let hCfg_Doze = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        heartIv_Doze.image = UIImage(systemName: "heart.fill", withConfiguration: hCfg_Doze)
        heartIv_Doze.tintColor = ColorConfig_Doze.secondaryGradientStart_Doze
        heartIv_Doze.contentMode = .scaleAspectFit
        likeBottomRow_Doze.addSubview(heartIv_Doze)
        heartIv_Doze.snp.makeConstraints { make in
            make.right.equalTo(likesLbl_Doze.snp.left).offset(-3)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }

        // 透明点赞按钮：覆盖图标与数字，tag 为帖子 ID
        let likeBtn_Doze = UIButton(type: .custom)
        likeBtn_Doze.tag = post_Doze.titleId_Doze
        likeBtn_Doze.addTarget(self, action: #selector(likeBtnTapped_Doze(_:)), for: .touchUpInside)
        likeBottomRow_Doze.addSubview(likeBtn_Doze)
        likeBtn_Doze.snp.makeConstraints { make in
            make.left.equalTo(heartIv_Doze)
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }

        // 点击跳转详情
        let tap_Doze = UITapGestureRecognizer(target: self, action: #selector(postCardTapped_Doze(_:)))
        card_Doze.isUserInteractionEnabled = true
        card_Doze.addGestureRecognizer(tap_Doze)
        card_Doze.tag = post_Doze.titleId_Doze

        return card_Doze
    }

    // MARK: - 事件处理

    /// 返回
    @objc private func backTapped_Doze() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.pop_Doze()
    }

    /// 举报用户
    @objc private func reportTapped_Doze() {
        guard let user_Doze = userModel_Doze else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        ReportDeleteHelper_Doze.block_Doze(user_Doze: user_Doze, from: self) { [weak self] in
            Navigation_Doze.pop_Doze()
            self?.loadData_Doze()
        }
    }

    /// 关注/取消关注，使用 UserViewModel 处理状态并同步按钮 UI
    @objc private func followTapped_Doze() {
        guard let user_Doze = userModel_Doze else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()

        // 未登录提示
        guard UserViewModel_Doze.shared_Doze.isLoggedIn_Doze else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                Navigation_Doze.toLogin_Doze(style_doze: .present_doze)
            }
            return
        }

        UserViewModel_Doze.shared_Doze.followUser_Doze(user_doze: user_Doze)

        // 同步刷新按钮状态（Follow ↔ Followed）
        let isNowFollowing_Doze = UserViewModel_Doze.shared_Doze.isFollowing_Doze(user_doze: user_Doze)
        followButton_Doze.isSelected = isNowFollowing_Doze
        followButton_Doze.backgroundColor = isNowFollowing_Doze
            ? UIColor(hexstring_Doze: "#F0ECF9")
            : .clear

        // 按钮弹跳动画
        UIView.animate(withDuration: 0.15, animations: {
            self.followButton_Doze.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                self.followButton_Doze.transform = .identity
            }
        }
    }

    /// 点击聊天按钮 → 跳转到与该用户的聊天页
    @objc private func chatTapped_Doze() {
        guard let user_Doze = userModel_Doze else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // 未登录提示
        guard UserViewModel_Doze.shared_Doze.isLoggedIn_Doze else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                Navigation_Doze.toLogin_Doze(style_doze: .present_doze)
            }
            return
        }

        Navigation_Doze.toMessageUser_Doze(with: user_Doze)
    }

    /// 点赞按钮点击 → 调用 TitleViewModel 点赞/取消点赞
    /// - Parameter sender: tag 为帖子 ID 的透明按钮
    @objc private func likeBtnTapped_Doze(_ sender: UIButton) {
        let postId_Doze = sender.tag
        guard let post_Doze = TitleViewModel_Doze.shared_Doze.getPosts_Doze()
            .first(where: { $0.titleId_Doze == postId_Doze }) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        TitleViewModel_Doze.shared_Doze.likePost_Doze(post_doze: post_Doze)
    }

    /// 帖子卡片点击跳转详情
    @objc private func postCardTapped_Doze(_ sender: UITapGestureRecognizer) {
        guard let card_Doze = sender.view else { return }
        let postId_Doze = card_Doze.tag
        let post_Doze = TitleViewModel_Doze.shared_Doze.getPosts_Doze()
            .first(where: { $0.titleId_Doze == postId_Doze })
        guard let post_Doze = post_Doze else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Doze.toTitleDetail_Doze(titleModel_doze: post_Doze)
    }
}
