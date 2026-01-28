import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Base_one {
    /// 个人聊天
    case personal_base_one
    /// 群聊
    case group_base_one
    /// AI聊天
    case ai_base_one
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Base_one {
    
    /// 单例
    static let shared_Base_one = MessageViewModel_Base_one()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Base_one = Notification.Name("MessageStateDidChange_Base_one")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Base_one: [Int: [MessageModel_Base_one]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Base_one: [Int: GroupChatInfo_Base_one] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Base_one: [MessageModel_Base_one] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Base_one: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Base_one() {
        userMesMap_Base_one = [:]
        aiChats_Base_one = []
        setGroup_Base_one()
        notifyStateChange_Base_one()
    }
    
    /// 设置群聊基础信息
    /// 功能：初始化5个预设群聊
    private func setGroup_Base_one() {
        groupChats_Base_one = [
            10: GroupChatInfo_Base_one(
                gid_base_one: 10,
                intro_base_one: "Bonfire Stories Hub",
                cover_base_one: "",
                join_base_one: "",
                messages_base_one: []
            ),
            11: GroupChatInfo_Base_one(
                gid_base_one: 11,
                intro_base_one: "Night Gathering Friends",
                cover_base_one: "",
                join_base_one: "",
                messages_base_one: []
            ),
            12: GroupChatInfo_Base_one(
                gid_base_one: 12,
                intro_base_one: "Campfire Adventure Team",
                cover_base_one: "",
                join_base_one: "",
                messages_base_one: []
            ),
            13: GroupChatInfo_Base_one(
                gid_base_one: 13,
                intro_base_one: "Outdoor Bonfire Lovers",
                cover_base_one: "",
                join_base_one: "",
                messages_base_one: []
            ),
            14: GroupChatInfo_Base_one(
                gid_base_one: 14,
                intro_base_one: "Warm Fire Community",
                cover_base_one: "",
                join_base_one: "",
                messages_base_one: []
            )
        ]
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Base_one() -> [Int: GroupChatInfo_Base_one] {
        return groupChats_Base_one
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Base_one(userId_base_one: Int) -> [MessageModel_Base_one] {
        return userMesMap_Base_one[userId_base_one] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Base_one() -> [PrewUserModel_Base_one] {
        let userIds_base_one = userMesMap_Base_one.keys
        return LocalData_Base_one.shared_Base_one.userList_Base_one.filter { user in
            guard let userId = user.userId_Base_one else { return false }
            return userIds_base_one.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Base_one() -> [MessageModel_Base_one] {
        return aiChats_Base_one
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Base_one(groupId_base_one: Int) -> [MessageModel_Base_one] {
        return groupChats_Base_one[groupId_base_one]?.messages_base_one ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Base_one(userId_base_one: Int) -> MessageModel_Base_one? {
        return userMesMap_Base_one[userId_base_one]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Base_one(message_base_one: String, chatType_base_one: ChatType_Base_one, id_base_one: Int) {
        let currentTime_base_one = getCurrentTime_Base_one()
        
        let chatMessage_base_one = MessageModel_Base_one(
            messageId_base_one: Int(Date().timeIntervalSince1970 * 1000),
            content_base_one: message_base_one,
            userHead_base_one: "current_user_head", // 这里应该从UserViewModel获取
            isMine_base_one: true,
            time_base_one: currentTime_base_one
        )
        
        switch chatType_base_one {
        case .personal_base_one:
            // 个人聊天
            if userMesMap_Base_one[id_base_one] == nil {
                userMesMap_Base_one[id_base_one] = []
            }
            userMesMap_Base_one[id_base_one]?.append(chatMessage_base_one)
            handleMessage_Base_one(message_base_one: chatMessage_base_one, id_base_one: id_base_one, chatType_base_one: chatType_base_one)
            
        case .group_base_one:
            // 群聊
            if var groupInfo_base_one = groupChats_Base_one[id_base_one] {
                groupInfo_base_one.messages_base_one.append(chatMessage_base_one)
                groupChats_Base_one[id_base_one] = groupInfo_base_one
            } else {
                groupChats_Base_one[id_base_one] = GroupChatInfo_Base_one(
                    gid_base_one: id_base_one,
                    intro_base_one: "",
                    cover_base_one: "",
                    join_base_one: "",
                    messages_base_one: [chatMessage_base_one]
                )
            }
            
        case .ai_base_one:
            // AI聊天
            aiChats_Base_one.append(chatMessage_base_one)
            handleMessage_Base_one(message_base_one: chatMessage_base_one, id_base_one: id_base_one, chatType_base_one: chatType_base_one)
        }
        
        notifyStateChange_Base_one()
    }
    
    /// 处理消息回复
    private func handleMessage_Base_one(message_base_one: MessageModel_Base_one, id_base_one: Int, chatType_base_one: ChatType_Base_one) {
        Task {
            let response_base_one = await chatService_Base_one(
                userId_base_one: 0, // 这里应该从UserViewModel获取
                message_base_one: message_base_one.content_Base_one ?? ""
            )
            
            let replyMessage_base_one = MessageModel_Base_one(
                messageId_base_one: Int(Date().timeIntervalSince1970 * 1000),
                content_base_one: response_base_one ?? "Server error",
                userHead_base_one: "",
                isMine_base_one: false,
                time_base_one: getCurrentTime_Base_one()
            )
            
            switch chatType_base_one {
            case .ai_base_one:
                aiChats_Base_one.append(replyMessage_base_one)
                
            case .personal_base_one:
                if userMesMap_Base_one[id_base_one] == nil {
                    userMesMap_Base_one[id_base_one] = []
                }
                userMesMap_Base_one[id_base_one]?.append(replyMessage_base_one)
                
            case .group_base_one:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Base_one()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Base_one(groupId_base_one: Int) {
        if var groupInfo_base_one = groupChats_Base_one[groupId_base_one] {
            groupInfo_base_one.messages_base_one = []
            groupChats_Base_one[groupId_base_one] = groupInfo_base_one
            notifyStateChange_Base_one()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Base_one(groupId_base_one: Int) {
        groupChats_Base_one.removeValue(forKey: groupId_base_one)
        notifyStateChange_Base_one()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Base_one() {
        aiChats_Base_one = []
        notifyStateChange_Base_one()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Base_one(userId_base_one: Int) {
        userMesMap_Base_one.removeValue(forKey: userId_base_one)
        notifyStateChange_Base_one()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Base_one() {
        userMesMap_Base_one = [:]
        groupChats_Base_one = [:]
        aiChats_Base_one = []
        notifyStateChange_Base_one()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Base_one() -> String {
        let formatter_base_one = DateFormatter()
        formatter_base_one.dateFormat = "HH:mm"
        return formatter_base_one.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Base_one() {
        NotificationCenter.default.post(
            name: MessageViewModel_Base_one.messageStateDidChangeNotification_Base_one,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Base_one(userId_base_one: Int, message_base_one: String) async -> String? {
        do {
            let bundleId_base_one = "com.base_one.app"
            let timestamp_base_one = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_base_one = generateRandomString_Base_one(length_base_one: 16)
            let sessionId_base_one = "\(timestamp_base_one)_\(randomString_base_one)"
            
            // 解密URL
            let urlString_base_one = decryptUrl_Base_one(encryptedCodes_base_one: MessageViewModel_Base_one.chatService_Base_one)
            guard let url_base_one = URL(string: urlString_base_one) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_base_one = URLRequest(url: url_base_one)
            request_base_one.httpMethod = "POST"
            request_base_one.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_base_one: [String: Any] = [
                "bundle_id": bundleId_base_one,
                "session_id": sessionId_base_one,
                "content_type": "text",
                "content": message_base_one
            ]
            
            request_base_one.httpBody = try JSONSerialization.data(withJSONObject: body_base_one)
            
            let (data_base_one, response_base_one) = try await URLSession.shared.data(for: request_base_one)
            
            if let httpResponse_base_one = response_base_one as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_base_one.statusCode)")
                
                if httpResponse_base_one.statusCode == 200 {
                    if let json_base_one = try JSONSerialization.jsonObject(with: data_base_one) as? [String: Any],
                       let code_base_one = json_base_one["code"] as? Int,
                       code_base_one == 1003,
                       let data_base_one = json_base_one["data"] as? [String: Any],
                       let answer_base_one = data_base_one["answer"] as? String,
                       !answer_base_one.isEmpty {
                        return answer_base_one
                    }
                }
            }
            return "Server error"
        } catch {
            print("❌ chatService 错误: \(error)")
            return "Server error"
        }
    }
    
    /// URL解密方法（双重解密：异或解密 + 字符偏移解密）
    private func decryptUrl_Base_one(encryptedCodes_base_one: [Int]) -> String {
        let xorKey_base_one = 20 // 异或密钥
        let offset_base_one = 23 // 字符偏移量
        
        var result_base_one = ""
        
        // 第一层：异或解密
        for code_base_one in encryptedCodes_base_one {
            let charCode_base_one = code_base_one ^ xorKey_base_one
            if let scalar_base_one = UnicodeScalar(charCode_base_one) {
                result_base_one.append(Character(scalar_base_one))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_base_one = ""
        for char_base_one in result_base_one.unicodeScalars {
            let charCode_base_one = Int(char_base_one.value) - offset_base_one
            if let scalar_base_one = UnicodeScalar(charCode_base_one) {
                finalResult_base_one.append(Character(scalar_base_one))
            }
        }
        
        return finalResult_base_one
    }
    
    /// 生成随机字符串
    private func generateRandomString_Base_one(length_base_one: Int) -> String {
        let letters_base_one = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_base_one).map { _ in letters_base_one.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Base_one {
    /// 群组ID
    var gid_base_one: Int
    /// 群组简介
    var intro_base_one: String
    /// 群组封面
    var cover_base_one: String
    /// 加入信息
    var join_base_one: String
    /// 消息列表
    var messages_base_one: [MessageModel_Base_one]
}
