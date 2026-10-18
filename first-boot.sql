-- Run by railway-start in a loop until it prints 'done'. Idempotent.
SELECT to_regclass('instance.login') IS NOT NULL AS ready \gset
\if :ready
-- REI3 seeds admin/admin; replace it with R3_ADMIN_PASSWORD while the default is still set
WITH s AS (SELECT md5(random()::text) AS salt)
UPDATE instance.login SET salt = s.salt, hash = encode(sha256(convert_to(s.salt || :'pw', 'UTF8')), 'hex')
FROM s WHERE name = 'admin' AND :'pw' <> ''
  AND hash = encode(sha256(convert_to(instance.login.salt || 'admin', 'UTF8')), 'hex');
-- links in mails, ICS and client configs use publicHostName (default 'localhost')
UPDATE instance.config SET value = :'host' WHERE name = 'publicHostName' AND value = 'localhost' AND :'host' <> '';
SELECT 'done' WHERE EXISTS (SELECT FROM instance.login WHERE name = 'admin')
  AND NOT EXISTS (SELECT FROM instance.login WHERE name = 'admin'
    AND hash = encode(sha256(convert_to(salt || 'admin', 'UTF8')), 'hex'));
\endif
