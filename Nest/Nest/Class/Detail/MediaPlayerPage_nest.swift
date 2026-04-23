import UIKit
import SnapKit
import Kingfisher
import AVFoundation

// MARK: - 全屏媒体浏览页

/// 全屏媒体浏览页
/// 核心作用：
///   - 图片模式：以沉浸式黑底全屏展示，支持双指缩放、双击放大/还原、下滑关闭
///   - 视频模式：通过 AVPlayer 播放 Bundle / Documents / 网络视频，支持播放/暂停、进度条、下滑关闭
/// 设计思路：
///   - 媒体路径与 MediaDisplayView_Nest 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Nest:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Nest:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Nest: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Nest: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Nest: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Nest: MediaType_Nest = .none_Nest

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Nest = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Nest: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Nest: AVPlayer?
    private var playerLayer_Nest: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Nest: Any?
    /// 是否处于播放状态
    private var isPlaying_Nest = false

    // MARK: - UI：黑色背景

    private let backgroundView_Nest: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Nest: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator   = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never
        sv.bouncesZoom      = true
        sv.minimumZoomScale = 1.0
        sv.maximumZoomScale = 4.0
        sv.backgroundColor  = .clear
        return sv
    }()

    private let imageView_Nest: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Nest: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Nest: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Nest), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Nest), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Nest: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Nest: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Nest: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Nest: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Nest: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Nest: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Nest = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Nest), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Nest: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Nest: UILabel = {
        let l = UILabel()
        l.text          = "Swipe down to close"
        l.font          = .systemFont(ofSize: 11, weight: .regular)
        l.textColor     = UIColor.white.withAlphaComponent(0.45)
        l.textAlignment = .center
        return l
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI_Nest()
        buildConstraints_Nest()
        bindGestures_Nest()
        loadMedia_Nest()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 进场前预设透明，由 viewDidAppear 统一淡入，避免与系统转场动画叠加导致闪烁
        view.alpha = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) { self.view.alpha = 1 }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cleanupPlayer_Nest()
    }

    deinit {
        cleanupPlayer_Nest()
    }

    // MARK: - UI 搭建

    private func buildUI_Nest() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Nest)

        // 图片容器
        view.addSubview(scrollView_Nest)
        scrollView_Nest.addSubview(imageView_Nest)
        scrollView_Nest.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Nest)
        videoContainerView_Nest.addSubview(playPauseButton_Nest)
        videoContainerView_Nest.addSubview(progressBg_Nest)
        progressBg_Nest.addSubview(progressFill_Nest)

        // 通用
        view.addSubview(loadingIndicator_Nest)
        view.addSubview(topBar_Nest)
        topBar_Nest.addSubview(closeButton_Nest)
        topBar_Nest.addSubview(mediaTypeLabel_Nest)
        view.addSubview(bottomHint_Nest)
    }

    private func buildConstraints_Nest() {
        backgroundView_Nest.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Nest.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Nest.frame = view.bounds

        videoContainerView_Nest.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Nest.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Nest.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Nest.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Nest = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Nest.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Nest.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Nest.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Nest.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Nest.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Nest.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Nest?.frame = videoContainerView_Nest.bounds
        updateImageLayout_Nest()
    }

    // MARK: - 手势

    private func bindGestures_Nest() {
        // 双击缩放（图片）
        let doubleTap_Nest = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Nest(_:)))
        doubleTap_Nest.numberOfTapsRequired = 2
        scrollView_Nest.addGestureRecognizer(doubleTap_Nest)

        // 单击关闭 / 视频播放切换
        let singleTap_Nest = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Nest))
        singleTap_Nest.numberOfTapsRequired = 1
        singleTap_Nest.require(toFail: doubleTap_Nest)
        scrollView_Nest.addGestureRecognizer(singleTap_Nest)

        // 视频区单击切换播放/暂停
        let videoTap_Nest = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Nest))
        videoContainerView_Nest.addGestureRecognizer(videoTap_Nest)

        // 下滑关闭
        let pan_Nest = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Nest(_:)))
        pan_Nest.delegate = self
        view.addGestureRecognizer(pan_Nest)

        // 播放/暂停按钮
        playPauseButton_Nest.addTarget(self, action: #selector(togglePlayPause_Nest), for: .touchUpInside)
        closeButton_Nest.addTarget(self, action: #selector(closeTapped_Nest), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Nest 和 isVideo_Nest 加载媒体
    private func loadMedia_Nest() {
        guard let path_Nest = mediaPath_Nest, !path_Nest.isEmpty else { showEmpty_Nest(); return }
        loadingIndicator_Nest.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Nest, let url_Nest = resolveVideoURL_Nest(path_Nest) {
            setupVideoPlayer_Nest(url_Nest: url_Nest)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Nest = resolveVideoURL_Nest(path_Nest) {
            setupVideoPlayer_Nest(url_Nest: url_Nest)
            return
        }

        // 图片加载流程
        resolvedType_Nest = .image_Nest
        loadImage_Nest(path_Nest: path_Nest)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Nest: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Nest(_ path_Nest: String) -> URL? {
        // Bundle 资源
        if let url_Nest = MediaDisplayView_Nest.bundleVideoURL_Nest(named: path_Nest) {
            return url_Nest
        }
        // Documents 目录视频文件
        let docs_Nest = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Nest in ["mp4", "mov", "m4v"] {
            let url_Nest = docs_Nest.appendingPathComponent("\(path_Nest).\(ext_Nest)")
            if FileManager.default.fileExists(atPath: url_Nest.path) { return url_Nest }
        }
        // 已带扩展名的文档目录文件
        let direct_Nest = docs_Nest.appendingPathComponent(path_Nest)
        if FileManager.default.fileExists(atPath: direct_Nest.path) { return direct_Nest }
        // 网络视频 URL
        if (path_Nest.hasPrefix("http://") || path_Nest.hasPrefix("https://")),
           let url_Nest = URL(string: path_Nest) {
            let ext_Nest = (path_Nest as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Nest) { return url_Nest }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Nest 策略对齐）
    /// - Parameter path_Nest: 媒体路径
    private func loadImage_Nest(path_Nest: String) {
        // SF Symbols
        if let img_Nest = UIImage(systemName: path_Nest) { applyImage_Nest(img_Nest); return }
        // Assets
        if let img_Nest = UIImage(named: path_Nest) { applyImage_Nest(img_Nest); return }
        // 网络
        if path_Nest.hasPrefix("http://") || path_Nest.hasPrefix("https://") {
            guard let url_Nest = URL(string: path_Nest) else { showEmpty_Nest(); return }
            imageView_Nest.kf.setImage(with: url_Nest, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Nest.stopAnimating()
                if case .success(let v_Nest) = result { self?.onImageLoaded_Nest(v_Nest.image) }
                else { self?.showEmpty_Nest() }
            }
            return
        }
        // Documents 文件名
        let docs_Nest = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Nest = docs_Nest.appendingPathComponent(path_Nest)
        if let img_Nest = UIImage(contentsOfFile: docURL_Nest.path) { applyImage_Nest(img_Nest); return }
        // 完整路径
        if let img_Nest = UIImage(contentsOfFile: path_Nest) { applyImage_Nest(img_Nest); return }
        showEmpty_Nest()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Nest: 视频文件 URL
    private func setupVideoPlayer_Nest(url_Nest: URL) {
        resolvedType_Nest = .video_Nest

        // 切换到视频容器
        scrollView_Nest.isHidden         = true
        videoContainerView_Nest.isHidden = false
        progressBg_Nest.isHidden         = false

        mediaTypeLabel_Nest.text = "Video"

        let player_Nest  = AVPlayer(url: url_Nest)
        self.player_Nest = player_Nest
        let layer_Nest   = AVPlayerLayer(player: player_Nest)
        layer_Nest.videoGravity  = .resizeAspect
        layer_Nest.frame         = videoContainerView_Nest.bounds
        layer_Nest.backgroundColor = UIColor.black.cgColor
        videoContainerView_Nest.layer.insertSublayer(layer_Nest, at: 0)
        playerLayer_Nest = layer_Nest

        // 视频就绪后淡入播放按钮
        player_Nest.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Nest = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Nest = player_Nest.addPeriodicTimeObserver(
            forInterval: interval_Nest,
            queue: .main
        ) { [weak self] time_Nest in
            self?.updateProgress_Nest(currentTime_Nest: time_Nest)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Nest),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Nest.currentItem
        )

        loadingIndicator_Nest.stopAnimating()
        player_Nest.play()
        isPlaying_Nest = true
        playPauseButton_Nest.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Nest.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Nest: AVPlayer 当前时间
    private func updateProgress_Nest(currentTime_Nest: CMTime) {
        guard let duration_Nest = player_Nest?.currentItem?.duration,
              duration_Nest.isNumeric, duration_Nest.seconds > 0 else { return }
        let progress_Nest = CGFloat(currentTime_Nest.seconds / duration_Nest.seconds)
        let totalW_Nest   = progressBg_Nest.bounds.width
        progressWidthCon_Nest?.update(offset: totalW_Nest * min(max(progress_Nest, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Nest() {
        player_Nest?.seek(to: .zero)
        isPlaying_Nest = false
        playPauseButton_Nest.isSelected = false
        progressWidthCon_Nest?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Nest() {
        if let token_Nest = timeObserverToken_Nest {
            player_Nest?.removeTimeObserver(token_Nest)
            timeObserverToken_Nest = nil
        }
        player_Nest?.removeObserver(self, forKeyPath: "status")
        player_Nest?.pause()
        player_Nest = nil
        playerLayer_Nest?.removeFromSuperlayer()
        playerLayer_Nest = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Nest = object as? AVPlayer,
              player_Nest.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Nest() }
    }

    // MARK: - 图片辅助

    private func applyImage_Nest(_ image_Nest: UIImage) {
        loadingIndicator_Nest.stopAnimating()
        imageView_Nest.image = image_Nest
        imageSize_Nest       = image_Nest.size
        mediaTypeLabel_Nest.text = "Photo"
        updateImageLayout_Nest()
    }

    private func onImageLoaded_Nest(_ image_Nest: UIImage) {
        imageSize_Nest = image_Nest.size
        mediaTypeLabel_Nest.text = "Photo"
        updateImageLayout_Nest()
    }

    private func showEmpty_Nest() {
        loadingIndicator_Nest.stopAnimating()
        imageView_Nest.image       = UIImage(systemName: "photo.slash")
        imageView_Nest.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Nest.contentMode = .center
    }

    private func updateImageLayout_Nest() {
        guard imageSize_Nest != .zero else {
            imageView_Nest.frame = view.bounds
            scrollView_Nest.contentSize = view.bounds.size
            return
        }
        let screenW_Nest = view.bounds.width
        let screenH_Nest = view.bounds.height
        let ratio_Nest   = imageSize_Nest.height / imageSize_Nest.width
        let imgH_Nest    = screenW_Nest * ratio_Nest
        let y_Nest       = max(0, (screenH_Nest - imgH_Nest) / 2)
        imageView_Nest.frame        = CGRect(x: 0, y: y_Nest, width: screenW_Nest, height: imgH_Nest)
        scrollView_Nest.contentSize = CGSize(width: screenW_Nest,
                                              height: max(imgH_Nest + y_Nest * 2, screenH_Nest))
        scrollView_Nest.zoomScale   = 1.0
        centerImageIfNeeded_Nest()
    }

    private func centerImageIfNeeded_Nest() {
        let offX_Nest = max(0, (scrollView_Nest.bounds.width  - scrollView_Nest.contentSize.width)  / 2)
        let offY_Nest = max(0, (scrollView_Nest.bounds.height - scrollView_Nest.contentSize.height) / 2)
        imageView_Nest.center = CGPoint(
            x: scrollView_Nest.contentSize.width  / 2 + offX_Nest,
            y: scrollView_Nest.contentSize.height / 2 + offY_Nest
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Nest(_ gesture_Nest: UITapGestureRecognizer) {
        guard resolvedType_Nest == .image_Nest else { return }
        if scrollView_Nest.zoomScale > 1.0 {
            scrollView_Nest.setZoomScale(1.0, animated: true)
        } else {
            let pt_Nest    = gesture_Nest.location(in: imageView_Nest)
            let rect_Nest  = zoomRect_Nest(scale_Nest: 2.5, center_Nest: pt_Nest)
            scrollView_Nest.zoom(to: rect_Nest, animated: true)
        }
    }

    @objc private func handleSingleTap_Nest() {
        guard resolvedType_Nest != .video_Nest,
              scrollView_Nest.zoomScale <= 1.01 else { return }
        dismissPage_Nest(velocity_Nest: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Nest() {
        togglePlayPause_Nest()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Nest() {
        guard let player_Nest = player_Nest else { return }
        if isPlaying_Nest {
            player_Nest.pause()
            isPlaying_Nest = false
            playPauseButton_Nest.isSelected = false
        } else {
            player_Nest.play()
            isPlaying_Nest = true
            playPauseButton_Nest.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Nest.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Nest else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Nest.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Nest() {
        dismissPage_Nest(velocity_Nest: 0)
    }

    @objc private func handlePan_Nest(_ gesture_Nest: UIPanGestureRecognizer) {
        guard scrollView_Nest.zoomScale <= 1.01 else { return }
        let translation_Nest = gesture_Nest.translation(in: view)
        let velocity_Nest    = gesture_Nest.velocity(in: view).y
        switch gesture_Nest.state {
        case .changed:
            let progress_Nest         = max(0, translation_Nest.y / view.bounds.height)
            backgroundView_Nest.alpha = max(0, 1 - progress_Nest * 1.5)
            topBar_Nest.alpha         = max(0, 1 - progress_Nest * 2)
            bottomHint_Nest.alpha     = max(0, 1 - progress_Nest * 2)
            let activeView_Nest: UIView = resolvedType_Nest == .video_Nest
                ? videoContainerView_Nest : scrollView_Nest
            activeView_Nest.transform = CGAffineTransform(
                translationX: translation_Nest.x * 0.3,
                y: max(0, translation_Nest.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Nest = translation_Nest.y > view.bounds.height * 0.25 || velocity_Nest > 900
            if shouldDismiss_Nest {
                dismissPage_Nest(velocity_Nest: velocity_Nest)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Nest.transform         = .identity
                    self.videoContainerView_Nest.transform = .identity
                    self.backgroundView_Nest.alpha  = 1
                    self.topBar_Nest.alpha           = 1
                    self.bottomHint_Nest.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Nest: 下拉速度（影响动画时长）
    private func dismissPage_Nest(velocity_Nest: CGFloat) {
        guard !isDismissing_Nest else { return }
        isDismissing_Nest = true
        player_Nest?.pause()
        let duration_Nest = velocity_Nest > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Nest, animations: {
            self.view.alpha = 0
            let activeView_Nest: UIView = self.resolvedType_Nest == .video_Nest
                ? self.videoContainerView_Nest : self.scrollView_Nest
            activeView_Nest.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Nest(scale_Nest: CGFloat, center_Nest: CGPoint) -> CGRect {
        let w_Nest = scrollView_Nest.bounds.width  / scale_Nest
        let h_Nest = scrollView_Nest.bounds.height / scale_Nest
        return CGRect(x: center_Nest.x - w_Nest / 2,
                      y: center_Nest.y - h_Nest / 2,
                      width: w_Nest, height: h_Nest)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Nest: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Nest }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Nest() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Nest: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Nest = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Nest.zoomScale <= 1.01 else { return false }
        let vel_Nest = pan_Nest.velocity(in: view)
        return abs(vel_Nest.y) > abs(vel_Nest.x) && vel_Nest.y > 0
    }
}
