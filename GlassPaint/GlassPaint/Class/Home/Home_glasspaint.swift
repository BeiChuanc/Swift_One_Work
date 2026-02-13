import Foundation
import UIKit
import SnapKit

// MARK: 首页

/// 首页页面
/// 功能：展示今日灵感推荐和我的彩绘时光轴
/// 特性：推荐卡片横向滚动、成长曲线图、时光轴列表
class Home_Glasspaint: UIViewController {
    
    // MARK: - UI属性
    
    /// 主滚动视图
    private let scrollView_Glasspaint = UIScrollView()
    
    /// 内容容器
    private let contentView_Glasspaint = UIView()
    
    /// 背景渐变层
    private let backgroundGradientLayer_Glasspaint = CAGradientLayer()
    
    /// 装饰圆圈1
    private let decorCircle1_Glasspaint = UIView()
    
    /// 装饰圆圈2
    private let decorCircle2_Glasspaint = UIView()
    
    /// 粒子层
    private let particleLayer_Glasspaint = CAEmitterLayer()
    
    /// 导航栏容器
    private let navContainer_Glasspaint = UIView()
    
    /// 导航栏毛玻璃效果
    private let navBlurEffect_Glasspaint = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    
    /// 用户头像
    private let avatarView_Glasspaint = CurrentUserAvatarView_Glasspaint()
    
    /// 标题标签
    private let titleLabel_Glasspaint = UILabel()
    
    /// 副标题标签
    private let subtitleLabel_Glasspaint = UILabel()
    
    // 今日灵感推荐区域
    private let recommendContainer_Glasspaint = UIView()
    private let recommendTitleLabel_Glasspaint = UILabel()
    private let refreshButton_Glasspaint = UIButton(type: .system)
    private let recommendCollectionView_Glasspaint: UICollectionView = {
        let layout_glasspaint = UICollectionViewFlowLayout()
        layout_glasspaint.scrollDirection = .horizontal
        layout_glasspaint.minimumLineSpacing = 16
        layout_glasspaint.itemSize = CGSize(width: 280, height: 420)
        let collectionView_glasspaint = UICollectionView(frame: .zero, collectionViewLayout: layout_glasspaint)
        collectionView_glasspaint.showsHorizontalScrollIndicator = false
        collectionView_glasspaint.backgroundColor = .clear
        collectionView_glasspaint.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView_glasspaint
    }()
    
    // 我的彩绘时光轴区域
    private let timelineContainer_Glasspaint = UIView()
    private let timelineTitleLabel_Glasspaint = UILabel()
    private let growthChartView_Glasspaint = GrowthChartView_Glasspaint()
    
    /// 空状态视图
    private let emptyStateView_Glasspaint = EmptyStateView_Glasspaint(stateType_glasspaint: .noRecommendations_glasspaint)
    
    // MARK: - 数据属性
    
    /// 推荐作品列表
    private var recommendations_Glasspaint: [TitleModel_Glasspaint] = []
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        loadRecommendations_Glasspaint()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Glasspaint()
        setupNotifications_Glasspaint()
        loadRecommendations_Glasspaint()
        loadGrowthData_Glasspaint()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Glasspaint() {
        view.backgroundColor = ColorConfig_Glasspaint.backgroundPrimary_Glasspaint
        
        // 背景渐变层
        setupBackgroundGradient_Glasspaint()
        
        // 装饰元素
        setupDecorationElements_Glasspaint()
        
        // 主滚动视图
        view.addSubview(scrollView_Glasspaint)
        scrollView_Glasspaint.showsVerticalScrollIndicator = false
        scrollView_Glasspaint.contentInsetAdjustmentBehavior = .never
        scrollView_Glasspaint.delegate = self
        
        // 内容容器
        scrollView_Glasspaint.addSubview(contentView_Glasspaint)
        
        // 导航栏
        contentView_Glasspaint.addSubview(navContainer_Glasspaint)
        setupNavigationBar_Glasspaint()
        
        // 推荐区域
        contentView_Glasspaint.addSubview(recommendContainer_Glasspaint)
        setupRecommendSection_Glasspaint()
        
        // 时光轴区域
        contentView_Glasspaint.addSubview(timelineContainer_Glasspaint)
        setupTimelineSection_Glasspaint()
        
        // 空状态视图
        contentView_Glasspaint.addSubview(emptyStateView_Glasspaint)
        emptyStateView_Glasspaint.isHidden = true
        emptyStateView_Glasspaint.onActionTap_Glasspaint = { [weak self] in
            self?.handleRefresh_Glasspaint()
        }
        
        // 布局
        setupConstraints_Glasspaint()
    }
    
