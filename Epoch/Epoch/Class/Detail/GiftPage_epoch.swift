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
///   - selectedGift_Epoch：当前选中的礼物
///   - refreshSelectionUI_Epoch：刷新选中态背景色
class GiftPage_Epoch: UIViewController {

    // MARK: - 布局常量

    private var screenW_Epoch: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Epoch: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Epoch: CGFloat { screenW_Epoch - 32 }
    /// bgCard 高 = 屏幕高 × 0.6
    private var bgCardH_Epoch: CGFloat { screenH_Epoch * 0.65 }
    /// 组件1/2 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Epoch: CGFloat { screenW_Epoch - 68 }
    private var contentInset_Epoch: CGFloat { (bgCardW_Epoch - contentW_Epoch) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买）
    private var topGift_Epoch: StoreModel_Epoch?
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Epoch: [StoreModel_Epoch] = []
    /// 当前选中的礼物
    private var selectedGift_Epoch: StoreModel_Epoch?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Epoch = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：顶级礼物横向卡片
    private let comp1View_Epoch = UIView()
    /// 组件1内部卡片（存储引用以更新选中态背景色）
    private weak var comp1Card_Epoch: UIView?
    /// 组件1信息标签（价格+描述一行，存储引用以更新选中态字色）
    private weak var comp1InfoLabel_Epoch: UILabel?

    /// 组件2：普通礼物网格
    private let comp2View_Epoch = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Epoch: [GiftItemView_Epoch] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Epoch: UIButton = {
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
        loadGiftData_Epoch()
        buildDimAndCard_Epoch()
        buildComp1_Epoch()
        buildComp2_Epoch()
        buildBuyBtn_Epoch()
        setupConstraints_Epoch()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：区分顶级礼物与普通礼物
    private func loadGiftData_Epoch() {
        let all = Store_Epoch.shared_Epoch.goodsList_Epoch
            .filter { !($0.goodIsVIP_Epoch ?? false) }
        topGift_Epoch    = all.first { $0.goodIsTop_Epoch ?? false }
        normalGifts_Epoch = Array(
            all.filter { !($0.goodIsTop_Epoch ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Epoch() {
        view.addSubview(dimView_Epoch)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Epoch))
        dimView_Epoch.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Epoch)
        bgCard_Epoch.clipsToBounds = true
        bgCard_Epoch.addSubview(bgImageView_Epoch)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Epoch.addSubview(comp1View_Epoch)
        bgCard_Epoch.addSubview(comp2View_Epoch)
    }

    // MARK: - 组件1：顶级礼物横向卡片

    /// 构建组件1（HStack：左侧 gift_one 图片 / 右侧价格+描述一行文字）
    /// 未选中背景 #F93AA7，选中背景白色；已购时禁用点击并显示 Already Purchased
    private func buildComp1_Epoch() {
        guard let top = topGift_Epoch else { return }
        let isPur_Epoch = Store_Epoch.shared_Epoch.isPur_Epoch

        /// 圆角卡片背景，初始为未选中粉色
        let card_Epoch = UIView()
        card_Epoch.backgroundColor = UIColor(hexstring_Epoch: "#F93AA7")
        card_Epoch.layer.cornerRadius = 15
        card_Epoch.layer.masksToBounds = true
        comp1View_Epoch.addSubview(card_Epoch)
        card_Epoch.snp.makeConstraints { make in make.edges.equalToSuperview() }
        comp1Card_Epoch = card_Epoch

        /// 禁用/降透
        card_Epoch.alpha = isPur_Epoch ? 0.55 : 1.0
        card_Epoch.isUserInteractionEnabled = !isPur_Epoch

        /// 左侧礼物图（gift_one，72×72）
        let giftIV_Epoch = UIImageView()
        giftIV_Epoch.image       = UIImage(named: "gift_one")?.withRenderingMode(.alwaysOriginal)
        giftIV_Epoch.contentMode = .scaleAspectFit
        giftIV_Epoch.snp.makeConstraints { make in make.width.height.equalTo(72) }

        /// 右侧价格+描述一行文字，初始为白色（未选中）
        let subtitle_Epoch = isPur_Epoch ? "Already Purchased" : "Can only be purchased once"
        let infoLabel_Epoch = UILabel()
        infoLabel_Epoch.text      = "\(top.goodsPrice_Epoch ?? "")  \(subtitle_Epoch)"
        infoLabel_Epoch.font      = UIFont.systemFont(ofSize: 13, weight: .regular)
        infoLabel_Epoch.textColor = .white
        infoLabel_Epoch.numberOfLines = 1
        comp1InfoLabel_Epoch = infoLabel_Epoch

        /// HStack：图片在左 + 文字在右，间距 8，居中
        let hStack_Epoch = UIStackView(arrangedSubviews: [giftIV_Epoch, infoLabel_Epoch])
        hStack_Epoch.axis      = .horizontal
        hStack_Epoch.spacing   = 8
        hStack_Epoch.alignment = .center

        card_Epoch.addSubview(hStack_Epoch)
        hStack_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(12)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }

        /// 点击选中（未购时）
        if !isPur_Epoch {
            let tap_Epoch = UITapGestureRecognizer(target: self, action: #selector(comp1Tapped_Epoch))
            card_Epoch.addGestureRecognizer(tap_Epoch)
        }
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Epoch() {
        comp2View_Epoch.backgroundColor = .clear
        comp2Items_Epoch.removeAll()

        let row1_Epoch = Array(normalGifts_Epoch.prefix(4))
        let row2_Epoch: [StoreModel_Epoch] = normalGifts_Epoch.count > 4
            ? Array(normalGifts_Epoch[4...].prefix(4)) : []

        let rowStack1_Epoch = buildGridRow_Epoch(gifts: row1_Epoch, iconName: "gift_two")
        let rowStack2_Epoch = buildGridRow_Epoch(gifts: row2_Epoch, iconName: "gift_three")

        let outerStack_Epoch = UIStackView(arrangedSubviews: [rowStack1_Epoch, rowStack2_Epoch])
        outerStack_Epoch.axis         = .vertical
        outerStack_Epoch.spacing      = 12
        outerStack_Epoch.distribution = .fillEqually

        comp2View_Epoch.addSubview(outerStack_Epoch)
        outerStack_Epoch.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，左右间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Epoch(gifts: [StoreModel_Epoch], iconName: String) -> UIStackView {
        var items_Epoch: [UIView] = []
        for i in 0..<4 {
            let gift_Epoch = i < gifts.count ? gifts[i] : nil
            let itemView_Epoch = GiftItemView_Epoch(iconName: iconName)
            if let gift_Epoch = gift_Epoch {
                itemView_Epoch.configure_Epoch(gift: gift_Epoch)
                comp2Items_Epoch.append(itemView_Epoch)
                let tap_Epoch = GiftItemTap_Epoch(
                    gift: gift_Epoch,
                    target: self,
                    action: #selector(gridItemTapped_Epoch(_:))
                )
                itemView_Epoch.isUserInteractionEnabled = true
                itemView_Epoch.addGestureRecognizer(tap_Epoch)
            } else {
                /// 空位透明占位
                itemView_Epoch.alpha = 0
                itemView_Epoch.isUserInteractionEnabled = false
            }
            items_Epoch.append(itemView_Epoch)
        }
        let stack_Epoch = UIStackView(arrangedSubviews: items_Epoch)
        stack_Epoch.axis         = .horizontal
        stack_Epoch.spacing      = 5
        stack_Epoch.distribution = .fillEqually
        return stack_Epoch
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Epoch() {
        bgCard_Epoch.addSubview(buyBtn_Epoch)
        buyBtn_Epoch.addTarget(self, action: #selector(buyTapped_Epoch), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    private func setupConstraints_Epoch() {
        let inset_Epoch = contentInset_Epoch
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Epoch: CGFloat = 109 * 2 + 12

        /// 全屏遮罩
        dimView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Epoch)
            make.height.equalTo(bgCardH_Epoch)
        }

        /// 背景图铺满 bgCard
        bgImageView_Epoch.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Epoch.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-30)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于购买按钮上方 10
        comp2View_Epoch.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Epoch)
            make.trailing.equalToSuperview().offset(-inset_Epoch)
            make.height.equalTo(comp2H_Epoch)
            make.bottom.equalTo(buyBtn_Epoch.snp.top).offset(-10)
        }

        /// 组件1：宽 = contentW，高 72，位于组件2上方 10
        comp1View_Epoch.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Epoch)
            make.trailing.equalToSuperview().offset(-inset_Epoch)
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Epoch.snp.top).offset(-10)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Epoch() {
        dismiss(animated: true)
    }

    /// 点击组件1（顶级礼物）
    @objc private func comp1Tapped_Epoch() {
        guard let top = topGift_Epoch else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Epoch = top
        refreshSelectionUI_Epoch(selectedId: top.goodsId_Epoch)
    }

    /// 点击组件2网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Epoch(_ tap: GiftItemTap_Epoch) {
        guard let gift = tap.gift_Epoch else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Epoch = gift
        refreshSelectionUI_Epoch(selectedId: gift.goodsId_Epoch)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Epoch() {
        guard let gift_Epoch = selectedGift_Epoch,
              let gid_Epoch  = gift_Epoch.goodsId_Epoch else {
            Utils_Epoch.showWarning_Epoch(message_Epoch: "Please select a gift first")
            return
        }
        Store_Epoch.shared_Epoch.PurchaseStoreGift_Epoch(gid_Epoch: gid_Epoch) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中态（背景色与字色）
    /// 选中：白色背景 + 黑色字体；未选中：#F93AA7 背景 + 白色字体
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Epoch(selectedId: String?) {
        let unselBg_Epoch  = UIColor(hexstring_Epoch: "#F93AA7")
        let selBg_Epoch    = UIColor.white
        let unselText_Epoch = UIColor.white
        let selText_Epoch   = UIColor(hexstring_Epoch: "#111111")

        /// 组件1
        let isComp1_Epoch = selectedId == topGift_Epoch?.goodsId_Epoch
        UIView.animate(withDuration: 0.18) {
            self.comp1Card_Epoch?.backgroundColor  = isComp1_Epoch ? selBg_Epoch : unselBg_Epoch
            self.comp1InfoLabel_Epoch?.textColor   = isComp1_Epoch ? selText_Epoch : unselText_Epoch
        }

        /// 组件2
        comp2Items_Epoch.forEach { item_Epoch in
            let isSel_Epoch = item_Epoch.gift_Epoch?.goodsId_Epoch == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Epoch.updateSelection_Epoch(isSelected: isSel_Epoch)
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2网格，白色圆角背景，选中时变为浅紫色
/// 关键属性：gift_Epoch（绑定数据，供外部判断选中态）
class GiftItemView_Epoch: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Epoch: StoreModel_Epoch?

    // MARK: - UI 组件

    private let iconIV_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，初始白色（未选中）
    private let nameLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，初始白色（未选中）
    private let priceLabel_Epoch: UILabel = {
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
        iconIV_Epoch.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Epoch()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Epoch() {
        /// 初始为未选中粉色背景
        backgroundColor = UIColor(hexstring_Epoch: "#F93AA7")
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Epoch = UIStackView(arrangedSubviews: [iconIV_Epoch, nameLabel_Epoch, priceLabel_Epoch])
        vStack_Epoch.axis         = .vertical
        vStack_Epoch.spacing      = 5
        vStack_Epoch.alignment    = .center
        vStack_Epoch.distribution = .fill

        addSubview(vStack_Epoch)
        vStack_Epoch.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Epoch.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Epoch 礼物模型
    func configure_Epoch(gift: StoreModel_Epoch) {
        self.gift_Epoch       = gift
        nameLabel_Epoch.text  = gift.goodsName_Epoch  ?? ""
        priceLabel_Epoch.text = gift.goodsPrice_Epoch ?? ""
    }

    // MARK: - 选中态更新

    /// 更新选中态：选中白色背景+黑色字，未选中粉色背景+白色字
    /// - Parameter isSelected: 是否为当前选中项
    func updateSelection_Epoch(isSelected: Bool) {
        backgroundColor          = isSelected ? .white : UIColor(hexstring_Epoch: "#F93AA7")
        let textColor_epoch: UIColor = isSelected ? UIColor(hexstring_Epoch: "#111111") : .white
        nameLabel_Epoch.textColor  = textColor_epoch
        priceLabel_Epoch.textColor = textColor_epoch
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Epoch: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Epoch: StoreModel_Epoch?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Epoch, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Epoch = gift
    }
}
