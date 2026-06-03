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
///   - selectedGift_Posture：当前选中的礼物
///   - refreshSelectionUI_Posture：刷新选中态背景色
class GiftPage_Posture: UIViewController {

    // MARK: - 布局常量

    private var screenW_Posture: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Posture: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Posture: CGFloat { screenW_Posture - 32 }
    /// bgCard 高 = 屏幕高 × 0.75
    private var bgCardH_Posture: CGFloat { screenH_Posture * 0.75 }
    /// 组件1/2 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Posture: CGFloat { screenW_Posture - 68 }
    private var contentInset_Posture: CGFloat { (bgCardW_Posture - contentW_Posture) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买）
    private var topGift_Posture: StoreModel_Posture?
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Posture: [StoreModel_Posture] = []
    /// 当前选中的礼物
    private var selectedGift_Posture: StoreModel_Posture?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Posture: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Posture = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Posture: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：顶级礼物横向卡片
    private let comp1View_Posture = UIView()
    /// 组件1内部白色卡片（存储引用以更新选中态）
    private weak var comp1Card_Posture: UIView?
    private weak var comp1PriceLabel_Posture: UILabel?
    private weak var comp1SubLabel_Posture: UILabel?

    /// 组件2：普通礼物网格
    private let comp2View_Posture = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Posture: [GiftItemView_Posture] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Posture: UIButton = {
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
        loadGiftData_Posture()
        buildDimAndCard_Posture()
        buildComp1_Posture()
        buildComp2_Posture()
        buildBuyBtn_Posture()
        setupConstraints_Posture()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：区分顶级礼物与普通礼物
    private func loadGiftData_Posture() {
        let all = Subscribe_Posture.shared_Posture.goodsList_Posture
            .filter { !($0.goodIsVIP_Posture ?? false) }
        topGift_Posture    = all.first { $0.goodIsTop_Posture ?? false }
        normalGifts_Posture = Array(
            all.filter { !($0.goodIsTop_Posture ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Posture() {
        view.addSubview(dimView_Posture)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Posture))
        dimView_Posture.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Posture)
        bgCard_Posture.clipsToBounds = true
        bgCard_Posture.addSubview(bgImageView_Posture)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Posture.addSubview(comp1View_Posture)
        bgCard_Posture.addSubview(comp2View_Posture)
    }

    // MARK: - 组件1：顶级礼物横向卡片

    /// 构建组件1（HStack：左侧 gift_one 图片 / 右侧单行文字）
    /// 背景白色；图标居左；价格与副标题合并为一行；已购时禁用并显示 Already Purchased
    private func buildComp1_Posture() {
        guard let top = topGift_Posture else { return }
        let isPur_Posture = Subscribe_Posture.shared_Posture.isPur_Posture

        /// 白色圆角卡片背景
        let card_Posture = UIView()
        card_Posture.backgroundColor = .white
        card_Posture.layer.cornerRadius = 15
        card_Posture.layer.masksToBounds = true
        comp1View_Posture.addSubview(card_Posture)
        card_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
        comp1Card_Posture = card_Posture

        /// 禁用/降透
        card_Posture.alpha = isPur_Posture ? 0.55 : 1.0
        card_Posture.isUserInteractionEnabled = !isPur_Posture

        /// 左侧礼物图（gift_one，52×52）
        let giftIV_Posture = UIImageView()
        giftIV_Posture.image       = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        giftIV_Posture.contentMode = .scaleAspectFit
        giftIV_Posture.snp.makeConstraints { make in make.width.height.equalTo(52) }

        /// 右侧单行文字：价格（加粗）+空格+副标题（常规），合并为一行
        let subText_Posture  = isPur_Posture ? "Already Purchased" : "Can only be purchased once"
        let priceText_Posture = top.goodsPrice_Posture ?? ""
        let textLabel_Posture = UILabel()
        textLabel_Posture.text          = "\(priceText_Posture)  \(subText_Posture)"
        textLabel_Posture.font          = UIFont.systemFont(ofSize: 13, weight: .medium)
        textLabel_Posture.textColor     = UIColor(hexstring_Posture: "#2353E4")
        textLabel_Posture.numberOfLines = 1
        /// 存储引用供 refreshSelectionUI_Posture 更新文字颜色
        comp1PriceLabel_Posture = textLabel_Posture

        /// HStack：图片（左）+ 文字（右），间距12，垂直居中
        let hStack_Posture = UIStackView(arrangedSubviews: [giftIV_Posture, textLabel_Posture])
        hStack_Posture.axis      = .horizontal
        hStack_Posture.spacing   = 12
        hStack_Posture.alignment = .center

        card_Posture.addSubview(hStack_Posture)
        hStack_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-16)
        }

        /// 点击选中（未购时）
        if !isPur_Posture {
            let tap_Posture = UITapGestureRecognizer(target: self, action: #selector(comp1Tapped_Posture))
            card_Posture.addGestureRecognizer(tap_Posture)
        }
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Posture() {
        comp2View_Posture.backgroundColor = .clear
        comp2Items_Posture.removeAll()

        let row1_Posture = Array(normalGifts_Posture.prefix(4))
        let row2_Posture: [StoreModel_Posture] = normalGifts_Posture.count > 4
            ? Array(normalGifts_Posture[4...].prefix(4)) : []

        let rowStack1_Posture = buildGridRow_Posture(gifts: row1_Posture, iconName: "gift_two")
        let rowStack2_Posture = buildGridRow_Posture(gifts: row2_Posture, iconName: "gift_three")

        let outerStack_Posture = UIStackView(arrangedSubviews: [rowStack1_Posture, rowStack2_Posture])
        outerStack_Posture.axis         = .vertical
        outerStack_Posture.spacing      = 12
        outerStack_Posture.distribution = .fillEqually

        comp2View_Posture.addSubview(outerStack_Posture)
        outerStack_Posture.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，左右间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Posture(gifts: [StoreModel_Posture], iconName: String) -> UIStackView {
        var items_Posture: [UIView] = []
        for i in 0..<4 {
            let gift_Posture = i < gifts.count ? gifts[i] : nil
            let itemView_Posture = GiftItemView_Posture(iconName: iconName)
            if let gift_Posture = gift_Posture {
                itemView_Posture.configure_Posture(gift: gift_Posture)
                comp2Items_Posture.append(itemView_Posture)
                let tap_Posture = GiftItemTap_Posture(
                    gift: gift_Posture,
                    target: self,
                    action: #selector(gridItemTapped_Posture(_:))
                )
                itemView_Posture.isUserInteractionEnabled = true
                itemView_Posture.addGestureRecognizer(tap_Posture)
            } else {
                /// 空位透明占位
                itemView_Posture.alpha = 0
                itemView_Posture.isUserInteractionEnabled = false
            }
            items_Posture.append(itemView_Posture)
        }
        let stack_Posture = UIStackView(arrangedSubviews: items_Posture)
        stack_Posture.axis         = .horizontal
        stack_Posture.spacing      = 5
        stack_Posture.distribution = .fillEqually
        return stack_Posture
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Posture() {
        bgCard_Posture.addSubview(buyBtn_Posture)
        buyBtn_Posture.addTarget(self, action: #selector(buyTapped_Posture), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Posture() {
        let inset_Posture = contentInset_Posture
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Posture: CGFloat = 109 * 2 + 12

        /// 全屏遮罩
        dimView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Posture)
            make.height.equalTo(bgCardH_Posture)
        }

        /// 背景图铺满 bgCard
        bgImageView_Posture.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Posture.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-30)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于购买按钮上方 10
        comp2View_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Posture)
            make.trailing.equalToSuperview().offset(-inset_Posture)
            make.height.equalTo(comp2H_Posture)
            make.bottom.equalTo(buyBtn_Posture.snp.top).offset(-10)
        }

        /// 组件1：宽 = contentW，高 72，位于组件2上方 10
        comp1View_Posture.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Posture)
            make.trailing.equalToSuperview().offset(-inset_Posture)
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Posture.snp.top).offset(-15)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Posture() {
        dismiss(animated: true)
    }

