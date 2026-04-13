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
///   - selectedGift_Tidy：当前选中的礼物
///   - refreshSelectionUI_Tidy：刷新选中态背景色
class GiftPage_Tidy: UIViewController {

    // MARK: - 布局常量

    private var screenW_Tidy: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Tidy: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Tidy: CGFloat { screenW_Tidy - 32 }
    /// bgCard 高 = 屏幕高 × 0.6
    private var bgCardH_Tidy: CGFloat { screenH_Tidy * 0.65 }
    /// 组件1/2 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Tidy: CGFloat { screenW_Tidy - 68 }
    private var contentInset_Tidy: CGFloat { (bgCardW_Tidy - contentW_Tidy) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买）
    private var topGift_Tidy: StoreModel_Tidy?
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Tidy: [StoreModel_Tidy] = []
    /// 当前选中的礼物
    private var selectedGift_Tidy: StoreModel_Tidy?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Tidy: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Tidy = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：顶级礼物横向卡片
    private let comp1View_Tidy = UIView()
    /// 组件1内部白色卡片（存储引用以更新选中态）
    private weak var comp1Card_Tidy: UIView?
    private weak var comp1PriceLabel_Tidy: UILabel?
    private weak var comp1SubLabel_Tidy: UILabel?

    /// 组件2：普通礼物网格
    private let comp2View_Tidy = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Tidy: [GiftItemView_Tidy] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Tidy: UIButton = {
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
        loadGiftData_Tidy()
        buildDimAndCard_Tidy()
        buildComp1_Tidy()
        buildComp2_Tidy()
        buildBuyBtn_Tidy()
        setupConstraints_Tidy()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：区分顶级礼物与普通礼物
    private func loadGiftData_Tidy() {
        let all = Store_Tidy.shared_Tidy.goodsList_Tidy
            .filter { !($0.goodIsVIP_Tidy ?? false) }
        topGift_Tidy    = all.first { $0.goodIsTop_Tidy ?? false }
        normalGifts_Tidy = Array(
            all.filter { !($0.goodIsTop_Tidy ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Tidy() {
        view.addSubview(dimView_Tidy)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Tidy))
        dimView_Tidy.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Tidy)
        bgCard_Tidy.clipsToBounds = true
        bgCard_Tidy.addSubview(bgImageView_Tidy)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Tidy.addSubview(comp1View_Tidy)
        bgCard_Tidy.addSubview(comp2View_Tidy)
    }

    // MARK: - 组件1：顶级礼物横向卡片

    /// 构建组件1（HStack：左侧价格+文字 / 右侧 gift_one 图片）
    /// 已购时禁用点击并显示 Already Purchased
    private func buildComp1_Tidy() {
        guard let top = topGift_Tidy else { return }
        let isPur_Tidy = Store_Tidy.shared_Tidy.isPur_Tidy

        /// 白色圆角卡片背景
        let card_Tidy = UIView()
        card_Tidy.backgroundColor = UIColor(hexstring_Tidy: "#2353E4")
        card_Tidy.layer.cornerRadius = 15
        card_Tidy.layer.masksToBounds = true
        comp1View_Tidy.addSubview(card_Tidy)
        card_Tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }
        comp1Card_Tidy = card_Tidy

        /// 禁用/降透
        card_Tidy.alpha = isPur_Tidy ? 0.55 : 1.0
        card_Tidy.isUserInteractionEnabled = !isPur_Tidy

        /// 左侧价格文字栈
        let priceLabel_Tidy = UILabel()
        priceLabel_Tidy.text      = top.goodsPrice_Tidy ?? ""
        priceLabel_Tidy.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        priceLabel_Tidy.textColor = .white
        comp1PriceLabel_Tidy = priceLabel_Tidy

        let subLabel_Tidy = UILabel()
        subLabel_Tidy.text      = isPur_Tidy ? "Already Purchased" : "Can only be purchased once"
        subLabel_Tidy.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        subLabel_Tidy.textColor = .white
        comp1SubLabel_Tidy = subLabel_Tidy

        let textStack_Tidy = UIStackView(arrangedSubviews: [priceLabel_Tidy, subLabel_Tidy])
        textStack_Tidy.axis      = .vertical
        textStack_Tidy.spacing   = 5
        textStack_Tidy.alignment = .leading

        /// 右侧礼物图（gift_one，72×72）
        let giftIV_Tidy = UIImageView()
        giftIV_Tidy.image       = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        giftIV_Tidy.contentMode = .scaleAspectFit
        giftIV_Tidy.snp.makeConstraints { make in make.width.height.equalTo(72) }

        /// HStack：文字 + 图片，间距 8，居中
        let hStack_Tidy = UIStackView(arrangedSubviews: [textStack_Tidy, giftIV_Tidy])
        hStack_Tidy.axis      = .horizontal
        hStack_Tidy.spacing   = 8
        hStack_Tidy.alignment = .center

        card_Tidy.addSubview(hStack_Tidy)
        hStack_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }

        /// 点击选中（未购时）
        if !isPur_Tidy {
            let tap_Tidy = UITapGestureRecognizer(target: self, action: #selector(comp1Tapped_Tidy))
            card_Tidy.addGestureRecognizer(tap_Tidy)
        }
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Tidy() {
        comp2View_Tidy.backgroundColor = .clear
        comp2Items_Tidy.removeAll()

        let row1_Tidy = Array(normalGifts_Tidy.prefix(4))
        let row2_Tidy: [StoreModel_Tidy] = normalGifts_Tidy.count > 4
            ? Array(normalGifts_Tidy[4...].prefix(4)) : []

        let rowStack1_Tidy = buildGridRow_Tidy(gifts: row1_Tidy, iconName: "gift_two")
        let rowStack2_Tidy = buildGridRow_Tidy(gifts: row2_Tidy, iconName: "gift_three")

        let outerStack_Tidy = UIStackView(arrangedSubviews: [rowStack1_Tidy, rowStack2_Tidy])
        outerStack_Tidy.axis         = .vertical
        outerStack_Tidy.spacing      = 12
        outerStack_Tidy.distribution = .fillEqually

        comp2View_Tidy.addSubview(outerStack_Tidy)
        outerStack_Tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，左右间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Tidy(gifts: [StoreModel_Tidy], iconName: String) -> UIStackView {
        var items_Tidy: [UIView] = []
        for i in 0..<4 {
            let gift_Tidy = i < gifts.count ? gifts[i] : nil
            let itemView_Tidy = GiftItemView_Tidy(iconName: iconName)
            if let gift_Tidy = gift_Tidy {
                itemView_Tidy.configure_Tidy(gift: gift_Tidy)
                comp2Items_Tidy.append(itemView_Tidy)
                let tap_Tidy = GiftItemTap_Tidy(
                    gift: gift_Tidy,
                    target: self,
                    action: #selector(gridItemTapped_Tidy(_:))
                )
                itemView_Tidy.isUserInteractionEnabled = true
                itemView_Tidy.addGestureRecognizer(tap_Tidy)
            } else {
                /// 空位透明占位
                itemView_Tidy.alpha = 0
                itemView_Tidy.isUserInteractionEnabled = false
            }
            items_Tidy.append(itemView_Tidy)
        }
        let stack_Tidy = UIStackView(arrangedSubviews: items_Tidy)
        stack_Tidy.axis         = .horizontal
        stack_Tidy.spacing      = 5
        stack_Tidy.distribution = .fillEqually
        return stack_Tidy
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Tidy() {
        bgCard_Tidy.addSubview(buyBtn_Tidy)
        buyBtn_Tidy.addTarget(self, action: #selector(buyTapped_Tidy), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Tidy() {
        let inset_Tidy = contentInset_Tidy
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Tidy: CGFloat = 109 * 2 + 12

        /// 全屏遮罩
        dimView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Tidy)
            make.height.equalTo(bgCardH_Tidy)
        }

        /// 背景图铺满 bgCard
        bgImageView_Tidy.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Tidy.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-50)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于购买按钮上方 10
        comp2View_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Tidy)
            make.trailing.equalToSuperview().offset(-inset_Tidy)
            make.height.equalTo(comp2H_Tidy)
            make.bottom.equalTo(buyBtn_Tidy.snp.top).offset(-10)
        }

        /// 组件1：宽 = contentW，高 72，位于组件2上方 10
        comp1View_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Tidy)
            make.trailing.equalToSuperview().offset(-inset_Tidy)
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Tidy.snp.top).offset(-10)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Tidy() {
        dismiss(animated: true)
    }

