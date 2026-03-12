import UIKit
import SnapKit

// MARK: - 礼物展示单项视图

/// 礼物展示单项通用视图
/// 核心作用：展示单个礼物的图标、名称（HStack）与价格（VStack），供 Section1/2 UIStackView 复用
/// imageName_Doze 可指定自定义图片名称，否则使用 gift_{id} 规则
/// 背景白色圆角20，选中时替换为浅紫色 #BE92FD
class GiftItemView_Doze: UIView {

    // MARK: - 常量
    private static let selectedBg_Doze = UIColor(hexstring_Doze: "#BE92FD").withAlphaComponent(0.35)

    // MARK: - 属性

    /// 礼物数据（set 后自动刷新 UI）
    var model_Doze: StoreModel_Doze? { didSet { fillData_Doze() } }

    /// 自定义图片名称，优先于 gift_{id} 规则
    var imageName_Doze: String? { didSet { fillData_Doze() } }

    /// 选中状态（set 后自动更新背景色）
    var isGiftSelected_Doze: Bool = false { didSet { updateSelectedState_Doze() } }

    /// 点击回调
    var onTap_Doze: ((StoreModel_Doze) -> Void)?

    // MARK: - UI 组件

    private let giftImageView_Doze: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor(hexstring_Doze: "#111111")
        lbl.textAlignment = .center
        return lbl
    }()

    private let priceLabel_Doze: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = UIColor(hexstring_Doze: "#111111")
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Doze()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// VStack：HStack(图片36×36 + 名称, 间距5) + 价格
    private func setupUI_Doze() {
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

        giftImageView_Doze.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        let topRow_Doze = UIStackView(arrangedSubviews: [giftImageView_Doze, nameLabel_Doze])
        topRow_Doze.axis = .horizontal
        topRow_Doze.spacing = 5
        topRow_Doze.alignment = .center

        let vStack_Doze = UIStackView(arrangedSubviews: [topRow_Doze, priceLabel_Doze])
        vStack_Doze.axis = .vertical
        vStack_Doze.spacing = 6
        vStack_Doze.alignment = .center

        addSubview(vStack_Doze)
        vStack_Doze.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(6)
            make.trailing.lessThanOrEqualToSuperview().offset(-6)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Doze))
        addGestureRecognizer(tap)
    }

    // MARK: - 数据填充

    private func fillData_Doze() {
        guard let m = model_Doze else { return }
        // 优先使用自定义图片名称，否则按 gift_{id} 规则
        let name = imageName_Doze ?? "gift_\(m.id_Doze ?? 1)"
        giftImageView_Doze.image = UIImage(named: name)
        nameLabel_Doze.text  = m.goodsName_Doze
        priceLabel_Doze.text = m.goodsPrice_Doze
    }

    private func updateSelectedState_Doze() {
        backgroundColor = isGiftSelected_Doze ? Self.selectedBg_Doze : .white
    }

    @objc private func handleTap_Doze() {
        guard let m = model_Doze else { return }
        onTap_Doze?(m)
    }
}


// MARK: - 送礼界面（模态弹起）

/// 送礼界面视图控制器
/// 核心作用：以模态底部弹起方式展示礼物列表，支持选中、购买（接入 Store_Doze IAP）
/// 设计思路：全屏半透明遮罩 + gift_bg 图片面板（屏幕高 85%） + 三区礼物 + 底部购买按钮
/// 组件布局（底部对齐，间距 20）：buyButton ← section3 ← section2 ← section1
/// 关键方法：handleItemSelected_Doze（礼物选中），handleBuyTap_Doze（发起内购）
class GiftView_Doze: UIViewController {

    // MARK: - 常量

    private let panelH_Doze: CGFloat  = UIScreen.main.bounds.height * 0.85
    private let screenW_Doze: CGFloat = UIScreen.main.bounds.width
    /// Section3 每列固定 4 列，左右各 16pt 内边距
    private let s3SideInset_Doze: CGFloat = 16
    private let s3Cols_Doze: CGFloat      = 4
    private let s3ItemH_Doze: CGFloat     = 82
    private let s3LineSpacing_Doze: CGFloat = 12

    // MARK: - 数据

    private var topGifts_Doze: [StoreModel_Doze] = []
    private var limitGifts_Doze: [StoreModel_Doze] = []
    private var normalGifts_Doze: [StoreModel_Doze] = []
    private var selectedGift_Doze: StoreModel_Doze?
    private var allItemViews_Doze: [GiftItemView_Doze] = []

    // MARK: - UI 组件

