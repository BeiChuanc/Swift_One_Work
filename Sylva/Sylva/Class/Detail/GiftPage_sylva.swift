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
///   - selectedGift_Sylva：当前选中的礼物
///   - refreshSelectionUI_Sylva：刷新选中态背景色
class GiftPage_Sylva: UIViewController {

    // MARK: - 布局常量

    private var screenW_Sylva: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Sylva: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Sylva: CGFloat { screenW_Sylva - 32 }
    /// bgCard 高 = 屏幕高 × 0.6
    private var bgCardH_Sylva: CGFloat { screenH_Sylva * 0.65 }
    /// 组件1/2 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Sylva: CGFloat { screenW_Sylva - 68 }
    private var contentInset_Sylva: CGFloat { (bgCardW_Sylva - contentW_Sylva) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买）
    private var topGift_Sylva: StoreModel_Sylva?
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Sylva: [StoreModel_Sylva] = []
    /// 当前选中的礼物
    private var selectedGift_Sylva: StoreModel_Sylva?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Sylva: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Sylva = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Sylva: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：顶级礼物横向卡片
    private let comp1View_Sylva = UIView()
    /// 组件1内部白色卡片（存储引用以更新选中态）
    private weak var comp1Card_Sylva: UIView?
    private weak var comp1PriceLabel_Sylva: UILabel?
    private weak var comp1SubLabel_Sylva: UILabel?

    /// 组件2：普通礼物网格
    private let comp2View_Sylva = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Sylva: [GiftItemView_Sylva] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Sylva: UIButton = {
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
        loadGiftData_Sylva()
        buildDimAndCard_Sylva()
        buildComp1_Sylva()
        buildComp2_Sylva()
        buildBuyBtn_Sylva()
        setupConstraints_Sylva()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：区分顶级礼物与普通礼物
    private func loadGiftData_Sylva() {
        let all = Store_Sylva.shared_Sylva.goodsList_Sylva
            .filter { !($0.goodIsVIP_Sylva ?? false) }
        topGift_Sylva    = all.first { $0.goodIsTop_Sylva ?? false }
        normalGifts_Sylva = Array(
            all.filter { !($0.goodIsTop_Sylva ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Sylva() {
        view.addSubview(dimView_Sylva)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Sylva))
        dimView_Sylva.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Sylva)
        bgCard_Sylva.clipsToBounds = true
        bgCard_Sylva.addSubview(bgImageView_Sylva)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Sylva.addSubview(comp1View_Sylva)
        bgCard_Sylva.addSubview(comp2View_Sylva)
    }

    // MARK: - 组件1：顶级礼物横向卡片

    /// 构建组件1（HStack：左侧价格+文字 / 右侧 gift_one 图片）
    /// 已购时禁用点击并显示 Already Purchased
    private func buildComp1_Sylva() {
        guard let top = topGift_Sylva else { return }

        /// 白色圆角卡片背景
        let card_Sylva = UIView()
        card_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#2353E4")
        card_Sylva.layer.cornerRadius = 15
        card_Sylva.layer.masksToBounds = true
        comp1View_Sylva.addSubview(card_Sylva)
        card_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }
        comp1Card_Sylva = card_Sylva

        /// 禁用/降透
        card_Sylva.alpha = 1.0
        card_Sylva.isUserInteractionEnabled = true

        /// 左侧价格文字栈
        let priceLabel_Sylva = UILabel()
        priceLabel_Sylva.text      = top.goodsPrice_Sylva ?? ""
        priceLabel_Sylva.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        priceLabel_Sylva.textColor = .white
        comp1PriceLabel_Sylva = priceLabel_Sylva

        let subLabel_Sylva = UILabel()
        subLabel_Sylva.text      = "Can only be purchased once"
        subLabel_Sylva.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        subLabel_Sylva.textColor = .white
        comp1SubLabel_Sylva = subLabel_Sylva

        let textStack_Sylva = UIStackView(arrangedSubviews: [priceLabel_Sylva, subLabel_Sylva])
        textStack_Sylva.axis      = .vertical
        textStack_Sylva.spacing   = 5
        textStack_Sylva.alignment = .leading

        /// 右侧礼物图（gift_one，72×72）
        let giftIV_Sylva = UIImageView()
        giftIV_Sylva.image       = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        giftIV_Sylva.contentMode = .scaleAspectFit
        giftIV_Sylva.snp.makeConstraints { make in make.width.height.equalTo(72) }

        /// HStack：文字 + 图片，间距 8，居中
        let hStack_Sylva = UIStackView(arrangedSubviews: [textStack_Sylva, giftIV_Sylva])
        hStack_Sylva.axis      = .horizontal
        hStack_Sylva.spacing   = 8
        hStack_Sylva.alignment = .center

        card_Sylva.addSubview(hStack_Sylva)
        hStack_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Sylva() {
        comp2View_Sylva.backgroundColor = .clear
        comp2Items_Sylva.removeAll()

        let row1_Sylva = Array(normalGifts_Sylva.prefix(4))
        let row2_Sylva: [StoreModel_Sylva] = normalGifts_Sylva.count > 4
            ? Array(normalGifts_Sylva[4...].prefix(4)) : []

        let rowStack1_Sylva = buildGridRow_Sylva(gifts: row1_Sylva, iconName: "gift_two")
        let rowStack2_Sylva = buildGridRow_Sylva(gifts: row2_Sylva, iconName: "gift_three")

        let outerStack_Sylva = UIStackView(arrangedSubviews: [rowStack1_Sylva, rowStack2_Sylva])
        outerStack_Sylva.axis         = .vertical
        outerStack_Sylva.spacing      = 12
        outerStack_Sylva.distribution = .fillEqually

        comp2View_Sylva.addSubview(outerStack_Sylva)
        outerStack_Sylva.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，左右间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Sylva(gifts: [StoreModel_Sylva], iconName: String) -> UIStackView {
        var items_Sylva: [UIView] = []
        for i in 0..<4 {
            let gift_Sylva = i < gifts.count ? gifts[i] : nil
            let itemView_Sylva = GiftItemView_Sylva(iconName: iconName)
            if let gift_Sylva = gift_Sylva {
                itemView_Sylva.configure_Sylva(gift: gift_Sylva)
                comp2Items_Sylva.append(itemView_Sylva)
                let tap_Sylva = GiftItemTap_Sylva(
                    gift: gift_Sylva,
                    target: self,
                    action: #selector(gridItemTapped_Sylva(_:))
                )
                itemView_Sylva.isUserInteractionEnabled = true
                itemView_Sylva.addGestureRecognizer(tap_Sylva)
            } else {
                /// 空位透明占位
                itemView_Sylva.alpha = 0
                itemView_Sylva.isUserInteractionEnabled = false
            }
            items_Sylva.append(itemView_Sylva)
        }
        let stack_Sylva = UIStackView(arrangedSubviews: items_Sylva)
        stack_Sylva.axis         = .horizontal
        stack_Sylva.spacing      = 5
        stack_Sylva.distribution = .fillEqually
        return stack_Sylva
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Sylva() {
        bgCard_Sylva.addSubview(buyBtn_Sylva)
        buyBtn_Sylva.addTarget(self, action: #selector(buyTapped_Sylva), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Sylva() {
        let inset_Sylva = contentInset_Sylva
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Sylva: CGFloat = 109 * 2 + 12

        /// 全屏遮罩
        dimView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Sylva)
            make.height.equalTo(bgCardH_Sylva)
        }

        /// 背景图铺满 bgCard
        bgImageView_Sylva.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Sylva.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-50)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于购买按钮上方 10
        comp2View_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Sylva)
            make.trailing.equalToSuperview().offset(-inset_Sylva)
            make.height.equalTo(comp2H_Sylva)
            make.bottom.equalTo(buyBtn_Sylva.snp.top).offset(-10)
        }

        /// 组件1：宽 = contentW，高 72，位于组件2上方 10
        comp1View_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Sylva)
            make.trailing.equalToSuperview().offset(-inset_Sylva)
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Sylva.snp.top).offset(-10)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Sylva() {
        dismiss(animated: true)
    }

