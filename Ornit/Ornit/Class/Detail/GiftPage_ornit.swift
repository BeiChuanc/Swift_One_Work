import Foundation
import UIKit
import SnapKit

// MARK: - 送礼界面

/// 送礼模态弹起界面（从底部滑入，距离底部0间距）
/// 核心作用：展示礼物商品列表，用户选择后发起内购
/// 设计思路：
///   半透明遮罩 + gift_bg 背景卡片从底部弹起；
///   组件1：3个限定礼物横向等分卡片（goodIsSpecial = true），各110×114；
///   组件2：3行×4列网格，行1/2/3分别使用 gift_four/five/six；
///   底部购买按钮（gift_buy 图片）；
///   点击遮罩区域关闭，向下滑动可关闭。
class GiftPage_Ornit: UIViewController {

    // MARK: - 布局常量

    private var screenW_Ornit: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Ornit: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 高 = 屏幕高 × 0.72
    private var bgCardH_Ornit: CGFloat { screenH_Ornit * 0.85 }
    /// 组件内容左右各留 18
    private var contentInset_Ornit: CGFloat { 18 }

    // MARK: - 数据

    /// 限定礼物（goodIsSpecial = true），最多 3 个，对应组件1
    private var limitGifts_Ornit: [StoreModel_Ornit] = []
    /// 普通礼物（非限定/非顶级/非VIP），最多 12 个，对应组件2
    private var normalGifts_Ornit: [StoreModel_Ornit] = []
    /// 当前选中的礼物
    private var selectedGift_Ornit: StoreModel_Ornit?

    // MARK: - 选中态引用

    /// 组件1各卡片引用（card, priceLabel, subLabel, gift）
    private struct Comp1Ref_Ornit {
        weak var card: UIView?
        weak var priceLabel: UILabel?
        weak var subLabel: UILabel?
        weak var bannerView: UIView?  // 存 bannerView，选中/未选中时切换背景
        var gift: StoreModel_Ornit
    }
    private var comp1Refs_Ornit: [Comp1Ref_Ornit] = []

    /// 组件2所有 GiftItemView
    private var comp2Items_Ornit: [GiftItemView_Ornit] = []

    // MARK: - UI 组件

