Write-Output "$WINDOWN_PFX"
Move-Item -Path $WINDOWS_PFX -Destination zazzychat.pem
certutil -decode zazzychat.pem zazzychat.pfx

flutter pub run msix:create -c zazzychat.pfx -p $WINDOWS_PFX_PASS --sign-msix true --install-certificate false
