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
///   - 媒体路径与 MediaDisplayView_Breeze 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Breeze:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Breeze:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Breeze: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Breeze: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Breeze: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Breeze: MediaType_Breeze = .none_Breeze

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Breeze = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Breeze: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Breeze: AVPlayer?
    private var playerLayer_Breeze: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Breeze: Any?
    /// 是否处于播放状态
    private var isPlaying_Breeze = false

    // MARK: - UI：黑色背景

    private let backgroundView_Breeze: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Breeze: UIScrollView = {
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

    private let imageView_Breeze: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Breeze: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Breeze: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Breeze = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Breeze), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Breeze), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Breeze: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Breeze: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Breeze: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Breeze: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Breeze: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Breeze: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Breeze = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Breeze), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Breeze: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Breeze: UILabel = {
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
        buildUI_Breeze()
        buildConstraints_Breeze()
        bindGestures_Breeze()
        loadMedia_Breeze()
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
        cleanupPlayer_Breeze()
    }

    deinit {
        cleanupPlayer_Breeze()
    }

    // MARK: - UI 搭建

    private func buildUI_Breeze() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Breeze)

        // 图片容器
        view.addSubview(scrollView_Breeze)
        scrollView_Breeze.addSubview(imageView_Breeze)
        scrollView_Breeze.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Breeze)
        videoContainerView_Breeze.addSubview(playPauseButton_Breeze)
        videoContainerView_Breeze.addSubview(progressBg_Breeze)
        progressBg_Breeze.addSubview(progressFill_Breeze)

        // 通用
        view.addSubview(loadingIndicator_Breeze)
        view.addSubview(topBar_Breeze)
        topBar_Breeze.addSubview(closeButton_Breeze)
        topBar_Breeze.addSubview(mediaTypeLabel_Breeze)
        view.addSubview(bottomHint_Breeze)
    }

    private func buildConstraints_Breeze() {
        backgroundView_Breeze.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Breeze.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Breeze.frame = view.bounds

        videoContainerView_Breeze.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Breeze.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Breeze.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Breeze.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Breeze = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Breeze.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Breeze.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Breeze.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Breeze.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Breeze.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Breeze.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Breeze?.frame = videoContainerView_Breeze.bounds
        updateImageLayout_Breeze()
    }

    // MARK: - 手势

    private func bindGestures_Breeze() {
        // 双击缩放（图片）
        let doubleTap_Breeze = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Breeze(_:)))
        doubleTap_Breeze.numberOfTapsRequired = 2
        scrollView_Breeze.addGestureRecognizer(doubleTap_Breeze)

        // 单击关闭 / 视频播放切换
        let singleTap_Breeze = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Breeze))
        singleTap_Breeze.numberOfTapsRequired = 1
        singleTap_Breeze.require(toFail: doubleTap_Breeze)
        scrollView_Breeze.addGestureRecognizer(singleTap_Breeze)

        // 视频区单击切换播放/暂停
        let videoTap_Breeze = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Breeze))
        videoContainerView_Breeze.addGestureRecognizer(videoTap_Breeze)

        // 下滑关闭
        let pan_Breeze = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Breeze(_:)))
        pan_Breeze.delegate = self
        view.addGestureRecognizer(pan_Breeze)

        // 播放/暂停按钮
        playPauseButton_Breeze.addTarget(self, action: #selector(togglePlayPause_Breeze), for: .touchUpInside)
        closeButton_Breeze.addTarget(self, action: #selector(closeTapped_Breeze), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Breeze 和 isVideo_Breeze 加载媒体
    private func loadMedia_Breeze() {
        guard let path_Breeze = mediaPath_Breeze, !path_Breeze.isEmpty else { showEmpty_Breeze(); return }
        loadingIndicator_Breeze.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Breeze, let url_Breeze = resolveVideoURL_Breeze(path_Breeze) {
            setupVideoPlayer_Breeze(url_Breeze: url_Breeze)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Breeze = resolveVideoURL_Breeze(path_Breeze) {
            setupVideoPlayer_Breeze(url_Breeze: url_Breeze)
            return
        }

        // 图片加载流程
        resolvedType_Breeze = .image_Breeze
        loadImage_Breeze(path_Breeze: path_Breeze)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Breeze: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Breeze(_ path_Breeze: String) -> URL? {
        // Bundle 资源
        if let url_Breeze = MediaDisplayView_Breeze.bundleVideoURL_Breeze(named: path_Breeze) {
            return url_Breeze
        }
        // Documents 目录视频文件
        let docs_Breeze = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Breeze in ["mp4", "mov", "m4v"] {
            let url_Breeze = docs_Breeze.appendingPathComponent("\(path_Breeze).\(ext_Breeze)")
            if FileManager.default.fileExists(atPath: url_Breeze.path) { return url_Breeze }
        }
        // 已带扩展名的文档目录文件
        let direct_Breeze = docs_Breeze.appendingPathComponent(path_Breeze)
        if FileManager.default.fileExists(atPath: direct_Breeze.path) { return direct_Breeze }
        // 网络视频 URL
        if (path_Breeze.hasPrefix("http://") || path_Breeze.hasPrefix("https://")),
           let url_Breeze = URL(string: path_Breeze) {
            let ext_Breeze = (path_Breeze as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Breeze) { return url_Breeze }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Breeze 策略对齐）
    /// - Parameter path_Breeze: 媒体路径
    private func loadImage_Breeze(path_Breeze: String) {
        // SF Symbols
        if let img_Breeze = UIImage(systemName: path_Breeze) { applyImage_Breeze(img_Breeze); return }
        // Assets
        if let img_Breeze = UIImage(named: path_Breeze) { applyImage_Breeze(img_Breeze); return }
        // 网络
        if path_Breeze.hasPrefix("http://") || path_Breeze.hasPrefix("https://") {
            guard let url_Breeze = URL(string: path_Breeze) else { showEmpty_Breeze(); return }
            imageView_Breeze.kf.setImage(with: url_Breeze, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Breeze.stopAnimating()
                if case .success(let v_Breeze) = result { self?.onImageLoaded_Breeze(v_Breeze.image) }
                else { self?.showEmpty_Breeze() }
            }
            return
        }
        // Documents 文件名
        let docs_Breeze = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Breeze = docs_Breeze.appendingPathComponent(path_Breeze)
        if let img_Breeze = UIImage(contentsOfFile: docURL_Breeze.path) { applyImage_Breeze(img_Breeze); return }
        // 完整路径
        if let img_Breeze = UIImage(contentsOfFile: path_Breeze) { applyImage_Breeze(img_Breeze); return }
        showEmpty_Breeze()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Breeze: 视频文件 URL
    private func setupVideoPlayer_Breeze(url_Breeze: URL) {
        resolvedType_Breeze = .video_Breeze

        // 切换到视频容器
        scrollView_Breeze.isHidden         = true
        videoContainerView_Breeze.isHidden = false
        progressBg_Breeze.isHidden         = false

        mediaTypeLabel_Breeze.text = "Video"

        let player_Breeze  = AVPlayer(url: url_Breeze)
        self.player_Breeze = player_Breeze
        let layer_Breeze   = AVPlayerLayer(player: player_Breeze)
        layer_Breeze.videoGravity  = .resizeAspect
        layer_Breeze.frame         = videoContainerView_Breeze.bounds
        layer_Breeze.backgroundColor = UIColor.black.cgColor
        videoContainerView_Breeze.layer.insertSublayer(layer_Breeze, at: 0)
        playerLayer_Breeze = layer_Breeze

        // 视频就绪后淡入播放按钮
        player_Breeze.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Breeze = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Breeze = player_Breeze.addPeriodicTimeObserver(
            forInterval: interval_Breeze,
            queue: .main
        ) { [weak self] time_Breeze in
            self?.updateProgress_Breeze(currentTime_Breeze: time_Breeze)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Breeze),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Breeze.currentItem
        )

        loadingIndicator_Breeze.stopAnimating()
        player_Breeze.play()
        isPlaying_Breeze = true
        playPauseButton_Breeze.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Breeze.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Breeze: AVPlayer 当前时间
    private func updateProgress_Breeze(currentTime_Breeze: CMTime) {
        guard let duration_Breeze = player_Breeze?.currentItem?.duration,
              duration_Breeze.isNumeric, duration_Breeze.seconds > 0 else { return }
        let progress_Breeze = CGFloat(currentTime_Breeze.seconds / duration_Breeze.seconds)
        let totalW_Breeze   = progressBg_Breeze.bounds.width
        progressWidthCon_Breeze?.update(offset: totalW_Breeze * min(max(progress_Breeze, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Breeze() {
        player_Breeze?.seek(to: .zero)
        isPlaying_Breeze = false
        playPauseButton_Breeze.isSelected = false
        progressWidthCon_Breeze?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Breeze() {
        if let token_Breeze = timeObserverToken_Breeze {
            player_Breeze?.removeTimeObserver(token_Breeze)
            timeObserverToken_Breeze = nil
        }
        player_Breeze?.removeObserver(self, forKeyPath: "status")
        player_Breeze?.pause()
        player_Breeze = nil
        playerLayer_Breeze?.removeFromSuperlayer()
        playerLayer_Breeze = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Breeze = object as? AVPlayer,
              player_Breeze.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Breeze() }
    }

    // MARK: - 图片辅助

    private func applyImage_Breeze(_ image_Breeze: UIImage) {
        loadingIndicator_Breeze.stopAnimating()
        imageView_Breeze.image = image_Breeze
        imageSize_Breeze       = image_Breeze.size
        mediaTypeLabel_Breeze.text = "Photo"
        updateImageLayout_Breeze()
    }

    private func onImageLoaded_Breeze(_ image_Breeze: UIImage) {
        imageSize_Breeze = image_Breeze.size
        mediaTypeLabel_Breeze.text = "Photo"
        updateImageLayout_Breeze()
    }

    private func showEmpty_Breeze() {
        loadingIndicator_Breeze.stopAnimating()
        imageView_Breeze.image       = UIImage(systemName: "photo.slash")
        imageView_Breeze.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Breeze.contentMode = .center
    }

    private func updateImageLayout_Breeze() {
        guard imageSize_Breeze != .zero else {
            imageView_Breeze.frame = view.bounds
            scrollView_Breeze.contentSize = view.bounds.size
            return
        }
        let screenW_Breeze = view.bounds.width
        let screenH_Breeze = view.bounds.height
        let ratio_Breeze   = imageSize_Breeze.height / imageSize_Breeze.width
        let imgH_Breeze    = screenW_Breeze * ratio_Breeze
        let y_Breeze       = max(0, (screenH_Breeze - imgH_Breeze) / 2)
        imageView_Breeze.frame        = CGRect(x: 0, y: y_Breeze, width: screenW_Breeze, height: imgH_Breeze)
        scrollView_Breeze.contentSize = CGSize(width: screenW_Breeze,
                                              height: max(imgH_Breeze + y_Breeze * 2, screenH_Breeze))
        scrollView_Breeze.zoomScale   = 1.0
        centerImageIfNeeded_Breeze()
    }

    private func centerImageIfNeeded_Breeze() {
        let offX_Breeze = max(0, (scrollView_Breeze.bounds.width  - scrollView_Breeze.contentSize.width)  / 2)
        let offY_Breeze = max(0, (scrollView_Breeze.bounds.height - scrollView_Breeze.contentSize.height) / 2)
        imageView_Breeze.center = CGPoint(
            x: scrollView_Breeze.contentSize.width  / 2 + offX_Breeze,
            y: scrollView_Breeze.contentSize.height / 2 + offY_Breeze
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Breeze(_ gesture_Breeze: UITapGestureRecognizer) {
        guard resolvedType_Breeze == .image_Breeze else { return }
        if scrollView_Breeze.zoomScale > 1.0 {
            scrollView_Breeze.setZoomScale(1.0, animated: true)
        } else {
            let pt_Breeze    = gesture_Breeze.location(in: imageView_Breeze)
            let rect_Breeze  = zoomRect_Breeze(scale_Breeze: 2.5, center_Breeze: pt_Breeze)
            scrollView_Breeze.zoom(to: rect_Breeze, animated: true)
        }
    }

    @objc private func handleSingleTap_Breeze() {
        guard resolvedType_Breeze != .video_Breeze,
              scrollView_Breeze.zoomScale <= 1.01 else { return }
        dismissPage_Breeze(velocity_Breeze: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Breeze() {
        togglePlayPause_Breeze()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Breeze() {
        guard let player_Breeze = player_Breeze else { return }
        if isPlaying_Breeze {
            player_Breeze.pause()
            isPlaying_Breeze = false
            playPauseButton_Breeze.isSelected = false
        } else {
            player_Breeze.play()
            isPlaying_Breeze = true
            playPauseButton_Breeze.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Breeze.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Breeze else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Breeze.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Breeze() {
        dismissPage_Breeze(velocity_Breeze: 0)
    }

    @objc private func handlePan_Breeze(_ gesture_Breeze: UIPanGestureRecognizer) {
        guard scrollView_Breeze.zoomScale <= 1.01 else { return }
        let translation_Breeze = gesture_Breeze.translation(in: view)
        let velocity_Breeze    = gesture_Breeze.velocity(in: view).y
        switch gesture_Breeze.state {
        case .changed:
            let progress_Breeze         = max(0, translation_Breeze.y / view.bounds.height)
            backgroundView_Breeze.alpha = max(0, 1 - progress_Breeze * 1.5)
            topBar_Breeze.alpha         = max(0, 1 - progress_Breeze * 2)
            bottomHint_Breeze.alpha     = max(0, 1 - progress_Breeze * 2)
            let activeView_Breeze: UIView = resolvedType_Breeze == .video_Breeze
                ? videoContainerView_Breeze : scrollView_Breeze
            activeView_Breeze.transform = CGAffineTransform(
                translationX: translation_Breeze.x * 0.3,
                y: max(0, translation_Breeze.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Breeze = translation_Breeze.y > view.bounds.height * 0.25 || velocity_Breeze > 900
            if shouldDismiss_Breeze {
                dismissPage_Breeze(velocity_Breeze: velocity_Breeze)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Breeze.transform         = .identity
                    self.videoContainerView_Breeze.transform = .identity
                    self.backgroundView_Breeze.alpha  = 1
                    self.topBar_Breeze.alpha           = 1
                    self.bottomHint_Breeze.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Breeze: 下拉速度（影响动画时长）
    private func dismissPage_Breeze(velocity_Breeze: CGFloat) {
        guard !isDismissing_Breeze else { return }
        isDismissing_Breeze = true
        player_Breeze?.pause()
        let duration_Breeze = velocity_Breeze > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Breeze, animations: {
            self.view.alpha = 0
            let activeView_Breeze: UIView = self.resolvedType_Breeze == .video_Breeze
                ? self.videoContainerView_Breeze : self.scrollView_Breeze
            activeView_Breeze.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Breeze(scale_Breeze: CGFloat, center_Breeze: CGPoint) -> CGRect {
        let w_Breeze = scrollView_Breeze.bounds.width  / scale_Breeze
        let h_Breeze = scrollView_Breeze.bounds.height / scale_Breeze
        return CGRect(x: center_Breeze.x - w_Breeze / 2,
                      y: center_Breeze.y - h_Breeze / 2,
                      width: w_Breeze, height: h_Breeze)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Breeze: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Breeze }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Breeze() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Breeze: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Breeze = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Breeze.zoomScale <= 1.01 else { return false }
        let vel_Breeze = pan_Breeze.velocity(in: view)
        return abs(vel_Breeze.y) > abs(vel_Breeze.x) && vel_Breeze.y > 0
    }
}
