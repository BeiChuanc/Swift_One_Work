import UIKit
import SnapKit

// MARK: - 礼物展示单项视图

/// 礼物展示单项通用视图
/// 核心作用：展示单个礼物的图标、名称（HStack）与价格（VStack），供 Section1/2 UIStackView 复用
/// imageName_Pane 可指定自定义图片名称，否则使用 gift_{id} 规则
/// 背景白色圆角20，选中时替换为浅紫色 #BE92FD
class GiftItemView_Pane: UIView {

    // MARK: - 常量
    private static let selectedBg_Pane = UIColor(hexstring_Pane: "#BE92FD").withAlphaComponent(0.35)

    // MARK: - 属性

    /// 礼物数据（set 后自动刷新 UI）
    var model_Pane: StoreModel_Pane? { didSet { fillData_Pane() } }

    /// 自定义图片名称，优先于 gift_{id} 规则
    var imageName_Pane: String? { didSet { fillData_Pane() } }

    /// 选中状态（set 后自动更新背景色）
    var isGiftSelected_Pane: Bool = false { didSet { updateSelectedState_Pane() } }

    /// 点击回调
    var onTap_Pane: ((StoreModel_Pane) -> Void)?

    // MARK: - UI 组件

    private let giftImageView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Pane: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor(hexstring_Pane: "#111111")
        lbl.textAlignment = .center
        return lbl
    }()

    private let priceLabel_Pane: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = UIColor(hexstring_Pane: "#111111")
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Pane()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// VStack：HStack(图片36×36 + 名称, 间距5) + 价格
    private func setupUI_Pane() {
        backgroundColor = .white
        layer.cornerRadius  = 20
        // masksToBounds 必须为 false，否则 layer.shadow* 被裁掉无法显示
        layer.masksToBounds = false
        // 底部阴影
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowOpacity = 0.10
        layer.shadowRadius  = 8
        isUserInteractionEnabled = true

        giftImageView_Pane.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        let topRow_Pane = UIStackView(arrangedSubviews: [giftImageView_Pane, nameLabel_Pane])
        topRow_Pane.axis = .horizontal
        topRow_Pane.spacing = 5
        topRow_Pane.alignment = .center

        let vStack_Pane = UIStackView(arrangedSubviews: [topRow_Pane, priceLabel_Pane])
        vStack_Pane.axis = .vertical
        vStack_Pane.spacing = 6
        vStack_Pane.alignment = .center

        addSubview(vStack_Pane)
        vStack_Pane.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(6)
            make.trailing.lessThanOrEqualToSuperview().offset(-6)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Pane))
        addGestureRecognizer(tap)
    }

    // MARK: - 数据填充

    private func fillData_Pane() {
        guard let m = model_Pane else { return }
        // 优先使用自定义图片名称，否则按 gift_{id} 规则
        let name = imageName_Pane ?? "gift_\(m.id_Pane ?? 1)"
        giftImageView_Pane.image = UIImage(named: name)
        nameLabel_Pane.text  = m.goodsName_Pane
        priceLabel_Pane.text = m.goodsPrice_Pane
    }

    private func updateSelectedState_Pane() {
        backgroundColor = isGiftSelected_Pane ? Self.selectedBg_Pane : .white
    }

    @objc private func handleTap_Pane() {
        guard let m = model_Pane else { return }
        onTap_Pane?(m)
    }
}


// MARK: - 送礼界面（模态弹起）

/// 送礼界面视图控制器
/// 核心作用：以模态底部弹起方式展示礼物列表，支持选中、购买（接入 Store_Pane IAP）
/// 设计思路：全屏半透明遮罩 + gift_bg 图片面板（屏幕高 85%） + 三区礼物 + 底部购买按钮
/// 组件布局（底部对齐，间距 20）：buyButton ← section3 ← section2 ← section1
/// 关键方法：handleItemSelected_Pane（礼物选中），handleBuyTap_Pane（发起内购）
class GiftView_Pane: UIViewController {

    // MARK: - 常量

    private let panelH_Pane: CGFloat  = UIScreen.main.bounds.height * 0.85
    private let screenW_Pane: CGFloat = UIScreen.main.bounds.width
    /// Section3 每列固定 4 列，左右各 16pt 内边距
    private let s3SideInset_Pane: CGFloat = 16
    private let s3Cols_Pane: CGFloat      = 4
    private let s3ItemH_Pane: CGFloat     = 82
    private let s3LineSpacing_Pane: CGFloat = 12

    // MARK: - 数据

    private var topGifts_Pane: [StoreModel_Pane] = []
    private var limitGifts_Pane: [StoreModel_Pane] = []
    private var normalGifts_Pane: [StoreModel_Pane] = []
    private var selectedGift_Pane: StoreModel_Pane?
    private var allItemViews_Pane: [GiftItemView_Pane] = []

    // MARK: - UI 组件

