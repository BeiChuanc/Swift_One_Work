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
///   - selectedGift_Lens：当前选中的礼物
///   - refreshSelectionUI_Lens：刷新选中态背景色
class GiftPage_Lens: UIViewController {

    // MARK: - 布局常量

    private var screenW_Lens: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Lens: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Lens: CGFloat { screenW_Lens - 32 }
    /// bgCard 高 = 屏幕高 × 0.6
    private var bgCardH_Lens: CGFloat { screenH_Lens * 0.65 }
    /// 组件1/2 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Lens: CGFloat { screenW_Lens - 68 }
    private var contentInset_Lens: CGFloat { (bgCardW_Lens - contentW_Lens) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买）
    private var topGift_Lens: StoreModel_Lens?
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Lens: [StoreModel_Lens] = []
    /// 当前选中的礼物
    private var selectedGift_Lens: StoreModel_Lens?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Lens: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Lens = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Lens: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：顶级礼物横向卡片
    private let comp1View_Lens = UIView()
    /// 组件1内部白色卡片（存储引用以更新选中态）
    private weak var comp1Card_Lens: UIView?
    private weak var comp1PriceLabel_Lens: UILabel?
    private weak var comp1SubLabel_Lens: UILabel?

    /// 组件2：普通礼物网格
    private let comp2View_Lens = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Lens: [GiftItemView_Lens] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Lens: UIButton = {
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
        loadGiftData_Lens()
        buildDimAndCard_Lens()
        buildComp1_Lens()
        buildComp2_Lens()
        buildBuyBtn_Lens()
        setupConstraints_Lens()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：区分顶级礼物与普通礼物
    private func loadGiftData_Lens() {
        let all = Store_Lens.shared_Lens.goodsList_Lens
            .filter { !($0.goodIsVIP_Lens ?? false) }
        topGift_Lens    = all.first { $0.goodIsTop_Lens ?? false }
        normalGifts_Lens = Array(
            all.filter { !($0.goodIsTop_Lens ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Lens() {
        view.addSubview(dimView_Lens)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Lens))
        dimView_Lens.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Lens)
        bgCard_Lens.clipsToBounds = true
        bgCard_Lens.addSubview(bgImageView_Lens)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Lens.addSubview(comp1View_Lens)
        bgCard_Lens.addSubview(comp2View_Lens)
    }

    // MARK: - 组件1：顶级礼物横向卡片

    /// 构建组件1（HStack：左侧价格+文字 / 右侧 gift_one 图片）
    /// 已购时禁用点击并显示 Already Purchased
    private func buildComp1_Lens() {
        guard let top = topGift_Lens else { return }

        /// 白色圆角卡片背景
        let card_Lens = UIView()
        card_Lens.backgroundColor = UIColor(hexstring_Lens: "#2353E4")
        card_Lens.layer.cornerRadius = 15
        card_Lens.layer.masksToBounds = true
        comp1View_Lens.addSubview(card_Lens)
        card_Lens.snp.makeConstraints { make in make.edges.equalToSuperview() }
        comp1Card_Lens = card_Lens

        /// 禁用/降透
        card_Lens.alpha = 1.0
        card_Lens.isUserInteractionEnabled = true

        /// 左侧价格文字栈
        let priceLabel_Lens = UILabel()
        priceLabel_Lens.text      = top.goodsPrice_Lens ?? ""
        priceLabel_Lens.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        priceLabel_Lens.textColor = .white
        comp1PriceLabel_Lens = priceLabel_Lens

        let subLabel_Lens = UILabel()
        subLabel_Lens.text      = "Can only be purchased once"
        subLabel_Lens.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        subLabel_Lens.textColor = .white
        comp1SubLabel_Lens = subLabel_Lens

        let textStack_Lens = UIStackView(arrangedSubviews: [priceLabel_Lens, subLabel_Lens])
        textStack_Lens.axis      = .vertical
        textStack_Lens.spacing   = 5
        textStack_Lens.alignment = .leading

        /// 右侧礼物图（gift_one，72×72）
        let giftIV_Lens = UIImageView()
        giftIV_Lens.image       = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        giftIV_Lens.contentMode = .scaleAspectFit
        giftIV_Lens.snp.makeConstraints { make in make.width.height.equalTo(72) }

        /// HStack：文字 + 图片，间距 8，居中
        let hStack_Lens = UIStackView(arrangedSubviews: [textStack_Lens, giftIV_Lens])
        hStack_Lens.axis      = .horizontal
        hStack_Lens.spacing   = 8
        hStack_Lens.alignment = .center

        card_Lens.addSubview(hStack_Lens)
        hStack_Lens.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Lens() {
        comp2View_Lens.backgroundColor = .clear
        comp2Items_Lens.removeAll()

        let row1_Lens = Array(normalGifts_Lens.prefix(4))
        let row2_Lens: [StoreModel_Lens] = normalGifts_Lens.count > 4
            ? Array(normalGifts_Lens[4...].prefix(4)) : []

        let rowStack1_Lens = buildGridRow_Lens(gifts: row1_Lens, iconName: "gift_two")
        let rowStack2_Lens = buildGridRow_Lens(gifts: row2_Lens, iconName: "gift_three")

        let outerStack_Lens = UIStackView(arrangedSubviews: [rowStack1_Lens, rowStack2_Lens])
        outerStack_Lens.axis         = .vertical
        outerStack_Lens.spacing      = 12
        outerStack_Lens.distribution = .fillEqually

        comp2View_Lens.addSubview(outerStack_Lens)
        outerStack_Lens.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，左右间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Lens(gifts: [StoreModel_Lens], iconName: String) -> UIStackView {
        var items_Lens: [UIView] = []
        for i in 0..<4 {
            let gift_Lens = i < gifts.count ? gifts[i] : nil
            let itemView_Lens = GiftItemView_Lens(iconName: iconName)
            if let gift_Lens = gift_Lens {
                itemView_Lens.configure_Lens(gift: gift_Lens)
                comp2Items_Lens.append(itemView_Lens)
                let tap_Lens = GiftItemTap_Lens(
                    gift: gift_Lens,
                    target: self,
                    action: #selector(gridItemTapped_Lens(_:))
                )
                itemView_Lens.isUserInteractionEnabled = true
                itemView_Lens.addGestureRecognizer(tap_Lens)
            } else {
                /// 空位透明占位
                itemView_Lens.alpha = 0
                itemView_Lens.isUserInteractionEnabled = false
            }
            items_Lens.append(itemView_Lens)
        }
        let stack_Lens = UIStackView(arrangedSubviews: items_Lens)
        stack_Lens.axis         = .horizontal
        stack_Lens.spacing      = 5
        stack_Lens.distribution = .fillEqually
        return stack_Lens
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Lens() {
        bgCard_Lens.addSubview(buyBtn_Lens)
        buyBtn_Lens.addTarget(self, action: #selector(buyTapped_Lens), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Lens() {
        let inset_Lens = contentInset_Lens
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Lens: CGFloat = 109 * 2 + 12

        /// 全屏遮罩
        dimView_Lens.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Lens.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Lens)
            make.height.equalTo(bgCardH_Lens)
        }

        /// 背景图铺满 bgCard
        bgImageView_Lens.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Lens.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-50)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于购买按钮上方 10
        comp2View_Lens.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Lens)
            make.trailing.equalToSuperview().offset(-inset_Lens)
            make.height.equalTo(comp2H_Lens)
            make.bottom.equalTo(buyBtn_Lens.snp.top).offset(-10)
        }

        /// 组件1：宽 = contentW，高 72，位于组件2上方 10
        comp1View_Lens.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Lens)
            make.trailing.equalToSuperview().offset(-inset_Lens)
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Lens.snp.top).offset(-10)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Lens() {
        dismiss(animated: true)
    }

    /// 点击组件1（顶级礼物）
    @objc private func comp1Tapped_Lens() {
        guard let top = topGift_Lens else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Lens = top
        refreshSelectionUI_Lens(selectedId: top.goodsId_Lens)
    }

    /// 点击组件2网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Lens(_ tap: GiftItemTap_Lens) {
        guard let gift = tap.gift_Lens else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Lens = gift
        refreshSelectionUI_Lens(selectedId: gift.goodsId_Lens)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Lens() {
        guard let gift_Lens = selectedGift_Lens,
              let gid_Lens  = gift_Lens.goodsId_Lens else {
            Load_Lens.showWarning_Lens(message_Lens: "Please select a gift first")
            return
        }
        Store_Lens.shared_Lens.PurchaseStoreGift_Lens(gid_Lens: gid_Lens) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Lens(selectedId: String?) {
        let normalBgColor_Lens = UIColor(hexstring_Lens: "#2353E4")
        let selectedBgColor_Lens = UIColor.white
        let normalTextColor_Lens = UIColor.white
        let selectedTextColor_Lens = UIColor.black

        /// 组件1
        let isComp1_Lens = selectedId == topGift_Lens?.goodsId_Lens
        UIView.animate(withDuration: 0.18) {
            self.comp1Card_Lens?.backgroundColor = isComp1_Lens ? selectedBgColor_Lens : normalBgColor_Lens
            self.comp1PriceLabel_Lens?.textColor = isComp1_Lens ? selectedTextColor_Lens : normalTextColor_Lens
            self.comp1SubLabel_Lens?.textColor = isComp1_Lens ? selectedTextColor_Lens : normalTextColor_Lens
        }

        /// 组件2
        comp2Items_Lens.forEach { item_Lens in
            let isSel_Lens = item_Lens.gift_Lens?.goodsId_Lens == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Lens.applySelectionState_Lens(
                    isSelected_Lens: isSel_Lens,
                    normalBgColor_Lens: normalBgColor_Lens,
                    selectedBgColor_Lens: selectedBgColor_Lens,
                    normalTextColor_Lens: normalTextColor_Lens,
                    selectedTextColor_Lens: selectedTextColor_Lens
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2网格，支持根据选中状态切换背景与文字颜色
/// 关键属性：gift_Lens（绑定数据，供外部判断选中态）
class GiftItemView_Lens: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Lens: StoreModel_Lens?

    // MARK: - UI 组件

    private let iconIV_Lens: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，#111111
    private let nameLabel_Lens: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，#111111
    private let priceLabel_Lens: UILabel = {
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
        iconIV_Lens.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Lens()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Lens() {
        backgroundColor = UIColor(hexstring_Lens: "#2353E4")
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Lens = UIStackView(arrangedSubviews: [iconIV_Lens, nameLabel_Lens, priceLabel_Lens])
        vStack_Lens.axis         = .vertical
        vStack_Lens.spacing      = 5
        vStack_Lens.alignment    = .center
        vStack_Lens.distribution = .fill

        addSubview(vStack_Lens)
        vStack_Lens.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Lens.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Lens 礼物模型
    func configure_Lens(gift: StoreModel_Lens) {
        self.gift_Lens     = gift
        nameLabel_Lens.text  = gift.goodsName_Lens  ?? ""
        priceLabel_Lens.text = gift.goodsPrice_Lens ?? ""
    }

    /// 应用礼物项选中态样式
    /// 参数：
    /// - isSelected_Lens: 当前是否选中
    /// - normalBgColor_Lens: 未选中背景色
    /// - selectedBgColor_Lens: 选中背景色
    /// - normalTextColor_Lens: 未选中文字色
    /// - selectedTextColor_Lens: 选中文字色
    /// 返回值：无
    func applySelectionState_Lens(isSelected_Lens: Bool,
                                  normalBgColor_Lens: UIColor,
                                  selectedBgColor_Lens: UIColor,
                                  normalTextColor_Lens: UIColor,
                                  selectedTextColor_Lens: UIColor) {
        backgroundColor = isSelected_Lens ? selectedBgColor_Lens : normalBgColor_Lens
        nameLabel_Lens.textColor = isSelected_Lens ? selectedTextColor_Lens : normalTextColor_Lens
        priceLabel_Lens.textColor = isSelected_Lens ? selectedTextColor_Lens : normalTextColor_Lens
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Lens: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Lens: StoreModel_Lens?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Lens, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Lens = gift
    }
}
