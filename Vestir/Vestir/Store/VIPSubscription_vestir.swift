import UIKit
import SnapKit

/// 会员订阅页面：展示会员权益、两列套餐卡片、恢复购买及订阅入口。
/// 设计思路：以深紫色背景和居中的价格卡片突出套餐，通过用户视图模型处理选择和交易。
/// 关键属性：套餐卡片响应选择通知，滚动容器保证小屏幕上操作按钮和协议可访问。
class VIPSubscription_Vestir: UIViewController {

    private let userViewModel_vestir = UserViewModel_Vestir.shared_Vestir
    private let navigationBar_vestir = UIView()
    private let backButton_vestir = UIButton(type: .custom)
    private let titleLabel_vestir = UILabel()
    private let scrollView_vestir = UIScrollView()
    private let contentView_vestir = UIView()
    private let benefitsImageView_vestir = UIImageView()
    private let plansStack_vestir = UIStackView()
    private let restoreButton_vestir = UIButton(type: .system)
    private let subscribeButton_vestir = UIButton(type: .custom)
    private var planCards_vestir: [VIPPlanCard_vestir] = []

    /// 加载套餐并构建页面，绑定选择状态通知。
    /// 参数：无；返回值：无（Void）；异常：无。
    override func viewDidLoad() {
        super.viewDidLoad()
        userViewModel_vestir.loadVIPPlans_vestir()
        buildUI_vestir()
        buildPlanCards_vestir()
        bindActions_vestir()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshSelection_vestir),
            name: UserViewModel_Vestir.vipSelectionDidChangeNotification_vestir,
            object: nil
        )
        refreshSelection_vestir()
    }

    /// 页面出现时使用自定义导航栏。
    /// 参数：animated_vestir 表示是否以动画更新；返回值：无（Void）；异常：无。
    override func viewWillAppear(_ animated_vestir: Bool) {
        super.viewWillAppear(animated_vestir)
        navigationController?.setNavigationBarHidden(true, animated: animated_vestir)
    }

    /// 页面从导航栈移除时恢复系统导航栏状态。
    /// 参数：animated_vestir 表示是否以动画更新；返回值：无（Void）；异常：无。
    override func viewWillDisappear(_ animated_vestir: Bool) {
        super.viewWillDisappear(animated_vestir)
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(false, animated: animated_vestir)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 构建深紫色页面、权益图片、套餐网格和白色协议文字。
    /// 参数：无；返回值：无（Void）；异常：资源缺失时图片为空，页面其余内容正常展示。
    private func buildUI_vestir() {
        view.backgroundColor = UIColor(hexstring_Vestir: "#271B39")
        scrollView_vestir.showsVerticalScrollIndicator = false
        scrollView_vestir.alwaysBounceVertical = true
        scrollView_vestir.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView_vestir)
        scrollView_vestir.addSubview(contentView_vestir)

        benefitsImageView_vestir.image = UIImage(named: "vip_top")
        benefitsImageView_vestir.contentMode = .scaleAspectFit
        benefitsImageView_vestir.layer.cornerRadius = 16
        benefitsImageView_vestir.clipsToBounds = true
        contentView_vestir.addSubview(benefitsImageView_vestir)

        plansStack_vestir.axis = .vertical
        plansStack_vestir.spacing = 12
        plansStack_vestir.alignment = .fill
        contentView_vestir.addSubview(plansStack_vestir)

        restoreButton_vestir.setAttributedTitle(NSAttributedString(
            string: "Restore Purchases",
            attributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.white,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor.white
            ]
        ), for: .normal)
        contentView_vestir.addSubview(restoreButton_vestir)

        subscribeButton_vestir.setImage(UIImage(named: "vip_subs"), for: .normal)
        subscribeButton_vestir.imageView?.contentMode = .scaleAspectFit
        subscribeButton_vestir.contentHorizontalAlignment = .fill
        subscribeButton_vestir.contentVerticalAlignment = .fill
        subscribeButton_vestir.accessibilityLabel = "Subscribe"
        contentView_vestir.addSubview(subscribeButton_vestir)

        let protocolLabel_vestir = ProtocolHelper_Vestir.createProtocolTextLabel_Vestir(
            firstProtocol_Vestir: .terms_Vestir,
            firstContent_Vestir: "terms.png",
            secondProtocol_Vestir: .eula_Vestir,
            secondContent_Vestir: "eula.png",
            config_Vestir: ProtocolHelper_Vestir.ProtocolTextConfig_Vestir(
                textColor_Vestir: .white,
                linkColor_Vestir: .white,
                fontSize_Vestir: 13,
                fontWeight_Vestir: .regular,
                hasUnderline_Vestir: true
            ),
            from: self
        )
        contentView_vestir.addSubview(protocolLabel_vestir)

        navigationBar_vestir.backgroundColor = UIColor(hexstring_Vestir: "#271B39")
        view.addSubview(navigationBar_vestir)
        let symbolConfiguration_vestir = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        backButton_vestir.setImage(UIImage(systemName: "chevron.left", withConfiguration: symbolConfiguration_vestir), for: .normal)
        backButton_vestir.tintColor = .white
        backButton_vestir.backgroundColor = UIColor(hexstring_Vestir: "#FFFFFF", alpha_Vestir: 0.2)
        backButton_vestir.layer.cornerRadius = 18
        backButton_vestir.accessibilityLabel = "Back"
        navigationBar_vestir.addSubview(backButton_vestir)
        titleLabel_vestir.text = "Subscription"
        titleLabel_vestir.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel_vestir.textColor = .white
        navigationBar_vestir.addSubview(titleLabel_vestir)

        setupConstraints_vestir(protocolLabel_vestir: protocolLabel_vestir)
    }

    /// 按原商品顺序创建两列套餐卡片，通过事件将选择转发给用户视图模型。
    /// 参数：无；返回值：无（Void）；异常：奇数个套餐时使用透明空位保持列宽一致。
    private func buildPlanCards_vestir() {
        var currentRow_vestir: UIStackView?
        for (index_vestir, plan_vestir) in userViewModel_vestir.vipPlans_vestir.enumerated() {
            if index_vestir.isMultiple(of: 2) {
                let row_vestir = UIStackView()
                row_vestir.axis = .horizontal
                row_vestir.spacing = 30
                row_vestir.distribution = .fillEqually
                plansStack_vestir.addArrangedSubview(row_vestir)
                row_vestir.snp.makeConstraints { make_vestir in
                    make_vestir.height.equalTo(80)
                }
                currentRow_vestir = row_vestir
            }
            let card_vestir = VIPPlanCard_vestir(model_vestir: plan_vestir)
            card_vestir.addAction(UIAction { [weak self] _ in
                self?.userViewModel_vestir.selectVIPPlan_vestir(plan_vestir: plan_vestir)
            }, for: .touchUpInside)
            currentRow_vestir?.addArrangedSubview(card_vestir)
            planCards_vestir.append(card_vestir)
        }
        if currentRow_vestir?.arrangedSubviews.count == 1 {
            currentRow_vestir?.addArrangedSubview(UIView())
        }
    }

    /// 设置自适应图片、两列网格及底部操作区，恢复购买与订阅按钮边缘相距十点。
    /// 参数：protocolLabel_vestir 为带协议链接的文字视图；返回值：无（Void）；异常：无。
    private func setupConstraints_vestir(protocolLabel_vestir: UILabel) {
        navigationBar_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.leading.trailing.equalToSuperview()
            make_vestir.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton_vestir.snp.makeConstraints { make_vestir in
            make_vestir.leading.equalTo(navigationBar_vestir.safeAreaLayoutGuide).offset(16)
            make_vestir.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make_vestir.size.equalTo(36)
        }
        titleLabel_vestir.snp.makeConstraints { make_vestir in
            make_vestir.centerX.equalToSuperview()
            make_vestir.centerY.equalTo(backButton_vestir)
        }
        scrollView_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.equalTo(navigationBar_vestir.snp.bottom)
            make_vestir.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        contentView_vestir.snp.makeConstraints { make_vestir in
            make_vestir.edges.equalTo(scrollView_vestir.contentLayoutGuide)
            make_vestir.width.equalTo(scrollView_vestir.frameLayoutGuide)
        }
        let benefitsRatio_vestir = benefitsImageView_vestir.image.map { image_vestir in
            image_vestir.size.height / image_vestir.size.width
        } ?? 0.75
        benefitsImageView_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.equalToSuperview().offset(16)
            make_vestir.leading.trailing.equalToSuperview().inset(20)
            make_vestir.height.equalTo(benefitsImageView_vestir.snp.width).multipliedBy(benefitsRatio_vestir)
        }
        plansStack_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.equalTo(benefitsImageView_vestir.snp.bottom).offset(20)
            make_vestir.leading.trailing.equalToSuperview().inset(40)
        }
        restoreButton_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.equalTo(plansStack_vestir.snp.bottom).offset(20)
            make_vestir.centerX.equalToSuperview()
            make_vestir.height.equalTo(24)
        }
        let subscribeRatio_vestir = subscribeButton_vestir.image(for: .normal).map { image_vestir in
            image_vestir.size.height / image_vestir.size.width
        } ?? (48.0 / 335.0)
        subscribeButton_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.equalTo(restoreButton_vestir.snp.bottom).offset(10)
            make_vestir.leading.trailing.equalToSuperview().inset(16)
            make_vestir.height.equalTo(subscribeButton_vestir.snp.width).multipliedBy(subscribeRatio_vestir)
        }
        protocolLabel_vestir.snp.makeConstraints { make_vestir in
            make_vestir.top.equalTo(subscribeButton_vestir.snp.bottom).offset(15)
            make_vestir.leading.trailing.equalToSuperview().inset(24)
            make_vestir.bottom.equalToSuperview().offset(-30)
        }
    }

    /// 根据模型中的套餐选择状态刷新卡片样式。
    /// 参数：无；返回值：无（Void）；异常：没有选中套餐时所有卡片为未选中状态。
    @objc private func refreshSelection_vestir() {
        let selectedPlan_vestir = userViewModel_vestir.selectedVIPPlan_vestir
        planCards_vestir.forEach { card_vestir in
            card_vestir.isSelected = card_vestir.model_vestir === selectedPlan_vestir
        }
    }

    /// 将页面按钮事件转发至导航管理器或用户视图模型。
    /// 参数：无；返回值：无（Void）；异常：交易提示由现有商店服务处理。
    private func bindActions_vestir() {
        backButton_vestir.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            Navigation_Vestir.pop_Vestir(from: self)
        }, for: .touchUpInside)
        restoreButton_vestir.addAction(UIAction { [weak self] _ in
            self?.userViewModel_vestir.restoreVIPPurchases_vestir()
        }, for: .touchUpInside)
        subscribeButton_vestir.addAction(UIAction { [weak self] _ in
            self?.userViewModel_vestir.subscribeSelectedVIPPlan_vestir { [weak self] in
                guard let self else { return }
                Navigation_Vestir.pop_Vestir(from: self)
            }
        }, for: .touchUpInside)
    }
}
