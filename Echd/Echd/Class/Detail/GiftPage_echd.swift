import Foundation
import UIKit
import SnapKit

// MARK: - 送礼界面

/// 送礼模态弹起界面
/// 核心作用：展示礼物商品列表，用户选择后发起内购
/// 设计思路：
///   半透明遮罩 + gift_bg 背景卡片居中；
///   组件2：普通礼物2行×4列网格；
///   组件3：横向3格顶级礼物（goodIsTop=true，gift_two图），可重复购买，始终展示；
///   底部购买按钮（gift_buy 图片）；
///   点击遮罩区域关闭，bgCard 外部区域可关闭。
/// 关键属性/方法：
///   - selectedGift_Echd：当前选中的礼物
///   - refreshSelectionUI_Echd：刷新选中态背景色
class GiftPage_Echd: UIViewController {

    // MARK: - 布局常量

    private var screenW_Echd: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Echd: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Echd: CGFloat { screenW_Echd - 32 }
    /// bgCard 高 = 屏幕高 × 0.70（调高以容纳组件3新增高度）
    private var bgCardH_Echd: CGFloat { screenH_Echd * 0.70 }
    /// 组件2/3 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Echd: CGFloat { screenW_Echd - 68 }
    private var contentInset_Echd: CGFloat { (bgCardW_Echd - contentW_Echd) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买，过滤已购商品），最多取 3 个
    private var topGifts_Echd: [StoreModel_Echd] = []
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Echd: [StoreModel_Echd] = []
    /// 当前选中的礼物
    private var selectedGift_Echd: StoreModel_Echd?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Echd: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Echd = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Echd: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件2：普通礼物网格
    private let comp2View_Echd = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Echd: [GiftItemView_Echd] = []

    /// 组件3：横向3格一次性顶级礼物区（gift_two 图，高109，间距12）
    private let comp3View_Echd = UIView()
    /// 组件3所有 GiftItemView（存储引用以更新选中态）
    private var comp3Items_Echd: [GiftItemView_Echd] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Echd: UIButton = {
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
        loadGiftData_Echd()
        buildDimAndCard_Echd()
        buildComp2_Echd()
        buildComp3_Echd()
        buildBuyBtn_Echd()
        setupConstraints_Echd()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：顶级礼物可重复购买，普通礼物最多取 8 个
    private func loadGiftData_Echd() {
        let all_Echd = Store_Echd.shared_Echd.goodsList_Echd
            .filter { !($0.goodIsVIP_Echd ?? false) }
        /// 顶级礼物：goodIsTop=true，不限制购买次数，始终全量展示，最多取 3 个
        topGifts_Echd = Array(
            all_Echd.filter { $0.goodIsTop_Echd ?? false }.prefix(3)
        )
        normalGifts_Echd = Array(
            all_Echd.filter { !($0.goodIsTop_Echd ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Echd() {
        view.addSubview(dimView_Echd)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap_Echd = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Echd))
        dimView_Echd.addGestureRecognizer(dimTap_Echd)

        view.addSubview(bgCard_Echd)
        bgCard_Echd.clipsToBounds = true
        bgCard_Echd.addSubview(bgImageView_Echd)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Echd.addSubview(comp2View_Echd)
        bgCard_Echd.addSubview(comp3View_Echd)
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Echd() {
        comp2View_Echd.backgroundColor = .clear
        comp2Items_Echd.removeAll()

        let row1_Echd = Array(normalGifts_Echd.prefix(4))
        let row2_Echd: [StoreModel_Echd] = normalGifts_Echd.count > 4
            ? Array(normalGifts_Echd[4...].prefix(4)) : []

        let rowStack1_Echd = buildGridRow_Echd(gifts: row1_Echd, iconName: "gift_one")
        let rowStack2_Echd = buildGridRow_Echd(gifts: row2_Echd, iconName: "gift_two")

        let outerStack_Echd = UIStackView(arrangedSubviews: [rowStack1_Echd, rowStack2_Echd])
        outerStack_Echd.axis         = .vertical
        outerStack_Echd.spacing      = 12
        outerStack_Echd.distribution = .fillEqually

        comp2View_Echd.addSubview(outerStack_Echd)
        outerStack_Echd.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，等宽均分，间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Echd(gifts: [StoreModel_Echd], iconName: String) -> UIStackView {
        var items_Echd: [UIView] = []
        for i in 0..<4 {
            let gift_Echd = i < gifts.count ? gifts[i] : nil
            let itemView_Echd = GiftItemView_Echd(iconName: iconName)
            if let gift_Echd = gift_Echd {
                itemView_Echd.configure_Echd(gift: gift_Echd)
                comp2Items_Echd.append(itemView_Echd)
                let tap_Echd = GiftItemTap_Echd(
                    gift: gift_Echd,
                    target: self,
                    action: #selector(gridItemTapped_Echd(_:))
                )
                itemView_Echd.isUserInteractionEnabled = true
                itemView_Echd.addGestureRecognizer(tap_Echd)
            } else {
                /// 空位透明占位
                itemView_Echd.alpha = 0
                itemView_Echd.isUserInteractionEnabled = false
            }
            items_Echd.append(itemView_Echd)
        }
        let stack_Echd = UIStackView(arrangedSubviews: items_Echd)
        stack_Echd.axis         = .horizontal
        stack_Echd.spacing      = 5
        stack_Echd.distribution = .fillEqually
        return stack_Echd
    }

    // MARK: - 组件3：一次性顶级礼物横向3格

    /// 构建组件3（横向3格，goodIsTop=true 的礼物，gift_two 图，高109，间距12）
    /// 可重复购买，商品始终展示在列表中
    private func buildComp3_Echd() {
        comp3View_Echd.backgroundColor = .clear
        comp3Items_Echd.removeAll()

        var itemViews_Echd: [UIView] = []
        for i_Echd in 0..<3 {
            if i_Echd < topGifts_Echd.count {
                let gift_Echd = topGifts_Echd[i_Echd]
                let itemView_Echd = GiftItemView_Echd(iconName: "gift_three")
                itemView_Echd.configure_Echd(gift: gift_Echd)
                comp3Items_Echd.append(itemView_Echd)
                let tap_Echd = GiftItemTap_Echd(
                    gift: gift_Echd,
                    target: self,
                    action: #selector(gridItemTapped_Echd(_:))
                )
                itemView_Echd.isUserInteractionEnabled = true
                itemView_Echd.addGestureRecognizer(tap_Echd)
                itemViews_Echd.append(itemView_Echd)
            } else {
                /// 已全部购买时用透明占位保持布局稳定
                let placeholder_Echd = UIView()
                placeholder_Echd.alpha = 0
                placeholder_Echd.isUserInteractionEnabled = false
                itemViews_Echd.append(placeholder_Echd)
            }
        }

        let stack_Echd = UIStackView(arrangedSubviews: itemViews_Echd)
        stack_Echd.axis         = .horizontal
        stack_Echd.spacing      = 12
        stack_Echd.distribution = .fillEqually

        comp3View_Echd.addSubview(stack_Echd)
        stack_Echd.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Echd() {
        bgCard_Echd.addSubview(buyBtn_Echd)
        buyBtn_Echd.addTarget(self, action: #selector(buyTapped_Echd), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    /// 垂直顺序（从下至上）：buyBtn → 间距10 → comp3 → 间距10 → comp2
    private func setupConstraints_Echd() {
        let inset_Echd = contentInset_Echd
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Echd: CGFloat = 109 * 2 + 12
        /// 组件3高度 = 109
        let comp3H_Echd: CGFloat = 109

        /// 全屏遮罩
        dimView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Echd)
            make.height.equalTo(bgCardH_Echd)
        }

        /// 背景图铺满 bgCard
        bgImageView_Echd.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Echd.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-50)
        }

        /// 组件3：宽 = contentW，高 = 109，位于购买按钮上方 10
        comp3View_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Echd)
            make.trailing.equalToSuperview().offset(-inset_Echd)
            make.height.equalTo(comp3H_Echd)
            make.bottom.equalTo(buyBtn_Echd.snp.top).offset(-10)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于组件3上方 10
        comp2View_Echd.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Echd)
            make.trailing.equalToSuperview().offset(-inset_Echd)
            make.height.equalTo(comp2H_Echd)
            make.bottom.equalTo(comp3View_Echd.snp.top).offset(-10)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Echd() {
        dismiss(animated: true)
    }

    /// 点击组件2/组件3网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Echd(_ tap: GiftItemTap_Echd) {
        guard let gift_Echd = tap.gift_Echd else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Echd = gift_Echd
        refreshSelectionUI_Echd(selectedId: gift_Echd.goodsId_Echd)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Echd() {
        guard let gift_Echd = selectedGift_Echd,
              let gid_Echd  = gift_Echd.goodsId_Echd else {
            Utils_Echd.showWarning_Echd(message_Echd: "Please select a gift first")
            return
        }
        Store_Echd.shared_Echd.PurchaseStoreGift_Echd(gid_Echd: gid_Echd) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色（组件2 + 组件3）
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Echd(selectedId: String?) {
        /// 未选中：白色背景 + 橘色文字；选中：橘色背景 + 白色文字
        let normalBgColor_Echd    = UIColor.white
        let selectedBgColor_Echd  = UIColor(hexstring_Echd: "#FF7A00")
        let normalTextColor_Echd  = UIColor(hexstring_Echd: "#FF7A00")
        let selectedTextColor_Echd = UIColor.white

        /// 组件2
        comp2Items_Echd.forEach { item_Echd in
            let isSel_Echd = item_Echd.gift_Echd?.goodsId_Echd == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Echd.applySelectionState_Echd(
                    isSelected_Echd: isSel_Echd,
                    normalBgColor_Echd: normalBgColor_Echd,
                    selectedBgColor_Echd: selectedBgColor_Echd,
                    normalTextColor_Echd: normalTextColor_Echd,
                    selectedTextColor_Echd: selectedTextColor_Echd
                )
            }
        }

        /// 组件3（一次性顶级礼物，选中态逻辑与组件2一致）
        comp3Items_Echd.forEach { item_Echd in
            let isSel_Echd = item_Echd.gift_Echd?.goodsId_Echd == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Echd.applySelectionState_Echd(
                    isSelected_Echd: isSel_Echd,
                    normalBgColor_Echd: normalBgColor_Echd,
                    selectedBgColor_Echd: selectedBgColor_Echd,
                    normalTextColor_Echd: normalTextColor_Echd,
                    selectedTextColor_Echd: selectedTextColor_Echd
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2/组件3网格，支持根据选中状态切换背景与文字颜色
/// 关键属性：gift_Echd（绑定数据，供外部判断选中态）
class GiftItemView_Echd: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Echd: StoreModel_Echd?

    // MARK: - UI 组件

    private let iconIV_Echd: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，未选中为橘色
    private let nameLabel_Echd: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = UIColor(hexstring_Echd: "#FF7A00")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，未选中为橘色
    private let priceLabel_Echd: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Echd: "#FF7A00")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    /// - Parameter iconName: 礼物图标 Assets 名称（gift_two / gift_three）
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Echd.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Echd()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Echd() {
        /// 未选中默认背景为白色
        backgroundColor = .white
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Echd = UIStackView(arrangedSubviews: [iconIV_Echd, nameLabel_Echd, priceLabel_Echd])
        vStack_Echd.axis         = .vertical
        vStack_Echd.spacing      = 5
        vStack_Echd.alignment    = .center
        vStack_Echd.distribution = .fill

        addSubview(vStack_Echd)
        vStack_Echd.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Echd.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Echd 礼物模型
    func configure_Echd(gift: StoreModel_Echd) {
        self.gift_Echd     = gift
        nameLabel_Echd.text  = gift.goodsName_Echd  ?? ""
        priceLabel_Echd.text = gift.goodsPrice_Echd ?? ""
    }

    /// 应用礼物项选中态样式
    /// 参数：
    /// - isSelected_Echd: 当前是否选中
    /// - normalBgColor_Echd: 未选中背景色
    /// - selectedBgColor_Echd: 选中背景色
    /// - normalTextColor_Echd: 未选中文字色
    /// - selectedTextColor_Echd: 选中文字色
    /// 返回值：无
    func applySelectionState_Echd(isSelected_Echd: Bool,
                                  normalBgColor_Echd: UIColor,
                                  selectedBgColor_Echd: UIColor,
                                  normalTextColor_Echd: UIColor,
                                  selectedTextColor_Echd: UIColor) {
        backgroundColor = isSelected_Echd ? selectedBgColor_Echd : normalBgColor_Echd
        nameLabel_Echd.textColor  = isSelected_Echd ? selectedTextColor_Echd : normalTextColor_Echd
        priceLabel_Echd.textColor = isSelected_Echd ? selectedTextColor_Echd : normalTextColor_Echd
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Echd: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Echd: StoreModel_Echd?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Echd, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Echd = gift
    }
}
