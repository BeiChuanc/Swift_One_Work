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
///   - selectedGift_Somnia：当前选中的礼物
///   - refreshSelectionUI_Somnia：刷新选中态背景色
class GiftPage_Somnia: UIViewController {

    // MARK: - 布局常量

    private var screenW_Somnia: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Somnia: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Somnia: CGFloat { screenW_Somnia - 32 }
    /// bgCard 高 = 屏幕高 × 0.6
    private var bgCardH_Somnia: CGFloat { screenH_Somnia * 0.7 }
    /// 组件1/2 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Somnia: CGFloat { screenW_Somnia - 68 }
    private var contentInset_Somnia: CGFloat { (bgCardW_Somnia - contentW_Somnia) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买）
    private var topGift_Somnia: StoreModel_Somnia?
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Somnia: [StoreModel_Somnia] = []
    /// 当前选中的礼物
    private var selectedGift_Somnia: StoreModel_Somnia?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Somnia = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：顶级礼物横向卡片
    private let comp1View_Somnia = UIView()
    /// 组件1内部白色卡片（存储引用以更新选中态）
    private weak var comp1Card_Somnia: UIView?

    /// 组件2：普通礼物网格
    private let comp2View_Somnia = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Somnia: [GiftItemView_Somnia] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Somnia: UIButton = {
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
        loadGiftData_Somnia()
        buildDimAndCard_Somnia()
        buildComp1_Somnia()
        buildComp2_Somnia()
        buildBuyBtn_Somnia()
        setupConstraints_Somnia()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：区分顶级礼物与普通礼物
    private func loadGiftData_Somnia() {
        let all = Store_Somnia.shared_Somnia.goodsList_Somnia
            .filter { !($0.goodIsVIP_Somnia ?? false) }
        topGift_Somnia    = all.first { $0.goodIsTop_Somnia ?? false }
        normalGifts_Somnia = Array(
            all.filter { !($0.goodIsTop_Somnia ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Somnia() {
        view.addSubview(dimView_Somnia)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Somnia))
        dimView_Somnia.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Somnia)
        bgCard_Somnia.clipsToBounds = true
        bgCard_Somnia.addSubview(bgImageView_Somnia)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Somnia.addSubview(comp1View_Somnia)
        bgCard_Somnia.addSubview(comp2View_Somnia)
    }

    // MARK: - 组件1：顶级礼物横向卡片

    /// 构建组件1（HStack：左侧价格+文字 / 右侧 gift_one 图片）
    /// 已购时禁用点击并显示 Already Purchased
    private func buildComp1_Somnia() {
        guard let top = topGift_Somnia else { return }
        let isPur_Somnia = Store_Somnia.shared_Somnia.isPur_Somnia

        /// 白色圆角卡片背景
        let card_Somnia = UIView()
        card_Somnia.backgroundColor = .white
        card_Somnia.layer.cornerRadius = 15
        card_Somnia.layer.masksToBounds = true
        comp1View_Somnia.addSubview(card_Somnia)
        card_Somnia.snp.makeConstraints { make in make.edges.equalToSuperview() }
        comp1Card_Somnia = card_Somnia

        /// 禁用/降透
        card_Somnia.alpha = isPur_Somnia ? 0.55 : 1.0
        card_Somnia.isUserInteractionEnabled = !isPur_Somnia

        /// 左侧价格文字栈
        let priceLabel_Somnia = UILabel()
        priceLabel_Somnia.text      = top.goodsPrice_Somnia ?? ""
        priceLabel_Somnia.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        priceLabel_Somnia.textColor = UIColor(hexstring_Somnia: "#111111")

        let subLabel_Somnia = UILabel()
        subLabel_Somnia.text      = isPur_Somnia ? "Already Purchased" : "Can only be purchased once"
        subLabel_Somnia.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        subLabel_Somnia.textColor = UIColor(hexstring_Somnia: "#111111")

        let textStack_Somnia = UIStackView(arrangedSubviews: [priceLabel_Somnia, subLabel_Somnia])
        textStack_Somnia.axis      = .vertical
        textStack_Somnia.spacing   = 5
        textStack_Somnia.alignment = .leading

        /// 右侧礼物图（gift_one，72×72）
        let giftIV_Somnia = UIImageView()
        giftIV_Somnia.image       = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        giftIV_Somnia.contentMode = .scaleAspectFit
        giftIV_Somnia.snp.makeConstraints { make in make.width.height.equalTo(72) }

        /// HStack：文字 + 图片，间距 8，居中
        let hStack_Somnia = UIStackView(arrangedSubviews: [textStack_Somnia, giftIV_Somnia])
        hStack_Somnia.axis      = .horizontal
        hStack_Somnia.spacing   = 8
        hStack_Somnia.alignment = .center

        card_Somnia.addSubview(hStack_Somnia)
        hStack_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(16)
            make.trailing.lessThanOrEqualToSuperview().offset(-8)
        }

        /// 点击选中（未购时）
        if !isPur_Somnia {
            let tap_Somnia = UITapGestureRecognizer(target: self, action: #selector(comp1Tapped_Somnia))
            card_Somnia.addGestureRecognizer(tap_Somnia)
        }
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Somnia() {
        comp2View_Somnia.backgroundColor = .clear
        comp2Items_Somnia.removeAll()

        let row1_Somnia = Array(normalGifts_Somnia.prefix(4))
        let row2_Somnia: [StoreModel_Somnia] = normalGifts_Somnia.count > 4
            ? Array(normalGifts_Somnia[4...].prefix(4)) : []

        let rowStack1_Somnia = buildGridRow_Somnia(gifts: row1_Somnia, iconName: "gift_two")
        let rowStack2_Somnia = buildGridRow_Somnia(gifts: row2_Somnia, iconName: "gift_three")

        let outerStack_Somnia = UIStackView(arrangedSubviews: [rowStack1_Somnia, rowStack2_Somnia])
        outerStack_Somnia.axis         = .vertical
        outerStack_Somnia.spacing      = 12
        outerStack_Somnia.distribution = .fillEqually

        comp2View_Somnia.addSubview(outerStack_Somnia)
        outerStack_Somnia.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，左右间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Somnia(gifts: [StoreModel_Somnia], iconName: String) -> UIStackView {
        var items_Somnia: [UIView] = []
        for i in 0..<4 {
            let gift_Somnia = i < gifts.count ? gifts[i] : nil
            let itemView_Somnia = GiftItemView_Somnia(iconName: iconName)
            if let gift_Somnia = gift_Somnia {
                itemView_Somnia.configure_Somnia(gift: gift_Somnia)
                comp2Items_Somnia.append(itemView_Somnia)
                let tap_Somnia = GiftItemTap_Somnia(
                    gift: gift_Somnia,
                    target: self,
                    action: #selector(gridItemTapped_Somnia(_:))
                )
                itemView_Somnia.isUserInteractionEnabled = true
                itemView_Somnia.addGestureRecognizer(tap_Somnia)
            } else {
                /// 空位透明占位
                itemView_Somnia.alpha = 0
                itemView_Somnia.isUserInteractionEnabled = false
            }
            items_Somnia.append(itemView_Somnia)
        }
        let stack_Somnia = UIStackView(arrangedSubviews: items_Somnia)
        stack_Somnia.axis         = .horizontal
        stack_Somnia.spacing      = 5
        stack_Somnia.distribution = .fillEqually
        return stack_Somnia
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Somnia() {
        bgCard_Somnia.addSubview(buyBtn_Somnia)
        buyBtn_Somnia.addTarget(self, action: #selector(buyTapped_Somnia), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Somnia() {
        let inset_Somnia = contentInset_Somnia
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Somnia: CGFloat = 109 * 2 + 12

        /// 全屏遮罩
        dimView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Somnia)
            make.height.equalTo(bgCardH_Somnia)
        }

        /// 背景图铺满 bgCard
        bgImageView_Somnia.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Somnia.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-35)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于购买按钮上方 10
        comp2View_Somnia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Somnia)
            make.trailing.equalToSuperview().offset(-inset_Somnia)
            make.height.equalTo(comp2H_Somnia)
            make.bottom.equalTo(buyBtn_Somnia.snp.top).offset(-10)
        }

        /// 组件1：宽 = contentW，高 72，位于组件2上方 10
        comp1View_Somnia.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Somnia)
            make.trailing.equalToSuperview().offset(-inset_Somnia)
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Somnia.snp.top).offset(-10)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Somnia() {
        dismiss(animated: true)
    }

    /// 点击组件1（顶级礼物）
    @objc private func comp1Tapped_Somnia() {
        guard let top = topGift_Somnia else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Somnia = top
        refreshSelectionUI_Somnia(selectedId: top.goodsId_Somnia)
    }

    /// 点击组件2网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Somnia(_ tap: GiftItemTap_Somnia) {
        guard let gift = tap.gift_Somnia else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Somnia = gift
        refreshSelectionUI_Somnia(selectedId: gift.goodsId_Somnia)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Somnia() {
        guard let gift_Somnia = selectedGift_Somnia,
              let gid_Somnia  = gift_Somnia.goodsId_Somnia else {
            Utils_Somnia.showWarning_Somnia(message_Somnia: "Please select a gift first")
            return
        }
        Store_Somnia.shared_Somnia.PurchaseStoreGift_Somnia(gid_Somnia: gid_Somnia) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Somnia(selectedId: String?) {
        let selColor_Somnia = UIColor(hexstring_Somnia: "#A678F1").withAlphaComponent(0.25)

        /// 组件1
        let isComp1_Somnia = selectedId == topGift_Somnia?.goodsId_Somnia
        UIView.animate(withDuration: 0.18) {
            self.comp1Card_Somnia?.backgroundColor = isComp1_Somnia ? selColor_Somnia : .white
        }

        /// 组件2
        comp2Items_Somnia.forEach { item_Somnia in
            let isSel_Somnia = item_Somnia.gift_Somnia?.goodsId_Somnia == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Somnia.backgroundColor = isSel_Somnia ? selColor_Somnia : .white
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2网格，白色圆角背景，选中时变为浅紫色
/// 关键属性：gift_Somnia（绑定数据，供外部判断选中态）
class GiftItemView_Somnia: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Somnia: StoreModel_Somnia?

    // MARK: - UI 组件

    private let iconIV_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，#111111
    private let nameLabel_Somnia: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = UIColor(hexstring_Somnia: "#111111")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，#111111
    private let priceLabel_Somnia: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Somnia: "#111111")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    /// - Parameter iconName: 礼物图标 Assets 名称（gift_two / gift_three）
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Somnia.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Somnia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Somnia() {
        backgroundColor = .white
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Somnia = UIStackView(arrangedSubviews: [iconIV_Somnia, nameLabel_Somnia, priceLabel_Somnia])
        vStack_Somnia.axis         = .vertical
        vStack_Somnia.spacing      = 5
        vStack_Somnia.alignment    = .center
        vStack_Somnia.distribution = .fill

        addSubview(vStack_Somnia)
        vStack_Somnia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Somnia.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Somnia 礼物模型
    func configure_Somnia(gift: StoreModel_Somnia) {
        self.gift_Somnia     = gift
        nameLabel_Somnia.text  = gift.goodsName_Somnia  ?? ""
        priceLabel_Somnia.text = gift.goodsPrice_Somnia ?? ""
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Somnia: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Somnia: StoreModel_Somnia?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Somnia, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Somnia = gift
    }
}
