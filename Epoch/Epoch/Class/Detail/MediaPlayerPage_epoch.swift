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
///   - 媒体路径与 MediaDisplayView_Epoch 加载策略完全对齐（Bundle → Documents → 网络）
///   - 顶部半透明导航条（关闭按钮 + 媒体类型标签）
///   - 背景 alpha 跟随下拉手势动态变化，松手回弹或关闭
/// 关键属性：
///   - mediaPath_Epoch:  媒体路径（支持 Assets / 网络 / Documents / Bundle 视频）
///   - isVideo_Epoch:    是否强制为视频模式（传 false 时由加载器自动检测）
class MediaPlayerPage_Epoch: UIViewController {

    // MARK: - 对外属性

    /// 媒体路径（支持 Assets 名 / https URL / Documents 文件名 / Bundle 资源名）
    var mediaPath_Epoch: String?

    /// 是否强制当作视频处理（false 时由加载流程自动检测）
    var isVideo_Epoch: Bool = false

    // MARK: - 私有属性

    /// 当前实际媒体类型（加载后确定）
    private var resolvedType_Epoch: MediaType_Epoch = .none_Epoch

    /// 下拉关闭时记录的起始偏移
    private var isDismissing_Epoch = false
    /// 图片原始尺寸（缩放布局用）
    private var imageSize_Epoch: CGSize = .zero

    // MARK: - AVPlayer（视频）

    private var player_Epoch: AVPlayer?
    private var playerLayer_Epoch: AVPlayerLayer?
    /// 视频进度观察者令牌
    private var timeObserverToken_Epoch: Any?
    /// 是否处于播放状态
    private var isPlaying_Epoch = false

    // MARK: - UI：黑色背景

    private let backgroundView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    // MARK: - UI：图片模式

    private let scrollView_Epoch: UIScrollView = {
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

    private let imageView_Epoch: UIImageView = {
        let iv = UIImageView()
        iv.contentMode   = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .clear
        return iv
    }()

    // MARK: - UI：视频模式

    /// 视频渲染容器（AVPlayerLayer 附着此 View）
    private let videoContainerView_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        v.isHidden        = true
        return v
    }()

