import Foundation
import UIKit
import SnapKit

// MARK: 发现页 - 沉浸式时尚瀑布流

/// 发现页控制器
/// 功能：以不规则瀑布流方式展示所有时尚帖子，支持举报/删除，点击进入详情
/// 设计：精致导航栏（渐变竖条 + 动态帖子数）+ 沉浸式全图卡片（底部渐变蒙层）
///       五档交错高度制造丰富视觉节奏，卡片带紫调阴影强化时尚质感
class Discover_Vestir: UIViewController {

    // MARK: - 私有属性

    /// 帖子数据列表
    private var posts_Vestir: [TitleModel_Vestir] = []

    // MARK: - 导航栏组件

    /// 自定义导航栏容器
    private let navBar_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.backgroundSecondary_Vestir
        return v_Vestir
    }()

    /// 左侧渐变装饰竖条（主渐变色，强化品牌感）
    private let navAccentBar_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 2.5
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    /// 主标题 "Discover"
    private let navTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Discover"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    /// 副标题（动态展示帖子数量）
    private let navSubtitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        lbl_Vestir.textColor = ColorConfig_Vestir.textSecondary_Vestir
        return lbl_Vestir
    }()

    /// 右侧装饰符号（使用主渐变色营造精致感）
    private let navSparkleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "✦"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 20)
        lbl_Vestir.textColor = ColorConfig_Vestir.primaryGradientStart_Vestir
        return lbl_Vestir
    }()

    /// 导航栏底部渐变分隔线（紫→粉→透明，横向渐变）
    private let navBottomLine_Vestir: UIView = {
        let v_Vestir = UIView()
        return v_Vestir
    }()

    // MARK: - 集合视图

    /// 瀑布流集合视图
    private lazy var collectionView_Vestir: UICollectionView = {
        let layout_Vestir = WaterfallLayout_Vestir()
        layout_Vestir.delegate = self
        layout_Vestir.numberOfColumns_Vestir = 2
        layout_Vestir.minimumInteritemSpacing_Vestir = 10
        layout_Vestir.minimumLineSpacing_Vestir = 12
        layout_Vestir.sectionInset_Vestir = UIEdgeInsets(top: 14, left: 14, bottom: 100, right: 14)
        // 386pt = 14(顶) + 158(banner) + 16(间距) + 20(趋势标题) + 10(间距) + 84(标签云)
        //       + 16(间距) + 28(帖子描述行) + 8(间距) + 1.5(分隔线) + 10(底边距) ≈ 386pt
        layout_Vestir.headerHeight_Vestir = 386

        let cv_Vestir = UICollectionView(frame: .zero, collectionViewLayout: layout_Vestir)
        cv_Vestir.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir
        cv_Vestir.showsVerticalScrollIndicator = false
        cv_Vestir.register(
            DiscoverCell_Vestir.self,
            forCellWithReuseIdentifier: DiscoverCell_Vestir.reuseId_Vestir
        )
        cv_Vestir.register(
            DiscoverHeaderView_Vestir.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: DiscoverHeaderView_Vestir.reuseId_Vestir
        )
        return cv_Vestir
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Vestir()
        setupConstraints_Vestir()
        bindNotifications_Vestir()
        loadData_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        loadData_Vestir()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 布局完成后刷新渐变图层尺寸
        refreshNavGradients_Vestir()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - UI 搭建

    /// 搭建视图层级
    private func setupUI_Vestir() {
        view.backgroundColor = ColorConfig_Vestir.backgroundPrimary_Vestir

        view.addSubview(navBar_Vestir)
        navBar_Vestir.addSubview(navAccentBar_Vestir)
        navBar_Vestir.addSubview(navTitleLabel_Vestir)
        navBar_Vestir.addSubview(navSubtitleLabel_Vestir)
        navBar_Vestir.addSubview(navSparkleLabel_Vestir)
        navBar_Vestir.addSubview(navBottomLine_Vestir)
        view.addSubview(collectionView_Vestir)

        collectionView_Vestir.dataSource = self
        collectionView_Vestir.delegate = self

        // 导航栏使用紫调阴影，增强时尚感
        navBar_Vestir.layer.shadowColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
        navBar_Vestir.layer.shadowOpacity = 0.10
        navBar_Vestir.layer.shadowOffset = CGSize(width: 0, height: 4)
        navBar_Vestir.layer.shadowRadius = 12
    }

    /// 配置 AutoLayout 约束
    private func setupConstraints_Vestir() {
        navBar_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(view.safeAreaInsets.top + 78)
        }

        // 左侧装饰竖条：与标题等高，宽 4pt，左边距 20pt
        navAccentBar_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalTo(navTitleLabel_Vestir)
            make.width.equalTo(4)
            make.height.equalTo(30)
        }

        navTitleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(navAccentBar_Vestir.snp.trailing).offset(10)
            make.bottom.equalToSuperview().offset(-20)
        }

        navSubtitleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(navTitleLabel_Vestir)
            make.top.equalTo(navTitleLabel_Vestir.snp.bottom).offset(2)
            make.bottom.lessThanOrEqualToSuperview().offset(-5)
        }

        navSparkleLabel_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-22)
            make.centerY.equalTo(navTitleLabel_Vestir)
        }

        // 底部渐变分隔线，高 1.5pt
        navBottomLine_Vestir.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(1.5)
        }

        collectionView_Vestir.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        navBar_Vestir.snp.updateConstraints { make in
            make.height.equalTo(view.safeAreaInsets.top + 78)
        }
    }

    // MARK: - 渐变刷新

    /// 刷新导航栏的渐变装饰图层（布局后调用以获取正确尺寸）
    private func refreshNavGradients_Vestir() {
        // 左侧竖条：主渐变色（紫→蓝，纵向）
        navAccentBar_Vestir.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        guard navAccentBar_Vestir.bounds.width > 0 else { return }

        let accentGrad_Vestir = CAGradientLayer()
        accentGrad_Vestir.frame = navAccentBar_Vestir.bounds
        accentGrad_Vestir.colors = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor
        ]
        accentGrad_Vestir.startPoint = CGPoint(x: 0.5, y: 0)
        accentGrad_Vestir.endPoint = CGPoint(x: 0.5, y: 1)
        accentGrad_Vestir.cornerRadius = 2.5
        navAccentBar_Vestir.layer.insertSublayer(accentGrad_Vestir, at: 0)

        // 底部分隔线：暖调渐变（蜜桃粉→橙金→透明，横向）
        navBottomLine_Vestir.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        guard navBottomLine_Vestir.bounds.width > 0 else { return }

        let lineGrad_Vestir = UIColor.createWarmGradientLayer_Vestir(
            frame_Vestir: navBottomLine_Vestir.bounds
        )
        navBottomLine_Vestir.layer.addSublayer(lineGrad_Vestir)
    }

    // MARK: - 数据加载

    /// 从 TitleViewModel 拉取帖子列表并刷新视图
    private func loadData_Vestir() {
        posts_Vestir = TitleViewModel_Vestir.shared_Vestir.getPosts_Vestir()
        // 动态更新副标题显示帖子总数
        let count_Vestir = posts_Vestir.count
        navSubtitleLabel_Vestir.text = count_Vestir > 0
            ? "\(count_Vestir) styles to explore ✦"
            : "Find your style inspo"
        collectionView_Vestir.reloadData()
    }

    /// 注册帖子状态与用户状态通知，数据变更时自动刷新列表
    private func bindNotifications_Vestir() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Vestir),
            name: TitleViewModel_Vestir.titleStateDidChangeNotification_Vestir,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onDataChanged_Vestir),
            name: UserViewModel_Vestir.userStateDidChangeNotification_Vestir,
            object: nil
        )
    }

    @objc private func onDataChanged_Vestir() {
        loadData_Vestir()
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension Discover_Vestir: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts_Vestir.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell_Vestir = collectionView.dequeueReusableCell(
            withReuseIdentifier: DiscoverCell_Vestir.reuseId_Vestir,
            for: indexPath
        ) as? DiscoverCell_Vestir else {
            return UICollectionViewCell()
        }
        let post_Vestir = posts_Vestir[indexPath.item]
        cell_Vestir.configure_Vestir(
            post_vestir: post_Vestir,
            index_vestir: indexPath.item,
            viewController_Vestir: self
        ) { [weak self] in
            self?.loadData_Vestir()
        }
        // 点击作者头像/用户名区域 → 跳转用户中心
        cell_Vestir.onAuthorTapped_Vestir = { userId_Vestir in
            let userModel_Vestir = UserViewModel_Vestir.shared_Vestir.getUserById_Vestir(
                userId_vestir: userId_Vestir
            )
            let userInfoVC_Vestir = UserInfo_Vestir()
            userInfoVC_Vestir.userModel_Vestir = userModel_Vestir
            Navigation_Vestir.push_Vestir(to: userInfoVC_Vestir)
        }
        return cell_Vestir
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_Vestir = posts_Vestir[indexPath.item]
        if let cell_Vestir = collectionView.cellForItem(at: indexPath) {
            cell_Vestir.animatePressDown_Vestir {
                cell_Vestir.animatePressUp_Vestir {
                    Navigation_Vestir.toTitleDetail_Vestir(titleModel_vestir: post_Vestir)
                }
            }
        } else {
            Navigation_Vestir.toTitleDetail_Vestir(titleModel_vestir: post_Vestir)
        }
    }

    /// 卡片入场动画：向上位移 + 缩放淡入，以交错延迟营造瀑布流动感
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 24)
            .scaledBy(x: 0.94, y: 0.94)

        UIView.animate(
            withDuration: 0.42,
            delay: Double(indexPath.item % 8) * 0.045,
            usingSpringWithDamping: 0.82,
            initialSpringVelocity: 0.3,
            options: .curveEaseOut
        ) {
            cell.alpha = 1
            cell.transform = .identity
        }
    }

    /// 提供 Section Header 视图并传入当前帖子数据
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let header_Vestir = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: DiscoverHeaderView_Vestir.reuseId_Vestir,
                for: indexPath
            ) as? DiscoverHeaderView_Vestir
        else {
            return UICollectionReusableView()
        }
        header_Vestir.configure_Vestir(posts_vestir: posts_Vestir)
        return header_Vestir
    }
}

