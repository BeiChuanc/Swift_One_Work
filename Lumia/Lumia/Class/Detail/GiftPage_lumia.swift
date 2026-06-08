import Foundation
import UIKit
import SnapKit

// MARK: - 送礼界面

/// 送礼模态弹起界面
/// 核心作用：展示礼物商品列表，用户选择后发起内购
/// 设计思路：
///   半透明遮罩 + gift_bg 背景卡片居中；
///   组件1：顶级一次性礼物横向卡片（HStack）；
///   组件2：普通礼物2行×4列网格；
///   底部购买按钮（gift_buy 图片）；
///   点击遮罩区域关闭，bgCard 外部区域可关闭。
/// 关键属性/方法：
///   - selectedGift_Lumia：当前选中的礼物
///   - refreshSelectionUI_Lumia：刷新选中态背景色
class GiftPage_Lumia: UIViewController {

    // MARK: - 布局常量

    private var screenW_Lumia: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Lumia: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Lumia: CGFloat { screenW_Lumia - 32 }
    /// bgCard 高 = 屏幕高 × 0.72，最大不超过 613pt（避免大屏幕留下过大的空白间隙）
    private var bgCardH_Lumia: CGFloat { min(screenH_Lumia * 0.72, 613) }
    /// 组件1/2 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Lumia: CGFloat { screenW_Lumia - 68 }
    private var contentInset_Lumia: CGFloat { (bgCardW_Lumia - contentW_Lumia) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买）
    private var topGift_Lumia: StoreModel_Lumia?
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Lumia: [StoreModel_Lumia] = []
    /// 当前选中的礼物
    private var selectedGift_Lumia: StoreModel_Lumia?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Lumia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Lumia = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Lumia: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：顶级礼物横向卡片
    private let comp1View_Lumia = UIView()
    /// 组件1内部卡片（存储引用以更新选中态）
    private weak var comp1Card_Lumia: UIView?
    private weak var comp1PriceLabel_Lumia: UILabel?
    private weak var comp1SubLabel_Lumia: UILabel?

    /// 组件2：普通礼物网格
    private let comp2View_Lumia = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Lumia: [GiftItemView_Lumia] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Lumia: UIButton = {
        let btn = UIButton(type: .custom)
        let img = UIImage(named: "gift_buy")?.withRenderingMode(.alwaysOriginal)
        btn.setImage(img, for: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        btn.imageView?.clipsToBounds = true
        btn.clipsToBounds = true
        return btn
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        loadGiftData_Lumia()
        buildDimAndCard_Lumia()
        buildComp1_Lumia()
        buildComp2_Lumia()
        buildBuyBtn_Lumia()
        setupConstraints_Lumia()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：区分顶级礼物与普通礼物
    private func loadGiftData_Lumia() {
        let all = Subscribe_Lumia.shared_Lumia.goodsList_Lumia
            .filter { !($0.goodIsVIP_Lumia ?? false) }
        topGift_Lumia    = all.first { $0.goodIsTop_Lumia ?? false }
        normalGifts_Lumia = Array(
            all.filter { !($0.goodIsTop_Lumia ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Lumia() {
        view.addSubview(dimView_Lumia)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Lumia))
        dimView_Lumia.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Lumia)
        bgCard_Lumia.clipsToBounds = true
        bgCard_Lumia.addSubview(bgImageView_Lumia)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Lumia.addSubview(comp1View_Lumia)
        bgCard_Lumia.addSubview(comp2View_Lumia)
    }

    // MARK: - 组件1：顶级礼物横向卡片

    /// 构建组件1：图片在文字前（左侧），文字价格+说明横向一行展示
    /// 已购时禁用点击并显示 Already Purchased
    private func buildComp1_Lumia() {
        guard let top = topGift_Lumia else { return }
        let isPur_Lumia = Subscribe_Lumia.shared_Lumia.isPur_Lumia

        /// 黄色圆角卡片背景
        let card_Lumia = UIView()
        card_Lumia.backgroundColor = UIColor(hexstring_Lumia: "#FBD115")
        card_Lumia.layer.cornerRadius = 15
        card_Lumia.layer.masksToBounds = true
        comp1View_Lumia.addSubview(card_Lumia)
        card_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        comp1Card_Lumia = card_Lumia

        /// 禁用/降透
        card_Lumia.alpha = isPur_Lumia ? 0.55 : 1.0
        card_Lumia.isUserInteractionEnabled = !isPur_Lumia

        /// 左侧礼物图（gift_one，72×72）— 图片在文字前
        let giftIV_Lumia = UIImageView()
        giftIV_Lumia.image       = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        giftIV_Lumia.contentMode = .scaleAspectFit
        giftIV_Lumia.snp.makeConstraints { make in make.width.height.equalTo(72) }

        /// 右侧文字：价格 + 购买说明，横向排列显示为一行
        let priceLabel_Lumia = UILabel()
        priceLabel_Lumia.text      = top.goodsPrice_Lumia ?? ""
        priceLabel_Lumia.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        priceLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#333333")
        priceLabel_Lumia.numberOfLines = 1
        comp1PriceLabel_Lumia = priceLabel_Lumia

        let subLabel_Lumia = UILabel()
        subLabel_Lumia.text      = isPur_Lumia ? "Already Purchased" : "Can only be purchased once"
        subLabel_Lumia.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        subLabel_Lumia.textColor = UIColor(hexstring_Lumia: "#333333")
        subLabel_Lumia.numberOfLines = 1
        subLabel_Lumia.lineBreakMode = .byTruncatingTail
        comp1SubLabel_Lumia = subLabel_Lumia

        /// 横向文字栈（价格 + 说明，一行）
        let textStack_Lumia = UIStackView(arrangedSubviews: [priceLabel_Lumia, subLabel_Lumia])
        textStack_Lumia.axis      = .horizontal
        textStack_Lumia.spacing   = 8
        textStack_Lumia.alignment = .center

        /// HStack：图片（左）→ 文字一行（右），居中
        let hStack_Lumia = UIStackView(arrangedSubviews: [giftIV_Lumia, textStack_Lumia])
        hStack_Lumia.axis      = .horizontal
        hStack_Lumia.spacing   = 8
        hStack_Lumia.alignment = .center

        card_Lumia.addSubview(hStack_Lumia)
        hStack_Lumia.snp.makeConstraints { make in
            // centerY 垂直居中；leading/trailing 各缩进 10pt，
            // 使 card.width = hStack 内容宽度 + 20pt，从而令 comp1View 宽度自适应内容
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        /// 点击选中（未购时）
        if !isPur_Lumia {
            let tap_Lumia = UITapGestureRecognizer(target: self, action: #selector(comp1Tapped_Lumia))
            card_Lumia.addGestureRecognizer(tap_Lumia)
        }
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Lumia() {
        comp2View_Lumia.backgroundColor = .clear
        comp2Items_Lumia.removeAll()

        let row1_Lumia = Array(normalGifts_Lumia.prefix(4))
        let row2_Lumia: [StoreModel_Lumia] = normalGifts_Lumia.count > 4
            ? Array(normalGifts_Lumia[4...].prefix(4)) : []

        let rowStack1_Lumia = buildGridRow_Lumia(gifts: row1_Lumia, iconName: "gift_two")
        let rowStack2_Lumia = buildGridRow_Lumia(gifts: row2_Lumia, iconName: "gift_three")

        let outerStack_Lumia = UIStackView(arrangedSubviews: [rowStack1_Lumia, rowStack2_Lumia])
        outerStack_Lumia.axis         = .vertical
        outerStack_Lumia.spacing      = 12
        outerStack_Lumia.distribution = .fillEqually

        comp2View_Lumia.addSubview(outerStack_Lumia)
        outerStack_Lumia.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，左右间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Lumia(gifts: [StoreModel_Lumia], iconName: String) -> UIStackView {
        var items_Lumia: [UIView] = []
        for i in 0..<4 {
            let gift_Lumia = i < gifts.count ? gifts[i] : nil
            let itemView_Lumia = GiftItemView_Lumia(iconName: iconName)
            if let gift_Lumia = gift_Lumia {
                itemView_Lumia.configure_Lumia(gift: gift_Lumia)
                comp2Items_Lumia.append(itemView_Lumia)
                let tap_Lumia = GiftItemTap_Lumia(
                    gift: gift_Lumia,
                    target: self,
                    action: #selector(gridItemTapped_Lumia(_:))
                )
                itemView_Lumia.isUserInteractionEnabled = true
                itemView_Lumia.addGestureRecognizer(tap_Lumia)
            } else {
                /// 空位透明占位
                itemView_Lumia.alpha = 0
                itemView_Lumia.isUserInteractionEnabled = false
            }
            items_Lumia.append(itemView_Lumia)
        }
        let stack_Lumia = UIStackView(arrangedSubviews: items_Lumia)
        stack_Lumia.axis         = .horizontal
        stack_Lumia.spacing      = 5
        stack_Lumia.distribution = .fillEqually
        return stack_Lumia
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Lumia() {
        bgCard_Lumia.addSubview(buyBtn_Lumia)
        buyBtn_Lumia.addTarget(self, action: #selector(buyTapped_Lumia), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Lumia() {
        let inset_Lumia = contentInset_Lumia
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Lumia: CGFloat = 109 * 2 + 12

        /// 全屏遮罩
        dimView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Lumia)
            make.height.equalTo(bgCardH_Lumia)
        }

        /// 背景图铺满 bgCard
        bgImageView_Lumia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Lumia.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-50)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于购买按钮上方 10
        comp2View_Lumia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Lumia)
            make.trailing.equalToSuperview().offset(-inset_Lumia)
            make.height.equalTo(comp2H_Lumia)
            make.bottom.equalTo(buyBtn_Lumia.snp.top).offset(-15)
        }

        /// 组件1：高 72，水平居中，宽度由内容自适应（hStack 内容 + 20pt 左右 padding）
        comp1View_Lumia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Lumia.snp.top).offset(-15)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Lumia() {
        dismiss(animated: true)
    }

    /// 点击组件1（顶级礼物）
    @objc private func comp1Tapped_Lumia() {
        guard let top = topGift_Lumia else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Lumia = top
        refreshSelectionUI_Lumia(selectedId: top.goodsId_Lumia)
    }

    /// 点击组件2网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Lumia(_ tap: GiftItemTap_Lumia) {
        guard let gift = tap.gift_Lumia else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Lumia = gift
        refreshSelectionUI_Lumia(selectedId: gift.goodsId_Lumia)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Lumia() {
        guard let gift_Lumia = selectedGift_Lumia,
              let gid_Lumia  = gift_Lumia.goodsId_Lumia else {
            Utils_Lumia.showWarning_Lumia(message_Lumia: "Please select a gift first")
            return
        }
        Subscribe_Lumia.shared_Lumia.PurchaseStoreGift_Lumia(gid_Lumia: gid_Lumia) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Lumia(selectedId: String?) {
        /// 组件1：背景 #FBD115（未选中）↔ 白色（选中）；文字始终 #333333 无需切换
        let isComp1_Lumia = selectedId == topGift_Lumia?.goodsId_Lumia
        UIView.animate(withDuration: 0.18) {
            self.comp1Card_Lumia?.backgroundColor = isComp1_Lumia
                ? .white
                : UIColor(hexstring_Lumia: "#FBD115")
        }

        /// 组件2：背景白色（未选中）↔ #FBD115（选中）；文字始终 #333333
        comp2Items_Lumia.forEach { item_Lumia in
            let isSel_Lumia = item_Lumia.gift_Lumia?.goodsId_Lumia == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Lumia.applySelectionState_Lumia(
                    isSelected_Lumia: isSel_Lumia,
                    normalBgColor_Lumia: .white,
                    selectedBgColor_Lumia: UIColor(hexstring_Lumia: "#FBD115")
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2网格，支持根据选中状态切换背景与文字颜色
/// 关键属性：gift_Lumia（绑定数据，供外部判断选中态）
class GiftItemView_Lumia: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Lumia: StoreModel_Lumia?

    // MARK: - UI 组件

    private let iconIV_Lumia: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，始终 #333333
    private let nameLabel_Lumia: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = UIColor(hexstring_Lumia: "#333333")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，始终 #333333
    private let priceLabel_Lumia: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Lumia: "#333333")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    /// - Parameter iconName: 礼物图标 Assets 名称（gift_two / gift_three）
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Lumia.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Lumia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Lumia() {
        backgroundColor = .white   // 未选中默认白色背景
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Lumia = UIStackView(arrangedSubviews: [iconIV_Lumia, nameLabel_Lumia, priceLabel_Lumia])
        vStack_Lumia.axis         = .vertical
        vStack_Lumia.spacing      = 5
        vStack_Lumia.alignment    = .center
        vStack_Lumia.distribution = .fill

        addSubview(vStack_Lumia)
        vStack_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Lumia.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Lumia 礼物模型
    func configure_Lumia(gift: StoreModel_Lumia) {
        self.gift_Lumia     = gift
        nameLabel_Lumia.text  = gift.goodsName_Lumia  ?? ""
        priceLabel_Lumia.text = gift.goodsPrice_Lumia ?? ""
    }

    /// 应用礼物项选中态样式
    /// - Parameters:
    ///   - isSelected_Lumia: 当前是否选中
    ///   - normalBgColor_Lumia: 未选中背景色（白色）
    ///   - selectedBgColor_Lumia: 选中背景色（#FBD115）
    /// 说明：文字颜色始终为 #333333，不随选中状态变化
    func applySelectionState_Lumia(isSelected_Lumia: Bool,
                                  normalBgColor_Lumia: UIColor,
                                  selectedBgColor_Lumia: UIColor) {
        backgroundColor = isSelected_Lumia ? selectedBgColor_Lumia : normalBgColor_Lumia
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Lumia: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Lumia: StoreModel_Lumia?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Lumia, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Lumia = gift
    }
}
