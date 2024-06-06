-- Enable hyperscan for IPS, AppID and HTTP inspection
-- Enable hyperscan for pcre/regex matches
search_engine = { search_method = 'hyperscan' }
detection = { hyperscan_literals = true, pcre_to_regex = true }

-- Add SMB port binding to dce_smb inspector
table.insert(
    binder, 2,
    { when = { proto = 'tcp', ports = '445', role='any' }, use = { type = 'dce_smb' } })

--  Enable SMB file inspection (unlimited file size inspection example)
dce_smb.smb_file_depth = 0
dce_smb.policy = 'Win7'

-- Enable ZIP, PDF and SWF decompression in http_inspect
http_inspect.decompress_pdf = true
http_inspect.decompress_swf = true
http_inspect.decompress_zip = true

-- Enable ZIP, PDF and SWF decompression in smtp
smtp.decompress_pdf = true
smtp.decompress_swf = true
smtp.decompress_zip = true

-- Enable logging of email headers and attachments in smtp
smtp.log_email_hdrs = true
smtp.log_filename = true
smtp.log_mailfrom = true
smtp.log_rcptto = true
