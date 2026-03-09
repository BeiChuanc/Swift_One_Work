import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Moode {
    /// 个人聊天
    case personal_moode
    /// 群聊
    case group_moode
    /// AI聊天
    case ai_moode
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Moode {
    
    /// 单例
    static let shared_Moode = MessageViewModel_Moode()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Moode = Notification.Name("MessageStateDidChange_Moode")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Moode: [Int: [MessageModel_Moode]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Moode: [Int: GroupChatInfo_Moode] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Moode: [MessageModel_Moode] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Moode: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Moode() {
        userMesMap_Moode = [:]
        aiChats_Moode = []
        setGroup_Moode()
        notifyStateChange_Moode()
    }
    
    /// 设置群聊基础信息
    /// 功能：初始化5个预设群聊
    private func setGroup_Moode() {
        groupChats_Moode = [
            10: GroupChatInfo_Moode(
                gid_moode: 10,
                intro_moode: "Bonfire Stories Hub",
                cover_moode: "",
                join_moode: "",
                messages_moode: []
            ),
            11: GroupChatInfo_Moode(
                gid_moode: 11,
                intro_moode: "Night Gathering Friends",
                cover_moode: "",
                join_moode: "",
                messages_moode: []
            ),
            12: GroupChatInfo_Moode(
                gid_moode: 12,
                intro_moode: "Campfire Adventure Team",
                cover_moode: "",
                join_moode: "",
                messages_moode: []
            ),
            13: GroupChatInfo_Moode(
                gid_moode: 13,
                intro_moode: "Outdoor Bonfire Lovers",
                cover_moode: "",
                join_moode: "",
                messages_moode: []
            ),
            14: GroupChatInfo_Moode(
                gid_moode: 14,
                intro_moode: "Warm Fire Community",
                cover_moode: "",
                join_moode: "",
                messages_moode: []
            )
        ]
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Moode() -> [Int: GroupChatInfo_Moode] {
        return groupChats_Moode
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Moode(userId_moode: Int) -> [MessageModel_Moode] {
        return userMesMap_Moode[userId_moode] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Moode() -> [PrewUserModel_Moode] {
        let userIds_moode = userMesMap_Moode.keys
        return LocalData_Moode.shared_Moode.userList_Moode.filter { user in
            guard let userId = user.userId_Moode else { return false }
            return userIds_moode.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Moode() -> [MessageModel_Moode] {
        return aiChats_Moode
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Moode(groupId_moode: Int) -> [MessageModel_Moode] {
        return groupChats_Moode[groupId_moode]?.messages_moode ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Moode(userId_moode: Int) -> MessageModel_Moode? {
        return userMesMap_Moode[userId_moode]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Moode(message_moode: String, chatType_moode: ChatType_Moode, id_moode: Int) {
        let currentTime_moode = getCurrentTime_Moode()
        
        let chatMessage_moode = MessageModel_Moode(
            messageId_moode: Int(Date().timeIntervalSince1970 * 1000),
            content_moode: message_moode,
            userHead_moode: "current_user_head", // 这里应该从UserViewModel获取
            isMine_moode: true,
            time_moode: currentTime_moode
        )
        
        switch chatType_moode {
        case .personal_moode:
            // 个人聊天
            if userMesMap_Moode[id_moode] == nil {
                userMesMap_Moode[id_moode] = []
            }
            userMesMap_Moode[id_moode]?.append(chatMessage_moode)
            handleMessage_Moode(message_moode: chatMessage_moode, id_moode: id_moode, chatType_moode: chatType_moode)
            
        case .group_moode:
            // 群聊
            if var groupInfo_moode = groupChats_Moode[id_moode] {
                groupInfo_moode.messages_moode.append(chatMessage_moode)
                groupChats_Moode[id_moode] = groupInfo_moode
            } else {
                groupChats_Moode[id_moode] = GroupChatInfo_Moode(
                    gid_moode: id_moode,
                    intro_moode: "",
                    cover_moode: "",
                    join_moode: "",
                    messages_moode: [chatMessage_moode]
                )
            }
            
        case .ai_moode:
            // AI聊天
            aiChats_Moode.append(chatMessage_moode)
            handleMessage_Moode(message_moode: chatMessage_moode, id_moode: id_moode, chatType_moode: chatType_moode)
        }
        
        notifyStateChange_Moode()
    }
    
    /// 处理消息回复
    private func handleMessage_Moode(message_moode: MessageModel_Moode, id_moode: Int, chatType_moode: ChatType_Moode) {
        Task {
            let response_moode = await chatService_Moode(
                userId_moode: 0, // 这里应该从UserViewModel获取
                message_moode: message_moode.content_Moode ?? ""
            )
            
            let replyMessage_moode = MessageModel_Moode(
                messageId_moode: Int(Date().timeIntervalSince1970 * 1000),
                content_moode: response_moode ?? "Server error",
                userHead_moode: "",
                isMine_moode: false,
                time_moode: getCurrentTime_Moode()
            )
            
            switch chatType_moode {
            case .ai_moode:
                aiChats_Moode.append(replyMessage_moode)
                
            case .personal_moode:
                if userMesMap_Moode[id_moode] == nil {
                    userMesMap_Moode[id_moode] = []
                }
                userMesMap_Moode[id_moode]?.append(replyMessage_moode)
                
            case .group_moode:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Moode()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Moode(groupId_moode: Int) {
        if var groupInfo_moode = groupChats_Moode[groupId_moode] {
            groupInfo_moode.messages_moode = []
            groupChats_Moode[groupId_moode] = groupInfo_moode
            notifyStateChange_Moode()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Moode(groupId_moode: Int) {
        groupChats_Moode.removeValue(forKey: groupId_moode)
        notifyStateChange_Moode()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Moode() {
        aiChats_Moode = []
        notifyStateChange_Moode()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Moode(userId_moode: Int) {
        userMesMap_Moode.removeValue(forKey: userId_moode)
        notifyStateChange_Moode()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Moode() {
        userMesMap_Moode = [:]
        groupChats_Moode = [:]
        aiChats_Moode = []
        notifyStateChange_Moode()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Moode() -> String {
        let formatter_moode = DateFormatter()
        formatter_moode.dateFormat = "HH:mm"
        return formatter_moode.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Moode() {
        NotificationCenter.default.post(
            name: MessageViewModel_Moode.messageStateDidChangeNotification_Moode,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Moode(userId_moode: Int, message_moode: String) async -> String? {
        do {
            let bundleId_moode = "com.moode.app"
            let timestamp_moode = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_moode = generateRandomString_Moode(length_moode: 16)
            let sessionId_moode = "\(timestamp_moode)_\(randomString_moode)"
            
            // 解密URL
            let urlString_moode = decryptUrl_Moode(encryptedCodes_moode: MessageViewModel_Moode.chatService_Moode)
            guard let url_moode = URL(string: urlString_moode) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_moode = URLRequest(url: url_moode)
            request_moode.httpMethod = "POST"
            request_moode.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_moode: [String: Any] = [
                "bundle_id": bundleId_moode,
                "session_id": sessionId_moode,
                "content_type": "text",
                "content": message_moode
            ]
            
            request_moode.httpBody = try JSONSerialization.data(withJSONObject: body_moode)
            
            let (data_moode, response_moode) = try await URLSession.shared.data(for: request_moode)
            
            if let httpResponse_moode = response_moode as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_moode.statusCode)")
                
                if httpResponse_moode.statusCode == 200 {
                    if let json_moode = try JSONSerialization.jsonObject(with: data_moode) as? [String: Any],
                       let code_moode = json_moode["code"] as? Int,
                       code_moode == 1003,
                       let data_moode = json_moode["data"] as? [String: Any],
                       let answer_moode = data_moode["answer"] as? String,
                       !answer_moode.isEmpty {
                        return answer_moode
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
    private func decryptUrl_Moode(encryptedCodes_moode: [Int]) -> String {
        let xorKey_moode = 20 // 异或密钥
        let offset_moode = 23 // 字符偏移量
        
        var result_moode = ""
        
        // 第一层：异或解密
        for code_moode in encryptedCodes_moode {
            let charCode_moode = code_moode ^ xorKey_moode
            if let scalar_moode = UnicodeScalar(charCode_moode) {
                result_moode.append(Character(scalar_moode))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_moode = ""
        for char_moode in result_moode.unicodeScalars {
            let charCode_moode = Int(char_moode.value) - offset_moode
            if let scalar_moode = UnicodeScalar(charCode_moode) {
                finalResult_moode.append(Character(scalar_moode))
            }
        }
        
        return finalResult_moode
    }
    
    /// 生成随机字符串
    private func generateRandomString_Moode(length_moode: Int) -> String {
        let letters_moode = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_moode).map { _ in letters_moode.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Moode {
    /// 群组ID
    var gid_moode: Int
    /// 群组简介
    var intro_moode: String
    /// 群组封面
    var cover_moode: String
    /// 加入信息
    var join_moode: String
    /// 消息列表
    var messages_moode: [MessageModel_Moode]
}
