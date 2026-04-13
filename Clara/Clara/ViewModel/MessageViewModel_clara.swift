import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Clara {
    /// 个人聊天
    case personal_clara
    /// 群聊
    case group_clara
    /// AI聊天
    case ai_clara
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Clara {
    
    /// 单例
    static let shared_Clara = MessageViewModel_Clara()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Clara = Notification.Name("MessageStateDidChange_Clara")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Clara: [Int: [MessageModel_Clara]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Clara: [Int: GroupChatInfo_Clara] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Clara: [MessageModel_Clara] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Clara: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Clara() {
        userMesMap_Clara = [:]
        aiChats_Clara = []
        notifyStateChange_Clara()
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Clara() -> [Int: GroupChatInfo_Clara] {
        return groupChats_Clara
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Clara(userId_clara: Int) -> [MessageModel_Clara] {
        return userMesMap_Clara[userId_clara] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Clara() -> [PrewUserModel_Clara] {
        let userIds_clara = userMesMap_Clara.keys
        return LocalData_Clara.shared_Clara.userList_Clara.filter { user in
            guard let userId = user.userId_Clara else { return false }
            return userIds_clara.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Clara() -> [MessageModel_Clara] {
        return aiChats_Clara
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Clara(groupId_clara: Int) -> [MessageModel_Clara] {
        return groupChats_Clara[groupId_clara]?.messages_clara ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Clara(userId_clara: Int) -> MessageModel_Clara? {
        return userMesMap_Clara[userId_clara]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Clara(message_clara: String, chatType_clara: ChatType_Clara, id_clara: Int) {
        let currentTime_clara = getCurrentTime_Clara()
        
        let chatMessage_clara = MessageModel_Clara(
            messageId_clara: Int(Date().timeIntervalSince1970 * 1000),
            content_clara: message_clara,
            userHead_clara: "current_user_head", // 这里应该从UserViewModel获取
            isMine_clara: true,
            time_clara: currentTime_clara
        )
        
        switch chatType_clara {
        case .personal_clara:
            // 个人聊天
            if userMesMap_Clara[id_clara] == nil {
                userMesMap_Clara[id_clara] = []
            }
            userMesMap_Clara[id_clara]?.append(chatMessage_clara)
            handleMessage_Clara(message_clara: chatMessage_clara, id_clara: id_clara, chatType_clara: chatType_clara)
            
        case .group_clara:
            // 群聊
            if var groupInfo_clara = groupChats_Clara[id_clara] {
                groupInfo_clara.messages_clara.append(chatMessage_clara)
                groupChats_Clara[id_clara] = groupInfo_clara
            } else {
                groupChats_Clara[id_clara] = GroupChatInfo_Clara(
                    gid_clara: id_clara,
                    intro_clara: "",
                    cover_clara: "",
                    join_clara: "",
                    messages_clara: [chatMessage_clara]
                )
            }
            
        case .ai_clara:
            // AI聊天
            aiChats_Clara.append(chatMessage_clara)
            handleMessage_Clara(message_clara: chatMessage_clara, id_clara: id_clara, chatType_clara: chatType_clara)
        }
        
        notifyStateChange_Clara()
    }
    
    /// 处理消息回复
    private func handleMessage_Clara(message_clara: MessageModel_Clara, id_clara: Int, chatType_clara: ChatType_Clara) {
        Task {
            let response_clara = await chatService_Clara(
                userId_clara: 0, // 这里应该从UserViewModel获取
                message_clara: message_clara.content_Clara ?? ""
            )
            
            let replyMessage_clara = MessageModel_Clara(
                messageId_clara: Int(Date().timeIntervalSince1970 * 1000),
                content_clara: response_clara ?? "Server error",
                userHead_clara: "",
                isMine_clara: false,
                time_clara: getCurrentTime_Clara()
            )
            
            switch chatType_clara {
            case .ai_clara:
                aiChats_Clara.append(replyMessage_clara)
                
            case .personal_clara:
                if userMesMap_Clara[id_clara] == nil {
                    userMesMap_Clara[id_clara] = []
                }
                userMesMap_Clara[id_clara]?.append(replyMessage_clara)
                
            case .group_clara:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Clara()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Clara(groupId_clara: Int) {
        if var groupInfo_clara = groupChats_Clara[groupId_clara] {
            groupInfo_clara.messages_clara = []
            groupChats_Clara[groupId_clara] = groupInfo_clara
            notifyStateChange_Clara()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Clara(groupId_clara: Int) {
        groupChats_Clara.removeValue(forKey: groupId_clara)
        notifyStateChange_Clara()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Clara() {
        aiChats_Clara = []
        notifyStateChange_Clara()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Clara(userId_clara: Int) {
        userMesMap_Clara.removeValue(forKey: userId_clara)
        notifyStateChange_Clara()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Clara() {
        userMesMap_Clara = [:]
        groupChats_Clara = [:]
        aiChats_Clara = []
        notifyStateChange_Clara()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Clara() -> String {
        let formatter_clara = DateFormatter()
        formatter_clara.dateFormat = "HH:mm"
        return formatter_clara.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Clara() {
        NotificationCenter.default.post(
            name: MessageViewModel_Clara.messageStateDidChangeNotification_Clara,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Clara(userId_clara: Int, message_clara: String) async -> String? {
        do {
            let bundleId_clara = "com.clara.app"
            let timestamp_clara = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_clara = generateRandomString_Clara(length_clara: 16)
            let sessionId_clara = "\(timestamp_clara)_\(randomString_clara)"
            
            // 解密URL
            let urlString_clara = decryptUrl_Clara(encryptedCodes_clara: MessageViewModel_Clara.chatService_Clara)
            guard let url_clara = URL(string: urlString_clara) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_clara = URLRequest(url: url_clara)
            request_clara.httpMethod = "POST"
            request_clara.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_clara: [String: Any] = [
                "bundle_id": bundleId_clara,
                "session_id": sessionId_clara,
                "content_type": "text",
                "content": message_clara
            ]
            
            request_clara.httpBody = try JSONSerialization.data(withJSONObject: body_clara)
            
            let (data_clara, response_clara) = try await URLSession.shared.data(for: request_clara)
            
            if let httpResponse_clara = response_clara as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_clara.statusCode)")
                
                if httpResponse_clara.statusCode == 200 {
                    if let json_clara = try JSONSerialization.jsonObject(with: data_clara) as? [String: Any],
                       let code_clara = json_clara["code"] as? Int,
                       code_clara == 1003,
                       let data_clara = json_clara["data"] as? [String: Any],
                       let answer_clara = data_clara["answer"] as? String,
                       !answer_clara.isEmpty {
                        return answer_clara
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL加密方法（双重加密：字符偏移加密 + 异或加密）
    static func encryptUrl_Clara(plainUrl_Clara: String) -> [Int] {
        let xorKey_Clara = 20 // 异或密钥
        let offset_Clara = 23 // 字符偏移量
        
        var result_Clara: [Int] = []
        
        // 第一层：字符偏移加密
        for char_Clara in plainUrl_Clara.unicodeScalars {
            let charCode_Clara = Int(char_Clara.value) + offset_Clara
            result_Clara.append(charCode_Clara)
        }
        
        // 第二层：异或加密
        var finalResult_Clara: [Int] = []
        for code_Clara in result_Clara {
            finalResult_Clara.append(code_Clara ^ xorKey_Clara)
        }
        
        print("✅ URL加密结果: \(finalResult_Clara)")
        return finalResult_Clara
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Clara(encryptedCodes_clara: [Int]) -> String {
        let xorKey_clara = 20 // 异或密钥
        let offset_clara = 23 // 字符偏移量
        
        var result_clara = ""
        
        // 第一层：异或解密
        for code_clara in encryptedCodes_clara {
            let charCode_clara = code_clara ^ xorKey_clara
            if let scalar_clara = UnicodeScalar(charCode_clara) {
                result_clara.append(Character(scalar_clara))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_clara = ""
        for char_clara in result_clara.unicodeScalars {
            let charCode_clara = Int(char_clara.value) - offset_clara
            if let scalar_clara = UnicodeScalar(charCode_clara) {
                finalResult_clara.append(Character(scalar_clara))
            }
        }
        
        return finalResult_clara
    }
    
    /// 生成随机字符串
    private func generateRandomString_Clara(length_clara: Int) -> String {
        let letters_clara = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_clara).map { _ in letters_clara.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Clara {
    /// 群组ID
    var gid_clara: Int
    /// 群组简介
    var intro_clara: String
    /// 群组封面
    var cover_clara: String
    /// 加入信息
    var join_clara: String
    /// 消息列表
    var messages_clara: [MessageModel_Clara]
}
