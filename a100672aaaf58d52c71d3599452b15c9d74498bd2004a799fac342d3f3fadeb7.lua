---------------------------------------------------------------------------
-- Snort++ configuration
---------------------------------------------------------------------------

-- there are over 200 modules available to tune your policy.
-- many can be used with defaults w/o any explicit configuration.
-- use this conf as a template for your specific configuration.

-- 1. configure defaults
-- 2. configure inspection
-- 3. configure bindings
-- 4. configure performance
-- 5. configure detection
-- 6. configure filters
-- 7. configure outputs
-- 8. configure tweaks

---------------------------------------------------------------------------
-- 1. configure defaults
---------------------------------------------------------------------------

-- HOME_NET and EXTERNAL_NET must be set now
-- setup the network addresses you are protecting
-- HOME_NET = 'any'
HOME_NET = [[ 10.0.0.0/8 192.168.0.0/16 172.16.0.0/12 ]]

-- set up the external network addresses.
-- (leave as "any" in most situations)
EXTERNAL_NET = 'any'

include 'snort_defaults.lua'
include 'file_magic.lua'

---------------------------------------------------------------------------
-- 2. configure inspection
---------------------------------------------------------------------------

-- mod = { } uses internal defaults
-- you can see them with snort --help-module mod

-- mod = default_mod uses external defaults
-- you can see them in snort_defaults.lua

-- the following are quite capable with defaults:

stream = { }
stream_ip = { }
stream_icmp = { }
stream_tcp = { }
stream_udp = { }
stream_user = { }
stream_file = { }

arp_spoof = { }
back_orifice = { }
dnp3 = { }
dns = { }
http_inspect = { }
http2_inspect = { }
imap = { }
modbus = { }
normalizer = { }
pop = { }
rpc_decode = { }
sip = { }
ssh = { }
ssl = { }
telnet = { }

dce_smb = { }
dce_tcp = { }
dce_udp = { }
dce_http_proxy = { }
dce_http_server = { }

-- see snort_defaults.lua for default_*
gtp_inspect = default_gtp
port_scan = default_med_port_scan
smtp = default_smtp

ftp_server = default_ftp_server
ftp_client = { }
ftp_data = { }

-- see file_magic.lua for file id rules
-- file_id = { file_rules = file_magic }

file_id =
{
    enable_type = true,
    enable_signature = true,
    file_rules = file_magic,
    file_policy =
    {
        { use = { verdict = 'log', enable_file_type = true, enable_file_signature = true } }
    }
}

-- the following require additional configuration to be fully effective:

appid =
{
    -- appid requires this to use appids in rules
    app_detector_dir = APPID_PATH,
    log_stats = true,
    app_stats_period = 300
}

reputation =
{
    -- configure one or both of these, then uncomment reputation
    blacklist = BLOCK_LIST_PATH .. '/ip-blocklist',
    whitelist = PASS_LIST_PATH .. '/ip-passlist'
}

---------------------------------------------------------------------------
-- 3. configure bindings
---------------------------------------------------------------------------

wizard = default_wizard

binder =
{
    -- port bindings required for protocols without wizard support
    { when = { proto = 'udp', ports = '53', role='server' },  use = { type = 'dns' } },
    { when = { proto = 'tcp', ports = '53', role='server' },  use = { type = 'dns' } },
    { when = { proto = 'tcp', ports = '111', role='server' }, use = { type = 'rpc_decode' } },
    { when = { proto = 'tcp', ports = '502', role='server' }, use = { type = 'modbus' } },
    { when = { proto = 'tcp', ports = '2123 2152 3386', role='server' }, use = { type = 'gtp_inspect' } },

    { when = { proto = 'tcp', service = 'dcerpc' }, use = { type = 'dce_tcp' } },
    { when = { proto = 'udp', service = 'dcerpc' }, use = { type = 'dce_udp' } },

    { when = { service = 'netbios-ssn' },      use = { type = 'dce_smb' } },
    { when = { service = 'dce_http_server' },  use = { type = 'dce_http_server' } },
    { when = { service = 'dce_http_proxy' },   use = { type = 'dce_http_proxy' } },

    { when = { service = 'dnp3' },             use = { type = 'dnp3' } },
    { when = { service = 'dns' },              use = { type = 'dns' } },
    { when = { service = 'ftp' },              use = { type = 'ftp_server' } },
    { when = { service = 'ftp-data' },         use = { type = 'ftp_data' } },
    { when = { service = 'gtp' },              use = { type = 'gtp_inspect' } },
    { when = { service = 'imap' },             use = { type = 'imap' } },
    { when = { service = 'http' },             use = { type = 'http_inspect' } },
    { when = { service = 'http2' },            use = { type = 'http2_inspect' } },
    { when = { service = 'modbus' },           use = { type = 'modbus' } },
    { when = { service = 'pop3' },             use = { type = 'pop' } },
    { when = { service = 'ssh' },              use = { type = 'ssh' } },
    { when = { service = 'sip' },              use = { type = 'sip' } },
    { when = { service = 'smtp' },             use = { type = 'smtp' } },
    { when = { service = 'ssl' },              use = { type = 'ssl' } },
    { when = { service = 'sunrpc' },           use = { type = 'rpc_decode' } },
    { when = { service = 'telnet' },           use = { type = 'telnet' } },

    { use = { type = 'wizard' } }
}

