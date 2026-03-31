import UIKit
import SnapKit

// MARK: - 礼物展示单项视图

/// 礼物展示单项通用视图
/// 核心作用：展示单个礼物的图标、名称（HStack）与价格（VStack），供 Section1/2 UIStackView 复用
/// imageName_Flick 可指定自定义图片名称，否则使用 gift_{id} 规则
/// 背景白色圆角20，选中时替换为浅紫色 #BE92FD
class GiftItemView_Flick: UIView {

    // MARK: - 常量

    /// 选中背景色：白色
    private static let selectedBg_Flick  = UIColor.white
    /// 未选中背景色：#07152A 透明度 20%
    private static let normalBg_Flick    = UIColor(hexstring_Flick: "#07152A").withAlphaComponent(0.2)
    /// 选中文字颜色：黑色
    private static let selectedText_Flick = UIColor(hexstring_Flick: "#111111")
    /// 未选中文字颜色：白色
    private static let normalText_Flick   = UIColor.white

    // MARK: - 属性

    /// 礼物数据（set 后自动刷新 UI）
    var model_Flick: StoreModel_Flick? { didSet { fillData_Flick() } }

    /// 自定义图片名称，优先于 gift_{id} 规则
    var imageName_Flick: String? { didSet { fillData_Flick() } }

    /// 选中状态（set 后自动更新背景色）
    var isGiftSelected_Flick: Bool = false { didSet { updateSelectedState_Flick() } }

    /// 点击回调
    var onTap_Flick: ((StoreModel_Flick) -> Void)?

    // MARK: - UI 组件

    private let giftImageView_Flick: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        // 未选中时白色，选中时由 updateSelectedState_Flick 切换为黑色
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        return lbl
    }()

    private let priceLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        // 未选中时白色，选中时由 updateSelectedState_Flick 切换为黑色
        lbl.textColor = UIColor.white
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Flick()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// VStack：HStack(图片36×36 + 名称, 间距5) + 价格
    private func setupUI_Flick() {
        // 未选中：#07152A 20% 半透明背景
        backgroundColor     = Self.normalBg_Flick
        layer.cornerRadius  = 20
        layer.masksToBounds = true
        isUserInteractionEnabled = true

        giftImageView_Flick.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        let topRow_Flick = UIStackView(arrangedSubviews: [giftImageView_Flick, nameLabel_Flick])
        topRow_Flick.axis = .horizontal
        topRow_Flick.spacing = 5
        topRow_Flick.alignment = .center

        let vStack_Flick = UIStackView(arrangedSubviews: [topRow_Flick, priceLabel_Flick])
        vStack_Flick.axis = .vertical
        vStack_Flick.spacing = 6
        vStack_Flick.alignment = .center

        addSubview(vStack_Flick)
        vStack_Flick.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(6)
            make.trailing.lessThanOrEqualToSuperview().offset(-6)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Flick))
        addGestureRecognizer(tap)
    }

    // MARK: - 数据填充

    private func fillData_Flick() {
        guard let m = model_Flick else { return }
        // 优先使用自定义图片名称，否则按 gift_{id} 规则
        let name = imageName_Flick ?? "gift_\(m.id_Flick ?? 1)"
        giftImageView_Flick.image = UIImage(named: name)
        nameLabel_Flick.text  = m.goodsName_Flick
        priceLabel_Flick.text = m.goodsPrice_Flick
    }

    /// 根据选中状态同步背景色与文字颜色
    private func updateSelectedState_Flick() {
        backgroundColor = isGiftSelected_Flick ? Self.selectedBg_Flick : Self.normalBg_Flick
        let textColor   = isGiftSelected_Flick ? Self.selectedText_Flick : Self.normalText_Flick
        nameLabel_Flick.textColor  = textColor
        priceLabel_Flick.textColor = textColor
    }

    @objc private func handleTap_Flick() {
        guard let m = model_Flick else { return }
        onTap_Flick?(m)
    }
}


// MARK: - 送礼界面（模态弹起）