// MARK: - WaterfallLayoutDelegate

extension Discover_Vestir: WaterfallLayoutDelegate_Vestir {

    /// 返回帖子卡片高度
    /// 五档高度交替循环，形成不规则、有节奏的瀑布流排列
    func collectionView_Vestir(
        _ collectionView: UICollectionView,
        heightForItemAt_Vestir indexPath: IndexPath,
        withWidth_Vestir width: CGFloat
    ) -> CGFloat {
        // 五档高度产生丰富的视觉节奏
        let heights_Vestir: [CGFloat] = [280, 200, 255, 185, 265]
        return heights_Vestir[indexPath.item % heights_Vestir.count]
    }
}

// MARK: - 发现页沉浸式卡片 Cell

/// 发现页帖子卡片 Cell
/// 功能：沉浸式全图展示媒体，底部渐变蒙层承载作者信息与点赞数
/// 设计亮点：
///   • 8 种时尚渐变色板循环赋予占位图多样视觉
///   • 顶部光泽层 + 底部三段渐变蒙层营造立体深度
///   • 横向渐变标签徽章（紫→靛蓝），点赞数封装在深色磨砂胶囊内
///   • 双层紫调阴影，与暖白背景形成精致对比
class DiscoverCell_Vestir: UICollectionViewCell {

    static let reuseId_Vestir = "DiscoverCell_Vestir"

    // MARK: - 时尚渐变色板（8 种，令每张卡片占位图视觉不同）

    /// 卡片占位渐变色板，对角渐变，柔和饱和度营造精致时尚感
    static let cardGradients_Vestir: [[CGColor]] = [
        // 玫瑰石英：粉→杏
        [UIColor(hexstring_Vestir: "#FECDD3").cgColor, UIColor(hexstring_Vestir: "#FDE68A").cgColor],
        // 薰衣草雾：紫→蓝
        [UIColor(hexstring_Vestir: "#DDD6FE").cgColor, UIColor(hexstring_Vestir: "#BFDBFE").cgColor],
        // 蜜桃珊瑚：橙→粉红
        [UIColor(hexstring_Vestir: "#FED7AA").cgColor, UIColor(hexstring_Vestir: "#FCA5A5").cgColor],
        // 薄荷奶昔：绿→青蓝
        [UIColor(hexstring_Vestir: "#A7F3D0").cgColor, UIColor(hexstring_Vestir: "#BAE6FD").cgColor],
        // 丁香粉：紫粉→浅粉
        [UIColor(hexstring_Vestir: "#F5D0FE").cgColor, UIColor(hexstring_Vestir: "#FBCFE8").cgColor],
        // 奶油杏：黄→绿白
        [UIColor(hexstring_Vestir: "#FEF3C7").cgColor, UIColor(hexstring_Vestir: "#D1FAE5").cgColor],
        // 晨雾蔚蓝：天蓝→紫蓝
        [UIColor(hexstring_Vestir: "#BFDBFE").cgColor, UIColor(hexstring_Vestir: "#E0E7FF").cgColor],
        // 珊瑚玫瑰：浅红→粉
        [UIColor(hexstring_Vestir: "#FFE4E6").cgColor, UIColor(hexstring_Vestir: "#FCE7F3").cgColor]
    ]

