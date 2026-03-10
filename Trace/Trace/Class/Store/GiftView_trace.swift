import UIKit
import SnapKit

// MARK: - 礼物展示单项视图

/// 礼物展示单项通用视图
/// 核心作用：展示单个礼物的图标、名称（HStack）与价格（VStack），供 Section1/2 UIStackView 复用
/// imageName_Trace 可指定自定义图片名称，否则使用 gift_{id} 规则
/// 背景白色圆角20，选中时替换为浅紫色 #BE92FD
class GiftItemView_Trace: UIView {

    // MARK: - 常量
    private static let selectedBg_Trace = UIColor(hexstring_Trace: "#BE92FD").withAlphaComponent(0.35)

    // MARK: - 属性

    /// 礼物数据（set 后自动刷新 UI）
    var model_Trace: StoreModel_Trace? { didSet { fillData_Trace() } }

    /// 自定义图片名称，优先于 gift_{id} 规则
    var imageName_Trace: String? { didSet { fillData_Trace() } }

    /// 选中状态（set 后自动更新背景色）
    var isGiftSelected_Trace: Bool = false { didSet { updateSelectedState_Trace() } }

    /// 点击回调
    var onTap_Trace: ((StoreModel_Trace) -> Void)?

    // MARK: - UI 组件

    private let giftImageView_Trace: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor(hexstring_Trace: "#111111")
        lbl.textAlignment = .center
        return lbl
    }()

    private let priceLabel_Trace: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = UIColor(hexstring_Trace: "#111111")
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Trace()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// VStack：HStack(图片36×36 + 名称, 间距5) + 价格
    private func setupUI_Trace() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.masksToBounds = true
        isUserInteractionEnabled = true

        giftImageView_Trace.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        let topRow_Trace = UIStackView(arrangedSubviews: [giftImageView_Trace, nameLabel_Trace])
        topRow_Trace.axis = .horizontal
        topRow_Trace.spacing = 5
        topRow_Trace.alignment = .center

        let vStack_Trace = UIStackView(arrangedSubviews: [topRow_Trace, priceLabel_Trace])
        vStack_Trace.axis = .vertical
        vStack_Trace.spacing = 6
        vStack_Trace.alignment = .center

        addSubview(vStack_Trace)
        vStack_Trace.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(6)
            make.trailing.lessThanOrEqualToSuperview().offset(-6)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Trace))
        addGestureRecognizer(tap)
    }

    // MARK: - 数据填充

    private func fillData_Trace() {
        guard let m = model_Trace else { return }
        // 优先使用自定义图片名称，否则按 gift_{id} 规则
        let name = imageName_Trace ?? "gift_\(m.id_Trace ?? 1)"
        giftImageView_Trace.image = UIImage(named: name)
        nameLabel_Trace.text  = m.goodsName_Trace
        priceLabel_Trace.text = m.goodsPrice_Trace
    }

    private func updateSelectedState_Trace() {
        backgroundColor = isGiftSelected_Trace ? Self.selectedBg_Trace : .white
    }

    @objc private func handleTap_Trace() {
        guard let m = model_Trace else { return }
        onTap_Trace?(m)
    }
}


// MARK: - 送礼界面（模态弹起）

/// 送礼界面视图控制器
/// 核心作用：以模态底部弹起方式展示礼物列表，支持选中、购买（接入 Store_Trace IAP）
/// 设计思路：全屏半透明遮罩 + gift_bg 图片面板（屏幕高 85%） + 三区礼物 + 底部购买按钮
/// 组件布局（底部对齐，间距 20）：buyButton ← section3 ← section2 ← section1
/// 关键方法：handleItemSelected_Trace（礼物选中），handleBuyTap_Trace（发起内购）
class GiftView_Trace: UIViewController {

    // MARK: - 常量

    private let panelH_Trace: CGFloat  = UIScreen.main.bounds.height * 0.85
    private let screenW_Trace: CGFloat = UIScreen.main.bounds.width
    /// Section3 每列固定 4 列，左右各 16pt 内边距
    private let s3SideInset_Trace: CGFloat = 16
    private let s3Cols_Trace: CGFloat      = 4
    private let s3ItemH_Trace: CGFloat     = 82
    private let s3LineSpacing_Trace: CGFloat = 12

    // MARK: - 数据

    private var topGifts_Trace: [StoreModel_Trace] = []
    private var limitGifts_Trace: [StoreModel_Trace] = []
    private var normalGifts_Trace: [StoreModel_Trace] = []
    private var selectedGift_Trace: StoreModel_Trace?
    private var allItemViews_Trace: [GiftItemView_Trace] = []

    // MARK: - UI 组件