    /// 全屏半透明遮罩（点击非面板区域关闭）
    private let overlayView_Doze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    /// gift_bg 图片面板（屏幕宽度 × 屏幕高度60%，底部对齐）
    private let bgImageView_Doze: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = false
        iv.isUserInteractionEnabled = true
        return iv
    }()

    // ── Section1：HStack（gift_spe 固定170×32 + 顶部礼物平分剩余空间）────────

    /// Section1 水平容器（高度78，gift_spe 在左，礼物 fillEqually 在右）
    private let section1View_Doze = UIView()

    /// 装饰图片 gift_spe（固定 170×32，垂直居中于 78pt 行）
    private let speImageView_Doze: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_spe")
        iv.contentMode = .scaleAspectFit
        // 不被压缩/拉伸，维持固定宽度
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()

    /// 顶部礼物 fillEqually 容器（平分 gift_spe 右侧剩余空间）
    private let topGiftsContainer_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section2：HStack（限定礼物横向均分，图标 gift_three）────────────────

    private let section2Stack_Doze: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section3：手动网格（2行×4列，左右 inset16，行0=gift_four，行1=gift_five）──

    /// Section3 容器（通过 UIStackView 手动排列，避免 UICollectionView 选中回调不稳定的问题）
    private let section3View_Doze = UIView()

    // ── 购买按钮 ────────────────────────────────────────────────────────────

    private let buyButton_Doze: UIButton = {
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
        loadData_Doze()
        setupUI_Doze()
        buildSection1_Doze()
        buildSection2_Doze()
        buildSection3_Doze()
        bindActions_Doze()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePanelIn_Doze()
    }

    // MARK: - 数据加载

    private func loadData_Doze() {
        let all = Store_Doze.shared_Doze.goodsList_Doze
        topGifts_Doze    = all.filter { $0.goodIsTop_Doze == true }
        limitGifts_Doze  = all.filter { $0.goodIsSpecial_Doze == true }
        normalGifts_Doze = all.filter {
            $0.goodIsTop_Doze != true && $0.goodIsSpecial_Doze != true
        }
    }

    // MARK: - UI 搭建

    /// 主布局：遮罩 + gift_bg 面板 + 各组件（底部对齐，组件间距 20pt）
    private func setupUI_Doze() {
        view.addSubview(overlayView_Doze)
        overlayView_Doze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(bgImageView_Doze)
        bgImageView_Doze.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(panelH_Doze)
        }

        // 购买按钮（布局起点，距面板底部 50）
        view.addSubview(buyButton_Doze)
        buyButton_Doze.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(62)
            make.bottom.equalTo(bgImageView_Doze.snp.bottom).offset(-70)
        }

        // Section3 手动网格（2行，高 = 2×82 + 12 = 176），距购买按钮 20
        view.addSubview(section3View_Doze)
        section3View_Doze.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Int(s3ItemH_Doze) * 2 + Int(s3LineSpacing_Doze))
            make.bottom.equalTo(buyButton_Doze.snp.top).offset(-20)
        }

        // Section2 限定礼物 HStack（高78），距 Section3 上方 20
        view.addSubview(section2Stack_Doze)
        section2Stack_Doze.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(78)
            make.bottom.equalTo(section3View_Doze.snp.top).offset(-20)
        }

        // Section1 HStack 容器（高度78，含 gift_spe + 礼物），距 Section2 上方 20
        view.addSubview(section1View_Doze)
        section1View_Doze.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(78)
            make.bottom.equalTo(section2Stack_Doze.snp.top).offset(-20)
        }

        // 初始位置在屏幕下方，等待滑入动画
        let offscreen = CGAffineTransform(translationX: 0, y: panelH_Doze)
        bgImageView_Doze.transform    = offscreen
        section1View_Doze.transform   = offscreen
        section2Stack_Doze.transform  = offscreen
        section3View_Doze.transform   = offscreen
        buyButton_Doze.transform      = offscreen
        overlayView_Doze.alpha        = 0
    }

    /// 构建 Section1：gift_spe(170×32)固定在左侧居中 + 顶部礼物 fillEqually 平分剩余宽度
    /// 图标依次使用 gift_one（第1个）、gift_two（第2个）
    private func buildSection1_Doze() {
        section1View_Doze.addSubview(speImageView_Doze)
        section1View_Doze.addSubview(topGiftsContainer_Doze)

        // gift_spe：左边距16，垂直居中，固定 170×32
        speImageView_Doze.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(170)
            make.height.equalTo(32)
        }

        // 礼物容器：紧贴 speImageView 右侧 8pt，右边距 16，高度填满 section1View（78pt）
        topGiftsContainer_Doze.snp.makeConstraints { make in
            make.leading.equalTo(speImageView_Doze.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }

        // 顶部礼物：按顺序使用 gift_one / gift_two
        let topImageNames_Doze = ["gift_one", "gift_two"]
        topGifts_Doze.enumerated().forEach { idx, gift in
            let imgName = idx < topImageNames_Doze.count
                ? topImageNames_Doze[idx]
                : "gift_\(gift.id_Doze ?? 1)"
            let itemView = makeGiftItemView_Doze(model: gift, imageName_Doze: imgName)
            topGiftsContainer_Doze.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section2：限定礼物横向均分，全部使用图标 gift_three
    private func buildSection2_Doze() {
        limitGifts_Doze.forEach { gift in
            let itemView = makeGiftItemView_Doze(model: gift, imageName_Doze: "gift_three")
            section2Stack_Doze.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section3：2行×4列手动网格
    /// 行0 使用图标 gift_four，行1 使用图标 gift_five
    /// 礼物均使用 GiftItemView_Doze（自带 onTap_Doze，选中状态由 handleItemSelected_Doze 统一管理）
    private func buildSection3_Doze() {
        // 按每行 4 个切分礼物数组
        let cols = Int(s3Cols_Doze)
        let rowImages = ["gift_four", "gift_five"]

        let vStack = UIStackView()
        vStack.axis        = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing     = s3LineSpacing_Doze

        for rowIdx in 0..<2 {
            let start = rowIdx * cols
            let end   = min(start + cols, normalGifts_Doze.count)
            guard start < end else { continue }

            let rowGifts = normalGifts_Doze[start..<end]
            let imgName  = rowIdx < rowImages.count ? rowImages[rowIdx] : "gift_three"

            let hStack = UIStackView()
            hStack.axis         = .horizontal
            hStack.distribution = .fillEqually
            hStack.spacing      = 8

            rowGifts.forEach { gift in
                let item = makeGiftItemView_Doze(model: gift, imageName_Doze: imgName)
                hStack.addArrangedSubview(item)
            }
            vStack.addArrangedSubview(hStack)
        }

        section3View_Doze.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Int(s3SideInset_Doze))
            make.trailing.equalToSuperview().offset(-Int(s3SideInset_Doze))
            make.top.bottom.equalToSuperview()
        }
    }

    // MARK: - 工厂方法

    /// 创建并注册 GiftItemView_Doze（支持自定义图片名）
    /// - Parameters:
    ///   - model: 礼物数据
    ///   - imageName_Doze: 指定图片名称（不传则按 gift_{id} 规则）
    private func makeGiftItemView_Doze(
        model: StoreModel_Doze,
        imageName_Doze: String? = nil
    ) -> GiftItemView_Doze {
        let v = GiftItemView_Doze()
        v.imageName_Doze = imageName_Doze
        v.model_Doze     = model
        v.onTap_Doze = { [weak self] selected in
            self?.handleItemSelected_Doze(model: selected)
        }
        allItemViews_Doze.append(v)
        return v
    }

    // MARK: - 动画

    private func animatePanelIn_Doze() {
        UIView.animate(
            withDuration: 0.38,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.overlayView_Doze.alpha        = 1
            self.bgImageView_Doze.transform    = .identity
            self.section1View_Doze.transform   = .identity
            self.section2Stack_Doze.transform  = .identity
            self.section3View_Doze.transform   = .identity
            self.buyButton_Doze.transform      = .identity
        }
    }

    private func animatePanelOut_Doze(completion_Doze: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.28) {
            self.overlayView_Doze.alpha = 0
            let t = CGAffineTransform(translationX: 0, y: self.panelH_Doze)
            self.bgImageView_Doze.transform   = t
            self.section1View_Doze.transform  = t
            self.section2Stack_Doze.transform = t
            self.section3View_Doze.transform  = t
            self.buyButton_Doze.transform     = t
        } completion: { _ in
            self.dismiss(animated: false, completion: completion_Doze)
        }
    }

    // MARK: - 选中处理

    /// 统一处理礼物选中（Section1/2/3 所有视图均在 allItemViews_Doze 中，直接遍历更新）
    private func handleItemSelected_Doze(model: StoreModel_Doze) {
        selectedGift_Doze = model
        allItemViews_Doze.forEach { v in
            v.isGiftSelected_Doze = (v.model_Doze?.id_Doze == model.id_Doze)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Doze() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap_Doze(_:)))
        // 不阻断面板内部视图（CollectionView、UIButton 等）的触摸传递
        tap.cancelsTouchesInView = false
        overlayView_Doze.addGestureRecognizer(tap)
        buyButton_Doze.addTarget(self, action: #selector(handleBuyTap_Doze), for: .touchUpInside)
    }

    /// 点击遮罩：仅当点击位置位于面板（bgImageView）区域外时才关闭界面
    @objc private func handleOverlayTap_Doze(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        // 触碰面板内部时不关闭，避免拦截 CollectionView cell 点击
        if bgImageView_Doze.frame.contains(point) { return }
        animatePanelOut_Doze()
    }

    @objc private func handleBuyTap_Doze() {
        guard let gift = selectedGift_Doze, let gid = gift.goodsId_Doze else {
            Utils_Doze.showWarning_Doze(message_Doze: "Please select a gift first.")
            return
        }
        buyButton_Doze.animatePressDown_Doze { self.buyButton_Doze.animatePressUp_Doze() }
        Store_Doze.shared_Doze.PurchaseStoreGift_Doze(gid_Doze: gid) { [weak self] in
            self?.animatePanelOut_Doze()
        }
    }
}

