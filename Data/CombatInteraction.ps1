# Variables globales

[bool]$BattleIsActive = $false # Variable traquant si la bataille doit se terminer, ou pas
[int]$PlayerArmor = 0 # Armure passive du joueur (est retranch� � l'attaque de son adversaire)
[bool]$PlayerDefend = $false # Variable traquant si le joueur se d�fend
[int]$BoostArmorValue = 0 # Valeur d'armure suppl�mentaire
[int]$TurnCount = 0 # Nombre de tour
[int]$MinDegatOpp = 0 # D�gat minimum de l'adversaire
[int]$MaxDegatOpp = 10 # D�gat maximum de l'adversaire
[int]$PVOppMax = 100 # PV max adversaire
[int]$PVOpp = 100 # PV Adversaire
[int]$OppXP = 100 # XP gagn� pour avoir tu� l'adversaire
[string]$NameOpp = "Une cr�ature" # Nom affich� de l'adversaire
[bool]$PlayerIsAway = $false # Variable traquant si le joueur s'est enfuit
[bool]$LackAttack = $false # Variable traquant si un debuf d'attaque est actif
[int]$TimeLackAttack = 0 # Variable traquant le temps restant au d�buf
[bool]$LackDefense = $false # Variable traquant si un debuf de defense est actif
[int]$TimeLackDefense = 0 # Variable traquant le temps restant au d�buf
[bool]$BoostAttack = $false # Variable traquant si un Buff d'attaque est actif
[int]$TimeBoostAttack = 0 # Variable traquant le temps restant au Buff
[bool]$BoostDefense = $false # Variable traquant si un buff de d�fense
[int]$TimeBoostDefense = 0 # Variable traquant le temps restant au Buff
[string]$OppAI = "Standard" # Variable d�finnisant le comportement de l'ennemi
[string[]]$OppStatuts = @("None","None","None")
[string[]]$PlayerStatus = @("None","None","None")
[bool]$PlayerTurnOK = $true
[bool]$OppTurnOK = $true

# Fonction Permettant de reset les valeurs avant un prochain combat
function ResetValue ()
{
    $Script:BattleIsActive = $false
    $Script:PlayerArmor = 0
    $Script:PlayerDefend = $false
    $Script:BoostArmorValue = 0
    $Script:TurnCount = 0
    $Script:MinDegatOpp = 0
    $Script:MaxDegatOpp = 10
    $Script:PVOpp = 100
    $Scritp:PVOppMax = 100
    $Script:NameOpp = "Une cr�ature"
    $Script:PlayerIsAway = $false
    $Script:OppXP = 100
    $Script:LackAttack = $false
    $Script:LackDefense = $false
    $Script:BoostAttack = $false
    $Script:BoostDefense = $false
    $Script:TimeBoostDefense = 0
    $Script:TimeLackAttack = 0
    $Script:TimeLackDefense = 0
    $Script:TimeBoostAttack = 0
    $Script:OppAI = "Standard"
    $Script:OppStatuts = "None","None","None"
    $Script:PlayerStatuts = "None","None","None"
    $Script:OppTurnOK = $true
    $Script:PlayerTurnOK = $true
}

