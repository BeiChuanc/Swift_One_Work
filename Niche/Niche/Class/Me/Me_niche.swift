import Foundation
import UIKit
import SnapKit

// MARK: 我的页面

/// 我的页面视图控制器
/// 功能：展示当前登录用户信息、发布/喜欢帖子，提供编辑资料和设置入口
/// 设计理念：沉浸式封面（无独立白卡）+ 玻璃拟态统计 + 胶囊式 Tab 切换 + 杂志风帖子卡片
/// 响应：监听 UserViewModel、TitleViewModel 通知刷新 UI
class Me_Niche: UIViewController {

    // MARK: - 传入数据

    var meModel_Niche: LoginUserModel_Niche?

    // MARK: - 私有属性

    private var _displayUser_niche: LoginUserModel_Niche {
        meModel_Niche ?? UserViewModel_Niche.shared_Niche.getCurrentUser_Niche()
    }
    private var _selectedTab_niche: Int = 0

    // MARK: - UI 组件 / 沉浸式封面

    private let _scrollView_niche: UIScrollView = {
        let sv_niche = UIScrollView()
        sv_niche.showsVerticalScrollIndicator = false
        sv_niche.contentInsetAdjustmentBehavior = .never
        return sv_niche
    }()
    private let _contentView_niche = UIView()

    /// 封面区域（承载所有用户信息，高 320pt）
    private let _coverView_niche = UIView()

    /// 封面装饰元素（大气泡）
    private let _orb1_niche: UIView = makeOrb_Niche(size: 160, alpha: 0.10)
    private let _orb2_niche: UIView = makeOrb_Niche(size: 90,  alpha: 0.07)
    private let _orb3_niche: UIView = makeOrb_Niche(size: 60,  alpha: 0.12)

