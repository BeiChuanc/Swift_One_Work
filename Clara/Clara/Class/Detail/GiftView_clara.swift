import UIKit
import SnapKit

// MARK: - 礼物展示单项视图

/// 礼物展示单项通用视图
/// 核心作用：展示单个礼物的图标、名称（HStack）与价格（VStack），供 Section1/2 UIStackView 复用
/// imageName_Clara 可指定自定义图片名称，否则使用 gift_{id} 规则
/// 背景白色圆角20，选中时替换为浅紫色 #BE92FD
class GiftItemView_Clara: UIView {

    // MARK: - 常量

    /// 选中背景色：白色
    private static let selectedBg_Clara  = UIColor(hexstring_Clara: "#000000",alpha_Clara: 0.35)
    /// 未选中背景色：#07152A 透明度 20%
    private static let normalBg_Clara    = UIColor.white
    /// 选中文字颜色：黑色
    private static let selectedText_Clara = UIColor.white
    /// 未选中文字颜色：白色
    private static let normalText_Clara   = UIColor(hexstring_Clara: "#FF3880")

    // MARK: - 属性

    /// 礼物数据（set 后自动刷新 UI）
    var model_Clara: StoreModel_Clara? { didSet { fillData_Clara() } }

    /// 自定义图片名称，优先于 gift_{id} 规则
    var imageName_Clara: String? { didSet { fillData_Clara() } }

    /// 选中状态（set 后自动更新背景色）
    var isGiftSelected_Clara: Bool = false { didSet { updateSelectedState_Clara() } }

    /// 点击回调
    var onTap_Clara: ((StoreModel_Clara) -> Void)?

    // MARK: - UI 组件

    private let giftImageView_Clara: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Clara: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        // 未选中时白色，选中时由 updateSelectedState_Clara 切换为黑色
        lbl.textColor = UIColor(hexstring_Clara: "#FF3880")
        lbl.textAlignment = .center
        return lbl
    }()

    private let priceLabel_Clara: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        // 未选中时白色，选中时由 updateSelectedState_Clara 切换为黑色
        lbl.textColor = UIColor(hexstring_Clara: "#FF3880")
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Clara()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// VStack：HStack(图片36×36 + 名称, 间距5) + 价格
    private func setupUI_Clara() {
        // 未选中：#07152A 20% 半透明背景
        backgroundColor     = Self.normalBg_Clara
        layer.cornerRadius  = 20
        layer.masksToBounds = true
        isUserInteractionEnabled = true

        giftImageView_Clara.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        let topRow_Clara = UIStackView(arrangedSubviews: [giftImageView_Clara, nameLabel_Clara])
        topRow_Clara.axis = .horizontal
        topRow_Clara.spacing = 5
        topRow_Clara.alignment = .center

        let vStack_Clara = UIStackView(arrangedSubviews: [topRow_Clara, priceLabel_Clara])
        vStack_Clara.axis = .vertical
        vStack_Clara.spacing = 6
        vStack_Clara.alignment = .center

        addSubview(vStack_Clara)
        vStack_Clara.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(6)
            make.trailing.lessThanOrEqualToSuperview().offset(-6)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Clara))
        addGestureRecognizer(tap)
    }

    // MARK: - 数据填充

    private func fillData_Clara() {
        guard let m = model_Clara else { return }
        // 优先使用自定义图片名称，否则按 gift_{id} 规则
        let name = imageName_Clara ?? "gift_\(m.id_Clara ?? 1)"
        giftImageView_Clara.image = UIImage(named: name)
        nameLabel_Clara.text  = m.goodsName_Clara
        priceLabel_Clara.text = m.goodsPrice_Clara
    }

    /// 根据选中状态同步背景色与文字颜色
    private func updateSelectedState_Clara() {
        backgroundColor = isGiftSelected_Clara ? Self.selectedBg_Clara : Self.normalBg_Clara
        let textColor   = isGiftSelected_Clara ? Self.selectedText_Clara : Self.normalText_Clara
        nameLabel_Clara.textColor  = textColor
        priceLabel_Clara.textColor = textColor
    }

    @objc private func handleTap_Clara() {
        guard let m = model_Clara else { return }
        onTap_Clara?(m)
    }
}


