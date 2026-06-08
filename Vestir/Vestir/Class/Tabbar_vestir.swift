import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航 TabBar
/// 功能：5 个 Tab（首页/发现/发布/消息/我的），自定义悬浮胶囊样式
/// 设计：
///   • 背景：#721BB1 → #0452BB 垂直渐变（顶部居中→底部居中）
///   • 图标使用 Assets 原图；非发布 Tab 选中时图标白色（#FFFFFF）
///   • 非发布图标尺寸 27×40；发布图标尺寸 44×44
///   • 支持外部 selectedIndex 变更时同步按钮选中态
class TabBar_Vestir: UITabBarController {

    // MARK: - 私有属性

    /// 渐变背景胶囊容器
    private var tabBgView_Vestir = UIView()

    /// 渐变图层（垂直方向：#721BB1 → #0452BB）
    private var tabGradientLayer_Vestir = CAGradientLayer()

    /// 按钮水平布局容器
    private var tabStackView_Vestir = UIStackView()

    /// 首页按钮
    private var btnHome_Vestir = UIButton(type: .custom)

    /// 发现页按钮
    private var btnDiscover_Vestir = UIButton(type: .custom)

    /// 发布按钮（44×44，始终原图，不改变颜色）
    private var btnRelease_Vestir = UIButton(type: .custom)

    /// 消息按钮
    private var btnMessage_Vestir = UIButton(type: .custom)

    /// 我的按钮
    private var btnMe_Vestir = UIButton(type: .custom)

    /// 当前选中索引
    private var currentIndex_Vestir: Int = 0 {
        didSet { syncButtonStates_Vestir() }
    }

    // MARK: - selectedIndex 拦截（支持外部 programmatic 切换）

