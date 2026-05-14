import Foundation
import UIKit
import SnapKit

// MARK: 我的时光页
// 设计思路：
//   顶部渐变 Header（玫瑰粉-琥珀渐变，区分主色调），自定义三段选择器；
//   三个内容屏：
//     - Published（已发布）：当前用户发布的弹幕卡片列表，可举报/删除
//     - Favorites（已收藏）：从 DanmakuFavVM 读取收藏列表，可取消收藏
//     - Timeline（时光轨迹）：以时间轴形式可视化个人弹幕历程，
//       左侧竖线+彩色圆点，右侧帖子卡片，呈现时间印记感
// 逻辑与数据分别由 TitleViewModel / DanmakuFavVM / UserViewModel 提供。

/// 我的时光页视图控制器
class MyMoments_Echd: UIViewController {

    // MARK: - 私有属性

    /// 当前选中 Tab 索引（0=Published 1=Favorites 2=Timeline）
    private var selectedTab_Echd: Int = 0

    // MARK: - UI组件 / Header

    /// 使用自动同步 frame 的渐变视图，确保 Header 颜色始终正确
    private let headerView_Echd: UIView = {
        final class _GradView: UIView {
            private let g = CAGradientLayer()
            override init(frame: CGRect) {
                super.init(frame: frame)
                g.colors = [UIColor(hexstring_Echd: "#EC4899").cgColor, UIColor(hexstring_Echd: "#F59E0B").cgColor]
                g.startPoint = CGPoint(x: 0, y: 0.5); g.endPoint = CGPoint(x: 1, y: 0.5)
                layer.insertSublayer(g, at: 0)
            }
            required init?(coder: NSCoder) { fatalError() }
            override func layoutSubviews() { super.layoutSubviews(); g.frame = bounds }
        }
        let v = _GradView(); v.clipsToBounds = true; return v
    }()
    // headerGradient_Echd 已由 _GradView 自动管理，保留变量占位以免编译报错
    private var headerGradient_Echd: CAGradientLayer?

    private let backButton_Echd = BackButton_Echd()

