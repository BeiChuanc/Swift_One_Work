import Foundation
import UIKit
import SnapKit

// MARK: - 发现页视图控制器

/// 发现页视图控制器
/// 功能：顶部渐变导航 + 横向分类标签筛选 + 精美双列不规则瀑布流
/// 设计：图片区带渐变遮罩和角标叠层，卡片投影+圆角，进场级联弹入动画
/// 逻辑：监听 TitleViewModel/UserViewModel 通知响应式刷新；标签按帖子ID哈希分类
class Discover_Maki: UIViewController {

    // MARK: - 私有常量

    private enum K_Maki {
        static let primary    = UIColor(hexstring_Maki: "#FF8C00")
        static let bg         = UIColor(hexstring_Maki: "#FFFBF4")
        static let card       = UIColor.white
        static let tp         = UIColor(hexstring_Maki: "#1A0A00")
        static let ts         = UIColor(hexstring_Maki: "#8B7355")
        static let accent     = UIColor(hexstring_Maki: "#E85D04")
        /// 双列宽度（屏幕宽度 - 左右边距 16×2 - 列间距 18）
        static let colW       = (APPSCREEN_Maki.WIDTH_Maki - 50) / 2
        static let cardR: CGFloat = 18
        /// 标签分类名称（第 0 项为 All，其余为具体分类）
        static let tags       = ["All", "Craft", "Art", "Food", "Travel", "Life"]
        /// 各标签对应的主题色
        static let tagColors: [UIColor] = [
            UIColor(hexstring_Maki: "#FF8C00"),
            UIColor(hexstring_Maki: "#9B59B6"),
            UIColor(hexstring_Maki: "#E74C3C"),
            UIColor(hexstring_Maki: "#27AE60"),
            UIColor(hexstring_Maki: "#2980B9"),
            UIColor(hexstring_Maki: "#E67E22")
        ]
    }

    // MARK: - UI 属性 / 主容器

    /// 主滚动容器（禁用自动内容偏移，避免顶部出现状态栏间隙）
    private let scrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.showsVerticalScrollIndicator = false
        sv_maki.alwaysBounceVertical = true
        sv_maki.contentInsetAdjustmentBehavior = .never
        return sv_maki
    }()
    private let contentView_Maki = UIView()

    // MARK: - UI 属性 / 顶部导航区

    /// 导航区容器（承载渐变层）
    private let navArea_Maki = UIView()
    /// 导航渐变层（深琥珀 → 橙金）
    private let navGrad_Maki = CAGradientLayer()
    /// 装饰气泡 1（右上角，大）
    private let navBubble1_Maki = UIView()
    /// 装饰气泡 2（左下角，小）
    private let navBubble2_Maki = UIView()
    /// 搜索按钮（右侧）
    private let searchBtn_Maki: UIButton = {
        let btn_maki = UIButton(type: .system)
        btn_maki.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        btn_maki.tintColor = .white
        btn_maki.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        btn_maki.layer.cornerRadius = 18
        btn_maki.layer.borderWidth = 1.5
        btn_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.4).cgColor
        return btn_maki
    }()

    // MARK: - UI 属性 / 标签筛选条

    /// 横向滚动容器（承载标签按钮栈）
    private let tagScrollView_Maki: UIScrollView = {
        let sv_maki = UIScrollView()
        sv_maki.showsHorizontalScrollIndicator = false
        sv_maki.alwaysBounceHorizontal = true
        return sv_maki
    }()
    /// 标签按钮水平栈视图
    private let tagStack_Maki: UIStackView = {
        let sv_maki = UIStackView()
        sv_maki.axis = .horizontal
        sv_maki.spacing = 8
        sv_maki.alignment = .center
        return sv_maki
    }()
    /// 当前选中标签索引（0 = All）
    private var selectedTagIndex_Maki: Int = 0

    // MARK: - UI 属性 / 瀑布流

    /// 双列容器视图
    private let columnsContainer_Maki = UIView()
    /// 左列堆叠视图
    private let leftColumn_Maki: UIStackView = {
        let sv_maki = UIStackView()
        sv_maki.axis = .vertical
        sv_maki.spacing = 14
        sv_maki.alignment = .fill
        return sv_maki
    }()
    /// 右列堆叠视图
    private let rightColumn_Maki: UIStackView = {
        let sv_maki = UIStackView()
        sv_maki.axis = .vertical
        sv_maki.spacing = 14
        sv_maki.alignment = .fill
        return sv_maki
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = K_Maki.bg
        buildUI_Maki()
        bindNotifications_Maki()
        reloadPosts_Maki()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadPosts_Maki()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playEntranceAnimation_Maki()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        navGrad_Maki.frame = navArea_Maki.bounds
    }

    deinit { NotificationCenter.default.removeObserver(self) }
}