# Fonction de combat
function StartBattle ($DegatMinOpp, $DegatMaxOpp, $OppPV, $OppXP, $OppName) 
{
    ResetValue
    # Test conditionel pour emp�cher certaines erreur d'arriver
    if ($DegatMinOpp -eq $null)
    {
        Write-Host "ERREUR : DEMMARAGE DU COMBAT IMPOSSIBLE, INFORMATIONS MANQUANTES" -ForegroundColor Red
    }
    elseif ($DegatMaxOpp -eq $null)
    {
        Write-Host "ERREUR : DEMMARAGE DU COMBAT IMPOSSIBLE, INFORMATIONS MANQUANTES" -ForegroundColor Red
    }
    elseif ($OppPV -eq $null)
    {
        Write-Host "ERREUR : DEMMARAGE DU COMBAT IMPOSSIBLE, INFORMATIONS MANQUANTES" -ForegroundColor Red
    }
    else
    {
        # On d�finit les variables
        $Script:BattleIsActive = $true
        $Script:MinDegatOpp = $DegatMinOpp
        $Script:MaxDegatOpp = $DegatMaxOpp
        $Script:PVOppMax = $OppPV
        $Script:PVOpp = $OppPV
        $Script:PlayerArmor = $ArmurePJ

        if ($OppName -ne $null)
        {
            $Script:NameOpp = $OppName
        }
        if ($OppAttr -ne $null)
        {
            $Script:AttrOpp = $OppAttr
        }
        
        # Boucle de combat
        while ($BattleIsActive -eq $true)
        {
            cls

            if ($PlayerDefend -eq $true)
            {
                # R�tablit l'armure aux valeur de d�part au d�but du tour
                Write-Host "Votre armure revient � son niveau normal..." -ForegroundColor Gray
                $Script:PlayerDefend = $false
                $Script:BoostArmorValue = 0
                echo ""
            }
            
            # Test permettant de comptez le temps restant au diff�rents effet

            if ($LackDefense -eq $true) {$Script:TimeLackDefense--; if($TimeLackDefense -lt 0) {$Script:LackDefense = $false; Write-Host "Votre d�fense redevient normal..." -ForegroundColor Yellow; $Script:TimeLackDefense = 0; echo ""}}
            if ($LackAttack -eq $true) {$Script:TimeLackAttack--; if($TimeLackAttack -lt 0) {$LackAttack = $false; Write-Host "Votre attaque redevient normal..." -ForegroundColor Yellow; $Script:TimeLackAttack = 0; echo ""}}
            if ($BoostDefense -eq $true) {$Script:TimeBoostDefense--; if($TimeBoostDefense -lt 0) {$BoostDefense = $false; Write-Host "Votre d�fense redevient normal..." -ForegroundColor Yellow; $Script:TimeBoostDefense = 0; echo ""}} 
            if ($BoostAttack -eq $true) {$Script:TimeBoostAttack--; if($TimeBoostAttack -lt 0) {$BoostAttack = $false; Write-Host "Votre attaque redevient normal..." -ForegroundColor Yellow; $Script:TimeBoostAttack = 0; echo ""}}

            # On applique les effets de status

            PlayerApplyStatus

            # Le tour du joueur commence concr�tement
            if ($PlayerTurnOK)
            {
                PlayerTurn
            }
            else
            {
                Write-Host "Vous n'arrivez pas � faire quoi que ce soit !!!" -ForegroundColor Red
            }

            # Fin du tour du joueur

            $Script:TurnCount++

            # On fait un test pour savoir si l'adversaire est mort

            $Win = OppCheckDeath

            # Le combat se termine si l'adversaire est mort

            if ($Win -eq $true)
            {
                Write-Host "Vous avez vaincu $NameOpp !" -ForegroundColor Yellow
                XPGain $OppXP
                $Script:BattleIsActive = $false
                break
            }

            # Le combat se termine si le joueur r�ussit � fuir

            if ($PlayerIsAway -eq $true)
            {
                break
            }

            # Si l'adversaire n'est pas mort, c'est � son tour

            # On applique les effets de status

            OppApplyStatus

            if ($OppTurnOK)
            {
                OppTurn
            }
            else
            {
                Write-Host "$OppName n'arrive pas � agir !" -ForegroundColor Green
            }
            pause
        }

    }
    
}

# Tour du joueur

function PlayerTurn () 
{
    Write-Host "[COMBAT] Que faire ?" -ForegroundColor Yellow
    Write-Host "(Attaquer / A ; Se d�fendre / D ; Magie / M ; Inventaire / I ; Tentez de fuir / F)" -ForegroundColor Gray
    $Todo = Read-Host
    # R�alise les diff�rentes fonction suivant le choix du joueur
    if ($Todo -match "i")
    {
        InventoryMenu
    }
    elseif ($Todo -match "a")
    {
        PlayerAttack
    }
    elseif ($Todo -match "d")
    {
        PlayerDefend
    }
    elseif ($Todo -match "m")
    {
        MagicMenu
    }
    elseif ($Todo -match "f")
    {
        PlayerRun
    }
    else
    {
        cls
        PlayerTurn
    }

}

# Fonction d�finissant l'attaque