    /// 点击组件1（顶级礼物）
    @objc private func comp1Tapped_Tidy() {
        guard let top = topGift_Tidy else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Tidy = top
        refreshSelectionUI_Tidy(selectedId: top.goodsId_Tidy)
    }

    /// 点击组件2网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Tidy(_ tap: GiftItemTap_Tidy) {
        guard let gift = tap.gift_Tidy else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Tidy = gift
        refreshSelectionUI_Tidy(selectedId: gift.goodsId_Tidy)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Tidy() {
        guard let gift_Tidy = selectedGift_Tidy,
              let gid_Tidy  = gift_Tidy.goodsId_Tidy else {
            Utils_Tidy.showWarning_Tidy(message_Tidy: "Please select a gift first")
            return
        }
        Store_Tidy.shared_Tidy.PurchaseStoreGift_Tidy(gid_Tidy: gid_Tidy) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Tidy(selectedId: String?) {
        let normalBgColor_Tidy = UIColor(hexstring_Tidy: "#2353E4")
        let selectedBgColor_Tidy = UIColor.white
        let normalTextColor_Tidy = UIColor.white
        let selectedTextColor_Tidy = UIColor.black

        /// 组件1
        let isComp1_Tidy = selectedId == topGift_Tidy?.goodsId_Tidy
        UIView.animate(withDuration: 0.18) {
            self.comp1Card_Tidy?.backgroundColor = isComp1_Tidy ? selectedBgColor_Tidy : normalBgColor_Tidy
            self.comp1PriceLabel_Tidy?.textColor = isComp1_Tidy ? selectedTextColor_Tidy : normalTextColor_Tidy
            self.comp1SubLabel_Tidy?.textColor = isComp1_Tidy ? selectedTextColor_Tidy : normalTextColor_Tidy
        }

        /// 组件2
        comp2Items_Tidy.forEach { item_Tidy in
            let isSel_Tidy = item_Tidy.gift_Tidy?.goodsId_Tidy == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Tidy.applySelectionState_Tidy(
                    isSelected_Tidy: isSel_Tidy,
                    normalBgColor_Tidy: normalBgColor_Tidy,
                    selectedBgColor_Tidy: selectedBgColor_Tidy,
                    normalTextColor_Tidy: normalTextColor_Tidy,
                    selectedTextColor_Tidy: selectedTextColor_Tidy
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2网格，支持根据选中状态切换背景与文字颜色
/// 关键属性：gift_Tidy（绑定数据，供外部判断选中态）
class GiftItemView_Tidy: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Tidy: StoreModel_Tidy?

    // MARK: - UI 组件

    private let iconIV_Tidy: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，#111111
    private let nameLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，#111111
    private let priceLabel_Tidy: UILabel = {
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
        iconIV_Tidy.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Tidy()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Tidy() {
        backgroundColor = UIColor(hexstring_Tidy: "#2353E4")
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Tidy = UIStackView(arrangedSubviews: [iconIV_Tidy, nameLabel_Tidy, priceLabel_Tidy])
        vStack_Tidy.axis         = .vertical
        vStack_Tidy.spacing      = 5
        vStack_Tidy.alignment    = .center
        vStack_Tidy.distribution = .fill

        addSubview(vStack_Tidy)
        vStack_Tidy.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Tidy.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Tidy 礼物模型
    func configure_Tidy(gift: StoreModel_Tidy) {
        self.gift_Tidy     = gift
        nameLabel_Tidy.text  = gift.goodsName_Tidy  ?? ""
        priceLabel_Tidy.text = gift.goodsPrice_Tidy ?? ""
    }

    /// 应用礼物项选中态样式
    /// 参数：
    /// - isSelected_Tidy: 当前是否选中
    /// - normalBgColor_Tidy: 未选中背景色
    /// - selectedBgColor_Tidy: 选中背景色
    /// - normalTextColor_Tidy: 未选中文字色
    /// - selectedTextColor_Tidy: 选中文字色
    /// 返回值：无
    func applySelectionState_Tidy(isSelected_Tidy: Bool,
                                  normalBgColor_Tidy: UIColor,
                                  selectedBgColor_Tidy: UIColor,
                                  normalTextColor_Tidy: UIColor,
                                  selectedTextColor_Tidy: UIColor) {
        backgroundColor = isSelected_Tidy ? selectedBgColor_Tidy : normalBgColor_Tidy
        nameLabel_Tidy.textColor = isSelected_Tidy ? selectedTextColor_Tidy : normalTextColor_Tidy
        priceLabel_Tidy.textColor = isSelected_Tidy ? selectedTextColor_Tidy : normalTextColor_Tidy
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Tidy: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Tidy: StoreModel_Tidy?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Tidy, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Tidy = gift
    }
}
