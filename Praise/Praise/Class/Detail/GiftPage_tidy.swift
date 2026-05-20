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
///   - selectedGift_Tidy：当前选中的礼物
///   - refreshSelectionUI_Tidy：刷新选中态背景色
class GiftPage_Tidy: UIViewController {

    // MARK: - 布局常量

    private var screenW_Tidy: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Tidy: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Tidy: CGFloat { screenW_Tidy - 32 }
    /// bgCard 高 = 屏幕高 × 0.70（调高以容纳组件3新增高度）
    private var bgCardH_Tidy: CGFloat { screenH_Tidy * 0.70 }
    /// 组件2/3 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Tidy: CGFloat { screenW_Tidy - 68 }
    private var contentInset_Tidy: CGFloat { (bgCardW_Tidy - contentW_Tidy) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买，过滤已购商品），最多取 3 个
    private var topGifts_Tidy: [StoreModel_Tidy] = []
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

    /// 组件2：普通礼物网格
    private let comp2View_Tidy = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Tidy: [GiftItemView_Tidy] = []

    /// 组件3：横向3格一次性顶级礼物区（gift_two 图，高109，间距12）
    private let comp3View_Tidy = UIView()
    /// 组件3所有 GiftItemView（存储引用以更新选中态）
    private var comp3Items_Tidy: [GiftItemView_Tidy] = []

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
        buildComp2_Tidy()
        buildComp3_Tidy()
        buildBuyBtn_Tidy()
        setupConstraints_Tidy()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：顶级礼物可重复购买，普通礼物最多取 8 个
    private func loadGiftData_Tidy() {
        let all_Tidy = Store_Tidy.shared_Tidy.goodsList_Tidy
            .filter { !($0.goodIsVIP_Tidy ?? false) }
        /// 顶级礼物：goodIsTop=true，不限制购买次数，始终全量展示，最多取 3 个
        topGifts_Tidy = Array(
            all_Tidy.filter { $0.goodIsTop_Tidy ?? false }.prefix(3)
        )
        normalGifts_Tidy = Array(
            all_Tidy.filter { !($0.goodIsTop_Tidy ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Tidy() {
        view.addSubview(dimView_Tidy)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap_Tidy = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Tidy))
        dimView_Tidy.addGestureRecognizer(dimTap_Tidy)

        view.addSubview(bgCard_Tidy)
        bgCard_Tidy.clipsToBounds = true
        bgCard_Tidy.addSubview(bgImageView_Tidy)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Tidy.addSubview(comp2View_Tidy)
        bgCard_Tidy.addSubview(comp3View_Tidy)
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

    /// 构建网格一行（4 个 GiftItemView，等宽均分，间距 5）
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

    // MARK: - 组件3：一次性顶级礼物横向3格

    /// 构建组件3（横向3格，goodIsTop=true 的礼物，gift_two 图，高109，间距12）
    /// 可重复购买，商品始终展示在列表中
    private func buildComp3_Tidy() {
        comp3View_Tidy.backgroundColor = .clear
        comp3Items_Tidy.removeAll()

        var itemViews_Tidy: [UIView] = []
        for i_Tidy in 0..<3 {
            if i_Tidy < topGifts_Tidy.count {
                let gift_Tidy = topGifts_Tidy[i_Tidy]
                let itemView_Tidy = GiftItemView_Tidy(iconName: "gift_two")
                itemView_Tidy.configure_Tidy(gift: gift_Tidy)
                comp3Items_Tidy.append(itemView_Tidy)
                let tap_Tidy = GiftItemTap_Tidy(
                    gift: gift_Tidy,
                    target: self,
                    action: #selector(gridItemTapped_Tidy(_:))
                )
                itemView_Tidy.isUserInteractionEnabled = true
                itemView_Tidy.addGestureRecognizer(tap_Tidy)
                itemViews_Tidy.append(itemView_Tidy)
            } else {
                /// 已全部购买时用透明占位保持布局稳定
                let placeholder_Tidy = UIView()
                placeholder_Tidy.alpha = 0
                placeholder_Tidy.isUserInteractionEnabled = false
                itemViews_Tidy.append(placeholder_Tidy)
            }
        }

        let stack_Tidy = UIStackView(arrangedSubviews: itemViews_Tidy)
        stack_Tidy.axis         = .horizontal
        stack_Tidy.spacing      = 12
        stack_Tidy.distribution = .fillEqually

        comp3View_Tidy.addSubview(stack_Tidy)
        stack_Tidy.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Tidy() {
        bgCard_Tidy.addSubview(buyBtn_Tidy)
        buyBtn_Tidy.addTarget(self, action: #selector(buyTapped_Tidy), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    /// 垂直顺序（从下至上）：buyBtn → 间距10 → comp3 → 间距10 → comp2
    private func setupConstraints_Tidy() {
        let inset_Tidy = contentInset_Tidy
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Tidy: CGFloat = 109 * 2 + 12
        /// 组件3高度 = 109
        let comp3H_Tidy: CGFloat = 109

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

        /// 组件3：宽 = contentW，高 = 109，位于购买按钮上方 10
        comp3View_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Tidy)
            make.trailing.equalToSuperview().offset(-inset_Tidy)
            make.height.equalTo(comp3H_Tidy)
            make.bottom.equalTo(buyBtn_Tidy.snp.top).offset(-10)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于组件3上方 10
        comp2View_Tidy.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Tidy)
            make.trailing.equalToSuperview().offset(-inset_Tidy)
            make.height.equalTo(comp2H_Tidy)
            make.bottom.equalTo(comp3View_Tidy.snp.top).offset(-10)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Tidy() {
        dismiss(animated: true)
    }

    /// 点击组件2/组件3网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Tidy(_ tap: GiftItemTap_Tidy) {
        guard let gift_Tidy = tap.gift_Tidy else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Tidy = gift_Tidy
        refreshSelectionUI_Tidy(selectedId: gift_Tidy.goodsId_Tidy)
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

    /// 刷新所有礼物条目的选中背景色（组件2 + 组件3）
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Tidy(selectedId: String?) {
        let normalBgColor_Tidy    = UIColor(hexstring_Tidy: "#2353E4")
        let selectedBgColor_Tidy  = UIColor.white
        let normalTextColor_Tidy  = UIColor.white
        let selectedTextColor_Tidy = UIColor.black

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

        /// 组件3（一次性顶级礼物，选中态逻辑与组件2一致）
        comp3Items_Tidy.forEach { item_Tidy in
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
/// 功能：用于组件2/组件3网格，支持根据选中状态切换背景与文字颜色
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

    /// 礼物名称：不加粗，10pt，白色
    private let nameLabel_Tidy: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，白色
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
        nameLabel_Tidy.textColor  = isSelected_Tidy ? selectedTextColor_Tidy : normalTextColor_Tidy
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
