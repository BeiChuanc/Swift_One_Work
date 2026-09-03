import Foundation
import UIKit
import SnapKit

// MARK: - 我的页面视图控制器

/// 我的页面视图控制器
/// 功能：展示登录用户头像、昵称、简介、关注/喜欢/帖子统计；Tab 切换发布/喜欢帖子双列网格
/// 设计：全屏渐变头部 + 玻璃态统计栏 + 胶囊 Tab + 精美帖子卡片；进场动画
/// 逻辑：监听用户/帖子通知响应式刷新；meModel_Maki 优先，未设则用当前登录用户
class Me_Maki: UIViewController {

    // MARK: - 对外属性
    var meModel_Maki: LoginUserModel_Maki?

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary  = UIColor(hexstring_Maki: "#FF8C00")
        static let gold     = UIColor(hexstring_Maki: "#FFD700")
        static let bg       = UIColor(hexstring_Maki: "#FFFBF4")
        static let card     = UIColor.white
        static let tp       = UIColor(hexstring_Maki: "#1A0A00")
        static let ts       = UIColor(hexstring_Maki: "#8B7355")
        static let cellId   = "MePostCell_Maki"
        static let tabMy    = 0
        static let tabLike  = 1
    }

    // MARK: - 数据属性

    private var displayUser_Maki: LoginUserModel_Maki {
        meModel_Maki ?? UserViewModel_Maki.shared_Maki.getCurrentUser_Maki()
    }
    /// 当前选中 Tab（0 = 我的帖子，1 = 喜欢帖子）
    private var currentTab_Maki = K_Maki.tabMy
    private var currentPosts_Maki: [TitleModel_Maki] {
        currentTab_Maki == K_Maki.tabMy
            ? displayUser_Maki.userPosts_Maki
            : displayUser_Maki.userLike_Maki
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
    private let headerGradient_Maki = CAGradientLayer()
    private let headerBubble1_Maki = UIView()
    private let headerBubble2_Maki = UIView()

    /// 头像外圈光晕（白色半透明圆环）
    private let avatarRingView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        v_maki.layer.cornerRadius = 56
        return v_maki
    }()
    private let avatarView_Maki = CurrentUserAvatarView_Maki()
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
    /// 统计数据容器行
    private let statsRow_Maki = UIView()

    /// 编辑按钮（左上角）
    private let editBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setImage(UIImage(systemName: "pencil"), for: .normal)
        btn_maki.tintColor = .white
        btn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn_maki.layer.cornerRadius = 18
        btn_maki.layer.borderWidth = 1.5
        btn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        return btn_maki
    }()
    /// 设置按钮（右上角）
    private let settingBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        btn_maki.tintColor = .white
        btn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        btn_maki.layer.cornerRadius = 18
        btn_maki.layer.borderWidth = 1.5
        btn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        return btn_maki
    }()
    /// VIP 按钮：使用资源图片，尺寸与设置按钮一致。
    private let vipBtn_maki: UIButton = {
        let button_maki = UIButton(type: .custom)
        button_maki.setImage(UIImage(named: "vip_btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button_maki.imageView?.contentMode = .scaleAspectFit
        return button_maki
    }()

    // MARK: - UI 属性 / Tab 切换区

    /// Tab 容器（胶囊背景）
    private let tabContainer_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor(hexstring_Maki: "#F0EDE6")
        v_maki.layer.cornerRadius = 14
        return v_maki
    }()
    /// Tab 滑动胶囊指示器
    private let tabIndicator_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor.white
        v_maki.layer.cornerRadius = 11
        v_maki.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 2)
        v_maki.layer.shadowRadius = 4
        v_maki.layer.shadowOpacity = 1
        return v_maki
    }()
    private let myPostsTabBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("My Posts", for: .normal)
        btn_maki.setTitleColor(UIColor(hexstring_Maki: "#FF8C00"), for: .normal)
        btn_maki.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn_maki.tag = 0
        return btn_maki
    }()
    private let likedTabBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setTitle("Liked", for: .normal)
        btn_maki.setTitleColor(UIColor(hexstring_Maki: "#8B7355"), for: .normal)
        btn_maki.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        btn_maki.tag = 1
        return btn_maki
    }()

    // MARK: - UI 属性 / 帖子网格

    private lazy var postsCV_Maki: UICollectionView = {
        let itemW_maki = (APPSCREEN_Maki.WIDTH_Maki - 50) / 2
        let layout_maki = UICollectionViewFlowLayout()
        layout_maki.scrollDirection = .vertical
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
    private var postsCVHeightRef_Maki: Constraint?
    /// 无帖子时的缺省视图
    private let postsEmptyView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.isHidden = true
        return v_maki
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        buildUI_Maki()
        bindNotifications_Maki()
        reloadAll_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadAll_Maki()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntranceAnimation_Maki()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Maki.frame = headerView_Maki.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UI 构建

extension Me_Maki {

    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }
        buildHeader_Maki()
        buildTabArea_Maki()
        buildPostsGrid_Maki()
    }

    /// 构建头部渐变区（渐变背景 + 装饰泡泡 + 按钮 + 头像 + 信息 + 统计栏）
    private func buildHeader_Maki() {
        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44

        // 渐变背景
        headerGradient_Maki.colors = [
            UIColor(hexstring_Maki: "#E8650A").cgColor,
            UIColor(hexstring_Maki: "#FF9F1C").cgColor
        ]
        headerGradient_Maki.startPoint = CGPoint(x: 0, y: 0)
        headerGradient_Maki.endPoint   = CGPoint(x: 1, y: 1)
        headerView_Maki.layer.insertSublayer(headerGradient_Maki, at: 0)
        contentView_Maki.addSubview(headerView_Maki)
        headerView_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            // 不设固定高度，由内容（decoBar 底部）驱动
        }

        // 装饰气泡（右上大泡）
        headerBubble1_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        headerBubble1_Maki.layer.cornerRadius = 70
        headerView_Maki.addSubview(headerBubble1_Maki)
        headerBubble1_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(140)
            make.trailing.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(-30)
        }
        // 装饰气泡（左中小泡）
        headerBubble2_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        headerBubble2_Maki.layer.cornerRadius = 40
        headerView_Maki.addSubview(headerBubble2_Maki)
        headerBubble2_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.leading.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview().offset(-20)
        }

        // 编辑 / VIP / 设置按钮
        editBtn_Maki.addTarget(self, action: #selector(onEditInfo_Maki), for: .touchUpInside)
        vipBtn_maki.addTarget(self, action: #selector(onVip_maki), for: .touchUpInside)
        settingBtn_Maki.addTarget(self, action: #selector(onSettings_Maki), for: .touchUpInside)
        headerView_Maki.addSubview(editBtn_Maki)
        headerView_Maki.addSubview(vipBtn_maki)
        headerView_Maki.addSubview(settingBtn_Maki)
        settingBtn_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-18)
            make.top.equalToSuperview().offset(statusH_maki + 10)
            make.width.height.equalTo(36)
        }
        vipBtn_maki.snp.makeConstraints { make in
            make.trailing.equalTo(settingBtn_Maki.snp.leading).offset(-10)
            make.centerY.equalTo(settingBtn_Maki)
            make.width.height.equalTo(36)
        }
        editBtn_Maki.snp.makeConstraints { make in
            make.trailing.equalTo(vipBtn_maki.snp.leading).offset(-10)
            make.centerY.equalTo(vipBtn_maki)
            make.width.height.equalTo(36)
        }

        // 返回按钮（仅在被 push 进来时显示，TabBar 根页不显示）
        if (navigationController?.viewControllers.count ?? 0) > 1 {
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
                make.centerY.equalTo(settingBtn_Maki)
                make.width.height.equalTo(36)
            }
        }

        // 头像光晕外圈
        headerView_Maki.addSubview(avatarRingView_Maki)
        avatarRingView_Maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(statusH_maki + 56)
            make.width.height.equalTo(112)
        }

        // 头像（白色边框圆形）
        avatarView_Maki.layer.cornerRadius = 44
        avatarView_Maki.clipsToBounds = true
        avatarView_Maki.layer.borderWidth = 3.5
        avatarView_Maki.layer.borderColor = UIColor.white.cgColor
        headerView_Maki.addSubview(avatarView_Maki)
        avatarView_Maki.snp.makeConstraints { make in
            make.center.equalTo(avatarRingView_Maki)
            make.width.height.equalTo(88)
        }

        // 用户名
        headerView_Maki.addSubview(nameLabel_Maki)
        nameLabel_Maki.snp.makeConstraints { make in
            make.top.equalTo(avatarRingView_Maki.snp.bottom).offset(12)
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

        // 统计栏（玻璃态圆角卡片容器，锚定在 bioLabel 下方）
        let glassBg_maki = UIView()
        glassBg_maki.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        glassBg_maki.layer.cornerRadius = 18
        glassBg_maki.layer.borderWidth  = 1
        glassBg_maki.layer.borderColor  = UIColor.white.withAlphaComponent(0.35).cgColor
        headerView_Maki.addSubview(glassBg_maki)
        glassBg_maki.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.top.equalTo(bioLabel_Maki.snp.bottom).offset(16)
            make.height.equalTo(62)
        }
        glassBg_maki.addSubview(statsRow_Maki)
        statsRow_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 底部圆角过渡条（锚定在 glassBg 下方，其 bottom 决定 headerView 高度）
        let decoBar_maki = UIView()
        decoBar_maki.backgroundColor = K_Maki.bg
        decoBar_maki.layer.cornerRadius = 22
        decoBar_maki.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerView_Maki.addSubview(decoBar_maki)
        decoBar_maki.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(glassBg_maki.snp.bottom).offset(10)
            make.height.equalTo(28)
            make.bottom.equalToSuperview()   // 驱动 headerView 的底部
        }
    }

    /// 构建 Tab 切换区（胶囊容器 + 滑动指示器）
    private func buildTabArea_Maki() {
        contentView_Maki.addSubview(tabContainer_Maki)
        tabContainer_Maki.snp.makeConstraints { make in
            make.top.equalTo(headerView_Maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }

        // 滑动指示器胶囊
        tabContainer_Maki.addSubview(tabIndicator_Maki)
        tabIndicator_Maki.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.equalToSuperview().offset(4)
            make.width.equalToSuperview().dividedBy(2).offset(-4)
        }

        // Tab 按钮
        myPostsTabBtn_Maki.addTarget(self, action: #selector(onTabSwitch_Maki(_:)), for: .touchUpInside)
        likedTabBtn_Maki.addTarget(self, action: #selector(onTabSwitch_Maki(_:)), for: .touchUpInside)
        tabContainer_Maki.addSubview(myPostsTabBtn_Maki)
        tabContainer_Maki.addSubview(likedTabBtn_Maki)

        myPostsTabBtn_Maki.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
        likedTabBtn_Maki.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
    }

    /// 构建帖子网格 CollectionView + 缺省视图
    private func buildPostsGrid_Maki() {
        contentView_Maki.addSubview(postsCV_Maki)
        postsCV_Maki.snp.makeConstraints { make in
            make.top.equalTo(tabContainer_Maki.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            postsCVHeightRef_Maki = make.height.equalTo(300).constraint
        }

        // 缺省视图（无帖子时显示，固定高度，不依赖 contentView 底部）
        buildPostsEmptyView_Maki()
        contentView_Maki.addSubview(postsEmptyView_Maki)
        postsEmptyView_Maki.snp.makeConstraints { make in
            make.top.equalTo(tabContainer_Maki.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(220)
        }
    }

    /// 构建无帖子缺省视图（白色圆角卡片 + emoji + 文字）
    private func buildPostsEmptyView_Maki() {
        let card_maki = UIView()
        card_maki.backgroundColor = .white
        card_maki.layer.cornerRadius = 20
        card_maki.layer.shadowColor = UIColor(hexstring_Maki: "#FF8C00").withAlphaComponent(0.1).cgColor
        card_maki.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_maki.layer.shadowRadius = 12
        card_maki.layer.shadowOpacity = 1
        postsEmptyView_Maki.addSubview(card_maki)
        card_maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        let iconLb_maki = UILabel()
        iconLb_maki.text = "🎨"
        iconLb_maki.font = .systemFont(ofSize: 52)
        iconLb_maki.textAlignment = .center

        // 默认文案，避免 layout 时高度为零；updatePostsCVHeight_Maki 会按 Tab 更新
        let titleLb_maki = UILabel()
        titleLb_maki.text = "No posts yet"
        titleLb_maki.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLb_maki.textColor = UIColor(hexstring_Maki: "#1A0A00")
        titleLb_maki.textAlignment = .center

        let subLb_maki = UILabel()
        subLb_maki.text = "Tap the ＋ button to share\nyour first creation!"
        subLb_maki.font = .systemFont(ofSize: 13)
        subLb_maki.textColor = UIColor(hexstring_Maki: "#8B7355")
        subLb_maki.textAlignment = .center
        subLb_maki.numberOfLines = 2

        // tag 用于 Tab 切换时更新文案
        iconLb_maki.tag  = 901
        titleLb_maki.tag = 902
        subLb_maki.tag   = 903

        card_maki.addSubview(iconLb_maki)
        card_maki.addSubview(titleLb_maki)
        card_maki.addSubview(subLb_maki)

        iconLb_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        titleLb_maki.snp.makeConstraints { make in
            make.top.equalTo(iconLb_maki.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        subLb_maki.snp.makeConstraints { make in
            make.top.equalTo(titleLb_maki.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
    }
}

// MARK: - 数据刷新

extension Me_Maki {

    /// 刷新全部 UI 数据（用户信息 + 统计 + 帖子）
    private func reloadAll_Maki() {
        let user_maki = displayUser_Maki
        nameLabel_Maki.text = user_maki.userName_Maki ?? "Maker"
        bioLabel_Maki.text  = user_maki.userIntroduce_Maki?.isEmpty == false
            ? user_maki.userIntroduce_Maki
            : "Craft · Create · Share"

        // 重建统计行
        statsRow_Maki.subviews.forEach { $0.removeFromSuperview() }
        buildStatsRow_Maki(items: [
            (value: "\(user_maki.userFollow_Maki.count)", label: "Following"),
            (value: "\(user_maki.userLike_Maki.count)",   label: "Liked"),
            (value: "\(user_maki.userPosts_Maki.count)",  label: "Posts")
        ])

        postsCV_Maki.reloadData()
        updatePostsCVHeight_Maki()
    }

    /// 重建统计数据行（三列：数值 + 标签）
    /// - Parameter items: (value, label) 元组数组
    private func buildStatsRow_Maki(items: [(value: String, label: String)]) {
        let stack_maki = UIStackView()
        stack_maki.axis = .horizontal
        stack_maki.distribution = .fillEqually
        stack_maki.alignment = .center
        statsRow_Maki.addSubview(stack_maki)
        stack_maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        for (i_maki, item_maki) in items.enumerated() {
            let col_maki = UIView()

            let numLb_maki = UILabel()
            numLb_maki.text = item_maki.value
            numLb_maki.font = .systemFont(ofSize: 20, weight: .bold)
            numLb_maki.textColor = .white
            numLb_maki.textAlignment = .center

            let titleLb_maki = UILabel()
            titleLb_maki.text = item_maki.label
            titleLb_maki.font = .systemFont(ofSize: 11, weight: .medium)
            titleLb_maki.textColor = UIColor.white.withAlphaComponent(0.8)
            titleLb_maki.textAlignment = .center

            col_maki.addSubview(numLb_maki)
            col_maki.addSubview(titleLb_maki)
            numLb_maki.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(10)
                make.centerX.equalToSuperview()
            }
            titleLb_maki.snp.makeConstraints { make in
                make.top.equalTo(numLb_maki.snp.bottom).offset(2)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-10)
            }

            // 列间竖线分隔（非最后一列）
            if i_maki < items.count - 1 {
                let divLine_maki = UIView()
                divLine_maki.backgroundColor = UIColor.white.withAlphaComponent(0.25)
                col_maki.addSubview(divLine_maki)
                divLine_maki.snp.makeConstraints { make in
                    make.trailing.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.width.equalTo(1)
                    make.height.equalTo(24)
                }
            }
            stack_maki.addArrangedSubview(col_maki)
        }
    }

    /// 动态更新帖子网格高度约束，无帖子时显示缺省视图
    private func updatePostsCVHeight_Maki() {
        let isEmpty_maki = currentPosts_Maki.isEmpty
        postsCV_Maki.isHidden       = isEmpty_maki
        postsEmptyView_Maki.isHidden = !isEmpty_maki

        if isEmpty_maki {
            // 更新缺省视图文案（根据当前 Tab）
            let isMy_maki = currentTab_Maki == K_Maki.tabMy
            if let titleLb_maki = postsEmptyView_Maki.viewWithTag(902) as? UILabel {
                titleLb_maki.text = isMy_maki ? "No posts yet" : "No liked posts yet"
            }
            if let subLb_maki = postsEmptyView_Maki.viewWithTag(903) as? UILabel {
                subLb_maki.text = isMy_maki
                    ? "Tap the ＋ button to share\nyour first creation!"
                    : "Explore the Discover page\nand like posts you enjoy!"
            }
            // 高度设为 280 确保 contentView 有足够空间容纳缺省视图
            postsCVHeightRef_Maki?.update(offset: 280)
            return
        }

        let itemW_maki = (APPSCREEN_Maki.WIDTH_Maki - 50) / 2
        let itemH_maki = itemW_maki * 1.3
        let count_maki = CGFloat(currentPosts_Maki.count)
        let rows_maki  = ceil(count_maki / 2)
        let h_maki     = rows_maki * itemH_maki + max(0, rows_maki - 1) * 12 + 20 + 100
        postsCVHeightRef_Maki?.update(offset: max(h_maki, 200))
    }
}

// MARK: - 进场动画

extension Me_Maki {

    /// 页面进场：Tab 区 + 帖子网格从下弹入
    private func playEntranceAnimation_Maki() {
        [tabContainer_Maki, postsCV_Maki].enumerated().forEach { i_maki, v_maki in
            v_maki.alpha = 0
            v_maki.transform = CGAffineTransform(translationX: 0, y: 20)
            UIView.animate(
                withDuration: 0.4,
                delay: Double(i_maki) * 0.08,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.3,
                options: [],
                animations: {
                    v_maki.alpha = 1
                    v_maki.transform = .identity
                }
            )
        }
    }
}

// MARK: - 通知绑定

extension Me_Maki {

    private func bindNotifications_Maki() {
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChange_Maki),
            name: UserViewModel_Maki.userStateDidChangeNotification_Maki, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onStateChange_Maki),
            name: TitleViewModel_Maki.titleStateDidChangeNotification_Maki, object: nil)
    }

    @objc private func onStateChange_Maki() { reloadAll_Maki() }
}

// MARK: - 事件响应

extension Me_Maki {

    @objc private func onBack_Maki() {
        Navigation_Maki.pop_Maki()
    }

    @objc private func onEditInfo_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Maki.toEditInfo_Maki()
    }

    @objc private func onSettings_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Maki.toSetting_Maki()
    }

    /// 打开 VIP 订阅页面。
    /// - 参数：无。
    /// - 返回值：无。
    /// - 异常场景：无。
    @objc private func onVip_maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Maki.toVipSubscription_maki()
    }

    /// Tab 切换：更新颜色 + 滑动指示器胶囊
    @objc private func onTabSwitch_Maki(_ sender: UIButton) {
        guard sender.tag != currentTab_Maki else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        currentTab_Maki = sender.tag
        let isFirst_maki = sender.tag == K_Maki.tabMy

        myPostsTabBtn_Maki.setTitleColor(isFirst_maki ? K_Maki.primary : K_Maki.ts, for: .normal)
        likedTabBtn_Maki.setTitleColor(isFirst_maki ? K_Maki.ts : K_Maki.primary, for: .normal)

        // 滑动胶囊指示器
        let halfW_maki = (APPSCREEN_Maki.WIDTH_Maki - 40 - 8) / 2
        UIView.animate(
            withDuration: 0.28,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [],
            animations: {
                self.tabIndicator_Maki.snp.updateConstraints { make in
                    make.leading.equalToSuperview().offset(isFirst_maki ? 4 : halfW_maki + 4)
                }
                self.tabContainer_Maki.layoutIfNeeded()
            }
        )
        postsCV_Maki.reloadData()
        updatePostsCVHeight_Maki()
    }
}

