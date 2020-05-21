### Triton

##### Tracking only messages you want, must-have for LFG. Triton, a WoW classic addon organizes messages into topics for you to track events of LFG, gold raid and others you may interested.

Chat messages in WoW were messy and spammed. Trying to find something you interested in fast scrolling chat message is challenging. 

Triton organize chat messages into topics by:

1. Filter out messages you interested by keywords
2. Organize the message into topics by tracking sender and event words (keywords)
3. Refresh the topics once sender send new messages with same topic

Simple and clear.

##### Using keywords

- Multiple keywords can be separated by comma (,)
- Using & as 'and' operator
- Using - as 'not' operator
- Special class keywords: class:warlock = warlock, class:mage = mage, etc
- Message, sender's name and class can be used in search
- Blizzard item link keyword can be used in search.

##### Examples

- bwl: accept messages which contain bwl
- -class:warlock&-summon: not accept messages contain 'summon' by warlock
- bwl,mc,ony: accept messages contain one of the words of: bwl, mc and ony
- bwl&lfg: accept messages with both bwl and lfg contained
- Hitem: search item link in messages

##### Options

- Message live time: Set max time for topics to be alive in window

- Font size: Windows font size

- Refresh interval: Time interval for window to refresh

##### Support blacklist of *Global Ignore List*

*Global Ignore List* is a great addon to block spam messages. Triton rejects messages sent by players in blacklist of *Global Ignore List*.

##### Thanks

Thanks to authors of Global Ignore List, CChatNotifier and an unknown author who revised CChatNotifier to support and/or operators. 

##### Author

Triton@匕首岭, 2020

----

### Triton

##### Triton实时跟踪你要的消息，跟团必备。Triton是魔兽世界怀旧服的插件，将杂乱的聊天消息组织成清晰明了的主题，无论是关注金团还是寻找队伍等， 从此变得非常简单。

聊天消息非常杂乱而且垃圾信息充斥，从这些消息中找到有用的信息吃力又伤眼。

所以，开发Triton目的就是为了将聊天消息归纳成清晰主题：

1. 通过关键字滤出需要的信息；
2. 以发送人和关键字做主题，将消息归纳到主题下；
3. 当收到同样主题的消息，刷新主题对应的信息。

简单直接。

##### 使用关键字

- 多关键字用逗号隔开
- 用&连接多个要包含的关键字
- 将-放在关键字前表示滤掉含有此关键字的消息
- 支持特殊的职业关键字，如：class:warlock = 术士, class:mage = 法师, 等等
- 消息本身、玩家名字和职业可用于关键字搜索中
- Blizzard 的消息内链接关键字可也用于搜索中

##### 范例

- bwl：接收含有bwl的消息
- -class:warlock&-飞机：拒绝术士发的含有飞机的消息
- bwl,mc,黑龙：接收含有bwl、mc、黑龙任意一个关键字的消息
- bwl&金团：接收含有bwl及金团的消息
- Hitem: 搜索含有物品链接的消息

##### 选项

- 消息留存时长：窗口的主题最长留存时间

- 字体大小：窗口主题显示字体大小

- 更新频率：窗口的主题刷新频率

##### 支持 *Global Ignore List*

*Global Ignore List* 是非常好用的黑名单及过滤消息的插件。Triton支持 *Global Ignore List* 的黑名单，如果从这些黑名单发来的消息将会被拒绝。

##### 致谢

感谢 Global Ignore List, CChatNotifier 和一位不知名的 CChatNotifier 修改版的作者。 

##### 作者

Triton@匕首岭, 2020



MIT License

You may freely modify or distribute the code of Triton.