// MARK: - UI 构建

extension Discover_Maki {

    /// 构建全部 UI 层级并建立约束
    private func buildUI_Maki() {
        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)
        scrollView_Maki.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView_Maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_Maki.contentLayoutGuide)
            make.width.equalTo(scrollView_Maki.frameLayoutGuide)
        }
        buildNavArea_Maki()
        buildTagBar_Maki()
        buildWaterfall_Maki()
    }

    /// 构建顶部渐变导航区
    /// 包含：渐变背景、装饰气泡、星号+标题、副标题、搜索按钮、底部圆角过渡条
    private func buildNavArea_Maki() {
        // 渐变背景（深琥珀 → 橙金，与首页保持统一）
        navGrad_Maki.colors = [
            UIColor(hexstring_Maki: "#E8650A").cgColor,
            UIColor(hexstring_Maki: "#FF9F1C").cgColor
        ]
        navGrad_Maki.startPoint = CGPoint(x: 0, y: 0)
        navGrad_Maki.endPoint   = CGPoint(x: 1, y: 1)
        navArea_Maki.layer.insertSublayer(navGrad_Maki, at: 0)
        contentView_Maki.addSubview(navArea_Maki)
        navArea_Maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            // 导航区高度 = 固定内容区 + 状态栏高度，确保渐变完整覆盖顶部安全区
            let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
            make.height.equalTo(132 + statusH_maki)
        }

        // 右上角装饰气泡（大）
        navBubble1_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        navBubble1_Maki.layer.cornerRadius = 55
        navArea_Maki.addSubview(navBubble1_Maki)
        navBubble1_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(110)
            make.trailing.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(-22)
        }

        // 左下角装饰气泡（小）
        navBubble2_Maki.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        navBubble2_Maki.layer.cornerRadius = 35
        navArea_Maki.addSubview(navBubble2_Maki)
        navBubble2_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(70)
            make.leading.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(18)
        }

        // 星号装饰符（从状态栏底部向下偏移，避免被遮挡）
        let statusH_maki = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 44
        let starLb_maki = UILabel()
        starLb_maki.text = "✦"
        starLb_maki.font = .systemFont(ofSize: 17, weight: .bold)
        starLb_maki.textColor = UIColor.white.withAlphaComponent(0.88)
        navArea_Maki.addSubview(starLb_maki)
        starLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalToSuperview().offset(statusH_maki + 14)
        }

        // 主标题
        let titleLb_maki = UILabel()
        titleLb_maki.text = "Discover"
        titleLb_maki.font = UIFont(name: "Georgia-Bold", size: 26)
            ?? .systemFont(ofSize: 26, weight: .bold)
        titleLb_maki.textColor = .white
        navArea_Maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(starLb_maki.snp.trailing).offset(8)
            make.centerY.equalTo(starLb_maki)
        }

        // 副标题
        let subLb_maki = UILabel()
        subLb_maki.text = "Explore creations from the community"
        subLb_maki.font = .systemFont(ofSize: 12, weight: .light)
        subLb_maki.textColor = UIColor.white.withAlphaComponent(0.8)
        navArea_Maki.addSubview(subLb_maki)
        subLb_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(22)
            make.top.equalTo(titleLb_maki.snp.bottom).offset(4)
        }

        // 右侧搜索按钮
        searchBtn_Maki.addTarget(self, action: #selector(onSearchTap_Maki), for: .touchUpInside)
        navArea_Maki.addSubview(searchBtn_Maki)
        searchBtn_Maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLb_maki).offset(2)
            make.width.height.equalTo(36)
        }

        // 底部圆角过渡条（平滑衔接背景色）
        let decoBar_maki = UIView()
        decoBar_maki.backgroundColor = K_Maki.bg
        decoBar_maki.layer.cornerRadius = 22
        decoBar_maki.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navArea_Maki.addSubview(decoBar_maki)
        decoBar_maki.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(28)
        }
    }

    /// 构建横向分类标签筛选条
    /// 标签：All / Craft / Art / Food / Travel / Life
    private func buildTagBar_Maki() {
        contentView_Maki.addSubview(tagScrollView_Maki)
        tagScrollView_Maki.addSubview(tagStack_Maki)

        tagScrollView_Maki.snp.makeConstraints { make in
            make.top.equalTo(navArea_Maki.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        tagStack_Maki.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalToSuperview()
        }

        // 逐个生成标签按钮
        for (idx_maki, tag_maki) in K_Maki.tags.enumerated() {
            let btn_maki = buildTagButton_Maki(title_maki: tag_maki, index_maki: idx_maki)
            tagStack_Maki.addArrangedSubview(btn_maki)
        }
    }

    /// 创建单个标签按钮
    /// - Parameters:
    ///   - title_maki: 按钮文字
    ///   - index_maki: 按钮索引，用于 tag 属性与配色
    /// - Returns: 配置好样式的 UIButton
    private func buildTagButton_Maki(title_maki: String, index_maki: Int) -> UIButton {
        let btn_maki = UIButton(type: .custom)
        btn_maki.setTitle(title_maki, for: .normal)
        btn_maki.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn_maki.tag = index_maki
        btn_maki.layer.cornerRadius = 14
        btn_maki.contentEdgeInsets = UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 16)
        btn_maki.addTarget(self, action: #selector(onTagTap_Maki(_:)), for: .touchUpInside)
        refreshTagButtonStyle_Maki(btn_maki, isSelected_maki: index_maki == selectedTagIndex_Maki)
        return btn_maki
    }

    /// 刷新单个标签按钮的选中/未选中视觉样式
    /// - Parameters:
    ///   - btn_maki: 目标按钮
    ///   - isSelected_maki: 是否处于选中状态
    private func refreshTagButtonStyle_Maki(_ btn_maki: UIButton, isSelected_maki: Bool) {
        let color_maki = K_Maki.tagColors[btn_maki.tag % K_Maki.tagColors.count]
        if isSelected_maki {
            btn_maki.backgroundColor = color_maki
            btn_maki.setTitleColor(.white, for: .normal)
            btn_maki.layer.shadowColor = color_maki.withAlphaComponent(0.45).cgColor
            btn_maki.layer.shadowOffset = CGSize(width: 0, height: 3)
            btn_maki.layer.shadowRadius = 6
            btn_maki.layer.shadowOpacity = 1
        } else {
            btn_maki.backgroundColor = UIColor.white
            btn_maki.setTitleColor(K_Maki.ts, for: .normal)
            btn_maki.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
            btn_maki.layer.shadowOffset = CGSize(width: 0, height: 2)
            btn_maki.layer.shadowRadius = 4
            btn_maki.layer.shadowOpacity = 1
        }
    }

    /// 构建双列瀑布流布局容器
    private func buildWaterfall_Maki() {
        contentView_Maki.addSubview(columnsContainer_Maki)
        columnsContainer_Maki.addSubview(leftColumn_Maki)
        columnsContainer_Maki.addSubview(rightColumn_Maki)

        columnsContainer_Maki.snp.makeConstraints { make in
            make.top.equalTo(tagScrollView_Maki.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-100)
        }
        leftColumn_Maki.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalTo(K_Maki.colW)
        }
        rightColumn_Maki.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.width.equalTo(K_Maki.colW)
        }
    }
}

