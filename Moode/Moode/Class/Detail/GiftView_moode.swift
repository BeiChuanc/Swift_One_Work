import UIKit
import SnapKit

// MARK: - 礼物展示单项视图

/// 礼物展示单项通用视图
/// 核心作用：展示单个礼物的图标、名称（HStack）与价格（VStack），供 Section1/2 UIStackView 复用
/// imageName_Moode 可指定自定义图片名称，否则使用 gift_{id} 规则
/// 背景白色圆角20，选中时替换为浅紫色 #BE92FD
class GiftItemView_Moode: UIView {

    // MARK: - 常量
    private static let selectedBg_Moode = UIColor(hexstring_Moode: "#BE92FD").withAlphaComponent(0.35)

    // MARK: - 属性

    /// 礼物数据（set 后自动刷新 UI）
    var model_Moode: StoreModel_Moode? { didSet { fillData_Moode() } }

    /// 自定义图片名称，优先于 gift_{id} 规则
    var imageName_Moode: String? { didSet { fillData_Moode() } }

    /// 选中状态（set 后自动更新背景色）
    var isGiftSelected_Moode: Bool = false { didSet { updateSelectedState_Moode() } }

    /// 点击回调
    var onTap_Moode: ((StoreModel_Moode) -> Void)?

    // MARK: - UI 组件

    private let giftImageView_Moode: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Moode: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor(hexstring_Moode: "#111111")
        lbl.textAlignment = .center
        return lbl
    }()

    private let priceLabel_Moode: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        lbl.textColor = UIColor(hexstring_Moode: "#111111")
        lbl.textAlignment = .center
        return lbl
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Moode()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// VStack：HStack(图片36×36 + 名称, 间距5) + 价格
    private func setupUI_Moode() {
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

        giftImageView_Moode.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }

        let topRow_Moode = UIStackView(arrangedSubviews: [giftImageView_Moode, nameLabel_Moode])
        topRow_Moode.axis = .horizontal
        topRow_Moode.spacing = 5
        topRow_Moode.alignment = .center

        let vStack_Moode = UIStackView(arrangedSubviews: [topRow_Moode, priceLabel_Moode])
        vStack_Moode.axis = .vertical
        vStack_Moode.spacing = 6
        vStack_Moode.alignment = .center

        addSubview(vStack_Moode)
        vStack_Moode.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(6)
            make.trailing.lessThanOrEqualToSuperview().offset(-6)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap_Moode))
        addGestureRecognizer(tap)
    }

    // MARK: - 数据填充

    private func fillData_Moode() {
        guard let m = model_Moode else { return }
        // 优先使用自定义图片名称，否则按 gift_{id} 规则
        let name = imageName_Moode ?? "gift_\(m.id_Moode ?? 1)"
        giftImageView_Moode.image = UIImage(named: name)
        nameLabel_Moode.text  = m.goodsName_Moode
        priceLabel_Moode.text = m.goodsPrice_Moode
    }

    private func updateSelectedState_Moode() {
        backgroundColor = isGiftSelected_Moode ? Self.selectedBg_Moode : .white
    }

    @objc private func handleTap_Moode() {
        guard let m = model_Moode else { return }
        onTap_Moode?(m)
    }
}


// MARK: - 送礼界面（模态弹起）

/// 送礼界面视图控制器
/// 核心作用：以模态底部弹起方式展示礼物列表，支持选中、购买（接入 Store_Moode IAP）
/// 设计思路：全屏半透明遮罩 + gift_bg 图片面板（屏幕高 85%） + 三区礼物 + 底部购买按钮
/// 组件布局（底部对齐，间距 20）：buyButton ← section3 ← section2 ← section1
/// 关键方法：handleItemSelected_Moode（礼物选中），handleBuyTap_Moode（发起内购）
class GiftView_Moode: UIViewController {

    // MARK: - 常量

