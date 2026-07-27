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
///   - selectedGift_Bague：当前选中的礼物
///   - refreshSelectionUI_Bague：刷新选中态背景色
class GiftPage_Bague: UIViewController {

    // MARK: - 布局常量

    private var screenW_Bague: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Bague: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 宽 = 屏幕宽 - 32
    private var bgCardW_Bague: CGFloat { screenW_Bague - 32 }
    /// bgCard 高 = 屏幕高 × 0.70（调高以容纳组件3新增高度）
    private var bgCardH_Bague: CGFloat { screenH_Bague * 0.70 }
    /// 组件2/3 宽 = 屏幕宽 - 68，在 bgCard 内两侧对称内缩
    private var contentW_Bague: CGFloat { screenW_Bague - 68 }
    private var contentInset_Bague: CGFloat { (bgCardW_Bague - contentW_Bague) / 2 }

    // MARK: - 数据

    /// 顶级礼物（goodIsTop = true，一次性购买，过滤已购商品），最多取 3 个
    private var topGifts_Bague: [StoreModel_Bague] = []
    /// 普通礼物（非顶级，非VIP），最多取 8 个
    private var normalGifts_Bague: [StoreModel_Bague] = []
    /// 当前选中的礼物
    private var selectedGift_Bague: StoreModel_Bague?

    // MARK: - UI 组件

    /// 半透明遮罩（点击关闭）
    private let dimView_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 背景卡片容器（gift_bg 图片作背景）
    private let bgCard_Bague = UIView()

    /// gift_bg 背景图片
    private let bgImageView_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件2：普通礼物网格
    private let comp2View_Bague = UIView()
    /// 组件2所有 GiftItemView（存储引用以更新选中态）
    private var comp2Items_Bague: [GiftItemView_Bague] = []

    /// 组件3：横向3格一次性顶级礼物区（gift_two 图，高109，间距12）
    private let comp3View_Bague = UIView()
    /// 组件3所有 GiftItemView（存储引用以更新选中态）
    private var comp3Items_Bague: [GiftItemView_Bague] = []

    /// 购买按钮（gift_buy 图片）
    private let buyBtn_Bague: UIButton = {
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
        loadGiftData_Bague()
        buildDimAndCard_Bague()
        buildComp2_Bague()
        buildComp3_Bague()
        buildBuyBtn_Bague()
        setupConstraints_Bague()
    }

    // MARK: - 数据加载

    /// 加载礼物数据：顶级礼物可重复购买，普通礼物最多取 8 个
    private func loadGiftData_Bague() {
        let all_Bague = Store_Bague.shared_Bague.goodsList_Bague
            .filter { !($0.goodIsVIP_Bague ?? false) }
        /// 顶级礼物：goodIsTop=true，不限制购买次数，始终全量展示，最多取 3 个
        topGifts_Bague = Array(
            all_Bague.filter { $0.goodIsTop_Bague ?? false }.prefix(3)
        )
        normalGifts_Bague = Array(
            all_Bague.filter { !($0.goodIsTop_Bague ?? false) }.prefix(8)
        )
    }

    // MARK: - UI 搭建

