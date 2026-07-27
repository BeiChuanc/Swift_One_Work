import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 屏幕高宽
enum APPSCREEN_Orna {
    
    static let WIDTH_Orna = UIScreen.main.bounds.width
    
    static let HEIGHT_Orna = UIScreen.main.bounds.height
}

/// 底部导航页面
class TabBar_Orna: UITabBarController {

    /// 悬浮底部导航栏在屏幕底部占用的遮挡高度（黄色背板顶部距容器底部的距离，再加一些安全余量）。
    /// 由于导航栏以自定义悬浮胶囊形式叠加在各 Tab 页面内容之上（而非系统标准 UITabBar 挤压布局），
    /// 各 Tab 页面的可滚动内容需在底部预留不小于该值的安全间距，避免可交互内容被悬浮导航栏遮挡、
    /// 或导致内容滚动到底后仍有一部分停留在导航栏后方无法完全露出
    static let floatingBarClearance_Orna: CGFloat = 130
    
    /// 黄色背景视图
    private var tabBgView_Orna = UIView()
    
    /// 按钮容器栈视图
    private var tabStackView_Orna = UIStackView()
    
    /// 首页按钮
    private var btnHome_Orna = UIButton(type: .custom)
    
    /// 发现页按钮
    private var btnDiscover_Orna = UIButton(type: .custom)
    
    /// 发布按钮
    private var btnRelease_Orna = UIButton(type: .custom)
    
    /// 消息按钮
    private var btnMessage_Orna = UIButton(type: .custom)
    
    /// 我的按钮
    private var btnMe_Orna = UIButton(type: .custom)
    
    /// 当前选中索引
    private var currentIndex_Orna: Int = 0
    
    // MARK: - 生命周期方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置视图控制器
        viewControllers = [Home_Orna(), Discover_Orna(), Release_Orna(), MessageList_Orna(), Me_Orna()]
        
        setupUI_Orna()
        setupConstraints_Orna()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    // MARK: - UI设置
    private func setupUI_Orna() {
        // 配置黄色背景视图
        tabBgView_Orna.backgroundColor = UIColor(hexstring_Orna: "#FFD700")
        tabBgView_Orna.layer.masksToBounds = true
        view.addSubview(tabBgView_Orna)
        
        // 配置StackView
        tabStackView_Orna.axis = .horizontal
        tabStackView_Orna.distribution = .equalSpacing
        tabStackView_Orna.alignment = .center
        tabStackView_Orna.spacing = 20
        view.addSubview(tabStackView_Orna)
        
        // 配置首页按钮
        btnHome_Orna.setImage(UIImage(named: "front_select"), for: .selected)
        btnHome_Orna.setImage(UIImage(named: "front_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnHome_Orna.tintColor = .gray
        btnHome_Orna.tag = 0
        btnHome_Orna.addTarget(self, action: #selector(tabButtonTapped_Orna(_:)), for: .touchUpInside)
        tabStackView_Orna.addArrangedSubview(btnHome_Orna)
        
        // 配置发现页按钮
        btnDiscover_Orna.setImage(UIImage(named: "pu_select"), for: .selected)
        btnDiscover_Orna.setImage(UIImage(named: "pu_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnDiscover_Orna.tintColor = .gray
        btnDiscover_Orna.tag = 1
        btnDiscover_Orna.addTarget(self, action: #selector(tabButtonTapped_Orna(_:)), for: .touchUpInside)
        tabStackView_Orna.addArrangedSubview(btnDiscover_Orna)
        
        // 配置发布按钮
        btnRelease_Orna.setImage(UIImage(named: "publish"), for: .normal)
        btnRelease_Orna.tag = 2
        btnRelease_Orna.addTarget(self, action: #selector(tabButtonTapped_Orna(_:)), for: .touchUpInside)
        tabStackView_Orna.addArrangedSubview(btnRelease_Orna)
        
        // 配置消息按钮
        btnMessage_Orna.setImage(UIImage(named: "mes_select"), for: .selected)
        btnMessage_Orna.setImage(UIImage(named: "mes_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMessage_Orna.tintColor = .gray
        btnMessage_Orna.tag = 3
        btnMessage_Orna.addTarget(self, action: #selector(tabButtonTapped_Orna(_:)), for: .touchUpInside)
        tabStackView_Orna.addArrangedSubview(btnMessage_Orna)
        
        // 配置我的按钮
        btnMe_Orna.setImage(UIImage(named: "me_select"), for: .selected)
        btnMe_Orna.setImage(UIImage(named: "me_select")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btnMe_Orna.tintColor = .gray
        btnMe_Orna.tag = 4
        btnMe_Orna.addTarget(self, action: #selector(tabButtonTapped_Orna(_:)), for: .touchUpInside)
        tabStackView_Orna.addArrangedSubview(btnMe_Orna)
        
        // 设置初始选中状态
        btnHome_Orna.isSelected = true
    }
    
    /// 设置约束布局
    private func setupConstraints_Orna() {
        // StackView约束
        tabStackView_Orna.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-50)
            make.height.equalTo(50)
        }
        
        // 按钮尺寸约束
        btnHome_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnDiscover_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnRelease_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(45)
        }
        
        btnMessage_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        btnMe_Orna.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        // 黄色背景视图约束（上下各距离StackView 15）
        tabBgView_Orna.snp.makeConstraints { make in
            make.leading.trailing.equalTo(tabStackView_Orna)
            make.top.equalTo(tabStackView_Orna).offset(-15)
            make.bottom.equalTo(tabStackView_Orna).offset(15)
        }
        
        // 设置圆角为高度的一半
        tabBgView_Orna.layoutIfNeeded()
        let bgHeight = 50 + 30 // StackView高度50 + 上下各15
        tabBgView_Orna.layer.cornerRadius = CGFloat(bgHeight) / 2.0
    }
    
    @objc private func tabButtonTapped_Orna(_ sender: UIButton) {
        let index = sender.tag
        
        // 更新选中状态
        currentIndex_Orna = index
        selectedIndex = index
        
        // 更新所有按钮的选中状态
        btnHome_Orna.isSelected = (index == 0)
        btnDiscover_Orna.isSelected = (index == 1)
        btnRelease_Orna.isSelected = (index == 2)
        btnMessage_Orna.isSelected = (index == 3)
        btnMe_Orna.isSelected = (index == 4)
    }
}
