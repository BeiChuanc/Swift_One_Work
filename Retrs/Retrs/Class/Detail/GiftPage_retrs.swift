import Foundation
import UIKit
import SnapKit

// MARK: - 送礼界面

/// 送礼模态弹起界面
/// 核心作用：底部弹出礼物列表，用户点击各Item内的Buy按钮发起内购
/// 设计思路：
///   - 半透明遮罩 + 底部卡片（仅上方圆角），吸附屏幕底部；
///   - 组件1：goodIsSpecial_Retrs=true 的三个限定礼物横向均分（#FDFF70背景，gift_one/two/three）；
///   - 组件2：goodIsSpecial_Retrs=false 的普通礼物横向可滚动列表（白色透明背景，gift_four）；
///   - 各Item内置Buy购买按钮，直接触发内购；
///   - 点击遮罩关闭界面。
/// 关键属性/方法：limitGifts_Retrs / normalGifts_Retrs / handleBuy_Retrs
class GiftPage_Retrs: UIViewController {

    // MARK: - 布局常量

    private var screenW_Retrs: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Retrs: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 高度 = 屏幕高度 × 0.7
    private var bgCardH_Retrs: CGFloat { screenH_Retrs * 0.5 }
    /// 内容区域左右内边距
    private let contentPadding_Retrs: CGFloat = 16
    /// 各礼物Item之间的间距
    private let itemSpacing_Retrs: CGFloat = 7

    // MARK: - 数据

    /// goodIsSpecial_Retrs=true 的限定礼物，最多取3个，依次对应 gift_one/two/three
    private var limitGifts_Retrs: [StoreModel_Retrs] = []
    /// goodIsSpecial_Retrs=false 的普通礼物，对应 gift_four
    private var normalGifts_Retrs: [StoreModel_Retrs] = []

    // MARK: - UI 组件