---------------------------------------------------------------------------
-- 4. configure performance
---------------------------------------------------------------------------

-- use latency to monitor / enforce packet and rule thresholds
--latency = { }

-- use these to capture perf data for analysis and tuning
--profiler = { }
--perf_monitor = { }

---------------------------------------------------------------------------
-- 5. configure detection
---------------------------------------------------------------------------

references = default_references
classifications = default_classifications

ips =
{
    mode = tap,

    -- use this to enable decoder and inspector alerts
    --enable_builtin_rules = true,

    -- use include for rules files; be sure to set your path
    -- note that rules files can include other rules files
    --include = 'snort3-community.rules'

    -- The following include syntax is only valid for BUILD_243 (13-FEB-2018) and later
    -- RULE_PATH is typically set in snort_defaults.lua
    rules = [[
        include $RULE_PATH/local.rules
        include $RULE_PATH/snort3-app-detect.rules
        include $RULE_PATH/snort3-browser-chrome.rules
        include $RULE_PATH/snort3-browser-firefox.rules
        include $RULE_PATH/snort3-browser-ie.rules
        include $RULE_PATH/snort3-browser-other.rules
        include $RULE_PATH/snort3-browser-plugins.rules
        include $RULE_PATH/snort3-browser-webkit.rules
        include $RULE_PATH/snort3-content-replace.rules
        include $RULE_PATH/snort3-exploit-kit.rules
        include $RULE_PATH/snort3-file-executable.rules
        include $RULE_PATH/snort3-file-flash.rules
        include $RULE_PATH/snort3-file-identify.rules
        include $RULE_PATH/snort3-file-image.rules
        include $RULE_PATH/snort3-file-java.rules
        include $RULE_PATH/snort3-file-multimedia.rules
        include $RULE_PATH/snort3-file-office.rules
        include $RULE_PATH/snort3-file-other.rules
        include $RULE_PATH/snort3-file-pdf.rules
        include $RULE_PATH/snort3-indicator-compromise.rules
        include $RULE_PATH/snort3-indicator-obfuscation.rules
        include $RULE_PATH/snort3-indicator-scan.rules
        include $RULE_PATH/snort3-indicator-shellcode.rules
        include $RULE_PATH/snort3-malware-backdoor.rules
        include $RULE_PATH/snort3-malware-cnc.rules
        include $RULE_PATH/snort3-malware-other.rules
        include $RULE_PATH/snort3-malware-tools.rules
        include $RULE_PATH/snort3-netbios.rules
        include $RULE_PATH/snort3-os-linux.rules
        include $RULE_PATH/snort3-os-mobile.rules
        include $RULE_PATH/snort3-os-other.rules
        include $RULE_PATH/snort3-os-solaris.rules
        include $RULE_PATH/snort3-os-windows.rules
        include $RULE_PATH/snort3-policy-multimedia.rules
        include $RULE_PATH/snort3-policy-other.rules
        include $RULE_PATH/snort3-policy-social.rules
        include $RULE_PATH/snort3-policy-spam.rules
        include $RULE_PATH/snort3-protocol-dns.rules
        include $RULE_PATH/snort3-protocol-finger.rules
        include $RULE_PATH/snort3-protocol-ftp.rules
        include $RULE_PATH/snort3-protocol-icmp.rules
        include $RULE_PATH/snort3-protocol-imap.rules
        include $RULE_PATH/snort3-protocol-nntp.rules
        include $RULE_PATH/snort3-protocol-other.rules
        include $RULE_PATH/snort3-protocol-pop.rules
        include $RULE_PATH/snort3-protocol-rpc.rules
        include $RULE_PATH/snort3-protocol-scada.rules
        include $RULE_PATH/snort3-protocol-services.rules
        include $RULE_PATH/snort3-protocol-snmp.rules
        include $RULE_PATH/snort3-protocol-telnet.rules
        include $RULE_PATH/snort3-protocol-tftp.rules
        include $RULE_PATH/snort3-protocol-voip.rules
        include $RULE_PATH/snort3-pua-adware.rules
        include $RULE_PATH/snort3-pua-other.rules
        include $RULE_PATH/snort3-pua-p2p.rules
        include $RULE_PATH/snort3-pua-toolbars.rules
        include $RULE_PATH/snort3-server-apache.rules
        include $RULE_PATH/snort3-server-iis.rules
        include $RULE_PATH/snort3-server-mail.rules
        include $RULE_PATH/snort3-server-mssql.rules
        include $RULE_PATH/snort3-server-mysql.rules
        include $RULE_PATH/snort3-server-oracle.rules
        include $RULE_PATH/snort3-server-other.rules
        include $RULE_PATH/snort3-server-samba.rules
        include $RULE_PATH/snort3-server-webapp.rules
        include $RULE_PATH/snort3-sql.rules
        include $RULE_PATH/snort3-x11.rules

    ]]
}

