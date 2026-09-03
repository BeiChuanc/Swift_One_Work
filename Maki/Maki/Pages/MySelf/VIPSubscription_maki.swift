import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐列表，支持套餐选择、发起内购订阅及恢复购买
/// 设计思路：全屏橙色渐变背景（顶部居中 #FA5A00 → 底部居中 #FF9800）+ 顶部 vip_top 装饰图 + 纵向套餐列表 + 底部操作区
/// 关键属性：
/// - vipItems_Maki: 从 Store_Maki 筛选出 goodIsVIP_Maki 为 true 的套餐数组
/// - selectedItem_Maki: 当前选中的 VIP 套餐（发起购买前校验）
/// - itemCells_Maki: 所有套餐 Cell，用于统一切换选中态
class VIPSubscription_Maki: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Maki: [StoreModel_Maki] = []
    /// 当前选中套餐
    private var selectedItem_Maki: StoreModel_Maki?
    /// 所有套餐 Cell 引用（统一更新选中态）
    private var itemCells_Maki: [VIPItemCell_Maki] = []

    // MARK: - UI · 背景渐变

    private var bgGradient_Maki: CAGradientLayer?

    // MARK: - UI · 自定义导航栏

    private let navBar_Maki: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Maki: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Maki = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg_Maki)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Maki: UILabel = {
        let l = UILabel()
        l.text = "Membership"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .black
        return l
    }()

    // MARK: - UI · 滚动容器

    private let scrollView_Maki: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Maki = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图（组件1），紧贴导航栏底部，左右内边距20，完整展示图片内容
    private let vipTopImage_Maki: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐纵向列表

    /// 套餐纵向 StackView，间距14。
    private let itemsVStack_Maki: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 14
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    // MARK: - UI · 组件3：恢复购买

    private let restoreButton_Maki: UIButton = {
        let b = UIButton(type: .system)
        let attrs_Maki: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.black
        ]
        let title_Maki = NSAttributedString(string: "Restore Purchases", attributes: attrs_Maki)
        b.setAttributedTitle(title_Maki, for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 组件4：订阅按钮

    private let subscribeButton_Maki: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub"), for: .normal)
        b.imageView?.contentMode = .scaleAspectFit
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件5：协议标签

    private var protocolLabel_Maki: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Maki()
        setupUI_Maki()
        buildItemCells_Maki()
        setupActions_Maki()
        // 默认选中第一项
        if let first_Maki = vipItems_Maki.first {
            updateSelection_Maki(model: first_Maki)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 只有被 pop 出栈时才恢复导航栏，避免 modal 弹出时错误地改变导航栏状态
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradient_Maki?.frame = view.bounds
    }

    // MARK: - 数据加载

    /// 从 Store_Maki 筛选 VIP 套餐
    private func loadData_Maki() {
        vipItems_Maki = Subscribe_Maki.shared_Maki.goodsList_Maki.filter { $0.goodIsVIP_Maki == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Maki() {
        setupBgGradient_Maki()

        view.addSubview(scrollView_Maki)
        scrollView_Maki.addSubview(contentView_Maki)

        // 组件1
        contentView_Maki.addSubview(vipTopImage_Maki)
        // 组件2：纵向列表
        contentView_Maki.addSubview(itemsVStack_Maki)
        // 组件4
        contentView_Maki.addSubview(subscribeButton_Maki)

        // 组件5：协议标签（terms + eula，黑色文字）
        let proto_Maki = ProtocolHelper_Maki.createProtocolTextLabel_Maki(
            firstProtocol_Maki: .terms_Maki,
            firstContent_Maki: "terms.png",
            secondProtocol_Maki: .eula_Maki,
            secondContent_Maki: "eula.png",
            config_Maki: ProtocolHelper_Maki.ProtocolTextConfig_Maki(
                textColor_Maki: UIColor(hexstring_Maki: "#111111"),
                linkColor_Maki: UIColor(hexstring_Maki: "#111111"),
                fontSize_Maki: 13,
                fontWeight_Maki: .regular,
                hasUnderline_Maki: true
            ),
            from: self
        )
        contentView_Maki.addSubview(proto_Maki)
        protocolLabel_Maki = proto_Maki

        // 导航栏（最顶层）
        view.addSubview(navBar_Maki)
        navBar_Maki.addSubview(backButton_Maki)
        navBar_Maki.addSubview(navTitleLabel_Maki)
        navBar_Maki.addSubview(restoreButton_Maki)

        setupConstraints_Maki(protoLabel: proto_Maki)
    }

    /// 全屏渐变背景：#FA5A00（顶部居中）→ #FF9800（底部居中）。
    /// - 参数：无。
    /// - 返回值：无。
    /// - 异常场景：无。
    private func setupBgGradient_Maki() {
        let gl_Maki = CAGradientLayer()
        gl_Maki.colors = [
            UIColor(hexstring_Maki: "#FA5A00").cgColor,
            UIColor(hexstring_Maki: "#FF9800").cgColor
        ]
        gl_Maki.startPoint = CGPoint(x: 0.5, y: 0.0)
        gl_Maki.endPoint   = CGPoint(x: 0.5, y: 1.0)
        view.layer.insertSublayer(gl_Maki, at: 0)
        bgGradient_Maki = gl_Maki
    }

    // MARK: - 构建套餐 Cell

    /// 遍历 vipItems_Maki 生成 VIPItemCell_Maki 并加入纵向列表
    private func buildItemCells_Maki() {
        itemCells_Maki.removeAll()
        vipItems_Maki.forEach { model_Maki in
            let cell_Maki = VIPItemCell_Maki()
            cell_Maki.configure_Maki(model: model_Maki)
            cell_Maki.onTap_Maki = { [weak self] selected_Maki in
                self?.updateSelection_Maki(model: selected_Maki)
            }
            itemsVStack_Maki.addArrangedSubview(cell_Maki)
            cell_Maki.snp.makeConstraints {
                $0.height.equalTo(56)
            }
            itemCells_Maki.append(cell_Maki)
        }
    }

    // MARK: - 约束

    private func setupConstraints_Maki(protoLabel: UILabel) {
        let screenW_Maki = UIScreen.main.bounds.width
        // 图片宽度 = 屏幕宽 - 左右各20内边距，高度按图片实际比例自适应（scaleAspectFit）
        let imgW_Maki: CGFloat = screenW_Maki - 40
        let img_Maki = UIImage(named: "vip_top")
        let aspect_Maki = img_Maki.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Maki: CGFloat = imgW_Maki * aspect_Maki

        // 导航栏
        navBar_Maki.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Maki.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Maki.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Maki)
        }
        restoreButton_Maki.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalTo(backButton_Maki)
            $0.height.equalTo(22)
        }

        // 滚动容器：顶部从导航栏底部开始，确保内容可正常滚动
        scrollView_Maki.snp.makeConstraints {
            $0.top.equalTo(navBar_Maki.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Maki.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // 组件1：vip_top，左右内边距20，高度按缩小比例展示完整图片
        vipTopImage_Maki.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Maki)
        }

        // 组件2：纵向套餐列表，距 vip_top 下方20，左右内边距10
        itemsVStack_Maki.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Maki.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }

        // 组件4：订阅按钮，距套餐列表下方 20，屏幕宽-32，高 62
        subscribeButton_Maki.snp.makeConstraints {
            $0.top.equalTo(itemsVStack_Maki.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(62)
        }

        // 组件5：协议，距订阅按钮下方 15
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(subscribeButton_Maki.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 选中状态更新

    /// 更新所有 Cell 的选中态，并记录当前选中套餐
    /// - Parameter model: 被选中的套餐模型
    private func updateSelection_Maki(model: StoreModel_Maki) {
        selectedItem_Maki = model
        itemCells_Maki.forEach { cell_Maki in
            cell_Maki.setSelected_Maki(cell_Maki.model_Maki?.id_Maki == model.id_Maki)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Maki() {
        backButton_Maki.addTarget(self, action: #selector(backTapped_Maki), for: .touchUpInside)
        restoreButton_Maki.addTarget(self, action: #selector(restoreTapped_Maki), for: .touchUpInside)
        subscribeButton_Maki.addTarget(self, action: #selector(subscribeTapped_Maki), for: .touchUpInside)
    }

    @objc private func backTapped_Maki() {
        Navigation_Maki.pop_Maki(from: self)
    }

    /// 恢复购买按钮回调
    @objc private func restoreTapped_Maki() {
        Subscribe_Maki.shared_Maki.RestorePurchase_Maki { [weak self] in
            guard let self_Maki = self else { return }
            _ = self_Maki
        }
    }

    /// 订阅按钮回调：发起 VIP 内购
    @objc private func subscribeTapped_Maki() {
        guard let item_Maki = selectedItem_Maki,
              let gid_Maki  = item_Maki.goodsId_Maki else {
            Load_Maki.showWarning_Maki(message_Maki: "Please select a subscription plan.")
            return
        }
        Subscribe_Maki.shared_Maki.PurchaseStoreVIP_Maki(vipId_Maki: gid_Maki) { [weak self] in
            guard let self_Maki = self else { return }
            Navigation_Maki.pop_Maki(from: self_Maki)
        }
    }
}

// MARK: - VIPItemCell_Maki

/// VIP 套餐单元格视图
/// 核心作用：展示单个 VIP 套餐信息（状态圆点 + 套餐名 + 价格），支持点击回调
/// 设计思路：高度56的白色圆角横向卡片，橙色圆点作为状态标识；选中时在圆点内显示白色勾选
/// 关键方法：
/// - configure_Maki: 注入套餐数据（价格 + 套餐名）
/// - setSelected_Maki: 切换选中态（同步圆形内的勾选图标）
private class VIPItemCell_Maki: UIView {

    // MARK: - 属性

    /// 当前套餐数据（外部只读，内部赋值）
    private(set) var model_Maki: StoreModel_Maki?

    /// 点击回调，回传选中的套餐模型
    var onTap_Maki: ((StoreModel_Maki) -> Void)?

    // MARK: - UI

    /// 套餐状态圆形指示器
    private let selectCircle_Maki: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 13
        v.backgroundColor = UIColor(hexstring_Maki: "#FFA11A")
        return v
    }()
    /// 选中勾选图标：仅在当前套餐被选中时展示。
    private let selectCheckImage_maki: UIImageView = {
        let imageView_maki = UIImageView()
        imageView_maki.image = UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysTemplate)
        imageView_maki.tintColor = .white
        imageView_maki.contentMode = .scaleAspectFit
        imageView_maki.isHidden = true
        return imageView_maki
    }()

    /// 价格文本，橙色20pt加粗。
    private let priceLabel_Maki: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 20, weight: .bold)
        l.textColor     = UIColor(hexstring_Maki: "#FFA11A")
        l.textAlignment = .right
        return l
    }()

    /// 套餐名：橙色18pt加粗。
    private let nameLabel_Maki: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 18, weight: .bold)
        l.textColor     = UIColor(hexstring_Maki: "#FFA11A")
        l.textAlignment = .left
        return l
    }()

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI_Maki()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - UI 搭建

    private func setupUI_Maki() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 14
        layer.masksToBounds = true

        addSubview(selectCircle_Maki)
        selectCircle_Maki.addSubview(selectCheckImage_maki)
        addSubview(nameLabel_Maki)
        addSubview(priceLabel_Maki)

        selectCircle_Maki.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(28)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(26)
        }
        selectCheckImage_maki.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(14)
        }
        nameLabel_Maki.snp.makeConstraints {
            $0.leading.equalTo(selectCircle_Maki.snp.trailing).offset(14)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(priceLabel_Maki.snp.leading).offset(-12)
        }
        priceLabel_Maki.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-28)
            $0.centerY.equalToSuperview()
        }

        // 点击手势
        let tap_Maki = UITapGestureRecognizer(target: self, action: #selector(handleTap_Maki))
        addGestureRecognizer(tap_Maki)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据
    /// - Parameter model: VIP 套餐模型（读取 goodsPrice_Maki 和 goodsName_Maki）
    func configure_Maki(model: StoreModel_Maki) {
        self.model_Maki = model
        priceLabel_Maki.text = model.goodsPrice_Maki
        nameLabel_Maki.text = model.goodsName_Maki
    }

    // MARK: - 选中态切换

    /// 切换选中状态：套餐行保持白底橙字，选中时仅显示圆形内的白色勾选。
    /// - Parameter selected: true 为选中态，false 为未选中态
    func setSelected_Maki(_ selected: Bool) {
        selectCheckImage_maki.isHidden = !selected
    }

    // MARK: - 点击处理

    @objc private func handleTap_Maki() {
        guard let model_Maki = model_Maki else { return }
        onTap_Maki?(model_Maki)
    }
}
