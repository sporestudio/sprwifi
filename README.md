<img alt="logo" width="600px" src="assets/logo/logo-positive.png"/>

# SPRWIFI CRACKER
Tool to automate WiFi attacks (WPA/WPA2 - PSK) aimed at obtaining a password.

</br>


The wifiCrack tool has 2 attack modes. The first one is the Handshake attack, where in an automated way, it manages everything necessary for a classic de-authentication and reconnection attack by a station to obtain a valid Handshake with which it can later work to apply brute force.

The second attack mode is the PKMID ClientLess Attack, which focuses its attention on wireless networks that do not have associated clients (Modern Method).



## Handshake attack mode
Handshake Process:

    Message 1: The AP sends a nonce (a random number) to the client.
    Message 2: The client generates its own nonce, derives a Pairwise Transient Key (PTK) using both nonces and the PSK, and sends its nonce and a Message Integrity Code (MIC) back to the AP.
    Message 3: The AP receives the client's nonce, derives the PTK, and sends another message containing its MIC.
    Message 4: The client confirms the PTK and sends a final message to the AP.

Handshake Capture:

    An attacker can capture this handshake by listening to the communication between the client and AP using tools like airmon-ng and airodump-ng.
    The attacker doesn’t need to be actively connected to the network, just within range to capture the handshake packets.
  
Cracking the Handshake:

    Once the handshake is captured, the attacker can use tools like aircrack-ng to perform a dictionary or brute-force attack on the PSK.
    The attacker uses the captured handshake to verify guesses against the PSK until the correct one is found.
    

## PKIMD attack mode
    Understanding PMKID:
    
        PMKID (Pairwise Master Key Identifier) is used in WPA2 and WPA3 networks to facilitate fast roaming between access points.
        It's a unique key generated from the PMK (Pairwise Master Key), the MAC address of the AP, and the MAC address of the client.

    PKMID Attack Process:
    
        The attacker sends a request to the AP, and the AP responds with an EAPOL (Extensible Authentication Protocol over LAN) frame containing the PMKID.
        Unlike the full 4-way handshake, capturing the PMKID does not require an existing client to be connected to the network.
        This PMKID can be collected simply by sending a request to the AP and waiting for the response, making it less intrusive and quicker than the traditional handshake capture.

    Cracking the PMKID:
    
        With the captured PMKID, the attacker can use tools like hashcat to perform a dictionary or brute-force attack on the PMK.
        The attacker uses the captured PMKID to verify guesses against the PMK until the correct one is found.
        Once the correct PMK is obtained, it can be used to derive the PSK.

        

# HOW TO USE IT  
The tool has 2 parameters, on the one hand the parameter ‘**-a**’ to specify the attack mode (Handshake|PKMID) and on the other hand the parameter **-n** to specify the name of the network card.

In any case, the tool has a help panel after execution:

```bash
[*] Use: :/sprwifi.sh

sprwifi - Next generation wifi cracker version 1.0
Developed by sporestudio


ATTACK MODE:

 -a Handshake:	Captures the authentication message exchange between a client device and a Wi-Fi access point.
		This exchange contains information that can be used to attempt to decrypt the network's security key.

 -a PKMID:	PMKID mode (Pairwise Master Key Identifier), the attacker can capture the PMKID of a Wi-Fi access point
		without needing to capture a complete handshake. The PMKID is an identifier used in the authentication
		process of WPA/WPA2-protected Wi-Fi networks.


NETWORK CARD NAME:

 -n <net_card>:	User network card name


HELP PANEL:

 -h Help panel:	Displays the help panel

```
