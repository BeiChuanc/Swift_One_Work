import Foundation
import UIKit
import SnapKit

// MARK: - VIP 订阅页面

/// VIP 订阅页面
/// 核心作用：展示 VIP 套餐两列两行网格，选中套餐后点击全局 vip_sub 订阅按钮发起内购
/// 设计思路：顶部 vip_top_bg 背景图 + vip_top 装饰图 + 两列网格套餐（高88，等宽，艺术斜体字）
///           + vip_sub 订阅按钮（网格下方29）+ 底部协议
/// 关键属性：
///   - vipItems_Bague: 从 Store_Bague 筛选出 goodIsVIP_Bague 为 true 的套餐数组
///   - selectedItem_Bague: 当前选中的套餐
///   - selectedCell_Bague: 当前选中的 Cell 引用（用于边框切换）
class VIPSubscription_Bague: UIViewController {

    // MARK: - 数据

    /// 所有 VIP 套餐
    private var vipItems_Bague: [StoreModel_Bague] = []
    /// 当前选中的套餐
    private var selectedItem_Bague: StoreModel_Bague?
    /// 当前选中 Cell（弱引用，避免循环）
    private weak var selectedCell_Bague: VIPItemCell_Bague?

    // MARK: - UI · 顶部背景图

    /// 顶部背景图（vip_top_bg），宽度等于屏幕宽，高度按图片比例自适应，置于所有内容之下
    private let topBgImageView_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top_bg")?.withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    // MARK: - UI · 自定义导航栏

    private let navBar_Bague: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private let backButton_Bague: UIButton = {
        let b = UIButton(type: .custom)
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        b.setImage(
            UIImage(systemName: "chevron.left", withConfiguration: cfg)?
                .withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        b.tintColor = .white
        b.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        b.layer.cornerRadius = 18
        return b
    }()

    private let navTitleLabel_Bague: UILabel = {
        let l = UILabel()
        l.text = "Membership Subscription"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let restoreButton_Bague: UIButton = {
        let b = UIButton(type: .system)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.black
        ]
        b.setAttributedTitle(NSAttributedString(string: "Restore Purchases", attributes: attrs), for: .normal)
        b.backgroundColor = .clear
        return b
    }()

    // MARK: - UI · 纵向滚动容器

    private let scrollView_Bague: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        return sv
    }()

    private let contentView_Bague = UIView()

    // MARK: - UI · 组件1：顶部装饰图