// MARK: - 数据刷新

extension Discover_Maki {

    /// 根据当前选中标签过滤帖子
    /// - Returns: 过滤后的帖子列表；"All"返回全部，其余标签按帖子 ID 哈希分配
    private func filteredPosts_Maki() -> [TitleModel_Maki] {
        let all_maki = TitleViewModel_Maki.shared_Maki.getPosts_Maki()
        // selectedTagIndex_Maki == 0 对应 "All"，展示全部
        guard selectedTagIndex_Maki > 0 else { return all_maki }
        // 分类数量 = 标签数 - 1（去掉 All）
        let catCount_maki = K_Maki.tags.count - 1
        return all_maki.filter { ($0.titleId_Maki % catCount_maki) == (selectedTagIndex_Maki - 1) }
    }

    /// 重建双列瀑布流（清空后重新填充）
    private func reloadPosts_Maki() {
        leftColumn_Maki.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rightColumn_Maki.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let posts_maki = filteredPosts_Maki()
        guard !posts_maki.isEmpty else {
            buildEmptyState_Maki()
            return
        }

        var leftH_maki: CGFloat  = 0
        var rightH_maki: CGFloat = 0

        for post_maki in posts_maki {
            let cardH_maki = estimateCardHeight_Maki(for: post_maki)
            let card_maki  = buildPostCard_Maki(post: post_maki)
            card_maki.snp.makeConstraints { $0.height.equalTo(cardH_maki) }

            // 向高度更小的列追加，保持双列平衡
            if leftH_maki <= rightH_maki {
                leftColumn_Maki.addArrangedSubview(card_maki)
                leftH_maki += cardH_maki + 14
            } else {
                rightColumn_Maki.addArrangedSubview(card_maki)
                rightH_maki += cardH_maki + 14
            }
        }

        // 较短一列末尾补充空白使底部对齐
        let diff_maki = abs(leftH_maki - rightH_maki)
        if diff_maki > 20 {
            let spacer_maki = UIView()
            if leftH_maki < rightH_maki {
                leftColumn_Maki.addArrangedSubview(spacer_maki)
                spacer_maki.snp.makeConstraints { $0.height.equalTo(diff_maki) }
            } else {
                rightColumn_Maki.addArrangedSubview(spacer_maki)
                spacer_maki.snp.makeConstraints { $0.height.equalTo(diff_maki) }
            }
        }
    }