    private let pageTitleLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "My Moments"
        label_Echd.font = UIFont.systemFont(ofSize: 26, weight: .black)
        label_Echd.textColor = .white
        return label_Echd
    }()

    private let pageSubLabel_Echd: UILabel = {
        let label_Echd = UILabel()
        label_Echd.text = "Capture every spark of your life ✦"
        label_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        label_Echd.textColor = UIColor.white.withAlphaComponent(0.78)
        return label_Echd
    }()

    private let headerDecoIcon_Echd: UIImageView = {
        let iv_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 46, weight: .thin)
        iv_Echd.image = UIImage(systemName: "clock.arrow.circlepath", withConfiguration: cfg_Echd)
        iv_Echd.tintColor = UIColor.white.withAlphaComponent(0.12)
        iv_Echd.contentMode = .scaleAspectFit
        return iv_Echd
    }()

    // MARK: - UI组件 / 分段选择器

    private let segContainer_Echd: UIView = {
        let view_Echd = UIView()
        view_Echd.backgroundColor = .white
        view_Echd.layer.cornerRadius = 18
        // 阴影使用极小值，防止大 shadowRadius 投射进 scrollView 区域产生椭圆 artifact
        view_Echd.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        view_Echd.layer.shadowOffset = CGSize(width: 0, height: 2)
        view_Echd.layer.shadowRadius = 4
        view_Echd.layer.shadowOpacity = 1
        return view_Echd
    }()

    private let tabPublished_Echd: UIButton = makeSegBtn_Echd(title: "Published")
    private let tabFavorites_Echd: UIButton = makeSegBtn_Echd(title: "Favorites")
    private let tabTimeline_Echd: UIButton = makeSegBtn_Echd(title: "Timeline")

    private static func makeSegBtn_Echd(title: String) -> UIButton {
        let btn_Echd = UIButton(type: .custom)
        btn_Echd.setTitle(title, for: .normal)
        btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        return btn_Echd
    }

    // MARK: - UI组件 / 内容区

    private let scrollView_Echd: UIScrollView = {
        let sv_Echd = UIScrollView()
        sv_Echd.showsVerticalScrollIndicator = false
        sv_Echd.alwaysBounceVertical = true
        return sv_Echd
    }()

    private let contentView_Echd = UIView()
    private let cardsStack_Echd: UIStackView = {
        let sv_Echd = UIStackView()
        sv_Echd.axis = .vertical
        sv_Echd.spacing = 14
        return sv_Echd
    }()

    // MARK: - 生命周期

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        refreshContent_Echd()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hexstring_Echd: "#F8F7FF")
        setupUI_Echd()
        setupConstraints_Echd()
        updateSegUI_Echd(animated: false)
        observeNotifications_Echd()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerGradient_Echd?.frame = headerView_Echd.bounds
        applyHeaderArc_Echd()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - UI设置

    private func setupUI_Echd() {
        // Header（渐变由 _GradView.layoutSubviews 自动维护，无需手动设置 frame）
        view.addSubview(headerView_Echd)
        headerView_Echd.addSubview(pageTitleLabel_Echd)
        headerView_Echd.addSubview(pageSubLabel_Echd)
        headerView_Echd.addSubview(headerDecoIcon_Echd)

        view.addSubview(backButton_Echd)
        backButton_Echd.onTapped_Echd = { Navigation_Echd.pop_Echd() }

        // 分段选择器（无独立滑块视图，选中态直接由按钮背景色体现）
        view.addSubview(segContainer_Echd)
        segContainer_Echd.addSubview(tabPublished_Echd)
        segContainer_Echd.addSubview(tabFavorites_Echd)
        segContainer_Echd.addSubview(tabTimeline_Echd)

        tabPublished_Echd.tag = 0
        tabFavorites_Echd.tag = 1
        tabTimeline_Echd.tag = 2
        [tabPublished_Echd, tabFavorites_Echd, tabTimeline_Echd].forEach {
            $0.addTarget(self, action: #selector(segTapped_Echd(_:)), for: .touchUpInside)
        }

        // 内容滚动区
        view.addSubview(scrollView_Echd)
        scrollView_Echd.addSubview(contentView_Echd)
        contentView_Echd.addSubview(cardsStack_Echd)
    }

    private func applyHeaderArc_Echd() {
        let w_Echd = headerView_Echd.bounds.width
        let h_Echd = headerView_Echd.bounds.height
        let path_Echd = UIBezierPath()
        path_Echd.move(to: .zero)
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: 0))
        path_Echd.addLine(to: CGPoint(x: w_Echd, y: h_Echd - 18))
        path_Echd.addQuadCurve(
            to: CGPoint(x: 0, y: h_Echd - 18),
            controlPoint: CGPoint(x: w_Echd / 2, y: h_Echd + 18)
        )
        path_Echd.close()
        let mask_Echd = CAShapeLayer(); mask_Echd.path = path_Echd.cgPath
        headerView_Echd.layer.mask = mask_Echd
    }

    // MARK: - 约束

    private func setupConstraints_Echd() {
        let sw_Echd = UIScreen.main.bounds.width
        let segW_Echd = (sw_Echd - 32 - 8) / 3

        headerView_Echd.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(130)
        }
        backButton_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(44)
        }
        pageTitleLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.leading.equalTo(backButton_Echd.snp.trailing).offset(8)
            make.trailing.lessThanOrEqualTo(headerDecoIcon_Echd.snp.leading).offset(-10)
        }
        pageSubLabel_Echd.snp.makeConstraints { make in
            make.top.equalTo(pageTitleLabel_Echd.snp.bottom).offset(4)
            make.leading.equalTo(backButton_Echd.snp.trailing).offset(8)
        }
        headerDecoIcon_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(8)
            make.width.height.equalTo(110)
        }

        segContainer_Echd.snp.makeConstraints { make in
            make.top.equalTo(headerView_Echd.snp.bottom).offset(14)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(46)
        }
        tabPublished_Echd.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(4)
            make.width.equalTo(segW_Echd)
        }
        tabFavorites_Echd.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(4)
            make.width.equalTo(segW_Echd)
        }
        tabTimeline_Echd.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview().inset(4)
            make.width.equalTo(segW_Echd)
        }

        scrollView_Echd.snp.makeConstraints { make in
            make.top.equalTo(segContainer_Echd.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(sw_Echd)
        }
        cardsStack_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 分段选择器样式更新

    /// 切换分段按钮选中态：选中 = 玫瑰粉背景 + 白色粗体，未选中 = 透明背景 + 灰色常规体
    /// 不使用独立滑块视图，彻底规避 layoutIfNeeded 在 viewDidLoad 阶段的 artifact 问题
    private func updateSegUI_Echd(animated: Bool) {
        let block_Echd = {
            let btns_Echd = [self.tabPublished_Echd, self.tabFavorites_Echd, self.tabTimeline_Echd]
            for (i_Echd, btn_Echd) in btns_Echd.enumerated() {
                let sel_Echd = i_Echd == self.selectedTab_Echd
                btn_Echd.backgroundColor = sel_Echd ? UIColor(hexstring_Echd: "#EC4899") : .clear
                btn_Echd.setTitleColor(sel_Echd ? .white : UIColor(hexstring_Echd: "#6B7280"), for: .normal)
                btn_Echd.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: sel_Echd ? .bold : .medium)
                btn_Echd.layer.cornerRadius = sel_Echd ? 14 : 0
            }
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: block_Echd)
        } else {
            block_Echd()
        }
    }

    // MARK: - 内容刷新

    private func refreshContent_Echd() {
        cardsStack_Echd.arrangedSubviews.forEach { $0.removeFromSuperview() }
        switch selectedTab_Echd {
        case 0: buildPublishedContent_Echd()
        case 1: buildFavoritesContent_Echd()
        default: buildTimelineContent_Echd()
        }
    }

    // MARK: Published — 我发布的弹幕，右上角删除按钮

    private func buildPublishedContent_Echd() {
        let list_Echd = DanmakuFavVM_Echd.shared_Echd.getMyPublishedDanmaku_Echd()
        if list_Echd.isEmpty {
            cardsStack_Echd.addArrangedSubview(buildEmpty_Echd(text: "You haven't sent any sparks yet.\nTap \"Send Spark\" to start drifting! ✦"))
            return
        }
        let accents_Echd: [UIColor] = [
            UIColor(hexstring_Echd: "#7C3AED"), UIColor(hexstring_Echd: "#EC4899"),
            UIColor(hexstring_Echd: "#6366F1"), UIColor(hexstring_Echd: "#F59E0B")
        ]
        for (idx_Echd, item_Echd) in list_Echd.enumerated() {
            cardsStack_Echd.addArrangedSubview(
                buildDanmakuCard_Echd(danmaku: item_Echd,
                                       accent: accents_Echd[idx_Echd % accents_Echd.count],
                                       actionType: .delete_Echd)
            )
        }
    }

    // MARK: Favorites — 我收藏的弹幕，右上角举报按钮

    private func buildFavoritesContent_Echd() {
        let list_Echd = DanmakuFavVM_Echd.shared_Echd.getFavoritedDanmaku_Echd()
        if list_Echd.isEmpty {
            cardsStack_Echd.addArrangedSubview(buildEmpty_Echd(text: "No favorites yet.\nTap ♡ on sparks you love! ✨"))
            return
        }
        for (idx_Echd, item_Echd) in list_Echd.enumerated() {
            let accent_Echd = UIColor(hexstring_Echd: idx_Echd % 2 == 0 ? "#F43F5E" : "#EC4899")
            cardsStack_Echd.addArrangedSubview(
                buildDanmakuCard_Echd(danmaku: item_Echd,
                                       accent: accent_Echd,
                                       actionType: .report_Echd)
            )
        }
    }

    // MARK: Timeline — 我发布 + 我收藏的弹幕合并，图标可视化时间轴

    private func buildTimelineContent_Echd() {
        let items_Echd = DanmakuFavVM_Echd.shared_Echd.getTimelineData_Echd()
        if items_Echd.isEmpty {
            cardsStack_Echd.addArrangedSubview(buildEmpty_Echd(text: "Your timeline is empty.\nSend or favorite sparks to begin ✦"))
            return
        }

        // 顶部图例说明
        let legend_Echd = buildTimelineLegend_Echd()
        cardsStack_Echd.addArrangedSubview(legend_Echd)

        for (idx_Echd, tuple_Echd) in items_Echd.enumerated() {
            let isLast_Echd = idx_Echd == items_Echd.count - 1
            cardsStack_Echd.addArrangedSubview(
                buildTimelineItem_Echd(danmaku: tuple_Echd.0, isPublished: tuple_Echd.1, isLast: isLast_Echd)
            )
        }
    }

    /// 时间轴图例（Published = pencil/purple，Favorited = heart/rose）
    /// 时光轨迹图例横幅
    /// 设计：极浅紫背景卡片，左侧标题 + 右侧两个彩色徽章（Sent / Saved）
    private func buildTimelineLegend_Echd() -> UIView {
        let banner_Echd = UIView()
        banner_Echd.backgroundColor = UIColor(hexstring_Echd: "#EDE9FE")   // 极浅紫
        banner_Echd.layer.cornerRadius = 14

        // 左侧标题行（图标 + 文字）
        let titleIcon_Echd = UIImageView()
        let tiCfg_Echd = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        titleIcon_Echd.image = UIImage(systemName: "sparkles", withConfiguration: tiCfg_Echd)
        titleIcon_Echd.tintColor = UIColor(hexstring_Echd: "#7C3AED")
        banner_Echd.addSubview(titleIcon_Echd)

        let titleLbl_Echd = UILabel()
        titleLbl_Echd.text = "Your Spark Journey"
        titleLbl_Echd.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        titleLbl_Echd.textColor = UIColor(hexstring_Echd: "#7C3AED")
        banner_Echd.addSubview(titleLbl_Echd)

        // 右侧图例徽章栈
        let pillStack_Echd = UIStackView()
        pillStack_Echd.axis = .horizontal
        pillStack_Echd.spacing = 8
        pillStack_Echd.alignment = .center
        banner_Echd.addSubview(pillStack_Echd)

        for (icon_Echd, color_Echd, text_Echd) in [
            ("pencil.circle.fill", UIColor(hexstring_Echd: "#7C3AED"), "Sent"),
            ("heart.circle.fill",  UIColor(hexstring_Echd: "#F43F5E"), "Saved")
        ] {
            // 徽章容器
            let pill_Echd = UIView()
            pill_Echd.backgroundColor = color_Echd.withAlphaComponent(0.12)
            pill_Echd.layer.cornerRadius = 12

            let iv_Echd = UIImageView()
            let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
            iv_Echd.image = UIImage(systemName: icon_Echd, withConfiguration: cfg_Echd)
            iv_Echd.tintColor = color_Echd

            let lbl_Echd = UILabel()
            lbl_Echd.text = text_Echd
            lbl_Echd.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
            lbl_Echd.textColor = color_Echd

            let row_Echd = UIStackView(arrangedSubviews: [iv_Echd, lbl_Echd])
            row_Echd.spacing = 4
            row_Echd.alignment = .center
            pill_Echd.addSubview(row_Echd)

            // row 约束（相对于 pill）
            row_Echd.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(5)
                make.leading.trailing.equalToSuperview().inset(9)
            }
            pillStack_Echd.addArrangedSubview(pill_Echd)
        }

        // banner 内部约束
        titleIcon_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.centerY.equalTo(titleLbl_Echd)
            make.width.height.equalTo(16)
        }
        titleLbl_Echd.snp.makeConstraints { make in
            make.leading.equalTo(titleIcon_Echd.snp.trailing).offset(6)
            make.top.equalToSuperview().offset(14)
        }
        pillStack_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalTo(titleLbl_Echd.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-14)
        }

        return banner_Echd
    }

    /// 构建时间轴单项（弹幕 + 类型图标 + 时间）
    /// - Parameters:
    ///   - danmaku: 弹幕数据
    ///   - isPublished: true=我发布（紫色 pencil），false=我收藏（玫瑰红 heart）
    ///   - isLast: 是否最后一项（最后一项不绘制竖线）
    private func buildTimelineItem_Echd(danmaku: DanmakuModel_Echd, isPublished: Bool, isLast: Bool) -> UIView {
        let dotColor_Echd = isPublished
            ? UIColor(hexstring_Echd: "#7C3AED")
            : UIColor(hexstring_Echd: "#F43F5E")
        let iconName_Echd = isPublished ? "pencil.circle.fill" : "heart.circle.fill"
        let typeLabel_Echd = isPublished ? "Sent" : "Saved"

        let wrap_Echd = UIView()

        // 竖线
        let line_Echd = UIView()
        line_Echd.backgroundColor = isLast ? .clear : UIColor(hexstring_Echd: "#E5E7EB")
        wrap_Echd.addSubview(line_Echd)

        // 类型图标圆点
        let iconIV_Echd = UIImageView()
        let cfg_Echd = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconIV_Echd.image = UIImage(systemName: iconName_Echd, withConfiguration: cfg_Echd)
        iconIV_Echd.tintColor = dotColor_Echd
        iconIV_Echd.backgroundColor = UIColor.white
        iconIV_Echd.layer.cornerRadius = 12
        iconIV_Echd.contentMode = .scaleAspectFit
        wrap_Echd.addSubview(iconIV_Echd)

        // 类型标签 + 时间
        let date_Echd = Date(timeIntervalSince1970: danmaku.timestamp_Echd)
        let fmt_Echd = DateFormatter()
        fmt_Echd.dateFormat = "yyyy.MM.dd"
        let timeLbl_Echd = UILabel()
        timeLbl_Echd.text = "\(typeLabel_Echd)  \(fmt_Echd.string(from: date_Echd))"
        timeLbl_Echd.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        timeLbl_Echd.textColor = dotColor_Echd
        wrap_Echd.addSubview(timeLbl_Echd)

        // 内容卡片
        let card_Echd = UIView()
        card_Echd.backgroundColor = .white
        card_Echd.layer.cornerRadius = 14
        card_Echd.layer.shadowColor = dotColor_Echd.withAlphaComponent(0.15).cgColor
        card_Echd.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Echd.layer.shadowRadius = 10
        card_Echd.layer.shadowOpacity = 1
        wrap_Echd.addSubview(card_Echd)

        let bar_Echd = UIView()
        bar_Echd.backgroundColor = dotColor_Echd
        bar_Echd.layer.cornerRadius = 2
        card_Echd.addSubview(bar_Echd)

        let contentLbl_Echd = UILabel()
        contentLbl_Echd.text = danmaku.content_Echd
        contentLbl_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        contentLbl_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        contentLbl_Echd.numberOfLines = 2
        card_Echd.addSubview(contentLbl_Echd)

        let authorLbl_Echd = UILabel()
        authorLbl_Echd.text = "— \(danmaku.authorName_Echd)"
        authorLbl_Echd.font = UIFont.systemFont(ofSize: 11)
        authorLbl_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        card_Echd.addSubview(authorLbl_Echd)

        // 约束
        iconIV_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(24)
        }
        line_Echd.snp.makeConstraints { make in
            make.centerX.equalTo(iconIV_Echd)
            make.top.equalTo(iconIV_Echd.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(2)
        }
        timeLbl_Echd.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_Echd.snp.trailing).offset(10)
            make.centerY.equalTo(iconIV_Echd)
        }
        card_Echd.snp.makeConstraints { make in
            make.leading.equalTo(iconIV_Echd.snp.trailing).offset(10)
            make.top.equalTo(timeLbl_Echd.snp.bottom).offset(6)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
        }
        bar_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(4)
        }
        contentLbl_Echd.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        authorLbl_Echd.snp.makeConstraints { make in
            make.top.equalTo(contentLbl_Echd.snp.bottom).offset(4)
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        return wrap_Echd
    }

    // MARK: - 弹幕卡片（已发布 / 已收藏通用）

    /// 操作类型枚举：发布项显示删除按钮，收藏项显示举报按钮
    private enum DanmakuCardAction_Echd { case delete_Echd, report_Echd }

    /// 构建弹幕卡片
    /// - Parameters:
    ///   - danmaku: 弹幕数据
    ///   - accent: 卡片主调色
    ///   - actionType: 右上角按钮类型（delete=删除，report=举报）
    private func buildDanmakuCard_Echd(danmaku: DanmakuModel_Echd,
                                        accent: UIColor,
                                        actionType: DanmakuCardAction_Echd) -> UIView {
        let card_Echd = UIView()
        card_Echd.backgroundColor = .white
        card_Echd.layer.cornerRadius = 16
        card_Echd.layer.shadowColor = accent.withAlphaComponent(0.18).cgColor
        card_Echd.layer.shadowOffset = CGSize(width: 0, height: 4)
        card_Echd.layer.shadowRadius = 12
        card_Echd.layer.shadowOpacity = 1
        card_Echd.clipsToBounds = false

        let bar_Echd = UIView()
        bar_Echd.backgroundColor = accent
        bar_Echd.layer.cornerRadius = 2.5
        card_Echd.addSubview(bar_Echd)

        let sparkIcon_Echd = UILabel()
        sparkIcon_Echd.text = "►"
        sparkIcon_Echd.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        sparkIcon_Echd.textColor = accent
        card_Echd.addSubview(sparkIcon_Echd)

        let contentLbl_Echd = UILabel()
        contentLbl_Echd.text = danmaku.content_Echd
        contentLbl_Echd.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        contentLbl_Echd.textColor = UIColor(hexstring_Echd: "#1F2937")
        contentLbl_Echd.numberOfLines = 3
        card_Echd.addSubview(contentLbl_Echd)

        let authorLbl_Echd = UILabel()
        let fmt_Echd = DateFormatter(); fmt_Echd.dateFormat = "MM/dd"
        let dateStr_Echd = fmt_Echd.string(from: Date(timeIntervalSince1970: danmaku.timestamp_Echd))
        authorLbl_Echd.text = "— \(danmaku.authorName_Echd)  ·  \(dateStr_Echd)"
        authorLbl_Echd.font = UIFont.systemFont(ofSize: 11)
        authorLbl_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        card_Echd.addSubview(authorLbl_Echd)

        // 右上角操作按钮（删除 or 举报）
        let actionBtn_Echd = UIButton(type: .system)
        let btnIconName_Echd = actionType == .delete_Echd ? "trash" : "ellipsis"
        let btnCfg_Echd = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        actionBtn_Echd.setImage(UIImage(systemName: btnIconName_Echd, withConfiguration: btnCfg_Echd), for: .normal)
        actionBtn_Echd.tintColor = actionType == .delete_Echd
            ? UIColor(hexstring_Echd: "#EF4444")
            : UIColor(hexstring_Echd: "#9CA3AF")
        actionBtn_Echd.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            if actionType == .delete_Echd {
                ReportDeleteHelper_Echd.deleteDanmaku_Echd(
                    danmaku_Echd: danmaku, from: self,
                    completion_Echd: { self.refreshContent_Echd() }
                )
            } else {
                ReportDeleteHelper_Echd.reportDanmaku_Echd(
                    danmaku_Echd: danmaku, from: self,
                    completion_Echd: {
                        DanmakuFavVM_Echd.shared_Echd.toggleDanmakuFavorite_Echd(danmakuId_echd: danmaku.danmakuId_Echd)
                        self.refreshContent_Echd()
                    }
                )
            }
        }, for: .touchUpInside)
        card_Echd.addSubview(actionBtn_Echd)

        // 约束
        bar_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(14)
            make.top.equalToSuperview().offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.width.equalTo(4)
        }
        actionBtn_Echd.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.width.height.equalTo(28)
        }
        sparkIcon_Echd.snp.makeConstraints { make in
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(16)
        }
        contentLbl_Echd.snp.makeConstraints { make in
            make.leading.equalTo(sparkIcon_Echd.snp.trailing).offset(6)
            make.top.equalToSuperview().offset(14)
            make.trailing.equalTo(actionBtn_Echd.snp.leading).offset(-6)
        }
        authorLbl_Echd.snp.makeConstraints { make in
            make.leading.equalTo(bar_Echd.snp.trailing).offset(10)
            make.top.equalTo(contentLbl_Echd.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-14)
        }
        return card_Echd
    }

    private func buildEmpty_Echd(text: String) -> UIView {
        let wrap_Echd = UIView()
        let lbl_Echd = UILabel()
        lbl_Echd.text = text
        lbl_Echd.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        lbl_Echd.textColor = UIColor(hexstring_Echd: "#9CA3AF")
        lbl_Echd.textAlignment = .center
        lbl_Echd.numberOfLines = 0
        wrap_Echd.addSubview(lbl_Echd)
        lbl_Echd.snp.makeConstraints { make in make.edges.equalToSuperview().inset(20) }
        return wrap_Echd
    }

    // MARK: - 事件处理

    @objc private func segTapped_Echd(_ sender: UIButton) {
        guard sender.tag != selectedTab_Echd else { return }
        selectedTab_Echd = sender.tag
        updateSegUI_Echd(animated: true)
        refreshContent_Echd()
    }

    // MARK: - 通知监听

    private func observeNotifications_Echd() {
        [DanmakuFavVM_Echd.danmakuChangedNotification_Echd,
         DanmakuFavVM_Echd.favChangedNotification_Echd].forEach {
            NotificationCenter.default.addObserver(
                self, selector: #selector(handleDataChange_Echd), name: $0, object: nil
            )
        }
    }

    @objc private func handleDataChange_Echd() { refreshContent_Echd() }
}
