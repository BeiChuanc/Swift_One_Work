import Foundation
import UIKit
import SnapKit

// MARK: 导航器

/// 底部导航 TabBar
/// 核心作用：自定义 TabBar，使用 Assets 图标（原图不着色）；
///           发布图标 40×40，其余 30×30；选中非发布 Tab 时在图标后显示 30×30 圆角矩形（#04E6DA）
/// 设计思路：全宽白色背景（顶部左右圆角 25），紧贴屏幕左右与底部；StackView 等间距分布
class TabBar_Breeze: UITabBarController {
    
    // MARK: - UI 属性
    
    /// 背景视图（白色，仅顶部两角圆角）
    private let tabBgView_Breeze = UIView()
    
    /// 按钮水平栈
    private let tabStackView_Breeze = UIStackView()
    
    /// 五个 Tab 的点击按钮（透明，覆盖整个可点击区域）
    private let tapBtnHome_Breeze    = UIButton(type: .custom)
    private let tapBtnDiscover_Breeze = UIButton(type: .custom)
    private let tapBtnRelease_Breeze  = UIButton(type: .custom)
    private let tapBtnMessage_Breeze  = UIButton(type: .custom)
    private let tapBtnMe_Breeze       = UIButton(type: .custom)
    
    /// 非发布 Tab 的选中指示器（index 0/1/3/4 对应，index 2 = nil）
    private var indicators_Breeze: [UIView?] = []
    
    /// 当前选中 Tab 下标
    private var currentIndex_Breeze: Int = 0
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [Home_Breeze(), Discover_Breeze(), Release_Breeze(), MessageList_Breeze(), Me_Breeze()]
        setupUI_Breeze()
        setupConstraints_Breeze()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tabBar.isHidden = true
    }
    
    // MARK: - UI 搭建
    
    private func setupUI_Breeze() {
        // 背景视图：白色，顶部两圆角 25，顶部阴影
        tabBgView_Breeze.backgroundColor = UIColor(hexstring_Breeze: "#FFFFFF")
        tabBgView_Breeze.layer.masksToBounds = false
        tabBgView_Breeze.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBgView_Breeze.layer.cornerRadius = 25
        tabBgView_Breeze.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        tabBgView_Breeze.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBgView_Breeze.layer.shadowRadius = 12
        tabBgView_Breeze.layer.shadowOpacity = 1
        view.addSubview(tabBgView_Breeze)
        
        // 水平栈
        tabStackView_Breeze.axis = .horizontal
        tabStackView_Breeze.distribution = .equalSpacing
        tabStackView_Breeze.alignment = .center
        tabBgView_Breeze.addSubview(tabStackView_Breeze)
        
        // Tab 配置表（asset名, tap按钮, index, 是否发布）
        let tabConfigs_Breeze: [(assetName: String, tapBtn: UIButton, tag: Int, isPublish: Bool)] = [
            ("home",    tapBtnHome_Breeze,    0, false),
            ("discover", tapBtnDiscover_Breeze, 1, false),
            ("publish", tapBtnRelease_Breeze,  2, true),
            ("message", tapBtnMessage_Breeze,  3, false),
            ("me",      tapBtnMe_Breeze,       4, false),
        ]
        
        for config_breeze in tabConfigs_Breeze {
            let iconSize_breeze: CGFloat = config_breeze.isPublish ? 40 : 30
            
            // 图标 ImageView（使用原图，不着色）
            let iconIv_breeze = UIImageView()
            iconIv_breeze.image = UIImage(named: config_breeze.assetName)?.withRenderingMode(.alwaysOriginal)
            iconIv_breeze.contentMode = .scaleAspectFit
            
            // 透明点击按钮（tag 标识 index）
            config_breeze.tapBtn.tag = config_breeze.tag
            config_breeze.tapBtn.addTarget(self, action: #selector(tabButtonTapped_Breeze(_:)), for: .touchUpInside)
            config_breeze.tapBtn.backgroundColor = .clear
            
            // 容器视图
            let container_breeze = UIView()
            container_breeze.backgroundColor = .clear
            
            if config_breeze.isPublish {
                // 发布按钮：无选中指示器，图标 40×40
                container_breeze.addSubview(iconIv_breeze)
                container_breeze.addSubview(config_breeze.tapBtn)
                
                iconIv_breeze.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.height.equalTo(iconSize_breeze)
                }
                config_breeze.tapBtn.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                container_breeze.snp.makeConstraints { make in
                    make.width.height.equalTo(44)
                }
                indicators_Breeze.append(nil)
                
            } else {
                // 非发布按钮：添加 30×30 选中指示器（初始隐藏）
                let indicator_breeze = UIView()
                indicator_breeze.backgroundColor = UIColor(hexstring_Breeze: "#04E6DA")
                indicator_breeze.layer.cornerRadius = 8
                indicator_breeze.isHidden = true
                
                // 层叠顺序：indicator（最底）→ iconIv → tapBtn（最顶，透明）
                container_breeze.addSubview(indicator_breeze)
                container_breeze.addSubview(iconIv_breeze)
                container_breeze.addSubview(config_breeze.tapBtn)
                
                indicator_breeze.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.height.equalTo(30)
                }
                iconIv_breeze.snp.makeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.height.equalTo(iconSize_breeze)
                }
                config_breeze.tapBtn.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
                container_breeze.snp.makeConstraints { make in
                    make.width.height.equalTo(44)
                }
                indicators_Breeze.append(indicator_breeze)
            }
            
            tabStackView_Breeze.addArrangedSubview(container_breeze)
        }
        
        // 默认选中首页
        updateSelection_Breeze(index_breeze: 0)
    }
    
    // MARK: - 约束
    
    private func setupConstraints_Breeze() {
        // tabBgView：贴屏幕左/右/底，无间距
        tabBgView_Breeze.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        // StackView：顶部 14pt，底部在安全区上方 10pt，左右 inset 各 24
        tabStackView_Breeze.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(14)
            make.height.equalTo(54)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
    
    // MARK: - 选中状态
    
    /// 更新选中指示器可见性（发布 Tab 无指示器）
    private func updateSelection_Breeze(index_breeze: Int) {
        for (idx_breeze, indicator_breeze) in indicators_Breeze.enumerated() {
            indicator_breeze?.isHidden = idx_breeze != index_breeze
        }
    }
    
    // MARK: - 事件
    
    @objc private func tabButtonTapped_Breeze(_ sender: UIButton) {
        sender.animatePulse_Breeze()
        switchToTab_Breeze(index_breeze: sender.tag)
    }
    
    /// 程序化切换到指定 Tab（供子页面在操作完成后回调）
    /// - Parameter index_breeze: 目标 Tab 下标
    func switchToTab_Breeze(index_breeze: Int) {
        guard index_breeze != currentIndex_Breeze else { return }
        currentIndex_Breeze = index_breeze
        selectedIndex = index_breeze
        updateSelection_Breeze(index_breeze: index_breeze)
    }
}