    /// 设置按钮（右上角）
    private let _settingBtn_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn_niche.setImage(UIImage(systemName: "gearshape.fill", withConfiguration: cfg_niche), for: .normal)
        btn_niche.tintColor = .white
        btn_niche.backgroundColor = UIColor.white.withValues(alpha: 0.20)
        btn_niche.layer.cornerRadius = 18
        btn_niche.layer.borderWidth = 1
        btn_niche.layer.borderColor = UIColor.white.withValues(alpha: 0.3).cgColor
        return btn_niche
    }()

    /// 头像外发光容器
    private let _avatarGlowView_niche: UIView = {
        let v_niche = UIView()
        v_niche.layer.cornerRadius = 52
        v_niche.layer.shadowColor = UIColor(hexstring_Niche: "#B794F6").cgColor
        v_niche.layer.shadowOffset = .zero
        v_niche.layer.shadowRadius = 18
        v_niche.layer.shadowOpacity = 0.65
        return v_niche
    }()

    /// 头像外圈（渐变）
    private let _avatarRing_niche: UIView = {
        let v_niche = UIView()
        v_niche.layer.cornerRadius = 50
        return v_niche
    }()
    private var _avatarRingGrad_niche: CAGradientLayer?

    private let _avatarView_niche = CurrentUserAvatarView_Niche()

    /// 身份徽章（用户名旁边）
    private let _badgeView_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.20)
        v_niche.layer.cornerRadius = 10
        v_niche.layer.borderWidth = 0.8
        v_niche.layer.borderColor = UIColor.white.withValues(alpha: 0.35).cgColor
        return v_niche
    }()

    private let _badgeLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.text = "✦ Tribe Member"
        l_niche.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.9)
        return l_niche
    }()

    /// 用户名
    private let _nameLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        l_niche.textColor = .white
        l_niche.textAlignment = .center
        return l_niche
    }()

    /// 简介
    private let _bioLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.75)
        l_niche.textAlignment = .center
        l_niche.numberOfLines = 2
        return l_niche
    }()

    /// 玻璃拟态统计栏容器
    private let _statsGlassBar_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.15)
        v_niche.layer.cornerRadius = 18
        v_niche.layer.borderWidth = 1
        v_niche.layer.borderColor = UIColor.white.withValues(alpha: 0.25).cgColor
        return v_niche
    }()

    /// 统计数字标签缓存（动态刷新使用）
    private var _statCountLabels_niche: [UILabel] = []

    /// 编辑资料按钮（玻璃风格）
    private let _editBtn_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.setTitle("  Edit Profile  ", for: .normal)
        btn_niche.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_niche.setTitleColor(.white, for: .normal)
        btn_niche.backgroundColor = UIColor.white.withValues(alpha: 0.22)
        btn_niche.layer.cornerRadius = 20
        btn_niche.layer.borderWidth = 1.2
        btn_niche.layer.borderColor = UIColor.white.withValues(alpha: 0.40).cgColor
        return btn_niche
    }()

    // MARK: - UI 组件 / 胶囊 Tab 切换

    /// Tab 容器（浮动在封面底部）
    private let _tabContainer_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = .white
        v_niche.layer.cornerRadius = 18
        v_niche.layer.shadowColor = UIColor(hexstring_Niche: "#B794F6").withValues(alpha: 0.12).cgColor
        v_niche.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_niche.layer.shadowRadius = 12
        v_niche.layer.shadowOpacity = 1
        return v_niche
    }()

    /// 胶囊滑块（渐变背景，跟随选中切换）
    private let _tabSlider_niche: UIView = {
        let v_niche = UIView()
        v_niche.layer.cornerRadius = 14
        v_niche.clipsToBounds = true
        return v_niche
    }()
    private var _tabSliderGrad_niche: CAGradientLayer?

    private let _postsTabBtn_niche: UIButton = makeTabBtn_Niche("📝  Posts")
    private let _likedTabBtn_niche: UIButton = makeTabBtn_Niche("❤  Liked")

    // MARK: - UI 组件 / 帖子列表

    private let _postsContainer_niche = UIStackView()

    // MARK: - 辅助工厂

    private static func makeOrb_Niche(size: CGFloat, alpha: CGFloat) -> UIView {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: alpha)
        v_niche.layer.cornerRadius = size / 2
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }

    private static func makeTabBtn_Niche(_ title: String) -> UIButton {
        let btn_niche = UIButton(type: .custom)
        btn_niche.setTitle(title, for: .normal)
        btn_niche.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        return btn_niche
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
        setupObservers_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshAll_Niche()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshCoverGradient_Niche()
        refreshAvatarRingGrad_Niche()
        refreshTabSliderGrad_Niche()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#F0EEFF")

        view.addSubview(_scrollView_niche)
        _scrollView_niche.snp.makeConstraints { make in make.edges.equalToSuperview() }

        _scrollView_niche.addSubview(_contentView_niche)
        _contentView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        buildCover_Niche()
        buildTabToggle_Niche()
        buildPostsArea_Niche()

        // 设置按钮浮在最顶层
        view.addSubview(_settingBtn_niche)
        _settingBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(36)
        }
        _settingBtn_niche.addTarget(self, action: #selector(handleSetting_Niche), for: .touchUpInside)
    }

    // MARK: - 封面构建

    private func buildCover_Niche() {
        _contentView_niche.addSubview(_coverView_niche)
        // 不写死高度，由最底部元素的 bottom 约束决定
        _coverView_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        // 装饰气泡
        _coverView_niche.addSubview(_orb1_niche)
        _orb1_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-40)
            make.trailing.equalToSuperview().offset(30)
            make.width.height.equalTo(160)
        }
        _coverView_niche.addSubview(_orb2_niche)
        _orb2_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(-20)
            make.width.height.equalTo(90)
        }
        _coverView_niche.addSubview(_orb3_niche)
        _orb3_niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-80)
            make.top.equalToSuperview().offset(30)
            make.width.height.equalTo(60)
        }

        // 发光层（状态栏下约 56pt）
        _coverView_niche.addSubview(_avatarGlowView_niche)
        _avatarGlowView_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(104)
        }

        // 渐变外圈
        _avatarGlowView_niche.addSubview(_avatarRing_niche)
        _avatarRing_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }

        // 头像
        _avatarRing_niche.addSubview(_avatarView_niche)
        _avatarView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
        _avatarView_niche.onTapped_Niche = { [weak self] in
            Navigation_Niche.toEditInfo_Niche()
            _ = self
        }

        // 先全部 addSubview，再从上到下统一设置约束
        _coverView_niche.addSubview(_badgeView_niche)
        _coverView_niche.addSubview(_nameLabel_niche)
        _coverView_niche.addSubview(_bioLabel_niche)
        _coverView_niche.addSubview(_statsGlassBar_niche)
        _coverView_niche.addSubview(_editBtn_niche)

        _badgeView_niche.addSubview(_badgeLabel_niche)
        _badgeLabel_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }

        // ── 从上到下，严格按顺序约束 ──

        _badgeView_niche.snp.makeConstraints { make in
            make.top.equalTo(_avatarGlowView_niche.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }

        _nameLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_badgeView_niche.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        _bioLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_nameLabel_niche.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(28)
        }

        // 统计栏：在简介下方
        _statsGlassBar_niche.snp.makeConstraints { make in
            make.top.equalTo(_bioLabel_niche.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }

        // Edit 按钮：在统计栏下方，其 bottom 关闭封面高度
        _editBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(_statsGlassBar_niche.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(160)
            make.bottom.equalToSuperview().offset(-18)
        }
        _editBtn_niche.addTarget(self, action: #selector(handleEditProfile_Niche), for: .touchUpInside)

        // 填充统计栏内容
        buildStatsGlassBar_Niche()
    }

    /// 构建玻璃拟态统计栏（三列等分，容器已由 buildCover 添加并设好约束）
    private func buildStatsGlassBar_Niche() {

        let items_niche: [(String, String)] = [
            ("0", "Posts"),
            ("0", "Following"),
            ("0", "Liked")
        ]

        _statCountLabels_niche.removeAll()
        var prevDivider_niche: UIView? = nil
        var prevItem_niche: UIView? = nil

        for (i_niche, item_niche) in items_niche.enumerated() {
            let itemView_niche = buildGlassStatItem_Niche(count: item_niche.0, label: item_niche.1)
            _statsGlassBar_niche.addSubview(itemView_niche)

            itemView_niche.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                if let prev_niche = prevDivider_niche {
                    make.leading.equalTo(prev_niche.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
                if i_niche == items_niche.count - 1 {
                    make.trailing.equalToSuperview()
                }
            }

            // 竖向分割线（非最后一项）
            if i_niche < items_niche.count - 1 {
                let div_niche = UIView()
                div_niche.backgroundColor = UIColor.white.withValues(alpha: 0.30)
                _statsGlassBar_niche.addSubview(div_niche)
                div_niche.snp.makeConstraints { make in
                    make.leading.equalTo(itemView_niche.snp.trailing)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(0.7)
                    make.height.equalTo(28)
                }
                prevDivider_niche = div_niche
            }

            // 等宽约束
            if let prev_niche = prevItem_niche {
                itemView_niche.snp.makeConstraints { make in
                    make.width.equalTo(prev_niche)
                }
            }
            prevItem_niche = itemView_niche
        }
    }

    private func buildGlassStatItem_Niche(count: String, label: String) -> UIView {
        let v_niche = UIView()

        let countLbl_niche = UILabel()
        countLbl_niche.text = count
        countLbl_niche.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        countLbl_niche.textColor = .white
        countLbl_niche.textAlignment = .center

        let labelLbl_niche = UILabel()
        labelLbl_niche.text = label
        labelLbl_niche.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        labelLbl_niche.textColor = UIColor.white.withValues(alpha: 0.72)
        labelLbl_niche.textAlignment = .center

        v_niche.addSubview(countLbl_niche)
        v_niche.addSubview(labelLbl_niche)

        countLbl_niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        labelLbl_niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(countLbl_niche.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-10)
        }

        _statCountLabels_niche.append(countLbl_niche)
        return v_niche
    }

    // MARK: - 胶囊 Tab 构建

    private func buildTabToggle_Niche() {
        _contentView_niche.addSubview(_tabContainer_niche)
        _tabContainer_niche.snp.makeConstraints { make in
            make.top.equalTo(_coverView_niche.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(50)
        }

        // 胶囊滑块（先添加，在按钮下方）
        _tabContainer_niche.addSubview(_tabSlider_niche)
        _tabSlider_niche.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.leading.equalToSuperview().inset(5)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-5)
        }

        _tabContainer_niche.addSubview(_postsTabBtn_niche)
        _tabContainer_niche.addSubview(_likedTabBtn_niche)

        _postsTabBtn_niche.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        _likedTabBtn_niche.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
        }

        _postsTabBtn_niche.addTarget(self, action: #selector(handleTabPosts_Niche), for: .touchUpInside)
        _likedTabBtn_niche.addTarget(self, action: #selector(handleTabLiked_Niche), for: .touchUpInside)

        updateTabStyle_Niche()
    }

    // MARK: - 帖子区域

    private func buildPostsArea_Niche() {
        _postsContainer_niche.axis = .vertical
        _postsContainer_niche.spacing = 16
        _contentView_niche.addSubview(_postsContainer_niche)
        _postsContainer_niche.snp.makeConstraints { make in
            make.top.equalTo(_tabContainer_niche.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().offset(-100)
        }
    }

    // MARK: - 渐变刷新

    private func refreshCoverGradient_Niche() {
        _coverView_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        guard !_coverView_niche.bounds.isEmpty else { return }
        let grad_niche = CAGradientLayer()
        grad_niche.frame = _coverView_niche.bounds
        // 4 色斜向渐变，营造深度感
        grad_niche.colors = [
            UIColor(hexstring_Niche: "#6B21A8").cgColor,
            UIColor(hexstring_Niche: "#9333EA").cgColor,
            UIColor(hexstring_Niche: "#B794F6").cgColor,
            UIColor(hexstring_Niche: "#93C5FD").cgColor
        ]
        grad_niche.locations = [0, 0.35, 0.7, 1.0]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint = CGPoint(x: 1, y: 1)
        // 封面底部圆角
        grad_niche.cornerRadius = 36
        grad_niche.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        _coverView_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    private func refreshAvatarRingGrad_Niche() {
        guard !_avatarRing_niche.bounds.isEmpty else { return }
        if _avatarRingGrad_niche == nil {
            let grad_niche = CAGradientLayer()
            grad_niche.cornerRadius = 50
            grad_niche.colors = [
                UIColor.white.cgColor,
                UIColor(hexstring_Niche: "#D8B4FE").cgColor
            ]
            grad_niche.startPoint = CGPoint(x: 0, y: 0)
            grad_niche.endPoint = CGPoint(x: 1, y: 1)
            _avatarRing_niche.layer.insertSublayer(grad_niche, at: 0)
            _avatarRingGrad_niche = grad_niche
        }
        _avatarRingGrad_niche?.frame = _avatarRing_niche.bounds
    }

    private func refreshTabSliderGrad_Niche() {
        guard !_tabSlider_niche.bounds.isEmpty else { return }
        if _tabSliderGrad_niche == nil {
            let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: _tabSlider_niche.bounds)
            grad_niche.cornerRadius = 14
            _tabSlider_niche.layer.insertSublayer(grad_niche, at: 0)
            _tabSliderGrad_niche = grad_niche
        }
        _tabSliderGrad_niche?.frame = _tabSlider_niche.bounds
    }

    // MARK: - Tab 胶囊滑块动画

    private func updateTabStyle_Niche() {
        let isPosts_niche = _selectedTab_niche == 0

        _postsTabBtn_niche.setTitleColor(
            isPosts_niche ? .white : ColorConfig_Niche.textSecondary_Niche,
            for: .normal
        )
        _postsTabBtn_niche.titleLabel?.font = UIFont.systemFont(
            ofSize: 13, weight: isPosts_niche ? .bold : .semibold
        )
        _likedTabBtn_niche.setTitleColor(
            !isPosts_niche ? .white : ColorConfig_Niche.textSecondary_Niche,
            for: .normal
        )
        _likedTabBtn_niche.titleLabel?.font = UIFont.systemFont(
            ofSize: 13, weight: !isPosts_niche ? .bold : .semibold
        )

        // 胶囊滑块滑动到对应位置
        _tabSlider_niche.snp.remakeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.width.equalToSuperview().multipliedBy(0.5).offset(-5)
            if isPosts_niche {
                make.leading.equalToSuperview().inset(5)
            } else {
                make.trailing.equalToSuperview().inset(5)
            }
        }
        UIView.animate(
            withDuration: AnimationConfig_Niche.durationNormal_Niche,
            delay: 0,
            usingSpringWithDamping: AnimationConfig_Niche.springDampingLight_Niche,
            initialSpringVelocity: AnimationConfig_Niche.springVelocity_Niche,
            options: [.allowUserInteraction]
        ) {
            self._tabContainer_niche.layoutIfNeeded()
        }
    }

    // MARK: - 数据刷新

    private func setupObservers_Niche() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Niche),
            name: UserViewModel_Niche.userStateDidChangeNotification_Niche, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleStateChange_Niche),
            name: TitleViewModel_Niche.titleStateDidChangeNotification_Niche, object: nil
        )
    }

    @objc private func handleStateChange_Niche() { refreshAll_Niche() }

    private func refreshAll_Niche() {
        refreshUserInfo_Niche()
        refreshPosts_Niche()
    }

    private func refreshUserInfo_Niche() {
        let user_niche = _displayUser_niche
        _avatarView_niche.loadCurrentUserAvatar_Niche()
        _nameLabel_niche.text = user_niche.userName_Niche ?? "Explorer"

        if let uid_niche = user_niche.userId_Niche {
            let bio_niche = user_niche.userIntroduce_Niche
                ?? UserViewModel_Niche.shared_Niche.getUserById_Niche(userId_niche: uid_niche).userIntroduce_Niche
                ?? "Exploring the niche ✦"
            _bioLabel_niche.text = bio_niche
        } else {
            _bioLabel_niche.text = "Exploring the niche ✦"
        }

        let isCurrentUser_niche = (meModel_Niche == nil)
        _editBtn_niche.isHidden = !isCurrentUser_niche

        // 更新统计数字（直接更新缓存的 count label）
        let counts_niche = [
            user_niche.userPosts_Niche.count,
            user_niche.userFollow_Niche.count,
            user_niche.userLike_Niche.count
        ]
        for (i_niche, lbl_niche) in _statCountLabels_niche.enumerated() {
            if i_niche < counts_niche.count {
                lbl_niche.text = "\(counts_niche[i_niche])"
            }
        }
    }

    private func refreshPosts_Niche() {
        _postsContainer_niche.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let user_niche = _displayUser_niche
        let posts_niche = _selectedTab_niche == 0 ? user_niche.userPosts_Niche : user_niche.userLike_Niche

        if posts_niche.isEmpty {
            let emptyView_niche = buildEmptyPostsView_Niche()
            _postsContainer_niche.addArrangedSubview(emptyView_niche)
            return
        }

        for (idx_niche, post_niche) in posts_niche.enumerated() {
            let card_niche = buildPostCard_Niche(post: post_niche, index: idx_niche)
            _postsContainer_niche.addArrangedSubview(card_niche)
        }
    }

    private func buildEmptyPostsView_Niche() -> UIView {
        let container_niche = UIView()

        let iconBg_niche = UIView()
        iconBg_niche.backgroundColor = ColorConfig_Niche.primaryGradientStart_Niche.withValues(alpha: 0.10)
        iconBg_niche.layer.cornerRadius = 30
        container_niche.addSubview(iconBg_niche)
        iconBg_niche.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }

        let iconIV_niche = UIImageView()
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        iconIV_niche.image = UIImage(
            systemName: _selectedTab_niche == 0 ? "square.and.pencil" : "heart.slash",
            withConfiguration: cfg_niche
        )
        iconIV_niche.tintColor = ColorConfig_Niche.primaryGradientStart_Niche
        iconIV_niche.contentMode = .scaleAspectFit
        iconBg_niche.addSubview(iconIV_niche)
        iconIV_niche.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }

        let emptyLbl_niche = UILabel()
        emptyLbl_niche.text = _selectedTab_niche == 0
            ? "No posts yet\nShare your story with the tribe!"
            : "No liked posts yet\nExplore and heart some stories!"
        emptyLbl_niche.font = UIFont.systemFont(ofSize: 14)
        emptyLbl_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        emptyLbl_niche.textAlignment = .center
        emptyLbl_niche.numberOfLines = 2
        container_niche.addSubview(emptyLbl_niche)
        emptyLbl_niche.snp.makeConstraints { make in
            make.top.equalTo(iconBg_niche.snp.bottom).offset(12)
            make.leading.trailing.bottom.equalToSuperview()
        }

        container_niche.snp.makeConstraints { make in
            make.height.equalTo(130)
        }
        return container_niche
    }

    /// 杂志风帖子卡片：全宽封面图 + 底部文字区域
    private func buildPostCard_Niche(post: TitleModel_Niche, index: Int) -> UIView {
        let card_niche = UIView()
        card_niche.backgroundColor = .white
        card_niche.layer.cornerRadius = 20
        card_niche.layer.shadowColor = UIColor(hexstring_Niche: "#B794F6").withValues(alpha: 0.12).cgColor
        card_niche.layer.shadowOffset = CGSize(width: 0, height: 5)
        card_niche.layer.shadowRadius = 14
        card_niche.layer.shadowOpacity = 1
        card_niche.isUserInteractionEnabled = true

        // 全宽封面图（顶部，圆角仅上部）
        let mediaContainer_niche = UIView()
        mediaContainer_niche.layer.cornerRadius = 20
        mediaContainer_niche.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mediaContainer_niche.clipsToBounds = true
        card_niche.addSubview(mediaContainer_niche)
        mediaContainer_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(160)
        }

        let mediaView_niche = MediaDisplayView_Niche()
        mediaView_niche.configure_Niche(mediaPath_Niche: post.titleMeidas_Niche.first)
        mediaView_niche.layer.cornerRadius = 0
        mediaContainer_niche.addSubview(mediaView_niche)
        mediaView_niche.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 举报/删除按钮（媒体右上角，玻璃风格）
        let reportBtn_niche = ReportDeleteHelper_Niche.createPostReportButton_Niche(
            post_Niche: post, size_Niche: 13,
            color_Niche: .white, from: self
        ) { [weak self] in self?.refreshPosts_Niche() }
        reportBtn_niche.backgroundColor = UIColor.black.withValues(alpha: 0.30)
        reportBtn_niche.layer.cornerRadius = 14
        card_niche.addSubview(reportBtn_niche)
        reportBtn_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(28)
        }

        // 底部文字区域
        let titleLbl_niche = UILabel()
        titleLbl_niche.text = post.title_Niche
        titleLbl_niche.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        titleLbl_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        titleLbl_niche.numberOfLines = 2
        card_niche.addSubview(titleLbl_niche)
        titleLbl_niche.snp.makeConstraints { make in
            make.top.equalTo(mediaContainer_niche.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(14)
        }

        // 底部 meta 行（点赞数 + 评论数）
        let metaRow_niche = buildMetaRow_Niche(post: post)
        card_niche.addSubview(metaRow_niche)
        metaRow_niche.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_niche.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(22)
        }

        let tap_niche = MePostTapGesture_Niche(post: post)
        tap_niche.addTarget(self, action: #selector(handlePostTap_Niche(_:)))
        card_niche.addGestureRecognizer(tap_niche)
        return card_niche
    }

    private func buildMetaRow_Niche(post: TitleModel_Niche) -> UIView {
        let row_niche = UIView()

        // 点赞数
        let heartIV_niche = UIImageView()
        let hCfg_niche = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        heartIV_niche.image = UIImage(systemName: "heart.fill", withConfiguration: hCfg_niche)
        heartIV_niche.tintColor = UIColor(hexstring_Niche: "#FF6B9D")
        heartIV_niche.contentMode = .scaleAspectFit
        row_niche.addSubview(heartIV_niche)
        heartIV_niche.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        let likeLbl_niche = UILabel()
        likeLbl_niche.text = "\(post.likes_Niche)"
        likeLbl_niche.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        likeLbl_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        row_niche.addSubview(likeLbl_niche)
        likeLbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(heartIV_niche.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }

        // 评论数
        let commentIV_niche = UIImageView()
        let cCfg_niche = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        commentIV_niche.image = UIImage(systemName: "bubble.right.fill", withConfiguration: cCfg_niche)
        commentIV_niche.tintColor = ColorConfig_Niche.primaryGradientEnd_Niche
        commentIV_niche.contentMode = .scaleAspectFit
        row_niche.addSubview(commentIV_niche)
        commentIV_niche.snp.makeConstraints { make in
            make.leading.equalTo(likeLbl_niche.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        let commentLbl_niche = UILabel()
        commentLbl_niche.text = "\(post.reviews_Niche.count)"
        commentLbl_niche.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        commentLbl_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        row_niche.addSubview(commentLbl_niche)
        commentLbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(commentIV_niche.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }

        return row_niche
    }

    // MARK: - 事件

    @objc private func handleSetting_Niche() { Navigation_Niche.toSetting_Niche() }
    @objc private func handleEditProfile_Niche() { Navigation_Niche.toEditInfo_Niche() }

    @objc private func handleTabPosts_Niche() {
        guard _selectedTab_niche != 0 else { return }
        _selectedTab_niche = 0
        updateTabStyle_Niche()
        refreshPosts_Niche()
    }

    @objc private func handleTabLiked_Niche() {
        guard _selectedTab_niche != 1 else { return }
        _selectedTab_niche = 1
        updateTabStyle_Niche()
        refreshPosts_Niche()
    }

    @objc private func handlePostTap_Niche(_ gesture: MePostTapGesture_Niche) {
        Navigation_Niche.toTitleDetail_Niche(titleModel_niche: gesture.post_niche)
    }
}

private class MePostTapGesture_Niche: UITapGestureRecognizer {
    let post_niche: TitleModel_Niche
    init(post: TitleModel_Niche) {
        self.post_niche = post
        super.init(target: nil, action: nil)
    }
}
