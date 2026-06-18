import Foundation
import UIKit
import SnapKit

// MARK: - 渐变圆形视图（内部工具类）

/// 渐变圆形选中背景视图
/// 功能：在 layoutSubviews 中自动同步 CAGradientLayer.frame，避免时序问题
/// 渐变方向：顶部居中 → 底部居中（垂直）
private class GradCircleView_Sylva: UIView {

    private let gradLayer_Sylva = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 20
        clipsToBounds = true
        gradLayer_Sylva.colors = [
            UIColor(hexstring_Sylva: "#3EDD21").cgColor,
            UIColor(hexstring_Sylva: "#009369").cgColor
        ]
        gradLayer_Sylva.startPoint = CGPoint(x: 0.5, y: 0)
        gradLayer_Sylva.endPoint   = CGPoint(x: 0.5, y: 1)
        layer.addSublayer(gradLayer_Sylva)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        // 每次布局时同步渐变层 frame，确保始终正确
        gradLayer_Sylva.frame = bounds
    }
}

// MARK: - 底部导航栏

/// 自定义 TabBar 控制器
/// 核心作用：管理首页/发现/发布/消息/我的五个模块切换
/// 设计思路：白色浮层背景；选中非发布项时居中显示 40×40 绿色渐变圆（#3EDD21→#009369 顶→底）；
///           发布按钮独立样式 54×32；图标均使用 Assets 原图（无 tint）
class TabBar_Sylva: UITabBarController {

    // MARK: - 私有属性

    /// 白色底部背景条
    private let tabBgView_Sylva = UIView()

    /// 图标横向排列容器
    private let tabStackView_Sylva = UIStackView()

    // 选中态渐变圆视图（使用自定义子类，layoutSubviews 中自动同步渐变 frame）
    private let gradHome_Sylva     = GradCircleView_Sylva()
    private let gradDiscover_Sylva = GradCircleView_Sylva()
    private let gradMessage_Sylva  = GradCircleView_Sylva()
    private let gradMe_Sylva       = GradCircleView_Sylva()

