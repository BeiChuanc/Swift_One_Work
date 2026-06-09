import Foundation
import UIKit
import SnapKit

// MARK: - 送礼界面

/// 送礼模态弹起界面
/// 核心作用：底部弹出礼物列表，用户点击各Item内的Buy按钮发起内购
/// 设计思路：
///   - 半透明遮罩 + 底部卡片（仅上方圆角），吸附屏幕底部；
///   - 组件1：goodIsSpecial_Niche=true 的三个限定礼物横向均分（#FDFF70背景，gift_one/two/three）；
///   - 组件2：goodIsSpecial_Niche=false 的普通礼物横向可滚动列表（白色透明背景，gift_four）；
///   - 各Item内置Buy购买按钮，直接触发内购；
///   - 点击遮罩关闭界面。
/// 关键属性/方法：limitGifts_Niche / normalGifts_Niche / handleBuy_Niche
class GiftPage_Niche: UIViewController {

    // MARK: - 布局常量

    private var screenW_Niche: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Niche: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 高度 = 屏幕高度 × 0.7
    private var bgCardH_Niche: CGFloat { screenH_Niche * 0.5 }
    /// 内容区域左右内边距
    private let contentPadding_Niche: CGFloat = 16
    /// 各礼物Item之间的间距
    private let itemSpacing_Niche: CGFloat = 7

    // MARK: - 数据

    /// goodIsSpecial_Niche=true 的限定礼物，最多取3个，依次对应 gift_one/two/three
    private var limitGifts_Niche: [StoreModel_Niche] = []
    /// goodIsSpecial_Niche=false 的普通礼物，对应 gift_four
    private var normalGifts_Niche: [StoreModel_Niche] = []

    // MARK: - UI 组件