    /// 搭建遮罩与背景卡片
    private func buildDimAndCard_Bague() {
        view.addSubview(dimView_Bague)
        /// 点击遮罩区域（bgCard 之外）关闭界面
        let dimTap_Bague = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Bague))
        dimView_Bague.addGestureRecognizer(dimTap_Bague)

        view.addSubview(bgCard_Bague)
        bgCard_Bague.clipsToBounds = true
        bgCard_Bague.addSubview(bgImageView_Bague)
        /// bgCard 内容视图阻止触摸穿透到遮罩
        bgCard_Bague.addSubview(comp2View_Bague)
        bgCard_Bague.addSubview(comp3View_Bague)
    }

    // MARK: - 组件2：普通礼物网格

    /// 构建组件2（2行×4列网格，行1用 gift_two，行2用 gift_three）
    private func buildComp2_Bague() {
        comp2View_Bague.backgroundColor = .clear
        comp2Items_Bague.removeAll()

        let row1_Bague = Array(normalGifts_Bague.prefix(4))
        let row2_Bague: [StoreModel_Bague] = normalGifts_Bague.count > 4
            ? Array(normalGifts_Bague[4...].prefix(4)) : []

        let rowStack1_Bague = buildGridRow_Bague(gifts: row1_Bague, iconName: "gift_one")
        let rowStack2_Bague = buildGridRow_Bague(gifts: row2_Bague, iconName: "gift_two")

        let outerStack_Bague = UIStackView(arrangedSubviews: [rowStack1_Bague, rowStack2_Bague])
        outerStack_Bague.axis         = .vertical
        outerStack_Bague.spacing      = 12
        outerStack_Bague.distribution = .fillEqually

        comp2View_Bague.addSubview(outerStack_Bague)
        outerStack_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4 个 GiftItemView，等宽均分，间距 5）
    /// - Parameters:
    ///   - gifts: 该行礼物数据（不足4个时用透明占位）
    ///   - iconName: 该行礼物图标名称
    /// - Returns: 横向 UIStackView
    private func buildGridRow_Bague(gifts: [StoreModel_Bague], iconName: String) -> UIStackView {
        var items_Bague: [UIView] = []
        for i in 0..<4 {
            let gift_Bague = i < gifts.count ? gifts[i] : nil
            let itemView_Bague = GiftItemView_Bague(iconName: iconName)
            if let gift_Bague = gift_Bague {
                itemView_Bague.configure_Bague(gift: gift_Bague)
                comp2Items_Bague.append(itemView_Bague)
                let tap_Bague = GiftItemTap_Bague(
                    gift: gift_Bague,
                    target: self,
                    action: #selector(gridItemTapped_Bague(_:))
                )
                itemView_Bague.isUserInteractionEnabled = true
                itemView_Bague.addGestureRecognizer(tap_Bague)
            } else {
                /// 空位透明占位
                itemView_Bague.alpha = 0
                itemView_Bague.isUserInteractionEnabled = false
            }
            items_Bague.append(itemView_Bague)
        }
        let stack_Bague = UIStackView(arrangedSubviews: items_Bague)
        stack_Bague.axis         = .horizontal
        stack_Bague.spacing      = 5
        stack_Bague.distribution = .fillEqually
        return stack_Bague
    }

    // MARK: - 组件3：一次性顶级礼物横向3格

    /// 构建组件3（横向3格，goodIsTop=true 的礼物，gift_two 图，高109，间距12）
    /// 可重复购买，商品始终展示在列表中
    private func buildComp3_Bague() {
        comp3View_Bague.backgroundColor = .clear
        comp3Items_Bague.removeAll()

        var itemViews_Bague: [UIView] = []
        for i_Bague in 0..<3 {
            if i_Bague < topGifts_Bague.count {
                let gift_Bague = topGifts_Bague[i_Bague]
                let itemView_Bague = GiftItemView_Bague(iconName: "gift_three")
                itemView_Bague.configure_Bague(gift: gift_Bague)
                comp3Items_Bague.append(itemView_Bague)
                let tap_Bague = GiftItemTap_Bague(
                    gift: gift_Bague,
                    target: self,
                    action: #selector(gridItemTapped_Bague(_:))
                )
                itemView_Bague.isUserInteractionEnabled = true
                itemView_Bague.addGestureRecognizer(tap_Bague)
                itemViews_Bague.append(itemView_Bague)
            } else {
                /// 已全部购买时用透明占位保持布局稳定
                let placeholder_Bague = UIView()
                placeholder_Bague.alpha = 0
                placeholder_Bague.isUserInteractionEnabled = false
                itemViews_Bague.append(placeholder_Bague)
            }
        }

        let stack_Bague = UIStackView(arrangedSubviews: itemViews_Bague)
        stack_Bague.axis         = .horizontal
        stack_Bague.spacing      = 12
        stack_Bague.distribution = .fillEqually

        comp3View_Bague.addSubview(stack_Bague)
        stack_Bague.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮（gift_buy 图片全宽）
    private func buildBuyBtn_Bague() {
        bgCard_Bague.addSubview(buyBtn_Bague)
        buyBtn_Bague.addTarget(self, action: #selector(buyTapped_Bague), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束
    /// 垂直顺序（从下至上）：buyBtn → 间距10 → comp3 → 间距10 → comp2
    private func setupConstraints_Bague() {
        let inset_Bague = contentInset_Bague
        /// 组件2高度 = 2行×109 + 行间距12
        let comp2H_Bague: CGFloat = 109 * 2 + 12
        /// 组件3高度 = 109
        let comp3H_Bague: CGFloat = 109

        /// 全屏遮罩
        dimView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard 居中
        bgCard_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(bgCardW_Bague)
            make.height.equalTo(bgCardH_Bague)
        }

        /// 背景图铺满 bgCard
        bgImageView_Bague.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 50
        buyBtn_Bague.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-50)
        }

        /// 组件3：宽 = contentW，高 = 109，位于购买按钮上方 10
        comp3View_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Bague)
            make.trailing.equalToSuperview().offset(-inset_Bague)
            make.height.equalTo(comp3H_Bague)
            make.bottom.equalTo(buyBtn_Bague.snp.top).offset(-10)
        }

        /// 组件2：宽 = contentW，高 = comp2H，位于组件3上方 10
        comp2View_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(inset_Bague)
            make.trailing.equalToSuperview().offset(-inset_Bague)
            make.height.equalTo(comp2H_Bague)
            make.bottom.equalTo(comp3View_Bague.snp.top).offset(-10)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Bague() {
        dismiss(animated: true)
    }

    /// 点击组件2/组件3网格某个礼物
    /// - Parameter tap: 携带礼物数据的自定义手势
    @objc private func gridItemTapped_Bague(_ tap: GiftItemTap_Bague) {
        guard let gift_Bague = tap.gift_Bague else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Bague = gift_Bague
        refreshSelectionUI_Bague(selectedId: gift_Bague.goodsId_Bague)
    }

    /// 点击购买按钮发起内购
    @objc private func buyTapped_Bague() {
        guard let gift_Bague = selectedGift_Bague,
              let gid_Bague  = gift_Bague.goodsId_Bague else {
            Utils_Bague.showWarning_Bague(message_Bague: "Please select a gift first")
            return
        }
        Store_Bague.shared_Bague.PurchaseStoreGift_Bague(gid_Bague: gid_Bague) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色（组件2 + 组件3）
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Bague(selectedId: String?) {
        /// 未选中：白色背景 + 橘色文字；选中：橘色背景 + 白色文字
        let normalBgColor_Bague    = UIColor.white
        let selectedBgColor_Bague  = UIColor(hexstring_Bague: "#FF7A00")
        let normalTextColor_Bague  = UIColor(hexstring_Bague: "#FF7A00")
        let selectedTextColor_Bague = UIColor.white

        /// 组件2
        comp2Items_Bague.forEach { item_Bague in
            let isSel_Bague = item_Bague.gift_Bague?.goodsId_Bague == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Bague.applySelectionState_Bague(
                    isSelected_Bague: isSel_Bague,
                    normalBgColor_Bague: normalBgColor_Bague,
                    selectedBgColor_Bague: selectedBgColor_Bague,
                    normalTextColor_Bague: normalTextColor_Bague,
                    selectedTextColor_Bague: selectedTextColor_Bague
                )
            }
        }

        /// 组件3（一次性顶级礼物，选中态逻辑与组件2一致）
        comp3Items_Bague.forEach { item_Bague in
            let isSel_Bague = item_Bague.gift_Bague?.goodsId_Bague == selectedId
            UIView.animate(withDuration: 0.18) {
                item_Bague.applySelectionState_Bague(
                    isSelected_Bague: isSel_Bague,
                    normalBgColor_Bague: normalBgColor_Bague,
                    selectedBgColor_Bague: selectedBgColor_Bague,
                    normalTextColor_Bague: normalTextColor_Bague,
                    selectedTextColor_Bague: selectedTextColor_Bague
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（VStack：图标60×60 → 名称10pt → 价格14pt）
/// 功能：用于组件2/组件3网格，支持根据选中状态切换背景与文字颜色
/// 关键属性：gift_Bague（绑定数据，供外部判断选中态）
class GiftItemView_Bague: UIView {

    // MARK: - 属性

    /// 绑定的礼物数据（通过 configure 注入）
    private(set) var gift_Bague: StoreModel_Bague?

    // MARK: - UI 组件

    private let iconIV_Bague: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 礼物名称：不加粗，10pt，未选中为橘色
    private let nameLabel_Bague: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = UIColor(hexstring_Bague: "#FF7A00")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：14pt，未选中为橘色
    private let priceLabel_Bague: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .regular)
        l.textColor = UIColor(hexstring_Bague: "#FF7A00")
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    /// - Parameter iconName: 礼物图标 Assets 名称（gift_two / gift_three）
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Bague.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Bague()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Bague() {
        /// 未选中默认背景为白色
        backgroundColor = .white
        layer.cornerRadius = 15
        layer.masksToBounds = true

        /// VStack：图标 → 名称（间距5）→ 价格
        let vStack_Bague = UIStackView(arrangedSubviews: [iconIV_Bague, nameLabel_Bague, priceLabel_Bague])
        vStack_Bague.axis         = .vertical
        vStack_Bague.spacing      = 5
        vStack_Bague.alignment    = .center
        vStack_Bague.distribution = .fill

        addSubview(vStack_Bague)
        vStack_Bague.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Bague.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: StoreModel_Bague 礼物模型
    func configure_Bague(gift: StoreModel_Bague) {
        self.gift_Bague     = gift
        nameLabel_Bague.text  = gift.goodsName_Bague  ?? ""
        priceLabel_Bague.text = gift.goodsPrice_Bague ?? ""
    }

    /// 应用礼物项选中态样式
    /// 参数：
    /// - isSelected_Bague: 当前是否选中
    /// - normalBgColor_Bague: 未选中背景色
    /// - selectedBgColor_Bague: 选中背景色
    /// - normalTextColor_Bague: 未选中文字色
    /// - selectedTextColor_Bague: 选中文字色
    /// 返回值：无
    func applySelectionState_Bague(isSelected_Bague: Bool,
                                  normalBgColor_Bague: UIColor,
                                  selectedBgColor_Bague: UIColor,
                                  normalTextColor_Bague: UIColor,
                                  selectedTextColor_Bague: UIColor) {
        backgroundColor = isSelected_Bague ? selectedBgColor_Bague : normalBgColor_Bague
        nameLabel_Bague.textColor  = isSelected_Bague ? selectedTextColor_Bague : normalTextColor_Bague
        priceLabel_Bague.textColor = isSelected_Bague ? selectedTextColor_Bague : normalTextColor_Bague
    }
}

// MARK: - 携带礼物数据的点击手势

/// 携带礼物模型数据的自定义点击手势，用于网格 Item 回调
private class GiftItemTap_Bague: UITapGestureRecognizer {

    /// 关联的礼物数据
    var gift_Bague: StoreModel_Bague?

    /// - Parameters:
    ///   - gift: 对应的礼物模型
    ///   - target: 响应者
    ///   - action: 响应方法
    convenience init(gift: StoreModel_Bague, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Bague = gift
    }
}