/// 送礼界面视图控制器
/// 核心作用：以模态底部弹起方式展示礼物列表，支持选中、购买（接入 Store_Flick IAP）
/// 设计思路：全屏半透明遮罩 + gift_bg 图片面板（屏幕高 85%） + 三区礼物 + 底部购买按钮
/// 组件布局（底部对齐，间距 20）：buyButton ← section3 ← section2 ← section1
/// 关键方法：handleItemSelected_Flick（礼物选中），handleBuyTap_Flick（发起内购）
class GiftView_Flick: UIViewController {

    // MARK: - 常量

    private let panelH_Flick: CGFloat  = UIScreen.main.bounds.height * 0.80
    private let screenW_Flick: CGFloat = UIScreen.main.bounds.width
    /// Section3 每列固定 4 列，左右各 16pt 内边距
    private let s3SideInset_Flick: CGFloat = 16
    private let s3Cols_Flick: CGFloat      = 4
    private let s3ItemH_Flick: CGFloat     = 82
    private let s3LineSpacing_Flick: CGFloat = 12

    // MARK: - 数据

    private var topGifts_Flick: [StoreModel_Flick] = []
    private var limitGifts_Flick: [StoreModel_Flick] = []
    private var normalGifts_Flick: [StoreModel_Flick] = []
    private var selectedGift_Flick: StoreModel_Flick?
    private var allItemViews_Flick: [GiftItemView_Flick] = []

    // MARK: - UI 组件

