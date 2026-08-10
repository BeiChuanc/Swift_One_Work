import Foundation
import UIKit
import SnapKit

// MARK: - 送礼界面

/// 送礼模态弹起界面
/// 核心作用：底部弹出礼物列表，用户点击各Item内的Buy按钮发起内购
/// 设计思路：
///   - 半透明遮罩 + 底部卡片（仅上方圆角），吸附屏幕底部；
///   - 组件1：goodIsSpecial_Orna=true 的三个限定礼物横向均分（#FDFF70背景，gift_one/two/three）；
///   - 组件2：goodIsSpecial_Orna=false 的普通礼物横向可滚动列表（白色透明背景，gift_four）；
///   - 各Item内置Buy购买按钮，直接触发内购；
///   - 点击遮罩或右上角关闭按钮关闭界面。
/// 关键属性/方法：limitGifts_Orna / normalGifts_Orna / closeButton_Orna / handleBuy_Orna
class GiftPage_Orna: UIViewController {

    // MARK: - 布局常量

    private var screenW_Orna: CGFloat { UIScreen.main.bounds.width }
    private var screenH_Orna: CGFloat { UIScreen.main.bounds.height }
    /// bgCard 高度 = 屏幕高度 × 0.7
    private var bgCardH_Orna: CGFloat { screenH_Orna * 0.5 }
    /// 内容区域左右内边距
    private let contentPadding_Orna: CGFloat = 16
    /// 各礼物Item之间的间距
    private let itemSpacing_Orna: CGFloat = 7

    // MARK: - 数据

    /// goodIsSpecial_Orna=true 的限定礼物，最多取3个，依次对应 gift_one/two/three
    private var limitGifts_Orna: [StoreModel_Orna] = []
    /// goodIsSpecial_Orna=false 的普通礼物，对应 gift_four
    private var normalGifts_Orna: [StoreModel_Orna] = []

    // MARK: - UI 组件