// MARK: - 送礼界面（模态弹起）

/// 送礼界面视图控制器
/// 核心作用：以模态底部弹起方式展示礼物列表，支持选中、购买（接入 Store_Clara IAP）
/// 设计思路：全屏半透明遮罩 + gift_bg 图片面板（屏幕高 85%） + 三区礼物 + 底部购买按钮
/// 组件布局（底部对齐，间距 20）：buyButton ← section3 ← section2 ← section1
/// 关键方法：handleItemSelected_Clara（礼物选中），handleBuyTap_Clara（发起内购）
class GiftView_Clara: UIViewController {

    // MARK: - 常量

    private let panelH_Clara: CGFloat  = UIScreen.main.bounds.height * 0.85
    private let screenW_Clara: CGFloat = UIScreen.main.bounds.width
    /// Section3 每列固定 4 列，左右各 16pt 内边距
    private let s3SideInset_Clara: CGFloat = 16
    private let s3Cols_Clara: CGFloat      = 4
    private let s3ItemH_Clara: CGFloat     = 82
    private let s3LineSpacing_Clara: CGFloat = 12

    // MARK: - 数据

    private var topGifts_Clara: [StoreModel_Clara] = []
    private var limitGifts_Clara: [StoreModel_Clara] = []
    private var normalGifts_Clara: [StoreModel_Clara] = []
    private var selectedGift_Clara: StoreModel_Clara?
    private var allItemViews_Clara: [GiftItemView_Clara] = []

    // MARK: - UI 组件

