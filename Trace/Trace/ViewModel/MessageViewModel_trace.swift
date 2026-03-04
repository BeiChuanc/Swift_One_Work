import Foundation

// MARK: 消息ViewModel

/// 消息类型枚举
enum ChatType_Trace {
    /// 个人聊天
    case personal_trace
    /// 群聊
    case group_trace
    /// AI聊天
    case ai_trace
}

/// 消息状态管理类
@MainActor
class MessageViewModel_Trace {
    
    /// 单例
    static let shared_Trace = MessageViewModel_Trace()
    
    // MARK: - 通知名称
    
    /// 消息状态更新通知
    static let messageStateDidChangeNotification_Trace = Notification.Name("MessageStateDidChange_Trace")
    
    // MARK: - 私有属性
    
    /// 个人消息映射（用户ID -> 消息列表）
    private var userMesMap_Trace: [Int: [MessageModel_Trace]] = [:]
    
    /// 群聊信息映射
    private var groupChats_Trace: [Int: GroupChatInfo_Trace] = [:]
    
    /// AI聊天消息列表
    private var aiChats_Trace: [MessageModel_Trace] = []
    
    /// 聊天服务URL（加密）
    private static let chatService_Trace: [Int] = [
        107, 159, 159, 147, 158, 69, 82, 82, 108, 147, 148, 81, 154, 148, 158, 104,
        108, 148, 148, 81, 110, 146, 144, 82, 154, 148, 158, 104, 108, 148, 82, 153,
        92, 82, 110, 107, 108, 159
    ]
    
    private init() {}
    
    // MARK: - 公共方法 - 初始化
    
    /// 初始化消息
    /// 功能：清空所有消息数据并重新设置群聊基础信息
    func initChat_Trace() {
        userMesMap_Trace = [:]
        aiChats_Trace = []
        setGroup_Trace()
        notifyStateChange_Trace()
    }
    
    /// 设置群聊基础信息
    /// 功能：初始化5个预设群聊
    private func setGroup_Trace() {
        groupChats_Trace = [
            10: GroupChatInfo_Trace(
                gid_trace: 10,
                intro_trace: "Bonfire Stories Hub",
                cover_trace: "",
                join_trace: "",
                messages_trace: []
            ),
            11: GroupChatInfo_Trace(
                gid_trace: 11,
                intro_trace: "Night Gathering Friends",
                cover_trace: "",
                join_trace: "",
                messages_trace: []
            ),
            12: GroupChatInfo_Trace(
                gid_trace: 12,
                intro_trace: "Campfire Adventure Team",
                cover_trace: "",
                join_trace: "",
                messages_trace: []
            ),
            13: GroupChatInfo_Trace(
                gid_trace: 13,
                intro_trace: "Outdoor Bonfire Lovers",
                cover_trace: "",
                join_trace: "",
                messages_trace: []
            ),
            14: GroupChatInfo_Trace(
                gid_trace: 14,
                intro_trace: "Warm Fire Community",
                cover_trace: "",
                join_trace: "",
                messages_trace: []
            )
        ]
    }
    
    // MARK: - 公共方法 - 获取数据
    
    /// 获取群聊信息字典
    func getGroupChats_Trace() -> [Int: GroupChatInfo_Trace] {
        return groupChats_Trace
    }
    
    /// 获取与指定用户的消息列表
    func getMessagesWithUser_Trace(userId_trace: Int) -> [MessageModel_Trace] {
        return userMesMap_Trace[userId_trace] ?? []
    }
    
    /// 获取有聊天记录的用户列表
    func getChatUsers_Trace() -> [PrewUserModel_Trace] {
        let userIds_trace = userMesMap_Trace.keys
        return LocalData_Trace.shared_Trace.userList_Trace.filter { user in
            guard let userId = user.userId_Trace else { return false }
            return userIds_trace.contains(userId)
        }
    }
    
    /// 获取AI聊天消息列表
    func getAiChats_Trace() -> [MessageModel_Trace] {
        return aiChats_Trace
    }
    
