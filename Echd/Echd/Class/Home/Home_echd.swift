import Foundation
import UIKit
import SnapKit

// MARK: - 渐变背景 Helper View
// 功能：在自身 layoutSubviews 中自动同步 CAGradientLayer.frame，
//       解决 CAGradientLayer 在 ScrollView 内部时机不对导致渐变不显示的问题。

private class HomeGradientView_Echd: UIView {
    private let grad_Echd = CAGradientLayer()
    init(colors: [UIColor],
         start: CGPoint = .init(x: 0, y: 0),
         end: CGPoint = .init(x: 1, y: 1)) {
        super.init(frame: .zero)
        grad_Echd.colors = colors.map { $0.cgColor }
        grad_Echd.startPoint = start
        grad_Echd.endPoint = end
        layer.insertSublayer(grad_Echd, at: 0)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layoutSubviews() {
        super.layoutSubviews()
        grad_Echd.frame = bounds
    }
}

// MARK: - 弹幕容器（自定义 hitTest + 触摸位置派发）
// 原理：UIView.animate 立刻把 model layer frame 设为终点，即使 hitTest 返回子按钮，
//       UIButton 内部的 point(inside:with:) 也会因 model 坐标在屏幕外而失败，吞掉点击。
// 解法：hitTest 只返回飞行 item 本身（使用 presentation frame 判断命中），
//       由 item 上的 UITapGestureRecognizer 处理点击，通过 presentation 坐标区分操作区域。

private class DanmakuContainer_Echd: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for item_Echd in subviews.reversed() {
            guard item_Echd.isUserInteractionEnabled,
                  let presentFrame_Echd = item_Echd.layer.presentation()?.frame else { continue }
            // 用 presentation frame 判断触摸是否命中视觉位置
            if presentFrame_Echd.contains(point) { return item_Echd }
        }
        return nil
    }
}

// MARK: 首页
// 主题：时光弹幕漂流（Echd）
// 设计思路：
//   顶部渐变 Header + Live Sparks 弹幕动画带（每条飞行弹幕含收藏/举报按钮，
//   举报后从数据池移除，收藏状态实时更新）；
//   "My Moments" 入口横幅；Theme Collections 竖向卡片列表。
//   渐变视图全部使用 HomeGradientView_Echd 确保 frame 始终正确。

class Home_Echd: UIViewController {

    // MARK: - UI组件 / 整体滚动