    /// 半透明黑色遮罩，点击可关闭界面
    private let dimView_Orna: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        return v
    }()

    /// 底部背景卡片（仅顶部圆角，吸附屏幕底部）
    private let bgCard_Orna: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    /// gift_bg 装饰背景图（铺满 bgCard）
    private let bgImageView_Orna: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()

    /// 关闭按钮：位于卡片右上角，提供明确的主动关闭入口
    private let closeButton_Orna: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_orna = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_orna), for: .normal)
        b.tintColor = UIColor(hexstring_Orna: "#2D2A3D")
        b.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        b.layer.cornerRadius = 16
        b.layer.shadowColor = UIColor.black.cgColor
        b.layer.shadowOpacity = 0.08
        b.layer.shadowOffset = CGSize(width: 0, height: 2)
        b.layer.shadowRadius = 6
        return b
    }()

    /// 组件1容器：限定礼物横向均分
    private let comp1View_Orna = UIView()

    /// 组件2横向滚动容器：普通礼物横向排列
    private let comp2ScrollView_Orna: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        return sv
    }()

    /// 组件2内容视图（承载所有普通礼物Item）
    private let comp2ContentView_Orna = UIView()

    /// bgCard 高度约束引用，用于适配安全区
    private var bgCardHeightConstraint_Orna: Constraint?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        loadGiftData_Orna()
        buildLayout_Orna()
        buildComp1_Orna()
        buildComp2_Orna()
        setupConstraints_Orna()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        /// 屏幕方向变化时同步更新卡片高度
        bgCardHeightConstraint_Orna?.update(offset: bgCardH_Orna)
    }

    // MARK: - 数据加载

    /// 区分限定礼物（goodIsSpecial_Orna=true）与普通礼物（goodIsSpecial_Orna=false）
    private func loadGiftData_Orna() {
        let all_Orna = Store_Orna.shared_Orna.goodsList_Orna
            .filter { !($0.goodIsVIP_Orna ?? false) }
        limitGifts_Orna  = Array(all_Orna.filter { $0.goodIsSpecial_Orna ?? false }.prefix(3))
        normalGifts_Orna = all_Orna.filter { !($0.goodIsSpecial_Orna ?? false) }
    }

    // MARK: - 基础视图层级

    /// 搭建遮罩与底部卡片的基础视图层级
    private func buildLayout_Orna() {
        view.addSubview(dimView_Orna)
        let dimTap_Orna = UITapGestureRecognizer(target: self, action: #selector(dimTapped_Orna))
        dimView_Orna.addGestureRecognizer(dimTap_Orna)

        view.addSubview(bgCard_Orna)
        bgCard_Orna.addSubview(bgImageView_Orna)
        bgCard_Orna.addSubview(comp1View_Orna)
        bgCard_Orna.addSubview(comp2ScrollView_Orna)
        bgCard_Orna.addSubview(closeButton_Orna)
        comp2ScrollView_Orna.addSubview(comp2ContentView_Orna)
        closeButton_Orna.addTarget(self, action: #selector(closeTapped_Orna), for: .touchUpInside)
    }

    // MARK: - 组件1：限定礼物横向均分

    /// 构建组件1：三个限定礼物Item横向均分展示
    /// 图标顺序：gift_one → gift_two → gift_three
    private func buildComp1_Orna() {
        let iconNames_Orna = ["gift_one", "gift_two", "gift_three"]
        var itemViews_Orna: [UIView] = []

        for (idx_Orna, gift_Orna) in limitGifts_Orna.enumerated() {
            let iconName_Orna = idx_Orna < iconNames_Orna.count
                ? iconNames_Orna[idx_Orna] : "gift_one"
            let item_Orna = LimitGiftItem_Orna(iconName: iconName_Orna)
            item_Orna.configure_Orna(gift: gift_Orna)
            item_Orna.onBuyTapped_Orna = { [weak self] gift in
                self?.handleBuy_Orna(gift: gift)
            }
            itemViews_Orna.append(item_Orna)
        }

        let stack_Orna = UIStackView(arrangedSubviews: itemViews_Orna)
        stack_Orna.axis         = .horizontal
        stack_Orna.spacing      = itemSpacing_Orna
        stack_Orna.distribution = .fillEqually
        stack_Orna.alignment    = .fill

        comp1View_Orna.addSubview(stack_Orna)
        stack_Orna.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 组件2：普通礼物横向滚动

    /// 构建组件2：普通礼物横向排列，约4个可见，可横向滚动
    /// 图标统一使用 gift_four
    private func buildComp2_Orna() {
        /// 约4个Item可见的单Item宽度
        let itemW_Orna = (screenW_Orna - 2 * contentPadding_Orna - 3 * itemSpacing_Orna) / 4
        var prevView_Orna: UIView? = nil

        for gift_Orna in normalGifts_Orna {
            let item_Orna = NormalGiftItem_Orna()
            item_Orna.configure_Orna(gift: gift_Orna)
            item_Orna.onBuyTapped_Orna = { [weak self] gift in
                self?.handleBuy_Orna(gift: gift)
            }
            comp2ContentView_Orna.addSubview(item_Orna)
            item_Orna.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(itemW_Orna)
                if let prev_Orna = prevView_Orna {
                    make.leading.equalTo(prev_Orna.snp.trailing).offset(itemSpacing_Orna)
                } else {
                    make.leading.equalToSuperview()
                }
            }
            prevView_Orna = item_Orna
        }

        /// 末尾Item的 trailing 决定 ScrollView 的 contentSize
        if let last_Orna = prevView_Orna {
            last_Orna.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
            }
        }
    }

    // MARK: - 约束布局

    /// 设置所有 SnapKit 约束，bgCard 吸附屏幕底部，高度为屏幕高度的 0.7
    /// 内容区从 bgCard 底部往上30pt对齐（bottom-up布局）
    private func setupConstraints_Orna() {
        dimView_Orna.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bgCard_Orna.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            bgCardHeightConstraint_Orna = make.height.equalTo(bgCardH_Orna).constraint
        }

        bgImageView_Orna.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        closeButton_Orna.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(18)
            make.trailing.equalToSuperview().offset(-18)
            make.width.height.equalTo(32)
        }

        /// 组件2：bottom 距 bgCard 安全区底部 30pt，高度105容纳图片+价格+按钮
        comp2ScrollView_Orna.snp.makeConstraints { make in
            make.bottom.equalTo(bgCard_Orna.safeAreaLayoutGuide.snp.bottom)
            make.leading.equalToSuperview().offset(contentPadding_Orna)
            make.trailing.equalToSuperview().offset(-contentPadding_Orna)
            make.height.equalTo(105)
        }

        /// 组件1：紧靠组件2上方12pt，高度160（容纳69图片+价格+按钮+内边距）
        comp1View_Orna.snp.makeConstraints { make in
            make.bottom.equalTo(comp2ScrollView_Orna.snp.top).offset(-12)
            make.leading.equalToSuperview().offset(contentPadding_Orna)
            make.trailing.equalToSuperview().offset(-contentPadding_Orna)
            make.height.equalTo(160)
        }

        /// comp2ContentView 高度与 ScrollView 一致，宽度由内部Item决定
        comp2ContentView_Orna.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(105)
        }
    }

    // MARK: - 事件处理

    /// 点击遮罩关闭界面
    @objc private func dimTapped_Orna() {
        dismiss(animated: true)
    }

    /// 点击关闭按钮关闭界面
    /// 功能：响应右上角关闭按钮点击，关闭当前送礼弹层
    /// 参数：无
    /// 返回值：无
    /// 异常场景：当前页面未被模态展示时 dismiss 不产生额外效果
    @objc private func closeTapped_Orna() {
        dismiss(animated: true)
    }

    /// 统一处理礼物购买逻辑
    /// - Parameter gift: 用户点击Buy的礼物模型
    private func handleBuy_Orna(gift: StoreModel_Orna) {
        guard let gid_Orna = gift.goodsId_Orna else {
            Load_Orna.showWarning_Orna(message_Orna: "Gift information is invalid")
            return
        }
        Store_Orna.shared_Orna.PurchaseStoreGift_Orna(gid_Orna: gid_Orna) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - 限定礼物 Item（组件1）

/// 限定礼物单元视图（组件1使用）
/// 核心作用：展示单个限定礼物，包含装饰图片、价格与购买按钮，右上角显示商品名称
/// 设计：高度137，背景#FDFF70，圆角20；内部居中竖向：69x69图片 → 价格标签 → Buy按钮；右上角商品名
/// 关键属性：onBuyTapped_Orna（点击Buy时的回调闭包）
class LimitGiftItem_Orna: UIView {

    // MARK: - 属性

    /// 点击Buy按钮时触发的回调，携带对应礼物模型
    var onBuyTapped_Orna: ((StoreModel_Orna) -> Void)?

    /// 绑定的礼物数据
    private var gift_Orna: StoreModel_Orna?

    // MARK: - UI 组件

    /// 礼物装饰图（69×69）
    private let iconIV_Orna: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 商品价格标签（16pt 中等 黑色）
    private let priceLabel_Orna: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 16, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()

    /// 购买按钮（86×24，背景#C197FC，文字"Buy"，14pt中等黑色）
    private let buyBtn_Orna: UIButton = {
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
    private let nameLabel_Orna: UILabel = {
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
        iconIV_Orna.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        buildUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// 构建内部视图层级与布局约束
    private func buildUI_Orna() {
        backgroundColor = UIColor(hexstring_Orna: "#FFFFFF").withAlphaComponent(0.35)
        layer.cornerRadius  = 20
        layer.masksToBounds = true

        addSubview(iconIV_Orna)
        addSubview(priceLabel_Orna)
        addSubview(buyBtn_Orna)
        addSubview(nameLabel_Orna)

        /// 图片居中于顶部区域
        iconIV_Orna.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(16)
            make.width.height.equalTo(69)
        }

        /// 价格在图片下方6pt
        priceLabel_Orna.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconIV_Orna.snp.bottom).offset(6)
        }

        /// 购买按钮在价格下方6pt，宽86高24
        buyBtn_Orna.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(priceLabel_Orna.snp.bottom).offset(6)
            make.width.equalTo(86)
            make.height.equalTo(24)
        }

        /// 商品名显示在右上角
        nameLabel_Orna.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
        }

        buyBtn_Orna.addTarget(self, action: #selector(buyTapped_Orna), for: .touchUpInside)
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: 礼物商品模型
    func configure_Orna(gift: StoreModel_Orna) {
        gift_Orna          = gift
        priceLabel_Orna.text = gift.goodsPrice_Orna ?? ""
        nameLabel_Orna.text  = gift.goodsName_Orna  ?? ""
    }

    // MARK: - 事件

    /// Buy按钮点击，回调携带礼物数据
    @objc private func buyTapped_Orna() {
        guard let gift = gift_Orna else { return }
        onBuyTapped_Orna?(gift)
    }
}