    /// 构建空状态占位视图（当前分类无帖子时展示）
    private func buildEmptyState_Maki() {
        let wrap_maki = UIView()
        let iconLb_maki = UILabel()
        iconLb_maki.text = "🎨"
        iconLb_maki.font = .systemFont(ofSize: 44)
        iconLb_maki.textAlignment = .center

        let msgLb_maki = UILabel()
        msgLb_maki.text = "No posts in this category yet"
        msgLb_maki.font = .systemFont(ofSize: 14, weight: .medium)
        msgLb_maki.textColor = K_Maki.ts
        msgLb_maki.textAlignment = .center

        let hintLb_maki = UILabel()
        hintLb_maki.text = "Be the first to share something!"
        hintLb_maki.font = .systemFont(ofSize: 12)
        hintLb_maki.textColor = K_Maki.ts.withAlphaComponent(0.6)
        hintLb_maki.textAlignment = .center

        wrap_maki.addSubview(iconLb_maki)
        wrap_maki.addSubview(msgLb_maki)
        wrap_maki.addSubview(hintLb_maki)
        iconLb_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(48)
            make.centerX.equalToSuperview()
        }
        msgLb_maki.snp.makeConstraints { make in
            make.top.equalTo(iconLb_maki.snp.bottom).offset(14)
            make.centerX.equalToSuperview()
        }
        hintLb_maki.snp.makeConstraints { make in
            make.top.equalTo(msgLb_maki.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-40)
        }

