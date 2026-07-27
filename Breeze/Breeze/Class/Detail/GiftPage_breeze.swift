import Foundation
import UIKit
import SnapKit

// MARK: - 送礼界面

/// 送礼模态弹起界面
/// 核心作用：底部弹出礼物列表，用户点击各Item内的Buy按钮发起内购
/// 设计思路：
///   - 半透明遮罩 + 底部卡片（仅上方圆角），吸附屏幕底部；
///   - 组件1：goodIsSpecial_Breeze=true 的三个限定礼物横向均分（#FDFF70背景，gift_one/two/three）；
///   - 组件2：goodIsSpecial_Breeze=false 的普通礼物横向可滚动列表（白色透明背景，gift_four）；
///   - 各Item内置Buy购买按钮，直接触发内购；
///   - 点击遮罩关闭界面。
/// 关键属性/方法：limitGifts_Breeze / normalGifts_Breeze / handleBuy_Breeze
class GiftPage_Breeze: UIViewController {

    // MARK: - 布局常量

    private var screenW_Breeze: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Breeze: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 高度 = 屏幕高度 × 0.7
    private var bgCardH_Breeze: CGFloat { screenH_Breeze * 0.5 }
    /// 内容区域左右内边距
    private let contentPadding_Breeze: CGFloat = 16
    /// 各礼物Item之间的间距
    private let itemSpacing_Breeze: CGFloat = 7

    // MARK: - 数据

    /// goodIsSpecial_Breeze=true 的限定礼物，最多取3个，依次对应 gift_one/two/three
    private var limitGifts_Breeze: [StoreModel_Breeze] = []
    /// goodIsSpecial_Breeze=false 的普通礼物，对应 gift_four
    private var normalGifts_Breeze: [StoreModel_Breeze] = []

    // MARK: - UI 组件

    /// 半透明黑色遮罩，点击可关闭界面
    private let dimView_Breeze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 底部背景卡片（仅顶部圆角，吸附屏幕底部）
    private let bgCard_Breeze: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// gift_bg 装饰背景图（铺满 bgCard）
    private let bgImageView_Breeze: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1容器：限定礼物横向均分
    private let comp1View_Breeze = UIView()

