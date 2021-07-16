local addonName, _ = ...
local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "ruRU")
if not L then return end
------------------------------------------------------------------------------

L["|cffffff00Click|r to toggle the triton main window."] = "|cffffff00Нажмите|r чтобы переключить главное окно triton."
L["TRITON"] = "Triton";

L["Only alias specified"] = "Указан только алиас"

L["Add new keywords"] = "Добавление новых ключевых слов"
L["Keywords (, & - may be used)"] = "Ключевые слова (, & - можно использовать символы)"
L["Add"] = "Добавить"
L["Back"] = "Назад"
L["Remove all keywords"] = "Удалить все ключевые слова"
L["Keywords will be removed!"] = "Ключевые слова будут удалены!"
L["Remove"] = "Удалить"
L["Cancel"] = "Отменить"
L["Keywords could not be empty"] = "Ключевые слова не могут быть пустыми"
L["Edit keywords"] = "Редактировать ключевые слова"
L["Confirm"] = "Подтвердить"
L["@"] = "@"
L["|cffffff00Click|r to toggle the triton main window."] = "|cffffff00Нажмите|r чтобы переключить главное окно triton"
L["Message alive time"] = "Как долго сохраняются сообщения"
L["How long will message be removed from event (default to 120 seconds)?"] = "Как долго сообщение не будет удалено из события (по умолчанию 120 секунд)?"
L["Font size"] = "Размер шрифта"
L["Font size of event window (default to 12.8)."] = "Размер шрифта окна события (по умолчанию 12.8)."
L["Refresh interval"] = "Интервал обновления"
L["How frequent to refresh event window (default to 2 seconds)?"] = "Как часто нужно обновлять окно событий (по умолчанию до 2 секунд)?"
L["enter /triton for main interface"] = "введите /triton для вызова главного интерфейса"

L["Choose operation: |cff00cccc"] = "Выберите операцию:|cff00cccc"
L["Block user"] = "Заблокировать игрока"
L["Add friend"] = "Добавить друга"
L["Copy user name"] = "Копировать имя игрока"
L["User details"] = "Сведения о игроке"
L["Whisper"] = "Шепот"
L["|cffff9900Cancel"] = "|cffff9900Отменить"

L["User spam score"] = "оценка спама"
L["'s spam score is "] = " оценка "
L["Please install Acamar auto-learning spam filtering addon to obtain user's spam score."] = "Установите аддон самообучающейся фильтрации спама Acamar, чтобы получить спам-рейтинг игрока."

L["ADDON_INFO"] = '|cffca99ffTriton|r отслеживание только тех сообщений, которые вам нужны, обязательно для LFG. организовать сообщения по темам для вас, чтобы отслеживать события LFG, Gold Raid и другие, которые могут вас заинтересовать.'

L["AUTHOR_INFO"] = 'Подсказка: при вводе ключевых слов используйте запятую |cff00cccc&|r чтобы разделить ключевые слова. |cff00cccc&|r можно использовать как "|cff00cccи|r" оператора, |cff00cccc-|r может быть использован "|cff00ccccбез|r" оператора. Ключевое слово для класса：|cff00ccccкласс:чернокнижник|r обратитесь к чернокнижнику и т. д. Имя отправителя может использоваться в поиске и игнорироваться регистром.\n\n' .. 
'Например:\n' .. 
'OYN&LFG: должна включать |cff00ccccOYN|r и |cff00ccccLFG|r.\n' ..
'OYN-Bad-fxxk: должна включать |cff00ccccOYN|r но ни один из них |cff00ccccBad|r или |cff00ccccfxxk|r.\n' ..
'OYN,MC,BWL: должен включать в себя один из |cff00ccccOYN|r, |cff00ccccMC|r и |cff00ccccBWL|r.' .. 
'\n\nhttps://github.com/bayard/triton\n|cffca99ffTriton|r@匕首岭 2020'

-- EOF