    // MARK: - 阴影容器（不裁剪，承载投影）

    /// 双层阴影容器，紫调投影增强时尚立体感
    private let shadowContainer_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
        v_Vestir.layer.shadowOpacity = 0.22
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_Vestir.layer.shadowRadius = 18
        return v_Vestir
    }()

    // MARK: - 内容卡片（裁剪圆角）

    /// 内容卡片：圆角 20pt，clipsToBounds
    private let cardView_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 20
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    // MARK: - 媒体层

    /// 全出血媒体视图，由外部设置自定义占位渐变色
    private let mediaView_Vestir: MediaDisplayView_Vestir = {
        let mv_Vestir = MediaDisplayView_Vestir()
        mv_Vestir.clipsToBounds = true
        mv_Vestir.layer.cornerRadius = 0
        return mv_Vestir
    }()

    // MARK: - 顶部光泽层（增加卡片立体感）

    /// 顶部光泽蒙层容器，占卡片上方 22%，产生高光折射效果
    private let topSheenView_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 顶部光泽渐变图层（白色→透明，由上至下）
    private var topSheenGrad_Vestir: CAGradientLayer?

    // MARK: - 底部信息蒙层

    /// 底部渐变蒙层容器，占卡片下方 58%
    private let overlayView_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 底部三段渐变图层（透明→半深→深）
    private var overlayGradient_Vestir: CAGradientLayer?

    // MARK: - 蒙层信息组件

    /// 帖子标题（白色粗体，2 行，带文字投影）
    private let titleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        lbl_Vestir.textColor = .white
        lbl_Vestir.numberOfLines = 2
        lbl_Vestir.layer.shadowColor = UIColor.black.cgColor
        lbl_Vestir.layer.shadowOpacity = 0.40
        lbl_Vestir.layer.shadowOffset = CGSize(width: 0, height: 1)
        lbl_Vestir.layer.shadowRadius = 4
        return lbl_Vestir
    }()

    /// 用户头像（圆形，白色细边框）
    private let avatarView_Vestir: UserAvatarView_Vestir = {
        let av_Vestir = UserAvatarView_Vestir()
        av_Vestir.layer.cornerRadius = 10
        av_Vestir.clipsToBounds = true
        av_Vestir.layer.borderWidth = 1.5
        av_Vestir.layer.borderColor = UIColor(white: 1.0, alpha: 0.85).cgColor
        return av_Vestir
    }()

    /// 用户名（白色，11pt medium）
    private let userNameLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.90)
        return lbl_Vestir
    }()

    // MARK: - 点赞磨砂胶囊

    /// 点赞磨砂胶囊容器（深色半透明圆角背景，包裹心形 + 数字）
    private let likePill_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 0, alpha: 0.32)
        v_Vestir.layer.cornerRadius = 10
        v_Vestir.clipsToBounds = true
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 心形图标（柔玫瑰红）
    private let likeIconLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "♥"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.heartColor_Vestir
        return lbl_Vestir
    }()

    /// 点赞数（白色，10pt semibold）
    private let likeCountLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.92)
        return lbl_Vestir
    }()

    // MARK: - 渐变标签徽章（紫→靛蓝横向渐变）

    /// 标签徽章容器，承载横向渐变背景
    private let tagBadgeContainer_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 10
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    /// 标签徽章渐变图层（紫→靛蓝）
    private var tagBadgeGrad_Vestir: CAGradientLayer?

    /// 标签文字（白色粗体）
    private let tagBadgeLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        lbl_Vestir.textColor = .white
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    // MARK: - 举报按钮

    private var reportBtn_Vestir: UIButton?

    // MARK: - 作者点击回调（外部设置，传出 userId 以便导航到用户中心）

    /// 点击作者信息区域时触发，传出 titleUserId 供外部跳转
    var onAuthorTapped_Vestir: ((Int) -> Void)?

    /// 缓存当前帖子的作者 userId（供透明按钮回调使用）
    private var currentAuthorId_Vestir: Int = 0

    /// 覆盖在作者头像+用户名区域的透明点击层（直接加在 cardView，绕过 overlayView 的 isUserInteractionEnabled = false）
    private lazy var authorTapBtn_Vestir: UIButton = {
        let btn_Vestir = UIButton(type: .system)
        btn_Vestir.backgroundColor = .clear
        btn_Vestir.addTarget(self, action: #selector(authorAreaTapped_Vestir), for: .touchUpInside)
        return btn_Vestir
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Vestir()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        refreshOverlayGradient_Vestir()
        refreshTopSheenGrad_Vestir()
        refreshTagBadgeGrad_Vestir()
        updateShadowPath_Vestir()
    }

    // MARK: - UI 搭建

    /// 构建 Cell 内部视图层级与约束
    private func setupUI_Vestir() {
        contentView.addSubview(shadowContainer_Vestir)
        shadowContainer_Vestir.addSubview(cardView_Vestir)

        cardView_Vestir.addSubview(mediaView_Vestir)
        cardView_Vestir.addSubview(topSheenView_Vestir)
        cardView_Vestir.addSubview(overlayView_Vestir)
        cardView_Vestir.addSubview(tagBadgeContainer_Vestir)
        tagBadgeContainer_Vestir.addSubview(tagBadgeLabel_Vestir)

        overlayView_Vestir.addSubview(titleLabel_Vestir)
        overlayView_Vestir.addSubview(avatarView_Vestir)
        overlayView_Vestir.addSubview(userNameLabel_Vestir)
        overlayView_Vestir.addSubview(likePill_Vestir)
        likePill_Vestir.addSubview(likeIconLabel_Vestir)
        likePill_Vestir.addSubview(likeCountLabel_Vestir)
        // 作者透明点击层：直接加在 cardView（不在 overlayView），确保可交互
        cardView_Vestir.addSubview(authorTapBtn_Vestir)

        shadowContainer_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        cardView_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }
        mediaView_Vestir.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 顶部光泽层：占卡片上方 22%
        topSheenView_Vestir.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.22)
        }

        // 底部信息蒙层：占卡片下方 58%
        overlayView_Vestir.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.58)
        }

        titleLabel_Vestir.snp.makeConstraints { make in
            make.bottom.equalTo(avatarView_Vestir.snp.top).offset(-9)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }

        avatarView_Vestir.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-12)
            make.leading.equalToSuperview().offset(12)
            make.width.height.equalTo(20)
        }

        userNameLabel_Vestir.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView_Vestir)
            make.leading.equalTo(avatarView_Vestir.snp.trailing).offset(5)
            make.trailing.lessThanOrEqualTo(likePill_Vestir.snp.leading).offset(-6)
        }

        // 作者点击层：覆盖头像+用户名区域（左下角，高 34pt，宽至卡片中点）
        authorTapBtn_Vestir.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-6)
            make.leading.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalTo(34)
        }

        // 点赞磨砂胶囊：右下角，高 20pt
        likePill_Vestir.snp.makeConstraints { make in
            make.centerY.equalTo(avatarView_Vestir)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(20)
        }

        likeIconLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(7)
            make.centerY.equalToSuperview()
        }

        likeCountLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(likeIconLabel_Vestir.snp.trailing).offset(3)
            make.trailing.equalToSuperview().offset(-7)
            make.centerY.equalToSuperview()
        }

        // 渐变标签徽章：左上角，高 22pt
        tagBadgeContainer_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(22)
        }

        tagBadgeLabel_Vestir.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }
    }

    // MARK: - 渐变刷新

    /// 刷新底部三段渐变蒙层（透明→半深→深），layoutSubviews 中调用
    private func refreshOverlayGradient_Vestir() {
        guard overlayView_Vestir.bounds.height > 0 else { return }
        overlayGradient_Vestir?.removeFromSuperlayer()

        let grad_Vestir = CAGradientLayer()
        grad_Vestir.frame = overlayView_Vestir.bounds
        grad_Vestir.colors = [
            UIColor.clear.cgColor,
            UIColor(white: 0, alpha: 0.22).cgColor,
            UIColor(white: 0, alpha: 0.72).cgColor
        ]
        grad_Vestir.locations = [0, 0.35, 1.0]
        overlayView_Vestir.layer.insertSublayer(grad_Vestir, at: 0)
        overlayGradient_Vestir = grad_Vestir
    }

    /// 刷新顶部光泽渐变（白色→透明），为卡片增加高光折射感
    private func refreshTopSheenGrad_Vestir() {
        guard topSheenView_Vestir.bounds.height > 0 else { return }
        topSheenGrad_Vestir?.removeFromSuperlayer()

        let grad_Vestir = CAGradientLayer()
        grad_Vestir.frame = topSheenView_Vestir.bounds
        grad_Vestir.colors = [
            UIColor(white: 1.0, alpha: 0.18).cgColor,
            UIColor.clear.cgColor
        ]
        topSheenView_Vestir.layer.insertSublayer(grad_Vestir, at: 0)
        topSheenGrad_Vestir = grad_Vestir
    }

    /// 刷新标签徽章横向渐变（紫→靛蓝），layoutSubviews 中调用
    private func refreshTagBadgeGrad_Vestir() {
        guard tagBadgeContainer_Vestir.bounds.width > 0 else { return }
        tagBadgeGrad_Vestir?.removeFromSuperlayer()

        let grad_Vestir = CAGradientLayer()
        grad_Vestir.frame = tagBadgeContainer_Vestir.bounds
        grad_Vestir.colors = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            UIColor(hexstring_Vestir: "#818CF8").cgColor
        ]
        grad_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        grad_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        tagBadgeContainer_Vestir.layer.insertSublayer(grad_Vestir, at: 0)
        tagBadgeGrad_Vestir = grad_Vestir
    }

    /// 更新阴影路径，提升渲染性能
    private func updateShadowPath_Vestir() {
        let path_Vestir = UIBezierPath(
            roundedRect: shadowContainer_Vestir.bounds,
            cornerRadius: 20
        )
        shadowContainer_Vestir.layer.shadowPath = path_Vestir.cgPath
    }

    // MARK: - 数据配置

    /// 配置 Cell 显示数据
    /// 参数：
    /// - post_vestir: 帖子数据模型
    /// - index_vestir: Cell 在列表中的索引，用于选择渐变色板
    /// - viewController_Vestir: 所在控制器（用于举报弹窗）
    /// - completion_vestir: 举报/删除后的刷新回调
    func configure_Vestir(
        post_vestir: TitleModel_Vestir,
        index_vestir: Int,
        viewController_Vestir: UIViewController,
        completion_vestir: (() -> Void)?
    ) {
        // 根据索引分配色板，使每张卡片呈现不同颜色
        let palette_Vestir = Self.cardGradients_Vestir[index_vestir % Self.cardGradients_Vestir.count]
        mediaView_Vestir.customPlaceholderColors_Vestir = palette_Vestir
        mediaView_Vestir.configure_Vestir(mediaPath_Vestir: post_vestir.titleMeidas_Vestir.first)

        currentAuthorId_Vestir = post_vestir.titleUserId_Vestir
        avatarView_Vestir.configure_Vestir(userId_Vestir: post_vestir.titleUserId_Vestir)
        userNameLabel_Vestir.text = post_vestir.titleUserName_Vestir
        titleLabel_Vestir.text = post_vestir.title_Vestir
        likeCountLabel_Vestir.text = "\(post_vestir.likes_Vestir)"

        // 从标题取第一个词作为标签（最多 8 字符）
        let firstWord_Vestir = post_vestir.title_Vestir
            .components(separatedBy: .whitespaces)
            .first(where: { !$0.isEmpty }) ?? "Style"
        tagBadgeLabel_Vestir.text = "  \(String(firstWord_Vestir.prefix(8)))  "

        // 移除旧举报按钮避免复用重叠
        reportBtn_Vestir?.removeFromSuperview()
        reportBtn_Vestir = nil

        let btn_Vestir = ReportDeleteHelper_Vestir.createPostReportButton_Vestir(
            post_Vestir: post_vestir,
            size_Vestir: 13,
            color_Vestir: UIColor(white: 1.0, alpha: 0.85),
            from: viewController_Vestir,
            completion_Vestir: completion_vestir
        )
        reportBtn_Vestir = btn_Vestir
        cardView_Vestir.addSubview(btn_Vestir)

        btn_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(28)
        }
    }

    /// 点击作者区域：触发外部回调，传出 userId
    @objc private func authorAreaTapped_Vestir() {
        onAuthorTapped_Vestir?(currentAuthorId_Vestir)
    }
}