    /// 设置导航栏
    private func setupNavigationBar_Glasspaint() {
        // 毛玻璃背景
        navContainer_Glasspaint.insertSubview(navBlurEffect_Glasspaint, at: 0)
        navBlurEffect_Glasspaint.alpha = 0
        
        // 用户头像容器（添加阴影和光晕效果）
        let avatarContainer_glasspaint = UIView()
        navContainer_Glasspaint.addSubview(avatarContainer_glasspaint)
        avatarContainer_glasspaint.addSubview(avatarView_Glasspaint)
        
        // 确保头像视图的圆角和裁剪
        avatarView_Glasspaint.layer.cornerRadius = 24
        avatarView_Glasspaint.layer.masksToBounds = true
        avatarView_Glasspaint.imageView_Glasspaint.layer.cornerRadius = 24
        avatarView_Glasspaint.imageView_Glasspaint.clipsToBounds = true
        
        // 头像边框
        avatarView_Glasspaint.layer.borderWidth = 2.5
        avatarView_Glasspaint.layer.borderColor = UIColor.white.cgColor
        
        // 头像发光效果
        avatarContainer_glasspaint.layer.shadowColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        avatarContainer_glasspaint.layer.shadowOffset = .zero
        avatarContainer_glasspaint.layer.shadowRadius = 10
        avatarContainer_glasspaint.layer.shadowOpacity = 0.5
        avatarContainer_glasspaint.layer.shadowPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 48, height: 48)).cgPath
        
        // 头像点击事件
        avatarView_Glasspaint.onTapped_Glasspaint = { [weak self] in
            self?.handleAvatarTap_Glasspaint()
        }
        
        // 标题容器（居中布局）
        let titleContainer_glasspaint = UIView()
        navContainer_Glasspaint.addSubview(titleContainer_glasspaint)
        
        // 主标题
        titleContainer_glasspaint.addSubview(titleLabel_Glasspaint)
        titleLabel_Glasspaint.text = "✨ GlassPaint"
        titleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 26, weight: .bold)
        titleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 副标题
        titleContainer_glasspaint.addSubview(subtitleLabel_Glasspaint)
        subtitleLabel_Glasspaint.text = "Create & Inspire"
        subtitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        subtitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        subtitleLabel_Glasspaint.alpha = 0.8
        
        // 布局
        navBlurEffect_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarContainer_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        avatarView_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(48)
        }
        
        // 强制刷新布局以确保圆角正确显示
        DispatchQueue.main.async {
            self.avatarView_Glasspaint.layoutIfNeeded()
            self.avatarView_Glasspaint.setNeedsLayout()
        }
        
        titleContainer_glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        titleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        
        subtitleLabel_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(titleLabel_Glasspaint.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    /// 设置推荐区域
    private func setupRecommendSection_Glasspaint() {
        // 标题容器（添加图标）
        let titleContainer_glasspaint = UIView()
        recommendContainer_Glasspaint.addSubview(titleContainer_glasspaint)
        
        // 装饰图标
        let iconView_glasspaint = UIImageView(image: UIImage(systemName: "sparkles"))
        titleContainer_glasspaint.addSubview(iconView_glasspaint)
        iconView_glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        iconView_glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        titleContainer_glasspaint.addSubview(recommendTitleLabel_Glasspaint)
        recommendTitleLabel_Glasspaint.text = "Today's Inspiration"
        recommendTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        recommendTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 刷新按钮（添加渐变背景）
        let refreshContainer_glasspaint = UIView()
        recommendContainer_Glasspaint.addSubview(refreshContainer_glasspaint)
        refreshContainer_glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.1)
        refreshContainer_glasspaint.layer.cornerRadius = 18
        
        refreshContainer_glasspaint.addSubview(refreshButton_Glasspaint)
        refreshButton_Glasspaint.setImage(UIImage(systemName: "arrow.clockwise.circle.fill"), for: .normal)
        refreshButton_Glasspaint.tintColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint
        refreshButton_Glasspaint.addTarget(self, action: #selector(handleRefresh_Glasspaint), for: .touchUpInside)
        
        // 布局
        titleContainer_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
        }
        
        iconView_glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        recommendTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconView_glasspaint.snp.right).offset(8)
            make.centerY.top.bottom.right.equalToSuperview()
        }
        
        refreshContainer_glasspaint.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleContainer_glasspaint)
            make.width.height.equalTo(36)
        }
        
        refreshButton_Glasspaint.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
        // 推荐集合视图
        recommendContainer_Glasspaint.addSubview(recommendCollectionView_Glasspaint)
        recommendCollectionView_Glasspaint.delegate = self
        recommendCollectionView_Glasspaint.dataSource = self
        recommendCollectionView_Glasspaint.register(RecommendationCardCell_Glasspaint.self, forCellWithReuseIdentifier: "RecommendationCardCell")
        
        // 布局推荐集合视图
        recommendCollectionView_Glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleContainer_glasspaint.snp.bottom).offset(20)
            make.height.equalTo(440)
            make.bottom.equalToSuperview()
        }
    }
    
    /// 设置时光轴区域
    private func setupTimelineSection_Glasspaint() {
        // 标题容器（添加图标和描述）
        let titleContainer_glasspaint = UIView()
        timelineContainer_Glasspaint.addSubview(titleContainer_glasspaint)
        
        // 装饰图标
        let iconView_glasspaint = UIImageView(image: UIImage(systemName: "chart.line.uptrend.xyaxis"))
        titleContainer_glasspaint.addSubview(iconView_glasspaint)
        iconView_glasspaint.tintColor = ColorConfig_Glasspaint.levelAdvancedColor_Glasspaint
        iconView_glasspaint.contentMode = .scaleAspectFit
        
        // 标题
        titleContainer_glasspaint.addSubview(timelineTitleLabel_Glasspaint)
        timelineTitleLabel_Glasspaint.text = "My Growth Journey"
        timelineTitleLabel_Glasspaint.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        timelineTitleLabel_Glasspaint.textColor = ColorConfig_Glasspaint.textPrimary_Glasspaint
        
        // 成长曲线图（添加容器增强视觉效果）
        let chartContainer_glasspaint = UIView()
        timelineContainer_Glasspaint.addSubview(chartContainer_glasspaint)
        chartContainer_glasspaint.backgroundColor = .clear
        
        chartContainer_glasspaint.addSubview(growthChartView_Glasspaint)
        
        // 布局
        titleContainer_glasspaint.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview()
        }
        
        iconView_glasspaint.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        timelineTitleLabel_Glasspaint.snp.makeConstraints { make in
            make.left.equalTo(iconView_glasspaint.snp.right).offset(8)
            make.centerY.top.bottom.right.equalToSuperview()
        }
        
        chartContainer_glasspaint.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(titleContainer_glasspaint.snp.bottom).offset(20)
            make.bottom.equalToSuperview()
        }
        
        growthChartView_Glasspaint.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-120)
        }
    }
    
    /// 设置布局约束
    private func setupConstraints_Glasspaint() {
        scrollView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        navContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(50)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        recommendContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(navContainer_Glasspaint.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
        }
        
        timelineContainer_Glasspaint.snp.makeConstraints { make in
            make.top.equalTo(recommendContainer_Glasspaint.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-24)
        }
        
        emptyStateView_Glasspaint.snp.makeConstraints { make in
            make.center.equalTo(recommendCollectionView_Glasspaint)
            make.width.equalTo(300)
            make.height.equalTo(400)
        }
    }
    
    // MARK: - 数据加载
    
    /// 加载推荐数据
    private func loadRecommendations_Glasspaint() {
        recommendations_Glasspaint = RecommendViewModel_Glasspaint.shared_Glasspaint.getTodayRecommendations_Glasspaint()
        
        // 更新UI
        if recommendations_Glasspaint.isEmpty {
            emptyStateView_Glasspaint.isHidden = false
            recommendCollectionView_Glasspaint.isHidden = true
        } else {
            emptyStateView_Glasspaint.isHidden = true
            recommendCollectionView_Glasspaint.isHidden = false
            recommendCollectionView_Glasspaint.reloadData()
        }
    }
    
    /// 加载成长数据
    private func loadGrowthData_Glasspaint() {
        let growthData_glasspaint = RecommendViewModel_Glasspaint.shared_Glasspaint.getGrowthCurve_Glasspaint()
        growthChartView_Glasspaint.configure_Glasspaint(with_glasspaint: growthData_glasspaint)
    }
    
    // MARK: - 通知
    
    /// 设置通知监听
    private func setupNotifications_Glasspaint() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTitleStateChange_Glasspaint),
            name: TitleViewModel_Glasspaint.titleStateDidChangeNotification_Glasspaint,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleUserStateChange_Glasspaint),
            name: UserViewModel_Glasspaint.userStateDidChangeNotification_Glasspaint,
            object: nil
        )
    }
    
    @objc private func handleTitleStateChange_Glasspaint() {
        loadRecommendations_Glasspaint()
        loadGrowthData_Glasspaint()
    }
    
    @objc private func handleUserStateChange_Glasspaint() {
        loadRecommendations_Glasspaint()
        loadGrowthData_Glasspaint()
    }
    
    // MARK: - 交互
    
    /// 处理头像点击事件
    private func handleAvatarTap_Glasspaint() {
        // 触觉反馈
        let generator_glasspaint = UIImpactFeedbackGenerator(style: .medium)
        generator_glasspaint.impactOccurred()
        
        // 切换到底部导航的"我的"页面（索引4）
        if let tabBarController_glasspaint = self.tabBarController {
            // 如果已经在"我的"页面，不做任何操作
            if tabBarController_glasspaint.selectedIndex == 4 {
                return
            }
            
            // 切换页面
            tabBarController_glasspaint.selectedIndex = 4
            
            // 添加平滑过渡动画
            UIView.transition(with: tabBarController_glasspaint.view,
                            duration: 0.25,
                            options: .transitionCrossDissolve,
                            animations: nil,
                            completion: nil)
        }
    }
    
    @objc private func handleRefresh_Glasspaint() {
        // 缩放动画
        UIView.animate(withDuration: 0.1, animations: {
            self.refreshButton_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.refreshButton_Glasspaint.transform = .identity
            }
        }
        
        // 旋转动画
        let rotation_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation_glasspaint.fromValue = 0
        rotation_glasspaint.toValue = Double.pi * 2
        rotation_glasspaint.duration = 0.6
        rotation_glasspaint.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        refreshButton_Glasspaint.layer.add(rotation_glasspaint, forKey: "refreshRotation")
        
        // 添加粒子爆炸效果
        createRefreshParticles_Glasspaint()
        
        loadRecommendations_Glasspaint()
    }
    
    /// 创建刷新粒子效果
    private func createRefreshParticles_Glasspaint() {
        let particleEmitter_glasspaint = CAEmitterLayer()
        
        // 获取按钮在视图中的位置
        let buttonFrame_glasspaint = refreshButton_Glasspaint.convert(refreshButton_Glasspaint.bounds, to: view)
        particleEmitter_glasspaint.emitterPosition = CGPoint(
            x: buttonFrame_glasspaint.midX,
            y: buttonFrame_glasspaint.midY
        )
        particleEmitter_glasspaint.emitterShape = .circle
        particleEmitter_glasspaint.emitterSize = CGSize(width: 20, height: 20)
        particleEmitter_glasspaint.renderMode = .additive
        
        let particle_glasspaint = CAEmitterCell()
        particle_glasspaint.contents = createCircleImage_Glasspaint().cgImage
        particle_glasspaint.birthRate = 50
        particle_glasspaint.lifetime = 0.8
        particle_glasspaint.velocity = 80
        particle_glasspaint.velocityRange = 40
        particle_glasspaint.emissionRange = .pi * 2
        particle_glasspaint.scale = 0.15
        particle_glasspaint.scaleRange = 0.1
        particle_glasspaint.alphaSpeed = -1.2
        particle_glasspaint.color = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        
        particleEmitter_glasspaint.emitterCells = [particle_glasspaint]
        view.layer.addSublayer(particleEmitter_glasspaint)
        
        // 0.1秒后停止发射
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            particleEmitter_glasspaint.birthRate = 0
        }
        
        // 1秒后移除
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            particleEmitter_glasspaint.removeFromSuperlayer()
        }
    }
    
    /// 创建圆形图像（用于粒子）
    private func createCircleImage_Glasspaint() -> UIImage {
        let size_glasspaint = CGSize(width: 8, height: 8)
        let renderer_glasspaint = UIGraphicsImageRenderer(size: size_glasspaint)
        
        return renderer_glasspaint.image { context_glasspaint in
            let rect_glasspaint = CGRect(origin: .zero, size: size_glasspaint)
            context_glasspaint.cgContext.setFillColor(UIColor.white.cgColor)
            context_glasspaint.cgContext.fillEllipse(in: rect_glasspaint)
        }
    }
    
    // MARK: - 背景和装饰
    
    /// 设置背景渐变
    private func setupBackgroundGradient_Glasspaint() {
        // 渐变层设置
        backgroundGradientLayer_Glasspaint.colors = [
            ColorConfig_Glasspaint.backgroundPrimary_Glasspaint.cgColor,
            UIColor(hexstring_Glasspaint: "#F0F4F8").cgColor,
            ColorConfig_Glasspaint.backgroundSecondary_Glasspaint.cgColor
        ]
        backgroundGradientLayer_Glasspaint.locations = [0.0, 0.5, 1.0]
        backgroundGradientLayer_Glasspaint.startPoint = CGPoint(x: 0, y: 0)
        backgroundGradientLayer_Glasspaint.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(backgroundGradientLayer_Glasspaint, at: 0)
    }
    
    /// 设置装饰元素
    private func setupDecorationElements_Glasspaint() {
        // 装饰圆圈1（右上角）
        view.addSubview(decorCircle1_Glasspaint)
        decorCircle1_Glasspaint.backgroundColor = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.withAlphaComponent(0.08)
        decorCircle1_Glasspaint.layer.cornerRadius = 150
        
        decorCircle1_Glasspaint.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(-80)
            make.right.equalToSuperview().offset(80)
            make.width.height.equalTo(300)
        }
        
        // 装饰圆圈2（左下角）
        view.addSubview(decorCircle2_Glasspaint)
        decorCircle2_Glasspaint.backgroundColor = ColorConfig_Glasspaint.secondaryGradientStart_Glasspaint.withAlphaComponent(0.06)
        decorCircle2_Glasspaint.layer.cornerRadius = 120
        
        decorCircle2_Glasspaint.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(60)
            make.left.equalToSuperview().offset(-60)
            make.width.height.equalTo(240)
        }
        
        // 添加旋转动画
        animateDecorationCircles_Glasspaint()
        
        // 添加粒子效果
        setupParticleEffect_Glasspaint()
    }
    
    /// 装饰圆圈动画
    private func animateDecorationCircles_Glasspaint() {
        // 圆圈1旋转动画
        let rotation1_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation1_glasspaint.fromValue = 0
        rotation1_glasspaint.toValue = Double.pi * 2
        rotation1_glasspaint.duration = 60
        rotation1_glasspaint.repeatCount = .infinity
        decorCircle1_Glasspaint.layer.add(rotation1_glasspaint, forKey: "rotation1")
        
        // 圆圈2反向旋转
        let rotation2_glasspaint = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation2_glasspaint.fromValue = 0
        rotation2_glasspaint.toValue = -Double.pi * 2
        rotation2_glasspaint.duration = 80
        rotation2_glasspaint.repeatCount = .infinity
        decorCircle2_Glasspaint.layer.add(rotation2_glasspaint, forKey: "rotation2")
        
        // 脉冲效果
        UIView.animate(withDuration: 3.0, delay: 0, options: [.repeat, .autoreverse, .curveEaseInOut]) {
            self.decorCircle1_Glasspaint.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            self.decorCircle2_Glasspaint.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    /// 设置粒子效果
    private func setupParticleEffect_Glasspaint() {
        // 粒子层配置
        particleLayer_Glasspaint.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -20)
        particleLayer_Glasspaint.emitterShape = .line
        particleLayer_Glasspaint.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        // 创建粒子单元（星星）
        let particleCell_glasspaint = CAEmitterCell()
        particleCell_glasspaint.contents = createStarImage_Glasspaint().cgImage
        particleCell_glasspaint.birthRate = 3
        particleCell_glasspaint.lifetime = 12
        particleCell_glasspaint.lifetimeRange = 4
        particleCell_glasspaint.velocity = 30
        particleCell_glasspaint.velocityRange = 20
        particleCell_glasspaint.emissionLongitude = .pi // 向下
        particleCell_glasspaint.emissionRange = .pi / 8
        particleCell_glasspaint.spin = 2
        particleCell_glasspaint.spinRange = 4
        particleCell_glasspaint.scale = 0.15
        particleCell_glasspaint.scaleRange = 0.1
        particleCell_glasspaint.alphaSpeed = -0.1
        particleCell_glasspaint.alphaRange = 0.3
        
        // 设置颜色（使用主题色）
        particleCell_glasspaint.color = ColorConfig_Glasspaint.primaryGradientStart_Glasspaint.cgColor
        particleCell_glasspaint.redRange = 0.2
        particleCell_glasspaint.greenRange = 0.2
        particleCell_glasspaint.blueRange = 0.3
        
        particleLayer_Glasspaint.emitterCells = [particleCell_glasspaint]
        view.layer.insertSublayer(particleLayer_Glasspaint, at: 1)
    }
    
    /// 创建星星图像（用于粒子）
    private func createStarImage_Glasspaint() -> UIImage {
        let size_glasspaint = CGSize(width: 20, height: 20)
        let renderer_glasspaint = UIGraphicsImageRenderer(size: size_glasspaint)
        
        return renderer_glasspaint.image { context_glasspaint in
            let ctx_glasspaint = context_glasspaint.cgContext
            
            // 绘制星星路径
            let center_glasspaint = CGPoint(x: size_glasspaint.width / 2, y: size_glasspaint.height / 2)
            let radius_glasspaint: CGFloat = 8
            let innerRadius_glasspaint: CGFloat = 4
            let points_glasspaint = 5
            
            ctx_glasspaint.beginPath()
            
            for i_glasspaint in 0..<points_glasspaint * 2 {
                let angle_glasspaint = CGFloat(i_glasspaint) * .pi / CGFloat(points_glasspaint) - .pi / 2
                let r_glasspaint = (i_glasspaint % 2 == 0) ? radius_glasspaint : innerRadius_glasspaint
                let x_glasspaint = center_glasspaint.x + r_glasspaint * cos(angle_glasspaint)
                let y_glasspaint = center_glasspaint.y + r_glasspaint * sin(angle_glasspaint)
                
                if i_glasspaint == 0 {
                    ctx_glasspaint.move(to: CGPoint(x: x_glasspaint, y: y_glasspaint))
                } else {
                    ctx_glasspaint.addLine(to: CGPoint(x: x_glasspaint, y: y_glasspaint))
                }
            }
            
            ctx_glasspaint.closePath()
            ctx_glasspaint.setFillColor(UIColor.white.cgColor)
            ctx_glasspaint.fillPath()
        }
    }
    
    // MARK: - 滚动视图代理
    
    /// 监听滚动，实现导航栏毛玻璃效果
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset_glasspaint = scrollView.contentOffset.y
        let alpha_glasspaint = min(1, max(0, offset_glasspaint / 50))
        navBlurEffect_Glasspaint.alpha = alpha_glasspaint
    }
    
    // MARK: - 布局更新
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 更新渐变层大小
        backgroundGradientLayer_Glasspaint.frame = view.bounds
        // 更新粒子层位置
        particleLayer_Glasspaint.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -20)
        particleLayer_Glasspaint.emitterSize = CGSize(width: view.bounds.width, height: 1)
        
        // 确保头像圆角正确显示
        let avatarRadius_glasspaint = avatarView_Glasspaint.bounds.width / 2
        avatarView_Glasspaint.layer.cornerRadius = avatarRadius_glasspaint
        avatarView_Glasspaint.imageView_Glasspaint.layer.cornerRadius = avatarRadius_glasspaint
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UICollectionView Delegate & DataSource

