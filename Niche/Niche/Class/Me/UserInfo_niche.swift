import Foundation
import UIKit
import SnapKit

// MARK: 用户中心页面

/// 用户中心视图控制器
/// 功能：展示他人用户信息、关注/进入聊天操作、帖子列表
/// 设计：沉浸式多色封面 + 头像光环 + 玻璃统计栏 + 渐变操作按钮 + 杂志风帖子卡片
/// 特殊：从聊天页进入时隐藏消息按钮，关注按钮居中显示
class UserInfo_Niche: UIViewController {

    // MARK: - 传入数据

    var userModel_Niche: PrewUserModel_Niche?
    var isFromMessageUser_Niche: Bool = false

    // MARK: - 私有属性

    private var _isFollowing_niche: Bool {
        guard let user_niche = userModel_Niche else { return false }
        return UserViewModel_Niche.shared_Niche.isFollowing_Niche(user_niche: user_niche)
    }

    // MARK: - UI 组件 / 导航

    private let _backBtn_niche = BackButton_Niche()

    private let _reportButton_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        let cfg_niche = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        btn_niche.setImage(UIImage(systemName: "ellipsis", withConfiguration: cfg_niche), for: .normal)
        btn_niche.tintColor = .white
        btn_niche.backgroundColor = UIColor.white.withValues(alpha: 0.20)
        btn_niche.layer.cornerRadius = 17
        btn_niche.layer.borderWidth = 1
        btn_niche.layer.borderColor = UIColor.white.withValues(alpha: 0.3).cgColor
        return btn_niche
    }()

    // MARK: - UI 组件 / 封面

    private let _scrollView_niche: UIScrollView = {
        let sv_niche = UIScrollView()
        sv_niche.showsVerticalScrollIndicator = false
        sv_niche.contentInsetAdjustmentBehavior = .never
        return sv_niche
    }()
    private let _contentView_niche = UIView()

    private let _coverView_niche = UIView()

    private let _coverOrb1_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.10)
        v_niche.layer.cornerRadius = 56
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()
    private let _coverOrb2_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.07)
        v_niche.layer.cornerRadius = 36
        v_niche.isUserInteractionEnabled = false
        return v_niche
    }()

    /// 头像外发光层
    private let _avatarGlow_niche: UIView = {
        let v_niche = UIView()
        v_niche.layer.cornerRadius = 46
        v_niche.layer.shadowColor = UIColor(hexstring_Niche: "#FD79A8").cgColor
        v_niche.layer.shadowOffset = .zero
        v_niche.layer.shadowRadius = 16
        v_niche.layer.shadowOpacity = 0.55
        return v_niche
    }()

    /// 头像外圈（渐变）
    private let _avatarRing_niche: UIView = {
        let v_niche = UIView()
        v_niche.layer.cornerRadius = 44
        return v_niche
    }()
    private var _avatarRingGrad_niche: CAGradientLayer?

    private let _avatarView_niche = UserAvatarView_Niche()

    /// 用户名
    private let _nameLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        l_niche.textColor = .white
        l_niche.textAlignment = .center
        return l_niche
    }()

    /// 简介
    private let _bioLabel_niche: UILabel = {
        let l_niche = UILabel()
        l_niche.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        l_niche.textColor = UIColor.white.withValues(alpha: 0.78)
        l_niche.textAlignment = .center
        l_niche.numberOfLines = 2
        return l_niche
    }()

    /// 玻璃统计栏
    private let _statsGlass_niche: UIView = {
        let v_niche = UIView()
        v_niche.backgroundColor = UIColor.white.withValues(alpha: 0.16)
        v_niche.layer.cornerRadius = 16
        v_niche.layer.borderWidth = 1
        v_niche.layer.borderColor = UIColor.white.withValues(alpha: 0.25).cgColor
        return v_niche
    }()
    private var _statLabels_niche: [UILabel] = []

    /// 操作按钮区域
    private let _actionsRow_niche = UIView()

    private let _followButton_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_niche.layer.cornerRadius = 20
        btn_niche.clipsToBounds = true
        return btn_niche
    }()
    private var _followBtnGrad_niche: CAGradientLayer?

    private let _messageButton_niche: UIButton = {
        let btn_niche = UIButton(type: .custom)
        btn_niche.setTitle("💬  Message", for: .normal)
        btn_niche.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        btn_niche.setTitleColor(.white, for: .normal)
        btn_niche.backgroundColor = UIColor.white.withValues(alpha: 0.22)
        btn_niche.layer.cornerRadius = 20
        btn_niche.layer.borderWidth = 1
        btn_niche.layer.borderColor = UIColor.white.withValues(alpha: 0.35).cgColor
        return btn_niche
    }()

    // MARK: - UI 组件 / 帖子区域

    private let _postsContainer_niche = UIStackView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
        setupObservers_Niche()
        refreshAll_Niche()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshFollowButton_Niche()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshCoverGradient_Niche()
        refreshAvatarRingGrad_Niche()
        refreshFollowBtnGrad_Niche()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 构建

    private func setupUI_Niche() {
        view.backgroundColor = UIColor(hexstring_Niche: "#F4F0FF")

        view.addSubview(_scrollView_niche)
        _scrollView_niche.snp.makeConstraints { make in make.edges.equalToSuperview() }

        _scrollView_niche.addSubview(_contentView_niche)
        _contentView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        buildCover_Niche()
        buildPostsArea_Niche()

        // 导航按钮浮层
        view.addSubview(_backBtn_niche)
        _backBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        _backBtn_niche.onTapped_Niche = { Navigation_Niche.pop_Niche() }

        view.addSubview(_reportButton_niche)
        _reportButton_niche.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(34)
        }
        _reportButton_niche.addTarget(self, action: #selector(handleReport_Niche), for: .touchUpInside)
    }

    private func buildCover_Niche() {
        _contentView_niche.addSubview(_coverView_niche)
        _coverView_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        // 装饰气泡
        _coverView_niche.addSubview(_coverOrb1_niche)
        _coverOrb1_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-30)
            make.trailing.equalToSuperview().offset(20)
            make.width.height.equalTo(112)
        }
        _coverView_niche.addSubview(_coverOrb2_niche)
        _coverOrb2_niche.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(-16)
            make.width.height.equalTo(72)
        }

        // 先全部 addSubview
        _coverView_niche.addSubview(_avatarGlow_niche)
        _avatarGlow_niche.addSubview(_avatarRing_niche)
        _avatarRing_niche.addSubview(_avatarView_niche)
        _coverView_niche.addSubview(_nameLabel_niche)
        _coverView_niche.addSubview(_bioLabel_niche)
        _coverView_niche.addSubview(_statsGlass_niche)
        _coverView_niche.addSubview(_actionsRow_niche)
        _actionsRow_niche.addSubview(_followButton_niche)
        _actionsRow_niche.addSubview(_messageButton_niche)

        // 约束：从上到下
        _avatarGlow_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(60)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(92)
        }
        _avatarRing_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
        _avatarView_niche.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }

        _nameLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_avatarGlow_niche.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        _bioLabel_niche.snp.makeConstraints { make in
            make.top.equalTo(_nameLabel_niche.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(28)
        }

        // 玻璃统计栏
        _statsGlass_niche.snp.makeConstraints { make in
            make.top.equalTo(_bioLabel_niche.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(58)
        }
        buildStatsGlassContent_Niche()

        // 操作按钮行（统计栏下，bottom 关闭 cover，leading/trailing 给定宽度）
        _actionsRow_niche.snp.makeConstraints { make in
            make.top.equalTo(_statsGlass_niche.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(22)
            make.height.equalTo(42)
            make.bottom.equalToSuperview().offset(-18)
        }

        // 绑定按钮事件
        _followButton_niche.addTarget(self, action: #selector(handleFollow_Niche), for: .touchUpInside)
        _messageButton_niche.addTarget(self, action: #selector(handleMessage_Niche), for: .touchUpInside)
    }

    private func buildStatsGlassContent_Niche() {
        let items_niche: [(String, String)] = [("0", "Posts"), ("0", "Following"), ("0", "Fans")]
        _statLabels_niche.removeAll()

        var prevDiv_niche: UIView? = nil
        var prevItem_niche: UIView? = nil

        for (i_niche, item_niche) in items_niche.enumerated() {
            let itemV_niche = buildGlassStatItem_Niche(count: item_niche.0, label: item_niche.1)
            _statsGlass_niche.addSubview(itemV_niche)
            itemV_niche.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                if let prev_niche = prevDiv_niche {
                    make.leading.equalTo(prev_niche.snp.trailing)
                } else {
                    make.leading.equalToSuperview()
                }
                if i_niche == items_niche.count - 1 {
                    make.trailing.equalToSuperview()
                }
            }
            if let prev_niche = prevItem_niche {
                itemV_niche.snp.makeConstraints { make in
                    make.width.equalTo(prev_niche)
                }
            }
            if i_niche < items_niche.count - 1 {
                let div_niche = UIView()
                div_niche.backgroundColor = UIColor.white.withValues(alpha: 0.28)
                _statsGlass_niche.addSubview(div_niche)
                div_niche.snp.makeConstraints { make in
                    make.leading.equalTo(itemV_niche.snp.trailing)
                    make.centerY.equalToSuperview()
                    make.width.equalTo(0.7)
                    make.height.equalTo(24)
                }
                prevDiv_niche = div_niche
            }
            prevItem_niche = itemV_niche
        }
    }

    private func buildGlassStatItem_Niche(count: String, label: String) -> UIView {
        let v_niche = UIView()
        let cntLbl_niche = UILabel()
        cntLbl_niche.text = count
        cntLbl_niche.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        cntLbl_niche.textColor = .white
        cntLbl_niche.textAlignment = .center
        let lLbl_niche = UILabel()
        lLbl_niche.text = label
        lLbl_niche.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        lLbl_niche.textColor = UIColor.white.withValues(alpha: 0.72)
        lLbl_niche.textAlignment = .center
        v_niche.addSubview(cntLbl_niche)
        v_niche.addSubview(lLbl_niche)
        cntLbl_niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8)
        }
        lLbl_niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cntLbl_niche.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-8)
        }
        _statLabels_niche.append(cntLbl_niche)
        return v_niche
    }

    private func buildPostsArea_Niche() {
        // 帖子区标题
        let sectionHeader_niche = UIView()
        _contentView_niche.addSubview(sectionHeader_niche)
        sectionHeader_niche.snp.makeConstraints { make in
            make.top.equalTo(_coverView_niche.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(18)
            make.height.equalTo(24)
        }

        let dot_niche = UIView()
        dot_niche.backgroundColor = ColorConfig_Niche.secondaryGradientStart_Niche
        dot_niche.layer.cornerRadius = 4
        sectionHeader_niche.addSubview(dot_niche)
        dot_niche.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }
        let titleLbl_niche = UILabel()
        titleLbl_niche.text = "POSTS"
        titleLbl_niche.font = UIFont.systemFont(ofSize: 11, weight: .heavy)
        titleLbl_niche.textColor = ColorConfig_Niche.secondaryGradientStart_Niche
        sectionHeader_niche.addSubview(titleLbl_niche)
        titleLbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(dot_niche.snp.trailing).offset(6)
            make.centerY.equalToSuperview()
        }

        _postsContainer_niche.axis = .vertical
        _postsContainer_niche.spacing = 16
        _contentView_niche.addSubview(_postsContainer_niche)
        _postsContainer_niche.snp.makeConstraints { make in
            make.top.equalTo(sectionHeader_niche.snp.bottom).offset(12)
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
        grad_niche.colors = [
            UIColor(hexstring_Niche: "#E91E8C").cgColor,
            UIColor(hexstring_Niche: "#FD79A8").cgColor,
            UIColor(hexstring_Niche: "#FBB6CE").cgColor,
            UIColor(hexstring_Niche: "#FED7AA").cgColor
        ]
        grad_niche.locations = [0, 0.35, 0.7, 1.0]
        grad_niche.startPoint = CGPoint(x: 0, y: 0)
        grad_niche.endPoint = CGPoint(x: 1, y: 1)
        grad_niche.cornerRadius = 32
        grad_niche.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        _coverView_niche.layer.insertSublayer(grad_niche, at: 0)
    }

    private func refreshAvatarRingGrad_Niche() {
        guard !_avatarRing_niche.bounds.isEmpty else { return }
        if _avatarRingGrad_niche == nil {
            let grad_niche = CAGradientLayer()
            grad_niche.cornerRadius = 44
            grad_niche.colors = [UIColor.white.cgColor, UIColor(hexstring_Niche: "#FBB6CE").cgColor]
            grad_niche.startPoint = CGPoint(x: 0, y: 0)
            grad_niche.endPoint = CGPoint(x: 1, y: 1)
            _avatarRing_niche.layer.insertSublayer(grad_niche, at: 0)
            _avatarRingGrad_niche = grad_niche
        }
        _avatarRingGrad_niche?.frame = _avatarRing_niche.bounds
    }

    private func refreshFollowBtnGrad_Niche() {
        guard !_followButton_niche.bounds.isEmpty else { return }
        if _isFollowing_niche {
            _followButton_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
            _followBtnGrad_niche = nil
            _followButton_niche.backgroundColor = UIColor.white.withValues(alpha: 0.28)
        } else {
            if _followBtnGrad_niche == nil {
                let grad_niche = UIColor.createSecondaryGradientLayer_Niche(frame_Niche: _followButton_niche.bounds)
                grad_niche.cornerRadius = 20
                _followButton_niche.layer.insertSublayer(grad_niche, at: 0)
                _followBtnGrad_niche = grad_niche
            }
            _followBtnGrad_niche?.frame = _followButton_niche.bounds
            _followButton_niche.backgroundColor = .clear
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

    @objc private func handleStateChange_Niche() {
        refreshAll_Niche()
        if isFromMessageUser_Niche && !_isFollowing_niche {
            handleUnfollowFromChat_Niche()
        }
    }

    private func refreshAll_Niche() {
        refreshUserInfo_Niche()
        refreshFollowButton_Niche()
        refreshPosts_Niche()
    }

    private func refreshUserInfo_Niche() {
        guard let user_niche = userModel_Niche else { return }
        _avatarView_niche.configure_Niche(userId_Niche: user_niche.userId_Niche ?? 0)
        _nameLabel_niche.text = user_niche.userName_Niche ?? "User"
        _bioLabel_niche.text = user_niche.userIntroduce_Niche ?? "Member of the tribe"

        // 更新统计数字
        // 更新统计数字：帖子数 / 关注数 / 粉丝数
        let postsCount_niche = TitleViewModel_Niche.shared_Niche.getUserPosts_Niche(user_niche: user_niche).count
        let counts_niche = [postsCount_niche, user_niche.userFollow_Niche ?? 0, user_niche.userFans_Niche ?? 0]
        for (i_niche, lbl_niche) in _statLabels_niche.enumerated() {
            if i_niche < counts_niche.count {
                lbl_niche.text = "\(counts_niche[i_niche])"
            }
        }
    }

    private func refreshFollowButton_Niche() {
        let isFollowing_niche = _isFollowing_niche

        // 更新按钮标题
        _followButton_niche.setTitle(
            isFollowing_niche ? "  Followed ✓  " : "  + Follow  ",
            for: .normal
        )
        _followButton_niche.setTitleColor(.white, for: .normal)

        // 立即移除旧渐变图层并同步重建（不等 viewDidLayoutSubviews）
        _followButton_niche.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        _followBtnGrad_niche = nil

        if isFollowing_niche {
            // 已关注：半透明白色背景
            _followButton_niche.backgroundColor = UIColor.white.withValues(alpha: 0.28)
        } else {
            // 未关注：辅助渐变背景
            _followButton_niche.backgroundColor = .clear
            if !_followButton_niche.bounds.isEmpty {
                let grad_niche = UIColor.createSecondaryGradientLayer_Niche(
                    frame_Niche: _followButton_niche.bounds
                )
                grad_niche.cornerRadius = 20
                _followButton_niche.layer.insertSublayer(grad_niche, at: 0)
                _followBtnGrad_niche = grad_niche
            } else {
                // bounds 尚未确定时退后到下一 RunLoop 再设置渐变
                DispatchQueue.main.async { [weak self] in
                    guard let self = self,
                          !self._isFollowing_niche,
                          !self._followButton_niche.bounds.isEmpty else { return }
                    let grad_niche = UIColor.createSecondaryGradientLayer_Niche(
                        frame_Niche: self._followButton_niche.bounds
                    )
                    grad_niche.cornerRadius = 20
                    self._followButton_niche.layer.insertSublayer(grad_niche, at: 0)
                    self._followBtnGrad_niche = grad_niche
                }
            }
        }

        if isFromMessageUser_Niche {
            _messageButton_niche.isHidden = true
            _followButton_niche.snp.remakeConstraints { make in
                make.centerX.centerY.equalToSuperview()
                make.width.equalTo(160)
                make.height.equalTo(42)
            }
        } else {
            _messageButton_niche.isHidden = false
            _followButton_niche.snp.remakeConstraints { make in
                make.leading.centerY.equalToSuperview()
                make.width.equalTo(130)
                make.height.equalTo(42)
            }
            _messageButton_niche.snp.remakeConstraints { make in
                make.leading.equalTo(_followButton_niche.snp.trailing).offset(10)
                make.trailing.centerY.equalToSuperview()
                make.width.equalTo(130)
                make.height.equalTo(42)
            }
        }
    }

    private func refreshPosts_Niche() {
        _postsContainer_niche.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let user_niche = userModel_Niche else { return }

        let posts_niche = TitleViewModel_Niche.shared_Niche.getUserPosts_Niche(user_niche: user_niche)

        if posts_niche.isEmpty {
            let emptyLbl_niche = UILabel()
            emptyLbl_niche.text = "No posts yet"
            emptyLbl_niche.font = UIFont.systemFont(ofSize: 14)
            emptyLbl_niche.textColor = ColorConfig_Niche.textPlaceholder_Niche
            emptyLbl_niche.textAlignment = .center
            _postsContainer_niche.addArrangedSubview(emptyLbl_niche)
            emptyLbl_niche.snp.makeConstraints { make in make.height.equalTo(60) }
            return
        }

        for post_niche in posts_niche {
            let card_niche = buildPostCard_Niche(post: post_niche)
            _postsContainer_niche.addArrangedSubview(card_niche)
        }
    }

    /// 杂志风帖子卡片（全宽封面图 + 文字区）
    private func buildPostCard_Niche(post: TitleModel_Niche) -> UIView {
        let card_niche = UIView()
        card_niche.backgroundColor = .white
        card_niche.layer.cornerRadius = 18
        card_niche.layer.shadowColor = UIColor(hexstring_Niche: "#FD79A8").withValues(alpha: 0.12).cgColor
        card_niche.layer.shadowOffset = CGSize(width: 0, height: 5)
        card_niche.layer.shadowRadius = 12
        card_niche.layer.shadowOpacity = 1
        card_niche.isUserInteractionEnabled = true

        // 全宽封面图
        let mediaContainer_niche = UIView()
        mediaContainer_niche.layer.cornerRadius = 18
        mediaContainer_niche.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        mediaContainer_niche.clipsToBounds = true
        card_niche.addSubview(mediaContainer_niche)
        mediaContainer_niche.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(150)
        }

        let mediaView_niche = MediaDisplayView_Niche()
        mediaView_niche.configure_Niche(mediaPath_Niche: post.titleMeidas_Niche.first)
        mediaView_niche.layer.cornerRadius = 0
        mediaContainer_niche.addSubview(mediaView_niche)
        mediaView_niche.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 举报按钮
        let reportBtn_niche = ReportDeleteHelper_Niche.createPostReportButton_Niche(
            post_Niche: post, size_Niche: 12, color_Niche: .white, from: self
        ) { [weak self] in self?.refreshPosts_Niche() }
        reportBtn_niche.backgroundColor = UIColor.black.withValues(alpha: 0.30)
        reportBtn_niche.layer.cornerRadius = 13
        card_niche.addSubview(reportBtn_niche)
        reportBtn_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.width.height.equalTo(26)
        }

        // 标题
        let titleLbl_niche = UILabel()
        titleLbl_niche.text = post.title_Niche
        titleLbl_niche.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        titleLbl_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        titleLbl_niche.numberOfLines = 2
        card_niche.addSubview(titleLbl_niche)
        titleLbl_niche.snp.makeConstraints { make in
            make.top.equalTo(mediaContainer_niche.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        // Meta 行
        let heartIV_niche = UIImageView()
        let hCfg_niche = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        heartIV_niche.image = UIImage(systemName: "heart.fill", withConfiguration: hCfg_niche)
        heartIV_niche.tintColor = UIColor(hexstring_Niche: "#FF6B9D")
        heartIV_niche.contentMode = .scaleAspectFit
        let likeLbl_niche = UILabel()
        likeLbl_niche.text = "\(post.likes_Niche)"
        likeLbl_niche.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        likeLbl_niche.textColor = ColorConfig_Niche.textSecondary_Niche

        card_niche.addSubview(heartIV_niche)
        card_niche.addSubview(likeLbl_niche)

        heartIV_niche.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_niche.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(13)
            make.bottom.equalToSuperview().offset(-10)
        }
        likeLbl_niche.snp.makeConstraints { make in
            make.leading.equalTo(heartIV_niche.snp.trailing).offset(3)
            make.centerY.equalTo(heartIV_niche)
        }

        let tap_niche = UserInfoPostTap_Niche(post: post)
        tap_niche.addTarget(self, action: #selector(handlePostTap_Niche(_:)))
        card_niche.addGestureRecognizer(tap_niche)
        return card_niche
    }

    // MARK: - 取消关注处理

    private func handleUnfollowFromChat_Niche() {
        if let userId_niche = userModel_Niche?.userId_Niche {
            Task { @MainActor in
                MessageViewModel_Niche.shared_Niche.deleteUserMessages_Niche(userId_niche: userId_niche)
            }
        }
        Navigation_Niche.popToSafeStateAfterBlock_Niche(from: self)
    }

    // MARK: - 事件处理

    @objc private func handleReport_Niche() {
        guard let user_niche = userModel_Niche else { return }
        ReportDeleteHelper_Niche.block_Niche(user_Niche: user_niche, from: self) { [weak self] in
            Navigation_Niche.popToSafeStateAfterBlock_Niche(from: self ?? UIViewController())
        }
    }

    @objc private func handleFollow_Niche() {
        guard let user_niche = userModel_Niche else { return }
        _followButton_niche.animatePulse_Niche()
        Task { @MainActor in UserViewModel_Niche.shared_Niche.followUser_Niche(user_niche: user_niche) }
    }

    @objc private func handleMessage_Niche() {
        guard let user_niche = userModel_Niche else { return }
        guard _isFollowing_niche else {
            Utils_Niche.showWarning_Niche(message_Niche: "Follow \(user_niche.userName_Niche ?? "this user") first to send a message")
            return
        }
        showMessageConfirmSheet_Niche(user: user_niche)
    }

    private func showMessageConfirmSheet_Niche(user: PrewUserModel_Niche) {
        let sheet_niche = UserMessageConfirmSheet_Niche(user: user)
        sheet_niche.onConfirm_Niche = { [weak self] in
            Navigation_Niche.toMessageUser_Niche(with: user)
            _ = self
        }
        if #available(iOS 15.0, *) {
            sheet_niche.sheetPresentationController?.detents = [.medium()]
        }
        present(sheet_niche, animated: true)
    }

    @objc private func handlePostTap_Niche(_ gesture: UserInfoPostTap_Niche) {
        Navigation_Niche.toTitleDetail_Niche(titleModel_niche: gesture.post_niche)
    }
}