    /// 播放/暂停中央大按钮（覆盖在视频上）
    private let playPauseButton_Epoch: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Epoch = UIImage.SymbolConfiguration(pointSize: 36, weight: .bold)
        b.setImage(UIImage(systemName: "play.circle.fill",  withConfiguration: cfg_Epoch), for: .normal)
        b.setImage(UIImage(systemName: "pause.circle.fill", withConfiguration: cfg_Epoch), for: .selected)
        b.tintColor       = .white
        b.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        b.layer.cornerRadius = 40
        b.alpha = 0   // 初始隐藏，加载完成后淡入
        return b
    }()

    /// 底部进度条背景
    private let progressBg_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor.white.withAlphaComponent(0.25)
        v.layer.cornerRadius = 2
        v.isHidden           = true
        return v
    }()

    /// 底部进度条前景
    private let progressFill_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor    = .white
        v.layer.cornerRadius = 2
        return v
    }()

    /// 进度条宽度约束（实时更新）
    private var progressWidthCon_Epoch: Constraint?

    // MARK: - UI：共用

    private let loadingIndicator_Epoch: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .white
        ai.hidesWhenStopped = true
        return ai
    }()

    private let topBar_Epoch: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        return v
    }()

    private let closeButton_Epoch: UIButton = {
        let b = UIButton(type: .custom)
        let cfg_Epoch = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        b.setImage(UIImage(systemName: "xmark", withConfiguration: cfg_Epoch), for: .normal)
        b.tintColor          = .white
        b.backgroundColor    = UIColor.white.withAlphaComponent(0.15)
        b.layer.cornerRadius = 18
        b.layer.borderWidth  = 1
        b.layer.borderColor  = UIColor.white.withAlphaComponent(0.25).cgColor
        return b
    }()

    private let mediaTypeLabel_Epoch: UILabel = {
        let l = UILabel()
        l.font          = .systemFont(ofSize: 12, weight: .semibold)
        l.textColor     = UIColor.white.withAlphaComponent(0.75)
        l.textAlignment = .center
        return l
    }()

    private let bottomHint_Epoch: UILabel = {
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
        buildUI_Epoch()
        buildConstraints_Epoch()
        bindGestures_Epoch()
        loadMedia_Epoch()
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
        cleanupPlayer_Epoch()
    }

    deinit {
        cleanupPlayer_Epoch()
    }

    // MARK: - UI 搭建

    private func buildUI_Epoch() {
        view.backgroundColor = .black

        view.addSubview(backgroundView_Epoch)

        // 图片容器
        view.addSubview(scrollView_Epoch)
        scrollView_Epoch.addSubview(imageView_Epoch)
        scrollView_Epoch.delegate = self

        // 视频容器
        view.addSubview(videoContainerView_Epoch)
        videoContainerView_Epoch.addSubview(playPauseButton_Epoch)
        videoContainerView_Epoch.addSubview(progressBg_Epoch)
        progressBg_Epoch.addSubview(progressFill_Epoch)

        // 通用
        view.addSubview(loadingIndicator_Epoch)
        view.addSubview(topBar_Epoch)
        topBar_Epoch.addSubview(closeButton_Epoch)
        topBar_Epoch.addSubview(mediaTypeLabel_Epoch)
        view.addSubview(bottomHint_Epoch)
    }

    private func buildConstraints_Epoch() {
        backgroundView_Epoch.snp.makeConstraints { $0.edges.equalToSuperview() }
        scrollView_Epoch.snp.makeConstraints     { $0.edges.equalToSuperview() }
        imageView_Epoch.frame = view.bounds

        videoContainerView_Epoch.snp.makeConstraints { $0.edges.equalToSuperview() }
        playPauseButton_Epoch.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(80)
        }

        progressBg_Epoch.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
            $0.height.equalTo(4)
        }
        progressFill_Epoch.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            progressWidthCon_Epoch = $0.width.equalTo(0).constraint
        }

        loadingIndicator_Epoch.snp.makeConstraints { $0.center.equalToSuperview() }

        topBar_Epoch.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        closeButton_Epoch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(12)
            $0.width.height.equalTo(36)
        }
        mediaTypeLabel_Epoch.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(14)
        }
        bottomHint_Epoch.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topBar_Epoch.snp.updateConstraints {
            $0.height.equalTo(view.safeAreaInsets.top + 58)
        }
        playerLayer_Epoch?.frame = videoContainerView_Epoch.bounds
        updateImageLayout_Epoch()
    }

    // MARK: - 手势

    private func bindGestures_Epoch() {
        // 双击缩放（图片）
        let doubleTap_Epoch = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap_Epoch(_:)))
        doubleTap_Epoch.numberOfTapsRequired = 2
        scrollView_Epoch.addGestureRecognizer(doubleTap_Epoch)

        // 单击关闭 / 视频播放切换
        let singleTap_Epoch = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap_Epoch))
        singleTap_Epoch.numberOfTapsRequired = 1
        singleTap_Epoch.require(toFail: doubleTap_Epoch)
        scrollView_Epoch.addGestureRecognizer(singleTap_Epoch)

        // 视频区单击切换播放/暂停
        let videoTap_Epoch = UITapGestureRecognizer(target: self, action: #selector(handleVideoTap_Epoch))
        videoContainerView_Epoch.addGestureRecognizer(videoTap_Epoch)

        // 下滑关闭
        let pan_Epoch = UIPanGestureRecognizer(target: self, action: #selector(handlePan_Epoch(_:)))
        pan_Epoch.delegate = self
        view.addGestureRecognizer(pan_Epoch)

        // 播放/暂停按钮
        playPauseButton_Epoch.addTarget(self, action: #selector(togglePlayPause_Epoch), for: .touchUpInside)
        closeButton_Epoch.addTarget(self, action: #selector(closeTapped_Epoch), for: .touchUpInside)
    }

    // MARK: - 媒体加载

    /// 根据 mediaPath_Epoch 和 isVideo_Epoch 加载媒体
    private func loadMedia_Epoch() {
        guard let path_Epoch = mediaPath_Epoch, !path_Epoch.isEmpty else { showEmpty_Epoch(); return }
        loadingIndicator_Epoch.startAnimating()

        // 若外部明确为视频，或路径在 Bundle 中找到视频文件 → 进入视频流程
        if isVideo_Epoch, let url_Epoch = resolveVideoURL_Epoch(path_Epoch) {
            setupVideoPlayer_Epoch(url_Epoch: url_Epoch)
            return
        }
        // 自动检测：先查 Bundle 视频
        if let url_Epoch = resolveVideoURL_Epoch(path_Epoch) {
            setupVideoPlayer_Epoch(url_Epoch: url_Epoch)
            return
        }

        // 图片加载流程
        resolvedType_Epoch = .image_Epoch
        loadImage_Epoch(path_Epoch: path_Epoch)
    }

    /// 解析路径对应的视频 URL（Bundle / Documents / 网络）
    /// - Parameter path_Epoch: 媒体路径或名称
    /// - Returns: 找到时返回 URL，否则返回 nil
    private func resolveVideoURL_Epoch(_ path_Epoch: String) -> URL? {
        // Bundle 资源
        if let url_Epoch = MediaDisplayView_Epoch.bundleVideoURL_Epoch(named: path_Epoch) {
            return url_Epoch
        }
        // Documents 目录视频文件
        let docs_Epoch = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext_Epoch in ["mp4", "mov", "m4v"] {
            let url_Epoch = docs_Epoch.appendingPathComponent("\(path_Epoch).\(ext_Epoch)")
            if FileManager.default.fileExists(atPath: url_Epoch.path) { return url_Epoch }
        }
        // 已带扩展名的文档目录文件
        let direct_Epoch = docs_Epoch.appendingPathComponent(path_Epoch)
        if FileManager.default.fileExists(atPath: direct_Epoch.path) { return direct_Epoch }
        // 网络视频 URL
        if (path_Epoch.hasPrefix("http://") || path_Epoch.hasPrefix("https://")),
           let url_Epoch = URL(string: path_Epoch) {
            let ext_Epoch = (path_Epoch as NSString).pathExtension.lowercased()
            if ["mp4", "mov", "m4v", "m3u8"].contains(ext_Epoch) { return url_Epoch }
        }
        return nil
    }

    /// 加载图片（与 MediaDisplayView_Epoch 策略对齐）
    /// - Parameter path_Epoch: 媒体路径
    private func loadImage_Epoch(path_Epoch: String) {
        // SF Symbols
        if let img_Epoch = UIImage(systemName: path_Epoch) { applyImage_Epoch(img_Epoch); return }
        // Assets
        if let img_Epoch = UIImage(named: path_Epoch) { applyImage_Epoch(img_Epoch); return }
        // 网络
        if path_Epoch.hasPrefix("http://") || path_Epoch.hasPrefix("https://") {
            guard let url_Epoch = URL(string: path_Epoch) else { showEmpty_Epoch(); return }
            imageView_Epoch.kf.setImage(with: url_Epoch, options: [.transition(.fade(0.3))]) { [weak self] result in
                self?.loadingIndicator_Epoch.stopAnimating()
                if case .success(let v_Epoch) = result { self?.onImageLoaded_Epoch(v_Epoch.image) }
                else { self?.showEmpty_Epoch() }
            }
            return
        }
        // Documents 文件名
        let docs_Epoch = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let docURL_Epoch = docs_Epoch.appendingPathComponent(path_Epoch)
        if let img_Epoch = UIImage(contentsOfFile: docURL_Epoch.path) { applyImage_Epoch(img_Epoch); return }
        // 完整路径
        if let img_Epoch = UIImage(contentsOfFile: path_Epoch) { applyImage_Epoch(img_Epoch); return }
        showEmpty_Epoch()
    }

    // MARK: - 视频播放器

    /// 初始化并启动 AVPlayer
    /// - Parameter url_Epoch: 视频文件 URL
    private func setupVideoPlayer_Epoch(url_Epoch: URL) {
        resolvedType_Epoch = .video_Epoch

        // 切换到视频容器
        scrollView_Epoch.isHidden         = true
        videoContainerView_Epoch.isHidden = false
        progressBg_Epoch.isHidden         = false

        mediaTypeLabel_Epoch.text = "Video"

        let player_Epoch  = AVPlayer(url: url_Epoch)
        self.player_Epoch = player_Epoch
        let layer_Epoch   = AVPlayerLayer(player: player_Epoch)
        layer_Epoch.videoGravity  = .resizeAspect
        layer_Epoch.frame         = videoContainerView_Epoch.bounds
        layer_Epoch.backgroundColor = UIColor.black.cgColor
        videoContainerView_Epoch.layer.insertSublayer(layer_Epoch, at: 0)
        playerLayer_Epoch = layer_Epoch

        // 视频就绪后淡入播放按钮
        player_Epoch.addObserver(self, forKeyPath: "status", options: [.new], context: nil)

        // 进度更新（每 0.1 秒）
        let interval_Epoch = CMTime(seconds: 0.1, preferredTimescale: 600)
        timeObserverToken_Epoch = player_Epoch.addPeriodicTimeObserver(
            forInterval: interval_Epoch,
            queue: .main
        ) { [weak self] time_Epoch in
            self?.updateProgress_Epoch(currentTime_Epoch: time_Epoch)
        }

        // 播放完毕回到开头
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinish_Epoch),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player_Epoch.currentItem
        )

        loadingIndicator_Epoch.stopAnimating()
        player_Epoch.play()
        isPlaying_Epoch = true
        playPauseButton_Epoch.isSelected = true
        UIView.animate(withDuration: 0.3) { self.playPauseButton_Epoch.alpha = 1 }
    }

    /// 更新底部进度条
    /// - Parameter currentTime_Epoch: AVPlayer 当前时间
    private func updateProgress_Epoch(currentTime_Epoch: CMTime) {
        guard let duration_Epoch = player_Epoch?.currentItem?.duration,
              duration_Epoch.isNumeric, duration_Epoch.seconds > 0 else { return }
        let progress_Epoch = CGFloat(currentTime_Epoch.seconds / duration_Epoch.seconds)
        let totalW_Epoch   = progressBg_Epoch.bounds.width
        progressWidthCon_Epoch?.update(offset: totalW_Epoch * min(max(progress_Epoch, 0), 1))
    }

    /// 播放结束时回到开头并切换按钮状态
    @objc private func playerDidFinish_Epoch() {
        player_Epoch?.seek(to: .zero)
        isPlaying_Epoch = false
        playPauseButton_Epoch.isSelected = false
        progressWidthCon_Epoch?.update(offset: 0)
    }

    /// 清理 AVPlayer 资源（防止内存泄漏）
    private func cleanupPlayer_Epoch() {
        if let token_Epoch = timeObserverToken_Epoch {
            player_Epoch?.removeTimeObserver(token_Epoch)
            timeObserverToken_Epoch = nil
        }
        player_Epoch?.removeObserver(self, forKeyPath: "status")
        player_Epoch?.pause()
        player_Epoch = nil
        playerLayer_Epoch?.removeFromSuperlayer()
        playerLayer_Epoch = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard keyPath == "status",
              let player_Epoch = object as? AVPlayer,
              player_Epoch.status == .failed else { return }
        DispatchQueue.main.async { self.showEmpty_Epoch() }
    }

    // MARK: - 图片辅助

    private func applyImage_Epoch(_ image_Epoch: UIImage) {
        loadingIndicator_Epoch.stopAnimating()
        imageView_Epoch.image = image_Epoch
        imageSize_Epoch       = image_Epoch.size
        mediaTypeLabel_Epoch.text = "Photo"
        updateImageLayout_Epoch()
    }

    private func onImageLoaded_Epoch(_ image_Epoch: UIImage) {
        imageSize_Epoch = image_Epoch.size
        mediaTypeLabel_Epoch.text = "Photo"
        updateImageLayout_Epoch()
    }

    private func showEmpty_Epoch() {
        loadingIndicator_Epoch.stopAnimating()
        imageView_Epoch.image       = UIImage(systemName: "photo.slash")
        imageView_Epoch.tintColor   = UIColor.white.withAlphaComponent(0.4)
        imageView_Epoch.contentMode = .center
    }

    private func updateImageLayout_Epoch() {
        guard imageSize_Epoch != .zero else {
            imageView_Epoch.frame = view.bounds
            scrollView_Epoch.contentSize = view.bounds.size
            return
        }
        let screenW_Epoch = view.bounds.width
        let screenH_Epoch = view.bounds.height
        let ratio_Epoch   = imageSize_Epoch.height / imageSize_Epoch.width
        let imgH_Epoch    = screenW_Epoch * ratio_Epoch
        let y_Epoch       = max(0, (screenH_Epoch - imgH_Epoch) / 2)
        imageView_Epoch.frame        = CGRect(x: 0, y: y_Epoch, width: screenW_Epoch, height: imgH_Epoch)
        scrollView_Epoch.contentSize = CGSize(width: screenW_Epoch,
                                              height: max(imgH_Epoch + y_Epoch * 2, screenH_Epoch))
        scrollView_Epoch.zoomScale   = 1.0
        centerImageIfNeeded_Epoch()
    }

    private func centerImageIfNeeded_Epoch() {
        let offX_Epoch = max(0, (scrollView_Epoch.bounds.width  - scrollView_Epoch.contentSize.width)  / 2)
        let offY_Epoch = max(0, (scrollView_Epoch.bounds.height - scrollView_Epoch.contentSize.height) / 2)
        imageView_Epoch.center = CGPoint(
            x: scrollView_Epoch.contentSize.width  / 2 + offX_Epoch,
            y: scrollView_Epoch.contentSize.height / 2 + offY_Epoch
        )
    }

    // MARK: - 手势响应

    @objc private func handleDoubleTap_Epoch(_ gesture_Epoch: UITapGestureRecognizer) {
        guard resolvedType_Epoch == .image_Epoch else { return }
        if scrollView_Epoch.zoomScale > 1.0 {
            scrollView_Epoch.setZoomScale(1.0, animated: true)
        } else {
            let pt_Epoch    = gesture_Epoch.location(in: imageView_Epoch)
            let rect_Epoch  = zoomRect_Epoch(scale_Epoch: 2.5, center_Epoch: pt_Epoch)
            scrollView_Epoch.zoom(to: rect_Epoch, animated: true)
        }
    }

    @objc private func handleSingleTap_Epoch() {
        guard resolvedType_Epoch != .video_Epoch,
              scrollView_Epoch.zoomScale <= 1.01 else { return }
        dismissPage_Epoch(velocity_Epoch: 0)
    }

    /// 视频区点击：切换播放/暂停
    @objc private func handleVideoTap_Epoch() {
        togglePlayPause_Epoch()
    }

    /// 播放/暂停切换
    @objc private func togglePlayPause_Epoch() {
        guard let player_Epoch = player_Epoch else { return }
        if isPlaying_Epoch {
            player_Epoch.pause()
            isPlaying_Epoch = false
            playPauseButton_Epoch.isSelected = false
        } else {
            player_Epoch.play()
            isPlaying_Epoch = true
            playPauseButton_Epoch.isSelected = true
        }
        // 短暂显示后淡出按钮
        UIView.animate(withDuration: 0.2) { self.playPauseButton_Epoch.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            guard self.isPlaying_Epoch else { return }
            UIView.animate(withDuration: 0.4) { self.playPauseButton_Epoch.alpha = 0.2 }
        }
    }

    @objc private func closeTapped_Epoch() {
        dismissPage_Epoch(velocity_Epoch: 0)
    }

    @objc private func handlePan_Epoch(_ gesture_Epoch: UIPanGestureRecognizer) {
        guard scrollView_Epoch.zoomScale <= 1.01 else { return }
        let translation_Epoch = gesture_Epoch.translation(in: view)
        let velocity_Epoch    = gesture_Epoch.velocity(in: view).y
        switch gesture_Epoch.state {
        case .changed:
            let progress_Epoch         = max(0, translation_Epoch.y / view.bounds.height)
            backgroundView_Epoch.alpha = max(0, 1 - progress_Epoch * 1.5)
            topBar_Epoch.alpha         = max(0, 1 - progress_Epoch * 2)
            bottomHint_Epoch.alpha     = max(0, 1 - progress_Epoch * 2)
            let activeView_Epoch: UIView = resolvedType_Epoch == .video_Epoch
                ? videoContainerView_Epoch : scrollView_Epoch
            activeView_Epoch.transform = CGAffineTransform(
                translationX: translation_Epoch.x * 0.3,
                y: max(0, translation_Epoch.y)
            )
        case .ended, .cancelled:
            let shouldDismiss_Epoch = translation_Epoch.y > view.bounds.height * 0.25 || velocity_Epoch > 900
            if shouldDismiss_Epoch {
                dismissPage_Epoch(velocity_Epoch: velocity_Epoch)
            } else {
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.85,
                               initialSpringVelocity: 0.5) {
                    self.scrollView_Epoch.transform         = .identity
                    self.videoContainerView_Epoch.transform = .identity
                    self.backgroundView_Epoch.alpha  = 1
                    self.topBar_Epoch.alpha           = 1
                    self.bottomHint_Epoch.alpha       = 1
                }
            }
        default: break
        }
    }

    // MARK: - 关闭页面

    /// 执行关闭动画并 dismiss（暂停视频）
    /// - Parameter velocity_Epoch: 下拉速度（影响动画时长）
    private func dismissPage_Epoch(velocity_Epoch: CGFloat) {
        guard !isDismissing_Epoch else { return }
        isDismissing_Epoch = true
        player_Epoch?.pause()
        let duration_Epoch = velocity_Epoch > 1200 ? 0.2 : 0.3
        UIView.animate(withDuration: duration_Epoch, animations: {
            self.view.alpha = 0
            let activeView_Epoch: UIView = self.resolvedType_Epoch == .video_Epoch
                ? self.videoContainerView_Epoch : self.scrollView_Epoch
            activeView_Epoch.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }) { _ in
            self.dismiss(animated: false)
        }
    }

    // MARK: - 工具

    private func zoomRect_Epoch(scale_Epoch: CGFloat, center_Epoch: CGPoint) -> CGRect {
        let w_Epoch = scrollView_Epoch.bounds.width  / scale_Epoch
        let h_Epoch = scrollView_Epoch.bounds.height / scale_Epoch
        return CGRect(x: center_Epoch.x - w_Epoch / 2,
                      y: center_Epoch.y - h_Epoch / 2,
                      width: w_Epoch, height: h_Epoch)
    }
}

// MARK: - UIScrollViewDelegate（图片缩放）

extension MediaPlayerPage_Epoch: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView_Epoch }
    func scrollViewDidZoom(_ scrollView: UIScrollView) { centerImageIfNeeded_Epoch() }
}

// MARK: - UIGestureRecognizerDelegate（下拉与缩放共存）

extension MediaPlayerPage_Epoch: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let pan_Epoch = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        guard scrollView_Epoch.zoomScale <= 1.01 else { return false }
        let vel_Epoch = pan_Epoch.velocity(in: view)
        return abs(vel_Epoch.y) > abs(vel_Epoch.x) && vel_Epoch.y > 0
    }
}