    /// 点击组件1（顶级礼物）
    @objc private func comp1Tapped_Posture() {
        guard let top = topGift_Posture else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Posture = top
        refreshSelectionUI_Posture(selectedId: top.goodsId_Posture)
    }

    /// 点击组件2网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Posture(_ tap: GiftItemTap_Posture) {
        guard let gift = tap.gift_Posture else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Posture = gift
        refreshSelectionUI_Posture(selectedId: gift.goodsId_Posture)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Posture() {
        guard let gift_Posture = selectedGift_Posture,
              let gid_Posture  = gift_Posture.goodsId_Posture else {
            Utils_Posture.showWarning_Posture(message_Posture: "Please select a gift first")
            return
        }
        Subscribe_Posture.shared_Posture.PurchaseStoreGift_Posture(gid_Posture: gid_Posture) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Posture(selectedId: String?) {
        /// 组件2：未选中白色背景+蓝色文字，选中蓝色背景+白色文字
        let normalBgColor_Posture    = UIColor.white
        let selectedBgColor_Posture  = UIColor(hexstring_Posture: "#2353E4")
        let normalTextColor_Posture  = UIColor(hexstring_Posture: "#2353E4")
        let selectedTextColor_Posture = UIColor.white

        /// 组件1：未选中白色背景+蓝色文字，选中蓝色背景+白色文字
        let isComp1_Posture = selectedId == topGift_Posture?.goodsId_Posture
        UIView.animate(withDuration: 0.18) {
            self.comp1Card_Posture?.backgroundColor = isComp1_Posture ? selectedBgColor_Posture : normalBgColor_Posture
            self.comp1PriceLabel_Posture?.textColor = isComp1_Posture ? selectedTextColor_Posture : normalTextColor_Posture
        }

        /// 组件2
        comp2Items_Posture.forEach { item_Posture in
            let isSel_Posture = item_Posture.gift_Posture?.goodsId_Posture == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Posture.applySelectionState_Posture(
                    isSelected_Posture: isSel_Posture,
                    normalBgColor_Posture: normalBgColor_Posture,
                    selectedBgColor_Posture: selectedBgColor_Posture,
                    normalTextColor_Posture: normalTextColor_Posture,
                    selectedTextColor_Posture: selectedTextColor_Posture
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2网格，支持根据选中状态切换背景与文字颜色
/// 关键属性：gift_Posture（绑定数据，供外部判断选中态）
class GiftItemView_Posture: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Posture: StoreModel_Posture?

    // MARK: - UI 组件

    private let iconIV_Posture: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，未选中显示蓝色
    private let nameLabel_Posture: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = UIColor(hexstring_Posture: "#2353E4")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，未选中显示蓝色
    private let priceLabel_Posture: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Posture: "#2353E4")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    /// - Parameter iconName: 礼物图标 Assets 名称（gift_two / gift_three）
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Posture.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Posture()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Posture() {
        /// 默认白色背景，选中时通过 applySelectionState_Posture 切换为蓝色
        backgroundColor = .white
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Posture = UIStackView(arrangedSubviews: [iconIV_Posture, nameLabel_Posture, priceLabel_Posture])
        vStack_Posture.axis         = .vertical
        vStack_Posture.spacing      = 5
        vStack_Posture.alignment    = .center
        vStack_Posture.distribution = .fill

        addSubview(vStack_Posture)
        vStack_Posture.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Posture.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Posture 礼物模型
    func configure_Posture(gift: StoreModel_Posture) {
        self.gift_Posture     = gift
        nameLabel_Posture.text  = gift.goodsName_Posture  ?? ""
        priceLabel_Posture.text = gift.goodsPrice_Posture ?? ""
    }

    /// 应用礼物项选中态样式
    /// 参数：
    /// - isSelected_Posture: 当前是否选中
    /// - normalBgColor_Posture: 未选中背景色
    /// - selectedBgColor_Posture: 选中背景色
    /// - normalTextColor_Posture: 未选中文字色
    /// - selectedTextColor_Posture: 选中文字色
    /// 返回值：无
    func applySelectionState_Posture(isSelected_Posture: Bool,
                                  normalBgColor_Posture: UIColor,
                                  selectedBgColor_Posture: UIColor,
                                  normalTextColor_Posture: UIColor,
                                  selectedTextColor_Posture: UIColor) {
        backgroundColor = isSelected_Posture ? selectedBgColor_Posture : normalBgColor_Posture
        nameLabel_Posture.textColor = isSelected_Posture ? selectedTextColor_Posture : normalTextColor_Posture
        priceLabel_Posture.textColor = isSelected_Posture ? selectedTextColor_Posture : normalTextColor_Posture
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Posture: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Posture: StoreModel_Posture?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Posture, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Posture = gift
    }
}