function PlayerAttack ()
{
    echo ""
    Write-Host "[ATTAQUE] Que faire ?" -ForegroundColor Yellow
    Write-Host "(Attaque L�g�re / L ; Attaque Normal / A ; Attaque Critique / C)" -ForegroundColor Gray
    # R�alise les diff�rentes fonction suivant le choix du joueur
    $Todo = Read-Host
    if ($Todo -match "L")
    {
        echo ""
        Write-Host "Vous lancez une attaque l�g�re !" -ForegroundColor Cyan
        Write-Host "Vous attaquez avec $ArmeEquipe" -ForegroundColor Gray

        # Random des d�gats (appliquant les diff�rents buff / d�buff)

        $Degat = (Randomize $DegatMin $DegatMax) / 2
        if($LackAttack -eq $true) { $Degat = $Degat / 2 }
        if($BoostAttack -eq $true) { $Degat = $Degat * 2 }
        # On retranche les d�gats aux pv de l'adversaire
        $Script:PVOpp = $PVOpp - $Degat

        Start-Sleep 1

        # Random de l'armure (appliquant les diff�rents buff / d�buff)

        $Script:BoostArmorValue += ((Randomize $CarEndurance ($CarEndurance * 10)) / 2)
        if($LackDefense -eq $true) { $Script:BoostArmorValue = $BoostArmorValue / 2 }
        if($BoostDefense -eq $true) { $Script:BoostArmorValue = $BoostArmorValue * 2 }
        # On indique que le joueur se d�fend
        $Script:PlayerDefend = $true
        echo ""
        Write-Host "Vous augementez votre armure de $BoostArmorValue !" -ForegroundColor Green
        echo ""
        Write-Host "Vous infligez $Degat d�gats � $NameOpp !" -ForegroundColor Green
    }
    elseif ($Todo -match "A")
    {
        echo ""
        Write-Host "Vous vous lancez � l'attaque !" -ForegroundColor Cyan
        Write-Host "Vous attaquez avec $ArmeEquipe" -ForegroundColor Gray

        # Random des d�gats (appliquant les diff�rents buff / d�buff)

        $Degat = Randomize $DegatMin $DegatMax
        if($LackAttack -eq $true) { $Degat = $Degat / 2 }
        if($BoostAttack -eq $true) { $Degat = $Degat * 2 }
        # On retranche les d�gats aux pv de l'adversaire
        $Script:PVOpp = $PVOpp - $Degat

        Start-Sleep 1

        echo ""
        Write-Host "Vous infligez $Degat d�gats � $NameOpp !" -ForegroundColor Green
    }
    elseif (($Todo -match "C") -and ($LackAttack -eq $false)) # L'attaque peut �tre lanc� uniquement si un d�buf d'attaque n'est pas actif
    {
        echo ""
        Write-Host "Vous lancez une attaque CRITIQUE !" -ForegroundColor Cyan
        Write-Host "Vous attaquez avec $ArmeEquipe" -ForegroundColor Gray

        # Random des d�gats (appliquant les diff�rents buff / d�buff)

        $Degat = (Randomize $DegatMin $DegatMax) * 2
        if($BoostAttack -eq $true) { $Degat = $Degat * 2 }
        # On retranche les d�gats aux pv de l'adversaire
        $Script:PVOpp = $PVOpp - $Degat
        $Script:LackAttack = $true
        $Script:TimeLackAttack = 2
        Start-Sleep 1
        echo ""
        Write-Host "Vous infligez $Degat d�gats � $NameOpp !" -ForegroundColor Green
        echo ""
        Write-Host "Votre capacit� � attaquer est diminu�e !" -ForegroundColor Red
    }
    else
    {
        echo ""
        Write-Host "Vous n'arrivez pas � attaquer !" -ForegroundColor Red
        Start-Sleep 1
    }
}
 