    /// 全屏半透明遮罩（点击非面板区域关闭）
    private let overlayView_Flick: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    /// gift_bg 图片面板（屏幕宽度 × 屏幕高度60%，底部对齐）
    private let bgImageView_Flick: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = false
        iv.isUserInteractionEnabled = true
        return iv
    }()

    // ── Section1：VStack（gift_spe 194×40 居左 + 顶部礼物横向均分）────────────

    /// Section1 垂直容器（gift_spe 居左在上，礼物 fillEqually 在下）
    private let section1View_Flick = UIView()

    /// 装饰图片 gift_spe（固定 194×40，居左对齐）
    private let speImageView_Flick: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_spe")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 顶部礼物 fillEqually 容器（横向均分，位于 gift_spe 下方）
    private let topGiftsContainer_Flick: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section1 与 Section2 之间的分区标题 ────────────────────────────────

    /// "Ordinary Gift" 标题标签（16号加粗，白色，居左）
    private let ordinaryGiftLabel_Flick: UILabel = {
        let lbl = UILabel()
        lbl.text = "Ordinary Gift"
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = .white
        lbl.textAlignment = .left
        return lbl
    }()

    // ── Section2：HStack（限定礼物横向均分，图标 gift_three）────────────────

    private let section2Stack_Flick: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section3：手动网格（2行×4列，左右 inset16，行0=gift_four，行1=gift_five）──

    /// Section3 容器（通过 UIStackView 手动排列，避免 UICollectionView 选中回调不稳定的问题）
    private let section3View_Flick = UIView()

    // ── 购买按钮 ────────────────────────────────────────────────────────────

    private let buyButton_Flick: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "gift_buy"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.clipsToBounds = true
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        loadData_Flick()
        setupUI_Flick()
        buildSection1_Flick()
        buildSection2_Flick()
        buildSection3_Flick()
        bindActions_Flick()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePanelIn_Flick()
    }

    // MARK: - 数据加载

    private func loadData_Flick() {
        let all = Store_Flick.shared_Flick.goodsList_Flick
        topGifts_Flick    = all.filter { $0.goodIsTop_Flick == true }
        limitGifts_Flick  = all.filter { $0.goodIsSpecial_Flick == true }
        normalGifts_Flick = all.filter {
            $0.goodIsTop_Flick != true && $0.goodIsSpecial_Flick != true
        }
    }

    // MARK: - UI 搭建

    /// 主布局：遮罩 + gift_bg 面板 + 各组件（底部对齐，组件间距 20pt）
    private func setupUI_Flick() {
        view.addSubview(overlayView_Flick)
        overlayView_Flick.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(bgImageView_Flick)
        bgImageView_Flick.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(panelH_Flick)
        }

        // 购买按钮（布局起点，距面板底部 50）
        view.addSubview(buyButton_Flick)
        buyButton_Flick.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(62)
            make.bottom.equalTo(bgImageView_Flick.snp.bottom).offset(-65)
        }

        // Section3 手动网格（2行，高 = 2×82 + 12 = 176），距购买按钮 20
        view.addSubview(section3View_Flick)
        section3View_Flick.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Int(s3ItemH_Flick) * 2 + Int(s3LineSpacing_Flick))
            make.bottom.equalTo(buyButton_Flick.snp.top).offset(-20)
        }

        // Section2 限定礼物 HStack（高78），距 Section3 上方 20
        view.addSubview(section2Stack_Flick)
        section2Stack_Flick.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(78)
            make.bottom.equalTo(section3View_Flick.snp.top).offset(-20)
        }

        // "Ordinary Gift" 分区标题，紧贴 Section2 上方 12pt
        view.addSubview(ordinaryGiftLabel_Flick)
        ordinaryGiftLabel_Flick.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(section2Stack_Flick.snp.top).offset(-12)
        }

        // Section1 VStack 容器（gift_spe 40 + 间距 8 + 礼物行 78 = 126），紧贴 ordinaryGiftLabel 上方 12pt
        view.addSubview(section1View_Flick)
        section1View_Flick.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(126)
            make.bottom.equalTo(ordinaryGiftLabel_Flick.snp.top).offset(-12)
        }

        // 初始位置在屏幕下方，等待滑入动画
        let offscreen = CGAffineTransform(translationX: 0, y: panelH_Flick)
        bgImageView_Flick.transform          = offscreen
        section1View_Flick.transform         = offscreen
        ordinaryGiftLabel_Flick.transform    = offscreen
        section2Stack_Flick.transform        = offscreen
        section3View_Flick.transform         = offscreen
        buyButton_Flick.transform            = offscreen
        overlayView_Flick.alpha              = 0
    }

    /// 构建 Section1：VStack 布局
    /// 上方：gift_spe（194×40）居左对齐
    /// 下方：顶部礼物横向 fillEqually 均分（左右各 16pt 内边距）
    private func buildSection1_Flick() {
        section1View_Flick.addSubview(speImageView_Flick)
        section1View_Flick.addSubview(topGiftsContainer_Flick)

        // gift_spe：左边距 16，顶部对齐，固定 194×40
        speImageView_Flick.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview()
            make.width.equalTo(194)
            make.height.equalTo(40)
        }

        // 礼物容器：位于 gift_spe 下方 8pt，左右各 16pt，底部对齐 section1View
        topGiftsContainer_Flick.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(speImageView_Flick.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }

        // 顶部礼物：按顺序使用 gift_one / gift_two / gift_three
        let topImageNames_Flick = ["gift_one", "gift_two", "gift_three"]
        topGifts_Flick.enumerated().forEach { idx, gift in
            let imgName = idx < topImageNames_Flick.count
                ? topImageNames_Flick[idx]
                : "gift_\(gift.id_Flick ?? 1)"
            let itemView = makeGiftItemView_Flick(model: gift, imageName_Flick: imgName)
            topGiftsContainer_Flick.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section2：限定礼物横向均分，全部使用图标 gift_four
    private func buildSection2_Flick() {
        limitGifts_Flick.forEach { gift in
            let itemView = makeGiftItemView_Flick(model: gift, imageName_Flick: "gift_four")
            section2Stack_Flick.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section3：2行×4列手动网格
    /// 行0 使用图标 gift_five，行1 使用图标 gift_six
    /// 礼物均使用 GiftItemView_Flick（自带 onTap_Flick，选中状态由 handleItemSelected_Flick 统一管理）
    private func buildSection3_Flick() {
        // 按每行 4 个切分礼物数组
        let cols = Int(s3Cols_Flick)
        let rowImages = ["gift_five", "gift_six"]

        let vStack = UIStackView()
        vStack.axis        = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing     = s3LineSpacing_Flick

        for rowIdx in 0..<2 {
            let start = rowIdx * cols
            let end   = min(start + cols, normalGifts_Flick.count)
            guard start < end else { continue }

            let rowGifts = normalGifts_Flick[start..<end]
            let imgName  = rowIdx < rowImages.count ? rowImages[rowIdx] : "gift_three"

            let hStack = UIStackView()
            hStack.axis         = .horizontal
            hStack.distribution = .fillEqually
            hStack.spacing      = 8

            rowGifts.forEach { gift in
                let item = makeGiftItemView_Flick(model: gift, imageName_Flick: imgName)
                hStack.addArrangedSubview(item)
            }
            vStack.addArrangedSubview(hStack)
        }

        section3View_Flick.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Int(s3SideInset_Flick))
            make.trailing.equalToSuperview().offset(-Int(s3SideInset_Flick))
            make.top.bottom.equalToSuperview()
        }
    }

    // MARK: - 工厂方法

    /// 创建并注册 GiftItemView_Flick（支持自定义图片名）
    /// - Parameters:
    ///   - model: 礼物数据
    ///   - imageName_Flick: 指定图片名称（不传则按 gift_{id} 规则）
    private func makeGiftItemView_Flick(
        model: StoreModel_Flick,
        imageName_Flick: String? = nil
    ) -> GiftItemView_Flick {
        let v = GiftItemView_Flick()
        v.imageName_Flick = imageName_Flick
        v.model_Flick     = model
        v.onTap_Flick = { [weak self] selected in
            self?.handleItemSelected_Flick(model: selected)
        }
        allItemViews_Flick.append(v)
        return v
    }

    // MARK: - 动画

    private func animatePanelIn_Flick() {
        UIView.animate(
            withDuration: 0.38,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.overlayView_Flick.alpha               = 1
            self.bgImageView_Flick.transform           = .identity
            self.section1View_Flick.transform          = .identity
            self.ordinaryGiftLabel_Flick.transform     = .identity
            self.section2Stack_Flick.transform         = .identity
            self.section3View_Flick.transform          = .identity
            self.buyButton_Flick.transform             = .identity
        }
    }

    private func animatePanelOut_Flick(completion_Flick: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.28) {
            self.overlayView_Flick.alpha = 0
            let t = CGAffineTransform(translationX: 0, y: self.panelH_Flick)
            self.bgImageView_Flick.transform          = t
            self.section1View_Flick.transform         = t
            self.ordinaryGiftLabel_Flick.transform    = t
            self.section2Stack_Flick.transform        = t
            self.section3View_Flick.transform         = t
            self.buyButton_Flick.transform            = t
        } completion: { _ in
            self.dismiss(animated: false, completion: completion_Flick)
        }
    }

    // MARK: - 选中处理

    /// 统一处理礼物选中（Section1/2/3 所有视图均在 allItemViews_Flick 中，直接遍历更新）
    private func handleItemSelected_Flick(model: StoreModel_Flick) {
        selectedGift_Flick = model
        allItemViews_Flick.forEach { v in
            v.isGiftSelected_Flick = (v.model_Flick?.id_Flick == model.id_Flick)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Flick() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap_Flick(_:)))
        // 不阻断面板内部视图（CollectionView、UIButton 等）的触摸传递
        tap.cancelsTouchesInView = false
        overlayView_Flick.addGestureRecognizer(tap)
        buyButton_Flick.addTarget(self, action: #selector(handleBuyTap_Flick), for: .touchUpInside)
    }

    /// 点击遮罩：仅当点击位置位于面板（bgImageView）区域外时才关闭界面
    @objc private func handleOverlayTap_Flick(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        // 触碰面板内部时不关闭，避免拦截 CollectionView cell 点击
        if bgImageView_Flick.frame.contains(point) { return }
        animatePanelOut_Flick()
    }

    @objc private func handleBuyTap_Flick() {
        guard let gift = selectedGift_Flick, let gid = gift.goodsId_Flick else {
            Utils_Flick.showWarning_Flick(message_Flick: "Please select a gift first.")
            return
        }
        buyButton_Flick.animatePressDown_Flick { self.buyButton_Flick.animatePressUp_Flick() }
        Store_Flick.shared_Flick.PurchaseStoreGift_Flick(gid_Flick: gid) { [weak self] in
            self?.animatePanelOut_Flick()
        }
    }
}