// MARK: - 普通礼物 Item（组件2）

/// 普通礼物单元视图（组件2使用）
/// 核心作用：展示单个普通礼物，图片(gift_four)上叠加商品名，下方价格与购买按钮
/// 设计：高度85，背景白色60%透明，圆角20；51x51图片叠加名称 → 价格标签 → Buy按钮
/// 关键属性：onBuyTapped_Orna（点击Buy时的回调闭包）
class NormalGiftItem_Orna: UIView {

    // MARK: - 属性

    /// 点击Buy按钮时触发的回调，携带对应礼物模型
    var onBuyTapped_Orna: ((StoreModel_Orna) -> Void)?

    /// 绑定的礼物数据
    private var gift_Orna: StoreModel_Orna?

    // MARK: - UI 组件

    /// 礼物图标（51×51，gift_four）
    private let iconIV_Orna: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "gift_four")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    /// 叠加在图片中心的商品名标签（12pt 中等 黑色）
    private let overlayNameLabel_Orna: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 12, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    /// 商品价格标签（14pt 中等 黑色）
    private let priceLabel_Orna: UILabel = {
        let l = UILabel()
        l.font      = UIFont.systemFont(ofSize: 14, weight: .medium)
        l.textColor = .black
        l.textAlignment = .center
        return l
    }()

    /// 购买按钮（64×24，白色背景，文字"Buy"，14pt中等黑色）
    private let buyBtn_Orna: UIButton = {
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
        buildUI_Orna()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    /// 构建内部视图层级与布局约束
    private func buildUI_Orna() {
        backgroundColor = UIColor(hexstring_Orna: "#FFFFFF").withAlphaComponent(0.35)
        layer.cornerRadius  = 20
        layer.masksToBounds = true

        addSubview(iconIV_Orna)
        addSubview(overlayNameLabel_Orna)
        addSubview(priceLabel_Orna)
        addSubview(buyBtn_Orna)

        /// 图片居中横向，顶部内边距4
        iconIV_Orna.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(4)
            make.width.height.equalTo(51)
        }

        /// 商品名叠加在图片中心
        overlayNameLabel_Orna.snp.makeConstraints { make in
            make.center.equalTo(iconIV_Orna)
            make.leading.greaterThanOrEqualTo(iconIV_Orna.snp.leading)
            make.trailing.lessThanOrEqualTo(iconIV_Orna.snp.trailing)
        }

        /// 价格在图片下方2pt
        priceLabel_Orna.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconIV_Orna.snp.bottom).offset(2)
        }

        /// Buy按钮固定在底部内边距4pt
        buyBtn_Orna.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-4)
            make.width.equalTo(64)
            make.height.equalTo(24)
        }

        buyBtn_Orna.addTarget(self, action: #selector(buyTapped_Orna), for: .touchUpInside)
    }

    // MARK: - 数据配置

    /// 绑定礼物数据到视图
    /// - Parameter gift: 礼物商品模型
    func configure_Orna(gift: StoreModel_Orna) {
        gift_Orna               = gift
        priceLabel_Orna.text    = gift.goodsPrice_Orna ?? ""
        overlayNameLabel_Orna.text = gift.goodsName_Orna ?? ""
    }

    // MARK: - 事件

    /// Buy按钮点击，回调携带礼物数据
    @objc private func buyTapped_Orna() {
        guard let gift = gift_Orna else { return }
        onBuyTapped_Orna?(gift)
    }
}
