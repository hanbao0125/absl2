# add the following function to your terminal configuration/profile
# on Windows GitBash: .bash_profile
# on Linux: .bashrc
# on MacOS: .bash_profile
# once the terminal process is restarted (open a new terminal tab or window) proxy_on and proxy_off will be available as commands
 
function proxy_on(){
    export HTTP_PROXY=http://proxy.sha.sap.corp:8080
    export HTTPS_PROXY=http://proxy.sha.sap.corp:8080
    export NO_PROXY='.local, 169.254/16, .sap.corp, localhost, 127.0.0.1, mail.sap.com, mailamer.sap.com, sip.sap.com, autodiscover.sap.com, .corp.sap'
}
 
function proxy_off(){
    export HTTP_PROXY=
    export HTTPS_PROXY=
    export NO_PROXY=
}

function c4c(){
    cd C:\\Code\\Jerrylaunchpad\\C4C
}