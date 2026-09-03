import Foundation
import UIKit
import SnapKit

// MARK: - 送礼界面

/// 送礼模态弹起界面
/// 核心作用：展示礼物商品列表，用户选择后发起内购
/// 设计思路：
///   半透明遮罩 + gift_bg 背景卡片底部展示；
///   组件1：顶级一次性礼物横向卡片（HStack）；
///   组件2：普通礼物单行横向滚动列表；
///   底部 Give Away 购买按钮；
///   点击遮罩区域关闭，bgCard 外部区域可关闭。
/// 关键属性/方法：
///   - selectedGift_Maki：当前选中的礼物
///   - refreshSelectionUI_Maki：刷新选中态背景色
class GiftPage_Maki: UIViewController {

    // MARK: - 布局常量

    /// 内容距送礼背景左右边缘的内间距。
    private let contentInset_maki: CGFloat = 18

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

    /// 购买按钮：资源缺失时使用文字按钮，保证送礼操作可用。
    private let buyBtn_Maki: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Give Away", for: .normal)
        btn.setTitleColor(UIColor(hexstring_Maki: "#5A320C"), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 14
        btn.layer.shadowColor = UIColor.black.withAlphaComponent(0.22).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowOpacity = 1
        btn.layer.shadowRadius = 3
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
        let all = Subscribe_Maki.shared_Maki.goodsList_Maki
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

    // MARK: - 组件2：普通礼物单行列表

    /// 构建组件2（单行横向滚动列表，所有礼物统一使用 gift_one 图标）。
    /// - 参数：无。
    /// - 返回值：无。
    /// - 异常场景：无。
    private func buildComp2_Maki() {
        comp2View_Maki.backgroundColor = .clear
        comp2Items_Maki.removeAll()

        let scrollView_maki = UIScrollView()
        scrollView_maki.showsHorizontalScrollIndicator = false
        scrollView_maki.alwaysBounceHorizontal = true
        scrollView_maki.decelerationRate = .fast

        let itemStack_maki = UIStackView()
        itemStack_maki.axis = .horizontal
        itemStack_maki.spacing = 8
        itemStack_maki.alignment = .fill
        itemStack_maki.distribution = .fill

        normalGifts_Maki.forEach { gift_maki in
            let itemView_maki = GiftItemView_Maki(iconName: "gift_one")
            itemView_maki.configure_Maki(gift: gift_maki)
            itemView_maki.isUserInteractionEnabled = true
            itemView_maki.snp.makeConstraints { make in
                make.width.equalTo(84)
            }
            let tap_maki = GiftItemTap_Maki(
                gift: gift_maki,
                target: self,
                action: #selector(gridItemTapped_Maki(_:))
            )
            itemView_maki.addGestureRecognizer(tap_maki)
            comp2Items_Maki.append(itemView_maki)
            itemStack_maki.addArrangedSubview(itemView_maki)
        }

        comp2View_Maki.addSubview(scrollView_maki)
        scrollView_maki.addSubview(itemStack_maki)
        scrollView_maki.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        itemStack_maki.snp.makeConstraints { make in
            make.edges.equalTo(scrollView_maki.contentLayoutGuide)
            make.height.equalTo(scrollView_maki.frameLayoutGuide)
        }
    }

    // MARK: - 购买按钮

    /// 搭建底部购买按钮。
    /// - 参数：无。
    /// - 返回值：无。
    /// - 异常场景：无。
    private func buildBuyBtn_Maki() {
        bgCard_Maki.addSubview(buyBtn_Maki)
        buyBtn_Maki.addTarget(self, action: #selector(buyTapped_Maki), for: .touchUpInside)
    }

    // MARK: - 约束布局

    /// 设置底部送礼面板的所有 SnapKit 约束。
    /// - 参数：无。
    /// - 返回值：无。
    /// - 异常场景：无。
    private func setupConstraints_Maki() {
        let comp2Height_maki: CGFloat = 112

        /// 全屏遮罩
        dimView_Maki.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 背景图贴合屏幕宽度并固定在底部，避免两侧出现缝隙。
        bgCard_Maki.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(bgCard_Maki.snp.width).multipliedBy(0.98)
        }

        /// 背景图铺满底部容器。
        bgImageView_Maki.contentMode = .scaleToFill
        bgImageView_Maki.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：宽102、高32，距送礼背景底部30pt。
        buyBtn_Maki.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(102)
            make.height.equalTo(32)
            make.bottom.equalToSuperview().offset(-30)
        }

        /// 组件2：单行横向滚动礼物卡片，完整保留每个礼物的信息层级。
        comp2View_Maki.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(contentInset_maki)
            make.height.equalTo(comp2Height_maki)
            make.bottom.equalTo(buyBtn_Maki.snp.top).offset(-6)
        }

        /// 组件1：有顶级礼物时显示在网格上方。
        comp1View_Maki.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(contentInset_maki)
            make.height.equalTo(72)
            make.bottom.equalTo(comp2View_Maki.snp.top).offset(-8)
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
        Subscribe_Maki.shared_Maki.PurchaseStoreGift_Maki(gid_Maki: gid_Maki) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    // MARK: - 选中态刷新

    /// 刷新所有礼物条目的选中背景色
    /// - Parameter selectedId: 当前选中商品的 goodsId
    private func refreshSelectionUI_Maki(selectedId: String?) {
        let normalBgColor_Maki = UIColor(hexstring_Maki: "#FFA11A")
        let selectedBgColor_Maki = UIColor(hexstring_Maki: "#F58200")
        let normalTextColor_Maki = UIColor.white
        let selectedTextColor_Maki = UIColor.white

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

/// 礼物商品单元视图（垂直排列：图标50×50、名称12pt、价格18pt）
/// 功能：用于组件2单行列表，支持根据选中状态切换背景与文字颜色
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

    /// 礼物名称：白色常规字重，12pt。
    private let nameLabel_Maki: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 礼物价格：白色加粗字重，18pt。
    private let priceLabel_Maki: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    /// - 参数：iconName：礼物图标资源名称，当前统一传入 gift_one。
    /// - 返回值：已配置图标的礼物单元视图。
    /// - 异常场景：资源缺失时仅不显示图标，单元其余内容仍可正常展示。
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Maki.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Maki()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func buildUI_Maki() {
        backgroundColor = UIColor(hexstring_Maki: "#FFA11A")
        layer.cornerRadius = 16
        layer.masksToBounds = true

        /// 垂直排列：图标、名称与价格，匹配紧凑礼物卡样式。
        let vStack_Maki = UIStackView(arrangedSubviews: [iconIV_Maki, nameLabel_Maki, priceLabel_Maki])
        vStack_Maki.axis         = .vertical
        vStack_Maki.spacing      = 2
        vStack_Maki.alignment    = .center
        vStack_Maki.distribution = .fill

        addSubview(vStack_Maki)
        vStack_Maki.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Maki.snp.makeConstraints { make in
            make.width.height.equalTo(50)
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
