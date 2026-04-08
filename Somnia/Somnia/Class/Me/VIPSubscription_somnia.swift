import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：顶部 vip_bg_top 图（屏幕宽 × 45% 高）+ 白色区域 + 图片底部白色阴影过渡
///          组件1-5 全部底部对齐，恢复购买移至导航栏右侧
/// 关键属性：
/// - vipItems_Somnia: 从 Store_Somnia 筛选出 goodIsVIP_Somnia 为 true 的套餐数组
/// - selectedItem_Somnia: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Somnia: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Somnia: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Somnia: [StoreModel_Somnia] = []
    /// 当前选中套餐
    private var selectedItem_Somnia: StoreModel_Somnia?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Somnia: [VIPItemCell_Somnia] = []

    // MARK: - UI · 顶部背景图

    /// vip_bg_top 背景图，宽 = 屏幕宽，高 = 屏幕高 × 0.45
    private let bgTopImage_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_bg_top")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    /// 图片底部白色阴影遮罩（渐变：透明 → 白色，衔接白色区域）
    private let shadowMask_Somnia: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        return v
    }()

    private var shadowGradient_Somnia: CAGradientLayer?

    // MARK: - UI · 自定义导航栏

    private let navBar_Somnia: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Somnia: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Somnia = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Somnia)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .black
        b.backgroundColor = .clear
        return b
    }()

    private let navTitleLabel_Somnia: UILabel = {
        let l = UILabel()
        l.text = "Subscription"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .black
        return l
    }()

    /// 恢复购买按钮（位于导航栏右侧，黑色下划线文字）
    private let restoreButton_Somnia: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Somnia: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.black
        ]
        b.setAttributedTitle(
            NSAttributedString(string: "Restore Purchases", attributes: attrs_Somnia),
            for: .normal
        )
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件1：顶部装饰图 vip_top

    /// vip_top 装饰图（组件1），左右内边距20，高度按比例自适应
    private let vipTopImage_Somnia: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐横向滑动列表

    /// 套餐横向滚动容器，高度 138
    private let itemsScrollView_Somnia: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.clipsToBounds = false
        return sv
    }()

    /// 套餐横向 StackView，间距 12
    private let itemsHStack_Somnia: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .fill
        return sv
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Somnia: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Somnia: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        loadData_Somnia()
        setupUI_Somnia()
        buildItemCells_Somnia()
        setupActions_Somnia()
        // 默认选中第一项
        if let first_Somnia = vipItems_Somnia.first {
            updateSelection_Somnia(model: first_Somnia)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新阴影渐变层尺寸
        shadowGradient_Somnia?.frame = shadowMask_Somnia.bounds
    }

    // MARK: - 数据加载

    /// 从 Store_Somnia 筛选 VIP 套餐
    private func loadData_Somnia() {
        vipItems_Somnia = Store_Somnia.shared_Somnia.goodsList_Somnia.filter { $0.goodIsVIP_Somnia == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Somnia() {
        let screenH_Somnia = UIScreen.main.bounds.height

        // 顶部背景图
        view.addSubview(bgTopImage_Somnia)
        bgTopImage_Somnia.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(screenH_Somnia * 0.45)
        }

        // 图片底部白色渐变遮罩
        view.addSubview(shadowMask_Somnia)
        shadowMask_Somnia.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bgTopImage_Somnia.snp.bottom)
            $0.height.equalTo(72)
        }
        setupShadowGradient_Somnia()

        // 组件1：vip_top 装饰图
        view.addSubview(vipTopImage_Somnia)

        // 组件2：横向套餐列表
        view.addSubview(itemsScrollView_Somnia)
        itemsScrollView_Somnia.addSubview(itemsHStack_Somnia)

        // 组件4：订阅按钮
        view.addSubview(subscribeButton_Somnia)

        // 组件5：协议标签（白色背景用浅色配置）
        let proto_Somnia = ProtocolHelper_Somnia.createProtocolTextLabel_Somnia(
            firstProtocol_Somnia: .terms_Somnia,
            firstContent_Somnia: "terms.png",
            secondProtocol_Somnia: .eula_Somnia,
            secondContent_Somnia: "eula.png",
            config_Somnia: .light_Somnia(),
            from: self
        )
        view.addSubview(proto_Somnia)
        protocolLabel_Somnia = proto_Somnia

        // 导航栏（最顶层）
        view.addSubview(navBar_Somnia)
        navBar_Somnia.addSubview(backButton_Somnia)
        navBar_Somnia.addSubview(navTitleLabel_Somnia)
        navBar_Somnia.addSubview(restoreButton_Somnia)

        setupConstraints_Somnia(protoLabel: proto_Somnia)
    }

    /// 图片底部白色渐变阴影：上方透明 → 下方纯白，平滑衔接白色背景
    private func setupShadowGradient_Somnia() {
        let gl_Somnia = CAGradientLayer()
        gl_Somnia.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.cgColor
        ]
        gl_Somnia.startPoint = CGPoint(x: 0.5, y: 0)
        gl_Somnia.endPoint   = CGPoint(x: 0.5, y: 1)
        shadowMask_Somnia.layer.addSublayer(gl_Somnia)
        shadowGradient_Somnia = gl_Somnia
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Somnia 生成 VIPItemCell_Somnia 并加入横向 StackView
    private func buildItemCells_Somnia() {
        itemCells_Somnia.removeAll()
        // 左侧首项内边距
        let leadingSpacer_Somnia = UIView()
        itemsHStack_Somnia.addArrangedSubview(leadingSpacer_Somnia)
        leadingSpacer_Somnia.snp.makeConstraints { $0.width.equalTo(20) }

        vipItems_Somnia.forEach { model_Somnia in
            let cell_Somnia = VIPItemCell_Somnia()
            cell_Somnia.configure_Somnia(model: model_Somnia)
            cell_Somnia.onTap_Somnia = { [weak self] selected_Somnia in
                self?.updateSelection_Somnia(model: selected_Somnia)
            }
            itemsHStack_Somnia.addArrangedSubview(cell_Somnia)
            cell_Somnia.snp.makeConstraints {
                $0.width.equalTo(100)
                $0.height.equalTo(138)
            }
            itemCells_Somnia.append(cell_Somnia)
        }

        // 右侧末项内边距
        let trailingSpacer_Somnia = UIView()
        itemsHStack_Somnia.addArrangedSubview(trailingSpacer_Somnia)
        trailingSpacer_Somnia.snp.makeConstraints { $0.width.equalTo(20) }
    }

    // MARK: - 约束（组件1/2/4/5 从底部向上对齐）

    private func setupConstraints_Somnia(protoLabel: UILabel) {
        // 导航栏
        navBar_Somnia.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Somnia.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Somnia.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Somnia)
        }
        // 恢复购买移至导航栏右侧
        restoreButton_Somnia.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(backButton_Somnia)
        }

        // 组件5：协议，固定在 safeArea 底部
        protoLabel.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        // 组件4：订阅按钮，在协议上方 12
        subscribeButton_Somnia.snp.makeConstraints {
            $0.bottom.equalTo(protoLabel.snp.top).offset(-12)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件2：横向套餐列表，在订阅按钮上方 20，高度 138
        itemsScrollView_Somnia.snp.makeConstraints {
            $0.bottom.equalTo(subscribeButton_Somnia.snp.top).offset(-20)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(138)
        }
        itemsHStack_Somnia.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }

        // 组件1：vip_top 图，在套餐列表上方 14，左右内边距 20
        let screenW_Somnia = UIScreen.main.bounds.width
        let img_Somnia     = UIImage(named: "vip_top")
        let aspect_Somnia  = img_Somnia.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Somnia: CGFloat = (screenW_Somnia - 40) * aspect_Somnia

        vipTopImage_Somnia.snp.makeConstraints {
            $0.bottom.equalTo(itemsScrollView_Somnia.snp.top).offset(-14)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Somnia)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Somnia(model: StoreModel_Somnia) {
        selectedItem_Somnia = model
        itemCells_Somnia.forEach { cell_Somnia in
            cell_Somnia.setSelected_Somnia(cell_Somnia.model_Somnia?.id_Somnia == model.id_Somnia)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Somnia() {
        backButton_Somnia.addTarget(self, action: #selector(backTapped_Somnia), for: .touchUpInside)
        restoreButton_Somnia.addTarget(self, action: #selector(restoreTapped_Somnia), for: .touchUpInside)
        subscribeButton_Somnia.addTarget(self, action: #selector(subscribeTapped_Somnia), for: .touchUpInside)
    }

    @objc private func backTapped_Somnia() {
        Navigation_Somnia.pop_Somnia(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Somnia() {
        Store_Somnia.shared_Somnia.RestorePurchase_Somnia { [weak self] in
            guard let self_Somnia = self else { return }
            print("恢复购买成功，刷新 VIP 状态")
            _ = self_Somnia
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Somnia() {
        guard let item_Somnia = selectedItem_Somnia,
              let gid_Somnia  = item_Somnia.goodsId_Somnia else {
            Utils_Somnia.showWarning_Somnia(message_Somnia: "Please select a subscription plan.")
            return
        }
        subscribeButton_Somnia.animatePressDown_Somnia { self.subscribeButton_Somnia.animatePressUp_Somnia() }
        Store_Somnia.shared_Somnia.PurchaseStoreVIP_Somnia(vipId_Somnia: gid_Somnia) { [weak self] in
            guard let self_Somnia = self else { return }
            print("VIP 订阅成功，关闭页面")
            Navigation_Somnia.pop_Somnia(from: self_Somnia)
        }
    }
}

// MARK: - VIPItemCell_Somnia

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（数字 + 套餐名 + 价格），支持点击回调
/// 设计思路：圆角12卡片，VStack 排列三行文本；
///          未选中：#FFCDDC 纯色背景；选中：#FFADCF→#9449FF 左上到右下渐变背景
/// 关键方法：
/// - configure_Somnia: 注入套餐数据
/// - setSelected_Somnia: 切换选中态（背景渐变/纯色）
private class VIPItemCell_Somnia: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Somnia: StoreModel_Somnia?

    /// 点击回调，回传选中的套餐模型
    var onTap_Somnia: ((StoreModel_Somnia) -> Void)?

    /// 选中态渐变背景层（复用，避免重复创建）
    private var selectedGradient_Somnia: CAGradientLayer?

    // MARK: - UI

    /// 数字标签（"Months" 套餐显示 3，其余显示 1），字号40加粗黑色
    private let numberLabel_Somnia: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 40, weight: .bold)
        l.textColor     = .black
        l.textAlignment = .center
        return l
    }()

    /// 套餐名，16字号不加粗黑色
    private let nameLabel_Somnia: UILabel = {
        let l = UILabel()
        l.font                         = .systemFont(ofSize: 16, weight: .regular)
        l.textColor                    = .black
        l.textAlignment                = .center
        l.numberOfLines                = 2
        l.adjustsFontSizeToFitWidth    = true
        l.minimumScaleFactor           = 0.7
        return l
    }()

    /// 价格标签，24字号加粗黑色
    private let priceLabel_Somnia: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 24, weight: .bold)
        l.textColor     = .black
        l.textAlignment = .center
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Somnia()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 选中渐变层跟随 bounds 更新
        selectedGradient_Somnia?.frame = bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Somnia() {
        backgroundColor    = UIColor(hexstring_Somnia: "#FFCDDC")
        layer.cornerRadius = 12
        clipsToBounds      = true

        // VStack：数字 → 套餐名 → 价格
        let vStack_Somnia = UIStackView(arrangedSubviews: [
            numberLabel_Somnia,
            nameLabel_Somnia,
            priceLabel_Somnia
        ])
        vStack_Somnia.axis      = .vertical
        vStack_Somnia.alignment = .center
        vStack_Somnia.spacing   = 2
        vStack_Somnia.setCustomSpacing(4, after: nameLabel_Somnia)

        addSubview(vStack_Somnia)
        vStack_Somnia.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(6)
        }

        // 点击手势
        let tap_Somnia = UITapGestureRecognizer(target: self, action: #selector(handleTap_Somnia))
        addGestureRecognizer(tap_Somnia)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据
    /// - Parameter model: VIP 套餐模型（读取 goodsPrice_Somnia 和 goodsName_Somnia）
    /// - 数字规则：goodsName 为 "Months" → 显示 "3"，其余 → 显示 "1"
    func configure_Somnia(model: StoreModel_Somnia) {
        self.model_Somnia      = model
        priceLabel_Somnia.text = model.goodsPrice_Somnia
        nameLabel_Somnia.text  = model.goodsName_Somnia
        numberLabel_Somnia.text = (model.goodsName_Somnia == "Months") ? "3" : "1"
    }

    // MARK: - 选中态切换

    /// 切换选中状态
    /// - Parameter selected: true 为选中（渐变背景），false 为未选中（#FFCDDC 纯色）
    func setSelected_Somnia(_ selected: Bool) {
        if selected {
            // 首次创建渐变层
            if selectedGradient_Somnia == nil {
                let gl_Somnia = CAGradientLayer()
                gl_Somnia.colors = [
                    UIColor(hexstring_Somnia: "#FFADCF").cgColor,
                    UIColor(hexstring_Somnia: "#9449FF").cgColor
                ]
                gl_Somnia.startPoint   = CGPoint(x: 0, y: 0)
                gl_Somnia.endPoint     = CGPoint(x: 1, y: 1)
                gl_Somnia.cornerRadius = 12
                gl_Somnia.frame        = bounds
                layer.insertSublayer(gl_Somnia, at: 0)
                selectedGradient_Somnia = gl_Somnia
            }
            selectedGradient_Somnia?.isHidden = false
            backgroundColor = .clear
        } else {
            selectedGradient_Somnia?.isHidden = true
            backgroundColor = UIColor(hexstring_Somnia: "#FFCDDC")
        }
    }

    // MARK: - 点击处理

    @objc private func handleTap_Somnia() {
        guard let model_Somnia = model_Somnia else { return }
        onTap_Somnia?(model_Somnia)
    }
}
