import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Maki {
    /// 个人聊天
    case personal_maki
    /// AI聊天
    case ai_maki
}

/// 消息状态管理类
/// 功能：管理个人聊天与AI聊天的消息存储、发送及清空操作
/// 设计：单例 + 通知驱动状态更新，UI 层监听通知刷新
@MainActor
class MessageViewModel_Maki {

    /// 单例
    static let shared_Maki = MessageViewModel_Maki()

    // MARK: - 通知名称

    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Maki = Notification.Name("MessageStateDidChange_Maki")

    // MARK: - 私有属性

    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Maki: [Int: [MessageModel_Maki]] = [:]

    /// AI聊天消息列表
    private var aiChats_Maki: [MessageModel_Maki] = []

    /// 聊天服务URL（加密存储）
    private static let chatService_Maki: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]

    private init() {}

    // MARK: - 公共方法 - 初始化 / 退出

    /// 初始化消息
    /// 功能：清空所有消息数据（个人聊天与AI聊天）
    func initChat_Maki() {
        userMesMap_Maki = [:]
        aiChats_Maki = []
        notifyStateChange_Maki()
    }

    /// 退出登录清空所有聊天数据
    func logoutChat_Maki() {
        initChat_Maki()
    }

    // MARK: - 公共方法 - 获取数据

    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Maki(userId_maki: Int) -> [MessageModel_Maki] {
        userMesMap_Maki[userId_maki] ?? []
    }

    /// 获取有聊天记录的用户列表
    func getChatUsers_Maki() -> [PrewUserModel_Maki] {
        LocalData_Maki.shared_Maki.userList_Maki.filter {
            guard let userId = $0.userId_Maki else { return false }
            return userMesMap_Maki.keys.contains(userId)
        }
    }

    /// 获取AI聊天消息列表
    func getAiChats_Maki() -> [MessageModel_Maki] { aiChats_Maki }

    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Maki(userId_maki: Int) -> MessageModel_Maki? {
        userMesMap_Maki[userId_maki]?.last
    }

    // MARK: - 公共方法 - 发送消息

    /// 发送消息
    /// 功能：构建消息并存储，同时异步请求服务端回复
    /// 参数：
    /// - message_maki: 消息文本内容
    /// - chatType_maki: 聊天类型（个人 / AI）
    /// - id_maki: 对话目标ID（个人聊天为用户ID，AI聊天传任意占位值）
    func sendMessage_Maki(message_maki: String, chatType_maki: ChatType_Maki, id_maki: Int) {
        let msg_maki = buildMessage_Maki(content_maki: message_maki, isMine_maki: true)
        appendMessage_Maki(msg_maki, chatType_maki: chatType_maki, id_maki: id_maki)
        handleReply_Maki(for: msg_maki, chatType_maki: chatType_maki, id_maki: id_maki)
        notifyStateChange_Maki()
    }

    // MARK: - 公共方法 - 清空消息

    /// 清空AI聊天记录
    func clearAiChat_Maki() {
        aiChats_Maki = []
        notifyStateChange_Maki()
    }

    /// 删除与指定用户的消息
    func deleteUserMessages_Maki(userId_maki: Int) {
        userMesMap_Maki.removeValue(forKey: userId_maki)
        notifyStateChange_Maki()
    }

    // MARK: - 私有方法 - 消息处理

    /// 构建消息模型
    /// 功能：统一构造 MessageModel，自动填充时间戳和当前时间
    /// 参数：
    /// - content_maki: 消息文本
    /// - isMine_maki: 是否为本人发送
    /// 返回值：构建完成的 MessageModel_Maki
    private func buildMessage_Maki(content_maki: String, isMine_maki: Bool) -> MessageModel_Maki {
        MessageModel_Maki(
            messageId_maki: Int(Date().timeIntervalSince1970 * 1000),
            content_maki: content_maki,
            userHead_maki: isMine_maki ? "current_user_head" : "",
            isMine_maki: isMine_maki,
            time_maki: getCurrentTime_Maki()
        )
    }

    /// 将消息追加到对应存储
    /// 参数：
    /// - msg_maki: 要追加的消息模型
    /// - chatType_maki: 聊天类型
    /// - id_maki: 个人聊天时为用户ID
    private func appendMessage_Maki(_ msg_maki: MessageModel_Maki, chatType_maki: ChatType_Maki, id_maki: Int) {
        switch chatType_maki {
        case .personal_maki:
            userMesMap_Maki[id_maki, default: []].append(msg_maki)
        case .ai_maki:
            aiChats_Maki.append(msg_maki)
        }
    }

    /// 异步请求服务端回复并追加到对应存储
    /// 参数：
    /// - msg_maki: 已发送的消息（用于提取内容请求接口）
    /// - chatType_maki: 聊天类型
    /// - id_maki: 对话目标ID
    private func handleReply_Maki(for msg_maki: MessageModel_Maki, chatType_maki: ChatType_Maki, id_maki: Int) {
        Task {
            let content_maki = await chatService_Maki(
                userId_maki: 0,
                message_maki: msg_maki.content_Maki ?? ""
            ) ?? "Server error"

            let reply_maki = buildMessage_Maki(content_maki: content_maki, isMine_maki: false)
            appendMessage_Maki(reply_maki, chatType_maki: chatType_maki, id_maki: id_maki)
            notifyStateChange_Maki()
        }
    }

    // MARK: - 私有方法 - 工具方法

    /// 获取当前时间字符串（HH:mm 格式）
    private func getCurrentTime_Maki() -> String {
        let formatter_maki = DateFormatter()
        formatter_maki.dateFormat = "HH:mm"
        return formatter_maki.string(from: Date())
    }

    /// 发送状态更新通知
    private func notifyStateChange_Maki() {
        NotificationCenter.default.post(
            name: MessageViewModel_Maki.messageStateDidChangeNotification_Maki,
            object: nil
        )
    }

    // MARK: - 网络请求

    /// 聊天服务API
    /// 功能：向服务端发送用户消息，返回AI回复内容
    /// 参数：
    /// - userId_maki: 当前用户ID
    /// - message_maki: 消息文本内容
    /// 返回值：服务端回复文本，失败时返回 nil
    private func chatService_Maki(userId_maki: Int, message_maki: String) async -> String? {
        do {
            let sessionId_maki = "\(Int(Date().timeIntervalSince1970 * 1000))_\(generateRandomString_Maki(length_maki: 16))"
            let urlString_maki = decryptUrl_Maki(encryptedCodes_maki: MessageViewModel_Maki.chatService_Maki)

            guard let url_maki = URL(string: urlString_maki) else {
                print("❌ 错误：无效的URL")
                return nil
            }

            var request_maki = URLRequest(url: url_maki)
            request_maki.httpMethod = "POST"
            request_maki.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request_maki.httpBody = try JSONSerialization.data(withJSONObject: [
                "bundle_id": "com.maki.app",
                "session_id": sessionId_maki,
                "content_type": "text",
                "content": message_maki
            ])

            let (data_maki, response_maki) = try await URLSession.shared.data(for: request_maki)

            guard let http_maki = response_maki as? HTTPURLResponse else { return "Server error" }
            print("✅ HTTP状态码: \(http_maki.statusCode)")

            guard http_maki.statusCode == 200,
                  let json_maki = try JSONSerialization.jsonObject(with: data_maki) as? [String: Any],
                  let code_maki = json_maki["code"] as? Int, code_maki == 1003,
                  let dataDict_maki = json_maki["data"] as? [String: Any],
                  let answer_maki = dataDict_maki["answer"] as? String,
                  !answer_maki.isEmpty else { return "Server error" }

            return answer_maki
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }

    /// URL加密方法（字符偏移 +23 后异或 ^20）
    /// 功能：对明文URL进行两层加密，生成整数编码数组
    /// 参数：
    /// - plainUrl_Maki: 待加密的原始URL字符串
    /// 返回值：加密后的整数编码数组
    static func encryptUrl_Maki(plainUrl_Maki: String) -> [Int] {
        let result_Maki = plainUrl_Maki.unicodeScalars.map { (Int($0.value) + 23) ^ 20 }
        print("✅ URL加密结果: \(result_Maki)")
        return result_Maki
    }

    /// URL解密方法（异或 ^20 后字符偏移 -23）
    /// 功能：对加密整数数组进行两层解密，还原原始URL
    /// 参数：
    /// - encryptedCodes_maki: 加密整数数组
    /// 返回值：解密后的URL字符串
    private func decryptUrl_Maki(encryptedCodes_maki: [Int]) -> String {
        String(encryptedCodes_maki.compactMap {
            UnicodeScalar(($0 ^ 20) - 23).map { Character($0) }
        })
    }

    /// 生成随机字符串
    /// 参数：
    /// - length_maki: 字符串长度
    /// 返回值：由字母和数字组成的随机字符串
    private func generateRandomString_Maki(length_maki: Int) -> String {
        let letters_maki = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_maki).map { _ in letters_maki.randomElement()! })
    }
}
