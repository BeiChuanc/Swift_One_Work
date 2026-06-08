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
///   - selectedGift_Hush：当前选中的礼物
///   - refreshSelectionUI_Hush：刷新选中态背景色
class GiftPage_Hush: UIViewController {

    // MARK: - 布局常量

    private var screenW_Hush: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Hush: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Hush: CGFloat { screenW_Hush - 32 }
    /// bgCard 高 = 屏幕高 × 0.72，最大不超过 613pt（避免大屏幕留下过大的空白间隙）
    private var bgCardH_Hush: CGFloat { min(screenH_Hush * 0.72, 613) }
    /// 组件1/2 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Hush: CGFloat { screenW_Hush - 68 }
    private var contentInset_Hush: CGFloat { (bgCardW_Hush - contentW_Hush) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买）
    private var topGift_Hush: StoreModel_Hush?
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Hush: [StoreModel_Hush] = []
    /// 当前选中的礼物
    private var selectedGift_Hush: StoreModel_Hush?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Hush: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Hush = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Hush: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：顶级礼物横向卡片
    private let comp1View_Hush = UIView()
    /// 组件1内部卡片（存储引用以更新选中态）
    private weak var comp1Card_Hush: UIView?
    private weak var comp1PriceLabel_Hush: UILabel?
    private weak var comp1SubLabel_Hush: UILabel?

    /// 组件2：普通礼物网格
    private let comp2View_Hush = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Hush: [GiftItemView_Hush] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Hush: UIButton = {
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
        loadGiftData_Hush()
        buildDimAndCard_Hush()
        buildComp1_Hush()
        buildComp2_Hush()
        buildBuyBtn_Hush()
        setupConstraints_Hush()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：区分顶级礼物与普通礼物
    private func loadGiftData_Hush() {
        let all = Subscribe_Hush.shared_Hush.goodsList_Hush
            .filter { !($0.goodIsVIP_Hush ?? false) }
        topGift_Hush    = all.first { $0.goodIsTop_Hush ?? false }
        normalGifts_Hush = Array(
            all.filter { !($0.goodIsTop_Hush ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Hush() {
        view.addSubview(dimView_Hush)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Hush))
        dimView_Hush.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Hush)
        bgCard_Hush.clipsToBounds = true
        bgCard_Hush.addSubview(bgImageView_Hush)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Hush.addSubview(comp1View_Hush)
        bgCard_Hush.addSubview(comp2View_Hush)
    }

    // MARK: - 组件1：顶级礼物横向卡片

    /// 构建组件1：图片在文字前（左侧），文字价格+说明横向一行展示
    /// 已购时禁用点击并显示 Already Purchased
    private func buildComp1_Hush() {
        guard let top = topGift_Hush else { return }
        let isPur_Hush = Subscribe_Hush.shared_Hush.isPur_Hush

        /// 橙红色圆角卡片背景
        let card_Hush = UIView()
        card_Hush.backgroundColor = UIColor(hexstring_Hush: "#F3461A")
        card_Hush.layer.cornerRadius = 15
        card_Hush.layer.masksToBounds = true
        comp1View_Hush.addSubview(card_Hush)
        card_Hush.snp.makeConstraints { make in make.edges.equalToSuperview() }
        comp1Card_Hush = card_Hush

        /// 禁用/降透
        card_Hush.alpha = isPur_Hush ? 0.55 : 1.0
        card_Hush.isUserInteractionEnabled = !isPur_Hush

        /// 左侧礼物图（gift_one，72×72）— 图片在文字前
        let giftIV_Hush = UIImageView()
        giftIV_Hush.image       = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        giftIV_Hush.contentMode = .scaleAspectFit
        giftIV_Hush.snp.makeConstraints { make in make.width.height.equalTo(72) }

        /// 右侧文字：价格 + 购买说明，横向排列显示为一行
        let priceLabel_Hush = UILabel()
        priceLabel_Hush.text      = top.goodsPrice_Hush ?? ""
        priceLabel_Hush.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        priceLabel_Hush.textColor = .white
        priceLabel_Hush.numberOfLines = 1
        comp1PriceLabel_Hush = priceLabel_Hush

        let subLabel_Hush = UILabel()
        subLabel_Hush.text      = isPur_Hush ? "Already Purchased" : "Can only be purchased once"
        subLabel_Hush.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        subLabel_Hush.textColor = .white
        subLabel_Hush.numberOfLines = 1
        subLabel_Hush.lineBreakMode = .byTruncatingTail
        comp1SubLabel_Hush = subLabel_Hush

        /// 横向文字栈（价格 + 说明，一行）
        let textStack_Hush = UIStackView(arrangedSubviews: [priceLabel_Hush, subLabel_Hush])
        textStack_Hush.axis      = .horizontal
        textStack_Hush.spacing   = 8
        textStack_Hush.alignment = .center

        /// HStack：图片（左）→ 文字一行（右），居中
        let hStack_Hush = UIStackView(arrangedSubviews: [giftIV_Hush, textStack_Hush])
        hStack_Hush.axis      = .horizontal
        hStack_Hush.spacing   = 8
        hStack_Hush.alignment = .center

        card_Hush.addSubview(hStack_Hush)
        hStack_Hush.snp.makeConstraints { make in
            // centerY 垂直居中；leading/trailing 各缩进 10pt，
            // 使 card.width = hStack 内容宽度 + 20pt，从而令 comp1View 宽度自适应内容
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }

        /// 点击选中（未购时）
        if !isPur_Hush {
            let tap_Hush = UITapGestureRecognizer(target: self, action: #selector(comp1Tapped_Hush))
            card_Hush.addGestureRecognizer(tap_Hush)
        }
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Hush() {
        comp2View_Hush.backgroundColor = .clear
        comp2Items_Hush.removeAll()

        let row1_Hush = Array(normalGifts_Hush.prefix(4))
        let row2_Hush: [StoreModel_Hush] = normalGifts_Hush.count > 4
            ? Array(normalGifts_Hush[4...].prefix(4)) : []

        let rowStack1_Hush = buildGridRow_Hush(gifts: row1_Hush, iconName: "gift_two")
        let rowStack2_Hush = buildGridRow_Hush(gifts: row2_Hush, iconName: "gift_three")

        let outerStack_Hush = UIStackView(arrangedSubviews: [rowStack1_Hush, rowStack2_Hush])
        outerStack_Hush.axis         = .vertical
        outerStack_Hush.spacing      = 12
        outerStack_Hush.distribution = .fillEqually

        comp2View_Hush.addSubview(outerStack_Hush)
        outerStack_Hush.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，左右间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Hush(gifts: [StoreModel_Hush], iconName: String) -> UIStackView {
        var items_Hush: [UIView] = []
        for i in 0..<4 {
            let gift_Hush = i < gifts.count ? gifts[i] : nil
            let itemView_Hush = GiftItemView_Hush(iconName: iconName)
            if let gift_Hush = gift_Hush {
                itemView_Hush.configure_Hush(gift: gift_Hush)
                comp2Items_Hush.append(itemView_Hush)
                let tap_Hush = GiftItemTap_Hush(
                    gift: gift_Hush,
                    target: self,
                    action: #selector(gridItemTapped_Hush(_:))
                )
                itemView_Hush.isUserInteractionEnabled = true
                itemView_Hush.addGestureRecognizer(tap_Hush)
            } else {
                /// 空位透明占位
                itemView_Hush.alpha = 0
                itemView_Hush.isUserInteractionEnabled = false
            }
            items_Hush.append(itemView_Hush)
        }
        let stack_Hush = UIStackView(arrangedSubviews: items_Hush)
        stack_Hush.axis         = .horizontal
        stack_Hush.spacing      = 5
        stack_Hush.distribution = .fillEqually
        return stack_Hush
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Hush() {
        bgCard_Hush.addSubview(buyBtn_Hush)
        buyBtn_Hush.addTarget(self, action: #selector(buyTapped_Hush), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Hush() {
        let inset_Hush = contentInset_Hush
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Hush: CGFloat = 109 * 2 + 12

        /// 全屏遮罩
        dimView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Hush)
            make.height.equalTo(bgCardH_Hush)
        }

        /// 背景图铺满 bgCard
        bgImageView_Hush.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Hush.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-50)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于购买按钮上方 10
        comp2View_Hush.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Hush)
            make.trailing.equalToSuperview().offset(-inset_Hush)
            make.height.equalTo(comp2H_Hush)
            make.bottom.equalTo(buyBtn_Hush.snp.top).offset(-15)
        }

        /// 组件1：高 72，水平居中，宽度由内容自适应（hStack 内容 + 20pt 左右 padding）
        comp1View_Hush.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Hush.snp.top).offset(-15)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Hush() {
        dismiss(animated: true)
    }

    /// 点击组件1（顶级礼物）
    @objc private func comp1Tapped_Hush() {
        guard let top = topGift_Hush else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Hush = top
        refreshSelectionUI_Hush(selectedId: top.goodsId_Hush)
    }

    /// 点击组件2网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Hush(_ tap: GiftItemTap_Hush) {
        guard let gift = tap.gift_Hush else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Hush = gift
        refreshSelectionUI_Hush(selectedId: gift.goodsId_Hush)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Hush() {
        guard let gift_Hush = selectedGift_Hush,
              let gid_Hush  = gift_Hush.goodsId_Hush else {
            Utils_Hush.showWarning_Hush(message_Hush: "Please select a gift first")
            return
        }
        Subscribe_Hush.shared_Hush.PurchaseStoreGift_Hush(gid_Hush: gid_Hush) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色与文字颜色
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Hush(selectedId: String?) {
        /// 组件1：未选中 → #F3461A 背景（白色文字）；选中 → 白色背景（#333333 文字）
        let isComp1_Hush = selectedId == topGift_Hush?.goodsId_Hush
        UIView.animate(withDuration: 0.18) {
            self.comp1Card_Hush?.backgroundColor = isComp1_Hush
                ? .white
                : UIColor(hexstring_Hush: "#F3461A")
            let comp1TextColor_Hush: UIColor = isComp1_Hush
                ? UIColor(hexstring_Hush: "#333333") : .white
            self.comp1PriceLabel_Hush?.textColor = comp1TextColor_Hush
            self.comp1SubLabel_Hush?.textColor   = comp1TextColor_Hush
        }

        /// 组件2：未选中 → 白色背景（#333333 文字）；选中 → #F3461A 背景（白色文字）
        comp2Items_Hush.forEach { item_Hush in
            let isSel_Hush = item_Hush.gift_Hush?.goodsId_Hush == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Hush.applySelectionState_Hush(
                    isSelected_Hush: isSel_Hush,
                    normalBgColor_Hush: .white,
                    selectedBgColor_Hush: UIColor(hexstring_Hush: "#F3461A")
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2网格，支持根据选中状态切换背景与文字颜色
/// 关键属性：gift_Hush（绑定数据，供外部判断选中态）
class GiftItemView_Hush: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Hush: StoreModel_Hush?

    // MARK: - UI 组件

    private let iconIV_Hush: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，未选中 #333333 / 选中白色
    private let nameLabel_Hush: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = UIColor(hexstring_Hush: "#333333")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，未选中 #333333 / 选中白色
    private let priceLabel_Hush: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Hush: "#333333")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    /// - Parameter iconName: 礼物图标 Assets 名称（gift_two / gift_three）
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Hush.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Hush()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Hush() {
        backgroundColor = .white   // 未选中默认白色背景
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Hush = UIStackView(arrangedSubviews: [iconIV_Hush, nameLabel_Hush, priceLabel_Hush])
        vStack_Hush.axis         = .vertical
        vStack_Hush.spacing      = 5
        vStack_Hush.alignment    = .center
        vStack_Hush.distribution = .fill

        addSubview(vStack_Hush)
        vStack_Hush.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Hush.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Hush 礼物模型
    func configure_Hush(gift: StoreModel_Hush) {
        self.gift_Hush     = gift
        nameLabel_Hush.text  = gift.goodsName_Hush  ?? ""
        priceLabel_Hush.text = gift.goodsPrice_Hush ?? ""
    }

    /// 应用礼物项选中态样式（背景色 + 文字颜色同步切换）
    /// - Parameters:
    ///   - isSelected_Hush: 当前是否选中
    ///   - normalBgColor_Hush: 未选中背景色（白色）
    ///   - selectedBgColor_Hush: 选中背景色（#F3461A）
    /// 说明：选中时文字切换为白色，未选中时恢复 #333333
    func applySelectionState_Hush(isSelected_Hush: Bool,
                                  normalBgColor_Hush: UIColor,
                                  selectedBgColor_Hush: UIColor) {
        backgroundColor = isSelected_Hush ? selectedBgColor_Hush : normalBgColor_Hush
        let textColor_Hush: UIColor = isSelected_Hush ? .white : UIColor(hexstring_Hush: "#333333")
        nameLabel_Hush.textColor  = textColor_Hush
        priceLabel_Hush.textColor = textColor_Hush
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Hush: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Hush: StoreModel_Hush?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Hush, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Hush = gift
    }
}
