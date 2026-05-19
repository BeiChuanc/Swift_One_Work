import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
/// 核心作用：自定义 TabBar，渐变胶囊背景 + 心形选中指示器 + 原图图标
/// 设计思路：
///   - tabBgView 使用 #FFA100→#E55C45 竖向渐变，胶囊圆角
///   - 非发布页选中时，图标后方叠加 34×29 心形（#FFFFFD 30% 透明度）
///   - 发布图标 40×40，其余图标 24×24，均使用 Assets 原图
class TabBar_Lumia: UITabBarController {

    // MARK: - 私有属性

    private let tabBgView_Lumia = UIView()
    private var gradientLayer_Lumia: CAGradientLayer?

    private let tabStackView_Lumia: UIStackView = {
        let sv_Lumia = UIStackView()
        sv_Lumia.axis = .horizontal
        sv_Lumia.distribution = .equalSpacing
        sv_Lumia.alignment = .center
        sv_Lumia.spacing = 0
        return sv_Lumia
    }()

    /// 非发布 Tab 项（带心形指示器）
    private lazy var itemHome_Lumia = TabItemView_Lumia(iconName: "home", size: 24)
    private lazy var itemDiscover_Lumia = TabItemView_Lumia(iconName: "discover", size: 24)
    private lazy var itemMessage_Lumia = TabItemView_Lumia(iconName: "message", size: 24)
    private lazy var itemMe_Lumia = TabItemView_Lumia(iconName: "me", size: 24)

    /// 发布按钮（无心形指示器）
    private let btnPublish_Lumia: UIButton = {
        let btn_Lumia = UIButton(type: .custom)
        btn_Lumia.setImage(UIImage(named: "publish")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn_Lumia.tag = 2
        return btn_Lumia
    }()

    private var currentIndex_Lumia: Int = 0

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [Home_Lumia(), Discover_Lumia(), Release_Lumia(), MessageList_Lumia(), Me_Lumia()]
        setupUI_Lumia()
        setupConstraints_Lumia()
        updateSelection_Lumia(index: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 渐变图层在布局完成后更新 frame
        gradientLayer_Lumia?.frame = tabBgView_Lumia.bounds
    }

    // MARK: - UI设置

    private func setupUI_Lumia() {
        // 渐变背景（顶部居中→底部居中：FFA100→E55C45）
        tabBgView_Lumia.layer.masksToBounds = true
        view.addSubview(tabBgView_Lumia)

        let grad_Lumia = CAGradientLayer()
        grad_Lumia.colors = [
            UIColor(hexstring_Lumia: "#FFA100").cgColor,
            UIColor(hexstring_Lumia: "#E55C45").cgColor
        ]
        grad_Lumia.startPoint = CGPoint(x: 0.5, y: 0)
        grad_Lumia.endPoint = CGPoint(x: 0.5, y: 1)
        tabBgView_Lumia.layer.insertSublayer(grad_Lumia, at: 0)
        gradientLayer_Lumia = grad_Lumia

        // StackView
        view.addSubview(tabStackView_Lumia)

        // 各 Tab 项加入 StackView
        [itemHome_Lumia, itemDiscover_Lumia, btnPublish_Lumia, itemMessage_Lumia, itemMe_Lumia].forEach {
            if let item_Lumia = $0 as? UIView {
                tabStackView_Lumia.addArrangedSubview(item_Lumia)
            }
        }

        // 回调绑定
        itemHome_Lumia.onTapped_Lumia = { [weak self] in self?.switchTo_Lumia(index: 0) }
        itemDiscover_Lumia.onTapped_Lumia = { [weak self] in self?.switchTo_Lumia(index: 1) }
        btnPublish_Lumia.addTarget(self, action: #selector(handlePublish_Lumia), for: .touchUpInside)
        itemMessage_Lumia.onTapped_Lumia = { [weak self] in self?.switchTo_Lumia(index: 3) }
        itemMe_Lumia.onTapped_Lumia = { [weak self] in self?.switchTo_Lumia(index: 4) }
    }

    private func setupConstraints_Lumia() {
        tabStackView_Lumia.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }

        // 非发布项：容器 44×44（图标 24 + 心形留白）
        [itemHome_Lumia, itemDiscover_Lumia, itemMessage_Lumia, itemMe_Lumia].forEach { item in
            item.snp.makeConstraints { make in make.width.height.equalTo(44) }
        }

        // 发布按钮：40×40
        btnPublish_Lumia.snp.makeConstraints { make in make.width.height.equalTo(40) }

        // 渐变胶囊背景：StackView 上下各 +15
        tabBgView_Lumia.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Lumia)
            make.top.equalTo(tabStackView_Lumia).offset(-15)
            make.bottom.equalTo(tabStackView_Lumia).offset(15)
        }