    /// 获取指定群聊的消息列表
    func getGroupMessages_Trace(groupId_trace: Int) -> [MessageModel_Trace] {
        return groupChats_Trace[groupId_trace]?.messages_trace ?? []
    }
    
    /// 获取与指定用户的最后一条消息
    func getLastMessageWithUser_Trace(userId_trace: Int) -> MessageModel_Trace? {
        return userMesMap_Trace[userId_trace]?.last
    }
    
    // MARK: - 公共方法 - 发送消息
    
    /// 发送消息
    func sendMessage_Trace(message_trace: String, chatType_trace: ChatType_Trace, id_trace: Int) {
        let currentTime_trace = getCurrentTime_Trace()
        
        let chatMessage_trace = MessageModel_Trace(
            messageId_trace: Int(Date().timeIntervalSince1970 * 1000),
            content_trace: message_trace,
            userHead_trace: "current_user_head", // 这里应该从UserViewModel获取
            isMine_trace: true,
            time_trace: currentTime_trace
        )
        
        switch chatType_trace {
        case .personal_trace:
            // 个人聊天
            if userMesMap_Trace[id_trace] == nil {
                userMesMap_Trace[id_trace] = []
            }
            userMesMap_Trace[id_trace]?.append(chatMessage_trace)
            handleMessage_Trace(message_trace: chatMessage_trace, id_trace: id_trace, chatType_trace: chatType_trace)
            
        case .group_trace:
            // 群聊
            if var groupInfo_trace = groupChats_Trace[id_trace] {
                groupInfo_trace.messages_trace.append(chatMessage_trace)
                groupChats_Trace[id_trace] = groupInfo_trace
            } else {
                groupChats_Trace[id_trace] = GroupChatInfo_Trace(
                    gid_trace: id_trace,
                    intro_trace: "",
                    cover_trace: "",
                    join_trace: "",
                    messages_trace: [chatMessage_trace]
                )
            }
            
        case .ai_trace:
            // AI聊天
            aiChats_Trace.append(chatMessage_trace)
            handleMessage_Trace(message_trace: chatMessage_trace, id_trace: id_trace, chatType_trace: chatType_trace)
        }
        
        notifyStateChange_Trace()
    }
    
    /// 处理消息回复
    private func handleMessage_Trace(message_trace: MessageModel_Trace, id_trace: Int, chatType_trace: ChatType_Trace) {
        Task {
            let response_trace = await chatService_Trace(
                userId_trace: 0, // 这里应该从UserViewModel获取
                message_trace: message_trace.content_Trace ?? ""
            )
            
            let replyMessage_trace = MessageModel_Trace(
                messageId_trace: Int(Date().timeIntervalSince1970 * 1000),
                content_trace: response_trace ?? "Server error",
                userHead_trace: "",
                isMine_trace: false,
                time_trace: getCurrentTime_Trace()
            )
            
            switch chatType_trace {
            case .ai_trace:
                aiChats_Trace.append(replyMessage_trace)
                
            case .personal_trace:
                if userMesMap_Trace[id_trace] == nil {
                    userMesMap_Trace[id_trace] = []
                }
                userMesMap_Trace[id_trace]?.append(replyMessage_trace)
                
            case .group_trace:
                break // 群聊不自动回复
            }
            
            notifyStateChange_Trace()
        }
    }
    
    // MARK: - 公共方法 - 删除/清空消息
    func clearGroupMessages_Trace(groupId_trace: Int) {
        if var groupInfo_trace = groupChats_Trace[groupId_trace] {
            groupInfo_trace.messages_trace = []
            groupChats_Trace[groupId_trace] = groupInfo_trace
            notifyStateChange_Trace()
        }
    }
    
    /// 移除指定群组
    func removeGroup_Trace(groupId_trace: Int) {
        groupChats_Trace.removeValue(forKey: groupId_trace)
        notifyStateChange_Trace()
    }
    
    /// 清空AI聊天记录
    func clearAiChat_Trace() {
        aiChats_Trace = []
        notifyStateChange_Trace()
    }
    
    /// 删除与指定用户的消息
    func deleteUserMessages_Trace(userId_trace: Int) {
        userMesMap_Trace.removeValue(forKey: userId_trace)
        notifyStateChange_Trace()
    }
    