        leftColumn_Maki.addArrangedSubview(wrap_maki)
        // 空状态视图横跨双列宽度（通过约束设置更宽）
        wrap_maki.snp.makeConstraints { $0.width.equalTo(K_Maki.colW * 2 + 18) }
    }

    /// 根据帖子内容估算卡片高度，产生不规则瀑布流视觉效果
    /// - Parameter post: 帖子模型
    /// - Returns: 估算高度（CGFloat）
    private func estimateCardHeight_Maki(for post: TitleModel_Maki) -> CGFloat {
        // 图片高度比例：按帖子 ID 取余在三档之间切换（0.65 / 0.75 / 0.9）
        let ratio_maki: CGFloat
        switch post.titleId_Maki % 3 {
        case 0:  ratio_maki = 0.90
        case 1:  ratio_maki = 0.75
        default: ratio_maki = 0.65
        }
        let imgH_maki    = K_Maki.colW * ratio_maki
        let titleH_maki: CGFloat  = 38
        let authorH_maki: CGFloat = 36
        let padding_maki: CGFloat = 24
        return imgH_maki + titleH_maki + authorH_maki + padding_maki
    }
}

// MARK: - 卡片构建

extension Discover_Maki {

    /// 构建单张精美帖子卡片
    /// - Parameter post: 帖子数据模型
    /// - Returns: 配置完毕的卡片 UIView
    private func buildPostCard_Maki(post: TitleModel_Maki) -> UIView {
        // 外层卡片（承载投影，不裁剪以确保阴影可见）
        let card_maki = UIView()
        card_maki.backgroundColor = K_Maki.card
        card_maki.layer.cornerRadius = K_Maki.cardR
        card_maki.layer.shadowColor = UIColor(hexstring_Maki: "#CC6600").withAlphaComponent(0.15).cgColor
        card_maki.layer.shadowOffset = CGSize(width: 0, height: 5)
        card_maki.layer.shadowRadius = 12
        card_maki.layer.shadowOpacity = 1
        card_maki.layer.masksToBounds = false

        // 内层容器（裁剪圆角，承载所有子视图）
        let inner_maki = UIView()
        inner_maki.backgroundColor = K_Maki.card
        inner_maki.layer.cornerRadius = K_Maki.cardR
        inner_maki.clipsToBounds = true
        card_maki.addSubview(inner_maki)
        inner_maki.snp.makeConstraints { $0.edges.equalToSuperview() }

        // 图片区高度（与估算逻辑保持一致）
        let ratio_maki: CGFloat
        switch post.titleId_Maki % 3 {
        case 0:  ratio_maki = 0.90
        case 1:  ratio_maki = 0.75
        default: ratio_maki = 0.65
        }
        let imgH_maki = K_Maki.colW * ratio_maki

        buildCardMediaArea_Maki(in: inner_maki, post: post, imgH_maki: imgH_maki)
        buildCardTextArea_Maki(in: inner_maki, post: post, imgH_maki: imgH_maki)

        // 点击进入详情
        let tap_maki = UITapGestureRecognizer(target: self, action: #selector(onCardTap_Maki(_:)))
        card_maki.isUserInteractionEnabled = true
        card_maki.addGestureRecognizer(tap_maki)
        card_maki.tag = post.titleId_Maki
        return card_maki
    }

    /// 构建卡片媒体图片区（含渐变遮罩、分类角标、点赞角标）
    /// - Parameters:
    ///   - container_maki: 父容器（inner_maki）
    ///   - post: 帖子模型
    ///   - imgH_maki: 图片区高度
    private func buildCardMediaArea_Maki(in container_maki: UIView,
                                         post: TitleModel_Maki,
                                         imgH_maki: CGFloat) {
        // 媒体图片
        let mediaIV_maki = UIImageView()
        mediaIV_maki.contentMode = .scaleAspectFill
        mediaIV_maki.clipsToBounds = true
        mediaIV_maki.backgroundColor = UIColor(hexstring_Maki: "#FFF3E0")
        if let name_maki = post.titleMeidas_Maki.first {
            mediaIV_maki.image = UIImage(named: name_maki) ?? UIImage(systemName: "photo.artframe")
            mediaIV_maki.tintColor = K_Maki.primary
        }
        container_maki.addSubview(mediaIV_maki)
        mediaIV_maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(imgH_maki)
        }

        // 底部渐变遮罩（透明 → 半透明黑，突出文字角标可读性）
        let gradView_maki = UIView()
        let gradLayer_maki = CAGradientLayer()
        gradLayer_maki.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.48).cgColor
        ]
        gradLayer_maki.startPoint = CGPoint(x: 0.5, y: 0.35)
        gradLayer_maki.endPoint   = CGPoint(x: 0.5, y: 1.0)
        gradLayer_maki.frame      = CGRect(x: 0, y: 0, width: K_Maki.colW, height: imgH_maki)
        gradView_maki.layer.insertSublayer(gradLayer_maki, at: 0)
        container_maki.addSubview(gradView_maki)
        gradView_maki.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(imgH_maki)
        }

        // 分类角标（左上角叠加，彩色胶囊样式）
        let catIdx_maki   = post.titleId_Maki % (K_Maki.tags.count - 1)
        let catName_maki  = K_Maki.tags[catIdx_maki + 1]
        let catColor_maki = K_Maki.tagColors[(catIdx_maki + 1) % K_Maki.tagColors.count]
        let tagPill_maki  = buildBadgePill_Maki(text_maki: catName_maki,
                                                 bgColor_maki: catColor_maki,
                                                 textColor_maki: .white,
                                                 fontSize_maki: 10)
        container_maki.addSubview(tagPill_maki)
        tagPill_maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(18)
        }

        // 点赞数角标（右上角叠加，毛玻璃效果）
        let likesBadge_maki = buildBadgePill_Maki(text_maki: "🔥 \(post.likes_Maki)",
                                                   bgColor_maki: UIColor.white.withAlphaComponent(0.22),
                                                   textColor_maki: .white,
                                                   fontSize_maki: 10)
        likesBadge_maki.layer.borderWidth = 1
        likesBadge_maki.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        container_maki.addSubview(likesBadge_maki)
        likesBadge_maki.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.top.equalToSuperview().offset(8)
            make.height.equalTo(20)
        }
    }

    /// 构建卡片文字信息区（标题、作者行、举报/删除按钮）
    /// - Parameters:
    ///   - container_maki: 父容器（inner_maki）
    ///   - post: 帖子模型
    ///   - imgH_maki: 图片区高度（用于定位标题顶部约束）
    private func buildCardTextArea_Maki(in container_maki: UIView,
                                        post: TitleModel_Maki,
                                        imgH_maki: CGFloat) {
        // 帖子标题
        let titleLb_maki = UILabel()
        titleLb_maki.text = post.title_Maki
        titleLb_maki.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLb_maki.textColor = K_Maki.tp
        titleLb_maki.numberOfLines = 2
        container_maki.addSubview(titleLb_maki)
        titleLb_maki.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(imgH_maki + 9)
            make.leading.trailing.equalToSuperview().inset(10)
        }

        // 作者头像（橙色细边框装饰）
        let authorAvatar_maki = UserAvatarView_Maki()
        authorAvatar_maki.configure_Maki(userId_Maki: post.titleUserId_Maki)
        authorAvatar_maki.layer.borderWidth = 1.5
        authorAvatar_maki.layer.borderColor = K_Maki.primary.withAlphaComponent(0.38).cgColor
        authorAvatar_maki.layer.cornerRadius = 12
        authorAvatar_maki.clipsToBounds = true

        // 作者名字
        let authorNameLb_maki = UILabel()
        authorNameLb_maki.text = post.titleUserName_Maki
        authorNameLb_maki.font = .systemFont(ofSize: 11, weight: .medium)
        authorNameLb_maki.textColor = K_Maki.ts

        // 举报/删除按钮
        let reportBtn_maki = ReportDeleteHelper_Maki.createPostReportButton_Maki(
            post_Maki: post,
            size_Maki: 11,
            color_Maki: UIColor(hexstring_Maki: "#C0B4A0"),
            from: self
        ) { [weak self] in self?.reloadPosts_Maki() }

        // 作者行容器
        let authorRow_maki = UIView()
        authorRow_maki.addSubview(authorAvatar_maki)
        authorRow_maki.addSubview(authorNameLb_maki)
        authorRow_maki.addSubview(reportBtn_maki)

        authorAvatar_maki.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        reportBtn_maki.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(22)
        }
        authorNameLb_maki.snp.makeConstraints { make in
            make.leading.equalTo(authorAvatar_maki.snp.trailing).offset(5)
            make.trailing.equalTo(reportBtn_maki.snp.leading).offset(-4)
            make.centerY.equalToSuperview()
        }

        container_maki.addSubview(authorRow_maki)
        authorRow_maki.snp.makeConstraints { make in
            make.top.equalTo(titleLb_maki.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(28)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
        }

        // 头像 + 名字区域点击进入用户中心：透明 UIButton 覆盖，tag 存储 userId
        let userId_maki = post.titleUserId_Maki
        let authorTapBtn_maki = UIButton(type: .custom)
        authorTapBtn_maki.backgroundColor = .clear
        authorTapBtn_maki.tag = userId_maki
        authorTapBtn_maki.addTarget(self, action: #selector(onAuthorTap_Maki(_:)), for: .touchUpInside)
        authorRow_maki.addSubview(authorTapBtn_maki)
        authorTapBtn_maki.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.trailing.equalTo(reportBtn_maki.snp.leading).offset(-2)
        }
    }

    /// 创建通用角标胶囊视图（用于分类角标、点赞角标）
    /// - Parameters:
    ///   - text_maki: 显示文字
    ///   - bgColor_maki: 背景色
    ///   - textColor_maki: 文字颜色
    ///   - fontSize_maki: 字号
    /// - Returns: 配置好的胶囊 UIView
    private func buildBadgePill_Maki(text_maki: String,
                                      bgColor_maki: UIColor,
                                      textColor_maki: UIColor,
                                      fontSize_maki: CGFloat) -> UIView {
        let pill_maki = UIView()
        pill_maki.backgroundColor = bgColor_maki
        pill_maki.layer.cornerRadius = 9

        let lb_maki = UILabel()
        lb_maki.text = text_maki
        lb_maki.font = .systemFont(ofSize: fontSize_maki, weight: .bold)
        lb_maki.textColor = textColor_maki

        pill_maki.addSubview(lb_maki)
        lb_maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.equalToSuperview().offset(7)
            make.trailing.equalToSuperview().offset(-7)
        }
        return pill_maki
    }
}

