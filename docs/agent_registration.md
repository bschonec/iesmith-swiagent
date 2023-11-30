copy:

ca_cert.crt
provisioning.pfx
SolarWindsAgent.ini


to a temp directory. NONE of the files get copied to /opt/Solarwinds in any form.  These files are only needed by the swiagentaid.sh script to register the agent to SW.  The files can be deleted after the agent is registered.

Ensure that you specify the FULL PATH of the certs/ini files in the command line.

cd <tmpdir>
# the minimum required to get the agent running and registered at the SW GUI is:

  1)  create the ini file in a temp location
  2)  copy the provisioning.pfx file to temp location
  3)  copy the ca_cert.crt file to a temp location
  4)  run: /opt/SolarWinds/Agent/bin/swiagentaid.sh init /installcert /s iniFile=$PWD/SolarWindsAgent.ini ca_cert=$PWD/ca_cert.crt cert=$PWD/provisioning.pfx
  5) systemctl start swiagentd

The agent should be registered with SW GUI at this time.  It will take about a minute before the agent shows up as managed/running/connected.

After the agent is registered, the following files/directories will be created in /opt/Solarwinds/Agent/bin:
  appdata
  cert
  swiagent.cfg

Ensure you view the agent at https://solarwinds.nfii.com/Orion/AgentManagement/Admin/ManageAgents.aspx

An 'rpm -e swiagent' will uninstall AND unregister the agent at the Solarwinds server.   The agent will show as "Agent is uninstalled" at SW gui.  You must delete the agent from the GUI.  The 'rpm -e' doesn't remove the agent from SW.



Solarwinds install from the install.sh:

- contains certificates and passwords in base64 encoding
- 


It appears that the swiagentd.sh init script REQUIRES that the certificates and such file be referenced by full path.
/opt/SolarWinds/Agent/bin/swiagentaid.sh init /installcert /s iniFile=$PWD/tmp.fyb8uXY4ue/SolarWindsAgent.ini ca_cert=$PWD/tmp.fyb8uXY4ue/ca_cert.crt cert=$PWD/tmp.fyb8uXY4ue/provisioning.pfx 

systemctl start swiagentd

it takes about 15 seconds before the agent will appear ready/green/registered at the SW gui.
Watch the swiagentd :

journalctl -xe -f -u swiagentd

EXAMPLE OUTPUT:
-- The start-up result is done.
Nov 30 10:06:58 nfiv-cis-01d swiagent[10230]: SolarWinds Agent[10230]: SolarWinds Orion Agent (provisioning) [2023.2.1.2035] was started, built with OpenSSL version [OpenSSL 1.1.1t  7 Feb 2023]
Nov 30 10:07:00 nfiv-cis-01d swiagent[10230]: SolarWinds Agent[10230]: SolarWinds Orion Agent [2023.2.1.2035] was started, built with OpenSSL version [OpenSSL 1.1.1t  7 Feb 2023]
Nov 30 10:07:09 nfiv-cis-01d swiagent[10230]: SolarWinds Agent[10230]: SolarWinds Agent with Device ID [0783EBF8-4D33-45F9-9F4D-9A5E17DE396C] was connected to [8A7B3D9E-3E09-4CEC-B739-58B11EC93632.AMS]
Nov 30 10:07:10 nfiv-cis-01d swiagent[10230]: SolarWinds Agent[10230]: SolarWinds Agent with Device ID [0783EBF8-4D33-45F9-9F4D-9A5E17DE396C] was connected to [8A7B3D9E-3E09-4CEC-B739-58B11EC936





