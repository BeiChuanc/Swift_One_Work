import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航页面
class TabBar_Retrs: UITabBarController {
    
    /// 黄色背景视图
    private var tabBgView_Retrs = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Retrs = UIStackView()
    
    /// 首页按钮
    private var btnHome_Retrs = UIButton(type: .custom)
    
    /// 发现页按钮
    private var btnDiscover_Retrs = UIButton(type: .custom)
    
    /// 发布按钮
    private var btnRelease_Retrs = UIButton(type: .custom)
    
    /// 消息按钮
    private var btnMessage_Retrs = UIButton(type: .custom)
    
    /// 我的按钮
    private var btnMe_Retrs = UIButton(type: .custom)
    
    /// 当前选中索引
    private var currentIndex_Retrs: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Retrs(), Discover_Retrs(), Release_Retrs(), MessageList_Retrs(), Me_Retrs()]
        
        setupUI_Retrs()
        setupConstraints_Retrs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    // MARK: - UI设置
    private func setupUI_Retrs() {
        // TabBar 背景为纯白
        tabBgView_Retrs.backgroundColor = UIColor(hexstring_Retrs: "#FFFFFF")
        tabBgView_Retrs.layer.masksToBounds = true
        view.addSubview(tabBgView_Retrs)

        // 配置 StackView
        tabStackView_Retrs.axis = .horizontal
        tabStackView_Retrs.distribution = .equalSpacing
        tabStackView_Retrs.alignment = .center
        tabStackView_Retrs.spacing = 20
        // 左右各留 16pt，使首尾 Item 与背景胶囊边缘保持距离
        tabStackView_Retrs.isLayoutMarginsRelativeArrangement = true
        tabStackView_Retrs.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.addSubview(tabStackView_Retrs)

        // 首页按钮：未选中 home（原图），选中 home_s（原图）
        btnHome_Retrs.setImage(UIImage(named: "home")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btnHome_Retrs.setImage(UIImage(named: "home_s")?.withRenderingMode(.alwaysOriginal), for: .selected)
        btnHome_Retrs.tag = 0
        btnHome_Retrs.addTarget(self, action: #selector(tabButtonTapped_Retrs(_:)), for: .touchUpInside)
        tabStackView_Retrs.addArrangedSubview(btnHome_Retrs)

        // 发现页按钮：未选中 discover（原图），选中 discover_s（原图）
        btnDiscover_Retrs.setImage(UIImage(named: "discover")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btnDiscover_Retrs.setImage(UIImage(named: "discover_s")?.withRenderingMode(.alwaysOriginal), for: .selected)
        btnDiscover_Retrs.tag = 1
        btnDiscover_Retrs.addTarget(self, action: #selector(tabButtonTapped_Retrs(_:)), for: .touchUpInside)
        tabStackView_Retrs.addArrangedSubview(btnDiscover_Retrs)

        // 发布按钮：仅 publish（原图），无选中态
        btnRelease_Retrs.setImage(UIImage(named: "publish")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btnRelease_Retrs.tag = 2
        btnRelease_Retrs.addTarget(self, action: #selector(tabButtonTapped_Retrs(_:)), for: .touchUpInside)
        tabStackView_Retrs.addArrangedSubview(btnRelease_Retrs)

        // 消息按钮：未选中 message（原图），选中 message_s（原图）
        btnMessage_Retrs.setImage(UIImage(named: "message")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btnMessage_Retrs.setImage(UIImage(named: "message_s")?.withRenderingMode(.alwaysOriginal), for: .selected)
        btnMessage_Retrs.tag = 3
        btnMessage_Retrs.addTarget(self, action: #selector(tabButtonTapped_Retrs(_:)), for: .touchUpInside)
        tabStackView_Retrs.addArrangedSubview(btnMessage_Retrs)

        // 我的按钮：未选中 me（原图），选中 me_s（原图）
        btnMe_Retrs.setImage(UIImage(named: "me")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btnMe_Retrs.setImage(UIImage(named: "me_s")?.withRenderingMode(.alwaysOriginal), for: .selected)
        btnMe_Retrs.tag = 4
        btnMe_Retrs.addTarget(self, action: #selector(tabButtonTapped_Retrs(_:)), for: .touchUpInside)
        tabStackView_Retrs.addArrangedSubview(btnMe_Retrs)

        // 初始选中首页
        btnHome_Retrs.isSelected = true
    }
    
    /// 设置约束布局
    private func setupConstraints_Retrs() {
        tabStackView_Retrs.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(56)   // 发布按钮 56pt 决定栈高
        }

        // 普通按钮 50×50
        [btnHome_Retrs, btnDiscover_Retrs, btnMessage_Retrs, btnMe_Retrs].forEach { btn_Retrs in
            btn_Retrs.snp.makeConstraints { make in
                make.width.height.equalTo(50)
            }
        }

        // 发布按钮 56×56
        btnRelease_Retrs.snp.makeConstraints { make in
            make.width.height.equalTo(56)
        }

        // 白色背景视图（上下各距离 StackView 15pt，形成圆角胶囊）
        tabBgView_Retrs.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Retrs)
            make.top.equalTo(tabStackView_Retrs).offset(-15)
            make.bottom.equalTo(tabStackView_Retrs).offset(15)
        }
        tabBgView_Retrs.layoutIfNeeded()
        let bgH_Retrs = 56 + 30  // StackView高度 + 上下各15
        tabBgView_Retrs.layer.cornerRadius = CGFloat(bgH_Retrs) / 2.0
    }
    
    @objc private func tabButtonTapped_Retrs(_ sender: UIButton) {
        let index = sender.tag
        switchToIndex_Retrs(index)
    }

    /// 切换到指定索引的 Tab
    /// - Parameter index_Retrs: 目标 Tab 索引（0~4）
    func switchToIndex_Retrs(_ index_Retrs: Int) {
        currentIndex_Retrs = index_Retrs
        selectedIndex = index_Retrs

        btnHome_Retrs.isSelected = (index_Retrs == 0)
        btnDiscover_Retrs.isSelected = (index_Retrs == 1)
        btnRelease_Retrs.isSelected = (index_Retrs == 2)
        btnMessage_Retrs.isSelected = (index_Retrs == 3)
        btnMe_Retrs.isSelected = (index_Retrs == 4)
    }
}