    private let dimView_Ornit: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        v.alpha = 0
        return v
    }()

    private let bgCard_Ornit = UIView()

    private let bgImageView_Ornit: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1：限定礼物横向容器
    private let comp1View_Ornit = UIView()

    /// "Recommended Gifts" 分隔标签
    private let recommendLabel_Ornit: UILabel = {
        let l = UILabel()
        l.text = "Recommended Gifts"
        l.font = UIFont.italicSystemFont(ofSize: 22).withWeight(.medium)
        l.textColor = UIColor(white: 0.15, alpha: 1)
        l.textAlignment = .left
        return l
    }()

    /// 组件2：普通礼物网格
    private let comp2View_Ornit = UIView()

    private let buyBtn_Ornit: UIButton = {
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
        loadGiftData_Ornit()
        buildDimAndCard_Ornit()
        buildComp1_Ornit()
        buildRecommendLabel_Ornit()
        buildComp2_Ornit()
        buildBuyBtn_Ornit()
        setupConstraints_Ornit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 初始位置在屏幕下方，准备滑入动画
        bgCard_Ornit.transform = CGAffineTransform(translationX: 0, y: bgCardH_Ornit + 40)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.38, delay: 0,
                       usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.bgCard_Ornit.transform = .identity
            self.dimView_Ornit.alpha = 1
        }
    }

    // MARK: - 数据加载

    /// 加载礼物数据：限定礼物（组件1）+ 普通礼物（组件2）
    private func loadGiftData_Ornit() {
        let all = Subscribe_Ornit.shared_Ornit.goodsList_Ornit
            .filter { !($0.goodIsVIP_Ornit ?? false) }
        limitGifts_Ornit = Array(
            all.filter { $0.goodIsSpecial_Ornit ?? false }.prefix(3)
        )
        normalGifts_Ornit = Array(
            all.filter { !($0.goodIsTop_Ornit ?? false) && !($0.goodIsSpecial_Ornit ?? false) }.prefix(12)
        )
    }

    // MARK: - UI 搭建

    private func buildDimAndCard_Ornit() {
        view.addSubview(dimView_Ornit)
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Ornit))
        dimView_Ornit.addGestureRecognizer(dimTap)

        view.addSubview(bgCard_Ornit)
        // 顶部圆角，底部贴边
        bgCard_Ornit.layer.cornerRadius = 24
        bgCard_Ornit.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        bgCard_Ornit.clipsToBounds = true

        bgCard_Ornit.addSubview(bgImageView_Ornit)
        bgCard_Ornit.addSubview(comp1View_Ornit)
        bgCard_Ornit.addSubview(recommendLabel_Ornit)
        bgCard_Ornit.addSubview(comp2View_Ornit)
    }

    // MARK: - 组件1：限定礼物横向三卡片

    /// 构建组件1（3个限定礼物均分横向排列，各110×114）
    private func buildComp1_Ornit() {
        comp1Refs_Ornit.removeAll()
        var cards_Ornit: [UIView] = []

        let iconNames_Ornit = ["gift_one", "gift_two", "gift_three"]

        for (i, gift) in limitGifts_Ornit.prefix(3).enumerated() {
            let card_Ornit = buildComp1Card_Ornit(
                gift: gift,
                iconName: iconNames_Ornit[safe: i] ?? "gift_one",
                index: i
            )
            cards_Ornit.append(card_Ornit)
        }

        // 不足3个时用透明占位补满
        while cards_Ornit.count < 3 {
            let placeholder = UIView()
            placeholder.alpha = 0
            placeholder.snp.makeConstraints { make in make.width.equalTo(110); make.height.equalTo(114) }
            cards_Ornit.append(placeholder)
        }

        let stack_Ornit = UIStackView(arrangedSubviews: cards_Ornit)
        stack_Ornit.axis = .horizontal
        stack_Ornit.distribution = .equalSpacing
        stack_Ornit.alignment = .fill

        comp1View_Ornit.addSubview(stack_Ornit)
        stack_Ornit.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 创建组件1单个卡片（110×114，白色圆角，图标+数量+价格+"Special Offer"）
    private func buildComp1Card_Ornit(gift: StoreModel_Ornit, iconName: String, index: Int) -> UIView {
        // 阴影包装层：仅负责阴影，不裁切内容
        let wrapper_Ornit = UIView()
        wrapper_Ornit.backgroundColor = .clear
        wrapper_Ornit.layer.cornerRadius = 30
        wrapper_Ornit.layer.shadowColor = UIColor.black.cgColor
        wrapper_Ornit.layer.shadowOffset = CGSize(width: 0, height: 4)
        wrapper_Ornit.layer.shadowOpacity = 0.18
        wrapper_Ornit.layer.shadowRadius = 8
        wrapper_Ornit.snp.makeConstraints { make in
            make.width.equalTo(110)
            make.height.equalTo(114)
        }

        // 实际卡片：masksToBounds = true 确保 bannerView 直角被自然裁切，不产生缝隙
        let card_Ornit = UIView()
        card_Ornit.backgroundColor = UIColor(hexstring_Ornit: "#2353E4")
        card_Ornit.layer.cornerRadius = 30
        card_Ornit.layer.masksToBounds = true
        wrapper_Ornit.addSubview(card_Ornit)
        card_Ornit.snp.makeConstraints { make in make.edges.equalToSuperview() }

        // 礼物图标（50×46）居上居中
        let iconIV_Ornit = UIImageView()
        iconIV_Ornit.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        iconIV_Ornit.contentMode = .scaleAspectFit
        card_Ornit.addSubview(iconIV_Ornit)
        iconIV_Ornit.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(46)
        }

        // 数量角标（×1）
        let badgeLabel_Ornit = UILabel()
        badgeLabel_Ornit.text = gift.goodsName_Ornit ?? "×1"
        badgeLabel_Ornit.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        badgeLabel_Ornit.textColor = UIColor.white.withAlphaComponent(0.85)
        card_Ornit.addSubview(badgeLabel_Ornit)
        badgeLabel_Ornit.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        // 价格
        let priceLabel_Ornit = UILabel()
        priceLabel_Ornit.text = gift.goodsPrice_Ornit ?? ""
        priceLabel_Ornit.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        priceLabel_Ornit.textColor = .white
        priceLabel_Ornit.textAlignment = .center
        card_Ornit.addSubview(priceLabel_Ornit)
        priceLabel_Ornit.snp.makeConstraints { make in
            make.top.equalTo(iconIV_Ornit.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview().inset(4)
            // 底部留 26pt 给 Special Offer 面板
            make.bottom.equalToSuperview().offset(-32)
        }

        // 底部 "Special Offer" 分层面板（无需自身圆角，由父级 masksToBounds 裁切）
        let bannerView_Ornit = UIView()
        bannerView_Ornit.backgroundColor = .white
        bannerView_Ornit.clipsToBounds = true
        card_Ornit.addSubview(bannerView_Ornit)
        bannerView_Ornit.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(28)
        }

        // 顶部内阴影渐变（从半透明黑到透明），营造分层立体感
        let shadowGrad_Ornit = CAGradientLayer()
        shadowGrad_Ornit.colors = [
            UIColor.black.withAlphaComponent(0.10).cgColor,
            UIColor.clear.cgColor
        ]
        shadowGrad_Ornit.startPoint = CGPoint(x: 0.5, y: 0)
        shadowGrad_Ornit.endPoint = CGPoint(x: 0.5, y: 1)
        shadowGrad_Ornit.frame = CGRect(x: 0, y: 0, width: 110, height: 10)
        bannerView_Ornit.layer.insertSublayer(shadowGrad_Ornit, at: 0)

        let subLabel_Ornit = UILabel()
        subLabel_Ornit.text = "Special Offer"
        subLabel_Ornit.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        subLabel_Ornit.textColor = UIColor(hexstring_Ornit: "#2353E4")
        subLabel_Ornit.textAlignment = .center
        bannerView_Ornit.addSubview(subLabel_Ornit)
        subLabel_Ornit.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(4)
        }

        // 存引用（含 bannerView，用于选中态切换）
        comp1Refs_Ornit.append(Comp1Ref_Ornit(
            card: card_Ornit,
            priceLabel: priceLabel_Ornit,
            subLabel: subLabel_Ornit,
            bannerView: bannerView_Ornit,
            gift: gift
        ))

        // 点击选中
        let tap_Ornit = GiftItemTap_Ornit(gift: gift, target: self, action: #selector(comp1ItemTapped_Ornit(_:)))
        card_Ornit.isUserInteractionEnabled = true
        card_Ornit.addGestureRecognizer(tap_Ornit)

        return wrapper_Ornit
    }

    // MARK: - "Recommended Gifts" 标签

    private func buildRecommendLabel_Ornit() {
        // 已在属性声明中配置，此处无需额外操作
    }

    // MARK: - 组件2：普通礼物网格（3行×4列）

    private func buildComp2_Ornit() {
        comp2View_Ornit.backgroundColor = .clear
        comp2Items_Ornit.removeAll()

        let row1_Ornit = Array(normalGifts_Ornit.prefix(4))
        let row2_Ornit = normalGifts_Ornit.count > 4
            ? Array(normalGifts_Ornit[4...].prefix(4)) : []
        let row3_Ornit = normalGifts_Ornit.count > 8
            ? Array(normalGifts_Ornit[8...].prefix(4)) : []

        // 每行使用不同图标
        let r1Stack_Ornit = buildGridRow_Ornit(gifts: row1_Ornit, iconName: "gift_four")
        let r2Stack_Ornit = buildGridRow_Ornit(gifts: row2_Ornit, iconName: "gift_five")
        let r3Stack_Ornit = buildGridRow_Ornit(gifts: row3_Ornit, iconName: "gift_six")

        let outerStack_Ornit = UIStackView(arrangedSubviews: [r1Stack_Ornit, r2Stack_Ornit, r3Stack_Ornit])
        outerStack_Ornit.axis = .vertical
        outerStack_Ornit.spacing = 10
        outerStack_Ornit.distribution = .fillEqually

        comp2View_Ornit.addSubview(outerStack_Ornit)
        outerStack_Ornit.snp.makeConstraints { make in make.edges.equalToSuperview() }
    }

    /// 构建网格一行（4个 GiftItemView，equalSpacing）
    private func buildGridRow_Ornit(gifts: [StoreModel_Ornit], iconName: String) -> UIStackView {
        var items_Ornit: [UIView] = []
        for i in 0..<4 {
            let gift_Ornit = i < gifts.count ? gifts[i] : nil
            let item_Ornit = GiftItemView_Ornit(iconName: iconName)
            if let g = gift_Ornit {
                item_Ornit.configure_Ornit(gift: g)
                comp2Items_Ornit.append(item_Ornit)
                let tap_Ornit = GiftItemTap_Ornit(
                    gift: g,
                    target: self,
                    action: #selector(gridItemTapped_Ornit(_:))
                )
                item_Ornit.isUserInteractionEnabled = true
                item_Ornit.addGestureRecognizer(tap_Ornit)
            } else {
                item_Ornit.alpha = 0
                item_Ornit.isUserInteractionEnabled = false
            }
            // 每个格子固定 82×82
            item_Ornit.snp.makeConstraints { make in
                make.width.height.equalTo(82)
            }
            items_Ornit.append(item_Ornit)
        }
        let stack_Ornit = UIStackView(arrangedSubviews: items_Ornit)
        stack_Ornit.axis = .horizontal
        stack_Ornit.spacing = 5
        stack_Ornit.distribution = .equalSpacing
        return stack_Ornit
    }

    // MARK: - 购买按钮

    private func buildBuyBtn_Ornit() {
        bgCard_Ornit.addSubview(buyBtn_Ornit)
        buyBtn_Ornit.addTarget(self, action: #selector(buyTapped_Ornit), for: .touchUpInside)

        // 右上角关闭按钮
        let closeBtn_Ornit = UIButton(type: .system)
        let closeConfig_Ornit = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        closeBtn_Ornit.setImage(
            UIImage(systemName: "xmark", withConfiguration: closeConfig_Ornit),
            for: .normal
        )
        closeBtn_Ornit.tintColor = UIColor(white: 0.4, alpha: 1)
        closeBtn_Ornit.backgroundColor = UIColor(white: 0.93, alpha: 1)
        closeBtn_Ornit.layer.cornerRadius = 16
        closeBtn_Ornit.addTarget(self, action: #selector(dismissWithAnimation_Ornit), for: .touchUpInside)
        bgCard_Ornit.addSubview(closeBtn_Ornit)

        closeBtn_Ornit.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(32)
        }
    }

    // MARK: - 约束布局

    private func setupConstraints_Ornit() {
        /// 组件2高度 = 3行×82 + 行间距×2×10
        let comp2H_Ornit: CGFloat = 82 * 3 + 10 * 2

        /// 遮罩全屏
        dimView_Ornit.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// bgCard：全宽，距底部0，高度固定
        bgCard_Ornit.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(bgCardH_Ornit)
        }

        /// 背景图铺满
        bgImageView_Ornit.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 购买按钮：全宽，高62，距 bgCard 底部 34
        buyBtn_Ornit.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(62)
            make.bottom.equalToSuperview().offset(-55)
        }

        /// 组件2：左右内缩，高comp2H，位于购买按钮上方10
        comp2View_Ornit.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(contentInset_Ornit)
            make.trailing.equalToSuperview().offset(-contentInset_Ornit)
            make.height.equalTo(comp2H_Ornit)
            make.bottom.equalTo(buyBtn_Ornit.snp.top).offset(-20)
        }

        /// "Recommended Gifts" 标签：上下各12，位于组件2上方12
        recommendLabel_Ornit.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(contentInset_Ornit)
            make.trailing.equalToSuperview().offset(-contentInset_Ornit)
            make.bottom.equalTo(comp2View_Ornit.snp.top).offset(-12)
        }

        /// 组件1：位于标签上方12，高114
        comp1View_Ornit.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(contentInset_Ornit)
            make.trailing.equalToSuperview().offset(-contentInset_Ornit)
            make.height.equalTo(114)
            make.bottom.equalTo(recommendLabel_Ornit.snp.top).offset(-20)
        }
    }

    // MARK: - 事件处理

    @objc private func dimTapped_Ornit() {
        dismissWithAnimation_Ornit()
    }

    /// 点击组件1某个限定礼物
    @objc private func comp1ItemTapped_Ornit(_ tap: GiftItemTap_Ornit) {
        guard let gift = tap.gift_Ornit else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Ornit = gift
        refreshSelectionUI_Ornit(selectedId: gift.goodsId_Ornit)
    }

    @objc private func gridItemTapped_Ornit(_ tap: GiftItemTap_Ornit) {
        guard let gift = tap.gift_Ornit else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedGift_Ornit = gift
        refreshSelectionUI_Ornit(selectedId: gift.goodsId_Ornit)
    }

    @objc private func buyTapped_Ornit() {
        guard let gift = selectedGift_Ornit, let gid = gift.goodsId_Ornit else {
            Utils_Ornit.showWarning_Ornit(message_Ornit: "Please select a gift first")
            return
        }
        Subscribe_Ornit.shared_Ornit.PurchaseStoreGift_Ornit(gid_Ornit: gid) { [weak self] in
            self?.dismissWithAnimation_Ornit()
        }
    }

    /// 带动画关闭
    @objc private func dismissWithAnimation_Ornit() {
        UIView.animate(withDuration: 0.25, animations: {
            self.bgCard_Ornit.transform = CGAffineTransform(translationX: 0, y: self.bgCardH_Ornit + 40)
            self.dimView_Ornit.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 选中态刷新

    private func refreshSelectionUI_Ornit(selectedId: String?) {
        /// 橘色 65% 透明度作为选中态背景
        let selectedBg_Ornit = UIColor(red: 1.0, green: 0.55, blue: 0.0, alpha: 0.65)
        let selectedText_Ornit = UIColor.white
        let normalText_Ornit = UIColor.white

        // 组件1
        for ref in comp1Refs_Ornit {
            let isSel = ref.gift.goodsId_Ornit == selectedId
            UIView.animate(withDuration: 0.18) {
                if isSel {
                    // 选中：橙色卡片 + bannerView 用深橙色保持可见 + 白色文字
                    ref.card?.backgroundColor = selectedBg_Ornit
                    ref.bannerView?.backgroundColor = UIColor(red: 0.85, green: 0.35, blue: 0.0, alpha: 0.9)
                    ref.priceLabel?.textColor = .white
                    ref.subLabel?.textColor = .white
                } else {
                    // 未选中：蓝色卡片 + 白色 bannerView + 蓝色文字
                    ref.card?.backgroundColor = UIColor(hexstring_Ornit: "#2353E4")
                    ref.bannerView?.backgroundColor = .white
                    ref.priceLabel?.textColor = .white
                    ref.subLabel?.textColor = UIColor(hexstring_Ornit: "#2353E4")
                }
            }
        }

        // 组件2
        comp2Items_Ornit.forEach { item in
            let isSel = item.gift_Ornit?.goodsId_Ornit == selectedId
            UIView.animate(withDuration: 0.18) {
                item.applySelectionState_Ornit(
                    isSelected_Ornit: isSel,
                    selectedBgColor_Ornit: selectedBg_Ornit,
                    selectedTextColor_Ornit: selectedText_Ornit,
                    normalTextColor_Ornit: normalText_Ornit
                )
            }
        }
    }
}

// MARK: - 礼物 Item 视图

/// 礼物商品单元视图（组件2，82×82，圆角20，渐变背景）
/// 未选中：#863DE6 → #3698EF 顶部到底部渐变；选中：白色背景
class GiftItemView_Ornit: UIView {

    private(set) var gift_Ornit: StoreModel_Ornit?

    private let iconIV_Ornit: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let nameLabel_Ornit: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    private let priceLabel_Ornit: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        l.textColor = .white
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 渐变图层（#863DE6 → #3698EF，顶部居中到底部居中）
    private let gradientLayer_Ornit: CAGradientLayer = {
        let g = CAGradientLayer()
        g.colors = [
            UIColor(red: 134/255, green: 61/255, blue: 230/255, alpha: 1).cgColor,
            UIColor(red: 54/255, green: 152/255, blue: 239/255, alpha: 1).cgColor
        ]
        g.startPoint = CGPoint(x: 0.5, y: 0)
        g.endPoint = CGPoint(x: 0.5, y: 1)
        return g
    }()

    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Ornit.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Ornit()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer_Ornit.frame = bounds
    }

    private func buildUI_Ornit() {
        layer.cornerRadius = 20
        layer.masksToBounds = true

        // 渐变作为默认背景
        layer.insertSublayer(gradientLayer_Ornit, at: 0)

        let vStack_Ornit = UIStackView(arrangedSubviews: [iconIV_Ornit, nameLabel_Ornit, priceLabel_Ornit])
        vStack_Ornit.axis = .vertical
        vStack_Ornit.spacing = 4
        vStack_Ornit.alignment = .center
        vStack_Ornit.distribution = .fill

        addSubview(vStack_Ornit)
        vStack_Ornit.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-4)
        }
        iconIV_Ornit.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
    }

    func configure_Ornit(gift: StoreModel_Ornit) {
        self.gift_Ornit = gift
        nameLabel_Ornit.text = gift.goodsName_Ornit ?? ""
        priceLabel_Ornit.text = gift.goodsPrice_Ornit ?? ""
    }

    /// 切换选中/未选中外观
    /// - Parameters:
    ///   - isSelected_Ornit: 是否选中
    ///   - selectedBgColor_Ornit: 选中时背景色（橘色65%透明度）
    ///   - selectedTextColor_Ornit: 选中时文字色
    ///   - normalTextColor_Ornit: 未选中文字色（白色）
    func applySelectionState_Ornit(isSelected_Ornit: Bool,
                                   selectedBgColor_Ornit: UIColor,
                                   selectedTextColor_Ornit: UIColor,
                                   normalTextColor_Ornit: UIColor) {
        if isSelected_Ornit {
            gradientLayer_Ornit.isHidden = true
            backgroundColor = selectedBgColor_Ornit
        } else {
            gradientLayer_Ornit.isHidden = false
            backgroundColor = .clear
        }
        nameLabel_Ornit.textColor = isSelected_Ornit ? selectedTextColor_Ornit : normalTextColor_Ornit
        priceLabel_Ornit.textColor = isSelected_Ornit ? selectedTextColor_Ornit : normalTextColor_Ornit
    }
}

// MARK: - 携带礼物数据的点击手势

private class GiftItemTap_Ornit: UITapGestureRecognizer {
    var gift_Ornit: StoreModel_Ornit?
    convenience init(gift: StoreModel_Ornit, target: Any?, action: Selector?) {
        self.init(target: target, action: action)
        self.gift_Ornit = gift
    }
}

// MARK: - 辅助扩展

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private extension UIFont {
    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let desc = fontDescriptor.addingAttributes([
            .traits: [UIFontDescriptor.TraitKey.weight: weight]
        ])
        return UIFont(descriptor: desc, size: pointSize)
    }
}
