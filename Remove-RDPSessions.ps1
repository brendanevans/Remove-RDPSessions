#Written by Brendan Evans

#Declare Log Details
$LogFile = $env:PROGRAMDATA + "\Remove-RDPSessions.log"
Function LogWrite {
    Param ([string]$LogString)
    Add-Content $LogFile -value $LogString
}

LogWrite "==============================================================="
LogWrite "Script started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')"
LogWrite "---------------------------------------------------------------"

#Declare Blank Array for Output
$Users = @()

#Grab the current sessions and split them into an array
LogWrite "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') :: Getting current session information..."
$Sessions = Query Session
1..($Sessions.Count -1) | % {
    $tempDetails = "" | Select SessionName, Username, ID, State, Type, Device
    $tempDetails.SessionName = $Sessions[$_].Substring(1,18).Trim()
    $tempDetails.Username = $Sessions[$_].Substring(19,20).Trim()
    $tempDetails.ID = $Sessions[$_].Substring(39,9).Trim()
    $tempDetails.State = $Sessions[$_].Substring(48,8).Trim()
    $tempDetails.Type = $Sessions[$_].Substring(56,12).Trim()
    $tempDetails.Device = $Sessions[$_].Substring(68).Trim()
    $Users += $tempDetails
    LogWrite "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') :: Session found for $($tempDetails.Username) with current state '$($tempDetails.State)'."
}

LogWrite "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') :: Attempting to logoff any disconnected sessions..."

#Iterate through the array and logoff any disconnected sessions
For ($i=0;$i -lt $Users.Length;$i++) {
    if ($Users[$i].State -eq "Disc" -and $Users[$i].Username -ne "") {
        Logoff $Users[$i].ID
        LogWrite "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') :: Session for $($Users[$i].Username) has been logged off cleanly."
    }

}
LogWrite "---------------------------------------------------------------"
LogWrite "Script completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff')"
LogWrite "==============================================================="
