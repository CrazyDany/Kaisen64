local dev_mode = false

hook_chat_command('k64-dev', 'Укажите специальный ключ для подтверждения перехода в режим разработчика',
    function(msg)
        local inputedKey = msg

        if inputedKey == '3141592653' then
            dev_mode = not dev_mode
            return true
        end

        return false
    end
)

function IsDevModActivated()
    return dev_mode
end
