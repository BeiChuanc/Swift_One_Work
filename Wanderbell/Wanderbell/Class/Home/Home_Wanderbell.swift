import Foundation
import UIKit
import SnapKit

// MARK: 首页

/// 首页页面 - 情绪记录仪表盘
/// 功能：展示用户情绪数据统计、日历、趋势图表和最近记录
/// 设计：数据仪表盘风格、卡片式布局、渐变配色
class Home_Wanderbell: UIViewController {
    
    // MARK: - UI组件
    
    /// 滚动容器
    private let scrollView_Wanderbell: UIScrollView = {
        let scrollView_wanderbell = UIScrollView()
        scrollView_wanderbell.showsVerticalScrollIndicator = false
        scrollView_wanderbell.backgroundColor = ColorConfig_Wanderbell.backgroundPrimary_Wanderbell
        return scrollView_wanderbell
    }()
    
    /// 内容容器
    private let contentView_Wanderbell = UIView()
    
    /// 页面标题
    private lazy var pageTitleView_Wanderbell: PageHeaderView_Wanderbell = {
        return PageHeaderView_Wanderbell(
            title_wanderbell: "Vessel",
            subtitle_wanderbell: "Your emotional journey dashboard",
            iconName_wanderbell: "heart.text.square.fill",
            iconColor_wanderbell: ColorConfig_Wanderbell.primaryGradientStart_Wanderbell
        )
    }()
    
    /// 头部卡片
    private let headerCard_Wanderbell = HomeHeaderCard_Wanderbell()
    
    /// 情绪日历
    private let emotionCalendar_Wanderbell = EmotionCalendar_Wanderbell()
    
    /// 统计卡片（增强版）
    private let statisticsCard_Wanderbell = ImprovedEmotionStatisticsCard_Wanderbell()
    
    /// 趋势图表（增强版）
    private let trendChart_Wanderbell = ImprovedEmotionTrendChart_Wanderbell()
    
    /// 最近记录
    private let recentRecords_Wanderbell = RecentRecordsSection_Wanderbell()
    
    /// 情绪选择器
    private var emotionPicker_Wanderbell: EmotionPickerView_Wanderbell?
    
    // MARK: - 生命周期
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI_Wanderbell()
        setupConstraints_Wanderbell()
        setupCallbacks_Wanderbell()
        animateAppearance_Wanderbell()
    }
    
    // MARK: - UI设置
    
    /// 设置UI
    private func setupUI_Wanderbell() {
        // 设置首页渐变背景
        view.addHomeBackgroundGradient_Wanderbell()
        
        view.addSubview(scrollView_Wanderbell)
        scrollView_Wanderbell.addSubview(contentView_Wanderbell)
        
        contentView_Wanderbell.addSubview(pageTitleView_Wanderbell)
        contentView_Wanderbell.addSubview(headerCard_Wanderbell)
        contentView_Wanderbell.addSubview(emotionCalendar_Wanderbell)
        contentView_Wanderbell.addSubview(statisticsCard_Wanderbell)
        contentView_Wanderbell.addSubview(trendChart_Wanderbell)
        contentView_Wanderbell.addSubview(recentRecords_Wanderbell)
    }
    
    /// 设置约束
    private func setupConstraints_Wanderbell() {
        scrollView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView_Wanderbell.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view.snp.width)
        }
        
        pageTitleView_Wanderbell.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(80)
        }
        
        headerCard_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(pageTitleView_Wanderbell.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(120)
        }
        
        emotionCalendar_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(headerCard_Wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(350)
        }
        
        statisticsCard_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(emotionCalendar_Wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(150)
        }
        
        trendChart_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(statisticsCard_Wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(200)
        }
        
        recentRecords_Wanderbell.snp.makeConstraints { make in
            make.top.equalTo(trendChart_Wanderbell.snp.bottom).offset(20)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-120)
        }
    }
    
    /// 设置回调
    private func setupCallbacks_Wanderbell() {
        // 快速记录按钮点击
        headerCard_Wanderbell.onQuickRecordTapped_Wanderbell = { [weak self] in
            self?.showEmotionPicker_Wanderbell()
        }
        
        // 日历日期选择
        emotionCalendar_Wanderbell.onDateSelected_Wanderbell = { [weak self] date_wanderbell in
            self?.showDayEmotionDetail_Wanderbell(date_wanderbell: date_wanderbell)
        }
    }
    
    /// 显示情绪选择器
    private func showEmotionPicker_Wanderbell() {
        let picker_wanderbell = EmotionPickerView_Wanderbell()
        picker_wanderbell.onEmotionSelected_Wanderbell = { [weak self] emotionType_wanderbell, intensity_wanderbell in
            self?.handleEmotionSelected_Wanderbell(emotionType_wanderbell: emotionType_wanderbell, intensity_wanderbell: intensity_wanderbell)
        }
        emotionPicker_Wanderbell = picker_wanderbell
        picker_wanderbell.show_Wanderbell(in: self)
    }
    
    /// 处理情绪选择
    private func handleEmotionSelected_Wanderbell(emotionType_wanderbell: EmotionType_Wanderbell, intensity_wanderbell: Int) {
        // 添加情绪记录
        EmotionViewModel_Wanderbell.shared_Wanderbell.addEmotionRecord_Wanderbell(
            emotionType_wanderbell: emotionType_wanderbell,
            customEmotion_wanderbell: nil,
            intensity_wanderbell: intensity_wanderbell,
            note_wanderbell: "Quick record",
            media_wanderbell: [],
            tags_wanderbell: []
        )
    }
    
    /// 显示日期情绪详情
    /// 功能：弹窗展示选中日期的所有情绪记录
    /// 参数：
    /// - date_wanderbell: 选中的日期
    private func showDayEmotionDetail_Wanderbell(date_wanderbell: Date) {
        let detailView_wanderbell = DayEmotionDetailView_Wanderbell(date_wanderbell: date_wanderbell)
        detailView_wanderbell.show_Wanderbell(in: self)
    }
    
    /// 动画出现
    private func animateAppearance_Wanderbell() {
        // 标题淡入
        pageTitleView_Wanderbell.animateFadeIn_Wanderbell(delay_wanderbell: 0)
        
        // 启动图标呼吸动画
        pageTitleView_Wanderbell.startBreathingAnimation_Wanderbell()
        
        // 其他卡片依次滑入
        let views_wanderbell = [headerCard_Wanderbell, emotionCalendar_Wanderbell, statisticsCard_Wanderbell, trendChart_Wanderbell, recentRecords_Wanderbell]
        
        for (index_wanderbell, view_wanderbell) in views_wanderbell.enumerated() {
            view_wanderbell.animateSlideInFromBottom_Wanderbell(
                offset_wanderbell: 30,
                delay_wanderbell: TimeInterval(index_wanderbell + 1) * 0.1
            )
        }
    }
}