rewrite = { }

-- use these to configure additional rule actions
-- react = { }
-- reject = { }

-- use this to enable payload injection utility
-- payload_injector = { }

---------------------------------------------------------------------------
-- 6. configure filters
---------------------------------------------------------------------------

-- below are examples of filters
-- each table is a list of records

--[[
suppress =
{
    -- don't want to any of see these
    { gid = 1, sid = 1 },

    -- don't want to see these for a given server
    { gid = 1, sid = 2, track = 'by_dst', ip = '1.2.3.4' },
}
--]]

--[[
event_filter =
{
    -- reduce the number of events logged for some rules
    { gid = 1, sid = 1, type = 'limit', track = 'by_src', count = 2, seconds = 10 },
    { gid = 1, sid = 2, type = 'both',  track = 'by_dst', count = 5, seconds = 60 },
}
--]]

--[[
rate_filter =
{
    -- alert on connection attempts from clients in SOME_NET
    { gid = 135, sid = 1, track = 'by_src', count = 5, seconds = 1,
      new_action = 'alert', timeout = 4, apply_to = '[$SOME_NET]' },

    -- alert on connections to servers over threshold
    { gid = 135, sid = 2, track = 'by_dst', count = 29, seconds = 3,
      new_action = 'alert', timeout = 1 },
}
--]]

---------------------------------------------------------------------------
-- 7. configure outputs
---------------------------------------------------------------------------

-- event logging
-- you can enable with defaults from the command line with -A <alert_type>
-- uncomment below to set non-default configs
--alert_csv = { }
--alert_fast = { }
--alert_full = { }
--alert_sfsocket = { }
--alert_syslog = { }
--unified2 = { }

-- packet logging
-- you can enable with defaults from the command line with -L <log_type>
--log_codecs = { }
--log_hext = { }
--log_pcap = { }

-- additional logs
--packet_capture = { }
--file_log = { }

alert_fast =
{
    file = true
}

file_log = 
{
    log_pkt_time = true,
    log_sys_time = false
}

data_log =
{
    key = 'http_request_header_event',
    limit = 100
}

alert_syslog =
{
    facility = local7,
    level = alert,
    options = pid
}

alert_json =
{
    file = true,
    limit = 100,
    fields = 'timestamp iface src_addr src_port dst_addr dst_port proto action msg priority class sid'
}

---------------------------------------------------------------------------
-- 8. configure tweaks
---------------------------------------------------------------------------

if ( tweaks ~= nil ) then
    include(tweaks .. '.lua')
end