    /// vip_top 装饰图，左右内边距20，高度按图片比例自适应
    private let vipTopImage_Bague: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "vip_top")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 16
        return iv
    }()

    // MARK: - UI · 组件2：套餐两列网格

    /// 网格外层容器（左右各10内边距）
    private let itemsGrid_Bague = UIView()

    /// 网格纵向 StackView，行间距5
    private let gridVStack_Bague: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 5
        return sv
    }()

    // MARK: - UI · 全局订阅按钮

    /// 全局订阅按钮（vip_sub 图片，宽度屏幕宽-32，高54，位于网格下方29）
    private let subButton_Bague: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "vip_sub")?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.imageView?.contentMode = .scaleAspectFill
        b.clipsToBounds = true
        return b
    }()

    // MARK: - UI · 组件3：协议标签

    private var protocolLabel_Bague: UILabel?

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData_Bague()
        setupUI_Bague()
        buildItemCells_Bague()
        setupActions_Bague()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// 只有被 pop 出栈时才恢复导航栏
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }

    // MARK: - 数据加载

    /// 从 Store_Bague 筛选 goodIsVIP_Bague 为 true 的套餐
    private func loadData_Bague() {
        vipItems_Bague = Store_Bague.shared_Bague.goodsList_Bague.filter { $0.goodIsVIP_Bague == true }
    }

    // MARK: - UI 搭建

    private func setupUI_Bague() {
        view.backgroundColor = .white

        /// 顶部背景图最先加入，置于所有内容之下
        view.addSubview(topBgImageView_Bague)
        view.addSubview(scrollView_Bague)
        scrollView_Bague.addSubview(contentView_Bague)

        /// 组件1
        contentView_Bague.addSubview(vipTopImage_Bague)
        /// 恢复按钮
        contentView_Bague.addSubview(restoreButton_Bague)
        /// 组件2：两列网格
        contentView_Bague.addSubview(itemsGrid_Bague)
        itemsGrid_Bague.addSubview(gridVStack_Bague)
        /// 全局订阅按钮
        contentView_Bague.addSubview(subButton_Bague)

        /// 组件3：协议标签
        let proto = ProtocolHelper_Bague.createProtocolTextLabel_Bague(
            firstProtocol_Bague: .terms_Bague,
            firstContent_Bague: "terms.png",
            secondProtocol_Bague: .eula_Bague,
            secondContent_Bague: "eula.png",
            config_Bague: ProtocolHelper_Bague.ProtocolTextConfig_Bague(
                textColor_Bague: UIColor(hexstring_Bague: "#111111"),
                linkColor_Bague: UIColor(hexstring_Bague: "#111111"),
                fontSize_Bague: 13,
                fontWeight_Bague: .regular,
                hasUnderline_Bague: true
            ),
            from: self
        )
        contentView_Bague.addSubview(proto)
        protocolLabel_Bague = proto

        /// 导航栏最顶层
        view.addSubview(navBar_Bague)
        navBar_Bague.addSubview(backButton_Bague)
        navBar_Bague.addSubview(navTitleLabel_Bague)

        setupConstraints_Bague(protoLabel: proto)
    }

    // MARK: - 构建套餐 Cell

    /// 将 vipItems_Bague 按每行2个排列，构建两列网格
    private func buildItemCells_Bague() {
        gridVStack_Bague.arrangedSubviews.forEach { $0.removeFromSuperview() }

        /// 按每行2个分组
        let chunks_Bague = stride(from: 0, to: vipItems_Bague.count, by: 2).map {
            Array(vipItems_Bague[$0..<min($0 + 2, vipItems_Bague.count)])
        }

        chunks_Bague.forEach { rowItems_Bague in
            let rowStack_Bague = UIStackView()
            rowStack_Bague.axis         = .horizontal
            rowStack_Bague.spacing      = 5
            rowStack_Bague.distribution = .fillEqually
            rowStack_Bague.alignment    = .fill

            rowItems_Bague.enumerated().forEach { colIdx_Bague, model_Bague in
                let isLeft_Bague = colIdx_Bague == 0
                let cell_Bague = VIPItemCell_Bague(isLeft_Bague: isLeft_Bague)
                cell_Bague.configure_Bague(model: model_Bague)
                cell_Bague.onTap_Bague = { [weak self, weak cell_Bague] in
                    guard let self_Bague = self, let cell_Bague = cell_Bague else { return }
                    self_Bague.selectCell_Bague(cell_Bague, model: model_Bague)
                }
                rowStack_Bague.addArrangedSubview(cell_Bague)
            }

            /// 奇数个时末行末列补透明占位保持布局稳定
            if rowItems_Bague.count == 1 {
                let placeholder_Bague = UIView()
                placeholder_Bague.backgroundColor = .clear
                rowStack_Bague.addArrangedSubview(placeholder_Bague)
            }

            gridVStack_Bague.addArrangedSubview(rowStack_Bague)
            rowStack_Bague.snp.makeConstraints { $0.height.equalTo(88) }
        }

        /// 默认选中第一个套餐
        if let firstModel_Bague = vipItems_Bague.first,
           let firstRow_Bague = gridVStack_Bague.arrangedSubviews.first as? UIStackView,
           let firstCell_Bague = firstRow_Bague.arrangedSubviews.first as? VIPItemCell_Bague {
            selectCell_Bague(firstCell_Bague, model: firstModel_Bague)
        }
    }

    /// 更新选中状态：取消旧选中，激活新选中
    /// - Parameters:
    ///   - cell: 新选中的 Cell
    ///   - model: 对应的套餐数据
    private func selectCell_Bague(_ cell: VIPItemCell_Bague, model: StoreModel_Bague) {
        selectedCell_Bague?.setSelected_Bague(false)
        cell.setSelected_Bague(true)
        selectedCell_Bague = cell
        selectedItem_Bague = model
    }

    // MARK: - 约束

    private func setupConstraints_Bague(protoLabel: UILabel) {
        let screenW_Bague = UIScreen.main.bounds.width

        /// vip_top 图片高度按比例自适应
        let imgW_Bague: CGFloat = screenW_Bague - 40
        let img_Bague = UIImage(named: "vip_top")
        let aspect_Bague = img_Bague.map { $0.size.height / $0.size.width } ?? 0.75
        let vipTopH_Bague: CGFloat = imgW_Bague * aspect_Bague

        /// 顶部背景图：全宽，高度按比例
        let bgImg_Bague = UIImage(named: "vip_top_bg")
        let bgAspect_Bague = bgImg_Bague.map { $0.size.height / $0.size.width } ?? 0.5
        let bgH_Bague: CGFloat = screenW_Bague * bgAspect_Bague
        topBgImageView_Bague.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(bgH_Bague)
        }

        /// 导航栏
        navBar_Bague.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_Bague.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.width.height.equalTo(36)
        }
        navTitleLabel_Bague.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton_Bague)
        }

        /// 纵向滚动容器
        scrollView_Bague.snp.makeConstraints {
            $0.top.equalTo(navBar_Bague.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        contentView_Bague.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualTo(scrollView_Bague.snp.height)
        }

        /// 组件1（vip_top）：顶部距 scrollView 内容顶部 10
        vipTopImage_Bague.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(vipTopH_Bague)
        }

        /// 组件2（两列网格）：vip_top 下方 16，左右内边距10
        itemsGrid_Bague.snp.makeConstraints {
            $0.top.equalTo(vipTopImage_Bague.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
        gridVStack_Bague.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        /// 全局订阅按钮：网格下方29，宽度屏幕宽-32，高54
        subButton_Bague.snp.makeConstraints {
            $0.top.equalTo(itemsGrid_Bague.snp.bottom).offset(29)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(screenW_Bague - 32)
            $0.height.equalTo(54)
        }

        /// 恢复购买按钮：订阅按钮下方23，水平居中
        restoreButton_Bague.snp.makeConstraints {
            $0.top.equalTo(subButton_Bague.snp.bottom).offset(23)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(22)
        }

        /// 协议标签：恢复按钮下方30，底部约束到 contentView 底部
        protoLabel.snp.makeConstraints {
            $0.top.equalTo(restoreButton_Bague.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-30)
        }
    }

    // MARK: - 事件绑定

    private func setupActions_Bague() {
        backButton_Bague.addTarget(self, action: #selector(backTapped_Bague), for: .touchUpInside)
        restoreButton_Bague.addTarget(self, action: #selector(restoreTapped_Bague), for: .touchUpInside)
        subButton_Bague.addTarget(self, action: #selector(subTapped_Bague), for: .touchUpInside)
    }

    @objc private func backTapped_Bague() {
        Navigation_Bague.pop_Bague(from: self)
    }

    /// 恢复购买
    @objc private func restoreTapped_Bague() {
        Store_Bague.shared_Bague.RestorePurchase_Bague { [weak self] in
            guard let self_Bague = self else { return }
            _ = self_Bague
        }
    }

    /// 点击全局订阅按钮，对当前选中套餐发起内购
    @objc private func subTapped_Bague() {
        guard let item_Bague = selectedItem_Bague else {
            Utils_Bague.showWarning_Bague(message_Bague: "Please select a plan first.")
            return
        }
        purchaseItem_Bague(model: item_Bague)
    }

    /// 发起指定套餐的 VIP 内购
    /// - Parameter model: 选中的套餐模型
    private func purchaseItem_Bague(model: StoreModel_Bague) {
        guard let gid_Bague = model.goodsId_Bague else {
            Utils_Bague.showWarning_Bague(message_Bague: "Invalid subscription plan.")
            return
        }
        Store_Bague.shared_Bague.PurchaseStoreVIP_Bague(vipId_Bague: gid_Bague) { [weak self] in
            guard let self_Bague = self else { return }
            Navigation_Bague.pop_Bague(from: self_Bague)
        }
    }
}

// MARK: - VIPItemCell_Bague

/// VIP 套餐卡片视图
/// 核心作用：展示单个套餐名称（artFont 25pt）/ Premium Member（白色 12pt）/ 价格（artFont 16pt）
/// 设计思路：渐变背景（#FF136A 顶 → #FF850F 底），艺术斜体字，
///           左列：除右下角外均圆角15；右列：除左下角外均圆角15
///           选中：红色边框2.5；未选中：白色边框1.5
/// 关键属性：
///   - isLeft_Bague: 决定圆角方向
///   - onTap_Bague: 点击回调（由控制器管理选中逻辑）
private class VIPItemCell_Bague: UIView {

    // MARK: - 属性

    private(set) var model_Bague: StoreModel_Bague?
    /// 点击回调，控制器负责更新选中状态
    var onTap_Bague: (() -> Void)?
    private let isLeft_Bague: Bool

    // MARK: - UI

    /// 套餐名称（艺术斜体 Georgia-BoldItalic 25pt 白色）
    private let nameLabel_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "Georgia-BoldItalic", size: 25) ?? UIFont.boldSystemFont(ofSize: 25)
        l.textColor = .white
        l.textAlignment = .left
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        l.numberOfLines = 1
        return l
    }()

    /// "Premium Member" 固定文本（12pt 白色，位于 name 和 price 之间，距上0距下6）
    private let memberLabel_Bague: UILabel = {
        let l = UILabel()
        l.text = "Premium Member"
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .white
        l.textAlignment = .left
        return l
    }()

    /// 套餐价格（艺术斜体 Georgia-BoldItalic 16pt 白色）
    private let priceLabel_Bague: UILabel = {
        let l = UILabel()
        l.font = UIFont(name: "Georgia-BoldItalic", size: 16) ?? UIFont.boldSystemFont(ofSize: 16)
        l.textColor = .white
        l.textAlignment = .left
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        l.numberOfLines = 1
        return l
    }()

    // MARK: - 初始化

    /// - Parameter isLeft_Bague: true = 左列（右下无圆角），false = 右列（左下无圆角）
    init(isLeft_Bague: Bool) {
        self.isLeft_Bague = isLeft_Bague
        super.init(frame: .zero)
        buildUI_Bague()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - 布局

    // MARK: - UI 搭建

    private func buildUI_Bague() {
        layer.cornerRadius = 15
        if isLeft_Bague {
            /// 左列：左上、右上、左下圆角15，右下无圆角
            layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner
            ]
        } else {
            /// 右列：左上、右上、右下圆角15，左下无圆角
            layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMaxXMaxYCorner
            ]
        }
        layer.masksToBounds = true
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.white.cgColor

        /// Cell 背景色：#59B2FF 66%透明度，渐透出页面底层背景
        backgroundColor = UIColor(hexstring_Bague: "#59B2FF").withAlphaComponent(0.66)

        /// VStack：name（间距0）→ member（间距6）→ price，整体垂直居中、左对齐
        let vStack_Bague = UIStackView(arrangedSubviews: [nameLabel_Bague, memberLabel_Bague, priceLabel_Bague])
        vStack_Bague.axis      = .vertical
        vStack_Bague.alignment = .leading
        vStack_Bague.spacing   = 0
        vStack_Bague.setCustomSpacing(0, after: nameLabel_Bague)
        vStack_Bague.setCustomSpacing(6, after: memberLabel_Bague)

        addSubview(vStack_Bague)
        vStack_Bague.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.lessThanOrEqualToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
        }

        /// 点击手势
        let tap_Bague = UITapGestureRecognizer(target: self, action: #selector(cellTapped_Bague))
        addGestureRecognizer(tap_Bague)
        isUserInteractionEnabled = true
    }

    // MARK: - 数据填充

    /// 注入套餐数据，更新名称与价格
    /// - Parameter model: VIP 套餐模型
    func configure_Bague(model: StoreModel_Bague) {
        self.model_Bague  = model
        nameLabel_Bague.text  = model.goodsName_Bague  ?? ""
        priceLabel_Bague.text = model.goodsPrice_Bague ?? ""
    }

    // MARK: - 选中状态

    /// 切换选中边框
    /// - Parameter selected: true = 红色边框2.5，false = 白色边框1.5
    func setSelected_Bague(_ selected: Bool) {
        layer.borderWidth = selected ? 2.5 : 1.5
        layer.borderColor = selected
            ? UIColor.red.cgColor
            : UIColor.white.cgColor
    }

    // MARK: - 点击处理

    @objc private func cellTapped_Bague() {
        animatePressDown_Bague {
            self.animatePressUp_Bague {
                self.onTap_Bague?()
            }
        }
    }
}