extension Home_Glasspaint: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommendations_Glasspaint.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell_glasspaint = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RecommendationCardCell",
            for: indexPath
        ) as! RecommendationCardCell_Glasspaint
        
        let post_glasspaint = recommendations_Glasspaint[indexPath.item]
        cell_glasspaint.configure_Glasspaint(with_glasspaint: post_glasspaint)
        
        // 添加入场动画
        cell_glasspaint.alpha = 0
        cell_glasspaint.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(
            withDuration: AnimationConfig_Glasspaint.durationSpring_Glasspaint,
            delay: Double(indexPath.item) * AnimationConfig_Glasspaint.delayShort_Glasspaint,
            usingSpringWithDamping: AnimationConfig_Glasspaint.springDampingNormal_Glasspaint,
            initialSpringVelocity: AnimationConfig_Glasspaint.springVelocity_Glasspaint
        ) {
            cell_glasspaint.alpha = 1.0
            cell_glasspaint.transform = .identity
        }
        
        return cell_glasspaint
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post_glasspaint = recommendations_Glasspaint[indexPath.item]
        Navigation_Glasspaint.toTitleDetail_Glasspaint(titleModel_glasspaint: post_glasspaint)
    }
}

// MARK: - 推荐卡片单元格

/// 推荐卡片单元格
class RecommendationCardCell_Glasspaint: UICollectionViewCell {
    
    private let cardView_Glasspaint = RecommendationCard_Glasspaint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardView_Glasspaint)
        cardView_Glasspaint.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure_Glasspaint(with_glasspaint post_glasspaint: TitleModel_Glasspaint) {
        cardView_Glasspaint.configure_Glasspaint(with_glasspaint: post_glasspaint)
    }
}