    private let scrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsVerticalScrollIndicator = false
        sv_Echd.alwaysBounceVertical = true
        // 禁用自动安全区域内边距，防止状态栏高度被追加为顶部空隙
        sv_Echd.contentInsetAdjustmentBehavior = .never
        return sv_Echd
    }()

    private let contentView_Echd = UIView()

    // MARK: - UI组件 / Header（使用自动更新 frame 的渐变视图）

    private let headerView_Echd = HomeGradientView_Echd(
        colors: [
            UIColor(hexstring_Echd: "#7C3AED"),
            UIColor(hexstring_Echd: "#4F46E5"),
            UIColor(hexstring_Echd: "#6366F1")
        ]
    )

    private let avatarView_Echd = CurrentUserAvatarView_Echd()

    private let titleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Echd"
        label_Echd.font = UIFont.systemFont(ofSize: 36, weight: .black)
        label_Echd.textColor = .white
        return label_Echd
    }()

    private let subTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Time Drift · Catch every spark"
        label_Echd.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.8)
        return label_Echd
    }()

    private let flameIconView_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        iv_Echd.image = UIImage(systemName: "flame.fill")
        iv_Echd.tintColor = UIColor(hexstring_Echd: "#FFD700")
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()

    // MARK: - UI组件 / Live Sparks 弹幕动画带

    private let liveSparksLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "✨  Live Sparks"
        label_Echd.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        return label_Echd
    }()

    /// 右侧发布弹幕按钮
    private let publishDanmakuButton_Echd: UIButton = {
        let btn_Echd = UIButton(type: .custom)
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        btn_Echd.setImage(UIImage(systemName: "plus.bubble.fill", withConfiguration: cfg_Echd), for: .normal)
        btn_Echd.setTitle("  Send Spark", for: .normal)
        btn_Echd.setTitleColor(.white, for: .normal)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        btn_Echd.tintColor = .white
        btn_Echd.backgroundColor = UIColor(hexstring_Echd: "#7C3AED")
        btn_Echd.layer.cornerRadius = 14
        btn_Echd.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 12)
        return btn_Echd
    }()

    private let danmakuCardView_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = UIColor(hexstring_Echd: "#1A1A2E")
        view_Echd.layer.cornerRadius = 20
        view_Echd.clipsToBounds = true
        return view_Echd
    }()

    /// 使用自定义 hitTest 容器，确保飞行中按钮可点击
    private let danmakuContainerView_Echd = DanmakuContainer_Echd()

    // MARK: - UI组件 / My Moments 横幅（使用自动更新 frame 的渐变视图）

    private let myMomentsBanner_Echd: HomeGradientView_Echd = {
        let v_Echd = HomeGradientView_Echd(
            colors: [UIColor(hexstring_Echd: "#EC4899"), UIColor(hexstring_Echd: "#F59E0B")],
            start: CGPoint(x: 0, y: 0.5),
            end: CGPoint(x: 1, y: 0.5)
        )
        v_Echd.layer.cornerRadius = 22
        v_Echd.clipsToBounds = true
        v_Echd.isUserInteractionEnabled = true
        return v_Echd
    }()

    // MARK: - UI组件 / Theme Collections 竖向列表

    private let themeCollectionLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Theme Collections"
        label_Echd.font = UIFont.systemFont(ofSize: 17, weight: .black)
        label_Echd.textColor = UIColor(hexstring_Echd: "#111827")
        return label_Echd
    }()

    private let themeVerticalStack_Echd: UIStackView = {
        let sv_Echd = UIStackView()
        sv_Echd.axis = .vertical
        sv_Echd.spacing = 14
        sv_Echd.alignment = .fill
        return sv_Echd
    }()

    // MARK: - 私有属性（弹幕动画）

    /// Live Sparks 独立弹幕数据（来自 DanmakuFavVM，与帖子系统无关）
    private var danmakuItems_Echd: [DanmakuModel_Echd] = []
    private let danmakuRowCount_Echd = 4
    private var danmakuTimer_Echd: Timer?
    private var danmakuIndex_Echd: Int = 0
    private let danmakuColors_Echd: [UIColor] = [
        UIColor(hexstring_Echd: "#C084FC"),
        UIColor(hexstring_Echd: "#60A5FA"),
        UIColor(hexstring_Echd: "#F472B6"),
        UIColor(hexstring_Echd: "#FBBF24")
    ]

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
        loadDanmakuData_Echd()
        buildThemeCards_Echd()
        observeNotifications_Echd()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startDanmakuAnimation_Echd()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopDanmakuAnimation_Echd()
    }

    deinit {
        stopDanmakuAnimation_Echd()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI设置

    private func setupUI_Echd() {
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(contentView_Echd)

        // Header
        contentView_Echd.addSubview(headerView_Echd)
        headerView_Echd.addSubview(titleLabel_Echd)
        headerView_Echd.addSubview(subTitleLabel_Echd)
        headerView_Echd.addSubview(flameIconView_Echd)
        headerView_Echd.addSubview(avatarView_Echd)
        avatarView_Echd.onTapped_Echd = { [weak self] in
            guard let self = self else { return }
            if let tabBar_Echd = self.tabBarController as? TabBar_Echd {
                tabBar_Echd.switchToTab_Echd(index_Echd: 4)
            }
        }

        // Live Sparks 弹幕动画带 + 发布按钮
        contentView_Echd.addSubview(liveSparksLabel_Echd)
        contentView_Echd.addSubview(publishDanmakuButton_Echd)
        publishDanmakuButton_Echd.addTarget(self, action: #selector(publishDanmakuTapped_Echd), for: .touchUpInside)
        contentView_Echd.addSubview(danmakuCardView_Echd)
        danmakuContainerView_Echd.backgroundColor = .clear
        danmakuContainerView_Echd.clipsToBounds = true
        danmakuCardView_Echd.addSubview(danmakuContainerView_Echd)

        // My Moments 横幅
        setupMyMomentsBanner_Echd()

        // Theme Collections 竖向
        contentView_Echd.addSubview(themeCollectionLabel_Echd)
        contentView_Echd.addSubview(themeVerticalStack_Echd)
    }

    /// 构建 My Moments 入口横幅内部子视图
    private func setupMyMomentsBanner_Echd() {
        contentView_Echd.addSubview(myMomentsBanner_Echd)

        let decoIV_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 60, weight: .thin)
        decoIV_Echd.image = UIImage(systemName: "clock.arrow.circlepath", withConfiguration: cfg_Echd)
        decoIV_Echd.tintColor = UIColor.white.withAlphaComponent(0.12)
        decoIV_Echd.contentMode = .scaleAspectFit
        myMomentsBanner_Echd.addSubview(decoIV_Echd)

        let titleLbl_Echd = UILabel()
        titleLbl_Echd.text = "My Moments"
        titleLbl_Echd.font = UIFont.systemFont(ofSize: 22, weight: .black)
        titleLbl_Echd.textColor = .white
        myMomentsBanner_Echd.addSubview(titleLbl_Echd)

        let subLbl_Echd = UILabel()
        subLbl_Echd.text = "Capture every spark of your life ✦"
        subLbl_Echd.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        subLbl_Echd.textColor = UIColor.white.withAlphaComponent(0.8)
        myMomentsBanner_Echd.addSubview(subLbl_Echd)

        let pillsRow_Echd = UIStackView()
        pillsRow_Echd.axis = .horizontal
        pillsRow_Echd.spacing = 8
        pillsRow_Echd.alignment = .center
        myMomentsBanner_Echd.addSubview(pillsRow_Echd)

        for pillText_Echd in ["Published", "Favorites", "Timeline"] {
            let pill_Echd = UILabel()
            pill_Echd.text = "  \(pillText_Echd)  "
            pill_Echd.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            pill_Echd.textColor = UIColor(hexstring_Echd: "#EC4899")
            pill_Echd.backgroundColor = .white
            pill_Echd.layer.cornerRadius = 10
            pill_Echd.clipsToBounds = true
            pill_Echd.textAlignment = .center
            pill_Echd.snp.makeConstraints { make in make.height.equalTo(22) }
            pillsRow_Echd.addArrangedSubview(pill_Echd)
        }

        let arrowIV_Echd = UIImageView()
        let aCfg_Echd = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        arrowIV_Echd.image = UIImage(systemName: "chevron.right.circle.fill", withConfiguration: aCfg_Echd)
        arrowIV_Echd.tintColor = UIColor.white.withAlphaComponent(0.9)
        myMomentsBanner_Echd.addSubview(arrowIV_Echd)

        decoIV_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(120)
        }
        titleLbl_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(20)
        }
        subLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Echd.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(20)
        }
        pillsRow_Echd.snp.makeConstraints { make in
            make.top.equalTo(subLbl_Echd.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-24)
            make.trailing.lessThanOrEqualTo(arrowIV_Echd.snp.leading).offset(-8)
        }
        arrowIV_Echd.snp.makeConstraints { make in
            make.trailing.equalTo(decoIV_Echd.snp.leading).offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(28)
        }

        myMomentsBanner_Echd.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(myMomentsTapped_Echd))
        )
    }

    // MARK: - 约束布局

    private func setupConstraints_Echd() {
        let sw_Echd = UIScreen.main.bounds.width

        scrollView_Echd.snp.makeConstraints { make in make.edges.equalToSuperview() }
        contentView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sw_Echd)
        }

        headerView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(152)  // 原 220，压缩顶部高度
        }
        avatarView_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(52)  // 原 60，稍微上移
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(42)
        }
        flameIconView_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalTo(titleLabel_Echd)
            make.width.height.equalTo(28)
        }
        titleLabel_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(54)  // 原 80，减少顶部留白
            make.leading.equalTo(flameIconView_Echd.snp.trailing).offset(8)
        }
        subTitleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Echd.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(24)
        }

        liveSparksLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(headerView_Echd.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        publishDanmakuButton_Echd.snp.makeConstraints { make in
            make.centerY.equalTo(liveSparksLabel_Echd)
            make.trailing.equalToSuperview().offset(-16)
        }
        danmakuCardView_Echd.snp.makeConstraints { make in
            make.top.equalTo(liveSparksLabel_Echd.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(160)
        }
        danmakuContainerView_Echd.snp.makeConstraints { make in make.edges.equalToSuperview() }

        myMomentsBanner_Echd.snp.makeConstraints { make in
            make.top.equalTo(danmakuCardView_Echd.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        themeCollectionLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(myMomentsBanner_Echd.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(20)
        }
        themeVerticalStack_Echd.snp.makeConstraints { make in
            make.top.equalTo(themeCollectionLabel_Echd.snp.bottom).offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-120)
        }
    }

    // MARK: - 弹幕动画数据

    /// 从 DanmakuFavVM 加载独立弹幕数据（不再使用帖子数据）
    private func loadDanmakuData_Echd() {
        danmakuItems_Echd = DanmakuFavVM_Echd.shared_Echd.getAllDanmaku_Echd()
    }

    // MARK: - 弹幕动画控制

    private func startDanmakuAnimation_Echd() {
        stopDanmakuAnimation_Echd()
        danmakuTimer_Echd = Timer.scheduledTimer(withTimeInterval: 1.1, repeats: true) { [weak self] _ in
            self?.launchDanmakuItem_Echd()
        }
        launchDanmakuItem_Echd()
        launchDanmakuItem_Echd()
    }

    private func stopDanmakuAnimation_Echd() {
        danmakuTimer_Echd?.invalidate()
        danmakuTimer_Echd = nil
    }

    /// 发射一条带交互按钮的弹幕项（使用 UIView.animate + DanmakuContainer_Echd hitTest 保证按钮可点击）
    private func launchDanmakuItem_Echd() {
        let w_Echd = danmakuContainerView_Echd.bounds.width
        let h_Echd = danmakuContainerView_Echd.bounds.height
        guard w_Echd > 0, h_Echd > 0 else { return }

        let row_Echd = Int.random(in: 0..<danmakuRowCount_Echd)
        let rowH_Echd = h_Echd / CGFloat(danmakuRowCount_Echd)
        let yPos_Echd = rowH_Echd * CGFloat(row_Echd) + (rowH_Echd - 28) / 2
        let color_Echd = danmakuColors_Echd[row_Echd % danmakuColors_Echd.count]

        if !danmakuItems_Echd.isEmpty {
            let danmaku_Echd = danmakuItems_Echd[danmakuIndex_Echd % danmakuItems_Echd.count]
            danmakuIndex_Echd += 1

            let item_Echd = buildFlyingItem_Echd(danmaku: danmaku_Echd, color: color_Echd)
            item_Echd.frame.origin = CGPoint(x: w_Echd + 10, y: yPos_Echd)
            danmakuContainerView_Echd.addSubview(item_Echd)

            UIView.animate(
                withDuration: Double.random(in: 7.0...10.0),
                delay: 0,
                options: [.curveLinear, .allowUserInteraction],
                animations: { item_Echd.frame.origin.x = -(item_Echd.frame.width + 10) },
                completion: { _ in item_Echd.removeFromSuperview() }
            )
        } else {
            // 无帖子时展示占位文本
            let placeholders_Echd = [
                "Be the first to drift a spark ✦",
                "Your moments drift through time 🌊",
                "Share your light with the world 🔥",
                "Every drift starts right here ✨"
            ]
            let label_Echd = UILabel()
            label_Echd.text = placeholders_Echd[danmakuIndex_Echd % placeholders_Echd.count]
            danmakuIndex_Echd += 1
            label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            label_Echd.textColor = color_Echd
            label_Echd.sizeToFit()
            label_Echd.frame = CGRect(x: w_Echd + 10, y: yPos_Echd, width: label_Echd.frame.width, height: 20)
            danmakuContainerView_Echd.addSubview(label_Echd)
            UIView.animate(
                withDuration: Double.random(in: 5.0...8.0),
                delay: 0, options: [.curveLinear],
                animations: { label_Echd.frame.origin.x = -(label_Echd.frame.width + 10) },
                completion: { _ in label_Echd.removeFromSuperview() }
            )
        }
    }

    /// 构建飞行弹幕 Item（文本 + 收藏图标 + 举报图标）
    /// 图标纯视觉展示，通过 item 整体的 UITapGestureRecognizer + presentation 坐标区分操作区域。
    /// - Parameters:
    ///   - danmaku: 独立弹幕数据
    ///   - color: 弹幕文字颜色
    /// - Returns: 飞行 UIView（tag = danmakuId）
    private func buildFlyingItem_Echd(danmaku: DanmakuModel_Echd, color: UIColor) -> UIView {
        let container_Echd = UIView()
        container_Echd.backgroundColor = .clear
        container_Echd.isUserInteractionEnabled = true
        // tag 存储 danmakuId，供 tap 回调查找
        container_Echd.tag = danmaku.danmakuId_Echd

        let textLbl_Echd = UILabel()
        textLbl_Echd.text = String(danmaku.content_Echd.prefix(36))
        textLbl_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        textLbl_Echd.textColor = color
        textLbl_Echd.sizeToFit()
        container_Echd.addSubview(textLbl_Echd)

        let gap_Echd: CGFloat = 8
        let btnSize_Echd: CGFloat = 22
        let itemH_Echd: CGFloat = 28
        let textW_Echd = textLbl_Echd.frame.width

        // 收藏图标（纯视觉，不拦截触摸）
        let isFav_Echd = DanmakuFavVM_Echd.shared_Echd.isDanmakuFavorited_Echd(danmakuId_echd: danmaku.danmakuId_Echd)
        let favIcon_Echd = UIImageView()
        let hCfg_Echd = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        favIcon_Echd.image = UIImage(systemName: isFav_Echd ? "heart.fill" : "heart", withConfiguration: hCfg_Echd)
        favIcon_Echd.tintColor = isFav_Echd ? UIColor(hexstring_Echd: "#F43F5E") : color.withAlphaComponent(0.8)
        favIcon_Echd.contentMode = .scaleAspectFit
        favIcon_Echd.isUserInteractionEnabled = false
        favIcon_Echd.tag = 101   // 用于后续更新图标
        container_Echd.addSubview(favIcon_Echd)

        // 举报图标（纯视觉，不拦截触摸）
        let reportIcon_Echd = UIImageView()
        let rCfg_Echd = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        reportIcon_Echd.image = UIImage(systemName: "flag", withConfiguration: rCfg_Echd)
        reportIcon_Echd.tintColor = color.withAlphaComponent(0.65)
        reportIcon_Echd.contentMode = .scaleAspectFit
        reportIcon_Echd.isUserInteractionEnabled = false
        container_Echd.addSubview(reportIcon_Echd)

        // Frame 布局
        let totalW_Echd = textW_Echd + gap_Echd + btnSize_Echd + gap_Echd + btnSize_Echd
        container_Echd.frame = CGRect(x: 0, y: 0, width: totalW_Echd, height: itemH_Echd)

        textLbl_Echd.frame = CGRect(
            x: 0, y: (itemH_Echd - textLbl_Echd.frame.height) / 2,
            width: textW_Echd, height: textLbl_Echd.frame.height
        )
        favIcon_Echd.frame = CGRect(
            x: textW_Echd + gap_Echd,
            y: (itemH_Echd - btnSize_Echd) / 2,
            width: btnSize_Echd, height: btnSize_Echd
        )
        reportIcon_Echd.frame = CGRect(
            x: textW_Echd + gap_Echd + btnSize_Echd + gap_Echd,
            y: (itemH_Echd - btnSize_Echd) / 2,
            width: btnSize_Echd, height: btnSize_Echd
        )

        // 整体 tap 手势：在 flyingItemTapped_Echd 中根据坐标区分操作区域
        let tap_Echd = UITapGestureRecognizer(target: self, action: #selector(flyingItemTapped_Echd(_:)))
        container_Echd.addGestureRecognizer(tap_Echd)

        return container_Echd
    }

    /// 飞行弹幕 item 被点击时，根据触摸位置相对 presentation frame 的偏移区分操作区域：
    /// - 收藏区（♡）：切换收藏并更新图标（收藏的是弹幕 postId=danmakuId，与帖子收藏独立）
    /// - 举报区（⚑）：弹出确认 Alert，确认后从弹幕数据池删除该条
    @objc private func flyingItemTapped_Echd(_ gesture: UITapGestureRecognizer) {
        guard let item_Echd = gesture.view,
              let presentFrame_Echd = item_Echd.layer.presentation()?.frame else { return }

        let ptInContainer_Echd = gesture.location(in: danmakuContainerView_Echd)
        let localX_Echd = ptInContainer_Echd.x - presentFrame_Echd.origin.x

        let danmakuId_Echd = item_Echd.tag
        guard let danmaku_Echd = danmakuItems_Echd.first(where: { $0.danmakuId_Echd == danmakuId_Echd }) else { return }

        let gap_Echd: CGFloat = 8
        let btnSize_Echd: CGFloat = 22
        let textW_Echd = presentFrame_Echd.width - 2 * (gap_Echd + btnSize_Echd)
        let favMinX_Echd = textW_Echd + gap_Echd
        let favMaxX_Echd = favMinX_Echd + btnSize_Echd
        let reportMinX_Echd = favMaxX_Echd + gap_Echd

        if localX_Echd >= reportMinX_Echd {
            // 举报区：Alert 确认后从弹幕池删除
            reportDanmakuItem_Echd(danmaku: danmaku_Echd)
        } else if localX_Echd >= favMinX_Echd {
            // 收藏区：切换并更新图标
            DanmakuFavVM_Echd.shared_Echd.toggleDanmakuFavorite_Echd(danmakuId_echd: danmaku_Echd.danmakuId_Echd)
            let nowFav_Echd = DanmakuFavVM_Echd.shared_Echd.isDanmakuFavorited_Echd(danmakuId_echd: danmaku_Echd.danmakuId_Echd)
            let hCfg_Echd = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            if let icon_Echd = item_Echd.viewWithTag(101) as? UIImageView {
                icon_Echd.image = UIImage(systemName: nowFav_Echd ? "heart.fill" : "heart", withConfiguration: hCfg_Echd)
                icon_Echd.tintColor = nowFav_Echd ? UIColor(hexstring_Echd: "#F43F5E") : UIColor.white.withAlphaComponent(0.8)
            }
        }
    }

    /// 举报弹幕：弹出确认 Alert，确认后调用 DanmakuFavVM 删除该条弹幕
    /// 举报弹幕：弹出 ActionSheet 前先暂停弹幕流，ActionSheet 关闭后自动恢复。
    /// 举报确认后：刷新数据池 + 移除仍在飞行中的该条弹幕 + 给出反馈提示。
    private func reportDanmakuItem_Echd(danmaku: DanmakuModel_Echd) {
        // 先暂停，再展示 ActionSheet
        pauseDanmakuAnimation_Echd()

        let reportedId_Echd = danmaku.danmakuId_Echd

        ReportDeleteHelper_Echd.reportDanmaku_Echd(
            danmaku_Echd: danmaku,
            from: self,
            completion_Echd: { [weak self] in
                guard let self = self else { return }
                // 1. 从数据池移除
                self.loadDanmakuData_Echd()
                // 2. 淡出并移除仍在飞行的同 ID 弹幕条目
                self.danmakuContainerView_Echd.subviews
                    .filter { $0.tag == reportedId_Echd }
                    .forEach { item_Echd in
                        UIView.animate(withDuration: 0.3,
                                       animations: { item_Echd.alpha = 0 },
                                       completion: { _ in item_Echd.removeFromSuperview() })
                    }
                // 3. 反馈提示
                Utils_Echd.showInfo_Echd(message_Echd: "This spark will no longer appear.")
            }
        )

        // ActionSheet 弹出有动画延迟，先等 0.8 s 后再开始轮询，
        // 避免 presentedViewController 还未赋值就误判为"已关闭"
        pollAlertDismissal_Echd(delay: 0.8)
    }

    /// 轮询检测 ActionSheet 是否已关闭（涵盖"确认"和"取消"两种情形），
    /// 关闭后恢复弹幕动画。
    /// - Parameter delay: 首次检测等待时间（秒），默认 0.8 s
    private func pollAlertDismissal_Echd(delay: TimeInterval = 0.8) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            if self.presentedViewController == nil {
                self.resumeDanmakuAnimation_Echd()
            } else {
                // 每 0.4 s 再次检查，直到 ActionSheet 消失
                self.pollAlertDismissal_Echd(delay: 0.4)
            }
        }
    }

    /// 暂停弹幕发射定时器（现有飞行条目继续滚动至结束）
    private func pauseDanmakuAnimation_Echd() {
        danmakuTimer_Echd?.invalidate()
        danmakuTimer_Echd = nil
    }

    /// 恢复弹幕发射定时器
    private func resumeDanmakuAnimation_Echd() {
        guard danmakuTimer_Echd == nil else { return }
        danmakuTimer_Echd = Timer.scheduledTimer(withTimeInterval: 1.1, repeats: true) { [weak self] _ in
            self?.launchDanmakuItem_Echd()
        }
        launchDanmakuItem_Echd()
    }

    /// 发布弹幕按钮点击：弹出输入框，用户输入内容后发布至 DanmakuFavVM
    @objc private func publishDanmakuTapped_Echd() {
        publishDanmakuButton_Echd.animatePulse_Echd()

        // 未登录时提示并跳转登录
        guard UserViewModel_Echd.shared_Echd.isLoggedIn_Echd else {
            Navigation_Echd.toLogin_Echd(style_echd: .present_echd)
            return
        }

        let alert_Echd = UIAlertController(
            title: "Send a Spark ✦",
            message: "Your spark will drift through the Live Sparks stream.",
            preferredStyle: .alert
        )
        alert_Echd.addTextField { tf_Echd in
            tf_Echd.placeholder = "What's your spark today?"
            tf_Echd.autocorrectionType = .no
        }
        alert_Echd.addAction(UIAlertAction(title: "Send", style: .default) { [weak self, weak alert_Echd] _ in
            guard let self = self,
                  let text_Echd = alert_Echd?.textFields?.first?.text,
                  !text_Echd.trimmingCharacters(in: .whitespaces).isEmpty else { return }

            let currentUser_Echd = UserViewModel_Echd.shared_Echd.getCurrentUser_Echd()
            DanmakuFavVM_Echd.shared_Echd.publishDanmaku_Echd(
                content_echd: text_Echd,
                authorName_echd: currentUser_Echd.userName_Echd ?? "Anonymous",
                authorId_echd: currentUser_Echd.userId_Echd ?? 0
            )
            self.loadDanmakuData_Echd()
        })
        alert_Echd.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert_Echd, animated: true)
    }

    // MARK: - Theme Collections 竖向卡片

    private func buildThemeCards_Echd() {
        themeVerticalStack_Echd.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (idx_Echd, theme_Echd) in DanmakuTheme_Echd.all_Echd.enumerated() {
            themeVerticalStack_Echd.addArrangedSubview(
                buildVerticalThemeCard_Echd(theme: theme_Echd, index: idx_Echd)
            )
        }
    }

    private func buildVerticalThemeCard_Echd(theme: DanmakuTheme_Echd, index: Int) -> UIView {
        // 使用 HomeGradientView_Echd 保证渐变正确显示
        let card_Echd = HomeGradientView_Echd(
            colors: [theme.gradientStart_Echd, theme.gradientEnd_Echd],
            start: CGPoint(x: 0, y: 0.5),
            end: CGPoint(x: 1, y: 0.5)
        )
        card_Echd.layer.cornerRadius = 18
        card_Echd.clipsToBounds = true
        card_Echd.snp.makeConstraints { make in make.height.equalTo(90) }

        let iconIV_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 48, weight: .thin)
        iconIV_Echd.image = UIImage(systemName: theme.icon_Echd, withConfiguration: cfg_Echd)
        iconIV_Echd.tintColor = UIColor.white.withAlphaComponent(0.14)
        iconIV_Echd.contentMode = .scaleAspectFit
        card_Echd.addSubview(iconIV_Echd)

        let titleLbl_Echd = UILabel()
        titleLbl_Echd.text = theme.title_Echd
        titleLbl_Echd.font = UIFont.systemFont(ofSize: 16, weight: .black)
        titleLbl_Echd.textColor = .white
        card_Echd.addSubview(titleLbl_Echd)

        let subLbl_Echd = UILabel()
        subLbl_Echd.text = theme.subtitle_Echd
        subLbl_Echd.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        subLbl_Echd.textColor = UIColor.white.withAlphaComponent(0.78)
        card_Echd.addSubview(subLbl_Echd)

        let posts_Echd = TitleViewModel_Echd.shared_Echd.getPosts_Echd()
        let count_Echd = posts_Echd.filter { $0.titleId_Echd % DanmakuTheme_Echd.all_Echd.count == index }.count
        let cntLbl_Echd = UILabel()
        cntLbl_Echd.text = "\(count_Echd) sparks ›"
        cntLbl_Echd.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        cntLbl_Echd.textColor = UIColor.white.withAlphaComponent(0.85)
        card_Echd.addSubview(cntLbl_Echd)

        iconIV_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(86)
        }
        titleLbl_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.leading.equalToSuperview().offset(18)
            make.trailing.lessThanOrEqualTo(iconIV_Echd.snp.leading).offset(-8)
        }
        subLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(titleLbl_Echd.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(18)
            make.trailing.lessThanOrEqualTo(iconIV_Echd.snp.leading).offset(-8)
        }
        cntLbl_Echd.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-14)
            make.leading.equalToSuperview().offset(18)
        }

        let tap_Echd = UITapGestureRecognizer(target: self, action: #selector(themeCardTapped_Echd(_:)))
        card_Echd.addGestureRecognizer(tap_Echd)
        card_Echd.tag = index
        return card_Echd
    }

    // MARK: - 事件处理

    @objc private func myMomentsTapped_Echd() {
        myMomentsBanner_Echd.animatePressDown_Echd { self.myMomentsBanner_Echd.animatePressUp_Echd() }
        Navigation_Echd.push_Echd(to: MyMoments_Echd())
    }

    @objc private func themeCardTapped_Echd(_ gesture: UITapGestureRecognizer) {
        guard let card_Echd = gesture.view,
              card_Echd.tag < DanmakuTheme_Echd.all_Echd.count else { return }
        let theme_Echd = DanmakuTheme_Echd.all_Echd[card_Echd.tag]
        card_Echd.animatePressDown_Echd { card_Echd.animatePressUp_Echd() }
        Navigation_Echd.push_Echd(to: ThemeCollection_Echd(theme: theme_Echd, themeIndex: card_Echd.tag))
    }

    // MARK: - 通知监听

    private func observeNotifications_Echd() {
        // 监听弹幕数据变化（新发布 / 删除）刷新 Live Sparks
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleDataChange_Echd),
            name: DanmakuFavVM_Echd.danmakuChangedNotification_Echd, object: nil
        )
    }

    @objc private func handleDataChange_Echd() { loadDanmakuData_Echd() }
}