    override var selectedIndex: Int {
        didSet {
            // 外部切换（如 tabBarController?.selectedIndex = 4）时同步按钮状态
            if currentIndex_Vestir != selectedIndex {
                currentIndex_Vestir = selectedIndex
            }
        }
    }

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            Home_Vestir(),
            Discover_Vestir(),
            Release_Vestir(),
            MessageList_Vestir(),
            Me_Vestir()
        ]
        setupUI_Vestir()
        setupConstraints_Vestir()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 同步渐变图层 frame（每次布局后刷新）
        tabGradientLayer_Vestir.frame = tabBgView_Vestir.bounds
    }

    // MARK: - UI 搭建

    private func setupUI_Vestir() {

        // ─── 渐变背景胶囊 ───
        tabBgView_Vestir.layer.masksToBounds = true
        tabBgView_Vestir.backgroundColor = .clear

        // 顶部居中 → 底部居中（垂直渐变）
        tabGradientLayer_Vestir.colors = [
            UIColor(hexstring_Vestir: "#721BB1").cgColor,
            UIColor(hexstring_Vestir: "#0452BB").cgColor
        ]
        tabGradientLayer_Vestir.startPoint = CGPoint(x: 0.5, y: 0)
        tabGradientLayer_Vestir.endPoint = CGPoint(x: 0.5, y: 1)
        tabBgView_Vestir.layer.insertSublayer(tabGradientLayer_Vestir, at: 0)
        view.addSubview(tabBgView_Vestir)

        // ─── 按钮容器 ───
        tabStackView_Vestir.axis = .horizontal
        tabStackView_Vestir.distribution = .equalSpacing
        tabStackView_Vestir.alignment = .center
        tabStackView_Vestir.spacing = 20
        // 左右内边距，确保两端按钮距胶囊圆角有足够间距
        tabStackView_Vestir.isLayoutMarginsRelativeArrangement = true
        tabStackView_Vestir.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        view.addSubview(tabStackView_Vestir)

        // ─── 非发布 Tab：原图 normal / 白色 selected ───
        configureRegularBtn_Vestir(btnHome_Vestir,    imageName_vestir: "home",     tag_vestir: 0)
        configureRegularBtn_Vestir(btnDiscover_Vestir, imageName_vestir: "discover", tag_vestir: 1)
        configureRegularBtn_Vestir(btnMessage_Vestir,  imageName_vestir: "message",  tag_vestir: 3)
        configureRegularBtn_Vestir(btnMe_Vestir,       imageName_vestir: "me",       tag_vestir: 4)

        tabStackView_Vestir.addArrangedSubview(btnHome_Vestir)
        tabStackView_Vestir.addArrangedSubview(btnDiscover_Vestir)

        // ─── 发布 Tab：始终原图，无选中态变色 ───
        btnRelease_Vestir.setImage(
            UIImage(named: "publish")?.withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        btnRelease_Vestir.tag = 2
        btnRelease_Vestir.addTarget(self, action: #selector(tabButtonTapped_Vestir(_:)), for: .touchUpInside)
        tabStackView_Vestir.addArrangedSubview(btnRelease_Vestir)

        tabStackView_Vestir.addArrangedSubview(btnMessage_Vestir)
        tabStackView_Vestir.addArrangedSubview(btnMe_Vestir)

        // 初始选中首页
        btnHome_Vestir.isSelected = true
    }

    /// 配置普通（非发布）Tab 按钮
    /// - normal：Assets 原图（.alwaysOriginal，不受 tintColor 影响）
    /// - selected：同一图，模板渲染（.alwaysTemplate），tintColor = #FFFFFF
    private func configureRegularBtn_Vestir(
        _ button: UIButton,
        imageName_vestir: String,
        tag_vestir: Int
    ) {
        let originalImg_Vestir = UIImage(named: imageName_vestir)

        // normal：保留原图颜色
        button.setImage(
            originalImg_Vestir?.withRenderingMode(.alwaysOriginal),
            for: .normal
        )
        // selected：图标变白
        button.setImage(
            originalImg_Vestir?.withRenderingMode(.alwaysTemplate),
            for: .selected
        )
        button.tintColor = UIColor(hexstring_Vestir: "#FFFFFF")
        button.tag = tag_vestir
        button.addTarget(self, action: #selector(tabButtonTapped_Vestir(_:)), for: .touchUpInside)
    }

    // MARK: - 约束

    private func setupConstraints_Vestir() {
        // StackView
        tabStackView_Vestir.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(45)
        }

        // 非发布图标：宽 27 × 高 40
        btnHome_Vestir.snp.makeConstraints { make in
            make.width.equalTo(27)
            make.height.equalTo(40)
        }
        btnDiscover_Vestir.snp.makeConstraints { make in
            make.width.equalTo(27)
            make.height.equalTo(40)
        }
        btnMessage_Vestir.snp.makeConstraints { make in
            make.width.equalTo(27)
            make.height.equalTo(40)
        }
        btnMe_Vestir.snp.makeConstraints { make in
            make.width.equalTo(27)
            make.height.equalTo(40)
        }

        // 发布图标：44×44
        btnRelease_Vestir.snp.makeConstraints { make in
            make.width.height.equalTo(44)
        }

        // 渐变背景胶囊：上下各留 14pt 缓冲，形成圆角胶囊
        tabBgView_Vestir.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Vestir)
            make.top.equalTo(tabStackView_Vestir).offset(-14)
            make.bottom.equalTo(tabStackView_Vestir).offset(14)
        }

        // 等布局完成后设置圆角为高度一半
        tabBgView_Vestir.layoutIfNeeded()
        let bgH_Vestir = 45 + 14 + 14  // stackView 高度 + 上下缓冲
        tabBgView_Vestir.layer.cornerRadius = CGFloat(bgH_Vestir) / 2.0
    }

    // MARK: - 按钮点击

    @objc private func tabButtonTapped_Vestir(_ sender: UIButton) {
        let index_Vestir = sender.tag
        selectedIndex = index_Vestir
        currentIndex_Vestir = index_Vestir
    }

    /// 根据 currentIndex_Vestir 同步所有按钮选中态
    private func syncButtonStates_Vestir() {
        let idx_Vestir = currentIndex_Vestir
        btnHome_Vestir.isSelected     = (idx_Vestir == 0)
        btnDiscover_Vestir.isSelected = (idx_Vestir == 1)
        // 发布按钮不处理选中态（始终原图）
        btnMessage_Vestir.isSelected  = (idx_Vestir == 3)
        btnMe_Vestir.isSelected       = (idx_Vestir == 4)
    }
}