// MARK: - UICollectionViewDataSource & Delegate

extension Me_Maki: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentPosts_Maki.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_maki = collectionView.dequeueReusableCell(
            withReuseIdentifier: K_Maki.cellId,
            for: indexPath
        ) as! MePostCell_Maki
        let post_maki = currentPosts_Maki[indexPath.item]
        let isMine_maki = currentTab_Maki == K_Maki.tabMy
        cell_maki.configure_Maki(post_maki: post_maki, showDelete: isMine_maki, vc_maki: self) { [weak self] in
            self?.postsCV_Maki.reloadData()
            self?.updatePostsCVHeight_Maki()
        }
        return cell_maki
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < currentPosts_Maki.count else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Maki.toTitleDetail_Maki(titleModel_maki: currentPosts_Maki[indexPath.item])
    }
}

// MARK: - MePostCell_Maki（我的帖子卡片 Cell）

/// 我的帖子双列卡片 Cell
/// 功能：缩略图 + 底部渐变遮罩 + 标题 + 右上角举报/删除按钮 + 左下角点赞徽章
final class MePostCell_Maki: UICollectionViewCell {

    // MARK: UI 子视图

    private let cardView_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = .white
        v_maki.layer.cornerRadius = 16
        v_maki.layer.shadowColor  = UIColor(hexstring_Maki: "#CC6600").withAlphaComponent(0.12).cgColor
        v_maki.layer.shadowOffset = CGSize(width: 0, height: 4)
        v_maki.layer.shadowRadius = 10
        v_maki.layer.shadowOpacity = 1
        v_maki.layer.masksToBounds = false
        return v_maki
    }()
    private let innerClip_Maki: UIView = {
        let v_maki = UIView()
        v_maki.layer.cornerRadius = 16
        v_maki.clipsToBounds = true
        return v_maki
    }()
    private let mediaIV_Maki: UIImageView = {
        let iv_maki = UIImageView()
        iv_maki.contentMode = .scaleAspectFill
        iv_maki.clipsToBounds = true
        iv_maki.backgroundColor = UIColor(hexstring_Maki: "#FFF3E0")
        return iv_maki
    }()
    /// 底部渐变叠层（突出文字）
    private let gradOverlay_Maki = UIView()
    private let gradLayer_Maki = CAGradientLayer()

    private let titleLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 12, weight: .semibold)
        lb_maki.textColor = .white
        lb_maki.numberOfLines = 2
        lb_maki.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        lb_maki.layer.shadowOffset = CGSize(width: 0, height: 1)
        lb_maki.layer.shadowRadius = 2
        lb_maki.layer.shadowOpacity = 1
        return lb_maki
    }()
    /// 点赞数角标（左下角，毛玻璃）
    private let likesBadge_Maki: UIView = {
        let v_maki = UIView()
        v_maki.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        v_maki.layer.cornerRadius = 9
        v_maki.layer.borderWidth = 1
        v_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        return v_maki
    }()
    private let likesLb_Maki: UILabel = {
        let lb_maki = UILabel()
        lb_maki.font = .systemFont(ofSize: 10, weight: .semibold)
        lb_maki.textColor = .white
        return lb_maki
    }()
    private var reportBtn_Maki: UIButton?

    // MARK: 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Maki()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer_Maki.frame = gradOverlay_Maki.bounds
    }

    // MARK: UI 搭建

    private func setupUI_Maki() {
        contentView.addSubview(cardView_Maki)
        cardView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        cardView_Maki.addSubview(innerClip_Maki)
        innerClip_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 图片铺满
        innerClip_Maki.addSubview(mediaIV_Maki)
        mediaIV_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 底部渐变遮罩
        gradLayer_Maki.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.6).cgColor
        ]
        gradLayer_Maki.startPoint = CGPoint(x: 0.5, y: 0.35)
        gradLayer_Maki.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gradOverlay_Maki.layer.insertSublayer(gradLayer_Maki, at: 0)
        innerClip_Maki.addSubview(gradOverlay_Maki)
        gradOverlay_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 标题文字（左下）
        innerClip_Maki.addSubview(titleLb_Maki)
        titleLb_Maki.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-32)
        }

        // 点赞角标（右下）
        likesBadge_Maki.addSubview(likesLb_Maki)
        innerClip_Maki.addSubview(likesBadge_Maki)
        likesLb_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(6)
            make.trailing.equalToSuperview().offset(-6)
        }
        likesBadge_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(20)
        }
    }

    // MARK: 配置

    func configure_Maki(post_maki: TitleModel_Maki, showDelete: Bool, vc_maki: UIViewController, completion_maki: (() -> Void)?) {
        if let name_maki = post_maki.titleMeidas_Maki.first {
            mediaIV_Maki.image = UIImage(named: name_maki) ?? UIImage(systemName: "photo.fill")
            mediaIV_Maki.tintColor = UIColor(hexstring_Maki: "#FF8C00")
        }
        titleLb_Maki.text = post_maki.title_Maki
        likesLb_Maki.text = "🔥 \(post_maki.likes_Maki)"

        reportBtn_Maki?.removeFromSuperview()
        let btn_maki = ReportDeleteHelper_Maki.createPostReportButton_Maki(
            post_Maki: post_maki,
            size_Maki: 11,
            color_Maki: UIColor.white.withAlphaComponent(0.8),
            from: vc_maki,
            completion_Maki: completion_maki
        )
        // 举报按钮叠加在 innerClip 上（图片右上角）
        innerClip_Maki.addSubview(btn_maki)
        btn_maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-6)
            make.top.equalToSuperview().offset(6)
            make.width.height.equalTo(24)
        }
        reportBtn_Maki = btn_maki
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        mediaIV_Maki.image = nil
    }
}