function PlayerDefend ()
{
    echo ""
    Write-Host "[DEFENSE] Que faire ?" -ForegroundColor Yellow
    Write-Host "(Coup de bouclier / B ; D�fense normal / D ; D�fense critique / C)" -ForegroundColor Gray
    $Todo = Read-Host
    if ($Todo -match "r")
    {
        Write-Host "Vous ass�nez un coup de bouclier !" -ForegroundColor Cyan

        # Random de l'armure (appliquant les diff�rents buff / d�buff)

        $Script:BoostArmorValue += ((Randomize $CarEndurance ($CarEndurance * 5)) / 2)
        if($LackDefense -eq $true) { $Script:BoostArmorValue = $BoostArmorValue / 2 }
        if($BoostDefense -eq $true) { $Script:BoostArmorValue = $BoostArmorValue * 2 }

        # Random des d�gats

        $Degat = (Randomize $DegatMin $DegatMax) / 2
        if($LackAttack -eq $true) { $Degat = $Degat / 2 }
        if($BoostAttack -eq $true) { $Degat = $Degat * 2 }
        # On retranche les d�gats aux pv de l'adversaire
        $Script:PVOpp = $PVOpp - $Degat        

         # On indique que le joueur se d�fend
        $Script:PlayerDefend = $true
        Start-Sleep 1
        Write-Host "Vous infligez $Degat d�gats � $NameOpp !" -ForegroundColor Green
        echo ""
        Write-Host "Vous augementez votre armure de $BoostArmorValue !" -ForegroundColor Green
    }
    elseif ($Todo -match "d")
    {
        Write-Host "Vous vous pr�parez � vous d�fendre !" -ForegroundColor Cyan

        # Random de l'armure (appliquant les diff�rents buff / d�buff)

        $Script:BoostArmorValue += Randomize $CarEndurance ($CarEndurance * 5)
        if($LackDefense -eq $true) { $Script:BoostArmorValue = $BoostArmorValue / 2 }
        if($BoostDefense -eq $true) { $Script:BoostArmorValue = $BoostArmorValue * 2 }
        # On indique que le joueur se d�fend
        $Script:PlayerDefend = $true
        Start-Sleep 1
        echo ""
        Write-Host "Vous augementez votre armure de $BoostArmorValue !" -ForegroundColor Green
    }
    elseif (($Todo -match "c") -and ($LackDefense -eq $false))
    {
        Write-Host "Vous vous pr�parez � une d�fense CRITIQUE !" -ForegroundColor Cyan

        # Random de l'armure (appliquant les diff�rents buff / d�buff)

        $Script:BoostArmorValue += (Randomize $CarEndurance ($CarEndurance * 5)) * 2
        if($BoostDefense -eq $true) { $Script:BoostArmorValue = $BoostArmorValue * 2 }
        # On indique que le joueur se d�fend
        $Script:PlayerDefend = $true
        $Script:LackDefense = $true
        $Script:TimeLackDefense = 2
        Start-Sleep 1
        echo ""
        Write-Host "Vous augementez votre armure de $BoostArmorValue !" -ForegroundColor Green
        echo ""
        Write-Host "Votre capacit� � vous d�fendre est diminu�e !" -ForegroundColor Red
    }
    else
    {
        echo ""
        Write-Host "Vous n'arrivez pas � vous d�fendre !" -ForegroundColor Red
        Start-Sleep 1
    }
}

# Fonction permettant de fuir

function PlayerRun ()
{
    echo ""
    Write-Host "Vous tentez de fuir !" -ForegroundColor Yellow
    [int]$difficulty = 100 - $CarChance
    $run = TryAction $difficulty 0
    if ($run -eq $true)
    {
        $Script:PlayerIsAway = $true
        Write-Host "Vous vous �tes enfui du combat !" -ForegroundColor Cyan
        $Script:CarChance = $CarChance - 2
        if ($CarChance -le 0)
        {
            $Script:CarChance = 0
        }

        Write-Host "Votre chance a baiss�e jusqu'� $CarChance % !" -ForegroundColor DarkYellow
    }
    else
    {
        Write-Host "Vous n'avez pas r�ussi � fuir !" -ForegroundColor Cyan
        $Script:CarChance = $CarChance - 4
        if ($Chance -le 0)
        {
            $Script:Chance = 0
        }

        Write-Host "Votre chance a baiss�e jusqu'� $CarChance % !" -ForegroundColor DarkYellow
    }
}

# Tour de l'adversaire

function OppTurn ()
{
    EnnemyAction $OppAI
}

function OppCheckDeath ()
{
    $dead = $false
    if ($PVOpp -lt 0)
    {
        $dead = $true
    }
    return $dead
}

function PlayerApplyStatus () 
{
    


}

function OppApplyStatus ()
{


}