    /// 全屏半透明遮罩（点击非面板区域关闭）
    private let overlayView_Clara: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    /// gift_bg 图片面板（屏幕宽度 × 屏幕高度60%，底部对齐）
    private let bgImageView_Clara: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = false
        iv.isUserInteractionEnabled = true
        return iv
    }()

    // ── Section1：VStack（gift_spe 194×40 居左 + 顶部礼物横向均分）────────────

    /// Section1 垂直容器（gift_spe 居左在上，礼物 fillEqually 在下）
    private let section1View_Clara = UIView()

    /// 装饰图片 gift_spe（固定 194×40，居左对齐）
    private let speImageView_Clara: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_spe")
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 顶部礼物 fillEqually 容器（横向均分，位于 gift_spe 下方）
    private let topGiftsContainer_Clara: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section1 与 Section2 之间的分区标题 ────────────────────────────────

    /// "Ordinary Gift" 标题标签（16号加粗，白色，居左）
    private let ordinaryGiftLabel_Clara: UILabel = {
        let lbl = UILabel()
        lbl.text = "Ordinary Gift"
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = .black
        lbl.textAlignment = .left
        return lbl
    }()

    // ── Section2：HStack（限定礼物横向均分，图标 gift_three）────────────────

    private let section2Stack_Clara: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section3：手动网格（2行×4列，左右 inset16，行0=gift_four，行1=gift_five）──

    /// Section3 容器（通过 UIStackView 手动排列，避免 UICollectionView 选中回调不稳定的问题）
    private let section3View_Clara = UIView()

    // ── 购买按钮 ────────────────────────────────────────────────────────────

    private let buyButton_Clara: UIButton = {
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
        loadData_Clara()
        setupUI_Clara()
        buildSection1_Clara()
        buildSection2_Clara()
        buildSection3_Clara()
        bindActions_Clara()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePanelIn_Clara()
    }

    // MARK: - 数据加载

    private func loadData_Clara() {
        let all = Store_Clara.shared_Clara.goodsList_Clara
        topGifts_Clara    = all.filter { $0.goodIsTop_Clara == true }
        limitGifts_Clara  = all.filter { $0.goodIsSpecial_Clara == true }
        normalGifts_Clara = all.filter {
            $0.goodIsTop_Clara != true && $0.goodIsSpecial_Clara != true
        }
    }

    // MARK: - UI 搭建

    /// 主布局：遮罩 + gift_bg 面板 + 各组件（底部对齐，组件间距 20pt）
    private func setupUI_Clara() {
        view.addSubview(overlayView_Clara)
        overlayView_Clara.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(bgImageView_Clara)
        bgImageView_Clara.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(panelH_Clara)
        }

        // 购买按钮（布局起点，距面板底部 50）
        view.addSubview(buyButton_Clara)
        buyButton_Clara.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(62)
            make.bottom.equalTo(bgImageView_Clara.snp.bottom).offset(-60)
        }

        // Section3 手动网格（2行，高 = 2×82 + 12 = 176），距购买按钮 20
        view.addSubview(section3View_Clara)
        section3View_Clara.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Int(s3ItemH_Clara) * 2 + Int(s3LineSpacing_Clara))
            make.bottom.equalTo(buyButton_Clara.snp.top).offset(-20)
        }

        // Section2 限定礼物 HStack（高78），距 Section3 上方 20
        view.addSubview(section2Stack_Clara)
        section2Stack_Clara.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(78)
            make.bottom.equalTo(section3View_Clara.snp.top).offset(-20)
        }

        // "Ordinary Gift" 分区标题，紧贴 Section2 上方 12pt
        view.addSubview(ordinaryGiftLabel_Clara)
        ordinaryGiftLabel_Clara.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(section2Stack_Clara.snp.top).offset(-12)
        }

        // Section1 VStack 容器（gift_spe 40 + 间距 8 + 礼物行 78 = 126），紧贴 ordinaryGiftLabel 上方 12pt
        view.addSubview(section1View_Clara)
        section1View_Clara.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(135)
            make.bottom.equalTo(ordinaryGiftLabel_Clara.snp.top).offset(-20)
        }

        // 初始位置在屏幕下方，等待滑入动画
        let offscreen = CGAffineTransform(translationX: 0, y: panelH_Clara)
        bgImageView_Clara.transform          = offscreen
        section1View_Clara.transform         = offscreen
        ordinaryGiftLabel_Clara.transform    = offscreen
        section2Stack_Clara.transform        = offscreen
        section3View_Clara.transform         = offscreen
        buyButton_Clara.transform            = offscreen
        overlayView_Clara.alpha              = 0
    }

    /// 构建 Section1：VStack 布局
    /// 上方：gift_spe（194×40）居左对齐
    /// 下方：顶部礼物横向 fillEqually 均分（左右各 16pt 内边距）
    private func buildSection1_Clara() {
        section1View_Clara.addSubview(speImageView_Clara)
        section1View_Clara.addSubview(topGiftsContainer_Clara)

        // gift_spe：左边距 16，顶部对齐，固定 194×40
        speImageView_Clara.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview()
            make.width.equalTo(194)
            make.height.equalTo(40)
        }

        // 礼物容器：位于 gift_spe 下方 8pt，左右各 16pt，底部对齐 section1View
        topGiftsContainer_Clara.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(speImageView_Clara.snp.bottom).offset(12)
            make.bottom.equalToSuperview()
        }

        // 顶部礼物：按顺序使用 gift_one / gift_two / gift_three
        let topImageNames_Clara = ["gift_one", "gift_one", "gift_one"]
        topGifts_Clara.enumerated().forEach { idx, gift in
            let imgName = idx < topImageNames_Clara.count
                ? topImageNames_Clara[idx]
                : "gift_\(gift.id_Clara ?? 1)"
            let itemView = makeGiftItemView_Clara(model: gift, imageName_Clara: imgName)
            topGiftsContainer_Clara.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section2：限定礼物横向均分，全部使用图标 gift_four
    private func buildSection2_Clara() {
        limitGifts_Clara.forEach { gift in
            let itemView = makeGiftItemView_Clara(model: gift, imageName_Clara: "gift_two")
            section2Stack_Clara.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section3：2行×4列手动网格
    /// 行0 使用图标 gift_five，行1 使用图标 gift_six
    /// 礼物均使用 GiftItemView_Clara（自带 onTap_Clara，选中状态由 handleItemSelected_Clara 统一管理）
    private func buildSection3_Clara() {
        // 按每行 4 个切分礼物数组
        let cols = Int(s3Cols_Clara)
        let rowImages = ["gift_three", "gift_four"]

        let vStack = UIStackView()
        vStack.axis        = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing     = s3LineSpacing_Clara

        for rowIdx in 0..<2 {
            let start = rowIdx * cols
            let end   = min(start + cols, normalGifts_Clara.count)
            guard start < end else { continue }

            let rowGifts = normalGifts_Clara[start..<end]
            let imgName  = rowIdx < rowImages.count ? rowImages[rowIdx] : "gift_three"

            let hStack = UIStackView()
            hStack.axis         = .horizontal
            hStack.distribution = .fillEqually
            hStack.spacing      = 8

            rowGifts.forEach { gift in
                let item = makeGiftItemView_Clara(model: gift, imageName_Clara: imgName)
                hStack.addArrangedSubview(item)
            }
            vStack.addArrangedSubview(hStack)
        }

        section3View_Clara.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Int(s3SideInset_Clara))
            make.trailing.equalToSuperview().offset(-Int(s3SideInset_Clara))
            make.top.bottom.equalToSuperview()
        }
    }

    // MARK: - 工厂方法

    /// 创建并注册 GiftItemView_Clara（支持自定义图片名）
    /// - Parameters:
    ///   - model: 礼物数据
    ///   - imageName_Clara: 指定图片名称（不传则按 gift_{id} 规则）
    private func makeGiftItemView_Clara(
        model: StoreModel_Clara,
        imageName_Clara: String? = nil
    ) -> GiftItemView_Clara {
        let v = GiftItemView_Clara()
        v.imageName_Clara = imageName_Clara
        v.model_Clara     = model
        v.onTap_Clara = { [weak self] selected in
            self?.handleItemSelected_Clara(model: selected)
        }
        allItemViews_Clara.append(v)
        return v
    }

    // MARK: - 动画

    private func animatePanelIn_Clara() {
        UIView.animate(
            withDuration: 0.38,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.overlayView_Clara.alpha               = 1
            self.bgImageView_Clara.transform           = .identity
            self.section1View_Clara.transform          = .identity
            self.ordinaryGiftLabel_Clara.transform     = .identity
            self.section2Stack_Clara.transform         = .identity
            self.section3View_Clara.transform          = .identity
            self.buyButton_Clara.transform             = .identity
        }
    }

    private func animatePanelOut_Clara(completion_Clara: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.28) {
            self.overlayView_Clara.alpha = 0
            let t = CGAffineTransform(translationX: 0, y: self.panelH_Clara)
            self.bgImageView_Clara.transform          = t
            self.section1View_Clara.transform         = t
            self.ordinaryGiftLabel_Clara.transform    = t
            self.section2Stack_Clara.transform        = t
            self.section3View_Clara.transform         = t
            self.buyButton_Clara.transform            = t
        } completion: { _ in
            self.dismiss(animated: false, completion: completion_Clara)
        }
    }

    // MARK: - 选中处理

    /// 统一处理礼物选中（Section1/2/3 所有视图均在 allItemViews_Clara 中，直接遍历更新）
    private func handleItemSelected_Clara(model: StoreModel_Clara) {
        selectedGift_Clara = model
        allItemViews_Clara.forEach { v in
            v.isGiftSelected_Clara = (v.model_Clara?.id_Clara == model.id_Clara)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Clara() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap_Clara(_:)))
        // 不阻断面板内部视图（CollectionView、UIButton 等）的触摸传递
        tap.cancelsTouchesInView = false
        overlayView_Clara.addGestureRecognizer(tap)
        buyButton_Clara.addTarget(self, action: #selector(handleBuyTap_Clara), for: .touchUpInside)
    }

    /// 点击遮罩：仅当点击位置位于面板（bgImageView）区域外时才关闭界面
    @objc private func handleOverlayTap_Clara(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        // 触碰面板内部时不关闭，避免拦截 CollectionView cell 点击
        if bgImageView_Clara.frame.contains(point) { return }
        animatePanelOut_Clara()
    }

    @objc private func handleBuyTap_Clara() {
        guard let gift = selectedGift_Clara, let gid = gift.goodsId_Clara else {
            Utils_Clara.showWarning_Clara(message_Clara: "Please select a gift first.")
            return
        }
        buyButton_Clara.animatePressDown_Clara { self.buyButton_Clara.animatePressUp_Clara() }
        Store_Clara.shared_Clara.PurchaseStoreGift_Clara(gid_Clara: gid) { [weak self] in
            self?.animatePanelOut_Clara()
        }
    }
}