    /// 退出登录清空所有聊天数据
    func logoutChat_Trace() {
        userMesMap_Trace = [:]
        groupChats_Trace = [:]
        aiChats_Trace = []
        notifyStateChange_Trace()
    }
    
    // MARK: - 私有方法 - 工具方法
    
    /// 获取当前时间字符串
    private func getCurrentTime_Trace() -> String {
        let formatter_trace = DateFormatter()
        formatter_trace.dateFormat = "HH:mm"
        return formatter_trace.string(from: Date())
    }
    
    /// 发送状态更新通知
    private func notifyStateChange_Trace() {
        NotificationCenter.default.post(
            name: MessageViewModel_Trace.messageStateDidChangeNotification_Trace,
            object: nil
        )
    }
    
    // MARK: - 网络请求
    
    /// 聊天服务API
    private func chatService_Trace(userId_trace: Int, message_trace: String) async -> String? {
        do {
            let bundleId_trace = "com.trace.app"
            let timestamp_trace = String(Int(Date().timeIntervalSince1970 * 1000))
            let randomString_trace = generateRandomString_Trace(length_trace: 16)
            let sessionId_trace = "\(timestamp_trace)_\(randomString_trace)"
            
            // 解密URL
            let urlString_trace = decryptUrl_Trace(encryptedCodes_trace: MessageViewModel_Trace.chatService_Trace)
            guard let url_trace = URL(string: urlString_trace) else {
                print("❌ 错误：无效的URL")
                return nil
            }
            
            var request_trace = URLRequest(url: url_trace)
            request_trace.httpMethod = "POST"
            request_trace.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body_trace: [String: Any] = [
                "bundle_id": bundleId_trace,
                "session_id": sessionId_trace,
                "content_type": "text",
                "content": message_trace
            ]
            
            request_trace.httpBody = try JSONSerialization.data(withJSONObject: body_trace)
            
            let (data_trace, response_trace) = try await URLSession.shared.data(for: request_trace)
            
            if let httpResponse_trace = response_trace as? HTTPURLResponse {
                print("✅ HTTP状态码: \(httpResponse_trace.statusCode)")
                
                if httpResponse_trace.statusCode == 200 {
                    if let json_trace = try JSONSerialization.jsonObject(with: data_trace) as? [String: Any],
                       let code_trace = json_trace["code"] as? Int,
                       code_trace == 1003,
                       let data_trace = json_trace["data"] as? [String: Any],
                       let answer_trace = data_trace["answer"] as? String,
                       !answer_trace.isEmpty {
                        return answer_trace
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
    private func decryptUrl_Trace(encryptedCodes_trace: [Int]) -> String {
        let xorKey_trace = 20 // 异或密钥
        let offset_trace = 23 // 字符偏移量
        
        var result_trace = ""
        
        // 第一层：异或解密
        for code_trace in encryptedCodes_trace {
            let charCode_trace = code_trace ^ xorKey_trace
            if let scalar_trace = UnicodeScalar(charCode_trace) {
                result_trace.append(Character(scalar_trace))
            }
        }
        
        // 第二层：字符偏移解密
        var finalResult_trace = ""
        for char_trace in result_trace.unicodeScalars {
            let charCode_trace = Int(char_trace.value) - offset_trace
            if let scalar_trace = UnicodeScalar(charCode_trace) {
                finalResult_trace.append(Character(scalar_trace))
            }
        }
        
        return finalResult_trace
    }
    
    /// 生成随机字符串
    private func generateRandomString_Trace(length_trace: Int) -> String {
        let letters_trace = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length_trace).map { _ in letters_trace.randomElement()! })
    }
}

// MARK: - 辅助数据结构

/// 群聊信息结构体
struct GroupChatInfo_Trace {
    /// 群组ID
    var gid_trace: Int
    /// 群组简介
    var intro_trace: String
    /// 群组封面
    var cover_trace: String
    /// 加入信息
    var join_trace: String
    /// 消息列表
    var messages_trace: [MessageModel_Trace]
}
