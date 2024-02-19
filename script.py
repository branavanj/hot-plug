import pygetwindow as gw
import subprocess

# Remplacez 'Nom de la fenetre' par le titre de la fenêtre que vous souhaitez déplacer
window_title = 'cmd'

# Trouver la fenêtre par son titre
window = gw.getWindowsWithTitle(window_title)

# Assurez-vous que la fenêtre est trouvée
if window:
    window = window[0]

    # Déplacer la fenêtre à de nouvelles coordonnées (par exemple, 100, 100)
    window.moveTo(950, 950)

    # Chemin du script PowerShell que vous souhaitez exécuter
    powershell_script_path = r'C:\Users\jeyak\wifi_connect.ps1'

    # Exécuter le script PowerShell en arrière-plan
    subprocess.Popen(['powershell', '-File', powershell_script_path], universal_newlines=True, shell=True)

else:
    print(f"Fenêtre '{window_title}' non trouvée.")