// MARK: - 瀑布流布局协议

/// 瀑布流布局数据源协议，提供每个 Item 的高度
protocol WaterfallLayoutDelegate_Vestir: AnyObject {
    /// 返回指定 IndexPath 在给定宽度下的高度
    func collectionView_Vestir(
        _ collectionView: UICollectionView,
        heightForItemAt_Vestir indexPath: IndexPath,
        withWidth_Vestir width: CGFloat
    ) -> CGFloat
}

// MARK: - 自定义瀑布流布局

/// 自定义非规则瀑布流布局
/// 功能：实现多列不等高的瀑布流布局，每次将新 Cell 放置到最短的一列
/// 设计：支持列数、列间距、行间距、Section 内边距以及顶部 Header 高度的自定义配置
class WaterfallLayout_Vestir: UICollectionViewLayout {

    weak var delegate: WaterfallLayoutDelegate_Vestir?

    var numberOfColumns_Vestir: Int = 2
    var minimumInteritemSpacing_Vestir: CGFloat = 10
    var minimumLineSpacing_Vestir: CGFloat = 10
    var sectionInset_Vestir: UIEdgeInsets = .zero

    /// Section Header 高度，设为 0 则不展示 Header
    var headerHeight_Vestir: CGFloat = 0

    private var cache_Vestir: [UICollectionViewLayoutAttributes] = []
    /// 缓存 Header 的布局属性
    private var headerAttributes_Vestir: UICollectionViewLayoutAttributes?
    private var contentHeight_Vestir: CGFloat = 0

