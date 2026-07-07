import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Lens {
    /// 个人聊天
    case personal_lens
    /// AI聊天
    case ai_lens
}

/// 消息状态管理类
/// 功能：管理个人聊天与AI聊天的消息存储、发送及清空操作
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class MessageViewModel_Lens {

    /// 单例
    static let shared_Lens = MessageViewModel_Lens()

    // MARK: - 通知名称

    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Lens = Notification.Name("MessageStateDidChange_Lens")

    // MARK: - 私有属性

    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Lens: [Int: [MessageModel_Lens]] = [:]

    /// AI聊天消息列表
    private var aiChats_Lens: [MessageModel_Lens] = []

    /// 聊天服务URL（加密存储）
    private static let chatService_Lens: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]

    private init() {}

    // MARK: - 公共方法 - 初始化 / 退出

    /// 初始化消息
    /// 功能：清空所有消息数据（个人聊天与AI聊天）
    func initChat_Lens() {
        userMesMap_Lens = [:]
        aiChats_Lens = []
        notifyStateChange_Lens()
    }

    /// 退出登录清空所有聊天数据
    func logoutChat_Lens() {
        initChat_Lens()
    }

    // MARK: - 公共方法 - 获取数据

    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Lens(userId_lens: Int) -> [MessageModel_Lens] {
        userMesMap_Lens[userId_lens] ?? []
    }

    /// 获取有聊天记录的用户列表
    func getChatUsers_Lens() -> [PrewUserModel_Lens] {
        LocalData_Lens.shared_Lens.userList_Lens.filter {
            guard let userId = $0.userId_Lens else { return false }
            return userMesMap_Lens.keys.contains(userId)
        }
    }

    /// 获取AI聊天消息列表
    func getAiChats_Lens() -> [MessageModel_Lens] { aiChats_Lens }

    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Lens(userId_lens: Int) -> MessageModel_Lens? {
        userMesMap_Lens[userId_lens]?.last
    }

    // MARK: - 公共方法 - 发送消息

    /// 发送消息
    /// 功能：构建消息并存储，同时异步请求服务端回复
    /// 参数：
    /// - message_lens: 消息文本内容
    /// - chatType_lens: 聊天类型（个人 / AI）
    /// - id_lens: 对话目标ID（个人聊天为用户ID，AI聊天传任意占位值）
    func sendMessage_Lens(message_lens: String, chatType_lens: ChatType_Lens, id_lens: Int) {
        let msg_lens = buildMessage_Lens(content_lens: message_lens, isMine_lens: true)
        appendMessage_Lens(msg_lens, chatType_lens: chatType_lens, id_lens: id_lens)
        handleReply_Lens(for: msg_lens, chatType_lens: chatType_lens, id_lens: id_lens)
        notifyStateChange_Lens()
    }

    // MARK: - 公共方法 - 清空消息

    /// 清空AI聊天记录
    func clearAiChat_Lens() {
        aiChats_Lens = []
        notifyStateChange_Lens()
    }

    /// 删除与指定用户的消息
    func deleteUserMessages_Lens(userId_lens: Int) {
        userMesMap_Lens.removeValue(forKey: userId_lens)
        notifyStateChange_Lens()
    }

    // MARK: - 私有方法 - 消息处理

    /// 构建消息模型
    /// 功能：统一构造 MessageModel，自动填充时间戳和当前时间
    /// 参数：
    /// - content_lens: 消息文本
    /// - isMine_lens: 是否为本人发送
    /// 返回值：构建完成的 MessageModel_Lens
    private func buildMessage_Lens(content_lens: String, isMine_lens: Bool) -> MessageModel_Lens {
        MessageModel_Lens(
            messageId_lens: Int(Date().timeIntervalSince1970 * 1000),
            content_lens: content_lens,
            userHead_lens: isMine_lens ? "current_user_head" : "",
            isMine_lens: isMine_lens,
            time_lens: getCurrentTime_Lens()
        )
    }

    /// 将消息追加到对应存储
    /// 参数：
    /// - msg_lens: 要追加的消息模型
    /// - chatType_lens: 聊天类型
    /// - id_lens: 个人聊天时为用户ID
    private func appendMessage_Lens(_ msg_lens: MessageModel_Lens, chatType_lens: ChatType_Lens, id_lens: Int) {
        switch chatType_lens {
        case .personal_lens:
            userMesMap_Lens[id_lens, default: []].append(msg_lens)
        case .ai_lens:
            aiChats_Lens.append(msg_lens)
        }
    }

    /// 异步请求服务端回复并追加到对应存储
    /// 参数：
    /// - msg_lens: 已发送的消息（用于提取内容请求接口）
    /// - chatType_lens: 聊天类型
    /// - id_lens: 对话目标ID
    private func handleReply_Lens(for msg_lens: MessageModel_Lens, chatType_lens: ChatType_Lens, id_lens: Int) {
        Task {
            let content_lens = await chatService_Lens(
                userId_lens: 0,
                message_lens: msg_lens.content_Lens ?? ""
            ) ?? "Server error"

            let reply_lens = buildMessage_Lens(content_lens: content_lens, isMine_lens: false)
            appendMessage_Lens(reply_lens, chatType_lens: chatType_lens, id_lens: id_lens)
            notifyStateChange_Lens()
        }
    }

    // MARK: - 私有方法 - 工具方法

    /// 获取当前时间字符串（HH:mm 格式）
    private func getCurrentTime_Lens() -> String {
        let formatter_lens = DateFormatter()
        formatter_lens.dateFormat = "HH:mm"
        return formatter_lens.string(from: Date())
    }

    /// 发送状态更新通知
    private func notifyStateChange_Lens() {
        NotificationCenter.default.post(
            name: MessageViewModel_Lens.messageStateDidChangeNotification_Lens,
            object: nil
        )
    }

    // MARK: - 网络请求

    /// 聊天服务API
    /// 功能：向服务端发送用户消息，返回AI回复内容
    /// 参数：
    /// - userId_lens: 当前用户ID
    /// - message_lens: 消息文本内容
    /// 返回值：服务端回复文本，失败时返回 nil
    private func chatService_Lens(userId_lens: Int, message_lens: String) async -> String? {
        do {
            let sessionId_lens = "\(Int(Date().timeIntervalSince1970 * 1000))_\(generateRandomString_Lens(length_lens: 16))"
            let urlString_lens = decryptUrl_Lens(encryptedCodes_lens: MessageViewModel_Lens.chatService_Lens)

            guard let url_lens = URL(string: urlString_lens) else {
                print("❌ 错误：无效的URL")
                return nil
            }

            var request_lens = URLRequest(url: url_lens)
            request_lens.httpMethod = "POST"
            request_lens.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request_lens.httpBody = try JSONSerialization.data(withJSONObject: [
                "bundle_id": "com.lens.app",
                "session_id": sessionId_lens,
                "content_type": "text",
                "content": message_lens
            ])

            let (data_lens, response_lens) = try await URLSession.shared.data(for: request_lens)

            guard let http_lens = response_lens as? HTTPURLResponse else { return "Server error" }
            print("✅ HTTP状态码: \(http_lens.statusCode)")

            guard http_lens.statusCode == 200,
                  let json_lens = try JSONSerialization.jsonObject(with: data_lens) as? [String: Any],
                  let code_lens = json_lens["code"] as? Int, code_lens == 1003,
                  let dataDict_lens = json_lens["data"] as? [String: Any],
                  let answer_lens = dataDict_lens["answer"] as? String,
                  !answer_lens.isEmpty else { return "Server error" }

            return answer_lens
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }

    /// URL加密方法（字符偏移 +23 后异或 ^20）
    /// 功能：对明文URL进行两层加密，生成整数编码数组
    /// 参数：
    /// - plainUrl_Lens: 待加密的原始URL字符串
    /// 返回值：加密后的整数编码数组
    static func encryptUrl_Lens(plainUrl_Lens: String) -> [Int] {
        let result_Lens = plainUrl_Lens.unicodeScalars.map { (Int($0.value) + 23) ^ 20 }
        print("✅ URL加密结果: \(result_Lens)")
        return result_Lens
    }

    /// URL解密方法（异或 ^20 后字符偏移 -23）
    /// 功能：对加密整数数组进行两层解密，还原原始URL
    /// 参数：
    /// - encryptedCodes_lens: 加密整数数组
    /// 返回值：解密后的URL字符串
    private func decryptUrl_Lens(encryptedCodes_lens: [Int]) -> String {
        String(encryptedCodes_lens.compactMap {
            UnicodeScalar(($0 ^ 20) - 23).map { Character($0) }
        })
    }

    /// 生成随机字符串
    /// 参数：
    /// - length_lens: 字符串长度
    /// 返回值：由字母和数字组成的随机字符串
    private func generateRandomString_Lens(length_lens: Int) -> String {
        let letters_lens = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_lens).map { _ in letters_lens.randomElement()! })
    }
}
