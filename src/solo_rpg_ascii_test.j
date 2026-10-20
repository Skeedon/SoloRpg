// Warcraft III 1.26/1.27 - diagnostic JASS
// Declare these variables in World Editor (Ctrl+B), with prefix udg_:
// udg_srHero unit, udg_srKills integer, udg_srEnemies unit array,
// udg_srEnemyType integer array, udg_srSpawnX real array, udg_srSpawnY real array,
// udg_srBoss boolean array, udg_srCount integer, udg_srInitialized boolean,
// udg_srDialog dialog, udg_srPal button, udg_srBlade button, udg_srMage button.
// Do not paste this comment into the variables editor.
function SRSpawn takes integer i returns nothing
    set udg_srEnemies[i] = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), udg_srEnemyType[i], udg_srSpawnX[i], udg_srSpawnY[i], 270.)
endfunction

function SRAddSpawn takes integer raw, real x, real y, boolean boss returns nothing
    set udg_srCount = udg_srCount + 1
    set udg_srEnemyType[udg_srCount] = raw
    set udg_srSpawnX[udg_srCount] = x
    set udg_srSpawnY[udg_srCount] = y
    set udg_srBoss[udg_srCount] = boss
    call SRSpawn(udg_srCount)
endfunction

function SRChoose takes nothing returns nothing
    local integer raw = 'Hpal'
    if GetClickedButton() == udg_srBlade then
        set raw = 'Obla'
    elseif GetClickedButton() == udg_srMage then
        set raw = 'Hamg'
    endif
    if udg_srHero == null then
        set udg_srHero = CreateUnit(Player(0), raw, 0., 0., 270.)
        call SelectUnitForPlayerSingle(udg_srHero, Player(0))
    endif
    call DialogDisplay(Player(0), udg_srDialog, false)
endfunction

function SRDeath takes nothing returns nothing
    local unit u = GetTriggerUnit()
    local integer i = 1
    if u == udg_srHero then
        call TriggerSleepAction(15.)
        call ReviveHero(udg_srHero, 0., 0., true)
    else
        loop
            exitwhen i > udg_srCount
            if u == udg_srEnemies[i] then
                set udg_srKills = udg_srKills + 1
                call SetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(Player(0), PLAYER_STATE_RESOURCE_GOLD) + 10)
                if udg_srBoss[i] then
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
        call DisplayTextToPlayer(Player(0), 0., 0., "Commands: -help, -stats")
    elseif s == "-stats" then
        call DisplayTextToPlayer(Player(0), 0., 0., "Kills: " + I2S(udg_srKills))
    endif
endfunction

function InitSoloRPG takes nothing returns nothing
    local trigger t
    if udg_srInitialized then
        return
    endif
    set udg_srInitialized = true
    set t = CreateTrigger()
    call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_DEATH)
    call TriggerAddAction(t, function SRDeath)
    set t = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(t, Player(0), "-", false)
    call TriggerAddAction(t, function SRChat)
    set udg_srDialog = DialogCreate()
    call DialogSetMessage(udg_srDialog, "Choose hero")
    set udg_srPal = DialogAddButton(udg_srDialog, "Paladin", 0)
    set udg_srBlade = DialogAddButton(udg_srDialog, "Blademaster", 0)
    set udg_srMage = DialogAddButton(udg_srDialog, "Archmage", 0)
    set t = CreateTrigger()
    call TriggerRegisterDialogEvent(t, udg_srDialog)
    call TriggerAddAction(t, function SRChoose)
    call DialogDisplay(Player(0), udg_srDialog, true)
    call SRAddSpawn('nfel', 950., 400., false)
    call SRAddSpawn('nfel', 1150., 500., false)
    call SRAddSpawn('nfel', 1300., 650., true)
    set t = null
endfunction
