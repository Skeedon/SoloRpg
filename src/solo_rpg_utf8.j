// Warcraft III 1.26/1.27 - diagnostic JASS
globals
    unit srHero = null
    integer srKills = 0
    unit array srEnemies
    integer array srEnemyType
    real array srSpawnX
    real array srSpawnY
    boolean array srBoss
    integer srCount = 0
    boolean srInitialized = false
    dialog srDialog = null
    button srPal = null
    button srBlade = null
    button srMage = null
endglobals

function SRSpawn takes integer i returns nothing
    set srEnemies[i] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), srEnemyType[i], srSpawnX[i], srSpawnY[i], 270.)
endfunction

function SRAddSpawn takes integer raw, real x, real y, boolean boss returns nothing
    set srCount = srCount + 1
    set srEnemyType[srCount] = raw
    set srSpawnX[srCount] = x
    set srSpawnY[srCount] = y
    set srBoss[srCount] = boss
    call SRSpawn(srCount)
endfunction

function SRChoose takes nothing returns nothing
    local integer raw = 'Hpal'
    if GetClickedButton() == srBlade then
        set raw = 'Obla'
    elseif GetClickedButton() == srMage then
        set raw = 'Hamg'
    endif
    if srHero == null then
        set srHero = CreateUnit(Player(0), raw, 0., 0., 270.)
        call SelectUnitForPlayerSingle(srHero, Player(0))
    endif
    call DialogDisplay(Player(0), srDialog, false)
endfunction

function SRDeath takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer i = 1
    if u == srHero then
        call TriggerSleepAction(15.)
        call ReviveHero(srHero, 0., 0., true)
    else
        loop
            exitwhen i > srCount
            if u == srEnemies[i] then
                set srKills = srKills + 1
                call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD) + 10)
                if srBoss[i] then
                    call TriggerSleepAction(300.)
                else
                    call TriggerSleepAction(40.)
                endif
                call SRSpawn(i)
                exitwhen true
            endif
            set i = i + 1
        endloop
    endif
    set u = null
endfunction

function SRChat takes nothing returns nothing
    local string s = GetEventPlayerChatString()
    if s == "-help" then
        call DisplayTextToPlayer(Player(0), 0., 0., "Команды: -help, -stats")
    elseif s == "-stats" then
        call DisplayTextToPlayer(Player(0), 0., 0., "Убийств: " + I2S(srKills))
    endif
endfunction

function InitSoloRPG takes nothing returns nothing
    local trigger t
    if srInitialized then
        return
    endif
    set srInitialized = true
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(t, function SRDeath)
    set t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t, Player(0), "-", false)
    call TriggerAddAction(t, function SRChat)
    set srDialog = DialogCreate()
    call DialogSetMessage(srDialog, "Выберите героя")
    set srPal = DialogAddButton(srDialog, "Паладин", 0)
    set srBlade = DialogAddButton(srDialog, "Мастер клинка", 0)
    set srMage = DialogAddButton(srDialog, "Архимаг", 0)
    set t = CreateTrigger()
    call TriggerRegisterDialogEvent(t, srDialog)
    call TriggerAddAction(t, function SRChoose)
    call DialogDisplay(Player(0), srDialog, true)
    call SRAddSpawn('nfel', 950., 400., false)
    call SRAddSpawn('nfel', 1150., 500., false)
    call SRAddSpawn('nfel', 1300., 650., true)
    set t = null
endfunction