    /// 半透明黑色遮罩，点击可关闭界面
    private let dimView_Niche: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withValues(alpha: 0.50)
        return v
    }()

    /// 底部背景卡片（仅顶部圆角，吸附屏幕底部）
    private let bgCard_Niche: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// gift_bg 装饰背景图（铺满 bgCard）
    private let bgImageView_Niche: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1容器：限定礼物横向均分
    private let comp1View_Niche = UIView()

    /// 组件2横向滚动容器：普通礼物横向排列
    private let comp2ScrollView_Niche: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    /// 组件2内容视图（承载所有普通礼物Item）
    private let comp2ContentView_Niche = UIView()

    /// bgCard 高度约束引用，用于适配安全区
    private var bgCardHeightConstraint_Niche: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        loadGiftData_Niche()
        buildLayout_Niche()
        buildComp1_Niche()
        buildComp2_Niche()
        setupConstraints_Niche()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        /// 屏幕方向变化时同步更新卡片高度
        bgCardHeightConstraint_Niche?.update(offset: bgCardH_Niche)
    }

    // MARK: - 数据加载

    /// 区分限定礼物（goodIsSpecial_Niche=true）与普通礼物（goodIsSpecial_Niche=false）
    private func loadGiftData_Niche() {
        let all_Niche = Store_Niche.shared_Niche.goodsList_Niche
            .filter { !($0.goodIsVIP_Niche ?? false) }
        limitGifts_Niche  = Array(all_Niche.filter { $0.goodIsSpecial_Niche ?? false }.prefix(3))
        normalGifts_Niche = all_Niche.filter { !($0.goodIsSpecial_Niche ?? false) }
    }

    // MARK: - 基础视图层级

    /// 搭建遮罩与底部卡片的基础视图层级
    private func buildLayout_Niche() {
        view.addSubview(dimView_Niche)
        let dimTap_Niche = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Niche))
        dimView_Niche.addGestureRecognizer(dimTap_Niche)

        view.addSubview(bgCard_Niche)
        bgCard_Niche.addSubview(bgImageView_Niche)
        bgCard_Niche.addSubview(comp1View_Niche)
        bgCard_Niche.addSubview(comp2ScrollView_Niche)
        comp2ScrollView_Niche.addSubview(comp2ContentView_Niche)
    }

    // MARK: - 组件1：限定礼物横向均分

    /// 构建组件1：三个限定礼物Item横向均分展示
    /// 图标顺序：gift_one → gift_two → gift_three
    private func buildComp1_Niche() {
        let iconNames_Niche = ["gift_one", "gift_two", "gift_three"]
        var itemViews_Niche: [UIView] = []

        for (idx_Niche, gift_Niche) in limitGifts_Niche.enumerated() {
            let iconName_Niche = idx_Niche < iconNames_Niche.count
                ? iconNames_Niche[idx_Niche] : "gift_one"
            let item_Niche = LimitGiftItem_Niche(iconName: iconName_Niche)
            item_Niche.configure_Niche(gift: gift_Niche)
            item_Niche.onBuyTapped_Niche = { [weak self] gift in
                self?.handleBuy_Niche(gift: gift)
            }
            itemViews_Niche.append(item_Niche)
        }

        let stack_Niche = UIStackView(arrangedSubviews: itemViews_Niche)
        stack_Niche.axis         = .horizontal
        stack_Niche.spacing      = itemSpacing_Niche
        stack_Niche.distribution = .fillEqually
        stack_Niche.alignment    = .fill

        comp1View_Niche.addSubview(stack_Niche)
        stack_Niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 组件2：普通礼物横向滚动

    /// 构建组件2：普通礼物横向排列，约4个可见，可横向滚动
    /// 图标统一使用 gift_four
    private func buildComp2_Niche() {
        /// 约4个Item可见的单Item宽度
        let itemW_Niche = (screenW_Niche - 2 * contentPadding_Niche - 3 * itemSpacing_Niche) / 4
        var prevView_Niche: UIView? = nil

        for gift_Niche in normalGifts_Niche {
            let item_Niche = NormalGiftItem_Niche()
            item_Niche.configure_Niche(gift: gift_Niche)
            item_Niche.onBuyTapped_Niche = { [weak self] gift in
                self?.handleBuy_Niche(gift: gift)
            }
            comp2ContentView_Niche.addSubview(item_Niche)
            item_Niche.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(itemW_Niche)
                if let prev_Niche = prevView_Niche {
                    make.leading.equalTo(prev_Niche.snp.trailing).offset(itemSpacing_Niche)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            prevView_Niche = item_Niche
        }

        /// 末尾Item的 trailing 决定 ScrollView 的 contentSize
        if let last_Niche = prevView_Niche {
            last_Niche.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
            }
        }
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束，bgCard 吸附屏幕底部，高度为屏幕高度的 0.7
    /// 内容区从 bgCard 底部往上30pt对齐（bottom-up布局）
    private func setupConstraints_Niche() {
        dimView_Niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bgCard_Niche.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            bgCardHeightConstraint_Niche = make.height.equalTo(bgCardH_Niche).constraint
        }

        bgImageView_Niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 组件2：bottom 距 bgCard 安全区底部 30pt，高度105容纳图片+价格+按钮
        comp2ScrollView_Niche.snp.makeConstraints { make in
            make.bottom.equalTo(bgCard_Niche.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalToSuperview().offset(contentPadding_Niche)
            make.trailing.equalToSuperview().offset(-contentPadding_Niche)
            make.height.equalTo(105)
        }

        /// 组件1：紧靠组件2上方12pt，高度160（容纳69图片+价格+按钮+内边距）
        comp1View_Niche.snp.makeConstraints { make in
            make.bottom.equalTo(comp2ScrollView_Niche.snp.top).offset(-12)
            make.leading.equalToSuperview().offset(contentPadding_Niche)
            make.trailing.equalToSuperview().offset(-contentPadding_Niche)
            make.height.equalTo(160)
        }

        /// comp2ContentView 高度与 ScrollView 一致，宽度由内部Item决定
        comp2ContentView_Niche.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(105)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Niche() {
        dismiss(animated: true)
    }

    /// 统一处理礼物购买逻辑
    /// - Parameter gift: 用户点击Buy的礼物模型
    private func handleBuy_Niche(gift: StoreModel_Niche) {
        guard let gid_Niche = gift.goodsId_Niche else {
            Utils_Niche.showWarning_Niche(message_Niche: "Gift information is invalid")
            return
        }
        Store_Niche.shared_Niche.PurchaseStoreGift_Niche(gid_Niche: gid_Niche) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - 限定礼物 Item（组件1）

/// 限定礼物单元视图（组件1使用）
/// 核心作用：展示单个限定礼物，包含装饰图片、价格与购买按钮，右上角显示商品名称
/// 设计：高度137，背景#FDFF70，圆角20；内部居中竖向：69x69图片 → 价格标签 → Buy按钮；右上角商品名
/// 关键属性：onBuyTapped_Niche（点击Buy时的回调闭包）
class LimitGiftItem_Niche: UIView {

    // MARK: - 属性

    /// 点击Buy按钮时触发的回调，携带对应礼物模型
    var onBuyTapped_Niche: ((StoreModel_Niche) -> Void)?

    /// 绑定的礼物数据
    private var gift_Niche: StoreModel_Niche?

    // MARK: - UI 组件

    /// 礼物装饰图（69×69）
    private let iconIV_Niche: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 商品价格标签（16pt 中等 黑色）
    private let priceLabel_Niche: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 16, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()

    /// 购买按钮（86×24，背景#C197FC，文字"Buy"，14pt中等黑色）
    private let buyBtn_Niche: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Buy", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = UIColor(hexstring_Niche: "#C197FC")
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        return btn
    }()

    /// 右上角商品名标签（12pt 中等 黑色）
    private let nameLabel_Niche: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = .black
        l.textAlignment = .right
        return l
    }()

    // MARK: - 初始化

    /// - Parameter iconName: 礼物图标 Assets 名称（gift_one / gift_two / gift_three）
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Niche.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Niche()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// 构建内部视图层级与布局约束
    private func buildUI_Niche() {
        backgroundColor = UIColor(hexstring_Niche: "#FDFF70")
        layer.cornerRadius  = 20
        layer.masksToBounds = true

        addSubview(iconIV_Niche)
        addSubview(priceLabel_Niche)
        addSubview(buyBtn_Niche)
        addSubview(nameLabel_Niche)

        /// 图片居中于顶部区域
        iconIV_Niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(69)
        }

        /// 价格在图片下方6pt
        priceLabel_Niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconIV_Niche.snp.bottom).offset(6)
        }

        /// 购买按钮在价格下方6pt，宽86高24
        buyBtn_Niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(priceLabel_Niche.snp.bottom).offset(6)
            make.width.equalTo(86)
            make.height.equalTo(24)
        }

        /// 商品名显示在右上角
        nameLabel_Niche.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        buyBtn_Niche.addTarget(self, action: #selector(buyTapped_Niche), for: .touchUpInside)
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: 礼物商品模型
    func configure_Niche(gift: StoreModel_Niche) {
        gift_Niche          = gift
        priceLabel_Niche.text = gift.goodsPrice_Niche ?? ""
        nameLabel_Niche.text  = gift.goodsName_Niche  ?? ""
    }

    // MARK: - 事件

    /// Buy按钮点击，回调携带礼物数据
    @objc private func buyTapped_Niche() {
        guard let gift = gift_Niche else { return }
        onBuyTapped_Niche?(gift)
    }
}