    private let panelH_Moode: CGFloat  = UIScreen.main.bounds.height * 0.85
    private let screenW_Moode: CGFloat = UIScreen.main.bounds.width
    /// Section3 每列固定 4 列，左右各 16pt 内边距
    private let s3SideInset_Moode: CGFloat = 16
    private let s3Cols_Moode: CGFloat      = 4
    private let s3ItemH_Moode: CGFloat     = 82
    private let s3LineSpacing_Moode: CGFloat = 12

    // MARK: - 数据

    private var topGifts_Moode: [StoreModel_Moode] = []
    private var limitGifts_Moode: [StoreModel_Moode] = []
    private var normalGifts_Moode: [StoreModel_Moode] = []
    private var selectedGift_Moode: StoreModel_Moode?
    private var allItemViews_Moode: [GiftItemView_Moode] = []

    // MARK: - UI 组件

    /// 全屏半透明遮罩（点击非面板区域关闭）
    private let overlayView_Moode: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return v
    }()

    /// gift_bg 图片面板（屏幕宽度 × 屏幕高度60%，底部对齐）
    private let bgImageView_Moode: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = false
        iv.isUserInteractionEnabled = true
        return iv
    }()

    // ── Section1：HStack（gift_spe 固定170×32 + 顶部礼物平分剩余空间）────────

    /// Section1 水平容器（高度78，gift_spe 在左，礼物 fillEqually 在右）
    private let section1View_Moode = UIView()

    /// 装饰图片 gift_spe（固定 170×32，垂直居中于 78pt 行）
    private let speImageView_Moode: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_spe")
        iv.contentMode = .scaleAspectFit
        // 不被压缩/拉伸，维持固定宽度
        iv.setContentHuggingPriority(.required, for: .horizontal)
        iv.setContentCompressionResistancePriority(.required, for: .horizontal)
        return iv
    }()

    /// 顶部礼物 fillEqually 容器（平分 gift_spe 右侧剩余空间）
    private let topGiftsContainer_Moode: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section2：HStack（限定礼物横向均分，图标 gift_three）────────────────

    private let section2Stack_Moode: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 8
        sv.alignment = .fill
        return sv
    }()

    // ── Section3：手动网格（2行×4列，左右 inset16，行0=gift_four，行1=gift_five）──

    /// Section3 容器（通过 UIStackView 手动排列，避免 UICollectionView 选中回调不稳定的问题）
    private let section3View_Moode = UIView()

    // ── 购买按钮 ────────────────────────────────────────────────────────────

    private let buyButton_Moode: UIButton = {
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
        loadData_Moode()
        setupUI_Moode()
        buildSection1_Moode()
        buildSection2_Moode()
        buildSection3_Moode()
        bindActions_Moode()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animatePanelIn_Moode()
    }

    // MARK: - 数据加载

    private func loadData_Moode() {
        let all = Store_Moode.shared_Moode.goodsList_Moode
        topGifts_Moode    = all.filter { $0.goodIsTop_Moode == true }
        limitGifts_Moode  = all.filter { $0.goodIsSpecial_Moode == true }
        normalGifts_Moode = all.filter {
            $0.goodIsTop_Moode != true && $0.goodIsSpecial_Moode != true
        }
    }

    // MARK: - UI 搭建

    /// 主布局：遮罩 + gift_bg 面板 + 各组件（底部对齐，组件间距 20pt）
    private func setupUI_Moode() {
        view.addSubview(overlayView_Moode)
        overlayView_Moode.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        view.addSubview(bgImageView_Moode)
        bgImageView_Moode.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(panelH_Moode)
        }

        // 购买按钮（布局起点，距面板底部 50）
        view.addSubview(buyButton_Moode)
        buyButton_Moode.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(62)
            make.bottom.equalTo(bgImageView_Moode.snp.bottom).offset(-70)
        }

        // Section3 手动网格（2行，高 = 2×82 + 12 = 176），距购买按钮 20
        view.addSubview(section3View_Moode)
        section3View_Moode.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(Int(s3ItemH_Moode) * 2 + Int(s3LineSpacing_Moode))
            make.bottom.equalTo(buyButton_Moode.snp.top).offset(-20)
        }

        // Section2 限定礼物 HStack（高78），距 Section3 上方 20
        view.addSubview(section2Stack_Moode)
        section2Stack_Moode.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(78)
            make.bottom.equalTo(section3View_Moode.snp.top).offset(-20)
        }

        // Section1 HStack 容器（高度78，含 gift_spe + 礼物），距 Section2 上方 20
        view.addSubview(section1View_Moode)
        section1View_Moode.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(78)
            make.bottom.equalTo(section2Stack_Moode.snp.top).offset(-20)
        }

        // 初始位置在屏幕下方，等待滑入动画
        let offscreen = CGAffineTransform(translationX: 0, y: panelH_Moode)
        bgImageView_Moode.transform    = offscreen
        section1View_Moode.transform   = offscreen
        section2Stack_Moode.transform  = offscreen
        section3View_Moode.transform   = offscreen
        buyButton_Moode.transform      = offscreen
        overlayView_Moode.alpha        = 0
    }

    /// 构建 Section1：gift_spe(170×32)固定在左侧居中 + 顶部礼物 fillEqually 平分剩余宽度
    /// 图标依次使用 gift_one（第1个）、gift_two（第2个）
    private func buildSection1_Moode() {
        section1View_Moode.addSubview(speImageView_Moode)
        section1View_Moode.addSubview(topGiftsContainer_Moode)

        // gift_spe：左边距16，垂直居中，固定 170×32
        speImageView_Moode.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(170)
            make.height.equalTo(32)
        }

        // 礼物容器：紧贴 speImageView 右侧 8pt，右边距 16，高度填满 section1View（78pt）
        topGiftsContainer_Moode.snp.makeConstraints { make in
            make.leading.equalTo(speImageView_Moode.snp.trailing).offset(8)
            make.trailing.equalToSuperview().offset(-16)
            make.top.bottom.equalToSuperview()
        }

        // 顶部礼物：按顺序使用 gift_one / gift_two
        let topImageNames_Moode = ["gift_one", "gift_one"]
        topGifts_Moode.enumerated().forEach { idx, gift in
            let imgName = idx < topImageNames_Moode.count
                ? topImageNames_Moode[idx]
                : "gift_\(gift.id_Moode ?? 1)"
            let itemView = makeGiftItemView_Moode(model: gift, imageName_Moode: imgName)
            topGiftsContainer_Moode.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section2：限定礼物横向均分，全部使用图标 gift_three
    private func buildSection2_Moode() {
        limitGifts_Moode.forEach { gift in
            let itemView = makeGiftItemView_Moode(model: gift, imageName_Moode: "gift_two")
            section2Stack_Moode.addArrangedSubview(itemView)
        }
    }

    /// 构建 Section3：2行×4列手动网格
    /// 行0 使用图标 gift_four，行1 使用图标 gift_five
    /// 礼物均使用 GiftItemView_Moode（自带 onTap_Moode，选中状态由 handleItemSelected_Moode 统一管理）
    private func buildSection3_Moode() {
        // 按每行 4 个切分礼物数组
        let cols = Int(s3Cols_Moode)
        let rowImages = ["gift_three", "gift_four"]

        let vStack = UIStackView()
        vStack.axis        = .vertical
        vStack.distribution = .fillEqually
        vStack.spacing     = s3LineSpacing_Moode

        for rowIdx in 0..<2 {
            let start = rowIdx * cols
            let end   = min(start + cols, normalGifts_Moode.count)
            guard start < end else { continue }

            let rowGifts = normalGifts_Moode[start..<end]
            let imgName  = rowIdx < rowImages.count ? rowImages[rowIdx] : "gift_three"

            let hStack = UIStackView()
            hStack.axis         = .horizontal
            hStack.distribution = .fillEqually
            hStack.spacing      = 8

            rowGifts.forEach { gift in
                let item = makeGiftItemView_Moode(model: gift, imageName_Moode: imgName)
                hStack.addArrangedSubview(item)
            }
            vStack.addArrangedSubview(hStack)
        }

        section3View_Moode.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Int(s3SideInset_Moode))
            make.trailing.equalToSuperview().offset(-Int(s3SideInset_Moode))
            make.top.bottom.equalToSuperview()
        }
    }

    // MARK: - 工厂方法

    /// 创建并注册 GiftItemView_Moode（支持自定义图片名）
    /// - Parameters:
    ///   - model: 礼物数据
    ///   - imageName_Moode: 指定图片名称（不传则按 gift_{id} 规则）
    private func makeGiftItemView_Moode(
        model: StoreModel_Moode,
        imageName_Moode: String? = nil
    ) -> GiftItemView_Moode {
        let v = GiftItemView_Moode()
        v.imageName_Moode = imageName_Moode
        v.model_Moode     = model
        v.onTap_Moode = { [weak self] selected in
            self?.handleItemSelected_Moode(model: selected)
        }
        allItemViews_Moode.append(v)
        return v
    }

    // MARK: - 动画

    private func animatePanelIn_Moode() {
        UIView.animate(
            withDuration: 0.38,
            delay: 0,
            usingSpringWithDamping: 0.88,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.overlayView_Moode.alpha        = 1
            self.bgImageView_Moode.transform    = .identity
            self.section1View_Moode.transform   = .identity
            self.section2Stack_Moode.transform  = .identity
            self.section3View_Moode.transform   = .identity
            self.buyButton_Moode.transform      = .identity
        }
    }

    private func animatePanelOut_Moode(completion_Moode: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.28) {
            self.overlayView_Moode.alpha = 0
            let t = CGAffineTransform(translationX: 0, y: self.panelH_Moode)
            self.bgImageView_Moode.transform   = t
            self.section1View_Moode.transform  = t
            self.section2Stack_Moode.transform = t
            self.section3View_Moode.transform  = t
            self.buyButton_Moode.transform     = t
        } completion: { _ in
            self.dismiss(animated: false, completion: completion_Moode)
        }
    }

    // MARK: - 选中处理

    /// 统一处理礼物选中（Section1/2/3 所有视图均在 allItemViews_Moode 中，直接遍历更新）
    private func handleItemSelected_Moode(model: StoreModel_Moode) {
        selectedGift_Moode = model
        allItemViews_Moode.forEach { v in
            v.isGiftSelected_Moode = (v.model_Moode?.id_Moode == model.id_Moode)
        }
    }

    // MARK: - 事件绑定

    private func bindActions_Moode() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleOverlayTap_Moode(_:)))
        // 不阻断面板内部视图（CollectionView、UIButton 等）的触摸传递
        tap.cancelsTouchesInView = false
        overlayView_Moode.addGestureRecognizer(tap)
        buyButton_Moode.addTarget(self, action: #selector(handleBuyTap_Moode), for: .touchUpInside)
    }

    /// 点击遮罩：仅当点击位置位于面板（bgImageView）区域外时才关闭界面
    @objc private func handleOverlayTap_Moode(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        // 触碰面板内部时不关闭，避免拦截 CollectionView cell 点击
        if bgImageView_Moode.frame.contains(point) { return }
        animatePanelOut_Moode()
    }

    @objc private func handleBuyTap_Moode() {
        guard let gift = selectedGift_Moode, let gid = gift.goodsId_Moode else {
            Utils_Moode.showWarning_Moode(message_Moode: "Please select a gift first.")
            return
        }
        buyButton_Moode.animatePressDown_Moode { self.buyButton_Moode.animatePressUp_Moode() }
        Store_Moode.shared_Moode.PurchaseStoreGift_Moode(gid_Moode: gid) { [weak self] in
            self?.animatePanelOut_Moode()
        }
    }
}