    /// 全屏半透明遮罩（点击非面板区域关闭）
    private let overlayView_Trace: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    /// gift_bg 图片面板（屏幕宽度 × 屏幕高度60%，底部对齐）
    private let bgImageView_Trace: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = false
        iv.isUserInteractionEnabled = true
        return iv
    }()

    // ── Section1：HStack（gift_spe 固定170×32 + 顶部礼物平分剩余空间）────────

    /// Section1 水平容器（高度78，gift_spe 在左，礼物 fillEqually 在右）
    private let section1View_Trace = UIView()

    /// 装饰图片 gift_spe（固定 170×32，垂直居中于 78pt 行）
    private let speImageView_Trace: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_spe")
        iv.contentMode = .scaleAspectFit
        // 不被压缩/拉伸，维持固定宽度
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()

    /// 顶部礼物 fillEqually 容器（平分 gift_spe 右侧剩余空间）
    private let topGiftsContainer_Trace: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section2：HStack（限定礼物横向均分，图标 gift_three）────────────────

    private let section2Stack_Trace: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section3：手动网格（2行×4列，左右 inset16，行0=gift_four，行1=gift_five）──

    /// Section3 容器（通过 UIStackView 手动排列，避免 UICollectionView 选中回调不稳定的问题）
    private let section3View_Trace = UIView()

    // ── 购买按钮 ────────────────────────────────────────────────────────────

    private let buyButton_Trace: UIButton = {
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
        loadData_Trace()
        setupUI_Trace()
        buildSection1_Trace()
        buildSection2_Trace()
        buildSection3_Trace()
        bindActions_Trace()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePanelIn_Trace()
    }

    // MARK: - 数据加载

    private func loadData_Trace() {
        let all = Store_Trace.shared_Trace.goodsList_Trace
        topGifts_Trace    = all.filter { $0.goodIsTop_Trace == true }
        limitGifts_Trace  = all.filter { $0.goodIsSpecial_Trace == true }
        normalGifts_Trace = all.filter {
            $0.goodIsTop_Trace != true && $0.goodIsSpecial_Trace != true
        }
    }

    // MARK: - UI 搭建

    /// 主布局：遮罩 + gift_bg 面板 + 各组件（底部对齐，组件间距 20pt）
    private func setupUI_Trace() {
        view.addSubview(overlayView_Trace)
        overlayView_Trace.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(bgImageView_Trace)
        bgImageView_Trace.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(panelH_Trace)
        }

        // 购买按钮（布局起点，距面板底部 50）
        view.addSubview(buyButton_Trace)
        buyButton_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(62)
            make.bottom.equalTo(bgImageView_Trace.snp.bottom).offset(-70)
        }

        // Section3 手动网格（2行，高 = 2×82 + 12 = 176），距购买按钮 20
        view.addSubview(section3View_Trace)
        section3View_Trace.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Int(s3ItemH_Trace) * 2 + Int(s3LineSpacing_Trace))
            make.bottom.equalTo(buyButton_Trace.snp.top).offset(-20)
        }

        // Section2 限定礼物 HStack（高78），距 Section3 上方 20
        view.addSubview(section2Stack_Trace)
        section2Stack_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(78)
            make.bottom.equalTo(section3View_Trace.snp.top).offset(-20)
        }

        // Section1 HStack 容器（高度78，含 gift_spe + 礼物），距 Section2 上方 20
        view.addSubview(section1View_Trace)
        section1View_Trace.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(78)
            make.bottom.equalTo(section2Stack_Trace.snp.top).offset(-20)
        }

        // 初始位置在屏幕下方，等待滑入动画
        let offscreen = CGAffineTransform(translationX: 0, y: panelH_Trace)
        bgImageView_Trace.transform    = offscreen
        section1View_Trace.transform   = offscreen
        section2Stack_Trace.transform  = offscreen
        section3View_Trace.transform   = offscreen
        buyButton_Trace.transform      = offscreen
        overlayView_Trace.alpha        = 0
    }

    /// 构建 Section1：gift_spe(170×32)固定在左侧居中 + 顶部礼物 fillEqually 平分剩余宽度
    /// 图标依次使用 gift_one（第1个）、gift_two（第2个）
    private func buildSection1_Trace() {
        section1View_Trace.addSubview(speImageView_Trace)
        section1View_Trace.addSubview(topGiftsContainer_Trace)

        // gift_spe：左边距16，垂直居中，固定 170×32
        speImageView_Trace.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(170)
            make.height.equalTo(32)
        }

        // 礼物容器：紧贴 speImageView 右侧 8pt，右边距 16，高度填满 section1View（78pt）
        topGiftsContainer_Trace.snp.makeConstraints { make in
            make.leading.equalTo(speImageView_Trace.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }

        // 顶部礼物：按顺序使用 gift_one / gift_two
        let topImageNames_Trace = ["gift_one", "gift_two"]
        topGifts_Trace.enumerated().forEach { idx, gift in
            let imgName = idx < topImageNames_Trace.count
                ? topImageNames_Trace[idx]
                : "gift_\(gift.id_Trace ?? 1)"
            let itemView = makeGiftItemView_Trace(model: gift, imageName_Trace: imgName)
            topGiftsContainer_Trace.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section2：限定礼物横向均分，全部使用图标 gift_three
    private func buildSection2_Trace() {
        limitGifts_Trace.forEach { gift in
            let itemView = makeGiftItemView_Trace(model: gift, imageName_Trace: "gift_three")
            section2Stack_Trace.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section3：2行×4列手动网格
    /// 行0 使用图标 gift_four，行1 使用图标 gift_five
    /// 礼物均使用 GiftItemView_Trace（自带 onTap_Trace，选中状态由 handleItemSelected_Trace 统一管理）
    private func buildSection3_Trace() {
        // 按每行 4 个切分礼物数组
        let cols = Int(s3Cols_Trace)
        let rowImages = ["gift_four", "gift_five"]

        let vStack = UIStackView()
        vStack.axis        = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing     = s3LineSpacing_Trace

        for rowIdx in 0..<2 {
            let start = rowIdx * cols
            let end   = min(start + cols, normalGifts_Trace.count)
            guard start < end else { continue }

            let rowGifts = normalGifts_Trace[start..<end]
            let imgName  = rowIdx < rowImages.count ? rowImages[rowIdx] : "gift_four"

            let hStack = UIStackView()
            hStack.axis         = .horizontal
            hStack.distribution = .fillEqually
            hStack.spacing      = 8

            rowGifts.forEach { gift in
                let item = makeGiftItemView_Trace(model: gift, imageName_Trace: imgName)
                hStack.addArrangedSubview(item)
            }
            vStack.addArrangedSubview(hStack)
        }

        section3View_Trace.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Int(s3SideInset_Trace))
            make.trailing.equalToSuperview().offset(-Int(s3SideInset_Trace))
            make.top.bottom.equalToSuperview()
        }
    }

    // MARK: - 工厂方法

    /// 创建并注册 GiftItemView_Trace（支持自定义图片名）
    /// - Parameters:
    ///   - model: 礼物数据
    ///   - imageName_Trace: 指定图片名称（不传则按 gift_{id} 规则）
    private func makeGiftItemView_Trace(
        model: StoreModel_Trace,
        imageName_Trace: String? = nil
    ) -> GiftItemView_Trace {
        let v = GiftItemView_Trace()
        v.imageName_Trace = imageName_Trace
        v.model_Trace     = model
        v.onTap_Trace = { [weak self] selected in
            self?.handleItemSelected_Trace(model: selected)
        }
        allItemViews_Trace.append(v)
        return v
    }

    // MARK: - 动画

    private func animatePanelIn_Trace() {
        UIView.animate(
            withDuration: 0.38,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.overlayView_Trace.alpha        = 1
            self.bgImageView_Trace.transform    = .identity
            self.section1View_Trace.transform   = .identity
            self.section2Stack_Trace.transform  = .identity
            self.section3View_Trace.transform   = .identity
            self.buyButton_Trace.transform      = .identity
        }
    }

    private func animatePanelOut_Trace(completion_Trace: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.28) {
            self.overlayView_Trace.alpha = 0
            let t = CGAffineTransform(translationX: 0, y: self.panelH_Trace)
            self.bgImageView_Trace.transform   = t
            self.section1View_Trace.transform  = t
            self.section2Stack_Trace.transform = t
            self.section3View_Trace.transform  = t
            self.buyButton_Trace.transform     = t
        } completion: { _ in
            self.dismiss(animated: false, completion: completion_Trace)
        }
    }

    // MARK: - 选中处理

    /// 统一处理礼物选中（Section1/2/3 所有视图均在 allItemViews_Trace 中，直接遍历更新）
    private func handleItemSelected_Trace(model: StoreModel_Trace) {
        selectedGift_Trace = model
        allItemViews_Trace.forEach { v in
            v.isGiftSelected_Trace = (v.model_Trace?.id_Trace == model.id_Trace)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Trace() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap_Trace(_:)))
        // 不阻断面板内部视图（CollectionView、UIButton 等）的触摸传递
        tap.cancelsTouchesInView = false
        overlayView_Trace.addGestureRecognizer(tap)
        buyButton_Trace.addTarget(self, action: #selector(handleBuyTap_Trace), for: .touchUpInside)
    }

    /// 点击遮罩：仅当点击位置位于面板（bgImageView）区域外时才关闭界面
    @objc private func handleOverlayTap_Trace(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        // 触碰面板内部时不关闭，避免拦截 CollectionView cell 点击
        if bgImageView_Trace.frame.contains(point) { return }
        animatePanelOut_Trace()
    }

    @objc private func handleBuyTap_Trace() {
        guard let gift = selectedGift_Trace, let gid = gift.goodsId_Trace else {
            Utils_Trace.showWarning_Trace(message_Trace: "Please select a gift first.")
            return
        }
        buyButton_Trace.animatePressDown_Trace { self.buyButton_Trace.animatePressUp_Trace() }
        Store_Trace.shared_Trace.PurchaseStoreGift_Trace(gid_Trace: gid) { [weak self] in
            self?.animatePanelOut_Trace()
        }
    }
}