// MARK: - 进场动画

extension Discover_Maki {

    /// 发现页进场：卡片从下方级联弹入，左右列交错排列
    private func playEntranceAnimation_Maki() {
        // 将左右列卡片交错合并，形成自然的视觉节奏
        let leftCards_maki  = leftColumn_Maki.arrangedSubviews
        let rightCards_maki = rightColumn_Maki.arrangedSubviews
        var merged_maki: [UIView] = []
        let maxCount_maki = max(leftCards_maki.count, rightCards_maki.count)
        for i_maki in 0..<maxCount_maki {
            if i_maki < leftCards_maki.count  { merged_maki.append(leftCards_maki[i_maki]) }
            if i_maki < rightCards_maki.count { merged_maki.append(rightCards_maki[i_maki]) }
        }

        for (i_maki, card_maki) in merged_maki.enumerated() {
            card_maki.alpha = 0
            card_maki.transform = CGAffineTransform(translationX: 0, y: 38)
            UIView.animate(
                withDuration: 0.46,
                delay: Double(i_maki) * 0.055,
                usingSpringWithDamping: 0.76,
                initialSpringVelocity: 0.3,
                options: [],
                animations: {
                    card_maki.alpha = 1
                    card_maki.transform = .identity
                }
            )
        }

        // 标签栏整体淡入滑下
        tagScrollView_Maki.alpha = 0
        tagScrollView_Maki.transform = CGAffineTransform(translationX: 0, y: -12)
        UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut) {
            self.tagScrollView_Maki.alpha = 1
            self.tagScrollView_Maki.transform = .identity
        }
    }
}