        // 圆角 = 高度 / 2（StackView 50 + 上下 30 = 80, 半径 40）
        tabBgView_Lumia.layoutIfNeeded()
        tabBgView_Lumia.layer.cornerRadius = (50 + 30) / 2.0
    }

    // MARK: - 切换逻辑

    private func switchTo_Lumia(index: Int) {
        currentIndex_Lumia = index
        selectedIndex = index
        updateSelection_Lumia(index: index)
    }

    /// 更新各 Tab 项的选中状态
    private func updateSelection_Lumia(index: Int) {
        itemHome_Lumia.isSelected_Lumia = (index == 0)
        itemDiscover_Lumia.isSelected_Lumia = (index == 1)
        itemMessage_Lumia.isSelected_Lumia = (index == 3)
        itemMe_Lumia.isSelected_Lumia = (index == 4)
    }

    @objc private func handlePublish_Lumia() {
        switchTo_Lumia(index: 2)
    }
}

// MARK: - Tab 项视图（含心形选中指示器）

/// 单个 Tab 按钮容器
/// 核心作用：背景层为心形指示器，前景层为原图图标，选中时显示心形
private class TabItemView_Lumia: UIView {

    var onTapped_Lumia: (() -> Void)?

    var isSelected_Lumia: Bool = false {
        didSet { heartIndicator_Lumia.isHidden = !isSelected_Lumia }
    }

    private let heartIndicator_Lumia = TabHeartIndicator_Lumia()
    private let iconView_Lumia = UIImageView()

    /// 初始化
    /// - Parameters:
    ///   - iconName: Assets 中的图标名称
    ///   - size: 图标边长（pt）
    init(iconName: String, size: CGFloat) {
        super.init(frame: .zero)

        // 心形背景（层级低于图标）
        heartIndicator_Lumia.isHidden = true
        addSubview(heartIndicator_Lumia)
        heartIndicator_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(35)
        }

        // 原图图标（层级高于心形）
        iconView_Lumia.image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
        iconView_Lumia.contentMode = .scaleAspectFit
        addSubview(iconView_Lumia)
        iconView_Lumia.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(size)
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap_Lumia)))
        isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    @objc private func handleTap_Lumia() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onTapped_Lumia?()
    }
}

// MARK: - 心形选中指示器

/// 心形背景指示器
/// 核心作用：在选中的 Tab 图标后方绘制心形，颜色 #FFFFFD 透明度 30%，尺寸 34×29
private class TabHeartIndicator_Lumia: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        guard let ctx_Lumia = UIGraphicsGetCurrentContext() else { return }
        let color_Lumia = UIColor(hexstring_Lumia: "#FFFFFD").withAlphaComponent(0.30)
        ctx_Lumia.setFillColor(color_Lumia.cgColor)
        let path_Lumia = makeHeartPath_Lumia(in: rect)
        ctx_Lumia.addPath(path_Lumia.cgPath)
        ctx_Lumia.fillPath()
    }

    /// 在指定矩形内构建心形贝塞尔路径
    private func makeHeartPath_Lumia(in rect: CGRect) -> UIBezierPath {
        let w_Lumia = rect.width
        let h_Lumia = rect.height
        let path_Lumia = UIBezierPath()

        // 从顶部中心凹口出发
        path_Lumia.move(to: CGPoint(x: w_Lumia / 2, y: h_Lumia * 0.27))

        // 右上弧→右侧最宽
        path_Lumia.addCurve(
            to: CGPoint(x: w_Lumia, y: h_Lumia * 0.40),
            controlPoint1: CGPoint(x: w_Lumia * 0.65, y: h_Lumia * 0.03),
            controlPoint2: CGPoint(x: w_Lumia, y: h_Lumia * 0.15)
        )
        // 右侧→底部尖端
        path_Lumia.addCurve(
            to: CGPoint(x: w_Lumia / 2, y: h_Lumia),
            controlPoint1: CGPoint(x: w_Lumia, y: h_Lumia * 0.68),
            controlPoint2: CGPoint(x: w_Lumia * 0.78, y: h_Lumia * 0.86)
        )
        // 底部尖端→左侧最宽
        path_Lumia.addCurve(
            to: CGPoint(x: 0, y: h_Lumia * 0.40),
            controlPoint1: CGPoint(x: w_Lumia * 0.22, y: h_Lumia * 0.86),
            controlPoint2: CGPoint(x: 0, y: h_Lumia * 0.68)
        )
        // 左侧→顶部中心凹口
        path_Lumia.addCurve(
            to: CGPoint(x: w_Lumia / 2, y: h_Lumia * 0.27),
            controlPoint1: CGPoint(x: 0, y: h_Lumia * 0.15),
            controlPoint2: CGPoint(x: w_Lumia * 0.35, y: h_Lumia * 0.03)
        )
        path_Lumia.close()
        return path_Lumia
    }
}