    /// 全屏半透明遮罩（点击非面板区域关闭）
    private let overlayView_Pane: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    /// gift_bg 图片面板（屏幕宽度 × 屏幕高度60%，底部对齐）
    private let bgImageView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = false
        iv.isUserInteractionEnabled = true
        return iv
    }()

    // ── Section1：HStack（gift_spe 固定170×32 + 顶部礼物平分剩余空间）────────

    /// Section1 水平容器（高度78，gift_spe 在左，礼物 fillEqually 在右）
    private let section1View_Pane = UIView()

    /// 装饰图片 gift_spe（固定 170×32，垂直居中于 78pt 行）
    private let speImageView_Pane: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_spe")
        iv.contentMode = .scaleAspectFit
        // 不被压缩/拉伸，维持固定宽度
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()

    /// 顶部礼物 fillEqually 容器（平分 gift_spe 右侧剩余空间）
    private let topGiftsContainer_Pane: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section2：HStack（限定礼物横向均分，图标 gift_three）────────────────

    private let section2Stack_Pane: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section3：手动网格（2行×4列，左右 inset16，行0=gift_four，行1=gift_five）──

    /// Section3 容器（通过 UIStackView 手动排列，避免 UICollectionView 选中回调不稳定的问题）
    private let section3View_Pane = UIView()

    // ── 购买按钮 ────────────────────────────────────────────────────────────

    private let buyButton_Pane: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "gift_buy"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        btn.clipsToBounds = true
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        loadData_Pane()
        setupUI_Pane()
        buildSection1_Pane()
        buildSection2_Pane()
        buildSection3_Pane()
        bindActions_Pane()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePanelIn_Pane()
    }

    // MARK: - 数据加载

    private func loadData_Pane() {
        let all = Store_Pane.shared_Pane.goodsList_Pane
        topGifts_Pane    = all.filter { $0.goodIsTop_Pane == true }
        limitGifts_Pane  = all.filter { $0.goodIsSpecial_Pane == true }
        normalGifts_Pane = all.filter {
            $0.goodIsTop_Pane != true && $0.goodIsSpecial_Pane != true
        }
    }

    // MARK: - UI 搭建

    /// 主布局：遮罩 + gift_bg 面板 + 各组件（底部对齐，组件间距 20pt）
    private func setupUI_Pane() {
        view.addSubview(overlayView_Pane)
        overlayView_Pane.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(bgImageView_Pane)
        bgImageView_Pane.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(panelH_Pane)
        }

        // 购买按钮（布局起点，距面板底部 50）
        view.addSubview(buyButton_Pane)
        buyButton_Pane.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(62)
            make.bottom.equalTo(bgImageView_Pane.snp.bottom).offset(-70)
        }

        // Section3 手动网格（2行，高 = 2×82 + 12 = 176），距购买按钮 20
        view.addSubview(section3View_Pane)
        section3View_Pane.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Int(s3ItemH_Pane) * 2 + Int(s3LineSpacing_Pane))
            make.bottom.equalTo(buyButton_Pane.snp.top).offset(-20)
        }

        // Section2 限定礼物 HStack（高78），距 Section3 上方 20
        view.addSubview(section2Stack_Pane)
        section2Stack_Pane.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(78)
            make.bottom.equalTo(section3View_Pane.snp.top).offset(-20)
        }

        // Section1 HStack 容器（高度78，含 gift_spe + 礼物），距 Section2 上方 20
        view.addSubview(section1View_Pane)
        section1View_Pane.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(78)
            make.bottom.equalTo(section2Stack_Pane.snp.top).offset(-20)
        }

        // 初始位置在屏幕下方，等待滑入动画
        let offscreen = CGAffineTransform(translationX: 0, y: panelH_Pane)
        bgImageView_Pane.transform    = offscreen
        section1View_Pane.transform   = offscreen
        section2Stack_Pane.transform  = offscreen
        section3View_Pane.transform   = offscreen
        buyButton_Pane.transform      = offscreen
        overlayView_Pane.alpha        = 0
    }

    /// 构建 Section1：gift_spe(170×32)固定在左侧居中 + 顶部礼物 fillEqually 平分剩余宽度
    /// 图标依次使用 gift_one（第1个）、gift_two（第2个）
    private func buildSection1_Pane() {
        section1View_Pane.addSubview(speImageView_Pane)
        section1View_Pane.addSubview(topGiftsContainer_Pane)

        // gift_spe：左边距16，垂直居中，固定 170×32
        speImageView_Pane.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(170)
            make.height.equalTo(32)
        }

        // 礼物容器：紧贴 speImageView 右侧 8pt，右边距 16，高度填满 section1View（78pt）
        topGiftsContainer_Pane.snp.makeConstraints { make in
            make.leading.equalTo(speImageView_Pane.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }

        // 顶部礼物：按顺序使用 gift_one / gift_two
        let topImageNames_Pane = ["gift_one", "gift_two"]
        topGifts_Pane.enumerated().forEach { idx, gift in
            let imgName = idx < topImageNames_Pane.count
                ? topImageNames_Pane[idx]
                : "gift_\(gift.id_Pane ?? 1)"
            let itemView = makeGiftItemView_Pane(model: gift, imageName_Pane: imgName)
            topGiftsContainer_Pane.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section2：限定礼物横向均分，全部使用图标 gift_three
    private func buildSection2_Pane() {
        limitGifts_Pane.forEach { gift in
            let itemView = makeGiftItemView_Pane(model: gift, imageName_Pane: "gift_three")
            section2Stack_Pane.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section3：2行×4列手动网格
    /// 行0 使用图标 gift_four，行1 使用图标 gift_five
    /// 礼物均使用 GiftItemView_Pane（自带 onTap_Pane，选中状态由 handleItemSelected_Pane 统一管理）
    private func buildSection3_Pane() {
        // 按每行 4 个切分礼物数组
        let cols = Int(s3Cols_Pane)
        let rowImages = ["gift_four", "gift_five"]

        let vStack = UIStackView()
        vStack.axis        = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing     = s3LineSpacing_Pane

        for rowIdx in 0..<2 {
            let start = rowIdx * cols
            let end   = min(start + cols, normalGifts_Pane.count)
            guard start < end else { continue }

            let rowGifts = normalGifts_Pane[start..<end]
            let imgName  = rowIdx < rowImages.count ? rowImages[rowIdx] : "gift_three"

            let hStack = UIStackView()
            hStack.axis         = .horizontal
            hStack.distribution = .fillEqually
            hStack.spacing      = 8

            rowGifts.forEach { gift in
                let item = makeGiftItemView_Pane(model: gift, imageName_Pane: imgName)
                hStack.addArrangedSubview(item)
            }
            vStack.addArrangedSubview(hStack)
        }

        section3View_Pane.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Int(s3SideInset_Pane))
            make.trailing.equalToSuperview().offset(-Int(s3SideInset_Pane))
            make.top.bottom.equalToSuperview()
        }
    }

    // MARK: - 工厂方法

    /// 创建并注册 GiftItemView_Pane（支持自定义图片名）
    /// - Parameters:
    ///   - model: 礼物数据
    ///   - imageName_Pane: 指定图片名称（不传则按 gift_{id} 规则）
    private func makeGiftItemView_Pane(
        model: StoreModel_Pane,
        imageName_Pane: String? = nil
    ) -> GiftItemView_Pane {
        let v = GiftItemView_Pane()
        v.imageName_Pane = imageName_Pane
        v.model_Pane     = model
        v.onTap_Pane = { [weak self] selected in
            self?.handleItemSelected_Pane(model: selected)
        }
        allItemViews_Pane.append(v)
        return v
    }

    // MARK: - 动画

    private func animatePanelIn_Pane() {
        UIView.animate(
            withDuration: 0.38,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.overlayView_Pane.alpha        = 1
            self.bgImageView_Pane.transform    = .identity
            self.section1View_Pane.transform   = .identity
            self.section2Stack_Pane.transform  = .identity
            self.section3View_Pane.transform   = .identity
            self.buyButton_Pane.transform      = .identity
        }
    }

    private func animatePanelOut_Pane(completion_Pane: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.28) {
            self.overlayView_Pane.alpha = 0
            let t = CGAffineTransform(translationX: 0, y: self.panelH_Pane)
            self.bgImageView_Pane.transform   = t
            self.section1View_Pane.transform  = t
            self.section2Stack_Pane.transform = t
            self.section3View_Pane.transform  = t
            self.buyButton_Pane.transform     = t
        } completion: { _ in
            self.dismiss(animated: false, completion: completion_Pane)
        }
    }

    // MARK: - 选中处理

    /// 统一处理礼物选中（Section1/2/3 所有视图均在 allItemViews_Pane 中，直接遍历更新）
    private func handleItemSelected_Pane(model: StoreModel_Pane) {
        selectedGift_Pane = model
        allItemViews_Pane.forEach { v in
            v.isGiftSelected_Pane = (v.model_Pane?.id_Pane == model.id_Pane)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Pane() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap_Pane(_:)))
        // 不阻断面板内部视图（CollectionView、UIButton 等）的触摸传递
        tap.cancelsTouchesInView = false
        overlayView_Pane.addGestureRecognizer(tap)
        buyButton_Pane.addTarget(self, action: #selector(handleBuyTap_Pane), for: .touchUpInside)
    }

    /// 点击遮罩：仅当点击位置位于面板（bgImageView）区域外时才关闭界面
    @objc private func handleOverlayTap_Pane(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        // 触碰面板内部时不关闭，避免拦截 CollectionView cell 点击
        if bgImageView_Pane.frame.contains(point) { return }
        animatePanelOut_Pane()
    }

    @objc private func handleBuyTap_Pane() {
        guard let gift = selectedGift_Pane, let gid = gift.goodsId_Pane else {
            Utils_Pane.showWarning_Pane(message_Pane: "Please select a gift first.")
            return
        }
        buyButton_Pane.animatePressDown_Pane { self.buyButton_Pane.animatePressUp_Pane() }
        Store_Pane.shared_Pane.PurchaseStoreGift_Pane(gid_Pane: gid) { [weak self] in
            self?.animatePanelOut_Pane()
        }
    }
}