// MARK: - 通知绑定

extension Discover_Maki {

    /// 注册帖子和用户状态变化通知
    private func bindNotifications_Maki() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChange_Maki),
            name: TitleViewModel_Maki.titleStateDidChangeNotification_Maki, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(onDataChange_Maki),
            name: UserViewModel_Maki.userStateDidChangeNotification_Maki, object: nil
        )
    }

    /// 数据变化时重建瀑布流
    @objc private func onDataChange_Maki() { reloadPosts_Maki() }
}

// MARK: - 事件响应

extension Discover_Maki {

    /// 搜索按钮点击：展示发现页搜索覆盖层
    @objc private func onSearchTap_Maki() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        Navigation_Maki.toDiscoverSearch_Maki(from: self)
    }

    /// 帖子卡片中作者区域点击：通过 tag 携带 userId，跳转用户中心
    @objc private func onAuthorTap_Maki(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        let user_maki = UserViewModel_Maki.shared_Maki.getUserById_Maki(userId_maki: sender.tag)
        Navigation_Maki.toUserInfo_Maki(with: user_maki)
    }

    /// 标签按钮点击：切换分类 + 刷新数据 + 按钮弹性动画
    @objc private func onTagTap_Maki(_ sender: UIButton) {
        guard sender.tag != selectedTagIndex_Maki else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // 刷新所有标签按钮样式
        tagStack_Maki.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { btn_maki in
            refreshTagButtonStyle_Maki(btn_maki, isSelected_maki: btn_maki.tag == sender.tag)
        }
        selectedTagIndex_Maki = sender.tag

        // 按钮弹性缩放反馈
        UIView.animate(withDuration: 0.12, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }, completion: { _ in
            UIView.animate(
                withDuration: 0.22,
                delay: 0,
                usingSpringWithDamping: 0.58,
                initialSpringVelocity: 0.4,
                options: [],
                animations: { sender.transform = .identity }
            )
        })

        reloadPosts_Maki()
        // 切换后为新卡片播放进场动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.playEntranceAnimation_Maki()
        }
    }

    /// 卡片点击：触觉反馈 + 跳转帖子详情页
    @objc private func onCardTap_Maki(_ gesture: UITapGestureRecognizer) {
        guard let postId_maki = gesture.view?.tag else { return }
        guard let post_maki = TitleViewModel_Maki.shared_Maki.getPosts_Maki().first(
            where: { $0.titleId_Maki == postId_maki }
        ) else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        // 卡片按压缩放反馈
        if let cardView_maki = gesture.view {
            UIView.animate(withDuration: 0.1, animations: {
                cardView_maki.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            }, completion: { _ in
                UIView.animate(withDuration: 0.15) {
                    cardView_maki.transform = .identity
                }
            })
        }

        Navigation_Maki.toTitleDetail_Maki(titleModel_maki: post_maki)
    }
}
