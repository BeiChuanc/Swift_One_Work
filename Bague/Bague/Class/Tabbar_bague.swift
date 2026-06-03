import Foundation
import UIKit
import SnapKit

// MARK: - 底部导航控制器

/// 底部导航页面
/// 核心作用：自定义 TabBar，使用渐变拱桥形背景，选中非发布页时图标后方居中显示圆形高亮
/// 设计思路：
///   - 隐藏系统 tabBar，通过自定义视图实现完全自定义样式
///   - 拱桥形通过 CAShapeLayer 遮罩实现（贝塞尔曲线），顶部中央凸起弧形
///   - 圆形高亮放在 view 层级上（tabBgView 上方、StackView 下方），避免遮罩裁剪
///   - 圆形位置通过坐标系转换在 viewDidLayoutSubviews 中精准对齐按钮中心
/// 关键属性：tabBgView_Bague（渐变背景）、selectedCircleBg_Bague（选中圆圈）、gradientLayer_Bague（渐变图层）
class TabBar_Bague: UITabBarController {

    /// 拱桥形渐变背景视图（紧贴屏幕左右底部）
    private var tabBgView_Bague = UIView()

    /// 渐变图层：A052F3 -> 2DAEFA，垂直方向（顶部居中到底部居中）
    private var gradientLayer_Bague = CAGradientLayer()

    /// 按钮容器栈视图
    private var tabStackView_Bague = UIStackView()

    /// 选中高亮圆形背景视图，颜色 #6900FF，大小 34x34
    /// 位于 tabBgView 上层、tabStackView 下层，发布页选中时隐藏
    private var selectedCircleBg_Bague = UIView()

    /// 首页按钮
    private var btnHome_Bague = UIButton(type: .custom)

    /// 发现页按钮
    private var btnDiscover_Bague = UIButton(type: .custom)

    /// 发布按钮
    private var btnRelease_Bague = UIButton(type: .custom)

    /// 消息按钮
    private var btnMessage_Bague = UIButton(type: .custom)

    /// 我的按钮
    private var btnMe_Bague = UIButton(type: .custom)

