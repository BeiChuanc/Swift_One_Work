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
///   - selectedGift_Orna：当前选中的礼物
///   - refreshSelectionUI_Orna：刷新选中态背景色
class GiftPage_Orna: UIViewController {

    // MARK: - 布局常量

    private var screenW_Orna: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Orna: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Orna: CGFloat { screenW_Orna - 32 }
    /// bgCard 高 = 屏幕高 × 0.6
    private var bgCardH_Orna: CGFloat { screenH_Orna * 0.65 }
    /// 组件1/2 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Orna: CGFloat { screenW_Orna - 68 }
    private var contentInset_Orna: CGFloat { (bgCardW_Orna - contentW_Orna) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买）
    private var topGift_Orna: StoreModel_Orna?
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Orna: [StoreModel_Orna] = []
    /// 当前选中的礼物
    private var selectedGift_Orna: StoreModel_Orna?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Orna = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：顶级礼物横向卡片
    private let comp1View_Orna = UIView()
    /// 组件1内部白色卡片（存储引用以更新选中态）
    private weak var comp1Card_Orna: UIView?
    private weak var comp1PriceLabel_Orna: UILabel?
    private weak var comp1SubLabel_Orna: UILabel?

    /// 组件2：普通礼物网格
    private let comp2View_Orna = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Orna: [GiftItemView_Orna] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Orna: UIButton = {
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
        loadGiftData_Orna()
        buildDimAndCard_Orna()
        buildComp1_Orna()
        buildComp2_Orna()
        buildBuyBtn_Orna()
        setupConstraints_Orna()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：区分顶级礼物与普通礼物
    private func loadGiftData_Orna() {
        let all = Store_Orna.shared_Orna.goodsList_Orna
            .filter { !($0.goodIsVIP_Orna ?? false) }
        topGift_Orna    = all.first { $0.goodIsTop_Orna ?? false }
        normalGifts_Orna = Array(
            all.filter { !($0.goodIsTop_Orna ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Orna() {
        view.addSubview(dimView_Orna)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Orna))
        dimView_Orna.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Orna)
        bgCard_Orna.clipsToBounds = true
        bgCard_Orna.addSubview(bgImageView_Orna)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Orna.addSubview(comp1View_Orna)
        bgCard_Orna.addSubview(comp2View_Orna)
    }

    // MARK: - 组件1：顶级礼物横向卡片

    /// 构建组件1（HStack：左侧价格+文字 / 右侧 gift_one 图片）
    /// 已购时禁用点击并显示 Already Purchased
    private func buildComp1_Orna() {
        guard let top = topGift_Orna else { return }

        /// 白色圆角卡片背景
        let card_Orna = UIView()
        card_Orna.backgroundColor = UIColor(hexstring_Orna: "#2353E4")
        card_Orna.layer.cornerRadius = 15
        card_Orna.layer.masksToBounds = true
        comp1View_Orna.addSubview(card_Orna)
        card_Orna.snp.makeConstraints { make in make.edges.equalToSuperview() }
        comp1Card_Orna = card_Orna

        /// 禁用/降透
        card_Orna.alpha = 1.0
        card_Orna.isUserInteractionEnabled = true

        /// 左侧价格文字栈
        let priceLabel_Orna = UILabel()
        priceLabel_Orna.text      = top.goodsPrice_Orna ?? ""
        priceLabel_Orna.font      = UIFont.funFont_Orna(ofSize: 14, weight: .regular)
        priceLabel_Orna.textColor = .white
        comp1PriceLabel_Orna = priceLabel_Orna

        let subLabel_Orna = UILabel()
        subLabel_Orna.text      = "Can only be purchased once"
        subLabel_Orna.font      = UIFont.funFont_Orna(ofSize: 10, weight: .regular)
        subLabel_Orna.textColor = .white
        comp1SubLabel_Orna = subLabel_Orna

        let textStack_Orna = UIStackView(arrangedSubviews: [priceLabel_Orna, subLabel_Orna])
        textStack_Orna.axis      = .vertical
        textStack_Orna.spacing   = 5
        textStack_Orna.alignment = .leading

        /// 右侧礼物图（gift_one，72×72）
        let giftIV_Orna = UIImageView()
        giftIV_Orna.image       = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        giftIV_Orna.contentMode = .scaleAspectFit
        giftIV_Orna.snp.makeConstraints { make in make.width.height.equalTo(72) }

        /// HStack：文字 + 图片，间距 8，居中
        let hStack_Orna = UIStackView(arrangedSubviews: [textStack_Orna, giftIV_Orna])
        hStack_Orna.axis      = .horizontal
        hStack_Orna.spacing   = 8
        hStack_Orna.alignment = .center

        card_Orna.addSubview(hStack_Orna)
        hStack_Orna.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Orna() {
        comp2View_Orna.backgroundColor = .clear
        comp2Items_Orna.removeAll()

        let row1_Orna = Array(normalGifts_Orna.prefix(4))
        let row2_Orna: [StoreModel_Orna] = normalGifts_Orna.count > 4
            ? Array(normalGifts_Orna[4...].prefix(4)) : []

        let rowStack1_Orna = buildGridRow_Orna(gifts: row1_Orna, iconName: "gift_two")
        let rowStack2_Orna = buildGridRow_Orna(gifts: row2_Orna, iconName: "gift_three")

        let outerStack_Orna = UIStackView(arrangedSubviews: [rowStack1_Orna, rowStack2_Orna])
        outerStack_Orna.axis         = .vertical
        outerStack_Orna.spacing      = 12
        outerStack_Orna.distribution = .fillEqually

        comp2View_Orna.addSubview(outerStack_Orna)
        outerStack_Orna.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，左右间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Orna(gifts: [StoreModel_Orna], iconName: String) -> UIStackView {
        var items_Orna: [UIView] = []
        for i in 0..<4 {
            let gift_Orna = i < gifts.count ? gifts[i] : nil
            let itemView_Orna = GiftItemView_Orna(iconName: iconName)
            if let gift_Orna = gift_Orna {
                itemView_Orna.configure_Orna(gift: gift_Orna)
                comp2Items_Orna.append(itemView_Orna)
                let tap_Orna = GiftItemTap_Orna(
                    gift: gift_Orna,
                    target: self,
                    action: #selector(gridItemTapped_Orna(_:))
                )
                itemView_Orna.isUserInteractionEnabled = true
                itemView_Orna.addGestureRecognizer(tap_Orna)
            } else {
                /// 空位透明占位
                itemView_Orna.alpha = 0
                itemView_Orna.isUserInteractionEnabled = false
            }
            items_Orna.append(itemView_Orna)
        }
        let stack_Orna = UIStackView(arrangedSubviews: items_Orna)
        stack_Orna.axis         = .horizontal
        stack_Orna.spacing      = 5
        stack_Orna.distribution = .fillEqually
        return stack_Orna
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Orna() {
        bgCard_Orna.addSubview(buyBtn_Orna)
        buyBtn_Orna.addTarget(self, action: #selector(buyTapped_Orna), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Orna() {
        let inset_Orna = contentInset_Orna
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Orna: CGFloat = 109 * 2 + 12

        /// 全屏遮罩
        dimView_Orna.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Orna.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Orna)
            make.height.equalTo(bgCardH_Orna)
        }

        /// 背景图铺满 bgCard
        bgImageView_Orna.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Orna.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-50)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于购买按钮上方 10
        comp2View_Orna.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Orna)
            make.trailing.equalToSuperview().offset(-inset_Orna)
            make.height.equalTo(comp2H_Orna)
            make.bottom.equalTo(buyBtn_Orna.snp.top).offset(-10)
        }

        /// 组件1：宽 = contentW，高 72，位于组件2上方 10
        comp1View_Orna.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Orna)
            make.trailing.equalToSuperview().offset(-inset_Orna)
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Orna.snp.top).offset(-10)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Orna() {
        dismiss(animated: true)
    }

    /// 点击组件1（顶级礼物）
    @objc private func comp1Tapped_Orna() {
        guard let top = topGift_Orna else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Orna = top
        refreshSelectionUI_Orna(selectedId: top.goodsId_Orna)
    }

    /// 点击组件2网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Orna(_ tap: GiftItemTap_Orna) {
        guard let gift = tap.gift_Orna else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Orna = gift
        refreshSelectionUI_Orna(selectedId: gift.goodsId_Orna)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Orna() {
        guard let gift_Orna = selectedGift_Orna,
              let gid_Orna  = gift_Orna.goodsId_Orna else {
            Load_Orna.showWarning_Orna(message_Orna: "Please select a gift first")
            return
        }
        Store_Orna.shared_Orna.PurchaseStoreGift_Orna(gid_Orna: gid_Orna) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Orna(selectedId: String?) {
        let normalBgColor_Orna = UIColor(hexstring_Orna: "#2353E4")
        let selectedBgColor_Orna = UIColor.white
        let normalTextColor_Orna = UIColor.white
        let selectedTextColor_Orna = UIColor.black

        /// 组件1
        let isComp1_Orna = selectedId == topGift_Orna?.goodsId_Orna
        UIView.animate(withDuration: 0.18) {
            self.comp1Card_Orna?.backgroundColor = isComp1_Orna ? selectedBgColor_Orna : normalBgColor_Orna
            self.comp1PriceLabel_Orna?.textColor = isComp1_Orna ? selectedTextColor_Orna : normalTextColor_Orna
            self.comp1SubLabel_Orna?.textColor = isComp1_Orna ? selectedTextColor_Orna : normalTextColor_Orna
        }

        /// 组件2
        comp2Items_Orna.forEach { item_Orna in
            let isSel_Orna = item_Orna.gift_Orna?.goodsId_Orna == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Orna.applySelectionState_Orna(
                    isSelected_Orna: isSel_Orna,
                    normalBgColor_Orna: normalBgColor_Orna,
                    selectedBgColor_Orna: selectedBgColor_Orna,
                    normalTextColor_Orna: normalTextColor_Orna,
                    selectedTextColor_Orna: selectedTextColor_Orna
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2网格，支持根据选中状态切换背景与文字颜色
/// 关键属性：gift_Orna（绑定数据，供外部判断选中态）
class GiftItemView_Orna: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Orna: StoreModel_Orna?

    // MARK: - UI 组件

    private let iconIV_Orna: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，#111111
    private let nameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font      = UIFont.funFont_Orna(ofSize: 10, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，#111111
    private let priceLabel_Orna: UILabel = {
        let l = UILabel()
        l.font      = UIFont.funFont_Orna(ofSize: 14, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    /// - Parameter iconName: 礼物图标 Assets 名称（gift_two / gift_three）
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Orna.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Orna() {
        backgroundColor = UIColor(hexstring_Orna: "#2353E4")
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Orna = UIStackView(arrangedSubviews: [iconIV_Orna, nameLabel_Orna, priceLabel_Orna])
        vStack_Orna.axis         = .vertical
        vStack_Orna.spacing      = 5
        vStack_Orna.alignment    = .center
        vStack_Orna.distribution = .fill

        addSubview(vStack_Orna)
        vStack_Orna.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Orna 礼物模型
    func configure_Orna(gift: StoreModel_Orna) {
        self.gift_Orna     = gift
        nameLabel_Orna.text  = gift.goodsName_Orna  ?? ""
        priceLabel_Orna.text = gift.goodsPrice_Orna ?? ""
    }

    /// 应用礼物项选中态样式
    /// 参数：
    /// - isSelected_Orna: 当前是否选中
    /// - normalBgColor_Orna: 未选中背景色
    /// - selectedBgColor_Orna: 选中背景色
    /// - normalTextColor_Orna: 未选中文字色
    /// - selectedTextColor_Orna: 选中文字色
    /// 返回值：无
    func applySelectionState_Orna(isSelected_Orna: Bool,
                                  normalBgColor_Orna: UIColor,
                                  selectedBgColor_Orna: UIColor,
                                  normalTextColor_Orna: UIColor,
                                  selectedTextColor_Orna: UIColor) {
        backgroundColor = isSelected_Orna ? selectedBgColor_Orna : normalBgColor_Orna
        nameLabel_Orna.textColor = isSelected_Orna ? selectedTextColor_Orna : normalTextColor_Orna
        priceLabel_Orna.textColor = isSelected_Orna ? selectedTextColor_Orna : normalTextColor_Orna
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Orna: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Orna: StoreModel_Orna?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Orna, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Orna = gift
    }
}
