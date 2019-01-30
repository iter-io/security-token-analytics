
CREATE SCHEMA IF NOT EXISTS ethereum;

-- Users with write privileges
CREATE USER webster WITH PASSWORD 'md5cf665ef3f22dbdbac3d814f411289983';

GRANT ALL ON SCHEMA public TO webster;
GRANT ALL ON ALL TABLES IN SCHEMA public TO webster;

GRANT ALL ON SCHEMA ethereum TO webster;
GRANT ALL ON ALL TABLES IN SCHEMA ethereum TO webster;

-- Group with read-only privileges
CREATE GROUP read_only;

REVOKE ALL ON SCHEMA public FROM GROUP read_only;
REVOKE ALL ON SCHEMA ethereum FROM GROUP read_only;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO GROUP read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA ethereum TO GROUP read_only;

GRANT USAGE ON SCHEMA public TO GROUP read_only;
GRANT USAGE ON SCHEMA ethereum TO GROUP read_only;

-- Read-only users for the data team; passwords are MD5 hashed
CREATE USER emily WITH PASSWORD 'md51ef5fec399320fe29b433cefd0b947b9';
CREATE USER jared WITH PASSWORD 'md56973f062ac9ff074c44728cf5933219f';
CREATE USER louis WITH PASSWORD 'md5f33e04a12adccd1d65ef2cf6cf389c23';
CREATE USER mitchell WITH PASSWORD 'md574a9cff949c98e0ac39bb59fb85fa62b';

ALTER GROUP read_only ADD USER
 emily,
 jared,
 louis,
 mitchell;
