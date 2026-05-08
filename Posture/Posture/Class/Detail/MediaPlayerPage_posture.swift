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
///   - 媒体路径与 MediaDisplayView_Posture 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Posture:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Posture:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Posture: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Posture: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Posture: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Posture: MediaType_Posture = .none_Posture

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Posture = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Posture: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Posture: AVPlayer?
    private var playerLayer_Posture: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Posture: Any?
    /// 是否处于播放状态
    private var isPlaying_Posture = false

    // MARK: - UI：黑色背景

    private let backgroundView_Posture: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Posture: UIScrollView = {
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

    private let imageView_Posture: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Posture: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Posture: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Posture = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Posture), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Posture), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Posture: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Posture: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Posture: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Posture: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Posture: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Posture: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Posture = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Posture), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Posture: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Posture: UILabel = {
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
        buildUI_Posture()
        buildConstraints_Posture()
        bindGestures_Posture()
        loadMedia_Posture()
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
        cleanupPlayer_Posture()
    }

    deinit {
        cleanupPlayer_Posture()
    }

    // MARK: - UI 搭建

    private func buildUI_Posture() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Posture)

        // 图片容器
        view.addSubview(scrollView_Posture)
        scrollView_Posture.addSubview(imageView_Posture)
        scrollView_Posture.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Posture)
        videoContainerView_Posture.addSubview(playPauseButton_Posture)
        videoContainerView_Posture.addSubview(progressBg_Posture)
        progressBg_Posture.addSubview(progressFill_Posture)

        // 通用
        view.addSubview(loadingIndicator_Posture)
        view.addSubview(topBar_Posture)
        topBar_Posture.addSubview(closeButton_Posture)
        topBar_Posture.addSubview(mediaTypeLabel_Posture)
        view.addSubview(bottomHint_Posture)
    }

    private func buildConstraints_Posture() {
        backgroundView_Posture.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Posture.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Posture.frame = view.bounds

        videoContainerView_Posture.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Posture.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Posture.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Posture.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Posture = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Posture.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Posture.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Posture.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Posture.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Posture.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Posture.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Posture?.frame = videoContainerView_Posture.bounds
        updateImageLayout_Posture()
    }

    // MARK: - 手势

    private func bindGestures_Posture() {
        // 双击缩放（图片）
        let doubleTap_Posture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Posture(_:)))
        doubleTap_Posture.numberOfTapsRequired = 2
        scrollView_Posture.addGestureRecognizer(doubleTap_Posture)

        // 单击关闭 / 视频播放切换
        let singleTap_Posture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Posture))
        singleTap_Posture.numberOfTapsRequired = 1
        singleTap_Posture.require(toFail: doubleTap_Posture)
        scrollView_Posture.addGestureRecognizer(singleTap_Posture)

        // 视频区单击切换播放/暂停
        let videoTap_Posture = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Posture))
        videoContainerView_Posture.addGestureRecognizer(videoTap_Posture)

        // 下滑关闭
        let pan_Posture = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Posture(_:)))
        pan_Posture.delegate = self
        view.addGestureRecognizer(pan_Posture)

        // 播放/暂停按钮
        playPauseButton_Posture.addTarget(self, action: #selector(togglePlayPause_Posture), for: .touchUpInside)
        closeButton_Posture.addTarget(self, action: #selector(closeTapped_Posture), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Posture 和 isVideo_Posture 加载媒体
    private func loadMedia_Posture() {
        guard let path_Posture = mediaPath_Posture, !path_Posture.isEmpty else { showEmpty_Posture(); return }
        loadingIndicator_Posture.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Posture, let url_Posture = resolveVideoURL_Posture(path_Posture) {
            setupVideoPlayer_Posture(url_Posture: url_Posture)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Posture = resolveVideoURL_Posture(path_Posture) {
            setupVideoPlayer_Posture(url_Posture: url_Posture)
            return
        }

        // 图片加载流程
        resolvedType_Posture = .image_Posture
        loadImage_Posture(path_Posture: path_Posture)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Posture: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Posture(_ path_Posture: String) -> URL? {
        // Bundle 资源
        if let url_Posture = MediaDisplayView_Posture.bundleVideoURL_Posture(named: path_Posture) {
            return url_Posture
        }
        // Documents 目录视频文件
        let docs_Posture = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Posture in ["mp4", "mov", "m4v"] {
            let url_Posture = docs_Posture.appendingPathComponent("\(path_Posture).\(ext_Posture)")
            if FileManager.default.fileExists(atPath: url_Posture.path) { return url_Posture }
        }
        // 已带扩展名的文档目录文件
        let direct_Posture = docs_Posture.appendingPathComponent(path_Posture)
        if FileManager.default.fileExists(atPath: direct_Posture.path) { return direct_Posture }
        // 网络视频 URL
        if (path_Posture.hasPrefix("http://") || path_Posture.hasPrefix("https://")),
           let url_Posture = URL(string: path_Posture) {
            let ext_Posture = (path_Posture as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Posture) { return url_Posture }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Posture 策略对齐）
    /// - Parameter path_Posture: 媒体路径
    private func loadImage_Posture(path_Posture: String) {
        // SF Symbols
        if let img_Posture = UIImage(systemName: path_Posture) { applyImage_Posture(img_Posture); return }
        // Assets
        if let img_Posture = UIImage(named: path_Posture) { applyImage_Posture(img_Posture); return }
        // 网络
        if path_Posture.hasPrefix("http://") || path_Posture.hasPrefix("https://") {
            guard let url_Posture = URL(string: path_Posture) else { showEmpty_Posture(); return }
            imageView_Posture.kf.setImage(with: url_Posture, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Posture.stopAnimating()
                if case .success(let v_Posture) = result { self?.onImageLoaded_Posture(v_Posture.image) }
                else { self?.showEmpty_Posture() }
            }
            return
        }
        // Documents 文件名
        let docs_Posture = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Posture = docs_Posture.appendingPathComponent(path_Posture)
        if let img_Posture = UIImage(contentsOfFile: docURL_Posture.path) { applyImage_Posture(img_Posture); return }
        // 完整路径
        if let img_Posture = UIImage(contentsOfFile: path_Posture) { applyImage_Posture(img_Posture); return }
        showEmpty_Posture()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Posture: 视频文件 URL
    private func setupVideoPlayer_Posture(url_Posture: URL) {
        resolvedType_Posture = .video_Posture

        // 切换到视频容器
        scrollView_Posture.isHidden         = true
        videoContainerView_Posture.isHidden = false
        progressBg_Posture.isHidden         = false

        mediaTypeLabel_Posture.text = "Video"

        let player_Posture  = AVPlayer(url: url_Posture)
        self.player_Posture = player_Posture
        let layer_Posture   = AVPlayerLayer(player: player_Posture)
        layer_Posture.videoGravity  = .resizeAspect
        layer_Posture.frame         = videoContainerView_Posture.bounds
        layer_Posture.backgroundColor = UIColor.black.cgColor
        videoContainerView_Posture.layer.insertSublayer(layer_Posture, at: 0)
        playerLayer_Posture = layer_Posture

        // 视频就绪后淡入播放按钮
        player_Posture.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Posture = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Posture = player_Posture.addPeriodicTimeObserver(
            forInterval: interval_Posture,
            queue: .main
        ) { [weak self] time_Posture in
            self?.updateProgress_Posture(currentTime_Posture: time_Posture)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Posture),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Posture.currentItem
        )

        loadingIndicator_Posture.stopAnimating()
        player_Posture.play()
        isPlaying_Posture = true
        playPauseButton_Posture.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Posture.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Posture: AVPlayer 当前时间
    private func updateProgress_Posture(currentTime_Posture: CMTime) {
        guard let duration_Posture = player_Posture?.currentItem?.duration,
              duration_Posture.isNumeric, duration_Posture.seconds > 0 else { return }
        let progress_Posture = CGFloat(currentTime_Posture.seconds / duration_Posture.seconds)
        let totalW_Posture   = progressBg_Posture.bounds.width
        progressWidthCon_Posture?.update(offset: totalW_Posture * min(max(progress_Posture, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Posture() {
        player_Posture?.seek(to: .zero)
        isPlaying_Posture = false
        playPauseButton_Posture.isSelected = false
        progressWidthCon_Posture?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Posture() {
        if let token_Posture = timeObserverToken_Posture {
            player_Posture?.removeTimeObserver(token_Posture)
            timeObserverToken_Posture = nil
        }
        player_Posture?.removeObserver(self, forKeyPath: "status")
        player_Posture?.pause()
        player_Posture = nil
        playerLayer_Posture?.removeFromSuperlayer()
        playerLayer_Posture = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Posture = object as? AVPlayer,
              player_Posture.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Posture() }
    }

    // MARK: - 图片辅助

    private func applyImage_Posture(_ image_Posture: UIImage) {
        loadingIndicator_Posture.stopAnimating()
        imageView_Posture.image = image_Posture
        imageSize_Posture       = image_Posture.size
        mediaTypeLabel_Posture.text = "Photo"
        updateImageLayout_Posture()
    }

    private func onImageLoaded_Posture(_ image_Posture: UIImage) {
        imageSize_Posture = image_Posture.size
        mediaTypeLabel_Posture.text = "Photo"
        updateImageLayout_Posture()
    }

    private func showEmpty_Posture() {
        loadingIndicator_Posture.stopAnimating()
        imageView_Posture.image       = UIImage(systemName: "photo.slash")
        imageView_Posture.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Posture.contentMode = .center
    }

    private func updateImageLayout_Posture() {
        guard imageSize_Posture != .zero else {
            imageView_Posture.frame = view.bounds
            scrollView_Posture.contentSize = view.bounds.size
            return
        }
        let screenW_Posture = view.bounds.width
        let screenH_Posture = view.bounds.height
        let ratio_Posture   = imageSize_Posture.height / imageSize_Posture.width
        let imgH_Posture    = screenW_Posture * ratio_Posture
        let y_Posture       = max(0, (screenH_Posture - imgH_Posture) / 2)
        imageView_Posture.frame        = CGRect(x: 0, y: y_Posture, width: screenW_Posture, height: imgH_Posture)
        scrollView_Posture.contentSize = CGSize(width: screenW_Posture,
                                              height: max(imgH_Posture + y_Posture * 2, screenH_Posture))
        scrollView_Posture.zoomScale   = 1.0
        centerImageIfNeeded_Posture()
    }

    private func centerImageIfNeeded_Posture() {
        let offX_Posture = max(0, (scrollView_Posture.bounds.width  - scrollView_Posture.contentSize.width)  / 2)
        let offY_Posture = max(0, (scrollView_Posture.bounds.height - scrollView_Posture.contentSize.height) / 2)
        imageView_Posture.center = CGPoint(
            x: scrollView_Posture.contentSize.width  / 2 + offX_Posture,
            y: scrollView_Posture.contentSize.height / 2 + offY_Posture
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Posture(_ gesture_Posture: UITapGestureRecognizer) {
        guard resolvedType_Posture == .image_Posture else { return }
        if scrollView_Posture.zoomScale > 1.0 {
            scrollView_Posture.setZoomScale(1.0, animated: true)
        } else {
            let pt_Posture    = gesture_Posture.location(in: imageView_Posture)
            let rect_Posture  = zoomRect_Posture(scale_Posture: 2.5, center_Posture: pt_Posture)
            scrollView_Posture.zoom(to: rect_Posture, animated: true)
        }
    }

    @objc private func handleSingleTap_Posture() {
        guard resolvedType_Posture != .video_Posture,
              scrollView_Posture.zoomScale <= 1.01 else { return }
        dismissPage_Posture(velocity_Posture: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Posture() {
        togglePlayPause_Posture()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Posture() {
        guard let player_Posture = player_Posture else { return }
        if isPlaying_Posture {
            player_Posture.pause()
            isPlaying_Posture = false
            playPauseButton_Posture.isSelected = false
        } else {
            player_Posture.play()
            isPlaying_Posture = true
            playPauseButton_Posture.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Posture.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Posture else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Posture.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Posture() {
        dismissPage_Posture(velocity_Posture: 0)
    }

    @objc private func handlePan_Posture(_ gesture_Posture: UIPanGestureRecognizer) {
        guard scrollView_Posture.zoomScale <= 1.01 else { return }
        let translation_Posture = gesture_Posture.translation(in: view)
        let velocity_Posture    = gesture_Posture.velocity(in: view).y
        switch gesture_Posture.state {
        case .changed:
            let progress_Posture         = max(0, translation_Posture.y / view.bounds.height)
            backgroundView_Posture.alpha = max(0, 1 - progress_Posture * 1.5)
            topBar_Posture.alpha         = max(0, 1 - progress_Posture * 2)
            bottomHint_Posture.alpha     = max(0, 1 - progress_Posture * 2)
            let activeView_Posture: UIView = resolvedType_Posture == .video_Posture
                ? videoContainerView_Posture : scrollView_Posture
            activeView_Posture.transform = CGAffineTransform(
                translationX: translation_Posture.x * 0.3,
                y: max(0, translation_Posture.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Posture = translation_Posture.y > view.bounds.height * 0.25 || velocity_Posture > 900
            if shouldDismiss_Posture {
                dismissPage_Posture(velocity_Posture: velocity_Posture)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Posture.transform         = .identity
                    self.videoContainerView_Posture.transform = .identity
                    self.backgroundView_Posture.alpha  = 1
                    self.topBar_Posture.alpha           = 1
                    self.bottomHint_Posture.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Posture: 下拉速度（影响动画时长）
    private func dismissPage_Posture(velocity_Posture: CGFloat) {
        guard !isDismissing_Posture else { return }
        isDismissing_Posture = true
        player_Posture?.pause()
        let duration_Posture = velocity_Posture > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Posture, animations: {
            self.view.alpha = 0
            let activeView_Posture: UIView = self.resolvedType_Posture == .video_Posture
                ? self.videoContainerView_Posture : self.scrollView_Posture
            activeView_Posture.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Posture(scale_Posture: CGFloat, center_Posture: CGPoint) -> CGRect {
        let w_Posture = scrollView_Posture.bounds.width  / scale_Posture
        let h_Posture = scrollView_Posture.bounds.height / scale_Posture
        return CGRect(x: center_Posture.x - w_Posture / 2,
                      y: center_Posture.y - h_Posture / 2,
                      width: w_Posture, height: h_Posture)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Posture: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Posture }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Posture() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Posture: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Posture = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Posture.zoomScale <= 1.01 else { return false }
        let vel_Posture = pan_Posture.velocity(in: view)
        return abs(vel_Posture.y) > abs(vel_Posture.x) && vel_Posture.y > 0
    }
}
