import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
/// 功能：自定义底部导航栏，替代系统 UITabBar
/// 设计：白色背景，顶部左右圆角 20pt，左右底部贴屏幕边缘
/// 图标：Assets 原色，选中后（除发布页）着色 #6200FF
class TabBar_Sprig: UITabBarController {

    // MARK: - UI 属性

    /// 底部导航栏背景视图（白色，顶部圆角，贴边显示）
    private let tabBgView_Sprig = UIView()

    /// 按钮容器栈视图
    private let tabStackView_Sprig = UIStackView()

    /// 首页按钮
    private let btnHome_Sprig = UIButton(type: .custom)

    /// 发现页按钮
    private let btnDiscover_Sprig = UIButton(type: .custom)

    /// 发布按钮（60×60，始终原色）
    private let btnRelease_Sprig = UIButton(type: .custom)

    /// 消息按钮
    private let btnMessage_Sprig = UIButton(type: .custom)

    /// 我的按钮
    private let btnMe_Sprig = UIButton(type: .custom)

    /// 当前选中索引
    private var currentIndex_Sprig: Int = 0

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [Home_Sprig(), Discover_Sprig(), Release_Sprig(), MessageList_Sprig(), Me_Sprig()]
        setupUI_Sprig()
        setupConstraints_Sprig()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }

    // MARK: - UI 搭建

    /// 搭建自定义底部导航栏
    private func setupUI_Sprig() {
        // 背景视图：白色，顶部左右圆角 20，左右底部贴屏幕边缘，带顶部阴影
        tabBgView_Sprig.backgroundColor = UIColor(hexstring_Sprig: "#FFFFFF")
        tabBgView_Sprig.layer.cornerRadius = 20
        tabBgView_Sprig.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBgView_Sprig.layer.masksToBounds = false
        tabBgView_Sprig.layer.shadowColor = UIColor.black.cgColor
        tabBgView_Sprig.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBgView_Sprig.layer.shadowRadius = 10
        tabBgView_Sprig.layer.shadowOpacity = 0.07
        view.addSubview(tabBgView_Sprig)

        // 按钮容器栈视图（叠在背景视图之上）
        tabStackView_Sprig.axis = .horizontal
        tabStackView_Sprig.distribution = .equalSpacing
        tabStackView_Sprig.alignment = .center
        view.addSubview(tabStackView_Sprig)

        // 普通 Tab 按钮：正常态原色，选中态着色 #6200FF
        setupTabButton_Sprig(btnHome_Sprig, imageName: "home", tag: 0)
        setupTabButton_Sprig(btnDiscover_Sprig, imageName: "discover", tag: 1)
        setupPublishButton_Sprig()
        setupTabButton_Sprig(btnMessage_Sprig, imageName: "message", tag: 3)
        setupTabButton_Sprig(btnMe_Sprig, imageName: "me", tag: 4)

        // 初始选中首页
        btnHome_Sprig.isSelected = true
    }

    /// 配置普通 Tab 按钮
    /// - Parameters:
    ///   - button: 目标按钮
    ///   - imageName: Assets 中的图片名称
    ///   - tag: 页面索引
    private func setupTabButton_Sprig(_ button: UIButton, imageName: String, tag: Int) {
        // 正常态：alwaysOriginal 保留图片原色，不受 tintColor 影响
        button.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal), for: .normal)
        // 选中态：alwaysTemplate 应用 tintColor（#6200FF）
        button.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .selected)
        button.tintColor = UIColor(hexstring_Sprig: "#6200FF")
        button.imageView?.contentMode = .scaleAspectFit
        button.tag = tag
        button.addTarget(self, action: #selector(tabButtonTapped_Sprig(_:)), for: .touchUpInside)
        tabStackView_Sprig.addArrangedSubview(button)
    }

    /// 配置发布按钮（60×60，正常态与选中态均保留原色）
    private func setupPublishButton_Sprig() {
        let originalImg_sprig = UIImage(named: "publish")?.withRenderingMode(.alwaysOriginal)
        btnRelease_Sprig.setImage(originalImg_sprig, for: .normal)
        btnRelease_Sprig.setImage(originalImg_sprig, for: .selected)
        btnRelease_Sprig.imageView?.contentMode = .scaleAspectFit
        btnRelease_Sprig.tag = 2
        btnRelease_Sprig.addTarget(self, action: #selector(tabButtonTapped_Sprig(_:)), for: .touchUpInside)
        tabStackView_Sprig.addArrangedSubview(btnRelease_Sprig)
    }

    // MARK: - 约束布局

    /// 搭建约束布局
    private func setupConstraints_Sprig() {
        // 普通按钮：30×30
        [btnHome_Sprig, btnDiscover_Sprig, btnMessage_Sprig, btnMe_Sprig].forEach { btn_sprig in
            btn_sprig.snp.makeConstraints { make in
                make.width.height.equalTo(30)
            }
        }

        // 发布按钮：60×60
        btnRelease_Sprig.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }

        // 按钮栈视图：左右各 24pt 边距，底部距安全区底部 8pt，高度 60
        tabStackView_Sprig.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
            make.height.equalTo(50)
        }

        // 背景视图：左右底部贴屏幕边缘（距离为 0），顶部与栈视图顶部对齐并上移 12pt
        tabBgView_Sprig.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tabStackView_Sprig.snp.top).offset(-12)
        }
    }

    // MARK: - 按钮响应

    @objc private func tabButtonTapped_Sprig(_ sender: UIButton) {
        selectPage_Sprig(index: sender.tag)
    }

    /// 程序化切换到指定 Tab 页
    /// - Parameter index: Tab 索引（0=首页 1=发现 2=发布 3=消息 4=我的）
    func selectPage_Sprig(index: Int) {
        currentIndex_Sprig = index
        selectedIndex = index
        btnHome_Sprig.isSelected     = (index == 0)
        btnDiscover_Sprig.isSelected = (index == 1)
        btnRelease_Sprig.isSelected  = (index == 2)
        btnMessage_Sprig.isSelected  = (index == 3)
        btnMe_Sprig.isSelected       = (index == 4)
    }
}