    private var contentWidth_Vestir: CGFloat {
        guard let cv_Vestir = collectionView else { return 0 }
        return cv_Vestir.bounds.width - sectionInset_Vestir.left - sectionInset_Vestir.right
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(
            width: contentWidth_Vestir + sectionInset_Vestir.left + sectionInset_Vestir.right,
            height: contentHeight_Vestir + sectionInset_Vestir.bottom
        )
    }

    override func prepare() {
        guard let cv_Vestir = collectionView, cache_Vestir.isEmpty else { return }

        // 若有 Header，先构建 Header 布局属性（横向全宽，y=0）
        if headerHeight_Vestir > 0 {
            let headerAttr_Vestir = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                with: IndexPath(item: 0, section: 0)
            )
            headerAttr_Vestir.frame = CGRect(
                x: 0,
                y: 0,
                width: cv_Vestir.bounds.width,
                height: headerHeight_Vestir
            )
            headerAttributes_Vestir = headerAttr_Vestir
        }

        let columnWidth_Vestir = (
            contentWidth_Vestir - CGFloat(numberOfColumns_Vestir - 1) * minimumInteritemSpacing_Vestir
        ) / CGFloat(numberOfColumns_Vestir)

        // 每列起始 X 坐标
        var xOffsets_Vestir = [CGFloat]()
        for col_Vestir in 0..<numberOfColumns_Vestir {
            xOffsets_Vestir.append(
                sectionInset_Vestir.left + CGFloat(col_Vestir) * (columnWidth_Vestir + minimumInteritemSpacing_Vestir)
            )
        }

        // 每列起始 Y 坐标 = Header 高度 + Section 顶部内边距
        var yOffsets_Vestir = [CGFloat](
            repeating: headerHeight_Vestir + sectionInset_Vestir.top,
            count: numberOfColumns_Vestir
        )
        var column_Vestir = 0

        for item_Vestir in 0..<cv_Vestir.numberOfItems(inSection: 0) {
            let indexPath_Vestir = IndexPath(item: item_Vestir, section: 0)
            let height_Vestir = delegate?.collectionView_Vestir(
                cv_Vestir,
                heightForItemAt_Vestir: indexPath_Vestir,
                withWidth_Vestir: columnWidth_Vestir
            ) ?? 200

            let frame_Vestir = CGRect(
                x: xOffsets_Vestir[column_Vestir],
                y: yOffsets_Vestir[column_Vestir],
                width: columnWidth_Vestir,
                height: height_Vestir
            )
            let attrs_Vestir = UICollectionViewLayoutAttributes(forCellWith: indexPath_Vestir)
            attrs_Vestir.frame = frame_Vestir
            cache_Vestir.append(attrs_Vestir)

            contentHeight_Vestir = max(contentHeight_Vestir, frame_Vestir.maxY)
            yOffsets_Vestir[column_Vestir] += height_Vestir + minimumLineSpacing_Vestir

            // 选择当前最短的列放置下一个 Cell
            column_Vestir = yOffsets_Vestir.firstIndex(of: yOffsets_Vestir.min()!) ?? 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attrs_Vestir = cache_Vestir.filter { $0.frame.intersects(rect) }
        // 若 Header 与可见区域相交，将其加入结果
        if let header_Vestir = headerAttributes_Vestir, header_Vestir.frame.intersects(rect) {
            attrs_Vestir.insert(header_Vestir, at: 0)
        }
        return attrs_Vestir
    }

    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        if elementKind == UICollectionView.elementKindSectionHeader {
            return headerAttributes_Vestir
        }
        return nil
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache_Vestir[safe_Vestir: indexPath.item]
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache_Vestir.removeAll()
        headerAttributes_Vestir = nil
        contentHeight_Vestir = 0
    }
}

// MARK: - Array 安全下标扩展