    /// 点击组件1（顶级礼物）
    @objc private func comp1Tapped_Sylva() {
        guard let top = topGift_Sylva else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Sylva = top
        refreshSelectionUI_Sylva(selectedId: top.goodsId_Sylva)
    }

    /// 点击组件2网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Sylva(_ tap: GiftItemTap_Sylva) {
        guard let gift = tap.gift_Sylva else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Sylva = gift
        refreshSelectionUI_Sylva(selectedId: gift.goodsId_Sylva)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Sylva() {
        guard let gift_Sylva = selectedGift_Sylva,
              let gid_Sylva  = gift_Sylva.goodsId_Sylva else {
            Utils_Sylva.showWarning_Sylva(message_Sylva: "Please select a gift first")
            return
        }
        Store_Sylva.shared_Sylva.PurchaseStoreGift_Sylva(gid_Sylva: gid_Sylva) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Sylva(selectedId: String?) {
        let normalBgColor_Sylva = UIColor(hexstring_Sylva: "#2353E4")
        let selectedBgColor_Sylva = UIColor.white
        let normalTextColor_Sylva = UIColor.white
        let selectedTextColor_Sylva = UIColor.black

        /// 组件1
        let isComp1_Sylva = selectedId == topGift_Sylva?.goodsId_Sylva
        UIView.animate(withDuration: 0.18) {
            self.comp1Card_Sylva?.backgroundColor = isComp1_Sylva ? selectedBgColor_Sylva : normalBgColor_Sylva
            self.comp1PriceLabel_Sylva?.textColor = isComp1_Sylva ? selectedTextColor_Sylva : normalTextColor_Sylva
            self.comp1SubLabel_Sylva?.textColor = isComp1_Sylva ? selectedTextColor_Sylva : normalTextColor_Sylva
        }

        /// 组件2
        comp2Items_Sylva.forEach { item_Sylva in
            let isSel_Sylva = item_Sylva.gift_Sylva?.goodsId_Sylva == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Sylva.applySelectionState_Sylva(
                    isSelected_Sylva: isSel_Sylva,
                    normalBgColor_Sylva: normalBgColor_Sylva,
                    selectedBgColor_Sylva: selectedBgColor_Sylva,
                    normalTextColor_Sylva: normalTextColor_Sylva,
                    selectedTextColor_Sylva: selectedTextColor_Sylva
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2网格，支持根据选中状态切换背景与文字颜色
/// 关键属性：gift_Sylva（绑定数据，供外部判断选中态）
class GiftItemView_Sylva: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Sylva: StoreModel_Sylva?

    // MARK: - UI 组件

    private let iconIV_Sylva: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，#111111
    private let nameLabel_Sylva: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，#111111
    private let priceLabel_Sylva: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    /// - Parameter iconName: 礼物图标 Assets 名称（gift_two / gift_three）
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Sylva.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Sylva()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Sylva() {
        backgroundColor = UIColor(hexstring_Sylva: "#2353E4")
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Sylva = UIStackView(arrangedSubviews: [iconIV_Sylva, nameLabel_Sylva, priceLabel_Sylva])
        vStack_Sylva.axis         = .vertical
        vStack_Sylva.spacing      = 5
        vStack_Sylva.alignment    = .center
        vStack_Sylva.distribution = .fill

        addSubview(vStack_Sylva)
        vStack_Sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Sylva.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Sylva 礼物模型
    func configure_Sylva(gift: StoreModel_Sylva) {
        self.gift_Sylva     = gift
        nameLabel_Sylva.text  = gift.goodsName_Sylva  ?? ""
        priceLabel_Sylva.text = gift.goodsPrice_Sylva ?? ""
    }

    /// 应用礼物项选中态样式
    /// 参数：
    /// - isSelected_Sylva: 当前是否选中
    /// - normalBgColor_Sylva: 未选中背景色
    /// - selectedBgColor_Sylva: 选中背景色
    /// - normalTextColor_Sylva: 未选中文字色
    /// - selectedTextColor_Sylva: 选中文字色
    /// 返回值：无
    func applySelectionState_Sylva(isSelected_Sylva: Bool,
                                  normalBgColor_Sylva: UIColor,
                                  selectedBgColor_Sylva: UIColor,
                                  normalTextColor_Sylva: UIColor,
                                  selectedTextColor_Sylva: UIColor) {
        backgroundColor = isSelected_Sylva ? selectedBgColor_Sylva : normalBgColor_Sylva
        nameLabel_Sylva.textColor = isSelected_Sylva ? selectedTextColor_Sylva : normalTextColor_Sylva
        priceLabel_Sylva.textColor = isSelected_Sylva ? selectedTextColor_Sylva : normalTextColor_Sylva
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Sylva: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Sylva: StoreModel_Sylva?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Sylva, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Sylva = gift
    }
}