    // 各图标 ImageView 引用（选中时切换为白色，取消选中时恢复原图）
    private let iconHome_Sylva     = UIImageView()
    private let iconDiscover_Sylva = UIImageView()
    private let iconMessage_Sylva  = UIImageView()
    private let iconMe_Sylva       = UIImageView()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            Home_Sylva(), Discover_Sylva(), Release_Sylva(), MessageList_Sylva(), Me_Sylva()
        ]
        setupTabBar_Sylva()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    /// 拦截外部对 selectedIndex 的直接修改（如首页头像点击切换到 Me 页），同步更新渐变圆
    override var selectedIndex: Int {
        didSet { updateGradients_Sylva(index: selectedIndex) }
    }

    // MARK: - UI 搭建

    private func setupTabBar_Sylva() {
        // 白色背景条（含顶部阴影，延伸到屏幕最底部覆盖 Home Indicator 区域）
        tabBgView_Sylva.backgroundColor = UIColor(hexstring_Sylva: "#FFFFFF")
        tabBgView_Sylva.layer.shadowColor   = UIColor.black.cgColor
        tabBgView_Sylva.layer.shadowOpacity = 0.08
        tabBgView_Sylva.layer.shadowRadius  = 12
        tabBgView_Sylva.layer.shadowOffset  = CGSize(width: 0, height: -3)
        view.addSubview(tabBgView_Sylva)

        // 图标 StackView（左右各 16pt 内边距，equalSpacing 均匀分布）
        tabStackView_Sylva.axis         = .horizontal
        tabStackView_Sylva.distribution = .equalSpacing
        tabStackView_Sylva.alignment    = .center
        tabBgView_Sylva.addSubview(tabStackView_Sylva)

        // 依次加入五个 Tab 项（传入 iconView 存储引用，便于后续颜色切换）
        tabStackView_Sylva.addArrangedSubview(buildTabItem_Sylva(iconName: "home",     gradView: gradHome_Sylva,     iconView: iconHome_Sylva,     tag: 0))
        tabStackView_Sylva.addArrangedSubview(buildTabItem_Sylva(iconName: "discover", gradView: gradDiscover_Sylva, iconView: iconDiscover_Sylva, tag: 1))
        tabStackView_Sylva.addArrangedSubview(buildPublishItem_Sylva())
        tabStackView_Sylva.addArrangedSubview(buildTabItem_Sylva(iconName: "message",  gradView: gradMessage_Sylva,  iconView: iconMessage_Sylva,  tag: 3))
        tabStackView_Sylva.addArrangedSubview(buildTabItem_Sylva(iconName: "me",       gradView: gradMe_Sylva,       iconView: iconMe_Sylva,       tag: 4))

        // 布局约束
        // tabBgView 底部贴屏幕底部，顶部由 tabStackView 顶部向上 4pt 决定
        tabBgView_Sylva.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(tabStackView_Sylva.snp.top).offset(-4)
        }
        // tabStackView 在 tabBgView 内，左右 16pt，底部距 tabBgView 底部 48pt（适配所有机型 Home Indicator）
        tabStackView_Sylva.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-48)
            make.height.equalTo(54)
        }

        // 初始选中首页
        updateGradients_Sylva(index: 0)
    }

    /// 构建普通 Tab 项容器（渐变圆 + 24×24 原图图标，整体触控区 44×44）
    /// - Parameters:
    ///   - iconName: Assets 中的图片名称
    ///   - gradView: 渐变圆视图（选中时显示）
    ///   - gradLayer: 对应 CAGradientLayer
    ///   - tag: Tab 索引
    private func buildTabItem_Sylva(
        iconName: String,
        gradView: GradCircleView_Sylva,
        iconView: UIImageView,
        tag: Int
    ) -> UIView {
        // GradCircleView_Sylva 已在 init 中配置好渐变，只需设置初始隐藏状态
        gradView.isHidden = true

        // 图标初始使用原图（template 渲染模式支持后续白色切换）
        iconView.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = UIColor(hexstring_Sylva: "#718096")  // 未选中：中灰色
        iconView.contentMode = .scaleAspectFit
        let iconView_sylva = iconView

        // 容器（44×44 触控区域）
        let container_sylva = UIView()
        container_sylva.isUserInteractionEnabled = true
        container_sylva.tag = tag
        container_sylva.addSubview(gradView)
        container_sylva.addSubview(iconView_sylva)

        gradView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(40)
        }
        iconView_sylva.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(24)
        }
        container_sylva.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }

        let tap_sylva = UITapGestureRecognizer(target: self, action: #selector(tabItemTapped_Sylva(_:)))
        container_sylva.addGestureRecognizer(tap_sylva)

        return container_sylva
    }

    /// 构建发布 Tab 项（原图 54×32，无渐变圆，无选中态）
    private func buildPublishItem_Sylva() -> UIView {
        let btn_sylva = UIButton(type: .custom)
        btn_sylva.setImage(UIImage(named: "publish"), for: .normal)
        btn_sylva.imageView?.contentMode = .scaleAspectFit
        btn_sylva.tag = 2
        btn_sylva.addTarget(self, action: #selector(publishTapped_Sylva), for: .touchUpInside)
        btn_sylva.snp.makeConstraints { make in
            make.width.equalTo(54)
            make.height.equalTo(32)
        }
        return btn_sylva
    }

    // MARK: - 选中状态管理

    /// 更新渐变圆显示状态，并同步切换图标颜色（选中：白色；未选中：中灰）
    private func updateGradients_Sylva(index: Int) {
        let selectedColor_sylva   = UIColor.white
        let unselectedColor_sylva = UIColor(hexstring_Sylva: "#718096")

        gradHome_Sylva.isHidden     = (index != 0)
        gradDiscover_Sylva.isHidden = (index != 1)
        gradMessage_Sylva.isHidden  = (index != 3)
        gradMe_Sylva.isHidden       = (index != 4)

        iconHome_Sylva.tintColor     = (index == 0) ? selectedColor_sylva : unselectedColor_sylva
        iconDiscover_Sylva.tintColor = (index == 1) ? selectedColor_sylva : unselectedColor_sylva
        iconMessage_Sylva.tintColor  = (index == 3) ? selectedColor_sylva : unselectedColor_sylva
        iconMe_Sylva.tintColor       = (index == 4) ? selectedColor_sylva : unselectedColor_sylva
    }

    // MARK: - 事件处理

    @objc private func tabItemTapped_Sylva(_ gesture: UITapGestureRecognizer) {
        guard let container_sylva = gesture.view else { return }
        selectedIndex = container_sylva.tag
    }

    @objc private func publishTapped_Sylva() {
        selectedIndex = 2
    }
}