private extension Array {
    /// 安全下标，越界返回 nil 避免崩溃
    subscript(safe_Vestir index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - 标签云视图

/// 标签云视图
/// 功能：接收标签数组，在 layoutSubviews 中做流式（wrap）排列
///       一行放不下时自动换行，行高 30pt，行间距 8pt，标签间距 8pt
/// 使用方：调用 setTags_Vestir(_:) 传入标签数据，视图宽度由外部约束决定
fileprivate final class DiscoverTagCloudView_Vestir: UIView {

    // MARK: - 常量

    private let pillHeight_Vestir: CGFloat = 30
    private let hSpacing_Vestir: CGFloat = 8   // 水平间距
    private let vSpacing_Vestir: CGFloat = 8   // 行间距

    // MARK: - 存储

    /// 当前展示的 Pill 视图列表
    private var pills_Vestir: [UILabel] = []

    // MARK: - 公共接口

    /// 设置标签数据，重建所有 Pill
    /// 参数：
    /// - tags_vestir: 元组数组，每项包含 (文字, 背景色, 文字色)
    func setTags_Vestir(_ tags_vestir: [(String, UIColor, UIColor)]) {
        pills_Vestir.forEach { $0.removeFromSuperview() }
        pills_Vestir = []

        for (text_Vestir, bg_Vestir, fg_Vestir) in tags_vestir {
            let lbl_Vestir = UILabel()
            lbl_Vestir.text = "  \(text_Vestir)  "
            lbl_Vestir.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            lbl_Vestir.textColor = fg_Vestir
            lbl_Vestir.backgroundColor = bg_Vestir
            lbl_Vestir.layer.cornerRadius = 12
            lbl_Vestir.clipsToBounds = true
            lbl_Vestir.textAlignment = .center
            addSubview(lbl_Vestir)
            pills_Vestir.append(lbl_Vestir)
        }

        setNeedsLayout()
    }

    // MARK: - 布局

    /// bounds 宽度变化时重新触发流式布局
    override var bounds: CGRect {
        didSet {
            if oldValue.width != bounds.width { setNeedsLayout() }
        }
    }

    /// 流式（wrap）排列：从左向右放置 Pill，放不下则换行
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, !pills_Vestir.isEmpty else { return }

        var x: CGFloat = 0
        var y: CGFloat = 0

        for pill_Vestir in pills_Vestir {
            // sizeThatFits 返回 Pill 的自然宽度（包含文字两侧空格内边距）
            let pillW_Vestir = pill_Vestir.sizeThatFits(
                CGSize(width: CGFloat.greatestFiniteMagnitude, height: pillHeight_Vestir)
            ).width

            // 换行条件：当前行已有内容 且 加上新 Pill 超出可用宽度
            if x > 0 && (x + pillW_Vestir) > bounds.width {
                x = 0
                y += pillHeight_Vestir + vSpacing_Vestir
            }

            pill_Vestir.frame = CGRect(x: x, y: y, width: pillW_Vestir, height: pillHeight_Vestir)
            x += pillW_Vestir + hSpacing_Vestir
        }
    }
}

// MARK: - 横幅渐变背景视图

/// 横幅渐变背景视图
/// 功能：自管理 CAGradientLayer，在自身 layoutSubviews 中同步更新 frame，
///       彻底规避从父视图 layoutSubviews 触发时 bounds 尚未确定的时序问题
/// 渐变配色：深紫 #6B21A8 → 靛蓝 #4338CA → 湛蓝 #0369A1（对角方向）
fileprivate final class DiscoverBannerCard_Vestir: UIView {

    private let gradientLayer_Vestir: CAGradientLayer = {
        let g_Vestir = CAGradientLayer()
        g_Vestir.colors = [
            UIColor(hexstring_Vestir: "#6B21A8").cgColor,  // 深紫
            UIColor(hexstring_Vestir: "#4338CA").cgColor,  // 靛蓝
            UIColor(hexstring_Vestir: "#0369A1").cgColor   // 湛蓝
        ]
        g_Vestir.locations = [0, 0.50, 1.0]
        g_Vestir.startPoint = CGPoint(x: 0, y: 0)
        g_Vestir.endPoint = CGPoint(x: 1, y: 1)
        return g_Vestir
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 20
        clipsToBounds = true
        // 渐变插在最底层，装饰圆和文字浮于其上
        layer.insertSublayer(gradientLayer_Vestir, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// bounds 变化时自动更新渐变 frame，确保始终完整覆盖
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Vestir.frame = bounds
    }
}

// MARK: - 发现页顶部描述头部视图

/// 发现页顶部描述头部视图
/// 功能：以 UICollectionReusableView 形式随瀑布流内容一起滚动
/// 设计分区：
///   ① 主题横幅卡片（三颗装饰圆 + 磨砂统计卡 + 品牌标语 + 双层阴影）
///   ② 横向可滚动风格标签行（四色和谐配色系统）
/// 对外暴露 configure_Vestir(posts:) 方法以刷新统计数据
class DiscoverHeaderView_Vestir: UICollectionReusableView {

    static let reuseId_Vestir = "DiscoverHeaderView_Vestir"

    // MARK: - 横幅阴影容器（不裁剪，仅承载投影）

    /// 横幅卡片阴影容器，不做裁剪以保留阴影
    private let bannerShadow_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = .clear
        v_Vestir.layer.shadowColor = ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor
        v_Vestir.layer.shadowOpacity = 0.28
        v_Vestir.layer.shadowOffset = CGSize(width: 0, height: 8)
        v_Vestir.layer.shadowRadius = 20
        return v_Vestir
    }()

    // MARK: - 横幅卡片（自管理渐变，bounds 变化时自动刷新）

    /// 横幅卡片：使用 DiscoverBannerCard_Vestir 自管理渐变图层，彻底避免 bounds 时序问题
    private let bannerCard_Vestir = DiscoverBannerCard_Vestir()

    /// 横幅三段对角渐变图层（由 DiscoverBannerCard_Vestir 自行管理，此处无需存储）

    // MARK: - 装饰圆（三颗，营造空间层次感）

    /// 装饰圆 1：右上大圆，白色 16% alpha，溢出裁剪产生弧线
    private let decoCircle1_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.16)
        v_Vestir.layer.cornerRadius = 60
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 装饰圆 2：左下中圆，浅蓝 28% alpha
    private let decoCircle2_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(hexstring_Vestir: "#93C5FD", alpha_Vestir: 0.28)
        v_Vestir.layer.cornerRadius = 40
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    /// 装饰圆 3：标题区右侧小圆，白色 20% alpha
    private let decoCircle3_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.20)
        v_Vestir.layer.cornerRadius = 22
        v_Vestir.isUserInteractionEnabled = false
        return v_Vestir
    }()

    // MARK: - 横幅文字内容

    /// 副标题装饰行 "✦ Curated for you"
    private let bannerTaglineLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "✦  Curated for you"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.68)
        return lbl_Vestir
    }()

    /// 主标题 "Style Feed"（22pt Heavy 白色，带文字投影）
    private let bannerTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Style Feed"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 22, weight: .heavy)
        lbl_Vestir.textColor = .white
        lbl_Vestir.layer.shadowColor = UIColor.black.cgColor
        lbl_Vestir.layer.shadowOpacity = 0.18
        lbl_Vestir.layer.shadowOffset = CGSize(width: 0, height: 1)
        lbl_Vestir.layer.shadowRadius = 4
        return lbl_Vestir
    }()

    /// 描述文字（11.5pt 白色 78% alpha，两行）
    private let bannerDescLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Explore fresh looks, outfit ideas & trending\nstyles from creators worldwide."
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11.5, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.78)
        lbl_Vestir.numberOfLines = 2
        return lbl_Vestir
    }()

    // MARK: - 磨砂统计卡（两个并排）

    /// Posts 磨砂卡容器（白色 22% alpha 背景，在深色渐变上更清晰）
    private let postsCard_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        v_Vestir.layer.cornerRadius = 12
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    /// Posts 数量（20pt bold 白色）
    private let postsNumberLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl_Vestir.textColor = .white
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// "Posts" 说明文字（10pt 白色 72% alpha）
    private let postsNameLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Posts"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.72)
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// Creators 磨砂卡容器（白色 22% alpha 背景）
    private let creatorsCard_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = UIColor(white: 1.0, alpha: 0.22)
        v_Vestir.layer.cornerRadius = 12
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    /// Creators 数量
    private let creatorsNumberLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        lbl_Vestir.textColor = .white
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// "Creators" 说明文字
    private let creatorsNameLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Creators"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        lbl_Vestir.textColor = UIColor(white: 1.0, alpha: 0.72)
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    // MARK: - 风格标签行

    /// 趋势标题行容器（渐变圆点 + 文字）
    private let trendingRow_Vestir: UIView = UIView()

    /// 渐变圆点（8pt，主渐变色）
    private let trendingDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.layer.cornerRadius = 4
        v_Vestir.clipsToBounds = true
        return v_Vestir
    }()

    /// 渐变圆点图层
    private var dotGrad_Vestir: CAGradientLayer?

    /// "Trending Styles" 标题（14pt Bold）
    private let trendingTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Trending Styles"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    /// 标签云视图（自动换行流式布局，替代原横向滚动行）
    private let tagCloud_Vestir = DiscoverTagCloudView_Vestir()

    // MARK: - 帖子列表描述行

    /// 帖子分区描述行容器（标题 + 计数徽章）
    private let postsDescRow_Vestir: UIView = UIView()

    /// 帖子分区左侧渐变圆点（与 Trending 圆点同色系）
    private let postsDescDot_Vestir: UIView = {
        let v_Vestir = UIView()
        v_Vestir.backgroundColor = ColorConfig_Vestir.primaryGradientStart_Vestir
        v_Vestir.layer.cornerRadius = 4
        return v_Vestir
    }()

    /// 帖子分区标题 "Latest Posts"
    private let postsDescTitleLabel_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.text = "Latest Posts"
        lbl_Vestir.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        lbl_Vestir.textColor = ColorConfig_Vestir.textPrimary_Vestir
        return lbl_Vestir
    }()

    /// 帖子数量徽章（浅薰衣草背景 + 深紫文字）
    private let postsDescBadge_Vestir: UILabel = {
        let lbl_Vestir = UILabel()
        lbl_Vestir.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        lbl_Vestir.textColor = ColorConfig_Vestir.tagPillText_Vestir
        lbl_Vestir.backgroundColor = ColorConfig_Vestir.tagPill_Vestir
        lbl_Vestir.layer.cornerRadius = 10
        lbl_Vestir.clipsToBounds = true
        lbl_Vestir.textAlignment = .center
        return lbl_Vestir
    }()

    /// 描述行下方渐变分隔线（紫→透明，横向）
    private let postsDescSeparator_Vestir: UIView = UIView()

    // MARK: - 静态数据

    /// 风格标签名称列表（纯展示，不关联过滤逻辑）
    private static let tagNames_Vestir = [
        "Outfit", "Minimal", "Street", "Casual",
        "Luxury", "Y2K", "Boho", "Chic", "Vintage"
    ]

    /// 四色和谐配色系（柔和底色 + 深调文字，视觉统一）
    private static let tagColorPairs_Vestir: [(UIColor, UIColor)] = [
        (UIColor(hexstring_Vestir: "#F3EEFF"), UIColor(hexstring_Vestir: "#7C3AED")),  // 薰衣草紫
        (UIColor(hexstring_Vestir: "#FFF1F2"), UIColor(hexstring_Vestir: "#BE123C")),  // 柔玫瑰
        (UIColor(hexstring_Vestir: "#EFF6FF"), UIColor(hexstring_Vestir: "#1D4ED8")),  // 天空蓝
        (UIColor(hexstring_Vestir: "#FFFBEB"), UIColor(hexstring_Vestir: "#B45309"))   // 暖琥珀
    ]

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Vestir()
        buildTagPills_Vestir()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // bannerCard_Vestir 自行管理渐变，此处只需刷新圆点、阴影、分隔线
        refreshDotGradient_Vestir()
        refreshSeparatorGradient_Vestir()
        refreshBannerShadowPath_Vestir()
    }

    // MARK: - UI 搭建

    /// 构建视图层级与约束（总高度 258pt）
    private func setupUI_Vestir() {
        backgroundColor = .clear

        addSubview(bannerShadow_Vestir)
        bannerShadow_Vestir.addSubview(bannerCard_Vestir)

        // 装饰圆（bannerCard 内，随其裁剪）
        bannerCard_Vestir.addSubview(decoCircle1_Vestir)
        bannerCard_Vestir.addSubview(decoCircle2_Vestir)
        bannerCard_Vestir.addSubview(decoCircle3_Vestir)

        // 文字内容
        bannerCard_Vestir.addSubview(bannerTaglineLabel_Vestir)
        bannerCard_Vestir.addSubview(bannerTitleLabel_Vestir)
        bannerCard_Vestir.addSubview(bannerDescLabel_Vestir)

        // 磨砂统计卡
        bannerCard_Vestir.addSubview(postsCard_Vestir)
        postsCard_Vestir.addSubview(postsNumberLabel_Vestir)
        postsCard_Vestir.addSubview(postsNameLabel_Vestir)
        bannerCard_Vestir.addSubview(creatorsCard_Vestir)
        creatorsCard_Vestir.addSubview(creatorsNumberLabel_Vestir)
        creatorsCard_Vestir.addSubview(creatorsNameLabel_Vestir)

        // 趋势标签行
        addSubview(trendingRow_Vestir)
        trendingRow_Vestir.addSubview(trendingDot_Vestir)
        trendingRow_Vestir.addSubview(trendingTitleLabel_Vestir)
        addSubview(tagCloud_Vestir)

        // ─── 横幅阴影容器：左右各 14pt 留白，高 158pt ───
        bannerShadow_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(14)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(158)
        }

        bannerCard_Vestir.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // 装饰圆 1：右上，溢出 36pt
        decoCircle1_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(120)
            make.top.equalToSuperview().offset(-36)
            make.trailing.equalToSuperview().offset(36)
        }

        // 装饰圆 2：左下，溢出底部 24pt
        decoCircle2_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.bottom.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(-20)
        }

        // 装饰圆 3：标题右侧
        decoCircle3_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.top.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().offset(-52)
        }

        // 副标题 tagline
        bannerTaglineLabel_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(18)
        }

        // 主标题
        bannerTitleLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(bannerTaglineLabel_Vestir.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-80)
        }

        // 描述文字
        bannerDescLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(bannerTitleLabel_Vestir.snp.bottom).offset(7)
            make.leading.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
        }

        // ─── 磨砂统计卡：底部对齐，左侧排列 ───
        postsCard_Vestir.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-16)
            make.leading.equalToSuperview().offset(18)
            make.width.greaterThanOrEqualTo(72)
            make.height.equalTo(50)
        }

        postsNumberLabel_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(7)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        postsNameLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(postsNumberLabel_Vestir.snp.bottom).offset(1)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-7)
        }

        creatorsCard_Vestir.snp.makeConstraints { make in
            make.bottom.equalTo(postsCard_Vestir)
            make.leading.equalTo(postsCard_Vestir.snp.trailing).offset(10)
            make.width.greaterThanOrEqualTo(84)
            make.height.equalTo(50)
        }

        creatorsNumberLabel_Vestir.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(7)
            make.leading.trailing.equalToSuperview().inset(12)
        }

        creatorsNameLabel_Vestir.snp.makeConstraints { make in
            make.top.equalTo(creatorsNumberLabel_Vestir.snp.bottom).offset(1)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-7)
        }

        // ─── 趋势标签行 ───
        trendingRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(bannerShadow_Vestir.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(20)
        }

        trendingDot_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }

        trendingTitleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(trendingDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }

        // 标签云：左右各 14pt 内边距，高度固定 84pt（容纳 2~3 行标签）
        tagCloud_Vestir.snp.makeConstraints { make in
            make.top.equalTo(trendingRow_Vestir.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(84)
        }

        // ─── 帖子列表描述行 ───
        addSubview(postsDescRow_Vestir)
        postsDescRow_Vestir.addSubview(postsDescDot_Vestir)
        postsDescRow_Vestir.addSubview(postsDescTitleLabel_Vestir)
        postsDescRow_Vestir.addSubview(postsDescBadge_Vestir)
        addSubview(postsDescSeparator_Vestir)

        postsDescRow_Vestir.snp.makeConstraints { make in
            make.top.equalTo(tagCloud_Vestir.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-14)
            make.height.equalTo(28)
        }

        postsDescDot_Vestir.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(8)
        }

        postsDescTitleLabel_Vestir.snp.makeConstraints { make in
            make.leading.equalTo(postsDescDot_Vestir.snp.trailing).offset(7)
            make.centerY.equalToSuperview()
        }

        postsDescBadge_Vestir.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(22)
        }

        // 分隔线：渐变颜色将在 layoutSubviews 中应用
        postsDescSeparator_Vestir.snp.makeConstraints { make in
            make.top.equalTo(postsDescRow_Vestir.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview()
            make.height.equalTo(1.5)
        }
    }

    /// 将静态标签数据传入标签云视图，由标签云自行构建并流式布局
    private func buildTagPills_Vestir() {
        let tags_Vestir = Self.tagNames_Vestir.enumerated().map { index_Vestir, name_Vestir -> (String, UIColor, UIColor) in
            let pair_Vestir = Self.tagColorPairs_Vestir[index_Vestir % Self.tagColorPairs_Vestir.count]
            return (name_Vestir, pair_Vestir.0, pair_Vestir.1)
        }
        tagCloud_Vestir.setTags_Vestir(tags_Vestir)
    }

    // MARK: - 渐变刷新

    /// 刷新渐变圆点图层（主渐变色，横向）
    private func refreshDotGradient_Vestir() {
        guard trendingDot_Vestir.bounds.width > 0 else { return }
        dotGrad_Vestir?.removeFromSuperlayer()

        let grad_Vestir = CAGradientLayer()
        grad_Vestir.frame = trendingDot_Vestir.bounds
        grad_Vestir.colors = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor
        ]
        grad_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        grad_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        grad_Vestir.cornerRadius = 4
        trendingDot_Vestir.layer.insertSublayer(grad_Vestir, at: 0)
        dotGrad_Vestir = grad_Vestir
    }

    /// 刷新横幅阴影路径，提升渲染性能
    private func refreshBannerShadowPath_Vestir() {
        guard bannerShadow_Vestir.bounds.width > 0 else { return }
        let path_Vestir = UIBezierPath(roundedRect: bannerShadow_Vestir.bounds, cornerRadius: 20)
        bannerShadow_Vestir.layer.shadowPath = path_Vestir.cgPath
    }

    /// 刷新帖子描述行下方分隔线渐变（主渐变色→透明，横向淡出）
    private func refreshSeparatorGradient_Vestir() {
        guard postsDescSeparator_Vestir.bounds.width > 0 else { return }
        postsDescSeparator_Vestir.layer.sublayers?
            .filter { $0 is CAGradientLayer }
            .forEach { $0.removeFromSuperlayer() }

        let grad_Vestir = CAGradientLayer()
        grad_Vestir.frame = postsDescSeparator_Vestir.bounds
        grad_Vestir.colors = [
            ColorConfig_Vestir.primaryGradientStart_Vestir.cgColor,
            ColorConfig_Vestir.primaryGradientEnd_Vestir.cgColor,
            UIColor.clear.cgColor
        ]
        grad_Vestir.locations = [0, 0.5, 1.0]
        grad_Vestir.startPoint = CGPoint(x: 0, y: 0.5)
        grad_Vestir.endPoint = CGPoint(x: 1, y: 0.5)
        postsDescSeparator_Vestir.layer.addSublayer(grad_Vestir)
    }

    // MARK: - 数据配置

    /// 配置头部统计数据（帖子总数 + 不重复创作者数 + 描述行计数）
    /// 参数：
    /// - posts_vestir: 当前帖子列表
    func configure_Vestir(posts_vestir: [TitleModel_Vestir]) {
        let count_Vestir = posts_vestir.count
        postsNumberLabel_Vestir.text = "\(count_Vestir)"
        creatorsNumberLabel_Vestir.text = "\(Set(posts_vestir.map { $0.titleUserId_Vestir }).count)"
        // 帖子计数徽章（含左右内边距空格）
        postsDescBadge_Vestir.text = "  \(count_Vestir) styles  "
    }
}