// MARK: - 进入聊天确认底部弹窗

class UserMessageConfirmSheet_Niche: UIViewController {

    private let _user_niche: PrewUserModel_Niche
    var onConfirm_Niche: (() -> Void)?

    init(user: PrewUserModel_Niche) {
        self._user_niche = user
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Niche()
    }

    private func setupUI_Niche() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 28
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        let dragBar_niche = UIView()
        dragBar_niche.backgroundColor = ColorConfig_Niche.border_Niche
        dragBar_niche.layer.cornerRadius = 2.5
        view.addSubview(dragBar_niche)
        dragBar_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.width.equalTo(40)
            make.height.equalTo(5)
        }

        let avatarRing_niche = UIView()
        avatarRing_niche.layer.cornerRadius = 38
        view.addSubview(avatarRing_niche)
        avatarRing_niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(76)
        }
        DispatchQueue.main.async {
            let grad_niche = UIColor.createSecondaryGradientLayer_Niche(frame_Niche: avatarRing_niche.bounds)
            grad_niche.cornerRadius = 38
            avatarRing_niche.layer.insertSublayer(grad_niche, at: 0)
        }

        let avatar_niche = UserAvatarView_Niche()
        avatar_niche.configure_Niche(userId_Niche: _user_niche.userId_Niche ?? 0)
        avatarRing_niche.addSubview(avatar_niche)
        avatar_niche.snp.makeConstraints { make in make.edges.equalToSuperview().inset(3) }

        let nameLbl_niche = UILabel()
        nameLbl_niche.text = _user_niche.userName_Niche ?? "User"
        nameLbl_niche.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLbl_niche.textColor = ColorConfig_Niche.textPrimary_Niche
        nameLbl_niche.textAlignment = .center
        view.addSubview(nameLbl_niche)
        nameLbl_niche.snp.makeConstraints { make in
            make.top.equalTo(avatarRing_niche.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        let bioLbl_niche = UILabel()
        bioLbl_niche.text = _user_niche.userIntroduce_Niche ?? "Member of the tribe"
        bioLbl_niche.font = UIFont.systemFont(ofSize: 13)
        bioLbl_niche.textColor = ColorConfig_Niche.textSecondary_Niche
        bioLbl_niche.textAlignment = .center
        bioLbl_niche.numberOfLines = 2
        view.addSubview(bioLbl_niche)
        bioLbl_niche.snp.makeConstraints { make in
            make.top.equalTo(nameLbl_niche.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        let confirmBtn_niche = UIButton(type: .custom)
        confirmBtn_niche.setTitle("  Enter Chat  ", for: .normal)
        confirmBtn_niche.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        confirmBtn_niche.setTitleColor(.white, for: .normal)
        confirmBtn_niche.layer.cornerRadius = 22
        confirmBtn_niche.clipsToBounds = true
        view.addSubview(confirmBtn_niche)
        confirmBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(bioLbl_niche.snp.bottom).offset(22)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(44)
        }
        DispatchQueue.main.async {
            let grad_niche = UIColor.createPrimaryGradientLayer_Niche(frame_Niche: confirmBtn_niche.bounds)
            grad_niche.cornerRadius = 22
            confirmBtn_niche.layer.insertSublayer(grad_niche, at: 0)
        }
        confirmBtn_niche.addTarget(self, action: #selector(handleConfirm_Niche), for: .touchUpInside)

        let cancelBtn_niche = UIButton(type: .system)
        cancelBtn_niche.setTitle("Cancel", for: .normal)
        cancelBtn_niche.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelBtn_niche.setTitleColor(ColorConfig_Niche.textSecondary_Niche, for: .normal)
        view.addSubview(cancelBtn_niche)
        cancelBtn_niche.snp.makeConstraints { make in
            make.top.equalTo(confirmBtn_niche.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        cancelBtn_niche.addTarget(self, action: #selector(handleCancel_Niche), for: .touchUpInside)
    }

    @objc private func handleConfirm_Niche() {
        dismiss(animated: true) { [weak self] in self?.onConfirm_Niche?() }
    }
    @objc private func handleCancel_Niche() { dismiss(animated: true) }
}

// MARK: - 辅助类

private class UserInfoPostTap_Niche: UITapGestureRecognizer {
    let post_niche: TitleModel_Niche
    init(post: TitleModel_Niche) {
        self.post_niche = post
        super.init(target: nil, action: nil)
    }
}