    /// 半透明黑色遮罩，点击可关闭界面
    private let dimView_Retrs: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withValues(alpha: 0.50)
        return v
    }()

    /// 底部背景卡片（仅顶部圆角，吸附屏幕底部）
    private let bgCard_Retrs: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// gift_bg 装饰背景图（铺满 bgCard）
    private let bgImageView_Retrs: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 组件1容器：限定礼物横向均分
    private let comp1View_Retrs = UIView()

    /// 组件2横向滚动容器：普通礼物横向排列
    private let comp2ScrollView_Retrs: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    /// 组件2内容视图（承载所有普通礼物Item）
    private let comp2ContentView_Retrs = UIView()

    /// bgCard 高度约束引用，用于适配安全区
    private var bgCardHeightConstraint_Retrs: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        loadGiftData_Retrs()
        buildLayout_Retrs()
        buildComp1_Retrs()
        buildComp2_Retrs()
        setupConstraints_Retrs()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        /// 屏幕方向变化时同步更新卡片高度
        bgCardHeightConstraint_Retrs?.update(offset: bgCardH_Retrs)
    }

    // MARK: - 数据加载

    /// 区分限定礼物（goodIsSpecial_Retrs=true）与普通礼物（goodIsSpecial_Retrs=false）
    private func loadGiftData_Retrs() {
        let all_Retrs = Store_Retrs.shared_Retrs.goodsList_Retrs
            .filter { !($0.goodIsVIP_Retrs ?? false) }
        limitGifts_Retrs  = Array(all_Retrs.filter { $0.goodIsSpecial_Retrs ?? false }.prefix(3))
        normalGifts_Retrs = all_Retrs.filter { !($0.goodIsSpecial_Retrs ?? false) }
    }

    // MARK: - 基础视图层级

    /// 搭建遮罩与底部卡片的基础视图层级
    private func buildLayout_Retrs() {
        view.addSubview(dimView_Retrs)
        let dimTap_Retrs = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Retrs))
        dimView_Retrs.addGestureRecognizer(dimTap_Retrs)

        view.addSubview(bgCard_Retrs)
        bgCard_Retrs.addSubview(bgImageView_Retrs)
        bgCard_Retrs.addSubview(comp1View_Retrs)
        bgCard_Retrs.addSubview(comp2ScrollView_Retrs)
        comp2ScrollView_Retrs.addSubview(comp2ContentView_Retrs)
    }

    // MARK: - 组件1：限定礼物横向均分

    /// 构建组件1：三个限定礼物Item横向均分展示
    /// 图标顺序：gift_one → gift_two → gift_three
    private func buildComp1_Retrs() {
        let iconNames_Retrs = ["gift_one", "gift_two", "gift_three"]
        var itemViews_Retrs: [UIView] = []

        for (idx_Retrs, gift_Retrs) in limitGifts_Retrs.enumerated() {
            let iconName_Retrs = idx_Retrs < iconNames_Retrs.count
                ? iconNames_Retrs[idx_Retrs] : "gift_one"
            let item_Retrs = LimitGiftItem_Retrs(iconName: iconName_Retrs)
            item_Retrs.configure_Retrs(gift: gift_Retrs)
            item_Retrs.onBuyTapped_Retrs = { [weak self] gift in
                self?.handleBuy_Retrs(gift: gift)
            }
            itemViews_Retrs.append(item_Retrs)
        }

        let stack_Retrs = UIStackView(arrangedSubviews: itemViews_Retrs)
        stack_Retrs.axis         = .horizontal
        stack_Retrs.spacing      = itemSpacing_Retrs
        stack_Retrs.distribution = .fillEqually
        stack_Retrs.alignment    = .fill

        comp1View_Retrs.addSubview(stack_Retrs)
        stack_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 组件2：普通礼物横向滚动

    /// 构建组件2：普通礼物横向排列，约4个可见，可横向滚动
    /// 图标统一使用 gift_four
    private func buildComp2_Retrs() {
        /// 约4个Item可见的单Item宽度
        let itemW_Retrs = (screenW_Retrs - 2 * contentPadding_Retrs - 3 * itemSpacing_Retrs) / 4
        var prevView_Retrs: UIView? = nil

        for gift_Retrs in normalGifts_Retrs {
            let item_Retrs = NormalGiftItem_Retrs()
            item_Retrs.configure_Retrs(gift: gift_Retrs)
            item_Retrs.onBuyTapped_Retrs = { [weak self] gift in
                self?.handleBuy_Retrs(gift: gift)
            }
            comp2ContentView_Retrs.addSubview(item_Retrs)
            item_Retrs.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(itemW_Retrs)
                if let prev_Retrs = prevView_Retrs {
                    make.leading.equalTo(prev_Retrs.snp.trailing).offset(itemSpacing_Retrs)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            prevView_Retrs = item_Retrs
        }

        /// 末尾Item的 trailing 决定 ScrollView 的 contentSize
        if let last_Retrs = prevView_Retrs {
            last_Retrs.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
            }
        }
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束，bgCard 吸附屏幕底部，高度为屏幕高度的 0.7
    /// 内容区从 bgCard 底部往上30pt对齐（bottom-up布局）
    private func setupConstraints_Retrs() {
        dimView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bgCard_Retrs.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            bgCardHeightConstraint_Retrs = make.height.equalTo(bgCardH_Retrs).constraint
        }

        bgImageView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        /// 组件2：bottom 距 bgCard 安全区底部 30pt，高度105容纳图片+价格+按钮
        comp2ScrollView_Retrs.snp.makeConstraints { make in
            make.bottom.equalTo(bgCard_Retrs.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalToSuperview().offset(contentPadding_Retrs)
            make.trailing.equalToSuperview().offset(-contentPadding_Retrs)
            make.height.equalTo(105)
        }

        /// 组件1：紧靠组件2上方12pt，高度160（容纳69图片+价格+按钮+内边距）
        comp1View_Retrs.snp.makeConstraints { make in
            make.bottom.equalTo(comp2ScrollView_Retrs.snp.top).offset(-12)
            make.leading.equalToSuperview().offset(contentPadding_Retrs)
            make.trailing.equalToSuperview().offset(-contentPadding_Retrs)
            make.height.equalTo(160)
        }

        /// comp2ContentView 高度与 ScrollView 一致，宽度由内部Item决定
        comp2ContentView_Retrs.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(105)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Retrs() {
        dismiss(animated: true)
    }

    /// 统一处理礼物购买逻辑
    /// - Parameter gift: 用户点击Buy的礼物模型
    private func handleBuy_Retrs(gift: StoreModel_Retrs) {
        guard let gid_Retrs = gift.goodsId_Retrs else {
            Utils_Retrs.showWarning_Retrs(message_Retrs: "Gift information is invalid")
            return
        }
        Store_Retrs.shared_Retrs.PurchaseStoreGift_Retrs(gid_Retrs: gid_Retrs) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - 限定礼物 Item（组件1）

/// 限定礼物单元视图（组件1使用）
/// 核心作用：展示单个限定礼物，包含装饰图片、价格与购买按钮，右上角显示商品名称
/// 设计：高度137，背景#FDFF70，圆角20；内部居中竖向：69x69图片 → 价格标签 → Buy按钮；右上角商品名
/// 关键属性：onBuyTapped_Retrs（点击Buy时的回调闭包）
class LimitGiftItem_Retrs: UIView {

    // MARK: - 属性

    /// 点击Buy按钮时触发的回调，携带对应礼物模型
    var onBuyTapped_Retrs: ((StoreModel_Retrs) -> Void)?

    /// 绑定的礼物数据
    private var gift_Retrs: StoreModel_Retrs?

    // MARK: - UI 组件

    /// 礼物装饰图（69×69）
    private let iconIV_Retrs: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 商品价格标签（16pt 中等 黑色）
    private let priceLabel_Retrs: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 16, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()

    /// 购买按钮（86×24，背景#C197FC，文字"Buy"，14pt中等黑色）
    private let buyBtn_Retrs: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Buy", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.backgroundColor = UIColor.white
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        return btn
    }()

    /// 右上角商品名标签（12pt 中等 黑色）
    private let nameLabel_Retrs: UILabel = {
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
        iconIV_Retrs.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Retrs()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// 构建内部视图层级与布局约束
    private func buildUI_Retrs() {
        backgroundColor = UIColor(hexstring_Retrs: "#FFFFFF").withAlphaComponent(0.35)
        layer.cornerRadius  = 20
        layer.masksToBounds = true

        addSubview(iconIV_Retrs)
        addSubview(priceLabel_Retrs)
        addSubview(buyBtn_Retrs)
        addSubview(nameLabel_Retrs)

        /// 图片居中于顶部区域
        iconIV_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(69)
        }

        /// 价格在图片下方6pt
        priceLabel_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconIV_Retrs.snp.bottom).offset(6)
        }

        /// 购买按钮在价格下方6pt，宽86高24
        buyBtn_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(priceLabel_Retrs.snp.bottom).offset(6)
            make.width.equalTo(86)
            make.height.equalTo(24)
        }

        /// 商品名显示在右上角
        nameLabel_Retrs.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        buyBtn_Retrs.addTarget(self, action: #selector(buyTapped_Retrs), for: .touchUpInside)
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: 礼物商品模型
    func configure_Retrs(gift: StoreModel_Retrs) {
        gift_Retrs          = gift
        priceLabel_Retrs.text = gift.goodsPrice_Retrs ?? ""
        nameLabel_Retrs.text  = gift.goodsName_Retrs  ?? ""
    }

    // MARK: - 事件

    /// Buy按钮点击，回调携带礼物数据
    @objc private func buyTapped_Retrs() {
        guard let gift = gift_Retrs else { return }
        onBuyTapped_Retrs?(gift)
    }
}

// MARK: - 普通礼物 Item（组件2）

/// 普通礼物单元视图（组件2使用）
/// 核心作用：展示单个普通礼物，图片(gift_four)上叠加商品名，下方价格与购买按钮
/// 设计：高度85，背景白色60%透明，圆角20；51x51图片叠加名称 → 价格标签 → Buy按钮
/// 关键属性：onBuyTapped_Retrs（点击Buy时的回调闭包）
class NormalGiftItem_Retrs: UIView {

    // MARK: - 属性

    /// 点击Buy按钮时触发的回调，携带对应礼物模型
    var onBuyTapped_Retrs: ((StoreModel_Retrs) -> Void)?

    /// 绑定的礼物数据
    private var gift_Retrs: StoreModel_Retrs?

    // MARK: - UI 组件

    /// 礼物图标（51×51，gift_four）
    private let iconIV_Retrs: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_four")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 叠加在图片中心的商品名标签（12pt 中等 黑色）
    private let overlayNameLabel_Retrs: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 商品价格标签（14pt 中等 黑色）
    private let priceLabel_Retrs: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()

    /// 购买按钮（64×24，白色背景，文字"Buy"，14pt中等黑色）
    private let buyBtn_Retrs: UIButton = {
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
        buildUI_Retrs()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// 构建内部视图层级与布局约束
    private func buildUI_Retrs() {
        backgroundColor = UIColor(hexstring_Retrs: "#FFFFFF").withAlphaComponent(0.35)
        layer.cornerRadius  = 20
        layer.masksToBounds = true

        addSubview(iconIV_Retrs)
        addSubview(overlayNameLabel_Retrs)
        addSubview(priceLabel_Retrs)
        addSubview(buyBtn_Retrs)

        /// 图片居中横向，顶部内边距4
        iconIV_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(51)
        }

        /// 商品名叠加在图片中心
        overlayNameLabel_Retrs.snp.makeConstraints { make in
            make.center.equalTo(iconIV_Retrs)
            make.leading.greaterThanOrEqualTo(iconIV_Retrs.snp.leading)
            make.trailing.lessThanOrEqualTo(iconIV_Retrs.snp.trailing)
        }

        /// 价格在图片下方2pt
        priceLabel_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconIV_Retrs.snp.bottom).offset(2)
        }

        /// Buy按钮固定在底部内边距4pt
        buyBtn_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-4)
            make.width.equalTo(64)
            make.height.equalTo(24)
        }

        buyBtn_Retrs.addTarget(self, action: #selector(buyTapped_Retrs), for: .touchUpInside)
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: 礼物商品模型
    func configure_Retrs(gift: StoreModel_Retrs) {
        gift_Retrs               = gift
        priceLabel_Retrs.text    = gift.goodsPrice_Retrs ?? ""
        overlayNameLabel_Retrs.text = gift.goodsName_Retrs ?? ""
    }

    // MARK: - 事件

    /// Buy按钮点击，回调携带礼物数据
    @objc private func buyTapped_Retrs() {
        guard let gift = gift_Retrs else { return }
        onBuyTapped_Retrs?(gift)
    }
}
