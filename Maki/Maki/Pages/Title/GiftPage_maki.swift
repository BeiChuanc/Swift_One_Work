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
///   - selectedGift_Maki：当前选中的礼物
///   - refreshSelectionUI_Maki：刷新选中态背景色
class GiftPage_Maki: UIViewController {

    // MARK: - 布局常量

    private var screenW_Maki: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Maki: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Maki: CGFloat { screenW_Maki - 32 }
    /// bgCard 高 = 屏幕高 × 0.6
    private var bgCardH_Maki: CGFloat { screenH_Maki * 0.65 }
    /// 组件1/2 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Maki: CGFloat { screenW_Maki - 68 }
    private var contentInset_Maki: CGFloat { (bgCardW_Maki - contentW_Maki) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买）
    private var topGift_Maki: StoreModel_Maki?
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Maki: [StoreModel_Maki] = []
    /// 当前选中的礼物
    private var selectedGift_Maki: StoreModel_Maki?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Maki: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Maki = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Maki: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：顶级礼物横向卡片
    private let comp1View_Maki = UIView()
    /// 组件1内部白色卡片（存储引用以更新选中态）
    private weak var comp1Card_Maki: UIView?
    private weak var comp1PriceLabel_Maki: UILabel?
    private weak var comp1SubLabel_Maki: UILabel?

    /// 组件2：普通礼物网格
    private let comp2View_Maki = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Maki: [GiftItemView_Maki] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Maki: UIButton = {
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
        loadGiftData_Maki()
        buildDimAndCard_Maki()
        buildComp1_Maki()
        buildComp2_Maki()
        buildBuyBtn_Maki()
        setupConstraints_Maki()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：区分顶级礼物与普通礼物
    private func loadGiftData_Maki() {
        let all = Store_Maki.shared_Maki.goodsList_Maki
            .filter { !($0.goodIsVIP_Maki ?? false) }
        topGift_Maki    = all.first { $0.goodIsTop_Maki ?? false }
        normalGifts_Maki = Array(
            all.filter { !($0.goodIsTop_Maki ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Maki() {
        view.addSubview(dimView_Maki)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Maki))
        dimView_Maki.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Maki)
        bgCard_Maki.clipsToBounds = true
        bgCard_Maki.addSubview(bgImageView_Maki)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Maki.addSubview(comp1View_Maki)
        bgCard_Maki.addSubview(comp2View_Maki)
    }

    // MARK: - 组件1：顶级礼物横向卡片

    /// 构建组件1（HStack：左侧价格+文字 / 右侧 gift_one 图片）
    /// 已购时禁用点击并显示 Already Purchased
    private func buildComp1_Maki() {
        guard let top = topGift_Maki else { return }

        /// 白色圆角卡片背景
        let card_Maki = UIView()
        card_Maki.backgroundColor = UIColor(hexstring_Maki: "#2353E4")
        card_Maki.layer.cornerRadius = 15
        card_Maki.layer.masksToBounds = true
        comp1View_Maki.addSubview(card_Maki)
        card_Maki.snp.makeConstraints { make in make.edges.equalToSuperview() }
        comp1Card_Maki = card_Maki

        /// 禁用/降透
        card_Maki.alpha = 1.0
        card_Maki.isUserInteractionEnabled = true

        /// 左侧价格文字栈
        let priceLabel_Maki = UILabel()
        priceLabel_Maki.text      = top.goodsPrice_Maki ?? ""
        priceLabel_Maki.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        priceLabel_Maki.textColor = .white
        comp1PriceLabel_Maki = priceLabel_Maki

        let subLabel_Maki = UILabel()
        subLabel_Maki.text      = "Can only be purchased once"
        subLabel_Maki.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        subLabel_Maki.textColor = .white
        comp1SubLabel_Maki = subLabel_Maki

        let textStack_Maki = UIStackView(arrangedSubviews: [priceLabel_Maki, subLabel_Maki])
        textStack_Maki.axis      = .vertical
        textStack_Maki.spacing   = 5
        textStack_Maki.alignment = .leading

        /// 右侧礼物图（gift_one，72×72）
        let giftIV_Maki = UIImageView()
        giftIV_Maki.image       = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        giftIV_Maki.contentMode = .scaleAspectFit
        giftIV_Maki.snp.makeConstraints { make in make.width.height.equalTo(72) }

        /// HStack：文字 + 图片，间距 8，居中
        let hStack_Maki = UIStackView(arrangedSubviews: [textStack_Maki, giftIV_Maki])
        hStack_Maki.axis      = .horizontal
        hStack_Maki.spacing   = 8
        hStack_Maki.alignment = .center

        card_Maki.addSubview(hStack_Maki)
        hStack_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Maki() {
        comp2View_Maki.backgroundColor = .clear
        comp2Items_Maki.removeAll()

        let row1_Maki = Array(normalGifts_Maki.prefix(4))
        let row2_Maki: [StoreModel_Maki] = normalGifts_Maki.count > 4
            ? Array(normalGifts_Maki[4...].prefix(4)) : []

        let rowStack1_Maki = buildGridRow_Maki(gifts: row1_Maki, iconName: "gift_two")
        let rowStack2_Maki = buildGridRow_Maki(gifts: row2_Maki, iconName: "gift_three")

        let outerStack_Maki = UIStackView(arrangedSubviews: [rowStack1_Maki, rowStack2_Maki])
        outerStack_Maki.axis         = .vertical
        outerStack_Maki.spacing      = 12
        outerStack_Maki.distribution = .fillEqually

        comp2View_Maki.addSubview(outerStack_Maki)
        outerStack_Maki.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，左右间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Maki(gifts: [StoreModel_Maki], iconName: String) -> UIStackView {
        var items_Maki: [UIView] = []
        for i in 0..<4 {
            let gift_Maki = i < gifts.count ? gifts[i] : nil
            let itemView_Maki = GiftItemView_Maki(iconName: iconName)
            if let gift_Maki = gift_Maki {
                itemView_Maki.configure_Maki(gift: gift_Maki)
                comp2Items_Maki.append(itemView_Maki)
                let tap_Maki = GiftItemTap_Maki(
                    gift: gift_Maki,
                    target: self,
                    action: #selector(gridItemTapped_Maki(_:))
                )
                itemView_Maki.isUserInteractionEnabled = true
                itemView_Maki.addGestureRecognizer(tap_Maki)
            } else {
                /// 空位透明占位
                itemView_Maki.alpha = 0
                itemView_Maki.isUserInteractionEnabled = false
            }
            items_Maki.append(itemView_Maki)
        }
        let stack_Maki = UIStackView(arrangedSubviews: items_Maki)
        stack_Maki.axis         = .horizontal
        stack_Maki.spacing      = 5
        stack_Maki.distribution = .fillEqually
        return stack_Maki
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Maki() {
        bgCard_Maki.addSubview(buyBtn_Maki)
        buyBtn_Maki.addTarget(self, action: #selector(buyTapped_Maki), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Maki() {
        let inset_Maki = contentInset_Maki
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Maki: CGFloat = 109 * 2 + 12

        /// 全屏遮罩
        dimView_Maki.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Maki)
            make.height.equalTo(bgCardH_Maki)
        }

        /// 背景图铺满 bgCard
        bgImageView_Maki.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Maki.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-50)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于购买按钮上方 10
        comp2View_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Maki)
            make.trailing.equalToSuperview().offset(-inset_Maki)
            make.height.equalTo(comp2H_Maki)
            make.bottom.equalTo(buyBtn_Maki.snp.top).offset(-10)
        }

        /// 组件1：宽 = contentW，高 72，位于组件2上方 10
        comp1View_Maki.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Maki)
            make.trailing.equalToSuperview().offset(-inset_Maki)
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Maki.snp.top).offset(-10)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Maki() {
        dismiss(animated: true)
    }

    /// 点击组件1（顶级礼物）
    @objc private func comp1Tapped_Maki() {
        guard let top = topGift_Maki else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Maki = top
        refreshSelectionUI_Maki(selectedId: top.goodsId_Maki)
    }

    /// 点击组件2网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Maki(_ tap: GiftItemTap_Maki) {
        guard let gift = tap.gift_Maki else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Maki = gift
        refreshSelectionUI_Maki(selectedId: gift.goodsId_Maki)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Maki() {
        guard let gift_Maki = selectedGift_Maki,
              let gid_Maki  = gift_Maki.goodsId_Maki else {
            Load_Maki.showWarning_Maki(message_Maki: "Please select a gift first")
            return
        }
        Store_Maki.shared_Maki.PurchaseStoreGift_Maki(gid_Maki: gid_Maki) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Maki(selectedId: String?) {
        let normalBgColor_Maki = UIColor(hexstring_Maki: "#2353E4")
        let selectedBgColor_Maki = UIColor.white
        let normalTextColor_Maki = UIColor.white
        let selectedTextColor_Maki = UIColor.black

        /// 组件1
        let isComp1_Maki = selectedId == topGift_Maki?.goodsId_Maki
        UIView.animate(withDuration: 0.18) {
            self.comp1Card_Maki?.backgroundColor = isComp1_Maki ? selectedBgColor_Maki : normalBgColor_Maki
            self.comp1PriceLabel_Maki?.textColor = isComp1_Maki ? selectedTextColor_Maki : normalTextColor_Maki
            self.comp1SubLabel_Maki?.textColor = isComp1_Maki ? selectedTextColor_Maki : normalTextColor_Maki
        }

        /// 组件2
        comp2Items_Maki.forEach { item_Maki in
            let isSel_Maki = item_Maki.gift_Maki?.goodsId_Maki == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Maki.applySelectionState_Maki(
                    isSelected_Maki: isSel_Maki,
                    normalBgColor_Maki: normalBgColor_Maki,
                    selectedBgColor_Maki: selectedBgColor_Maki,
                    normalTextColor_Maki: normalTextColor_Maki,
                    selectedTextColor_Maki: selectedTextColor_Maki
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2网格，支持根据选中状态切换背景与文字颜色
/// 关键属性：gift_Maki（绑定数据，供外部判断选中态）
class GiftItemView_Maki: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Maki: StoreModel_Maki?

    // MARK: - UI 组件

    private let iconIV_Maki: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，#111111
    private let nameLabel_Maki: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，#111111
    private let priceLabel_Maki: UILabel = {
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
        iconIV_Maki.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Maki()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Maki() {
        backgroundColor = UIColor(hexstring_Maki: "#2353E4")
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Maki = UIStackView(arrangedSubviews: [iconIV_Maki, nameLabel_Maki, priceLabel_Maki])
        vStack_Maki.axis         = .vertical
        vStack_Maki.spacing      = 5
        vStack_Maki.alignment    = .center
        vStack_Maki.distribution = .fill

        addSubview(vStack_Maki)
        vStack_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Maki 礼物模型
    func configure_Maki(gift: StoreModel_Maki) {
        self.gift_Maki     = gift
        nameLabel_Maki.text  = gift.goodsName_Maki  ?? ""
        priceLabel_Maki.text = gift.goodsPrice_Maki ?? ""
    }

    /// 应用礼物项选中态样式
    /// 参数：
    /// - isSelected_Maki: 当前是否选中
    /// - normalBgColor_Maki: 未选中背景色
    /// - selectedBgColor_Maki: 选中背景色
    /// - normalTextColor_Maki: 未选中文字色
    /// - selectedTextColor_Maki: 选中文字色
    /// 返回值：无
    func applySelectionState_Maki(isSelected_Maki: Bool,
                                  normalBgColor_Maki: UIColor,
                                  selectedBgColor_Maki: UIColor,
                                  normalTextColor_Maki: UIColor,
                                  selectedTextColor_Maki: UIColor) {
        backgroundColor = isSelected_Maki ? selectedBgColor_Maki : normalBgColor_Maki
        nameLabel_Maki.textColor = isSelected_Maki ? selectedTextColor_Maki : normalTextColor_Maki
        priceLabel_Maki.textColor = isSelected_Maki ? selectedTextColor_Maki : normalTextColor_Maki
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Maki: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Maki: StoreModel_Maki?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Maki, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Maki = gift
    }
}