// MARK: - 普通礼物 Item（组件2）

/// 普通礼物单元视图（组件2使用）
/// 核心作用：展示单个普通礼物，图片(gift_four)上叠加商品名，下方价格与购买按钮
/// 设计：高度85，背景白色60%透明，圆角20；51x51图片叠加名称 → 价格标签 → Buy按钮
/// 关键属性：onBuyTapped_Niche（点击Buy时的回调闭包）
class NormalGiftItem_Niche: UIView {

    // MARK: - 属性

    /// 点击Buy按钮时触发的回调，携带对应礼物模型
    var onBuyTapped_Niche: ((StoreModel_Niche) -> Void)?

    /// 绑定的礼物数据
    private var gift_Niche: StoreModel_Niche?

    // MARK: - UI 组件

    /// 礼物图标（51×51，gift_four）
    private let iconIV_Niche: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_four")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 叠加在图片中心的商品名标签（12pt 中等 黑色）
    private let overlayNameLabel_Niche: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 商品价格标签（14pt 中等 黑色）
    private let priceLabel_Niche: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()

    /// 购买按钮（64×24，白色背景，文字"Buy"，14pt中等黑色）
    private let buyBtn_Niche: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Buy", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        return btn
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI_Niche()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// 构建内部视图层级与布局约束
    private func buildUI_Niche() {
        backgroundColor = UIColor.white.withValues(alpha: 0.6)
        layer.cornerRadius  = 20
        layer.masksToBounds = true

        addSubview(iconIV_Niche)
        addSubview(overlayNameLabel_Niche)
        addSubview(priceLabel_Niche)
        addSubview(buyBtn_Niche)

        /// 图片居中横向，顶部内边距4
        iconIV_Niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(51)
        }

        /// 商品名叠加在图片中心
        overlayNameLabel_Niche.snp.makeConstraints { make in
            make.center.equalTo(iconIV_Niche)
            make.leading.greaterThanOrEqualTo(iconIV_Niche.snp.leading)
            make.trailing.lessThanOrEqualTo(iconIV_Niche.snp.trailing)
        }

        /// 价格在图片下方2pt
        priceLabel_Niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconIV_Niche.snp.bottom).offset(2)
        }

        /// Buy按钮固定在底部内边距4pt
        buyBtn_Niche.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-4)
            make.width.equalTo(64)
            make.height.equalTo(24)
        }

        buyBtn_Niche.addTarget(self, action: #selector(buyTapped_Niche), for: .touchUpInside)
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: 礼物商品模型
    func configure_Niche(gift: StoreModel_Niche) {
        gift_Niche               = gift
        priceLabel_Niche.text    = gift.goodsPrice_Niche ?? ""
        overlayNameLabel_Niche.text = gift.goodsName_Niche ?? ""
    }

    // MARK: - 事件

    /// Buy按钮点击，回调携带礼物数据
    @objc private func buyTapped_Niche() {
        guard let gift = gift_Niche else { return }
        onBuyTapped_Niche?(gift)
    }
}
