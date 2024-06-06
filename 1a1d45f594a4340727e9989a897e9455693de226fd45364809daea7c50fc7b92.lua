include 'snort_defaults.lua'

stream = { }
stream_ip = { }
stream_icmp = { }

wizard = default_wizard

binder =
{
    { use = { type = 'wizard' } }
}

ips =
{
	rules =
	[[
		block icmp any any -> any any (msg:"ICMP connection test"; sid:1000001; rev:1;)
	]]
}
