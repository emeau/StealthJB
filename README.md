  _________ __                .________________ ___      ____.__________ 
 /   _____//  |_  ____ _____  |  \__    ___/   |   \    |    |\______   \
 \_____  \\   __\/ __ \\__  \ |  | |    | /    ~    \   |    | |    |  _/
 /        \|  | \  ___/ / __ \|  |_|    | \    Y    /\__|    | |    |   \
/_______  /|__|  \___  >____  /____/____|  \___|_  /\________| |______  /
        \/           \/     \/                   \/        @GotoHack  \/ 

    Jailbreak detection features are implanted in order to detect
    when an end user has compromised their device, or to detect
    whether an intruder has compromised a stolen device. For
    example, all MDM application embeds jailbreak detection
    features.

    Nevertheless, jailbreak is mandatory in order to pentest / 
    analyse ios application security. StealthJB is a mobilesubstrate 
    extention that has the hability to hide the jailbreak from
    the application to be analyzed.

    Note: So far, the public version of StealthJB only handle the most
    common jailbreak detection features.

    ==================================================================

    * Building StealthJB:
        $ make
        $ make config

    * Installing StealthJB (require ssh to be installed on the device):
        Connect your idevice
        Launch tcp relay
        $ make install && make installconfig

    ==================================================================

    Help us to improve this project by sending us your patch...