    /// 当前选中索引，默认首页（0）
    private var currentIndex_Bague: Int = 0

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            Home_Bague(),
            Discover_Bague(),
            Release_Bague(),
            MessageList_Bague(),
            Me_Bague()
        ]
        setupUI_Bague()
        setupConstraints_Bague()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 同步渐变图层尺寸（布局改变时同步）
        gradientLayer_Bague.frame = tabBgView_Bague.bounds
        // 应用拱桥形遮罩（每次布局后重绘路径）
        applyArchBridgeMask_Bague()
        // 同步圆形高亮位置
        updateCircleBgPosition_Bague()
    }

    // MARK: - UI 配置

    /// 初始化所有 UI 元素及子视图层级
    private func setupUI_Bague() {
        setupTabBgView_Bague()
        // 圆形高亮插入在背景视图与按钮之间，保证图标可见在圆圈前方
        setupSelectedCircleBg_Bague()
        setupStackView_Bague()
        setupButtons_Bague()
        // 默认首页选中
        btnHome_Bague.isSelected = true
    }

    /// 配置渐变背景视图（拱桥形遮罩在 viewDidLayoutSubviews 中动态应用）
    private func setupTabBgView_Bague() {
        // 渐变图层：顶部居中(0.5, 0) -> 底部居中(0.5, 1)，垂直方向
        gradientLayer_Bague.colors = [
            UIColor(hexstring_Bague: "#A052F3").cgColor,
            UIColor(hexstring_Bague: "#2DAEFA").cgColor
        ]
        gradientLayer_Bague.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer_Bague.endPoint   = CGPoint(x: 0.5, y: 1)
        tabBgView_Bague.layer.addSublayer(gradientLayer_Bague)
        view.addSubview(tabBgView_Bague)
    }

    /// 使用 CAShapeLayer 贝塞尔路径应用拱桥形遮罩
    /// 路径描述：底部直角贴边，顶部中央凸起弧形（上凸拱桥）
    /// - 两侧竖边垂直，顶部通过三次贝塞尔曲线形成中央凸起弧形
    private func applyArchBridgeMask_Bague() {
        let bounds = tabBgView_Bague.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        // 拱桥参数：两侧顶点距视图顶部的偏移量（决定拱桥底脚高度）
        let archBase: CGFloat = 22
        // 拱桥顶点（中央最高点）位于视图顶部，y = 0

        let path = UIBezierPath()
        // 从左下角出发
        path.move(to: CGPoint(x: 0, y: bounds.height))
        // 左侧竖边到左侧拱脚
        path.addLine(to: CGPoint(x: 0, y: archBase))
        // 三次贝塞尔曲线：左拱脚 -> 右拱脚，控制点使顶部向上凸起（拱桥弧）
        path.addCurve(
            to: CGPoint(x: bounds.width, y: archBase),
            controlPoint1: CGPoint(x: bounds.width * 0.25, y: 0),
            controlPoint2: CGPoint(x: bounds.width * 0.75, y: 0)
        )
        // 右侧竖边到右下角
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        path.close()

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        tabBgView_Bague.layer.mask = maskLayer
    }

    /// 配置选中高亮圆形背景视图（直接添加到 view，避免被 tabBgView 遮罩裁剪）
    private func setupSelectedCircleBg_Bague() {
        selectedCircleBg_Bague.backgroundColor = UIColor(hexstring_Bague: "#6900FF")
        // 34x34 圆形，cornerRadius = 17
        selectedCircleBg_Bague.layer.cornerRadius = 17
        selectedCircleBg_Bague.layer.masksToBounds = true
        selectedCircleBg_Bague.isHidden = true
        // 插入在 tabBgView 上方，StackView 下方
        view.insertSubview(selectedCircleBg_Bague, aboveSubview: tabBgView_Bague)
    }

    /// 配置按钮容器 StackView
    private func setupStackView_Bague() {
        tabStackView_Bague.axis = .horizontal
        tabStackView_Bague.distribution = .equalSpacing
        tabStackView_Bague.alignment = .center
        tabStackView_Bague.spacing = 0
        view.addSubview(tabStackView_Bague)
    }

    /// 配置所有 Tab 按钮（均使用 .alwaysOriginal 保持原图颜色）
    private func setupButtons_Bague() {
        configureNormalButton_Bague(btnHome_Bague,     imageName: "home",     tag: 0)
        configureNormalButton_Bague(btnDiscover_Bague, imageName: "discover", tag: 1)
        configureReleaseButton_Bague()
        configureNormalButton_Bague(btnMessage_Bague,  imageName: "message",  tag: 3)
        configureNormalButton_Bague(btnMe_Bague,       imageName: "me",       tag: 4)
    }

    /// 配置普通 Tab 按钮（34x34，原图）
    /// - Parameters:
    ///   - button: 待配置的按钮
    ///   - imageName: Assets 图片名称
    ///   - tag: 对应子控制器索引
    private func configureNormalButton_Bague(_ button: UIButton, imageName: String, tag: Int) {
        let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
        button.setImage(image, for: .normal)
        button.setImage(image, for: .selected)
        button.tag = tag
        button.addTarget(self, action: #selector(tabButtonTapped_Bague(_:)), for: .touchUpInside)
        tabStackView_Bague.addArrangedSubview(button)
    }

    /// 配置发布按钮（64x64，原图）
    private func configureReleaseButton_Bague() {
        let image = UIImage(named: "publish")?.withRenderingMode(.alwaysOriginal)
        btnRelease_Bague.setImage(image, for: .normal)
        btnRelease_Bague.setImage(image, for: .selected)
        btnRelease_Bague.tag = 2
        btnRelease_Bague.addTarget(self, action: #selector(tabButtonTapped_Bague(_:)), for: .touchUpInside)
        tabStackView_Bague.addArrangedSubview(btnRelease_Bague)
    }

    // MARK: - 约束布局

    /// 设置所有视图约束
    private func setupConstraints_Bague() {
        // StackView：左右边距 20，底部对齐 safeArea，高度 64（与发布按钮一致）
        tabStackView_Bague.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(64)
        }

        // 普通按钮尺寸 34x34
        [btnHome_Bague, btnDiscover_Bague, btnMessage_Bague, btnMe_Bague].forEach { btn in
            btn.snp.makeConstraints { make in
                make.width.height.equalTo(34)
            }
        }

        // 发布按钮 64x64
        btnRelease_Bague.snp.makeConstraints { make in
            make.width.height.equalTo(64)
        }

        // 背景视图：紧贴屏幕左右底部，顶部从 StackView 上方 22pt 开始（与拱桥底脚高度保持一致）
        tabBgView_Bague.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(tabStackView_Bague).offset(-22)
        }
    }

    // MARK: - 选中高亮位置更新

    /// 更新选中圆形高亮在 view 坐标系中的位置，精准居中对齐选中按钮
    /// 在 viewDidLayoutSubviews 中调用以保证按钮 frame 已稳定
    private func updateCircleBgPosition_Bague() {
        // 发布页不显示圆形高亮
        guard currentIndex_Bague != 2 else {
            selectedCircleBg_Bague.isHidden = true
            return
        }

        let targetBtn: UIButton
        switch currentIndex_Bague {
        case 0: targetBtn = btnHome_Bague
        case 1: targetBtn = btnDiscover_Bague
        case 3: targetBtn = btnMessage_Bague
        case 4: targetBtn = btnMe_Bague
        default: return
        }

        // 确保按钮已完成布局（frame 有效）
        guard targetBtn.frame.width > 0 else { return }

        selectedCircleBg_Bague.isHidden = false

        // 将按钮中心点从自身坐标系转换到 view 坐标系
        let btnCenterInView = targetBtn.convert(
            CGPoint(x: targetBtn.bounds.midX, y: targetBtn.bounds.midY),
            to: view
        )
        let size: CGFloat = 34
        selectedCircleBg_Bague.frame = CGRect(
            x: btnCenterInView.x - size / 2,
            y: btnCenterInView.y - size / 2,
            width: size,
            height: size
        )
    }

    // MARK: - 按钮点击事件

    /// Tab 按钮点击处理，更新选中态并同步高亮位置
    /// - Parameter sender: 被点击的按钮，通过 tag 区分对应页面索引
    @objc private func tabButtonTapped_Bague(_ sender: UIButton) {
        let index = sender.tag
        currentIndex_Bague = index
        selectedIndex = index

        btnHome_Bague.isSelected     = (index == 0)
        btnDiscover_Bague.isSelected = (index == 1)
        btnRelease_Bague.isSelected  = (index == 2)
        btnMessage_Bague.isSelected  = (index == 3)
        btnMe_Bague.isSelected       = (index == 4)

        // 触发布局，确保高亮圆圈同步更新到新位置
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}