    /// 组件2横向滚动容器：普通礼物横向排列，整体携带黑色阴影
    private let comp2ScrollView_Breeze: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator   = false
        sv.clipsToBounds = false
        // 整体滑动区域阴影
        sv.layer.shadowColor   = UIColor.black.cgColor
        sv.layer.shadowOpacity = 0.6
        sv.layer.shadowRadius  = 8
        sv.layer.shadowOffset  = CGSize(width: 0, height: 4)
        return sv
    }()

    /// 组件2内容视图（承载所有普通礼物Item）
    private let comp2ContentView_Breeze = UIView()

    /// 关闭按钮（bgCard 右上角）
    private let closeButton_Breeze: UIButton = {
        let btn = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        btn.setImage(UIImage(systemName: "xmark", withConfiguration: config), for: .normal)
        btn.tintColor = .black
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        return btn
    }()

    /// bgCard 高度约束引用，用于适配安全区
    private var bgCardHeightConstraint_Breeze: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        loadGiftData_Breeze()
        buildLayout_Breeze()
        buildComp1_Breeze()
        buildComp2_Breeze()
        setupConstraints_Breeze()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        /// 屏幕方向变化时同步更新卡片高度
        bgCardHeightConstraint_Breeze?.update(offset: bgCardH_Breeze)
    }

    // MARK: - 数据加载

    /// 区分限定礼物（goodIsSpecial_Breeze=true）与普通礼物（goodIsSpecial_Breeze=false）
    private func loadGiftData_Breeze() {
        let all_Breeze = Store_Breeze.shared_Breeze.goodsList_Breeze
            .filter { !($0.goodIsVIP_Breeze ?? false) }
        limitGifts_Breeze  = Array(all_Breeze.filter { $0.goodIsSpecial_Breeze ?? false }.prefix(3))
        normalGifts_Breeze = all_Breeze.filter { !($0.goodIsSpecial_Breeze ?? false) }
    }

    // MARK: - 基础视图层级

    /// 搭建遮罩与底部卡片的基础视图层级
    private func buildLayout_Breeze() {
        view.addSubview(dimView_Breeze)
        let dimTap_Breeze = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Breeze))
        dimView_Breeze.addGestureRecognizer(dimTap_Breeze)

        view.addSubview(bgCard_Breeze)
        bgCard_Breeze.addSubview(bgImageView_Breeze)
        bgCard_Breeze.addSubview(comp1View_Breeze)
        bgCard_Breeze.addSubview(comp2ScrollView_Breeze)
        comp2ScrollView_Breeze.addSubview(comp2ContentView_Breeze)

        // 关闭按钮：叠加在 bgCard 左上角
        bgCard_Breeze.addSubview(closeButton_Breeze)
        closeButton_Breeze.addTarget(self, action: #selector(dimTapped_Breeze), for: .touchUpInside)
    }

    // MARK: - 组件1：限定礼物横向均分

    /// 构建组件1：三个限定礼物Item横向均分展示
    /// 图标顺序：gift_one → gift_two → gift_three
    private func buildComp1_Breeze() {
        let iconNames_Breeze = ["gift_one", "gift_two", "gift_three"]
        var itemViews_Breeze: [UIView] = []

        for (idx_Breeze, gift_Breeze) in limitGifts_Breeze.enumerated() {
            let iconName_Breeze = idx_Breeze < iconNames_Breeze.count
                ? iconNames_Breeze[idx_Breeze] : "gift_one"
            let item_Breeze = LimitGiftItem_Breeze(iconName: iconName_Breeze)
            item_Breeze.configure_Breeze(gift: gift_Breeze)
            item_Breeze.onBuyTapped_Breeze = { [weak self] gift in
                self?.handleBuy_Breeze(gift: gift)
            }
            itemViews_Breeze.append(item_Breeze)
        }

        let stack_Breeze = UIStackView(arrangedSubviews: itemViews_Breeze)
        stack_Breeze.axis         = .horizontal
        stack_Breeze.spacing      = itemSpacing_Breeze
        stack_Breeze.distribution = .fillEqually
        stack_Breeze.alignment    = .fill

        comp1View_Breeze.addSubview(stack_Breeze)
        stack_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 组件2：普通礼物横向滚动

    /// 构建组件2：普通礼物横向排列，约4个可见，可横向滚动
    /// 图标规则：前4个 gift_four，中间4个 gift_five，其余 gift_six
    private func buildComp2_Breeze() {
        /// 约4个Item可见的单Item宽度
        let itemW_Breeze = (screenW_Breeze - 2 * contentPadding_Breeze - 3 * itemSpacing_Breeze) / 4
        var prevView_Breeze: UIView? = nil

        for (idx_Breeze, gift_Breeze) in normalGifts_Breeze.enumerated() {
            let iconName_Breeze: String
            if idx_Breeze < 4 {
                iconName_Breeze = "gift_four"
            } else if idx_Breeze < 8 {
                iconName_Breeze = "gift_five"
            } else {
                iconName_Breeze = "gift_six"
            }
            let item_Breeze = NormalGiftItem_Breeze(iconName: iconName_Breeze)
            item_Breeze.configure_Breeze(gift: gift_Breeze)
            item_Breeze.onBuyTapped_Breeze = { [weak self] gift in
                self?.handleBuy_Breeze(gift: gift)
            }
            comp2ContentView_Breeze.addSubview(item_Breeze)
            item_Breeze.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(itemW_Breeze)
                if let prev_Breeze = prevView_Breeze {
                    make.leading.equalTo(prev_Breeze.snp.trailing).offset(itemSpacing_Breeze)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            prevView_Breeze = item_Breeze
        }

        /// 末尾Item的 trailing 决定 ScrollView 的 contentSize
        if let last_Breeze = prevView_Breeze {
            last_Breeze.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
            }
        }
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束，bgCard 吸附屏幕底部，高度为屏幕高度的 0.7
    /// 内容区从 bgCard 底部往上30pt对齐（bottom-up布局）
    private func setupConstraints_Breeze() {
        dimView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bgCard_Breeze.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            bgCardHeightConstraint_Breeze = make.height.equalTo(bgCardH_Breeze).constraint
        }

        bgImageView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 组件2：bottom 距 bgCard 安全区底部 30pt，高度105容纳图片+价格+按钮
        comp2ScrollView_Breeze.snp.makeConstraints { make in
            make.bottom.equalTo(bgCard_Breeze.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalToSuperview().offset(contentPadding_Breeze)
            make.trailing.equalToSuperview().offset(-contentPadding_Breeze)
            make.height.equalTo(105)
        }

        /// 组件1：紧靠组件2上方12pt，高度160（容纳69图片+价格+按钮+内边距）
        comp1View_Breeze.snp.makeConstraints { make in
            make.bottom.equalTo(comp2ScrollView_Breeze.snp.top).offset(-12)
            make.leading.equalToSuperview().offset(contentPadding_Breeze)
            make.trailing.equalToSuperview().offset(-contentPadding_Breeze)
            make.height.equalTo(160)
        }

        /// comp2ContentView 高度与 ScrollView 一致，宽度由内部Item决定
        comp2ContentView_Breeze.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(105)
        }

        /// 关闭按钮：bgCard 右上角，顶部12，右侧16，尺寸30×30
        closeButton_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(30)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Breeze() {
        dismiss(animated: true)
    }

    /// 统一处理礼物购买逻辑
    /// - Parameter gift: 用户点击Buy的礼物模型
    private func handleBuy_Breeze(gift: StoreModel_Breeze) {
        guard let gid_Breeze = gift.goodsId_Breeze else {
            Utils_Breeze.showWarning_Breeze(message_Breeze: "Gift information is invalid")
            return
        }
        Store_Breeze.shared_Breeze.PurchaseStoreGift_Breeze(gid_Breeze: gid_Breeze) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - 限定礼物 Item（组件1）

/// 限定礼物单元视图（组件1使用）
/// 核心作用：展示单个限定礼物，包含装饰图片、价格与购买按钮，右上角显示商品名称
/// 设计：高度137，背景#FDFF70，圆角20；内部居中竖向：69x69图片 → 价格标签 → Buy按钮；右上角商品名
/// 关键属性：onBuyTapped_Breeze（点击Buy时的回调闭包）
class LimitGiftItem_Breeze: UIView {

    // MARK: - 属性

    /// 点击Buy按钮时触发的回调，携带对应礼物模型
    var onBuyTapped_Breeze: ((StoreModel_Breeze) -> Void)?

    /// 绑定的礼物数据
    private var gift_Breeze: StoreModel_Breeze?

    // MARK: - UI 组件

    /// 礼物装饰图（69×69）
    private let iconIV_Breeze: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 商品价格标签（16pt 中等 黑色）
    private let priceLabel_Breeze: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 16, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()

    /// 购买按钮（86×24，与普通礼物按钮颜色一致：白色背景）
    private let buyBtn_Breeze: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Buy", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        return btn
    }()

    /// 右上角商品名标签（12pt 中等 黑色）
    private let nameLabel_Breeze: UILabel = {
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
        iconIV_Breeze.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Breeze()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// 构建内部视图层级与布局约束
    private func buildUI_Breeze() {
        // 背景色与普通礼物保持一致
        backgroundColor = UIColor.white.withAlphaComponent(0.6)
        layer.cornerRadius  = 20
        layer.masksToBounds = false
        // 黑色阴影，透明度 0.6
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius  = 6
        layer.shadowOffset  = CGSize(width: 0, height: 3)

        addSubview(iconIV_Breeze)
        addSubview(priceLabel_Breeze)
        addSubview(buyBtn_Breeze)
        addSubview(nameLabel_Breeze)

        /// 图片居中于顶部区域
        iconIV_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(69)
        }

        /// 价格在图片下方6pt
        priceLabel_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconIV_Breeze.snp.bottom).offset(6)
        }

        /// 购买按钮在价格下方6pt，宽86高24
        buyBtn_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(priceLabel_Breeze.snp.bottom).offset(6)
            make.width.equalTo(86)
            make.height.equalTo(24)
        }

        /// 商品名显示在右上角
        nameLabel_Breeze.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        buyBtn_Breeze.addTarget(self, action: #selector(buyTapped_Breeze), for: .touchUpInside)
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: 礼物商品模型
    func configure_Breeze(gift: StoreModel_Breeze) {
        gift_Breeze          = gift
        priceLabel_Breeze.text = gift.goodsPrice_Breeze ?? ""
        nameLabel_Breeze.text  = gift.goodsName_Breeze  ?? ""
    }

    // MARK: - 事件

    /// Buy按钮点击，回调携带礼物数据
    @objc private func buyTapped_Breeze() {
        guard let gift = gift_Breeze else { return }
        onBuyTapped_Breeze?(gift)
    }
}

// MARK: - 普通礼物 Item（组件2）

/// 普通礼物单元视图（组件2使用）
/// 核心作用：展示单个普通礼物，图片(gift_four)上叠加商品名，下方价格与购买按钮
/// 设计：高度85，背景白色60%透明，圆角20；51x51图片叠加名称 → 价格标签 → Buy按钮
/// 关键属性：onBuyTapped_Breeze（点击Buy时的回调闭包）
class NormalGiftItem_Breeze: UIView {

    // MARK: - 属性

    /// 点击Buy按钮时触发的回调，携带对应礼物模型
    var onBuyTapped_Breeze: ((StoreModel_Breeze) -> Void)?

    /// 绑定的礼物数据
    private var gift_Breeze: StoreModel_Breeze?

    // MARK: - UI 组件

    /// 礼物图标（51×51，图标名由外部传入）
    private let iconIV_Breeze: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 叠加在图片中心的商品名标签（12pt 中等 黑色）
    private let overlayNameLabel_Breeze: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 商品价格标签（14pt 中等 黑色）
    private let priceLabel_Breeze: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()

    /// 购买按钮（64×24，白色背景，文字"Buy"，14pt中等黑色）
    private let buyBtn_Breeze: UIButton = {
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

    /// - Parameter iconName: 礼物图标 Assets 名称（gift_four / gift_five / gift_six）
    init(iconName: String) {
        super.init(frame: .zero)
        iconIV_Breeze.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Breeze()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// 构建内部视图层级与布局约束
    private func buildUI_Breeze() {
        backgroundColor = UIColor.white.withAlphaComponent(0.6)
        layer.cornerRadius  = 20
        layer.masksToBounds = false
        // 黑色阴影，透明度 0.6
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowRadius  = 6
        layer.shadowOffset  = CGSize(width: 0, height: 3)

        addSubview(iconIV_Breeze)
        addSubview(overlayNameLabel_Breeze)
        addSubview(priceLabel_Breeze)
        addSubview(buyBtn_Breeze)

        /// 图片居中横向，顶部内边距4
        iconIV_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(51)
        }

        /// 商品名叠加在图片中心
        overlayNameLabel_Breeze.snp.makeConstraints { make in
            make.center.equalTo(iconIV_Breeze)
            make.leading.greaterThanOrEqualTo(iconIV_Breeze.snp.leading)
            make.trailing.lessThanOrEqualTo(iconIV_Breeze.snp.trailing)
        }

        /// 价格在图片下方2pt
        priceLabel_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconIV_Breeze.snp.bottom).offset(2)
        }

        /// Buy按钮固定在底部内边距4pt
        buyBtn_Breeze.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-4)
            make.width.equalTo(64)
            make.height.equalTo(24)
        }

        buyBtn_Breeze.addTarget(self, action: #selector(buyTapped_Breeze), for: .touchUpInside)
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: 礼物商品模型
    func configure_Breeze(gift: StoreModel_Breeze) {
        gift_Breeze               = gift
        priceLabel_Breeze.text    = gift.goodsPrice_Breeze ?? ""
        overlayNameLabel_Breeze.text = gift.goodsName_Breeze ?? ""
    }

    // MARK: - 事件

    /// Buy按钮点击，回调携带礼物数据
    @objc private func buyTapped_Breeze() {
        guard let gift = gift_Breeze else { return }
        onBuyTapped_Breeze?(gift)
    }
}
